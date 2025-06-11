import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/core/exceptions/ethers_exceptions.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/uniswap_permit2.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/app/create/deposit/widgets/deposit_success_modal.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/v3_v4_pool_constants.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

part "preview_deposit_modal_cubit.freezed.dart";
part "preview_deposit_modal_state.dart";

class PreviewDepositModalCubit extends Cubit<PreviewDepositModalState> with V3PoolConversorsMixin, DeviceInfoMixin {
  PreviewDepositModalCubit({
    required BigInt initialPoolTick,
    required PoolService poolService,
    required YieldDto currentYield,
    required Erc20 erc20,
    required Wallet wallet,
    required UniswapV3PositionManager uniswapPositionManager,
    required UniswapPermit2 permit2,
    required GlobalKey<NavigatorState> navigatorKey,
    required ZupAnalytics zupAnalytics,
  })  : _yield = currentYield,
        _poolRepository = poolService,
        _erc20 = erc20,
        _wallet = wallet,
        _latestPoolTick = initialPoolTick,
        _navigatorKey = navigatorKey,
        _zupAnalytics = zupAnalytics,
        _permit2 = permit2,
        super(const PreviewDepositModalState.loading());

  final PoolService _poolRepository;
  final Erc20 _erc20;
  final YieldDto _yield;
  final Wallet _wallet;
  final GlobalKey<NavigatorState> _navigatorKey;

  final ZupAnalytics _zupAnalytics;
  final UniswapPermit2 _permit2;

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
      final spender = _yield.poolType.isV4 ? _yield.permit2! : _yield.positionManagerAddress;
      final tokenAddressInNetwork = token.addresses[_yield.network.chainId]!;
      emit(PreviewDepositModalState.approvingToken(token.symbol));

      await _maybeSwitchNetwork();

      final contract = _erc20.fromSigner(
        contractAddress: tokenAddressInNetwork,
        signer: _wallet.signer!,
      );

      final tx = await contract.approve(spender: spender, value: value);

      if (_yield.poolType.isV4) checkOrApprovePermit2ForV4Pool(value, token);

      emit(PreviewDepositModalState.waitingTransaction(txId: tx.hash, type: WaitingTransactionType.approve));

      await tx.waitConfirmation();

      try {
        await _getTokensAllowance(canThrow: true);
      } catch (e) {
        if (_yield.token0.addresses[_yield.network.chainId] == tokenAddressInNetwork) _token0Allowance = value;
        if (_yield.token1.addresses[_yield.network.chainId] == tokenAddressInNetwork) _token1Allowance = value;
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

  Future<void> checkOrApprovePermit2ForV4Pool(BigInt approveValue, TokenDto token) async {
    final tokenAddressInNetwork = token.addresses[_yield.network.chainId]!;

    final permit2Contract = _permit2.fromSigner(
      contractAddress: _yield.permit2!,
      signer: _wallet.signer!,
    );

    final permit2CurrentAllowance = await permit2Contract.allowance(
      await _wallet.signer!.address,
      tokenAddressInNetwork,
      _yield.positionManagerAddress,
    );

    if (permit2CurrentAllowance.amount <= approveValue ||
        permit2CurrentAllowance.expiration < BigInt.from(DateTime.now().millisecondsSinceEpoch / 1000)) {
      final tx = await permit2Contract.approve(
        token: tokenAddressInNetwork,
        spender: _yield.positionManagerAddress,
        amount: EthereumConstants.uint160Max,
        expiration: EthereumConstants.uint48Max,
      );

      await tx.waitConfirmation();
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

      BigInt tickLower() {
        BigInt convertPriceToTickLower() {
          if (isMinPriceInfinity && !isReversed) return V3V4PoolConstants.minTick;
          if (isReversed && isMaxPriceInfinity) return V3V4PoolConstants.minTick;

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
          if (isMaxPriceInfinity && !isReversed) return V3V4PoolConstants.maxTick;
          if (isReversed && isMinPriceInfinity) return V3V4PoolConstants.maxTick;

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
      final amount0Min = slippage.calculateMinTokenAmountFromSlippage(amount0Desired);
      final amount1Min = slippage.calculateMinTokenAmountFromSlippage(amount1Desired);
      final recipient = await _wallet.signer!.address;

      final TransactionResponse tx = await () async {
        if (_yield.poolType.isV3) {
          return await _poolRepository.sendV3PoolDepositTransaction(
            _yield,
            _wallet.signer!,
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            deadline: deadline,
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: recipient,
            tickLower: tickLower(),
            tickUpper: tickUpper(),
          );
        }

        await checkOrApprovePermit2ForV4Pool(amount0Desired, _yield.token0);
        await checkOrApprovePermit2ForV4Pool(amount1Desired, _yield.token1);

        return await _poolRepository.sendV4PoolDepositTransaction(
          _yield,
          _wallet.signer!,
          deadline: deadline,
          tickLower: tickLower(),
          tickUpper: tickUpper(),
          amount0toDeposit: amount0Desired,
          amount1ToDeposit: amount1Desired,
          maxAmount0ToDeposit: slippage.calculateMaxTokenAmountFromSlippage(amount0Desired),
          maxAmount1ToDeposit: slippage.calculateMaxTokenAmountFromSlippage(amount1Desired),
          recipient: recipient,
          currentPoolTick: _latestPoolTick,
        );
      }.call();

      emit(PreviewDepositModalState.waitingTransaction(txId: tx.hash, type: WaitingTransactionType.deposit));

      await tx.waitConfirmation();

      emit(PreviewDepositModalState.depositSuccess(txId: tx.hash));
      _zupAnalytics.logDeposit(
        depositedYield: _yield,
        amount0: amount0Desired.parseTokenAmount(decimals: _yield.token0.decimals),
        amount1: amount1Desired.parseTokenAmount(decimals: _yield.token1.decimals),
        walletAddress: recipient,
      );
    } catch (e) {
      if (e.toString().toLowerCase().contains("slippage")) {
        emit(const PreviewDepositModalState.slippageCheckError());
        emit(PreviewDepositModalState.initial(token0Allowance: _token0Allowance, token1Allowance: _token1Allowance));

        return;
      }

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
      final spender = _yield.poolType.isV4 ? _yield.permit2! : _yield.positionManagerAddress;
      final owner = await _wallet.signer!.address;

      if (!_yield.isToken0Native) {
        final token0contract = _erc20.fromRpcProvider(
          contractAddress: _yield.token0.addresses[_yield.network.chainId]!,
          rpcUrl: _yield.network.rpcUrl,
        );

        _token0Allowance = await token0contract.allowance(
          owner: owner,
          spender: spender,
        );
      }

      if (!_yield.isToken1Native) {
        final token1contract = _erc20.fromRpcProvider(
          contractAddress: _yield.token1.addresses[_yield.network.chainId]!,
          rpcUrl: _yield.network.rpcUrl,
        );

        _token1Allowance = await token1contract.allowance(
          owner: owner,
          spender: spender,
        );
      }
    } catch (e) {
      if (canThrow) rethrow;
    }
  }

  void _updateTick() {
    try {
      _poolRepository.getPoolTick(_yield).then((tick) {
        _latestPoolTick = tick;
        _poolTickStreamController.add(tick);
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
                    token0Symbol: _yield.token0.symbol,
                    token1Symbol: _yield.token1.symbol,
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
