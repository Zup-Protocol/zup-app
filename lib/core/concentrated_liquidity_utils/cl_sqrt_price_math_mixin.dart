import 'dart:math';

import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';
import 'package:zup_core/extensions/extensions.dart';

mixin CLSqrtPriceMath {
  ({double token1PerToken0, double token0PerToken1}) sqrtPriceX96ToPrice({
    required BigInt sqrtPriceX96,
    required int poolToken0Decimals,
    required int poolToken1Decimals,
  }) {
    final priceSqrt = sqrtPriceX96 / CLPoolConstants.q96;
    final basePrice = pow(priceSqrt, 2) / pow(10, poolToken1Decimals - poolToken0Decimals);
    final quotePrice = (1 / basePrice);

    return (token1PerToken0: quotePrice, token0PerToken1: basePrice);
  }

  BigInt getAmount1Delta(BigInt sqrtRatioAX96, BigInt sqrtRatioBX96, BigInt liquidity, bool roundUp) {
    if (sqrtRatioAX96 > sqrtRatioBX96) {
      final tmp = sqrtRatioAX96;
      sqrtRatioAX96 = sqrtRatioBX96;
      sqrtRatioBX96 = tmp;
    }

    final numerator = sqrtRatioBX96 - sqrtRatioAX96;

    return roundUp
        ? liquidity.mulDivRoundingUp(numerator, CLPoolConstants.q96)
        : liquidity.mulDiv(numerator, CLPoolConstants.q96);
  }

  BigInt getAmount0Delta(BigInt sqrtRatioAX96, BigInt sqrtRatioBX96, BigInt liquidity, bool roundUp) {
    if (sqrtRatioAX96 > sqrtRatioBX96) {
      final tmp = sqrtRatioAX96;

      sqrtRatioAX96 = sqrtRatioBX96;
      sqrtRatioBX96 = tmp;
    }

    const resolution = 96;
    final numerator1 = liquidity << resolution;
    final numerator2 = sqrtRatioBX96 - sqrtRatioAX96;

    if (sqrtRatioAX96 <= BigInt.zero) {
      throw ArgumentError("sqrtRatioAX96 must be > 0");
    }

    if (roundUp) {
      final mulDivUp = numerator1.mulDivRoundingUp(numerator2, sqrtRatioBX96);
      return mulDivUp.divRoundingUp(sqrtRatioAX96);
    } else {
      final mulDivDown = numerator1.mulDiv(numerator2, sqrtRatioBX96);
      return mulDivDown ~/ sqrtRatioAX96;
    }
  }

  ({BigInt amount0Delta, BigInt amount1Delta}) getAmountsDeltas(
    BigInt sqrtPriceX96,
    BigInt sqrtPriceAX96,
    BigInt sqrtPriceBX96,
    BigInt liquidity,
  ) {
    if (sqrtPriceAX96 > sqrtPriceBX96) {
      final tmp = sqrtPriceAX96;

      sqrtPriceAX96 = sqrtPriceBX96;
      sqrtPriceBX96 = tmp;
    }

    if (sqrtPriceX96 < sqrtPriceAX96) {
      final amount0Delta = getAmount0Delta(sqrtPriceAX96, sqrtPriceBX96, liquidity, true);
      final amount1Delta = BigInt.zero;

      return (amount0Delta: amount0Delta, amount1Delta: amount1Delta);
    }

    if (sqrtPriceX96 < sqrtPriceBX96) {
      final amount0Delta = getAmount0Delta(sqrtPriceX96, sqrtPriceBX96, liquidity, true);
      final amount1Delta = getAmount1Delta(sqrtPriceAX96, sqrtPriceX96, liquidity, true);

      return (amount0Delta: amount0Delta, amount1Delta: amount1Delta);
    }

    return (amount0Delta: BigInt.zero, amount1Delta: getAmount1Delta(sqrtPriceAX96, sqrtPriceBX96, liquidity, true));
  }
}
