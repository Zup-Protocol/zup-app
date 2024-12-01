import 'dart:math';

import 'package:decimal/decimal.dart';
import 'package:intl/intl.dart';

extension NumExtension on num {
  String toAmount({bool useLessThan = false, int maxFixedDigits = 4}) {
    if (this == 0) return '0';
    if (this < double.parse("0.${"0" * (maxFixedDigits - 1)}1")) {
      return useLessThan ? '<${"0.${"0" * (maxFixedDigits - 1)}1"}' : toString();
    }

    return toStringAsFixed(maxFixedDigits);
  }

  int get decimals {
    final numberInString = toString();

    if (numberInString.contains("e")) {
      final splittedOnScientificNotation = numberInString.split("e");
      final scientificNotationDecimals = num.parse(splittedOnScientificNotation[0]);
      final decimalsBeforeScientificNotation = scientificNotationDecimals.toString().replaceAll(".", "").length - 1;

      return decimalsBeforeScientificNotation + num.parse(splittedOnScientificNotation[1]).abs().toInt();
    }

    if (numberInString.contains(".")) return numberInString.split(".")[1].length;

    return 0;
  }

  String formatCurrency({
    bool isUSD = true,
    bool useLessThan = false,
    int maxDecimals = 4,
  }) {
    int decimalsDigits = decimals;
    final maxDecimalsNumber = double.parse("0.${"0" * (maxDecimals - 1)}1");

    if (decimals > maxDecimals && (this > maxDecimalsNumber)) decimalsDigits = maxDecimals;
    if (useLessThan && this < maxDecimalsNumber) return toAmount(useLessThan: true, maxFixedDigits: maxDecimals);
    if (this < 0.1) return Decimal.parse(toString()).toString();

    return NumberFormat.simpleCurrency(
      decimalDigits: decimalsDigits,
      name: isUSD ? null : "",
    ).format(this);
  }

  String formatCompactCurrency({
    bool isUSD = true,
    bool useMoreThan = false,
    num? maxBeforeMoreThan,
  }) {
    final maxWithoutMoreThan = maxBeforeMoreThan ?? pow(10, 12) * 999;

    if (useMoreThan && this > maxWithoutMoreThan) {
      return NumberFormat.compactCurrency(
        decimalDigits: decimals,
        name: ">",
      ).format(maxWithoutMoreThan);
    }

    return NumberFormat.compactCurrency(
      decimalDigits: decimals,
      name: isUSD ? "USD " : "",
    ).format(this);
  }

  String maybeFormatCompactCurrency({
    bool isUSD = true,
    bool useMoreThan = false,
    bool useLessThan = false,
    num? maxBeforeMoreThan,
    num? maxBeforeCompact,
  }) {
    final maxWithoutMoreThan = maxBeforeMoreThan ?? pow(10, 12) * 999;
    final maxWithoutCompact = maxBeforeCompact ?? maxWithoutMoreThan;

    if (this > maxWithoutCompact) {
      return formatCompactCurrency(
        isUSD: isUSD,
        useMoreThan: useMoreThan,
        maxBeforeMoreThan: maxWithoutMoreThan,
      );
    }

    return formatCurrency(
      isUSD: isUSD,
      useLessThan: useLessThan,
    );
  }

  String get formatPercent => "${NumberFormat.decimalPatternDigits(decimalDigits: 0).format(this)}%";
}
