import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_list_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';

part 'token_selector_modal_cubit.freezed.dart';
part 'token_selector_modal_state.dart';

class TokenSelectorModalCubit extends Cubit<TokenSelectorModalState> {
  TokenSelectorModalCubit(this._tokensRepository, this._appCubit) : super(const TokenSelectorModalState.initial());

  final TokensRepository _tokensRepository;
  final AppCubit _appCubit;

  final Map<Networks, TokenListDto?> _tokenListCachedPerNetwork = {};
  TokenListDto? get tokenList => _tokenListCachedPerNetwork[_appCubit.selectedNetwork];

  void _emitSuccessCached() => emit(TokenSelectorModalState.success(tokenList!));
  bool get _shouldDiscardSearchState => state != const TokenSelectorModalState.searchLoading();
  bool get _shouldDiscardTokenListLoadedState => state != const TokenSelectorModalState.loading();

  Future<void> loadData() async {
    if (tokenList != null) return _emitSuccessCached();

    try {
      emit(const TokenSelectorModalState.loading());
      _tokenListCachedPerNetwork[_appCubit.selectedNetwork] = await _tokensRepository.getTokenList();

      if (_shouldDiscardTokenListLoadedState) return;

      _emitSuccessCached();
    } catch (e) {
      if (_shouldDiscardTokenListLoadedState) return;

      emit(const TokenSelectorModalState.error());
    }
  }

  Future<void> searchToken(String query) async {
    try {
      emit(const TokenSelectorModalState.searchLoading());
      final tokensList = await _tokensRepository.searchToken(query);

      if (_shouldDiscardSearchState) return;

      emit(TokenSelectorModalState.searchSuccess(tokensList));
    } catch (e) {
      if (_shouldDiscardSearchState) return;

      if (e is DioException && e.response?.statusCode == 404) {
        return emit(TokenSelectorModalState.searchNotFound(query));
      }

      emit(TokenSelectorModalState.searchError(query));
    }
  }
}
