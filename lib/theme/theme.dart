import 'package:flutter/material.dart';
import 'package:zup_app/theme/themes/zup_text_button_theme.dart';
import 'package:zup_ui_kit/zup_colors.dart';

abstract class ZupTheme {
  static String get fontFamily => "SF Pro Rounded";

  static ThemeData get lightTheme => ThemeData(
        fontFamily: "SF Pro Rounded",
        primaryColor: ZupColors.brand,
        inputDecorationTheme: const InputDecorationTheme(
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZupColors.red, width: 1.5),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZupColors.red, width: 1.5),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
            borderSide: BorderSide(color: ZupColors.brand, width: 1.5),
          ),
        ),
        scrollbarTheme:
            const ScrollbarThemeData(mainAxisMargin: 10, crossAxisMargin: 3, thickness: WidgetStatePropertyAll(5)),
        scaffoldBackgroundColor: Colors.transparent,
        textButtonTheme: ZupTextButtonTheme.lightTheme,
        textSelectionTheme: const TextSelectionThemeData(selectionColor: ZupColors.brand5),
        textTheme: const TextTheme(
          titleSmall: TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: ZupColors.black),
          bodySmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: ZupColors.black),
          bodyMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: ZupColors.black),
        ),
      );
}
