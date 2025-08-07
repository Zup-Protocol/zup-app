import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/enums/app_theme_mode.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class AppSettingsDropdown extends StatefulWidget {
  const AppSettingsDropdown({super.key});

  static void show(BuildContext showBelowContext) => ZupPopover.show(
    showBasedOnContext: showBelowContext,
    adjustment: const Offset(0, 16),
    child: const AppSettingsDropdown(),
  );

  @override
  State<AppSettingsDropdown> createState() => _AppSettingsDropdownState();
}

class _AppSettingsDropdownState extends State<AppSettingsDropdown> {
  final appCubit = inject<AppCubit>();

  @override
  Widget build(BuildContext context) {
    return Container(
      // width: 240,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: ZupThemeColors.background.themed(context.brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
      ),
      child: BlocBuilder<AppCubit, AppState>(
        bloc: appCubit,
        builder: (context, state) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            spacing: 16,
            children: [
              const Text("Theme Mode", style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              SizedBox(
                width: 180,
                child: ZupPopupMenuButton(
                  buttonHeight: 40,
                  initialSelectedIndex: appCubit.currentThemeMode.index,
                  items: AppThemeMode.values.map((themeMode) {
                    return ZupPopupMenuItem(
                      title: themeMode.label(context),
                      icon: Padding(
                        padding: const EdgeInsets.all(5),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            ZupThemeColors.iconColor.themed(context.brightness),
                            BlendMode.srcIn,
                          ),
                          child: themeMode.icon(),
                        ),
                      ),
                    );
                  }).toList(),

                  onSelected: (int selectedIndex) {
                    final newThemeMode = AppThemeMode.values[selectedIndex];
                    appCubit.updateAppThemeMode(newThemeMode);
                  },
                ),
              ),

              Row(
                // spacing: 10,
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      key: const Key("testnet-mode-text"),
                      onTap: () => appCubit.toggleTestnetMode(),
                      child: Text(S.of(context).appSettingsDropdownTestnetMode, style: const TextStyle(fontSize: 14)),
                    ),
                  ),
                  // const SizedBox(width: 20),
                  const Spacer(),
                  ZupSwitch(
                    key: const Key("testnet-mode-switch"),
                    value: appCubit.isTestnetMode,
                    onChanged: (value) => appCubit.toggleTestnetMode(),
                    size: 42,
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
