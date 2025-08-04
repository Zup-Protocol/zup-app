import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';

part 'position_dto.freezed.dart';
part 'position_dto.g.dart';

@freezed
sealed class PositionDto with _$PositionDto {
  const PositionDto._();

  @JsonSerializable(explicitToJson: true)
  const factory PositionDto({
    TokenDto? token0,
    TokenDto? token1,
    @Default(null) AppNetworks? network,
    @Default(PositionStatus.unknown) @JsonKey(unknownEnumValue: PositionStatus.unknown) PositionStatus status,
    @Default(null) ProtocolDto? protocol,
    @Default(0) num minRange,
    @Default(0) num maxRange,
    @Default(0) @JsonKey(name: "liquidity") num liquidityUSD,
    @Default(0) @JsonKey(name: 'unclaimed_fees') num unclaimedFeesUSD,
  }) = _PositionDto;

  factory PositionDto.fromJson(Map<String, dynamic> json) => _$PositionDtoFromJson(json);

  factory PositionDto.fixture() => PositionDto(
        liquidityUSD: 123543.43,
        minRange: 0.4,
        maxRange: 123413.43,
        status: PositionStatus.inRange,
        token0: TokenDto.fixture(),
        token1: TokenDto.fixture(),
        protocol: ProtocolDto.fixture(),
        unclaimedFeesUSD: 1543.43,
      );
}
