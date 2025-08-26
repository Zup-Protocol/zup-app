import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/concentrated_liquidity_utils/cl_pool_constants.dart';

void main() {
  test("minTick should be the correct value", () {
    expect(CLPoolConstants.minTick, BigInt.from(-887272));
  });

  test("maxTick should be the correct value", () {
    expect(CLPoolConstants.maxTick, BigInt.from(887272));
  });

  test("Q96 should be the correct value", () {
    expect(CLPoolConstants.q96, BigInt.from(2).pow(96));
  });

  test("Q32 should be the correct value", () {
    expect(CLPoolConstants.q32, BigInt.from(2).pow(32));
  });
}
