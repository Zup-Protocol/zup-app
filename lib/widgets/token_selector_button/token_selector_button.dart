import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TokenSelectorButton extends StatefulWidget {
  const TokenSelectorButton({super.key, required this.controller});

  final TokenSelectorButtonController controller;

  @override
  State<TokenSelectorButton> createState() => _TokenSelectorButtonState();
}

class _TokenSelectorButtonState extends State<TokenSelectorButton> {
  final zupCachedImage = inject<ZupCachedImage>();
  TokenDto? get selectedToken => widget.controller.selectedToken;

  bool isHovering = false;

  Color get getTextColor {
    if (isHovering || selectedToken == null) return ZupColors.brand;
    return ZupColors.black;
  }

  Color get getChevronColor {
    if (isHovering || selectedToken == null) return ZupColors.brand;
    return ZupColors.gray;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: widget.controller.selectedTokenStream,
        builder: (context, _) {
          return ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: MouseRegion(
              onEnter: (event) => setState(() => isHovering = true),
              onExit: (event) => setState(() => isHovering = false),
              child: MaterialButton(
                color: selectedToken != null ? ZupColors.gray6.withOpacity(0.6) : ZupColors.brand6,
                hoverColor: selectedToken != null ? ZupColors.gray6 : ZupColors.gray6.withOpacity(0.2),
                splashColor:
                    selectedToken != null ? ZupColors.gray5.withOpacity(0.4) : ZupColors.brand5.withOpacity(0.5),
                focusElevation: 0,
                highlightElevation: 0,
                elevation: 0,
                hoverElevation: 0,
                height: 100,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.all(30),
                onPressed: () => TokenSelectorModal.show(context, onSelectToken: (token) {
                  widget.controller.changeToken(token);
                }),
                child: Row(
                  children: [
                    if (selectedToken == null)
                      Assets.icons.boltCircleFill.svg(
                        height: 16,
                        colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                      )
                    else
                      zupCachedImage.build(
                        radius: 50,
                        width: 30,
                        selectedToken!.logoUrl,
                      ),
                    const SizedBox(width: 10),
                    Text.rich(
                      TextSpan(
                        style: TextStyle(
                          fontSize: 17,
                          color: getTextColor,
                          fontWeight: selectedToken == null ? FontWeight.w500 : null,
                        ),
                        children: [
                          TextSpan(text: selectedToken?.name ?? S.of(context).selectToken),
                          TextSpan(text: selectedToken?.symbol != null ? " (${selectedToken!.symbol})" : null),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Spacer(),
                    AnimatedRotation(
                      duration: const Duration(milliseconds: 500),
                      curve: Curves.easeOutBack,
                      turns: isHovering ? 0.5 : 0,
                      child: Assets.icons.chevronDown.svg(
                        colorFilter: ColorFilter.mode(getChevronColor, BlendMode.srcIn),
                        height: 8,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
