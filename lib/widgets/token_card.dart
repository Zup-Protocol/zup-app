import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
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
  bool shouldScale = false;

  final zupCachedImage = inject<ZupCachedImage>();

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 100),
      onEnd: () async => setState(() => shouldScale = false),
      scale: shouldScale ? 0.98 : 1,
      child: InkWell(
        onTap: () {
          setState(() => shouldScale = true);

          widget.onClick();
        },
        focusColor: Colors.transparent,
        hoverColor: Colors.transparent,
        splashColor: Colors.transparent,
        highlightColor: Colors.transparent,
        onHover: (value) => setState(() => isHovering = value),
        child: AnimatedContainer(
          padding: const EdgeInsets.all(16),
          duration: const Duration(milliseconds: 100),
          height: 80,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isHovering ? ZupColors.brand : ZupColors.gray5,
              width: isHovering ? 1.5 : 0.5,
            ),
            color: Colors.white,
          ),
          child: Row(
            children: [
              zupCachedImage.build(widget.asset.logoUrl, width: 35, radius: 50),
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
                            color: isHovering ? ZupColors.brand : ZupColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          widget.asset.name,
                          style: const TextStyle(fontSize: 14, color: ZupColors.gray),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
