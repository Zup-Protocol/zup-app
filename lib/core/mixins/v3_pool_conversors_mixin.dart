import 'dart:math' as math;

mixin V3PoolConversorsMixin {
  BigInt priceToTick({required int token0Decimals, required int token1Decimals, required double value}) {
    final priceWithDecimals = value * math.pow(10, token0Decimals);
    final quoteReserveRatio = (1 * math.pow(10, token1Decimals));

    final sqrtPriceRatio = quoteReserveRatio / priceWithDecimals;
    final tick = (math.log(sqrtPriceRatio) / math.log(1.0001)).floor();

    return BigInt.from(tick);
  }

  double tickToPrice({
    required int token0Decimals,
    required int token1Decimals,
    required BigInt tick,
    bool asToken0byToken1 = false,
  }) {
    final tickAsPrice = math.pow(1.0001, tick.toInt()).toDouble();

    final priceAstoken0byToken1 = tickAsPrice / (math.pow(10, token1Decimals - token0Decimals));
    final priceAsToken1byToken0 = 1 / priceAstoken0byToken1;

    return asToken0byToken1 ? priceAstoken0byToken1 : priceAsToken1byToken0;
  }

  BigInt tickToClosestValidTick({required BigInt tick, required int tickSpacing}) {
    final lowestValidTick = BigInt.from((tick / BigInt.from(tickSpacing)).floor() * tickSpacing);
    final highestValidTick = lowestValidTick + BigInt.from(tickSpacing);

    final lowestValidTickDistanceFromTick = (lowestValidTick - tick).abs();
    final highestValidTickDistanceFromTick = (highestValidTick - tick).abs();

    if (lowestValidTickDistanceFromTick < highestValidTickDistanceFromTick) return lowestValidTick;

    return highestValidTick;
  }

  double priceToClosestValidPrice({
    required int token0Decimals,
    required int token1Decimals,
    required int tickSpacing,
    required double value,
  }) {
    if (value == 0) return 0;

    final priceAsTick = priceToTick(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      value: value,
    );

    final closestUsableTickFromPrice = tickToClosestValidTick(tick: priceAsTick, tickSpacing: tickSpacing);

    final closestValidPrice = tickToPrice(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      tick: closestUsableTickFromPrice,
    );

    return closestValidPrice;
  }
}
