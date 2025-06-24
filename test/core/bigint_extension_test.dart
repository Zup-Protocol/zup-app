import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/extensions/bigint_extension.dart';
import 'package:zup_app/core/v3_v4_pool_constants.dart';

void main() {
  test("`isMaxTick` extension should return if the bigInt passed is the max tick based on the V3 pool", () {
    BigInt maxTick = V3V4PoolConstants.maxTick;

    expect(maxTick.isMaxTick, true);
  });

  test("`isMinTick` extension should return if the bigInt passed is the min tick based on the V3 pool", () {
    BigInt minTick = V3V4PoolConstants.minTick;

    expect(minTick.isMinTick, true);
  });
}
