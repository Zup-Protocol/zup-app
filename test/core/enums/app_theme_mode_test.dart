import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/app_theme_mode.dart';

void main() {
  test("When calling 'isLight' and the theme mode is light, it should return true", () {
    expect(AppThemeMode.light.isLight, true);
  });

  test("When calling 'isLight' and the theme mode is not light, it should return false", () {
    expect(AppThemeMode.dark.isLight, false);
  });

  test("When calling 'isDark' and the theme mode is dark, it should return true", () {
    expect(AppThemeMode.dark.isDark, true);
  });

  test("When calling 'isDark' and the theme mode is not dark, it should return false", () {
    expect(AppThemeMode.light.isDark, false);
  });

  test("When calling 'isSystem' and the theme mode is system, it should return true", () {
    expect(AppThemeMode.system.isSystem, true);
  });

  test("When calling 'isSystem' and the theme mode is not system, it should return false", () {
    expect(AppThemeMode.light.isSystem, false);
  });

  test("When calling 'flutterThemeMode' and the theme mode is light, it should return ThemeMode.light", () {
    expect(AppThemeMode.light.flutterThemeMode, ThemeMode.light);
  });

  test("When calling 'flutterThemeMode' and the theme mode is dark, it should return ThemeMode.dark", () {
    expect(AppThemeMode.dark.flutterThemeMode, ThemeMode.dark);
  });

  test("When calling 'flutterThemeMode' and the theme mode is system, it should return ThemeMode.system", () {
    expect(AppThemeMode.system.flutterThemeMode, ThemeMode.system);
  });
}
