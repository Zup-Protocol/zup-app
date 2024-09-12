import 'package:flutter/material.dart';
import 'package:zup_app/theme/zup_colors.dart';

class ZupHeaderTabButton extends StatefulWidget {
  const ZupHeaderTabButton({
    super.key,
    required this.title,
    this.selected = true,
    this.icon,
    required this.onPressed,
  });

  final String title;
  final bool selected;
  final Widget? icon;
  final Function() onPressed;

  @override
  State<ZupHeaderTabButton> createState() => _ZupHeaderTabButtonState();
}

class _ZupHeaderTabButtonState extends State<ZupHeaderTabButton> {
  bool isHovering = false;

  TextStyle? get _textStyle {
    if (widget.selected) return Theme.of(context).textTheme.titleSmall;
    if (isHovering) return Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500);

    return Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.w500,
          color: ZupColors.gray5,
        );
  }

  @override
  Widget build(BuildContext context) {
    return TextButton.icon(
      onPressed: widget.onPressed,
      onHover: (value) => setState(() => isHovering = value),
      icon: AnimatedContainer(
        width: (widget.selected || isHovering) ? 20 : 0,
        curve: Curves.decelerate,
        duration: const Duration(milliseconds: 300),
        child: widget.icon,
      ),
      label: Text(
        widget.title,
        style: _textStyle,
      ),
    );
  }
}
