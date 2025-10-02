import 'package:currency_text_input_formatter/currency_text_input_formatter.dart';
import 'package:flutter/material.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class CreatePageSettingsDropdown extends StatefulWidget {
  const CreatePageSettingsDropdown({super.key, required this.onClose});

  final void Function() onClose;

  static void show(BuildContext showBelowContext, {required void Function() onClose}) => ZupPopover.show(
    showBasedOnContext: showBelowContext,
    adjustment: const Offset(0, 10),
    child: CreatePageSettingsDropdown(onClose: onClose),
  );

  @override
  State<CreatePageSettingsDropdown> createState() => _CreatePageSettingsDropdownState();
}

class _CreatePageSettingsDropdownState extends State<CreatePageSettingsDropdown> {
  final minTVLController = TextEditingController();
  final cache = inject<AppCache>();
  final debouncer = inject<Debouncer>();

  bool showLowTVLAlert = false;

  void maybeShowLowTVLAlert() {
    if (minTVLController.text.isEmpty) {
      return setState(() => showLowTVLAlert = false);
    }

    if (num.parse(minTVLController.text.replaceAll(",", "")) < PoolSearchSettingsDto.defaultMinLiquidityUSD) {
      setState(() => showLowTVLAlert = true);
    } else if (showLowTVLAlert) {
      setState(() => showLowTVLAlert = false);
    }
  }

  Widget sectionTitle(String title) => Text(
    title,
    style: TextStyle(
      fontWeight: FontWeight.w600,
      fontSize: 15,
      color: ZupThemeColors.primaryText.themed(context.brightness),
    ),
  );

  @override
  void initState() {
    minTVLController.text = cache.getPoolSearchSettings().minLiquidityUSD.formatCurrency(isUSD: false);
    WidgetsBinding.instance.addPostFrameCallback((_) => maybeShowLowTVLAlert());

    super.initState();
  }

  @override
  void dispose() {
    minTVLController.dispose();
    widget.onClose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: ZupThemeColors.background.themed(context.brightness),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              sectionTitle(S.of(context).createPageSettingsDropdownMinimumLiquidity),
              const SizedBox(width: 8),
              ZupTooltip.text(
                key: const Key("min-liquidity-tooltip"),
                message: S.of(context).createPageSettingsDropdownMinimumLiquidityExplanation,
                child: Assets.icons.infoCircle.svg(
                  colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 200,
            child: TextField(
              key: const Key("min-liquidity-field"),
              onChanged: (value) {
                maybeShowLowTVLAlert();

                debouncer.run(() async {
                  await cache.savePoolSearchSettings(
                    settings: cache.getPoolSearchSettings().copyWith(
                      minLiquidityUSD:
                          num.tryParse(value.replaceAll(",", "")) ?? PoolSearchSettingsDto.defaultMinLiquidityUSD,
                    ),
                  );
                });
              },
              controller: minTVLController,
              keyboardType: const TextInputType.numberWithOptions(decimal: false),
              inputFormatters: [
                CurrencyTextInputFormatter.simpleCurrency(name: "", enableNegative: false, decimalDigits: 0),
              ],
              decoration: InputDecoration(
                hintText: PoolSearchSettingsDto.defaultMinLiquidityUSD.formatCurrency(isUSD: false),
                hintStyle: TextStyle(color: ZupThemeColors.disabledText.themed(context.brightness)),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: const BorderSide(color: ZupColors.brand, width: 1.5),
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIconColor: ZupColors.gray,
                suffixIcon: const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Text("USD", style: TextStyle(fontWeight: FontWeight.w600)),
                ),
                suffixIconConstraints: const BoxConstraints(maxHeight: 20),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            height: showLowTVLAlert ? 50 : 0,
            alignment: Alignment.bottomCenter,
            width: 198,
            child: showLowTVLAlert
                ? Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Assets.icons.exclamationmarkTriangle.svg(
                        width: 16,
                        height: 16,
                        colorFilter: ColorFilter.mode(ZupThemeColors.alert.themed(context.brightness), BlendMode.srcIn),
                      ),
                      const SizedBox(width: 10),
                      SizedBox(
                        width: 170,
                        child: Text(
                          S.of(context).createPageSettingsDropdownMiniumLiquidityLowWarning,
                          style: TextStyle(color: ZupThemeColors.alert.themed(context.brightness), fontSize: 14),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              sectionTitle(S.of(context).createPageSettingsDropdownAllowedPoolTypes),
              const SizedBox(width: 8),
              ZupTooltip.text(
                key: const Key("pool-types-allowed-tooltip"),
                message: S.of(context).createPageSettingsDropdownAllowedPoolTypesDescription,
                child: Assets.icons.infoCircle.svg(
                  colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                ),
              ),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Text(
                "V4",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 15,
                  color: ZupThemeColors.primaryText.themed(context.brightness),
                ),
              ),
              const SizedBox(width: 5),
              ZupSwitch(
                key: const Key("pool-types-allowed-v4-switch"),
                value: cache.getPoolSearchSettings().allowV4Search,
                onChanged: (value) async {
                  await cache.savePoolSearchSettings(
                    settings: cache.getPoolSearchSettings().copyWith(allowV4Search: value),
                  );

                  setState(() {});
                },
              ),
              const SizedBox(width: 12),
              Text(
                "V3",
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                  color: ZupThemeColors.primaryText.themed(context.brightness),
                ),
              ),
              const SizedBox(width: 5),
              ZupSwitch(
                key: const Key("pool-types-allowed-v3-switch"),
                value: cache.getPoolSearchSettings().allowV3Search,
                onChanged: (value) async {
                  await cache.savePoolSearchSettings(
                    settings: cache.getPoolSearchSettings().copyWith(allowV3Search: value),
                  );

                  setState(() {});
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}
