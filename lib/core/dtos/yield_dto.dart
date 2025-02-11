import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';

part 'yield_dto.freezed.dart';
part 'yield_dto.g.dart';

enum YieldTimeFrame { day, month, threeMonth, unknown }

extension YieldTimeFrameExtension on YieldTimeFrame {
  bool get isDay => this == YieldTimeFrame.day;
  bool get isMonth => this == YieldTimeFrame.month;
  bool get isThreeMonth => this == YieldTimeFrame.threeMonth;

  String label(BuildContext context) => [
        S.of(context).twentyFourHours,
        S.of(context).month,
        S.of(context).threeMonths,
        "???",
      ][index];

  String compactDaysLabel(BuildContext context) => [
        S.of(context).twentyFourHoursCompact,
        S.of(context).monthCompact,
        S.of(context).threeMonthsCompact,
        "???",
      ][index];
}

@freezed
class YieldDto with _$YieldDto {
  @JsonSerializable(explicitToJson: true)
  const factory YieldDto({
    @JsonKey(name: "token_a") required TokenDto token0,
    @JsonKey(name: "token_b") required TokenDto token1,
    @Default(0) @JsonKey(name: "yield") num yearlyYield,
    @Default("") @JsonKey(name: "address") String poolAddress,
    @Default("") @JsonKey(name: "position_manager_address") String positionManagerAddress,
    @Default(ProtocolDto()) ProtocolDto protocol,
    @Default(0) @JsonKey(name: "tick_spacing") int tickSpacing,
    @Default(0) @JsonKey(name: "fee_tier") int feeTier,
    @Default(YieldTimeFrame.unknown)
    @JsonKey(name: "timeframe", unknownEnumValue: YieldTimeFrame.unknown)
    YieldTimeFrame yieldTimeFrame,
    required Networks network,
  }) = _YieldDto;

  factory YieldDto.fromJson(Map<String, dynamic> json) => _$YieldDtoFromJson(json);

  factory YieldDto.fixture() => YieldDto(
        token0: TokenDto.fixture().copyWith(
          symbol: "USDC",
          decimals: 6,
          address: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
        ),
        token1: TokenDto.fixture().copyWith(
          symbol: "WETH",
          decimals: 18,
          address: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
        ),
        yearlyYield: 5634.2,
        tickSpacing: 10,
        protocol: ProtocolDto.fixture(),
        network: Networks.sepolia,
        yieldTimeFrame: YieldTimeFrame.day,
      );
}
