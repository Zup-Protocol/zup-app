part of 'app_cubit.dart';

@freezed
class AppState with _$AppState {
  const factory AppState.standard() = _Standard;

  const factory AppState.networkChanged(AppNetworks newNetwork) = _NetworkChanged;
  const factory AppState.testnetModeChanged(bool isTestnetMode) = _TestnetModeChanged;
}
