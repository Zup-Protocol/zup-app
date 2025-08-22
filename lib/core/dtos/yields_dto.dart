import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/enums/protocol_id.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';

part 'yields_dto.freezed.dart';
part 'yields_dto.g.dart';

@freezed
sealed class YieldsDto with _$YieldsDto {
  const YieldsDto._();

  @JsonSerializable(explicitToJson: true)
  const factory YieldsDto({
    @Default(<YieldDto>[]) @JsonKey(name: "pools") List<YieldDto> pools,
    @Default(PoolSearchFiltersDto()) PoolSearchFiltersDto filters,
  }) = _YieldsDto;

  bool get isEmpty => pools.isEmpty;

  List<YieldDto> get poolsSortedBy24hYield {
    return [...pools]..sort((a, b) => b.yield24h.compareTo(a.yield24h));
  }

  List<YieldDto> get poolsSortedBy7dYield {
    return [...pools]..sort((a, b) => b.yield7d.compareTo(a.yield7d));
  }

  List<YieldDto> get poolsSortedBy30dYield {
    return [...pools]..sort((a, b) => b.yield30d.compareTo(a.yield30d));
  }

  List<YieldDto> get poolsSortedBy90dYield {
    return [...pools]..sort((a, b) => b.yield90d.compareTo(a.yield90d));
  }

  List<YieldDto> poolsSortedByTimeframe(YieldTimeFrame timeframe) {
    switch (timeframe) {
      case YieldTimeFrame.day:
        return poolsSortedBy24hYield;
      case YieldTimeFrame.week:
        return poolsSortedBy7dYield;
      case YieldTimeFrame.month:
        return poolsSortedBy30dYield;
      case YieldTimeFrame.threeMonth:
        return poolsSortedBy90dYield;
    }
  }

  factory YieldsDto.fromJson(Map<String, dynamic> json) => _$YieldsDtoFromJson(json);

  factory YieldsDto.empty() => const YieldsDto(pools: []);

  factory YieldsDto.fixture() => YieldsDto(
    filters: PoolSearchFiltersDto.fixture(),
    pools: [
      YieldDto(
        latestTick: "637812562",
        positionManagerAddress: "0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4",
        poolType: PoolType.v3,
        yield7d: 21,
        token0: const TokenDto(
          addresses: {11155111: "0x02a3e7E0480B668bD46b42852C58363F93e3bA5C"},
          decimals: {11155111: 6},
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4/logo.png",
          name: "USDC",
          symbol: "USDC",
        ),
        token1: const TokenDto(
          addresses: {11155111: "0x5300000000000000000000000000000000000004"},
          decimals: {11155111: 18},
          logoUrl:
              "https://raw.githubusercontent.com/trustwallet/assets/master/blockchains/scroll/assets/0x5300000000000000000000000000000000000004/logo.png",
          name: "Wrapped Ether",
          symbol: "WETH",
        ),
        chainId: 11155111,
        poolAddress: "0x4040CE732c1A538A4Ac3157FDC35179D73ea76cd",
        tickSpacing: 10,
        yield24h: 1732.42,
        yield30d: 765.61,
        yield90d: 2022.99,
        totalValueLockedUSD: 65434567890.21,
        initialFeeTier: 500,
        currentFeeTier: 500,
        protocol: ProtocolDto(
          id: ProtocolId.pancakeSwapInfinityCL,
          rawId: ProtocolId.pancakeSwapInfinityCL.toRawJsonValue,
          name: "PancakeSwap",
          logo: "https://raw.githubusercontent.com/trustwallet/assets/master/dapps/exchange.pancakeswap.finance.png",
        ),
      ),
    ],
  );
}
