import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/mixins/v4_pool_liquidity_calculations_mixin.dart';

class _V4PoolLiquidityCalculationsMixinTest with V4PoolLiquidityCalculationsMixin {}

void main() {
  test(
    "When calling `getLiquidityForAmount0` it should return the correct value based on the v4 pool math",
    () {
      BigInt sqrtPriceAX96 = BigInt.parse("4242269098745952767280720");
      BigInt sqrtPriceBX96 = BigInt.parse("4242269098745952767280721");
      BigInt amount0 = BigInt.from(1241555);

      expect(
        _V4PoolLiquidityCalculationsMixinTest().getLiquidityForAmount0(sqrtPriceAX96, sqrtPriceBX96, amount0),
        BigInt.parse("282021882116526385819866125"),
      );
    },
  );

  test(
    "When calling `getLiquidityForAmount1` it should return the correct value based on the v4 pool math",
    () {
      BigInt sqrtPriceAX96 = BigInt.parse("4242269098745952767280720");
      BigInt sqrtPriceBX96 = BigInt.parse("4242269098745952767280721");
      BigInt amount0 = BigInt.from(1241555);

      expect(
        _V4PoolLiquidityCalculationsMixinTest().getLiquidityForAmount1(sqrtPriceAX96, sqrtPriceBX96, amount0),
        BigInt.parse("98366121310397459660952459259412480"),
      );
    },
  );

  test(
    "When calling `getLiquidityForAmounts` and the sqrtpricea is bigger, it should return the token0 liquidity calculated",
    () {
      BigInt sqrtPriceX96 = BigInt.parse("4242269098745952767280720");
      BigInt sqrtPriceAX96 = BigInt.parse("4242269098745952767280720");
      BigInt sqrtPriceBX96 = BigInt.parse("4242269098745952767280721");
      BigInt amount0 = BigInt.from(1241555);
      BigInt amount1 = BigInt.from(1241555);

      expect(
        _V4PoolLiquidityCalculationsMixinTest()
            .getLiquidityForAmounts(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, amount0, amount1),
        BigInt.parse("282021882116526385819866125"),
      );
    },
  );

  test(
    "When calling `getLiquidityForAmounts` and the sqrtpriceA is lower, it should return the token1 liquidity calculated",
    () {
      BigInt sqrtPriceX96 = BigInt.parse("4242269098745952767280720");
      BigInt sqrtPriceAX96 = BigInt.parse("4242269098745952767280724");
      BigInt sqrtPriceBX96 = BigInt.parse("4242269098745952767280721");
      BigInt amount0 = BigInt.from(1241555);
      BigInt amount1 = BigInt.from(1241555);

      expect(
        _V4PoolLiquidityCalculationsMixinTest()
            .getLiquidityForAmounts(sqrtPriceX96, sqrtPriceAX96, sqrtPriceBX96, amount0, amount1),
        BigInt.parse("94007294038842128606622041"),
      );
    },
  );

  test('getSqrtPriceAtTick should return correct value for tick 0', () {
    final result = _V4PoolLiquidityCalculationsMixinTest().getSqrtPriceAtTick(BigInt.zero);
    expect(result, BigInt.parse('79228162514264337593543950336'));
  });

  test('getSqrtPriceAtTick should return correct value for positive tick', () {
    final result = _V4PoolLiquidityCalculationsMixinTest().getSqrtPriceAtTick(BigInt.from(60));
    expect(result, BigInt.parse('79466191966197645195421774833'));
  });

  test('getSqrtPriceAtTick should return correct value for negative tick', () {
    final result = _V4PoolLiquidityCalculationsMixinTest().getSqrtPriceAtTick(BigInt.from(-60));
    expect(result, BigInt.parse('78990846045029531151608375686'));
  });

  test('getSqrtPriceAtTick should throw for tick out of range', () {
    expect(
      () => _V4PoolLiquidityCalculationsMixinTest().getSqrtPriceAtTick(BigInt.from(887273)),
      throwsException,
    );

    expect(
      () => _V4PoolLiquidityCalculationsMixinTest().getSqrtPriceAtTick(BigInt.from(-887273)),
      throwsException,
    );
  });
}
