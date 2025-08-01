import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_circular_loading_indicator.dart';
import 'package:zup_ui_kit/zup_colors.dart';
import 'package:zup_ui_kit/zup_selectable_card.dart';
import 'package:zup_ui_kit/zup_tooltip.dart';

class TokenGroupCard extends StatefulWidget {
  const TokenGroupCard({super.key, required this.group, required this.onClick});

  final TokenGroupDto group;
  final Function() onClick;

  @override
  State<TokenGroupCard> createState() => _TokenGroupCardState();
}

class _TokenGroupCardState extends State<TokenGroupCard> {
  final ZupCachedImage zupCachedImage = inject<ZupCachedImage>();
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return ZupSelectableCard(
      onPressed: () => widget.onClick(),
      onHoverChanged: (value) => setState(() => isHovering = value),
      boxShadow: const [],
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          zupCachedImage.build(
            widget.group.logoUrl,
            height: 35,
            width: 35,
            radius: 35,
            errorWidget: (_, __, ___) => Container(
              height: 35,
              width: 35,
              color: ZupColors.gray6,
              child: const Center(
                child: Text("?", style: TextStyle(color: ZupColors.gray, fontSize: 16)),
              ),
            ),
            placeholder: const Skeleton.ignore(
              child: ZupCircularLoadingIndicator(
                size: 50,
                backgroundColor: ZupColors.brand5,
                indicatorColor: ZupColors.brand,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            widget.group.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isHovering ? ZupColors.brand : ZupColors.gray,
            ),
          ),
          const Spacer(),
          ZupTooltip.widget(
            tooltipChild: ScrollbarTheme(
              data: ScrollbarThemeData(
                thumbVisibility: WidgetStateProperty.all(true),
                thickness: WidgetStateProperty.all(4.0),
                thumbColor: WidgetStateProperty.all(ZupColors.gray5),
                trackColor: WidgetStateProperty.all(ZupColors.gray5),
                mainAxisMargin: 10,
              ),
              child: GridView.builder(
                padding: const EdgeInsets.all(8),
                gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                  maxCrossAxisExtent: 100,
                  mainAxisExtent: 40,
                ),
                itemBuilder: (_, index) => Padding(
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      border: Border.all(color: ZupColors.gray5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      spacing: 10,
                      children: [
                        TokenAvatar(asset: widget.group.tokens[index], size: 20),
                        Expanded(
                          child: Text(
                            overflow: TextOverflow.ellipsis,
                            widget.group.tokens[index].symbol,
                            style: const TextStyle(color: ZupColors.gray),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                shrinkWrap: true,
                itemCount: widget.group.tokens.length,
              ),
            ),
            constraints: const BoxConstraints(maxHeight: 300, maxWidth: 200),
            child: Assets.icons.infoCircle.svg(
              colorFilter: const ColorFilter.mode(ZupColors.gray, BlendMode.srcIn),
              height: 15,
              width: 15,
            ),
          ),
        ],
      ),
    );
  }
}
