import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';

part 'position_dto.freezed.dart';
part 'position_dto.g.dart';

@freezed
class PositionDto with _$PositionDto {
  const PositionDto._();

  @JsonSerializable(explicitToJson: true)
  const factory PositionDto({
    TokenDto? token0,
    TokenDto? token1,
    @Default(null) Networks? network,
    @Default(PositionStatus.unknown) @JsonKey(unknownEnumValue: PositionStatus.unknown) PositionStatus status,
    @Default(null) ProtocolDto? protocol,
    @Default("") String minRange,
    @Default("") String maxRange,
    @Default("0") String liquidity,
    @Default("0") @JsonKey(name: 'unclaimed_fees') String unclaimedFees,
  }) = _PositionDto;

  factory PositionDto.fromJson(Map<String, dynamic> json) => _$PositionDtoFromJson(json);

  factory PositionDto.fixture() => PositionDto(
        liquidity: "123,543.43",
        minRange: "0.4",
        maxRange: "123,413.43",
        status: PositionStatus.inRange,
        token0: TokenDto.fixture(),
        token1: TokenDto.fixture(),
        protocol: ProtocolDto.fixture(),
        unclaimedFees: "1,543.43",
      );
}
