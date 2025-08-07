import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class YieldCard extends StatefulWidget {
  const YieldCard({
    super.key,
    required this.currentYield,
    required this.onChangeSelection,
    required this.isSelected,
    required this.timeFrame,
    this.isHotestYield = false,
  });

  final YieldDto currentYield;
  final bool isSelected;
  final Function(YieldDto? yield) onChangeSelection;
  final YieldTimeFrame timeFrame;
  final bool isHotestYield;

  @override
  State<YieldCard> createState() => _YieldCardState();
}

class _YieldCardState extends State<YieldCard> {
  final zupCachedImage = inject<ZupCachedImage>();
  final appCubit = inject<AppCubit>();
  final infinityAnimationAutoPlay = inject<bool>(instanceName: InjectInstanceNames.infinityAnimationAutoPlay);

  final selectionAnimationDuration = const Duration(milliseconds: 150);

  Widget get yieldText => Text(
    widget.currentYield.yieldTimeframed(widget.timeFrame).formatPercent,
    style: TextStyle(
      fontSize: 26,
      fontWeight: FontWeight.w600,
      color: ZupThemeColors.backgroundInverse.themed(context.brightness),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return ZupSelectableCard(
      isSelected: widget.isSelected,
      selectionAnimationDuration: selectionAnimationDuration,

      onPressed: () {
        return widget.onChangeSelection(widget.isSelected ? null : widget.currentYield);
      },
      padding: const EdgeInsets.all(10).copyWith(right: 2, top: 2, bottom: 0),
      child: Stack(
        children: [
          if (appCubit.selectedNetwork.isAllNetworks)
            Positioned(
              right: 2,
              top: 2,
              child: ZupTooltip.text(
                message: S.of(context).yieldCardThisPoolIsAtNetwork(network: widget.currentYield.network.label),
                trailingIcon: widget.currentYield.network.icon,
                child: Container(
                  height: 40,
                  padding: const EdgeInsets.all(6),
                  width: 40,
                  decoration: BoxDecoration(
                    color: widget.isSelected
                        ? ZupColors.brand.withValues(alpha: 0.1)
                        : (context.brightness.isDark ? ZupColors.black2 : ZupColors.gray6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: widget.currentYield.network.icon,
                ),
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Text(
                  S.of(context).yieldCardYearlyYield,
                  style: TextStyle(fontSize: 14, color: ZupThemeColors.primaryText.themed(context.brightness)),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (widget.isHotestYield) ...[
                    yieldText.animate(
                      effects: [
                        const ScaleEffect(
                          duration: Duration(milliseconds: 200),
                          alignment: Alignment.center,
                          begin: Offset(1.1, 1.1),
                          end: Offset(1, 1),
                        ),
                        ShimmerEffect(
                          duration: const Duration(seconds: 2),
                          color: ZupThemeColors.shimmer.themed(context.brightness),
                          curve: Curves.decelerate,
                          angle: 90,
                          size: 1,
                        ),
                      ],
                      autoPlay: infinityAnimationAutoPlay,
                      onComplete: (controller) => controller.repeat(reverse: true),
                    ),
                  ] else
                    yieldText,
                ],
              ),
              Text(
                "${NumberFormat.compactSimpleCurrency(decimalDigits: 2).format(widget.currentYield.totalValueLockedUSD)} ${S.of(context).tvl}",
                style: const TextStyle(fontSize: 14, height: 1, color: ZupColors.gray),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: widget.isSelected
                          ? (context.brightness.isDark ? ZupColors.brand.withValues(alpha: 0.1) : ZupColors.brand5)
                          : (context.brightness.isDark ? ZupColors.black2 : ZupColors.gray6),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ZupMergedWidgets(
                          firstWidget: TokenAvatar(asset: widget.currentYield.token0, size: 25),
                          secondWidget: TokenAvatar(asset: widget.currentYield.token1, size: 25),
                          spacing: 0,
                        ),
                        const SizedBox(width: 10),
                        Text(
                          "${widget.currentYield.token0.symbol}/${widget.currentYield.token1.symbol}",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: ZupThemeColors.primaryText.themed(context.brightness),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(">", style: TextStyle(color: ZupColors.gray)),
                  const SizedBox(width: 10),
                  if (widget.currentYield.protocol.logo.isNotEmpty)
                    zupCachedImage.build(
                      context,
                      widget.currentYield.protocol.logo,
                      height: 25,
                      width: 25,
                      radius: 50,
                      errorWidget: (context, error, stackTrace) {
                        return Container(
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(color: ZupColors.gray6, borderRadius: BorderRadius.circular(50)),
                        );
                      },
                    ),
                  const SizedBox(width: 5),
                  Flexible(
                    child: ZupTooltip.text(
                      message: "",
                      helperButtonTitle: S
                          .of(context)
                          .yieldCardVisitProtocol(protocolName: widget.currentYield.protocol.name),
                      helperButtonOnPressed: () => launchUrl(Uri.parse(widget.currentYield.protocol.url)),
                      child: Text(
                        widget.currentYield.protocol.name,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: ZupThemeColors.backgroundInverse.themed(context.brightness),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
