import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';
import 'package:zup_app/core/extensions/bigint_extension.dart';

void main() {
  test("`isMaxTick` extension should return if the bigInt passed is the max tick based on the V3 pool", () {
    BigInt maxTick = CLPoolConstants.maxTick;

    expect(maxTick.isMaxTick, true);
  });

  test("`isMinTick` extension should return if the bigInt passed is the min tick based on the V3 pool", () {
    BigInt minTick = CLPoolConstants.minTick;

    expect(minTick.isMinTick, true);
  });
}
