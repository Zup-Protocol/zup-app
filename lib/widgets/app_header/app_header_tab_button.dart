import 'package:flutter/material.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_theme_colors.dart';

class AppHeaderTabButton extends StatefulWidget {
  const AppHeaderTabButton({super.key, required this.title, this.selected = true, this.icon, required this.onPressed});

  final String title;
  final bool selected;
  final Widget? icon;
  final Function()? onPressed;

  @override
  State<AppHeaderTabButton> createState() => _AppHeaderTabButtonState();
}

class _AppHeaderTabButtonState extends State<AppHeaderTabButton> {
  bool isHovering = false;

  TextStyle? get _textStyle {
    if (widget.selected) {
      return TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ZupThemeColors.primaryText.themed(context.brightness),
      );
    }
    if (isHovering) {
      return TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: ZupThemeColors.primaryText.themed(context.brightness),
      );
    }

    return TextStyle(
      fontSize: 15,
      fontWeight: FontWeight.w500,
      color: ZupThemeColors.disabledText.themed(context.brightness),
    );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: widget.onPressed,
      onHover: (value) => setState(() => isHovering = value),
      style: ButtonStyle(
        surfaceTintColor: WidgetStateProperty.all(Colors.red),
        backgroundColor: WidgetStateProperty.all(Colors.transparent),
        overlayColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.hovered)) {
            return ZupThemeColors.hoverOnTertiaryButton.themed(context.brightness);
          }

          return Colors.transparent;
        }),
      ),
      icon: AnimatedContainer(
        width: (widget.selected || isHovering) ? 20 : 0,
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 300),
        child: widget.icon,
      ),
      label: Text(widget.title, style: _textStyle),
    );
  }
}
