import 'package:zup_app/core/enums/networks.dart';

mixin KeysMixin {
  String userTokenBalanceCacheKey({required String userAddress, required String tokenAddress}) {
    return 'userTokenBalance-$userAddress-$tokenAddress';
  }

  String poolTickCacheKey({required Networks network, required String poolAddress}) {
    return 'poolTick-$poolAddress-${network.name}';
  }
}
