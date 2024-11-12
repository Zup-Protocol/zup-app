import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/mixins/v3_pool_liquidity_calculations_mixin.dart';

class _V3PoolLiquidityCalculationsMixinWrapper with V3PoolLiquidityCalculationsMixin {}

void main() {
  test(""""`calculateTokenYAmountFromTokenX` should return the correct
   amount for token Y based on the amount of token X to deposit in a pool.
   Coming from factors of range and current price
""", () {
    const tokenXAmount = 1.0;
    const currentPrice = 3400.0;
    const priceLower = 0.0;
    const priceUpper = 4100.0;

    final tokenYAmount = _V3PoolLiquidityCalculationsMixinWrapper().calculateTokenYAmountFromTokenX(
      tokenXAmount,
      currentPrice,
      priceLower,
      priceUpper,
    );

    expect(tokenYAmount, 38049.06456823);
  });
}
