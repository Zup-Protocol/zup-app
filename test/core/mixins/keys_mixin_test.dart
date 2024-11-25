import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';

class _KeysMixinWrapper with KeysMixin {}

void main() {
  test("`userTokenBalanceCacheKey` should return correct key", () {
    const userAddress = '0xUserAddress';
    const tokenAddress = '0xTokenAddress';

    final key = _KeysMixinWrapper().userTokenBalanceCacheKey(
      userAddress: userAddress,
      tokenAddress: tokenAddress,
    );

    expect(key, 'userTokenBalance-$userAddress-$tokenAddress');
  });

  test("`poolTickCacheKey` should return correct key", () {
    const network = Networks.sepolia;
    const poolAddress = '0xPoolAddress';

    final key = _KeysMixinWrapper().poolTickCacheKey(
      network: network,
      poolAddress: poolAddress,
    );

    expect(key, 'poolTick-$poolAddress-${network.name}');
  });
}
