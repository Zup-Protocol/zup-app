import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/core/exceptions/ethers_exceptions.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/create/deposit/widgets/deposit_success_modal.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/v3_pool_constants.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

part "preview_deposit_modal_cubit.freezed.dart";
part "preview_deposit_modal_state.dart";

class PreviewDepositModalCubit extends Cubit<PreviewDepositModalState> with V3PoolConversorsMixin, DeviceInfoMixin {
  PreviewDepositModalCubit({
    required BigInt initialPoolTick,
    required UniswapV3Pool uniswapV3Pool,
    required YieldDto currentYield,
    required Erc20 erc20,
    required Wallet wallet,
    required UniswapPositionManager uniswapPositionManager,
    required GlobalKey<NavigatorState> navigatorKey,
    required bool depositWithNative,
  })  : _yield = currentYield,
        _uniswapV3Pool = uniswapV3Pool,
        _erc20 = erc20,
        _wallet = wallet,
        _uniswapPositionManager = uniswapPositionManager,
        _latestPoolTick = initialPoolTick,
        _navigatorKey = navigatorKey,
        _depositWithNative = depositWithNative,
        super(const PreviewDepositModalState.loading());

  final UniswapV3Pool _uniswapV3Pool;
  final Erc20 _erc20;
  final YieldDto _yield;
  final Wallet _wallet;
  final UniswapPositionManager _uniswapPositionManager;
  final GlobalKey<NavigatorState> _navigatorKey;
  final bool _depositWithNative;

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
      final tx = await contract.approve(spender: _yield.protocol.positionManager, value: value);

      emit(PreviewDepositModalState.waitingTransaction(txId: tx.hash, type: WaitingTransactionType.approve));

      await tx.waitConfirmation();

      try {
        await _getTokensAllowance(canThrow: true);
      } catch (e) {
        if (_yield.token0.address == token.address) _token0Allowance = value;
        if (_yield.token1.address == token.address) _token1Allowance = value;
      }

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
    required Slippage slippage,
    required Duration deadline,
  }) async {
    try {
      emit(const PreviewDepositModalState.depositing());
      await _maybeSwitchNetwork();

      final positionManagerContract = _uniswapPositionManager.fromSigner(
        contractAddress: _yield.protocol.positionManager,
        signer: _wallet.signer!,
      );

      BigInt tickLower() {
        BigInt convertPriceToTickLower() {
          if (isMinPriceInfinity && !isReversed) return V3PoolConstants.minTick;
          if (isReversed && isMaxPriceInfinity) return V3PoolConstants.minTick;

          return priceToTick(
            price: isReversed ? maxPrice : minPrice,
            poolToken0Decimals: _yield.token0.decimals,
            poolToken1Decimals: _yield.token1.decimals,
            isReversed: isReversed,
          );
        }

        return tickToClosestValidTick(
          tick: convertPriceToTickLower(),
          tickSpacing: _yield.tickSpacing,
        );
      }

      BigInt tickUpper() {
        BigInt convertPriceToTickUpper() {
          if (isMaxPriceInfinity && !isReversed) return V3PoolConstants.maxTick;
          if (isReversed && isMinPriceInfinity) return V3PoolConstants.maxTick;

          return priceToTick(
            price: isReversed ? minPrice : maxPrice,
            poolToken0Decimals: _yield.token0.decimals,
            poolToken1Decimals: _yield.token1.decimals,
            isReversed: isReversed,
          );
        }

        return tickToClosestValidTick(
          tick: convertPriceToTickUpper(),
          tickSpacing: _yield.tickSpacing,
        );
      }

      final amount0Desired = token0Amount;
      final amount1Desired = token1Amount;
      final amount0Min = slippage.calculateTokenAmountFromSlippage(amount0Desired);
      final amount1Min = slippage.calculateTokenAmountFromSlippage(amount1Desired);

      final TransactionResponse tx = await () async {
        if (_depositWithNative) {
          final mintCalldata = _uniswapPositionManager.getMintCalldata(
            params: (
              amount0Desired: amount0Desired,
              amount1Desired: amount1Desired,
              deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
              amount0Min: amount0Min,
              amount1Min: amount1Min,
              recipient: await _wallet.signer!.address,
              tickLower: tickLower(),
              tickUpper: tickUpper(),
              fee: BigInt.from(_yield.feeTier),
              token0: _yield.token0.address,
              token1: _yield.token1.address,
            ),
          );

          return await positionManagerContract.multicall(
              data: [
                mintCalldata,
                if (_depositWithNative) _uniswapPositionManager.getRefundETHCalldata(),
              ],
              ethValue: () {
                if (_depositWithNative && _yield.isToken0WrappedNative) {
                  return amount0Desired;
                }

                if (_depositWithNative && _yield.isToken1WrappedNative) {
                  return amount1Desired;
                }

                return BigInt.zero;
              }.call());
        }

        return await positionManagerContract.mint(
          params: (
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: await _wallet.signer!.address,
            tickLower: tickLower(),
            tickUpper: tickUpper(),
            fee: BigInt.from(_yield.feeTier),
            token0: _yield.token0.address,
            token1: _yield.token1.address,
          ),
        );
      }.call();

      emit(PreviewDepositModalState.waitingTransaction(txId: tx.hash, type: WaitingTransactionType.deposit));

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
      if ((await _wallet.connectedNetwork).hexChainId == _yield.network.chainInfo.hexChainId) return;

      await _wallet.switchOrAddNetwork(_yield.network.chainInfo);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _getTokensAllowance({bool canThrow = false}) async {
    try {
      final token0contract = _erc20.fromRpcProvider(
        contractAddress: _yield.token0.address,
        rpcUrl: _yield.network.rpcUrl,
      );

      final token1contract = _erc20.fromRpcProvider(
        contractAddress: _yield.token1.address,
        rpcUrl: _yield.network.rpcUrl,
      );

      final token0Allowance = await token0contract.allowance(
        owner: await _wallet.signer!.address,
        spender: _yield.protocol.positionManager,
      );

      final token1Allowance = await token1contract.allowance(
        owner: await _wallet.signer!.address,
        spender: _yield.protocol.positionManager,
      );

      _token0Allowance = token0Allowance;
      _token1Allowance = token1Allowance;
    } catch (e) {
      if (canThrow) rethrow;
    }
  }

  void _updateTick() {
    final uniswapV3PoolContract = _uniswapV3Pool.fromRpcProvider(
      contractAddress: _yield.poolAddress,
      rpcUrl: _yield.network.rpcUrl,
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

  void _waitTransactionFinishBeforeClosing() {
    final context = _navigatorKey.currentContext!;
    final stateAsWaitingTransaction = state as _WaitingTransaction;

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      ScaffoldMessenger.of(context).showSnackBar(() {
        return switch (stateAsWaitingTransaction.type) {
          WaitingTransactionType.deposit => ZupSnackBar(
              context,
              message: "${S.of(context).previewDepositModalCubitDepositingSnackBarMessage(
                    token0Symbol: _yield.maybeNativeToken0(permitNative: _depositWithNative).symbol,
                    token1Symbol: _yield.maybeNativeToken1(permitNative: _depositWithNative).symbol,
                  )} ",
              customIcon: const ZupCircularLoadingIndicator(size: 20),
              type: ZupSnackBarType.info,
              maxWidth: 500,
              snackDuration: const Duration(days: 10),
              helperButton: (
                title: S.of(context).previewDepositModalWaitingTransactionSnackBarHelperButtonTitle,
                onButtonTap: () => _yield.network.openTx(stateAsWaitingTransaction.txId),
              ),
            ),
          WaitingTransactionType.approve => ZupSnackBar(
              context,
              message: "${S.of(context).previewDepositModalCubitApprovingSnackBarMessage} ",
              type: ZupSnackBarType.info,
              maxWidth: 400,
              helperButton: (
                title: S.of(context).previewDepositModalWaitingTransactionSnackBarHelperButtonTitle,
                onButtonTap: () => _yield.network.openTx(stateAsWaitingTransaction.txId)
              ),
              customIcon: const ZupCircularLoadingIndicator(size: 20),
              snackDuration: const Duration(minutes: 10),
            )
        };
      }.call());
    });

    stream.listen((state) async {
      await state.maybeWhen(
        approveSuccess: (txId, symbol) {
          WidgetsBinding.instance.addPostFrameCallback((_) async {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(
              ZupSnackBar(
                context,
                message: S.of(context).previewDepositModalCubitApprovedSnackBarMessage(tokenSymbol: symbol),
                maxWidth: 400,
                type: ZupSnackBarType.success,
                snackDuration: const Duration(seconds: 5),
              ),
            );
          });
        },
        depositSuccess: (txId) async {
          WidgetsBinding.instance.addPostFrameCallback(
            (_) async => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
          );

          DepositSuccessModal.show(
            context,
            depositedYield: _yield,
            showAsBottomSheet: isMobileSize(context),
            depositedWithNative: _depositWithNative,
          );
        },
        orElse: () async {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      );

      close();
    });
  }

  @override
  Future<void> close() async {
    if (state is _WaitingTransaction) {
      return _waitTransactionFinishBeforeClosing();
    }

    await _poolTickStreamController.close();
    super.close();
  }
}
