import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/yield_timeframe.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class YieldCard extends StatefulWidget {
  const YieldCard({super.key, required this.yieldPool, required this.yieldTimeFrame, required this.isHotestYield});

  final YieldDto yieldPool;
  final bool isHotestYield;
  final YieldTimeFrame yieldTimeFrame;

  @override
  State<YieldCard> createState() => _YieldCardState();
}

class _YieldCardState extends State<YieldCard> with DeviceInfoMixin {
  final zupCachedImage = inject<ZupCachedImage>();
  final infinityAnimationAutoPlay = inject<bool>(instanceName: InjectInstanceNames.infinityAnimationAutoPlay);

  List<YieldTimeFrame> get timeframesExcludingCurrent {
    return YieldTimeFrame.values.where((timeframe) => timeframe != widget.yieldTimeFrame).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsetsGeometry.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        color: context.brightness.isDark ? ZupColors.black3.withValues(alpha: 0.3) : ZupColors.white,
        border: context.brightness.isDark
            ? null
            : Border.all(width: 0.5, color: ZupThemeColors.borderOnBackgroundSurface.themed(context.brightness)),
      ),
      child: Column(
        children: [
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 6),
              constraints: isMobileSize(context) ? null : const BoxConstraints(maxWidth: 300),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: ZupThemeColors.background.themed(context.brightness),
                border: context.brightness.isLight
                    ? Border.all(width: 0.5, color: ZupThemeColors.borderOnBackground.themed(context.brightness))
                    : null,
              ),
              child: Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ZupMergedWidgets(
                            spacing: 1,
                            firstWidget: TokenAvatar(asset: widget.yieldPool.token0, size: 30),
                            secondWidget: TokenAvatar(asset: widget.yieldPool.token1, size: 30),
                          ),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              "${widget.yieldPool.token0.symbol.clampMax(8, showEllipsis: true)}/${widget.yieldPool.token1.symbol.clampMax(8, showEllipsis: true)}",
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15, color: ZupColors.gray),
                            ),
                          ),
                          const SizedBox(width: 30),
                        ],
                      ),
                    ),

                    Align(
                      alignment: Alignment.centerRight,
                      child: ZupTooltip.text(
                        key: Key("yield-card-network-${widget.yieldPool.network.label}"),
                        message: S.of(context).yieldCardThisPoolIsAtNetwork(network: widget.yieldPool.network.label),
                        trailingIcon: widget.yieldPool.network.icon(context.brightness),
                        child: SizedBox(
                          height: 30,
                          width: 30,
                          child: widget.yieldPool.network.icon(context.brightness),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 25),
          SizedBox(
            height: 70,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(width: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(S.of(context).yieldCardYearlyYield),
                    if (widget.isHotestYield) ...[
                      yieldPercentText.animate(
                        autoPlay: infinityAnimationAutoPlay,
                        onComplete: (controller) => controller.repeat(reverse: true),
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
                      ),
                    ] else ...[
                      yieldPercentText,
                    ],
                  ],
                ),
                const SizedBox(width: 5),
                Align(
                  alignment: const Alignment(0, 0.3),
                  child: ZupTooltip.widget(
                    key: Key("yield-breakdown-tooltip-${widget.yieldPool.poolAddress}"),
                    tooltipChild: yieldBreakdownTooltipChild,
                    child: Assets.icons.infoCircle.svg(
                      width: 14,
                      height: 14,
                      colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Center(
            child: Text(
              "${NumberFormat.compactSimpleCurrency(decimalDigits: 2).format(widget.yieldPool.totalValueLockedUSD)} ${S.of(context).tvl}",
              style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15, color: ZupColors.gray),
            ),
          ),

          const SizedBox(height: 25),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              zupCachedImage.build(
                context,
                widget.yieldPool.protocol.logo,
                radius: 20,
                height: 25,
                width: 25,
                backgroundColor: ZupColors.white,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  widget.yieldPool.protocol.name,
                  style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            constraints: isMobileSize(context) ? null : const BoxConstraints(maxWidth: 300),
            child: ZupPrimaryButton(
              icon: Assets.icons.arrowRight.svg(),
              title: S.of(context).yieldCardDeposit,
              fixedIcon: true,
              isTrailingIcon: true,
              onPressed: (context) {},
              hoverElevation: 0,
              width: double.infinity,
              height: 45,
              alignCenter: true,
              foregroundColor: ZupColors.brand,
              splashColor: context.brightness.isDark ? ZupColors.brand.withValues(alpha: 0.1) : ZupColors.brand5,
              hoverColor: context.brightness.isDark ? ZupColors.brand.withValues(alpha: 0.1) : ZupColors.brand6,
              backgroundColor: context.brightness.isDark ? ZupColors.brand.withValues(alpha: 0.1) : ZupColors.brand7,
            ),
          ),
        ],
      ),
    );
  }

  Widget get yieldPercentText {
    final text = Text(
      widget.yieldPool.timeframedYieldFormatted(widget.yieldTimeFrame),
      key: Key("yield-card-yield-${widget.yieldPool.poolAddress}"),
      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 32),
    );

    if (isMobileDevice) return ZupTooltip.widget(tooltipChild: yieldBreakdownTooltipChild, child: text);

    return text;
  }

  Widget get yieldBreakdownTooltipChild => SizedBox(
    width: 200,
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(S.of(context).yieldCardYieldExplanation, style: const TextStyle(color: ZupColors.gray, fontSize: 14)),
          const SizedBox(height: 16),

          ...timeframesExcludingCurrent.mapIndexed(
            (index, yieldTimeFrame) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      S.of(context).yieldCardTimeframeYield(timeframe: yieldTimeFrame.compactDaysLabel(context)),
                      style: TextStyle(
                        color: ZupThemeColors.primaryText.themed(context.brightness),
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      widget.yieldPool.timeframedYieldFormatted(yieldTimeFrame),
                      style: const TextStyle(color: ZupColors.gray, fontSize: 15),
                    ),
                  ],
                ),
                if (index < timeframesExcludingCurrent.length - 1) ...[
                  ZupDivider(color: ZupThemeColors.borderOnBackgroundSurface.themed(context.brightness)),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
