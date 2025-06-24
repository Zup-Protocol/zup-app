import 'dart:math';

import 'package:zup_app/core/v3_v4_pool_constants.dart';

mixin V3PoolConversorsMixin {
  ({double priceAsQuoteToken, double priceAsBaseToken}) tickToPrice({
    required BigInt tick,
    required int poolToken0Decimals,
    required int poolToken1Decimals,
  }) {
    final basePrice = pow(1.0001, tick.toInt()) / pow(10, poolToken1Decimals - poolToken0Decimals);
    final quotePrice = 1 / basePrice;

    return (priceAsQuoteToken: quotePrice, priceAsBaseToken: basePrice);
  }

  BigInt tickToClosestValidTick({required BigInt tick, required int tickSpacing}) {
    final lowestValidTick = BigInt.from((tick / BigInt.from(tickSpacing)).floor() * tickSpacing);
    final highestValidTick = lowestValidTick + BigInt.from(tickSpacing);

    final lowestValidTickDistanceFromTick = (lowestValidTick - tick).abs();
    final highestValidTickDistanceFromTick = (highestValidTick - tick).abs();

    if (lowestValidTickDistanceFromTick < highestValidTickDistanceFromTick &&
        lowestValidTick >= V3V4PoolConstants.minTick) {
      return lowestValidTick;
    }

    return highestValidTick > V3V4PoolConstants.maxTick ? lowestValidTick : highestValidTick;
  }

  BigInt priceToTick({
    required double price,
    required int poolToken0Decimals,
    required int poolToken1Decimals,
    bool isReversed = false,
  }) {
    final baseTokenReserveRatio = (isReversed ? price : 1) * pow(10, poolToken0Decimals);
    final quoteTokenReserveRatio = (isReversed ? 1 : price) * pow(10, poolToken1Decimals);
    final sqrtPriceRatio = quoteTokenReserveRatio / baseTokenReserveRatio;
    final tickForPrice = (log(sqrtPriceRatio) / log(1.0001)).floor();

    return BigInt.from(tickForPrice);
  }

  ({double price, BigInt priceAsTick}) priceToClosestValidPrice(
      {required double price,
      required int poolToken0Decimals,
      required int poolToken1Decimals,
      required int tickSpacing,
      required bool isReversed}) {
    final priceAsTick = priceToTick(
      price: price,
      poolToken0Decimals: poolToken0Decimals,
      poolToken1Decimals: poolToken1Decimals,
      isReversed: isReversed,
    );

    final closestValidTick = tickToClosestValidTick(
      tick: priceAsTick,
      tickSpacing: tickSpacing,
    );

    final closestValidPrice = tickToPrice(
      tick: closestValidTick,
      poolToken0Decimals: poolToken0Decimals,
      poolToken1Decimals: poolToken1Decimals,
    );

    return (
      price: isReversed ? closestValidPrice.priceAsQuoteToken : closestValidPrice.priceAsBaseToken,
      priceAsTick: closestValidTick
    );
  }
}
