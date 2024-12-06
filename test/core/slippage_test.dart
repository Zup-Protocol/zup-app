import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

void main() {
  test(
    "When using `zeroPointOnePercent` method it should create the slippage object with 0.1 value",
    () {
      expect(Slippage.zeroPointOnePercent.value, 0.1);
    },
  );

  test(
    "When using `halfPercent` method it should create the slippage object with 0.5 value",
    () {
      expect(Slippage.halfPercent.value, 0.5);
    },
  );

  test(
    "When using `onePercent` method it should create the slippage object with 1 value",
    () {
      expect(Slippage.onePercent.value, 1);
    },
  );

  test(
    "When using `custom` method it should create the slippage object with the passed value",
    () {
      expect(Slippage.custom(32).value, 32);
    },
  );

  test("When passing '0.1' to `fromValue` factory, it should create a 'zeroPointOnePercent' slippage object", () {
    expect(Slippage.fromValue(0.1), Slippage.zeroPointOnePercent);
  });

  test("When passing '0.5' to `fromValue` factory, it should create a 'halfPercent' slippage object", () {
    expect(Slippage.fromValue(0.5), Slippage.halfPercent);
  });

  test("When passing '1' to `fromValue` factory, it should create a 'onePercent' slippage object", () {
    expect(Slippage.fromValue(1), Slippage.onePercent);
  });

  test("When passing a non-mapped value to `fromValue` factory, it should create a 'custom' slippage object", () {
    expect(Slippage.fromValue(542), Slippage.custom(542));
  });

  test("When passing a value greater than 10 in `riskBackgroundColor` it should return the red6 color", () {
    expect(Slippage.custom(11).riskBackgroundColor, ZupColors.red6);
  });

  test("When passing a value lower than 10 in `riskBackgroundColor` it should return the orange6 color", () {
    expect(Slippage.custom(5).riskBackgroundColor, ZupColors.orange6);
  });

  test("When passing a value lower than 1 in `riskBackgroundColor` it should return the gray6 color", () {
    expect(Slippage.custom(0.5).riskBackgroundColor, ZupColors.gray6);
  });

  test("When passing a value greater than 10 in `riskForegroundColor` it should return the red color", () {
    expect(Slippage.custom(11).riskForegroundColor, ZupColors.red);
  });

  test("When passing a value lower than 10 in `riskForegroundColor` it should return the orange color", () {
    expect(Slippage.custom(5).riskForegroundColor, ZupColors.orange);
  });

  test("When passing a value lower than 1 in `riskForegroundColor` it should return the brand color", () {
    expect(Slippage.custom(0.5).riskForegroundColor, ZupColors.brand);
  });

  test(
      "When using `isCustom` method it should return true if the slippage is not `zeroPointOnePercent`, `halfPercent` or `onePercent`",
      () {
    expect(Slippage.custom(43672).isCustom, true);
  });

  test(
      "When using `isCustom` method it should return false if the slippage is one of `zeroPointOnePercent`, `halfPercent` or `onePercent`",
      () {
    expect(Slippage.zeroPointOnePercent.isCustom, false, reason: "zeroPointOnePercent is not custom");
    expect(Slippage.halfPercent.isCustom, false, reason: "halfPercent is not custom");
    expect(Slippage.onePercent.isCustom, false, reason: "onePercent is not custom");
  });

  test("Equatable props should use the `value` field", () {
    expect(Slippage.zeroPointOnePercent.props, [Slippage.zeroPointOnePercent.value]);
  });

  group("""`calculateTokenAmountFromSlippage` should calculate the token amount with the slippage applied.
  basicaly it's the amount - (x)%""", () {
    test("(50% test case)", () {
      expect(
        Slippage.fromValue(50).calculateTokenAmountFromSlippage(BigInt.from(1000000)),
        BigInt.from(500000),
      );
    });

    test("(10% test case)", () {
      expect(
        Slippage.fromValue(10).calculateTokenAmountFromSlippage(BigInt.from(1000000)),
        BigInt.from(900000),
      );
    });

    test("(0% test case)", () {
      expect(
        Slippage.fromValue(0).calculateTokenAmountFromSlippage(BigInt.from(1000000)),
        BigInt.from(1000000),
      );
    });

    test("(100% test case)", () {
      expect(
        Slippage.fromValue(100).calculateTokenAmountFromSlippage(BigInt.from(1000000)),
        BigInt.from(0),
      );
    });
  });

  test("`valueBasisPoints` should return the slippage value in basis points", () {
    expect(Slippage.zeroPointOnePercent.valueBasisPoints, 10, reason: "zeroPointOnePercent is 10 basis points");
    expect(Slippage.halfPercent.valueBasisPoints, 50, reason: "halfPercent is 50 basis points");
    expect(Slippage.onePercent.valueBasisPoints, 100, reason: "onePercent is 100 basis points");
  });
}
