import 'package:zup_app/core/enums/networks.dart';

mixin KeysMixin {
  String userTokenBalanceCacheKey(
      {required String userAddress,
      required String tokenAddress,
      required bool isNative,
      required AppNetworks network}) {
    return 'userTokenBalance-$userAddress-$tokenAddress-native=$isNative-${network.name}';
  }

  String poolTickCacheKey({required AppNetworks network, required String poolAddress}) {
    return 'poolTick-$poolAddress-${network.name}';
  }

  String tokenPriceCacheKey({required String tokenAddress, required AppNetworks network}) {
    return 'tokenPrice-$tokenAddress-${network.name}';
  }
}
