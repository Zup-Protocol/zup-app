import 'package:zup_app/core/v3_v4_pool_constants.dart';

extension BigIntExtension on BigInt {
  bool get isMinTick => this == V3V4PoolConstants.minTick;
  bool get isMaxTick => this == V3V4PoolConstants.maxTick;
}
