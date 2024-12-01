import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_core/zup_core.dart';

part 'token_amount_input_card_user_balance_cubit.freezed.dart';
part 'token_amount_input_card_user_balance_state.dart';

class TokenAmountCardUserBalanceCubit extends Cubit<TokenAmountCardUserBalanceState> with KeysMixin {
  TokenAmountCardUserBalanceCubit(this._wallet, this._tokenAddress, this._network, this._zupSingletonCache)
      : super(const TokenAmountCardUserBalanceState.hideUserBalance()) {
    _setupStreams();
  }

  String _tokenAddress;

  final Wallet _wallet;
  final Networks _network;
  final ZupSingletonCache _zupSingletonCache;

  StreamSubscription<Signer?>? _signerStreamSubscription;
  double userBalance = 0;

  void _setupStreams() {
    _signerStreamSubscription = _wallet.signerStream.listen((signer) {
      if (signer == null) return emit(const TokenAmountCardUserBalanceState.hideUserBalance());

      getUserTokenAmount();
    });
  }

  Future<void> updateToken(String tokenAddress) async {
    _tokenAddress = tokenAddress;

    if (_wallet.signer != null) await getUserTokenAmount();
  }

  Future<void> getUserTokenAmount({bool ignoreCache = false}) async {
    try {
      emit(const TokenAmountCardUserBalanceState.loadingUserBalance());

      userBalance =
          await _zupSingletonCache.run(() async => await _wallet.tokenBalance(_tokenAddress, rpcUrl: _network.rpcUrl),
              key: userTokenBalanceCacheKey(
                tokenAddress: _tokenAddress,
                userAddress: await _wallet.signer!.address,
              ),
              ignoreCache: ignoreCache,
              expiration: const Duration(minutes: 10));

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
