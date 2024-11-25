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

  String formatCurrency({bool isUSD = true}) {
    int decimalsDigits = decimals;

    if (decimals > 4 && (this > 0.001)) decimalsDigits = 4;

    return NumberFormat.simpleCurrency(
      decimalDigits: decimalsDigits,
      name: isUSD ? null : "",
    ).format(this);
  }

  String get formatPercent => "${NumberFormat.decimalPatternDigits(decimalDigits: 0).format(this)}%";
}
