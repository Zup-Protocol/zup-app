import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_core/zup_core.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class DepositSettingsDropdownChild extends StatefulWidget {
  const DepositSettingsDropdownChild(
    this.context, {
    super.key,
    required this.selectedSlippage,
    required this.selectedDeadline,
    required this.onSettingsChanged,
  });

  final BuildContext context;
  final Slippage selectedSlippage;
  final Duration selectedDeadline;
  final void Function(Slippage slippage, Duration deadline) onSettingsChanged;

  @override
  State<DepositSettingsDropdownChild> createState() => _DepositSettingsDropdownChildState();
}

class _DepositSettingsDropdownChildState extends State<DepositSettingsDropdownChild> {
  final TextEditingController slippageTextController = TextEditingController();
  final TextEditingController deadlineTextController = TextEditingController();

  late Slippage selectedSlippage = widget.selectedSlippage;
  late Duration deadline = widget.selectedDeadline;

  void changeSlippage(Slippage newSlippage) {
    setState(() => selectedSlippage = newSlippage);
    if (!newSlippage.isCustom) slippageTextController.clear();

    widget.onSettingsChanged(newSlippage, deadline);
  }

  void changeDeadline(Duration newDeadline) {
    setState(() => deadline = newDeadline);

    widget.onSettingsChanged(selectedSlippage, newDeadline);
  }

  @override
  void initState() {
    if (widget.selectedSlippage.isCustom) slippageTextController.text = widget.selectedSlippage.value.toString();
    deadlineTextController.text = deadline.inMinutes.toString();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: ZupThemeColors.background.themed(context.brightness),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ZupThemeColors.borderOnBackground.themed(context.brightness), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ZupTooltip.text(
              key: const Key("slippage-tooltip"),
              message: S.of(context).slippageExplanation,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IgnorePointer(
                    child: Text(
                      S.of(context).depositSettingsDropdownChildMaxSlippage,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Assets.icons.infoCircle.svg(
                    width: 16,
                    height: 16,
                    colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                CupertinoSlidingSegmentedControl(
                  groupValue: selectedSlippage.isCustom ? null : selectedSlippage,
                  children: {
                    Slippage.zeroPointOnePercent: const MouseRegion(
                      key: Key("zero-point-one-percent-slippage"),
                      cursor: SystemMouseCursors.click,
                      child: IgnorePointer(
                        child: Text("0.1%", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Slippage.halfPercent: const MouseRegion(
                      key: Key("zero-point-five-percent-slippage"),
                      cursor: SystemMouseCursors.click,
                      child: IgnorePointer(
                        child: Text("0.5%", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                    Slippage.onePercent: const MouseRegion(
                      key: Key("one-percent-slippage"),
                      cursor: SystemMouseCursors.click,
                      child: IgnorePointer(
                        child: Text("1%", style: TextStyle(fontWeight: FontWeight.w600)),
                      ),
                    ),
                  },
                  onValueChanged: (slippage) => changeSlippage(slippage ?? widget.selectedSlippage),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: SizedBox(
                    height: 34,
                    child: Focus(
                      onFocusChange: (hasFocus) {
                        if (!hasFocus) {
                          final value = double.tryParse(slippageTextController.text) ?? widget.selectedSlippage.value;

                          if (value > 50) {
                            slippageTextController.text = "50";

                            return changeSlippage(Slippage.custom(50));
                          }

                          changeSlippage(value > 0 ? Slippage.custom(value) : widget.selectedSlippage);
                        }
                      },
                      child: TextField(
                        key: const Key("slippage-text-field"),
                        maxLength: 5,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        inputFormatters: [FilteringTextInputFormatter.allow(ZupRegex.decimalNumbers)],
                        controller: slippageTextController,
                        onChanged: (_) => setState(() {}),
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        decoration: InputDecoration(
                          counterText: "",
                          error: (double.tryParse(slippageTextController.text) ?? 0) > 50
                              ? const SizedBox.shrink()
                              : null,
                          hintText: "0.1",
                          hintStyle: TextStyle(color: ZupThemeColors.disabledText.themed(context.brightness)),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
                          ),
                          suffixIcon: const Padding(
                            padding: EdgeInsets.only(right: 12),
                            child: Text(
                              "%",
                              style: TextStyle(color: ZupColors.gray, fontWeight: FontWeight.w300, fontSize: 14),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            AnimatedContainer(
              duration: Durations.medium2,
              height: (double.tryParse(slippageTextController.text) ?? 0) > 1 ? 60 : 0,
              width: 280,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Assets.icons.exclamationmarkTriangle.svg(
                    colorFilter: ColorFilter.mode(ZupThemeColors.alert.themed(context.brightness), BlendMode.srcIn),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: S.of(context).depositSettingsDropdownChildHighSlippageWarningText),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              key: const Key("whats-this-question-link"),
                              onTap: () async {
                                final uri = Uri.parse(
                                  "https://www.cyfrin.io/blog/what-is-blockchain-and-crypto-front-running",
                                );

                                if (await canLaunchUrl(uri)) await launchUrl(uri);
                              },
                              child: MouseRegion(
                                cursor: SystemMouseCursors.click,
                                child: IgnorePointer(
                                  child: Text(
                                    S.of(context).whatsThisQuestionText,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: ZupThemeColors.alert.themed(context.brightness),
                                      fontWeight: FontWeight.bold,
                                      decoration: TextDecoration.underline,
                                      decorationColor: ZupThemeColors.alert.themed(context.brightness),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      style: TextStyle(color: ZupThemeColors.alert.themed(context.brightness), fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
            const ZupDivider(),
            const SizedBox(height: 10),
            Row(
              children: [
                ZupTooltip.text(
                  message: S.of(context).depositSettingsDropdownChildTransactionDeadlineExplanation,
                  key: const Key("deadline-tooltip"),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IgnorePointer(
                        child: Text(
                          S.of(context).depositSettingsDropdownTransactionDeadline,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Assets.icons.infoCircle.svg(
                        width: 16,
                        height: 16,
                        colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Focus(
                    onFocusChange: (hasFocus) {
                      if (!hasFocus) {
                        final value = int.tryParse(deadlineTextController.text) ?? widget.selectedDeadline.inMinutes;

                        if (value > 1200) {
                          deadlineTextController.text = "1200";
                          return changeDeadline(const Duration(minutes: 1200));
                        }

                        changeDeadline(value > 0 ? Duration(minutes: value) : widget.selectedDeadline);
                      }
                    },
                    child: SizedBox(
                      height: 40,
                      child: TextField(
                        key: const Key("deadline-textfield"),
                        keyboardType: TextInputType.number,
                        maxLength: 4,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                        controller: deadlineTextController,
                        onChanged: (value) => setState(() {}),
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          hintText: "10",
                          hintStyle: TextStyle(color: ZupThemeColors.disabledText.themed(context.brightness)),
                          contentPadding: EdgeInsets.zero,
                          counterText: "",
                          error: (int.tryParse(deadlineTextController.text) ?? 0) > 1200
                              ? const SizedBox.shrink()
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: ZupThemeColors.borderOnBackground.themed(context.brightness)),
                          ),
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 12),
                            child: Text(
                              S.of(context).minutes,
                              style: const TextStyle(color: ZupColors.gray, fontWeight: FontWeight.w400, fontSize: 14),
                            ),
                          ),
                          suffixIconConstraints: const BoxConstraints(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
