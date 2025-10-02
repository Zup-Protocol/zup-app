part of 'yields_cubit.dart';

@freezed
abstract class YieldsState with _$YieldsState {
  const factory YieldsState.initial() = _Initial;
  const factory YieldsState.loading() = _Loading;
  const factory YieldsState.success(YieldsDto yields) = _Success;
  const factory YieldsState.error(String message, String stackTrace) = _Error;
  const factory YieldsState.noYields({required PoolSearchFiltersDto filtersApplied}) = _NoYields;
}
