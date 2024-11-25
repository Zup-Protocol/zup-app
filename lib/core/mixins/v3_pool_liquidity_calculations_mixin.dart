import 'dart:math';

mixin V3PoolLiquidityCalculationsMixin {
  double calculateToken1AmountFromToken0(
    double tokenXAmount,
    double currentPrice,
    double priceLower,
    double priceUpper,
  ) {
    final liquidity =
        tokenXAmount * ((sqrt(currentPrice) * sqrt(priceUpper)) / (sqrt(priceUpper) - sqrt(currentPrice)));
    final token1Amount = liquidity * (sqrt(currentPrice) - sqrt(priceLower));

    return token1Amount;
  }

  double calculateToken0AmountFromToken1(
    double tokenYAmount,
    double currentPrice,
    double priceLower,
    double priceUpper,
  ) {
    final liquidity = tokenYAmount / (sqrt(currentPrice) - sqrt(priceLower));
    final token1Amount =
        liquidity * ((sqrt(priceUpper) - sqrt(currentPrice)) / (sqrt(priceUpper) * sqrt(currentPrice)));

    return token1Amount;
  }
}
