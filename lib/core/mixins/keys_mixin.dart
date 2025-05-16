import 'package:zup_app/core/enums/networks.dart';

mixin KeysMixin {
  String userTokenBalanceCacheKey({required String userAddress, required String tokenAddress, bool isNative = false}) {
    return 'userTokenBalance-$userAddress-$tokenAddress-native=$isNative';
  }

  String poolTickCacheKey({required AppNetworks network, required String poolAddress}) {
    return 'poolTick-$poolAddress-${network.name}';
  }
}
