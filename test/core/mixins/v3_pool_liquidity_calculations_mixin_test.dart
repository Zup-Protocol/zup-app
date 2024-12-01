import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/mixins/v3_pool_liquidity_calculations_mixin.dart';

class _V3PoolLiquidityCalculationsMixinWrapper with V3PoolLiquidityCalculationsMixin {}

void main() {
  test(""""`calculateToken1AmountFromToken0` should return the correct
   amount for token 1 based on the amount of token 0 to deposit in a pool.
   Coming from factors of range and current price""", () {
    const tokenXAmount = 1.0;
    const currentPrice = 3400.0;
    const priceLower = 0.0;
    const priceUpper = 4100.0;

    final tokenYAmount = _V3PoolLiquidityCalculationsMixinWrapper().calculateToken1AmountFromToken0(
      tokenXAmount,
      currentPrice,
      priceLower,
      priceUpper,
    );

    expect(tokenYAmount, 38049.06456823463);
  });

  test(""""`calculateToken0AmountFromToken1` should return the correct
   amount for token 0 based on the amount of token 1 to deposit in a pool.
   Coming from factors of range and current price""", () {
    const token1Amount = 1.0;
    const currentPrice = 3400.0;
    const priceLower = 0.0;
    const priceUpper = 4100.0;

    final token0Amount = _V3PoolLiquidityCalculationsMixinWrapper().calculateToken0AmountFromToken1(
      token1Amount,
      currentPrice,
      priceLower,
      priceUpper,
    );

    expect(token0Amount, 0.000026281855056033442);
  });
}
