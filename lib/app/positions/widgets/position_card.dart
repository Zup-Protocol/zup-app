import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:zup_app/app/positions/widgets/position_token.dart';
import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class PositionCard extends StatefulWidget {
  const PositionCard({super.key, required this.position});

  final PositionDto position;

  @override
  State<PositionCard> createState() => _PositionCardState();
}

class _PositionCardState extends State<PositionCard> {
  bool isHovering = false;
  bool shouldScale = false;

  final ZupCachedImage zupCachedImage = inject<ZupCachedImage>();

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 100),
      onEnd: () async => setState(() => shouldScale = false),
      scale: shouldScale ? 0.98 : 1,
      child: InkWell(
        key: const Key("position-card"),
        onTap: () async {
          setState(() => shouldScale = true);

          Future.delayed(const Duration(milliseconds: 200), () async {
            final protocolUri = Uri.tryParse(widget.position.protocol?.url ?? "");
            if (protocolUri == null) return;

            if (await canLaunchUrl(protocolUri)) launchUrl(protocolUri, mode: LaunchMode.platformDefault);
          });
        },
        splashFactory: NoSplash.splashFactory,
        hoverColor: Colors.transparent,
        highlightColor: Colors.transparent,
        focusColor: Colors.transparent,
        splashColor: Colors.transparent,
        onHover: (value) => setState(() => isHovering = value),
        child: AnimatedContainer(
          height: 133,
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.all(Radius.circular(12)),
            color: ZupColors.white,
            boxShadow: [
              BoxShadow(
                blurRadius: 8,
                color: isHovering ? ZupColors.brand5 : ZupColors.gray6,
                spreadRadius: 0.1,
                offset: const Offset(7, 5),
              ),
            ],
            border: Border.all(
              strokeAlign: 1,
              color: isHovering ? ZupColors.brand : ZupColors.gray5,
              width: isHovering ? 1.5 : 0.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      PositionToken(
                          tokenSymbol: widget.position.token0?.symbol ?? "",
                          tokenUrl: widget.position.token0?.logoUrl ?? ""),
                      const SizedBox(width: 15),
                      PositionToken(
                          tokenSymbol: widget.position.token1?.symbol ?? "",
                          tokenUrl: widget.position.token1?.logoUrl ?? ""),
                      const SizedBox(width: 20),
                      if (widget.position.network != null) ...[
                        Skeleton.ignore(
                          child: ZupTag(
                            title: widget.position.network!.label,
                            color: ZupColors.gray,
                            icon: widget.position.network?.icon,
                            iconSize: 22,
                            iconSpacing: 5,
                          ),
                        ),
                        const SizedBox(width: 10),
                      ],
                      Skeleton.leaf(
                        child: ZupTag(
                          title: widget.position.status.label(context),
                          color: widget.position.status.color,
                          icon: widget.position.status.icon,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(text: S.of(context).positionCardMin, style: const TextStyle(color: ZupColors.gray)),
                        TextSpan(
                            text: S.of(context).positionCardTokenPerToken(
                                  widget.position.minRange,
                                  widget.position.token0?.symbol ?? "",
                                  widget.position.token1?.symbol ?? "",
                                ),
                            style: const TextStyle(color: ZupColors.black)),
                        WidgetSpan(
                          alignment: PlaceholderAlignment.middle,
                          child: Skeleton.ignore(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              child: Assets.icons.arrow2Squarepath.svg(
                                height: 12,
                                colorFilter: const ColorFilter.mode(ZupColors.black, BlendMode.srcIn),
                              ),
                            ),
                          ),
                        ),
                        TextSpan(text: S.of(context).positionCardMax, style: const TextStyle(color: ZupColors.gray)),
                        TextSpan(
                            text: S.of(context).positionCardTokenPerToken(
                                  widget.position.maxRange,
                                  widget.position.token0?.symbol ?? "",
                                  widget.position.token1?.symbol ?? "",
                                ),
                            style: const TextStyle(color: ZupColors.black)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text.rich(
                    TextSpan(
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      children: [
                        TextSpan(
                          text: S.of(context).positionCardLiquidity,
                          style: const TextStyle(color: ZupColors.gray),
                        ),
                        TextSpan(
                          text: "\$${widget.position.liquidity}",
                          style: const TextStyle(color: ZupColors.black),
                        ),
                        const WidgetSpan(child: SizedBox(width: 20)),
                        TextSpan(
                          text: S.of(context).positionCardUnclaimedFees,
                          style: const TextStyle(color: ZupColors.gray),
                        ),
                        TextSpan(
                          text: "\$${widget.position.unclaimedFees}",
                          style: const TextStyle(color: ZupColors.black),
                        ),
                      ],
                    ),
                  )
                ],
              ),
              const Spacer(),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Row(
                    children: [
                      zupCachedImage.build(widget.position.protocol?.logoUrl ?? "", height: 22, width: 22, radius: 50),
                      const SizedBox(width: 10),
                      Text(
                        widget.position.protocol?.name ?? "",
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: ZupColors.gray,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Text(
                        S.of(context).positionCardViewMore,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: isHovering ? ZupColors.brand : ZupColors.gray,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Skeleton.shade(
                        child: Assets.icons.arrowUpRight.svg(
                          height: 10,
                          colorFilter: ColorFilter.mode(isHovering ? ZupColors.brand : ZupColors.gray, BlendMode.srcIn),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
