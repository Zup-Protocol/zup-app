part of 'token_selector_modal_cubit.dart';

@freezed
class TokenSelectorModalState with _$TokenSelectorModalState {
  const factory TokenSelectorModalState.initial() = _Initial;
  const factory TokenSelectorModalState.loading() = _Loading;
  const factory TokenSelectorModalState.searchLoading() = _SearchLoading;
  const factory TokenSelectorModalState.success(TokenListDto tokenList) = _Success;
  const factory TokenSelectorModalState.searchSuccess(List<TokenDto> result) = _SearchSuccess;
  const factory TokenSelectorModalState.error() = _Error;
  const factory TokenSelectorModalState.searchError(String searchedTerm) = _SearchError;
  const factory TokenSelectorModalState.searchNotFound(String searchedTerm) = _SearchNotFound;
}
