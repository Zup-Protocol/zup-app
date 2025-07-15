import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_type.dart';
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
  const YieldDto._();
  @JsonSerializable(explicitToJson: true)
  const factory YieldDto({
    required TokenDto token0,
    required TokenDto token1,
    required String poolAddress,
    required String positionManagerAddress,
    required int tickSpacing,
    required ProtocolDto protocol,
    required int feeTier,
    required num yield24h,
    required num yield30d,
    required num yield90d,
    required int chainId,
    required PoolType poolType,
    @Default("0") String latestTick,
    @Default(0) num totalValueLockedUSD,
    @Default(EthereumConstants.zeroAddress) @JsonKey(name: "hooksAddress") String v4Hooks,
    @JsonKey(name: "poolManagerAddress") String? v4PoolManager,
    @JsonKey(name: "stateViewAddress") String? v4StateView,
    @JsonKey(name: "permit2Address") String? permit2,
  }) = _YieldDto;

  AppNetworks get network => AppNetworks.fromChainId(chainId)!;

  bool get isToken0Native => token0.addresses[network.chainId] == EthereumConstants.zeroAddress;
  bool get isToken1Native => token1.addresses[network.chainId] == EthereumConstants.zeroAddress;

  factory YieldDto.fromJson(Map<String, dynamic> json) => _$YieldDtoFromJson(json);

  factory YieldDto.fixture() => YieldDto(
        feeTier: 0,
        yield24h: 32.2,
        yield30d: 32.2,
        yield90d: 32.2,
        latestTick: "1567241",
        positionManagerAddress: "0x5Df2f0aFb5b5bB2Df9D1e9C7b6f5f0DD5f9eD5e0",
        poolAddress: "0x5Df2f0aFb5b5bB2Df9D1e9C7b6f5f0DD5f9eD5e0",
        poolType: PoolType.v3,
        token0: TokenDto.fixture().copyWith(
          symbol: "USDC",
          decimals: 6,
          addresses: {
            AppNetworks.sepolia.chainId: "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48",
          },
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48/logo.png",
        ),
        token1: TokenDto.fixture().copyWith(
          symbol: "WETH",
          decimals: 18,
          addresses: {
            AppNetworks.sepolia.chainId: "0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2",
          },
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/ethereum/assets/0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2/logo.png",
        ),
        tickSpacing: 10,
        protocol: ProtocolDto.fixture(),
        chainId: AppNetworks.sepolia.chainId,
      );
}
