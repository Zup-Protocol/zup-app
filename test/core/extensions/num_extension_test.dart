import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/extensions/num_extension.dart';

void main() {
  test("The `decimals` getter should return how much digits the number has after the `.`", () {
    expect(2.123456789.decimals, 9);
  });

  test("The `decimals` getter should return how much digits the number has after the `.` (with big decimals)", () {
    const number = 0.0000000000000000006;

    expect(number.decimals, 19);
  });

  test("The `decimals` getter should return how much digits the number has after the `.` (without decimals)", () {
    const number = 12;

    expect(number.decimals, 0);
  });

  test('When the param `isUSD` is true on `formatCurrency` it should format and add the correct currency symbol', () {
    const number = 123456789.12345678;

    expect(number.formatCurrency(isUSD: true), "\$123,456,789.12345678");
  });

  test('When the param `isUSD` is false on `formatCurrency` it should format and do not add any currency symbol', () {
    const number = 123456789.12345678;

    expect(number.formatCurrency(isUSD: false), "123,456,789.12345678");
  });
}
