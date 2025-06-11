import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class Slippage extends Equatable {
  const Slippage._(this.value);

  final num value;

  static const Slippage zeroPointOnePercent = Slippage._(0.1);
  static const Slippage halfPercent = Slippage._(0.5);
  static const Slippage onePercent = Slippage._(1.0);
  static custom(num value) => Slippage._(value);

  factory Slippage.fromValue(num value) {
    if (value == zeroPointOnePercent.value) return zeroPointOnePercent;
    if (value == halfPercent.value) return halfPercent;
    if (value == onePercent.value) return onePercent;

    return custom(value);
  }

  Color get riskBackgroundColor {
    if (value > 10) return ZupColors.red6;
    if (value > 1) return ZupColors.orange6;

    return ZupColors.gray6;
  }

  Color get riskForegroundColor {
    if (value > 10) return ZupColors.red;
    if (value > 1) return ZupColors.orange;

    return ZupColors.brand;
  }

  BigInt calculateMinTokenAmountFromSlippage(BigInt amount) {
    return amount * (BigInt.from(10000) - BigInt.from(valueBasisPoints)) ~/ BigInt.from(10000);
  }

  BigInt calculateMaxTokenAmountFromSlippage(BigInt amount) {
    return amount * (BigInt.from(10000) + BigInt.from(valueBasisPoints)) ~/ BigInt.from(10000);
  }

  bool get isCustom => this != zeroPointOnePercent && this != halfPercent && this != onePercent;

  int get valueBasisPoints => (value * 100).toInt();

  @override
  List<Object?> get props => [value];
}
