import 'package:flutter/material.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/token_group_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/widgets/token_avatar.dart';
import 'package:zup_app/widgets/token_selector_button/token_selector_button_controller.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class TokenSelectorButton extends StatefulWidget {
  const TokenSelectorButton({super.key, required this.controller});

  final TokenSelectorButtonController controller;

  @override
  State<TokenSelectorButton> createState() => _TokenSelectorButtonState();
}

class _TokenSelectorButtonState extends State<TokenSelectorButton> with DeviceInfoMixin {
  final zupCachedImage = inject<ZupCachedImage>();
  TokenDto? get selectedToken => widget.controller.selectedToken;
  TokenGroupDto? get selectedGroup => widget.controller.selectedTokenGroup;

  bool get hasSelection => widget.controller.hasSelection;

  bool isHovering = false;

  Color get getTextColor {
    if (isHovering || !hasSelection) return ZupColors.brand;
    return ZupColors.black;
  }

  Color get getChevronColor {
    if (isHovering || selectedToken == null) return ZupColors.brand;
    return ZupColors.gray;
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: widget.controller.selectionStream,
      builder: (context, _) {
        return ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: MouseRegion(
            onEnter: (event) => setState(() => isHovering = true),
            onExit: (event) => setState(() => isHovering = false),
            child: MaterialButton(
              color: hasSelection ? ZupColors.gray6.withValues(alpha: 0.6) : ZupColors.brand6,
              hoverColor: hasSelection ? ZupColors.gray6 : ZupColors.gray6.withValues(alpha: 0.2),
              splashColor: hasSelection
                  ? ZupColors.gray5.withValues(alpha: 0.4)
                  : ZupColors.brand5.withValues(alpha: 0.5),
              focusElevation: 0,
              highlightElevation: 0,
              elevation: 0,
              hoverElevation: 0,
              height: 100,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.all(30),
              onPressed: () => TokenSelectorModal.show(
                context,
                showAsBottomSheet: isMobileSize(context),
                onSelectTokenGroup: (group) {
                  widget.controller.changeTokenGroup(group);
                },
                onSelectToken: (token) {
                  widget.controller.changeToken(token);
                },
              ),
              child: Row(
                children: [
                  if (!hasSelection)
                    Assets.icons.boltCircleFill.svg(
                      height: 16,
                      colorFilter: const ColorFilter.mode(ZupColors.brand, BlendMode.srcIn),
                    )
                  else ...[
                    if (selectedToken != null) TokenAvatar(asset: selectedToken!, size: 30),
                    if (selectedGroup != null)
                      zupCachedImage.build(
                        selectedGroup!.logoUrl,
                        height: 30,
                        width: 30,
                        radius: 50,
                        errorWidget: (_, __, ___) => const Text("data"),
                      ),
                  ],
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      () {
                        if (selectedToken != null) return "${selectedToken?.name} (${selectedToken?.symbol})";
                        if (selectedGroup != null) return "${selectedGroup?.name}";

                        return S.of(context).selectToken;
                      }(),
                      style: TextStyle(
                        fontSize: 17,
                        color: getTextColor,
                        fontWeight: !hasSelection ? FontWeight.w500 : null,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
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
      },
    );
  }
}
