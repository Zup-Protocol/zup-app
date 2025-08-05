import 'package:flutter/material.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';

enum AppThemeMode {
  light,
  dark,
  system;

  bool get isLight => this == AppThemeMode.light;
  bool get isDark => this == AppThemeMode.dark;
  bool get isSystem => this == AppThemeMode.system;

  String label(BuildContext context) {
    switch (this) {
      case AppThemeMode.light:
        return S.of(context).light;
      case AppThemeMode.dark:
        return S.of(context).dark;
      case AppThemeMode.system:
        return S.of(context).system;
    }
  }

  Widget icon() {
    switch (this) {
      case AppThemeMode.light:
        return Assets.icons.sunMax.svg(height: 12, width: 12);
      case AppThemeMode.dark:
        return Assets.icons.moon.svg(height: 12, width: 12);
      case AppThemeMode.system:
        return Assets.icons.laptop.svg(height: 12, width: 12);
    }
  }

  ThemeMode get flutterThemeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
}
