import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';

part 'token_selector_modal_cubit.freezed.dart';
part 'token_selector_modal_state.dart';

class TokenSelectorModalCubit extends Cubit<TokenSelectorModalState> {
  TokenSelectorModalCubit(this._tokensRepository, this._appCubit, this._wallet)
    : super(const TokenSelectorModalState.initial());

  final TokensRepository _tokensRepository;
  final AppCubit _appCubit;
  final Wallet _wallet;

  final Map<AppNetworks, Map<String, TokenListDto>> _tokenListCachedPerNetworkByAddress = {};
  Future<TokenListDto?> get tokenList async =>
      _tokenListCachedPerNetworkByAddress[_appCubit.selectedNetwork]?[await _wallet.signer?.address ??
          EthereumConstants.zeroAddress];

  Future<void> _emitSuccessCached() async => emit(TokenSelectorModalState.success((await tokenList)!));
  bool get _shouldDiscardSearchState => state != const TokenSelectorModalState.searchLoading();
  bool get _shouldDiscardTokenListLoadedState => state != const TokenSelectorModalState.loading();

  Future<void> fetchTokenList({bool forceRefresh = false}) async {
    if ((await tokenList) != null && !forceRefresh) {
      return await _emitSuccessCached();
    }

    if (_tokenListCachedPerNetworkByAddress[_appCubit.selectedNetwork] == null) {
      _tokenListCachedPerNetworkByAddress[_appCubit.selectedNetwork] = {};
    }

    final userAddress = await _wallet.signer?.address ?? EthereumConstants.zeroAddress;

    try {
      emit(const TokenSelectorModalState.loading());

      _tokenListCachedPerNetworkByAddress[_appCubit.selectedNetwork]![userAddress] = await _tokensRepository
          .getTokenList(_appCubit.selectedNetwork);

      if (_shouldDiscardTokenListLoadedState) return;

      await _emitSuccessCached();
    } catch (e) {
      if (_shouldDiscardTokenListLoadedState) return;

      emit(const TokenSelectorModalState.error());
    }
  }

  Future<void> searchToken(String query) async {
    if (query.isEthereumAddress() && _appCubit.selectedNetwork.isAllNetworks) {
      return emit(TokenSelectorModalState.searchNotFound(query));
    }

    try {
      emit(const TokenSelectorModalState.searchLoading());
      final tokensList = await _tokensRepository.searchToken(query, _appCubit.selectedNetwork);
      tokensList.removeWhere((token) => token.name.isEmpty && token.symbol.isEmpty);

      if (_shouldDiscardSearchState) return;

      if (tokensList.isEmpty) {
        return emit(TokenSelectorModalState.searchNotFound(query));
      }

      emit(TokenSelectorModalState.searchSuccess(tokensList));
    } catch (e) {
      if (_shouldDiscardSearchState || (e is DioException && CancelToken.isCancel(e))) return;

      emit(TokenSelectorModalState.searchError(query));
    }
  }
}
