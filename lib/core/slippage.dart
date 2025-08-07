import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class Slippage extends Equatable {
  const Slippage._(this.value);

  final num value;

  static const Slippage zeroPointOnePercent = Slippage._(0.1);
  static const Slippage halfPercent = Slippage._(0.5);
  static const Slippage onePercent = Slippage._(1.0);
  static Slippage custom(num value) => Slippage._(value);

  factory Slippage.fromValue(num value) {
    if (value == zeroPointOnePercent.value) return zeroPointOnePercent;
    if (value == halfPercent.value) return halfPercent;
    if (value == onePercent.value) return onePercent;

    return custom(value);
  }

  Color? riskBackgroundColor(Brightness brightness) {
    if (brightness.isDark) return ZupColors.black3;

    if (value > 10) return ZupColors.red6;
    if (value > 1) return ZupColors.orange6;

    return null;
  }

  Color? riskForegroundColor(Brightness brightness) {
    if (value > 10) return ZupThemeColors.error.themed(brightness);
    if (value > 1) return ZupThemeColors.alert.themed(brightness);

    return null;
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
