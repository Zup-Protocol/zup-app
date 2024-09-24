part of 'app_cubit.dart';

@freezed
class AppState {
  const factory AppState.standard() = _Standard;

  const factory AppState.networkChanged(Networks newNetwork) = _NetworkChanged;
}
