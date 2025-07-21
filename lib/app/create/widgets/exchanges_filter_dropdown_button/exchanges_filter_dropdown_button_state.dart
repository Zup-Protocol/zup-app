part of 'exchanges_filter_dropdown_button_cubit.dart';

@freezed
class ExchangesFilterDropdownButtonState with _$ExchangesFilterDropdownButtonState {
  const factory ExchangesFilterDropdownButtonState.initial() = _Initial;
  const factory ExchangesFilterDropdownButtonState.loading() = _Loading;
  const factory ExchangesFilterDropdownButtonState.error() = _Error;
  const factory ExchangesFilterDropdownButtonState.success(List<ProtocolDto> protocols) = _Success;
}
