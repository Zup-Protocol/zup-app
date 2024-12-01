import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/exceptions/ethers_exceptions.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/fee_controller.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/zup_router.abi.g.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/v3_pool_constants.dart';

part "preview_deposit_modal_cubit.freezed.dart";
part "preview_deposit_modal_state.dart";

class PreviewDepositModalCubit extends Cubit<PreviewDepositModalState> with V3PoolConversorsMixin {
  PreviewDepositModalCubit({
    required BigInt initialPoolTick,
    required UniswapV3Pool uniswapV3Pool,
    required YieldDto currentYield,
    required Erc20 erc20,
    required Wallet wallet,
    required ZupRouter zupRouter,
    required UniswapPositionManager uniswapPositionManager,
    required FeeController feeController,
  })  : _yield = currentYield,
        _uniswapV3Pool = uniswapV3Pool,
        _erc20 = erc20,
        _wallet = wallet,
        _zupRouter = zupRouter,
        _feeController = feeController,
        _uniswapPositionManager = uniswapPositionManager,
        _latestPoolTick = initialPoolTick,
        super(const PreviewDepositModalState.loading());

  final UniswapV3Pool _uniswapV3Pool;
  final Erc20 _erc20;
  final YieldDto _yield;
  final Wallet _wallet;
  final ZupRouter _zupRouter;
  final FeeController _feeController;
  final UniswapPositionManager _uniswapPositionManager;

  final StreamController<BigInt> _poolTickStreamController = StreamController<BigInt>.broadcast();

  BigInt _latestPoolTick = BigInt.zero;
  BigInt _token0Allowance = BigInt.zero;
  BigInt _token1Allowance = BigInt.zero;

  Stream<BigInt> get poolTickStream => _poolTickStreamController.stream;
  BigInt get latestPoolTick => _latestPoolTick;
  BigInt get token0Allowance => _token0Allowance;
  BigInt get token1Allowance => _token1Allowance;

  Future<void> setup() async {
    _poolTickStreamController.add(_latestPoolTick);

    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_poolTickStreamController.isClosed) return timer.cancel();

      _updateTick();
    });

    await _getTokensAllowance();

    emit(
      PreviewDepositModalState.initial(
        token0Allowance: _token0Allowance,
        token1Allowance: _token1Allowance,
      ),
    );
  }

  Future<void> approveToken(TokenDto token, BigInt value) async {
    try {
      emit(PreviewDepositModalState.approvingToken(token.symbol));

      await _maybeSwitchNetwork();

      final contract = _erc20.fromSigner(contractAddress: token.address, signer: _wallet.signer!);
      final tx = await contract.approve(spender: _yield.network.zupRouterAddress!, value: value);

      emit(PreviewDepositModalState.waitingTransaction(txId: tx.hash));

      await tx.waitConfirmation();

      if (_yield.token0.address == token.address) _token0Allowance = value;
      if (_yield.token1.address == token.address) _token1Allowance = value;

      emit(PreviewDepositModalState.approveSuccess(txId: tx.hash, symbol: token.symbol));
      emit(PreviewDepositModalState.initial(token0Allowance: _token0Allowance, token1Allowance: _token1Allowance));
    } catch (e) {
      if (e is UserRejectedAction) {
        return emit(
          PreviewDepositModalState.initial(token0Allowance: _token0Allowance, token1Allowance: _token1Allowance),
        );
      }

      emit(const PreviewDepositModalState.transactionError());
      emit(PreviewDepositModalState.initial(token0Allowance: _token0Allowance, token1Allowance: _token1Allowance));
    }
  }

  Future<void> deposit({
    required BigInt token0Amount,
    required BigInt token1Amount,
    required double minPrice,
    required double maxPrice,
    required bool isMinPriceInfinity,
    required bool isMaxPriceInfinity,
    required bool isReversed,
  }) async {
    try {
      emit(const PreviewDepositModalState.depositing());
      await _maybeSwitchNetwork();

      final zupRouterContract = _zupRouter.fromSigner(
        contractAddress: _yield.network.zupRouterAddress!,
        signer: _wallet.signer!,
      );

      final feeControllerContract = _feeController.fromRpcProvider(
        contractAddress: _yield.network.feeControllerAddress!,
        rpcUrl: _yield.network.rpcUrl ?? "",
      );

      final fee = await feeControllerContract.calculateJoinPoolFee(
        token0Amount: token0Amount,
        token1Amount: token1Amount,
      );

      BigInt tickLower() {
        if (isMinPriceInfinity && !isReversed) return V3PoolConstants.minTick;
        if (isReversed && isMaxPriceInfinity) return V3PoolConstants.minTick;

        return tickToClosestValidTick(
          tick: priceToTick(
            price: isReversed ? maxPrice : minPrice,
            poolToken0Decimals: _yield.token0.decimals,
            poolToken1Decimals: _yield.token1.decimals,
            isReversed: isReversed,
          ),
          tickSpacing: _yield.tickSpacing,
        );
      }

      BigInt tickUpper() {
        if (isMaxPriceInfinity && !isReversed) return V3PoolConstants.maxTick;
        if (isReversed && isMinPriceInfinity) return V3PoolConstants.maxTick;

        return tickToClosestValidTick(
          tick: priceToTick(
            price: isReversed ? minPrice : maxPrice,
            poolToken0Decimals: _yield.token0.decimals,
            poolToken1Decimals: _yield.token1.decimals,
            isReversed: isReversed,
          ),
          tickSpacing: _yield.tickSpacing,
        );
      }

      final depositData = _uniswapPositionManager.getMintCalldata(
        params: (
          amount0Desired: token0Amount - fee.feeToken0,
          amount1Desired: token1Amount - fee.feeToken1,
          // TODO: add deadline in the configs and tests for it
          deadline: BigInt.from(DateTime.now().add(const Duration(minutes: 10)).millisecondsSinceEpoch),
          // TODO: add slippage in the configs and tests for it
          amount0Min: BigInt.from(0),
          // TODO: add slippage in the configs and tests for it
          amount1Min: BigInt.from(0),
          recipient: await _wallet.signer!.address,
          tickLower: tickLower(),
          tickUpper: tickUpper(),
          fee: BigInt.from(_yield.feeTier),
          token0: _yield.token0.address,
          token1: _yield.token1.address,
        ),
      );

      final tx = await zupRouterContract.deposit(
        token0: (amount: token0Amount, token: _yield.token0.address),
        token1: (amount: token1Amount, token: _yield.token1.address),
        positionManager: _yield.positionManagerAddress,
        depositData: depositData,
      );

      emit(PreviewDepositModalState.waitingTransaction(txId: tx.hash));

      await tx.waitConfirmation();

      emit(PreviewDepositModalState.depositSuccess(txId: tx.hash));
    } catch (e) {
      if (e is UserRejectedAction) {
        return emit(
          PreviewDepositModalState.initial(
            token0Allowance: _token0Allowance,
            token1Allowance: _token1Allowance,
          ),
        );
      }

      emit(const PreviewDepositModalState.transactionError());
      emit(PreviewDepositModalState.initial(token0Allowance: _token0Allowance, token1Allowance: _token1Allowance));
    }
  }

  Future<void> _maybeSwitchNetwork() async {
    try {
      if ((await _wallet.connectedNetwork).hexChainId == _yield.network.chainInfo!.hexChainId) return;

      await _wallet.switchOrAddNetwork(_yield.network.chainInfo!);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getTokensAllowance() async {
    try {
      final token0contract = _erc20.fromRpcProvider(
        contractAddress: _yield.token0.address,
        rpcUrl: _yield.network.rpcUrl!,
      );

      final token1contract = _erc20.fromRpcProvider(
        contractAddress: _yield.token1.address,
        rpcUrl: _yield.network.rpcUrl!,
      );

      final token0Allowance = await token0contract.allowance(
        owner: await _wallet.signer!.address,
        spender: _yield.network.zupRouterAddress!,
      );

      final token1Allowance = await token1contract.allowance(
        owner: await _wallet.signer!.address,
        spender: _yield.network.zupRouterAddress!,
      );

      _token0Allowance = token0Allowance;
      _token1Allowance = token1Allowance;
    } catch (e) {
      // DO NOTHING
    }
  }

  void _updateTick() {
    final uniswapV3PoolContract = _uniswapV3Pool.fromRpcProvider(
      contractAddress: _yield.poolAddress,
      rpcUrl: _yield.network.rpcUrl ?? "",
    );

    try {
      uniswapV3PoolContract.slot0().then((slot0) {
        _poolTickStreamController.add(slot0.tick);
        _latestPoolTick = slot0.tick;
      });
    } catch (_) {
      // DO NOTHING
    }
  }

  @override
  Future<void> close() async {
    await _poolTickStreamController.close();
    return super.close();
  }
}
