import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';

part 'yield_dto.freezed.dart';
part 'yield_dto.g.dart';

enum YieldTimeFrame { day, month, threeMonth, unknown }

extension YieldTimeFrameExtension on YieldTimeFrame {
  bool get isDay => this == YieldTimeFrame.day;
  bool get isMonth => this == YieldTimeFrame.month;
  bool get isThreeMonth => this == YieldTimeFrame.threeMonth;

  String get label => [
        "24h",
        "Month",
        "3 Months",
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
    @Default(ProtocolDto()) ProtocolDto protocol,
    @Default(0) @JsonKey(name: "tick_spacing") int tickSpacing,
    required Networks network,
  }) = _YieldDto;

  factory YieldDto.fromJson(Map<String, dynamic> json) => _$YieldDtoFromJson(json);

  factory YieldDto.fixture() => YieldDto(
        token0: TokenDto.fixture().copyWith(
          symbol: "USDC",
          decimals: 6,
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
        ),
        token1: TokenDto.fixture().copyWith(
          symbol: "WETH",
          decimals: 18,
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
        ),
        yearlyYield: 5634.2,
        tickSpacing: 10,
        protocol: ProtocolDto.fixture(),
        network: Networks.arbitrum,
      );
}
