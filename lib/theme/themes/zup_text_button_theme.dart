import 'package:flutter/material.dart';
import 'package:zup_app/theme/theme.dart';
import 'package:zup_ui_kit/zup_colors.dart';

abstract class ZupTextButtonTheme {
  static TextButtonThemeData get lightTheme => TextButtonThemeData(
        style: ButtonStyle(
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          )),
          overlayColor: WidgetStatePropertyAll(ZupColors.brand.withValues(alpha: .05)),
          foregroundColor: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.disabled)) return ZupColors.gray5;

            return ZupColors.black;
          }),
          textStyle: WidgetStateProperty.resolveWith((states) {
            return TextStyle(fontSize: 17, fontWeight: FontWeight.normal, fontFamily: ZupTheme.fontFamily);
          }),
        ),
      );
}
