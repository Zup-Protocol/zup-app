import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class AppSettingsDropdown extends StatefulWidget {
  const AppSettingsDropdown({super.key});

  static void show(BuildContext showBelowContext) => ZupDropdown.show(
        showBelowContext: showBelowContext,
        offset: const Offset(0, 16),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ZupColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZupColors.gray5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            fit: FlexFit.loose,
            child: Row(
              spacing: 10,
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    key: const Key("testnet-mode-text"),
                    onTap: () => appCubit.toggleTestnetMode(),
                    child: Text(
                      S.of(context).appSettingsDropdownTestnetMode,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 28),
                BlocBuilder<AppCubit, AppState>(
                  bloc: appCubit,
                  builder: (context, state) {
                    return ZupSwitch(
                      key: const Key("testnet-mode-switch"),
                      value: appCubit.isTestnetMode,
                      onChanged: (value) => appCubit.toggleTestnetMode(),
                      size: 42,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
