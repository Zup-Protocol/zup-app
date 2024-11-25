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

    expect(number.formatCurrency(isUSD: true), "\$123,456,789.1235");
  });

  test('When the param `isUSD` is false on `formatCurrency` it should format and do not add any currency symbol', () {
    const number = 123456789.12345678;

    expect(number.formatCurrency(isUSD: false), "123,456,789.1235");
  });

  test("`toAmount` should return a string with the number formatted with fixed decimals of 4 (if none is passed)", () {
    const number = 123456789.12345678;

    expect(number.toAmount(), "123456789.1235");
  });

  test("`toAmount` should return a string with the number formatted with fixed decimals passed", () {
    const number = 123456789.12345678;

    expect(number.toAmount(maxFixedDigits: 2), "123456789.12");
  });

  test("if `useLessThan` is true on `toAmount` and the passed amount is less than 0.0001 it should return '<0.0001'",
      () {
    const number = 0.00001;

    expect(number.toAmount(useLessThan: true), "<0.0001");
  });

  test(""""if `useLessThan` is true on `toAmount` and the passed amount is not less than 0.0001
       it should return it with fixed decimals of 4 (if none is passed)
       """, () {
    const number = 0.0143124;

    expect(number.toAmount(useLessThan: true), "0.0143");
  });

  test("""if `useLessThan` is true on `toAmount` and the passed amount
  is not less than 0.0001 it should return it with fixed decimals passed
       """, () {
    const number = 0.0143124;

    expect(number.toAmount(useLessThan: true, maxFixedDigits: 2), "0.01");
  });

  test("if the amount passed to `toAmount` is 0 it should return 0", () {
    const number = 0;

    expect(number.toAmount(), "0");
  });
}
