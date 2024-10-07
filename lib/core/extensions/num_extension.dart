import 'package:intl/intl.dart';

extension NumExtension on num {
  int get decimals {
    final numberInString = toString();

    if (numberInString.contains(".")) return numberInString.split(".")[1].length;
    if (numberInString.contains("e")) return num.parse(numberInString.split("e")[1]).abs().toInt();

    return 0;
  }

  String formatCurrency({bool isUSD = true}) => NumberFormat.simpleCurrency(
        decimalDigits: decimals,
        name: isUSD ? null : "",
      ).format(this);
}
