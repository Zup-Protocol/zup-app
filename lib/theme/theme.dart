import 'package:flutter/material.dart';
import 'package:zup_ui_kit/zup_colors.dart';
import 'package:zup_ui_kit/zup_theme.dart';

abstract class AppTheme {
  static String get fontFamily => "SNPro";
  static Color get primaryColor => ZupColors.brand;

  static ThemeData get lightTheme => ZupTheme.lightTheme.copyWith(
    primaryColor: primaryColor,
    textSelectionTheme: const TextSelectionThemeData(selectionColor: ZupColors.brand5),
    textTheme: ZupTheme.lightTheme.textTheme.apply(fontFamily: fontFamily),
  );

  static ThemeData get darkTheme => ZupTheme.darkTheme.copyWith(
    primaryColor: primaryColor,
    textTheme: ZupTheme.darkTheme.textTheme.apply(fontFamily: fontFamily),
    textSelectionTheme: TextSelectionThemeData(selectionColor: ZupColors.brand.withValues(alpha: 0.3)),
  );
}
