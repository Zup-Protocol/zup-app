import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';

class _KeysMixinWrapper with KeysMixin {}

void main() {
  test("`userTokenBalanceCacheKey` should return correct key", () {
    const userAddress = '0xUserAddress';
    const tokenAddress = '0xTokenAddress';
    const isNative = true;
    const network = AppNetworks.sepolia;

    final key = _KeysMixinWrapper().userTokenBalanceCacheKey(
      userAddress: userAddress,
      tokenAddress: tokenAddress,
      isNative: isNative,
      network: network,
    );

    expect(key, 'userTokenBalance-$userAddress-$tokenAddress-native=$isNative-${network.name}');
  });

  test("`poolTickCacheKey` should return correct key", () {
    const network = AppNetworks.sepolia;
    const poolAddress = '0xPoolAddress';

    final key = _KeysMixinWrapper().poolTickCacheKey(
      network: network,
      poolAddress: poolAddress,
    );

    expect(key, 'poolTick-$poolAddress-${network.name}');
  });

  test("`tokenPriceCacheKey` should return correct key", () {
    const tokenAddress = '0xTokenAddress';
    const network = AppNetworks.sepolia;

    final key = _KeysMixinWrapper().tokenPriceCacheKey(
      tokenAddress: tokenAddress,
      network: network,
    );

    expect(key, 'tokenPrice-$tokenAddress-${network.name}');
  });

  test("protocolsListKey should return correct key", () {
    final key = _KeysMixinWrapper().protocolsListKey;

    expect(key, 'zup-supported-protocols');
  });
}
