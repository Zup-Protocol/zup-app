import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_core/zup_core.dart';

part 'token_amount_input_card_user_balance_cubit.freezed.dart';
part 'token_amount_input_card_user_balance_state.dart';

class TokenAmountCardUserBalanceCubit extends Cubit<TokenAmountCardUserBalanceState> with KeysMixin {
  TokenAmountCardUserBalanceCubit(
      this._wallet, this._tokenAddress, this._network, this._zupSingletonCache, this._onRefreshBalance)
      : super(const TokenAmountCardUserBalanceState.hideUserBalance()) {
    _setupStreams();
  }

  String _tokenAddress;
  AppNetworks _network;

  final Wallet _wallet;
  final ZupSingletonCache _zupSingletonCache;
  final VoidCallback? _onRefreshBalance;

  StreamSubscription<Signer?>? _signerStreamSubscription;
  double userBalance = 0;

  void _setupStreams() {
    _signerStreamSubscription = _wallet.signerStream.listen((signer) {
      if (signer == null) return emit(const TokenAmountCardUserBalanceState.hideUserBalance());

      getUserTokenAmount();
    });
  }

  Future<void> updateTokenAndNetwork(String tokenAddress, AppNetworks network, {required bool asNativeToken}) async {
    _tokenAddress = tokenAddress;
    _network = network;

    if (_wallet.signer != null) await getUserTokenAmount(isNative: asNativeToken);
  }

  Future<void> getUserTokenAmount({bool ignoreCache = false, bool isNative = false}) async {
    try {
      emit(const TokenAmountCardUserBalanceState.loadingUserBalance());

      userBalance = await _zupSingletonCache.run(() async {
        return await _wallet.nativeOrTokenBalance(
          isNative ? EthereumConstants.zeroAddress : _tokenAddress,
          rpcUrl: _network.rpcUrl,
        );
      },
          key: userTokenBalanceCacheKey(
            tokenAddress: _tokenAddress,
            userAddress: await _wallet.signer!.address,
            isNative: isNative,
          ),
          ignoreCache: ignoreCache,
          expiration: const Duration(minutes: 10));

      _onRefreshBalance?.call();
      emit(TokenAmountCardUserBalanceState.showUserBalance(userBalance));
    } catch (e) {
      emit(const TokenAmountCardUserBalanceState.error());
    }
  }

  @override
  Future<void> close() async {
    _signerStreamSubscription?.cancel();
    return super.close();
  }
}
