mixin V4PoolLiquidityCalculationsMixin {
  final _q96 = BigInt.parse("0x1000000000000000000000000");

  BigInt getLiquidityForAmount0(BigInt sqrtPriceAX96, BigInt sqrtPriceBX96, BigInt amount0) {
    if (sqrtPriceAX96 > sqrtPriceBX96) (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

    BigInt intermediate = ((sqrtPriceAX96 * sqrtPriceBX96) ~/ _q96);
    return (amount0 * intermediate) ~/ (sqrtPriceBX96 - sqrtPriceAX96);
  }

  BigInt getLiquidityForAmount1(BigInt sqrtPriceAX96, BigInt sqrtPriceBX96, BigInt amount1) {
    if (sqrtPriceAX96 > sqrtPriceBX96) (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);
    return (amount1 * _q96) ~/ (sqrtPriceBX96 - sqrtPriceAX96);
  }

  BigInt getLiquidityForAmounts(
    BigInt sqrtPriceX96,
    BigInt sqrtPriceAX96,
    BigInt sqrtPriceBX96,
    BigInt amount0,
    BigInt amount1,
  ) {
    if (sqrtPriceAX96 > sqrtPriceBX96) (sqrtPriceAX96, sqrtPriceBX96) = (sqrtPriceBX96, sqrtPriceAX96);

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
    const int maxTick = 887272;
    final List<BigInt> mulConstants = [
      BigInt.parse('fff97272373d413259a46990580e213a', radix: 16),
      BigInt.parse('fff2e50f5f656932ef12357cf3c7fdcc', radix: 16),
      BigInt.parse('ffe5caca7e10e4e61c3624eaa0941cd0', radix: 16),
      BigInt.parse('ffcb9843d60f6159c9db58835c926644', radix: 16),
      BigInt.parse('ff973b41fa98c081472e6896dfb254c0', radix: 16),
      BigInt.parse('ff2ea16466c96a3843ec78b326b52861', radix: 16),
      BigInt.parse('fe5dee046a99a2a811c461f1969c3053', radix: 16),
      BigInt.parse('fcbe86c7900a88aedcffc83b479aa3a4', radix: 16),
      BigInt.parse('f987a7253ac413176f2b074cf7815e54', radix: 16),
      BigInt.parse('f3392b0822b70005940c7a398e4b70f3', radix: 16),
      BigInt.parse('e7159475a2c29b7443b29c7fa6e889d9', radix: 16),
      BigInt.parse('d097f3bdfd2022b8845ad8f792aa5825', radix: 16),
      BigInt.parse('a9f746462d870fdf8a65dc1f90e061e5', radix: 16),
      BigInt.parse('70d869a156d2a1b890bb3df62baf32f7', radix: 16),
      BigInt.parse('31be135f97d08fd981231505542fcfa6', radix: 16),
      BigInt.parse('9aa508b5b7a84e1c677de54f3e99bc9', radix: 16),
      BigInt.parse('5d6af8dedb81196699c329225ee604', radix: 16),
      BigInt.parse('2216e584f5fa1ea926041bedfe98', radix: 16),
      BigInt.parse('48a170391f7dc42444e8fa2', radix: 16),
    ];

    BigInt absTick = tick.isNegative ? -tick : tick;
    if (absTick > BigInt.from(maxTick)) throw Exception('Tick out of range');

    BigInt price =
        (absTick.toInt() & 0x1) != 0 ? BigInt.parse('fffcb933bd6fad37aa2d162d1a594001', radix: 16) : BigInt.one << 128;

    for (int i = 0; i < mulConstants.length; i++) {
      if ((absTick.toInt() & (1 << (i + 1))) != 0) {
        price = (price * mulConstants[i]) >> 128;
      }
    }

    if (tick > BigInt.zero) {
      BigInt maxUint256 = (BigInt.one << 256) - BigInt.one;
      price = maxUint256 ~/ price;
    }

    BigInt maxUint32 = (BigInt.one << 32) - BigInt.one;
    price = (price + maxUint32) >> 32;

    BigInt mask160 = (BigInt.one << 160) - BigInt.one;
    return price & mask160;
  }
}
