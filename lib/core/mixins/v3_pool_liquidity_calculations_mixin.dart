import 'dart:math';

mixin V3PoolLiquidityCalculationsMixin {
  double calculateTokenYAmountFromTokenX(
      double tokenXAmount, double currentPrice, double priceLower, double priceUpper) {
    final liquidity =
        tokenXAmount * ((sqrt(currentPrice) * sqrt(priceUpper)) / (sqrt(priceUpper) - sqrt(currentPrice)));
    final token1Amount = liquidity * (sqrt(currentPrice) - sqrt(priceLower));

    return double.tryParse(token1Amount.toStringAsFixed(8)) ?? 0;
  }
}
