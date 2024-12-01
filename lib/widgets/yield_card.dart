import 'package:flutter/material.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/extensions/num_extension.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class YieldCard extends StatefulWidget {
  const YieldCard({
    super.key,
    required this.yield,
    required this.onChangeSelection,
    required this.isSelected,
    required this.timeFrame,
  });

  final YieldDto yield;
  final bool isSelected;
  final Function(YieldDto? yield) onChangeSelection;
  final YieldTimeFrame timeFrame;

  @override
  State<YieldCard> createState() => _YieldCardState();
}

class _YieldCardState extends State<YieldCard> {
  final zupCachedImage = inject<ZupCachedImage>();
  final appCubit = inject<AppCubit>();

  final selectionAnimationDuration = const Duration(milliseconds: 150);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6),
          child: Text(
            S.of(context).yieldCardTimeFrameBest(widget.timeFrame.label(context)),
            style: const TextStyle(color: ZupColors.gray, fontSize: 14, fontWeight: FontWeight.w600),
          ),
        ),
        const SizedBox(height: 5),
        ZupSelectableCard(
          isSelected: widget.isSelected,
          selectionAnimationDuration: selectionAnimationDuration,
          onPressed: () => widget.onChangeSelection(widget.isSelected ? null : widget.yield),
          padding: const EdgeInsets.all(10).copyWith(right: 0, top: 0),
          width: double.maxFinite,
          child: Stack(
            children: [
              if (appCubit.selectedNetwork.isAll)
                Positioned(
                  right: 2,
                  top: 2,
                  child: ZupTooltip(
                    message: S.of(context).yieldCardThisPoolIsAtNetwork(widget.yield.network.label),
                    trailingIcon: widget.yield.network.icon,
                    child: AnimatedContainer(
                      duration: selectionAnimationDuration,
                      height: 40,
                      padding: const EdgeInsets.all(6),
                      width: 40,
                      decoration: BoxDecoration(
                        boxShadow: [
                          BoxShadow(
                            blurStyle: BlurStyle.inner,
                            color: widget.isSelected ? ZupColors.brand5 : ZupColors.gray5,
                            blurRadius: 2,
                            spreadRadius: -2,
                            offset: const Offset(0, 0),
                          ),
                          BoxShadow(
                            color: widget.isSelected ? ZupColors.brand7 : ZupColors.white,
                            blurRadius: 5,
                            spreadRadius: -1,
                            offset: const Offset(2, -2),
                          ),
                        ],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: widget.yield.network.icon,
                    ),
                  ),
                ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      S.of(context).yieldCardYieldYearly,
                      style: const TextStyle(fontSize: 14),
                    ),
                  ),
                  Text(
                    widget.yield.yearlyYield.formatPercent,
                    style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 5),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (widget.yield.protocol.logoUrl.isNotEmpty)
                        zupCachedImage.build(
                          widget.yield.protocol.logoUrl,
                          height: 25,
                          width: 25,
                          radius: 50,
                        ),
                      const SizedBox(width: 5),
                      Text(
                        widget.yield.protocol.name,
                        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ],
                  )
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
