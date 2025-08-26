import 'dart:math';

import 'package:web3kit/core/ethereum_constants.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';

mixin CLPoolLiquidityCalculationsMixin {
  double calculateToken1AmountFromToken0({
    required double tokenXAmount,
    required double currentPrice,
    required double priceLower,
    required double priceUpper,
  }) {
    final liquidity =
        tokenXAmount * ((sqrt(currentPrice) * sqrt(priceUpper)) / (sqrt(priceUpper) - sqrt(currentPrice)));
    final token1Amount = liquidity * (sqrt(currentPrice) - sqrt(priceLower));

    return token1Amount;
  }

  double calculateToken0AmountFromToken1({
    required double tokenYAmount,
    required double currentPrice,
    required double priceLower,
    required double priceUpper,
  }) {
    final liquidity = tokenYAmount / (sqrt(currentPrice) - sqrt(priceLower));
    final token0Amount =
        liquidity * ((sqrt(priceUpper) - sqrt(currentPrice)) / (sqrt(priceUpper) * sqrt(currentPrice)));

    return token0Amount;
  }

  BigInt getLiquidityForAmount0(BigInt sqrtPriceAX96, BigInt sqrtPriceBX96, BigInt amount0) {
    if (sqrtPriceAX96 > sqrtPriceBX96) {
      final sqrtPriceAX96Before = sqrtPriceAX96;
      sqrtPriceAX96 = sqrtPriceBX96;
      sqrtPriceBX96 = sqrtPriceAX96Before;
    }

    final numerator = (amount0 * sqrtPriceAX96) * sqrtPriceBX96;
    final denominator = CLPoolConstants.q96 * (sqrtPriceBX96 - sqrtPriceAX96);

    return numerator ~/ denominator;
  }

  BigInt getLiquidityForAmount1(BigInt sqrtPriceAX96, BigInt sqrtPriceBX96, BigInt amount1) {
    if (sqrtPriceAX96 > sqrtPriceBX96) {
      final sqrtPriceAX96Before = sqrtPriceAX96;
      sqrtPriceAX96 = sqrtPriceBX96;
      sqrtPriceBX96 = sqrtPriceAX96Before;
    }

    return (amount1 * CLPoolConstants.q96) ~/ (sqrtPriceBX96 - sqrtPriceAX96);
  }

  BigInt getLiquidityForAmounts(
    BigInt sqrtPriceX96,
    BigInt sqrtPriceAX96,
    BigInt sqrtPriceBX96,
    BigInt amount0,
    BigInt amount1,
  ) {
    if (sqrtPriceAX96 > sqrtPriceBX96) {
      final sqrtPriceAX96Before = sqrtPriceAX96;
      sqrtPriceAX96 = sqrtPriceBX96;
      sqrtPriceBX96 = sqrtPriceAX96Before;
    }

    if (sqrtPriceX96 <= sqrtPriceAX96) {
      return getLiquidityForAmount0(sqrtPriceAX96, sqrtPriceBX96, amount0);
    } else if (sqrtPriceX96 < sqrtPriceBX96) {
      BigInt liquidity0 = getLiquidityForAmount0(sqrtPriceX96, sqrtPriceBX96, amount0);
      BigInt liquidity1 = getLiquidityForAmount1(sqrtPriceAX96, sqrtPriceX96, amount1);

      return liquidity0 < liquidity1 ? liquidity0 : liquidity1;
    } else {
      return getLiquidityForAmount1(sqrtPriceAX96, sqrtPriceBX96, amount1);
    }
  }

  BigInt getSqrtPriceAtTick(BigInt tick) {
    final absTick = tick.abs();

    if (absTick > CLPoolConstants.maxTick) throw Exception('Tick out of range');

    BigInt ratio = absTick & BigInt.from(0x1) != BigInt.zero
        ? BigInt.parse("0xfffcb933bd6fad37aa2d162d1a594001")
        : BigInt.parse("0x100000000000000000000000000000000");

    if (absTick & BigInt.from(0x2) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xfff97272373d413259a46990580e213a")) >> 128;
    }

    if (absTick & BigInt.from(0x4) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xfff2e50f5f656932ef12357cf3c7fdcc")) >> 128;
    }

    if (absTick & BigInt.from(0x8) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xffe5caca7e10e4e61c3624eaa0941cd0")) >> 128;
    }

    if (absTick & BigInt.from(0x10) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xffcb9843d60f6159c9db58835c926644")) >> 128;
    }

    if (absTick & BigInt.from(0x20) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xff973b41fa98c081472e6896dfb254c0")) >> 128;
    }

    if (absTick & BigInt.from(0x40) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xff2ea16466c96a3843ec78b326b52861")) >> 128;
    }

    if (absTick & BigInt.from(0x80) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xfe5dee046a99a2a811c461f1969c3053")) >> 128;
    }

    if (absTick & BigInt.from(0x100) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xfcbe86c7900a88aedcffc83b479aa3a4")) >> 128;
    }
    if (absTick & BigInt.from(0x200) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xf987a7253ac413176f2b074cf7815e54")) >> 128;
    }

    if (absTick & BigInt.from(0x400) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xf3392b0822b70005940c7a398e4b70f3")) >> 128;
    }
    if (absTick & BigInt.from(0x800) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xe7159475a2c29b7443b29c7fa6e889d9")) >> 128;
    }
    if (absTick & BigInt.from(0x1000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xd097f3bdfd2022b8845ad8f792aa5825")) >> 128;
    }
    if (absTick & BigInt.from(0x2000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0xa9f746462d870fdf8a65dc1f90e061e5")) >> 128;
    }

    if (absTick & BigInt.from(0x4000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0x70d869a156d2a1b890bb3df62baf32f7")) >> 128;
    }

    if (absTick & BigInt.from(0x8000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0x31be135f97d08fd981231505542fcfa6")) >> 128;
    }

    if (absTick & BigInt.from(0x10000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0x9aa508b5b7a84e1c677de54f3e99bc9")) >> 128;
    }

    if (absTick & BigInt.from(0x20000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0x5d6af8dedb81196699c329225ee604")) >> 128;
    }

    if (absTick & BigInt.from(0x40000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0x2216e584f5fa1ea926041bedfe98")) >> 128;
    }

    if (absTick & BigInt.from(0x80000) != BigInt.zero) {
      ratio = (ratio * BigInt.parse("0x48a170391f7dc42444e8fa2")) >> 128;
    }

    if (tick > BigInt.zero) ratio = EthereumConstants.uint256Max ~/ ratio;

    if (ratio.remainder(CLPoolConstants.q32) > BigInt.zero) {
      return ratio ~/ CLPoolConstants.q32 + BigInt.one;
    }

    return ratio ~/ CLPoolConstants.q32;
  }
}
