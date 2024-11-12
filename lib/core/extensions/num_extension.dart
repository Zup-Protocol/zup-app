import 'package:intl/intl.dart';

extension NumExtension on num {
  String toAmount({bool useLessThan = false, int maxFixedDigits = 4}) {
    if (this == 0) return '0';
    if (this < 0.0001) return useLessThan ? '<0.0001' : toString();

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

  String formatCurrency({bool isUSD = true}) => NumberFormat.simpleCurrency(
        decimalDigits: decimals,
        name: isUSD ? null : "",
      ).format(this);

  String get formatPercent => "${NumberFormat.decimalPatternDigits(decimalDigits: 0).format(this)}%";
}
