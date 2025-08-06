import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TokenCard extends StatefulWidget {
  const TokenCard({super.key, required this.asset, required this.onClick});

  final TokenDto asset;
  final Function() onClick;

  @override
  State<TokenCard> createState() => _TokenCardState();
}

class _TokenCardState extends State<TokenCard> {
  bool isHovering = false;

  final zupCachedImage = inject<ZupCachedImage>();

  @override
  Widget build(BuildContext context) {
    return ZupSelectableCard(
      onPressed: () {
        widget.onClick();
      },
      onHoverChanged: (value) {
        setState(() => isHovering = value);
      },
      child: Row(
        children: [
          TokenAvatar(asset: widget.asset, size: 35),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  children: [
                    Text(
                      widget.asset.symbol,
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                        color: isHovering ? ZupColors.brand : ZupThemeColors.primaryText.themed(context.brightness),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [Text(widget.asset.name, style: const TextStyle(fontSize: 14, color: ZupColors.gray))],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
