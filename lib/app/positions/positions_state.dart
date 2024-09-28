part of "positions_cubit.dart";

@freezed
class PositionsState with _$PositionsState {
  const factory PositionsState.initial() = _Initial;
  const factory PositionsState.loading() = _Loading;
  const factory PositionsState.noPositions() = _NoPositions;
  const factory PositionsState.noPositionsInNetwork() = _NoPositionsInNetwork;
  const factory PositionsState.positions(List<PositionDto> positions) = _Positions;
  const factory PositionsState.notConnected() = _NotConnected;
  const factory PositionsState.error() = _Error;
}
