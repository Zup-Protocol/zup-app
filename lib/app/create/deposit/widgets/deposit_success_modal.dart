import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class DepositSuccessModal extends StatefulWidget {
  const DepositSuccessModal({super.key, required this.depositedYield, required this.depositedWithNative});

  final YieldDto depositedYield;
  final bool depositedWithNative;

  static Future<void> show(
    BuildContext context, {
    required YieldDto depositedYield,
    required showAsBottomSheet,
    required bool depositedWithNative,
  }) async =>
      ZupModal.show(
        context,
        content: DepositSuccessModal(depositedYield: depositedYield, depositedWithNative: depositedWithNative),
        padding: const EdgeInsets.all(20),
        showAsBottomSheet: showAsBottomSheet,
        dismissible: true,
        size: const Size(370, 420),
      );

  @override
  State<DepositSuccessModal> createState() => _DepositSuccessModalState();
}

class _DepositSuccessModalState extends State<DepositSuccessModal> {
  final zupCachedImage = inject<ZupCachedImage>();
  final confettiController = inject<ConfettiController>(instanceName: InjectInstanceNames.confettiController10s);

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) => confettiController.play());
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ZupMergedWidgets(
              firstWidget: TokenAvatar(
                asset: widget.depositedYield.maybeNativeToken0(permitNative: widget.depositedWithNative),
                size: 70,
              ),
              secondWidget: TokenAvatar(
                asset: widget.depositedYield.maybeNativeToken1(permitNative: widget.depositedWithNative),
                size: 70,
              ),
              spacing: 0,
            ),
            const SizedBox(width: 20),
            Assets.icons.arrowRight.svg(
              colorFilter: const ColorFilter.mode(ZupColors.green, BlendMode.srcIn),
              height: 24,
            ),
            ConfettiWidget(
              confettiController: confettiController,
              shouldLoop: false,
              canvas: const Size(10000, 10000),
              blastDirectionality: BlastDirectionality.explosive,
              numberOfParticles: 50,
              gravity: 0.01,
              emissionFrequency: 0.008,
              minBlastForce: 10,
              particleDrag: 0.03,
            ),
            const SizedBox(width: 20),
            zupCachedImage.build(widget.depositedYield.protocol.logo, radius: 50, height: 70, width: 70),
          ],
        ),
        const SizedBox(height: 30),
        Text(
          S.of(context).depositSuccessModalTitle,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18, color: ZupColors.green),
        ),
        const SizedBox(height: 7),
        SizedBox(
            width: 320,
            child: RichText(
                textAlign: TextAlign.center,
                text: TextSpan(style: const TextStyle(color: ZupColors.gray, fontSize: 14), children: [
                  TextSpan(text: "${S.of(context).depositSuccessModalDescriptionPart1} "),
                  TextSpan(
                    text:
                        "${widget.depositedYield.maybeNativeToken0(permitNative: widget.depositedWithNative).symbol}/${widget.depositedYield.maybeNativeToken1(permitNative: widget.depositedWithNative).symbol}",
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: ZupColors.black,
                    ),
                  ),
                  TextSpan(text: " ${S.of(context).depositSuccessModalDescriptionPart2} "),
                  TextSpan(
                    text: widget.depositedYield.protocol.name,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: ZupColors.black),
                  ),
                  TextSpan(text: " ${S.of(context).depositSuccessModalDescriptionPart3} "),
                  TextSpan(
                    text: widget.depositedYield.network.label,
                    style: const TextStyle(fontWeight: FontWeight.w700, color: ZupColors.black),
                  ),
                ]))),
        const SizedBox(height: 10),
        ZupPrimaryButton(
          key: const Key("view-position-button"),
          title: S.of(context).depositSuccessModalViewPositionOnDEX(dexName: widget.depositedYield.protocol.name),
          onPressed: () => launchUrl(Uri.parse(widget.depositedYield.protocol.url)),
          fontWeight: FontWeight.w500,
          icon: Assets.icons.arrowUpRight.svg(),
          backgroundColor: Colors.transparent,
          foregroundColor: ZupColors.brand,
          hoverElevation: 0,
        ),
        const Spacer(),
        ZupPrimaryButton(
          alignCenter: true,
          key: const Key("close-button"),
          title: S.of(context).close,
          width: double.infinity,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }
}
