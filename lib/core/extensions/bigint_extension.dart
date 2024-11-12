import 'package:zup_app/core/v3_pool_constants.dart';

extension BigIntExtension on BigInt {
  bool get isMinTick => this == V3PoolConstants.minTick;
  bool get isMaxTick => this == V3PoolConstants.maxTick;
}
