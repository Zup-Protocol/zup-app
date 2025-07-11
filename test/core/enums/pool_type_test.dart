import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/pool_type.dart';

void main() {
  test('When calling `isV3` and the pool is indeed v3, it should return true', () {
    expect(PoolType.v3.isV3, true);
  });

  test('When calling `isV3` and the pool is not v3, it should return false', () {
    expect(PoolType.v4.isV3, false);
  });

  test('When calling `isV4` and the pool is indeed v4, it should return true', () {
    expect(PoolType.v4.isV4, true);
  });

  test('When calling `isV4` and the pool is not v4, it should return false', () {
    expect(PoolType.v3.isV4, false);
  });

  test('When calling `isV2` and the pool is indeed v2, it should return true', () {
    expect(PoolType.v2.isV2, true);
  });

  test('When calling `isV2` and the pool is not v2, it should return false', () {
    expect(PoolType.v3.isV2, false);
  });

  test('label should return correct string', () {
    expect(PoolType.v3.label, "V3");
    expect(PoolType.v4.label, "V4");
    expect(PoolType.v2.label, "V2");
  });
}
