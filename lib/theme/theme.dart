import 'package:flutter/material.dart';
import 'package:zup_app/theme/themes/zup_text_button_theme.dart';
import 'package:zup_ui_kit/zup_colors.dart';

abstract class ZupTheme {
  static String get fontFamily => "SF Pro Rounded";

  static ThemeData get lightTheme => ThemeData(
        fontFamily: "SF Pro Rounded",
        primaryColor: ZupColors.brand,
        scaffoldBackgroundColor: Colors.transparent,
        textButtonTheme: ZupTextButtonTheme.lightTheme,
        textTheme: const TextTheme(
          titleSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: ZupColors.black),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ZupColors.black),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ZupColors.black),
        ),
      );
}
