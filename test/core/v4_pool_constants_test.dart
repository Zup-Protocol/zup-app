import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/v4_pool_constants.dart';

void main() {
  test('mintPositionActionValue should return the correct value', () {
    expect(V4PoolConstants.mintPositionActionValue, 0x02);
  });

  test('settlePairActionValue should return the correct value', () {
    expect(V4PoolConstants.settlePairActionValue, 0x0d);
  });

  test('sweepActionValue should return the correct value', () {
    expect(V4PoolConstants.sweepActionValue, 0x14);
  });
}
