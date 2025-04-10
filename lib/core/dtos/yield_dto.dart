import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/zup_core.dart';

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
    required int tickSpacing,
    required ProtocolDto protocol,
    required int feeTier,
    @JsonKey(name: "yield") required num yearlyYield,
    @Default(0) num totalValueLockedUSD,
    required Networks network,
  }) = _YieldDto;

  TokenDto maybeNativeToken0({required bool permitNative}) {
    if (permitNative && token0.address.lowercasedEquals(network.wrappedNative.address)) {
      return TokenDto(
        address: EthereumConstants.zeroAddress,
        decimals: network.chainInfo.nativeCurrency!.decimals,
        logoUrl: network.chainInfo.nativeCurrency!.logoUrl,
        symbol: network.chainInfo.nativeCurrency!.symbol,
        name: network.chainInfo.nativeCurrency!.name,
      );
    }

    return token0;
  }

  TokenDto maybeNativeToken1({required bool permitNative}) {
    if (permitNative && token1.address.lowercasedEquals(network.wrappedNative.address)) {
      return TokenDto(
        address: EthereumConstants.zeroAddress,
        decimals: network.chainInfo.nativeCurrency!.decimals,
        logoUrl: network.chainInfo.nativeCurrency!.logoUrl,
        symbol: network.chainInfo.nativeCurrency!.symbol,
        name: network.chainInfo.nativeCurrency!.name,
      );
    }

    return token1;
  }

  bool get isToken0WrappedNative => token0.address.lowercasedEquals(network.wrappedNativeTokenAddress);
  bool get isToken1WrappedNative => token1.address.lowercasedEquals(network.wrappedNativeTokenAddress);

  factory YieldDto.fromJson(Map<String, dynamic> json) => _$YieldDtoFromJson(json);

  factory YieldDto.fixture() => YieldDto(
        feeTier: 0,
        poolAddress: "0x5Df2f0aFb5b5bB2Df9D1e9C7b6f5f0DD5f9eD5e0",
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
      );
}
