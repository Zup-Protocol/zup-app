import 'dart:math';

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

  test("When using `formatCompactCurrency`, it should return a string in the compact form (100k instead of 100,000)",
      () {
    const number = 123456;

    expect(number.formatCompactCurrency(), "USD 123K");
  });

  test("""When using `formatCompactCurrency` with `isUSD` false,
  it should return a string in the compact form
  (100k instead of 100,000), but without the currency symbol""", () {
    const number = 123456;

    expect(number.formatCompactCurrency(isUSD: false), "123K");
  });

  test(
    """When passing `useMoreThan` true to `formatCompactCurrency`,
    and the number is bigger than `maxBeforeMoreThan`, which
    by default is `999 * (10 ** 12)` it should return a string with the symbol '>'
    and the max number""",
    () {
      final number = pow(10, 13) * 999;

      expect(number.formatCompactCurrency(useMoreThan: true), ">999T");
    },
  );

  test(
    """When passing `useMoreThan` true to `formatCompactCurrency`,
    and the number is bigger than the passed `maxBeforeMoreThan`,
    it should return a string with the symbol '>' and the max number
    """,
    () {
      final number = pow(10, 13) * 999;

      expect(
          number.formatCompactCurrency(
            useMoreThan: true,
            maxBeforeMoreThan: 1000,
          ),
          ">1K");
    },
  );

  test(
    """When passing `useMoreThan` true to `formatCompactCurrency`,
    and the number is not bigger than the passed `maxBeforeMoreThan`,
    it should return the passed number, but formated compactly
    """,
    () {
      expect(
        1000.formatCompactCurrency(
          useMoreThan: true,
          maxBeforeMoreThan: 200000,
          isUSD: false,
        ),
        "1K",
      );
    },
  );

  test(
    """When passing `useMoreThan` true to `formatCompactCurrency`,
    and the number is not bigger than the default `maxBeforeMoreThan`,
    which is `999 * (10 ** 12)`, it should return the passed number,
    but formated compactly
    """,
    () {
      expect(
        1000.formatCompactCurrency(
          useMoreThan: true,
          isUSD: false,
        ),
        "1K",
      );
    },
  );

  test(
    """`maybeFormatCompactCurrency` should format compact if
    the passed number is bigger than maxBeforeCompact""",
    () {
      expect(
        1000.maybeFormatCompactCurrency(maxBeforeCompact: 999),
        "USD 1K",
      );
    },
  );

  test(
    """When `isUSD` is false in `maybeFormatCompactCurrency` should format compact if
    the passed number is bigger than maxBeforeCompact, but without the currency symbol""",
    () {
      expect(
        1000.maybeFormatCompactCurrency(
          maxBeforeCompact: 999,
          isUSD: false,
        ),
        "1K",
      );
    },
  );

  test(
    """When `useMoreThan` is true in `maybeFormatCompactCurrency
     should format compact if the passed number is bigger than maxBeforeMoreThan`""",
    () {
      expect(
        1000.maybeFormatCompactCurrency(
          maxBeforeMoreThan: 999,
          useMoreThan: true,
          isUSD: false,
        ),
        ">999",
      );
    },
  );

  test(
    """When `useLessThan` is true in `maybeFormatCompactCurrency`
    and the passed number is less than 0.0001 should use `<`
    """,
    () {
      expect(
        0.00001.maybeFormatCompactCurrency(useLessThan: true),
        "<0.0001",
      );
    },
  );
}
