import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_conversors_mixin.dart';

class _V3PoolConversorsMixinTest with CLPoolConversorsMixin {}

void main() {
  test("`tickToPrice` should correctly convert a passed tick to a price", () {
    final price = _V3PoolConversorsMixinTest().tickToPrice(
      tick: BigInt.from(194822),
      poolToken0Decimals: 6,
      poolToken1Decimals: 18,
    );

    expect(price.priceAsQuoteToken, 3462.6697030124183, reason: "`priceAsQuoteToken` is not correct");
    expect(price.priceAsBaseToken, 0.00028879450994994706, reason: "`priceAsBaseToken` is not correct");
  });

  test(
    """`tickToClosestValidTick` should correctly convert a
      passed tick to its closest valid tick based on the tick spacing (lower tick test case)""",
    () {
      final closestValidTick = _V3PoolConversorsMixinTest().tickToClosestValidTick(
        tick: BigInt.from(7),
        tickSpacing: 5,
      );

      expect(closestValidTick, BigInt.from(5));
    },
  );

  test(
    """When calling `tickToClosestValidTick` and the closest valid tick is lower
  than the minimum tick, it should return the higher valid tick""",
    () {
      final closestValidTick = _V3PoolConversorsMixinTest().tickToClosestValidTick(
        tick: CLPoolConstants.minTick - BigInt.from(1),
        tickSpacing: 1,
      );

      expect(closestValidTick, CLPoolConstants.minTick);
    },
  );

  test(
    """When calling `tickToClosestValidTick` and the closest valid tick is higher
  than the maximum tick, it should return the lower valid tick""",
    () {
      final closestValidTick = _V3PoolConversorsMixinTest().tickToClosestValidTick(
        tick: CLPoolConstants.maxTick + BigInt.from(2),
        tickSpacing: 4,
      );

      expect(closestValidTick, CLPoolConstants.maxTick);
    },
  );

  test(
    """`tickToClosestValidTick` should correctly convert a
      passed tick to its closest valid tick based on the tick spacing (higher tick test case)""",
    () {
      final closestValidTick = _V3PoolConversorsMixinTest().tickToClosestValidTick(
        tick: BigInt.from(8),
        tickSpacing: 5,
      );

      expect(closestValidTick, BigInt.from(10));
    },
  );

  test("`priceToTick` should correctly convert a passed price to a tick", () {
    final tick = _V3PoolConversorsMixinTest().priceToTick(price: 1200, poolToken0Decimals: 6, poolToken1Decimals: 18);

    expect(tick, BigInt.from(347228));
  });

  test("when is reversed is true, `priceToTick` should correctly convert a passed price to a tick", () {
    final tick = _V3PoolConversorsMixinTest().priceToTick(
      price: 1200,
      poolToken0Decimals: 6,
      poolToken1Decimals: 18,
      isReversed: true,
    );

    expect(tick, BigInt.from(205419));
  });

  test(
    "`priceToClosestValidPrice` should correctly convert a passed price to a closest valid price based on the tick spacing",
    () {
      final closestValidPrice = _V3PoolConversorsMixinTest().priceToClosestValidPrice(
        price: 1200,
        poolToken0Decimals: 6,
        poolToken1Decimals: 18,
        tickSpacing: 1,
        isReversed: false,
      );

      expect(closestValidPrice.price, 1199.9592295232399, reason: "`price` is not correct");
      expect(closestValidPrice.priceAsTick, BigInt.from(347228), reason: "`priceAsTick` is not correct");
    },
  );

  test(
    "When is reversed is true, `priceToClosestValidPrice` should correctly convert a passed price to a closest valid price based on the tick spacing",
    () {
      final closestValidPrice = _V3PoolConversorsMixinTest().priceToClosestValidPrice(
        price: 1200,
        poolToken0Decimals: 6,
        poolToken1Decimals: 18,
        tickSpacing: 1,
        isReversed: true,
      );

      expect(closestValidPrice.price, 1200.0855710750832, reason: "`price` is not correct");
      expect(closestValidPrice.priceAsTick, BigInt.from(205419), reason: "`priceAsTick` is not correct");
    },
  );
}
