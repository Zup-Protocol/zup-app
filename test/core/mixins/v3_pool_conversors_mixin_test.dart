import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';

class V3PoolConversorsMixinTest with V3PoolConversorsMixin {}

void main() {
  test("`tickToPrice` should correctly convert a passed tick to a price", () {
    final price = V3PoolConversorsMixinTest().tickToPrice(
      tick: BigInt.from(194822),
      poolToken0Decimals: 6,
      poolToken1Decimals: 18,
    );

    expect(price.priceAsQuoteToken, 3462.6697030124183, reason: "`priceAsQuoteToken` is not correct");
    expect(price.priceAsBaseToken, 0.00028879450994994706, reason: "`priceAsBaseToken` is not correct");
  });

  test("""`tickToClosestValidTick` should correctly convert a
      passed tick to its closest valid tick based on the tick spacing (lower tick test case)""", () {
    final closestValidTick = V3PoolConversorsMixinTest().tickToClosestValidTick(
      tick: BigInt.from(7),
      tickSpacing: 5,
    );

    expect(closestValidTick, BigInt.from(5));
  });

  test("""`tickToClosestValidTick` should correctly convert a
      passed tick to its closest valid tick based on the tick spacing (higher tick test case)""", () {
    final closestValidTick = V3PoolConversorsMixinTest().tickToClosestValidTick(
      tick: BigInt.from(8),
      tickSpacing: 5,
    );

    expect(closestValidTick, BigInt.from(10));
  });

  test("`priceToTick` should correctly convert a passed price to a tick", () {
    final tick = V3PoolConversorsMixinTest().priceToTick(
      price: 1200,
      poolToken0Decimals: 6,
      poolToken1Decimals: 18,
    );

    expect(tick, BigInt.from(347228));
  });

  test("when is reversed is true, `priceToTick` should correctly convert a passed price to a tick", () {
    final tick = V3PoolConversorsMixinTest().priceToTick(
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
      final closestValidPrice = V3PoolConversorsMixinTest().priceToClosestValidPrice(
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
      final closestValidPrice = V3PoolConversorsMixinTest().priceToClosestValidPrice(
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
