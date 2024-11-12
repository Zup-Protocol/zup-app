import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';

class _V3PoolConversorsMixinWrapper with V3PoolConversorsMixin {}

void main() {
  test("`priceToTick` should convert a given price to tick in v3 pool", () {
    const token0Decimals = 18; // ETH
    const token1Decimals = 6; // USDC / USDT
    const value = 1200.12;

    final tick = _V3PoolConversorsMixinWrapper().priceToTick(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      value: value,
    );

    expect(tick, BigInt.from(-347230));
  });

  test("`tickToPrice` should convert a given tick to price in v3 pool", () {
    const token0Decimals = 18; // ETH
    const token1Decimals = 6; // USDC / USDT
    const tick = -347230;

    final price = _V3PoolConversorsMixinWrapper().tickToPrice(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      tick: BigInt.from(tick),
    );

    expect(price, 1200.1992333687367);
  });

  test("""When the param `asToken0byToken1` is true,
  `tickToPrice` should return the price with
  token0 as the quote token (ex instead of "ETH/USDC" it will be "USDC/ETH")""", () {
    const token0Decimals = 18; // ETH
    const token1Decimals = 6; // USDC / USDT
    const tick = -347230;

    final price = _V3PoolConversorsMixinWrapper().tickToPrice(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      tick: BigInt.from(tick),
      asToken0byToken1: true,
    );

    expect(price, 0.0008331949997944803);
  });

  test("`tickToClosestValidTick` should return the closest valid tick based on the tick spacing", () {
    const tick = -347234;
    const tickSpacing = 10;
    const expectedClosestValidTick = -347230;

    final closestValidTick = _V3PoolConversorsMixinWrapper().tickToClosestValidTick(
      tick: BigInt.from(tick),
      tickSpacing: tickSpacing,
    );

    expect(closestValidTick, BigInt.from(expectedClosestValidTick));
  });

  test("`priceToClosestValidPrice` should return the closest valid price based on the tick spacing", () {
    const token0Decimals = 18; // ETH
    const token1Decimals = 6; // USDC / USDT

    const tickSpacing = 10;
    const value = 1243.12;

    final closestValidPrice = _V3PoolConversorsMixinWrapper().priceToClosestValidPrice(
      token0Decimals: token0Decimals,
      token1Decimals: token1Decimals,
      tickSpacing: tickSpacing,
      value: value,
    );

    expect(closestValidPrice, 1242.9478055472944);
  });
}
