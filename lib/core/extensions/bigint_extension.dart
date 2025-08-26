import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';

extension BigIntExtension on BigInt {
  bool get isMinTick => this == CLPoolConstants.minTick;
  bool get isMaxTick => this == CLPoolConstants.maxTick;
}
