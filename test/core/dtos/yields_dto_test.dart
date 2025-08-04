import 'package:collection/collection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';

void main() {
  test("When calling 'poolsSortedBy24hYield' it should short pools descending by 24h yield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield24h: 100),
      YieldDto.fixture().copyWith(yield24h: 87),
      YieldDto.fixture().copyWith(yield24h: 0),
      YieldDto.fixture().copyWith(yield24h: 2000),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedBy24hYield, pools.sorted((a, b) => b.yield24h.compareTo(a.yield24h)));
  });

  test("When calling 'poolsSortedBy7dYield' it should short pools descending by 7d yield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield7d: 12681),
      YieldDto.fixture().copyWith(yield7d: 111),
      YieldDto.fixture().copyWith(yield7d: 0),
      YieldDto.fixture().copyWith(yield7d: 21971972891),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedBy7dYield, pools.sorted((a, b) => b.yield7d.compareTo(a.yield7d)));
  });

  test("When calling 'poolsSortedBy30dYield' it should short pools descending by 30d yield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield30d: 089889888),
      YieldDto.fixture().copyWith(yield30d: 2222),
      YieldDto.fixture().copyWith(yield30d: 0),
      YieldDto.fixture().copyWith(yield30d: 12615654),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedBy30dYield, pools.sorted((a, b) => b.yield30d.compareTo(a.yield30d)));
  });

  test("When calling 'poolsSortedBy90dYield' it should short pools descending by 90d yield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield90d: 978888),
      YieldDto.fixture().copyWith(yield90d: 121),
      YieldDto.fixture().copyWith(yield90d: 0),
      YieldDto.fixture().copyWith(yield90d: 329087902),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedBy90dYield, pools.sorted((a, b) => b.yield90d.compareTo(a.yield90d)));
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.day it should return poolsSortedBy24hYield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield24h: 100),
      YieldDto.fixture().copyWith(yield24h: 87),
      YieldDto.fixture().copyWith(yield24h: 0),
      YieldDto.fixture().copyWith(yield24h: 2000),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(YieldTimeFrame.day), yields.poolsSortedBy24hYield);
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.week it should return poolsSortedBy7dYield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield7d: 12681),
      YieldDto.fixture().copyWith(yield7d: 111),
      YieldDto.fixture().copyWith(yield7d: 0),
      YieldDto.fixture().copyWith(yield7d: 21971972891),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(YieldTimeFrame.week), yields.poolsSortedBy7dYield);
  });

  test("when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.month it should return poolsSortedBy30dYield", () {
    final pools = [
      YieldDto.fixture().copyWith(yield30d: 089889888),
      YieldDto.fixture().copyWith(yield30d: 2222),
      YieldDto.fixture().copyWith(yield30d: 0),
      YieldDto.fixture().copyWith(yield30d: 12615654),
    ];

    final yields = YieldsDto.fixture().copyWith(pools: pools);

    expect(yields.poolsSortedByTimeframe(YieldTimeFrame.month), yields.poolsSortedBy30dYield);
  });

  test(
    "when calling 'poolsSortedByTimeframe' passing YieldTimeFrame.threeMonth it should return poolsSortedBy90dYield",
    () {
      final pools = [
        YieldDto.fixture().copyWith(yield90d: 978888),
        YieldDto.fixture().copyWith(yield90d: 121),
        YieldDto.fixture().copyWith(yield90d: 0),
        YieldDto.fixture().copyWith(yield90d: 329087902),
      ];

      final yields = YieldsDto.fixture().copyWith(pools: pools);

      expect(yields.poolsSortedByTimeframe(YieldTimeFrame.threeMonth), yields.poolsSortedBy90dYield);
    },
  );
}
