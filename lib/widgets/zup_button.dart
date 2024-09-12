import 'package:flutter/material.dart';
import 'package:zup_app/theme/zup_colors.dart';

class ZupButton extends StatefulWidget {
  const ZupButton({super.key, required this.title, this.icon, required this.onPressed});

  final String title;
  final Widget? icon;
  final Function() onPressed;

  @override
  State<ZupButton> createState() => _ZupButtonState();
}

class _ZupButtonState extends State<ZupButton> {
  bool isHovering = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) {
        if (isHovering) return;

        setState(() => isHovering = true);
      },
      onExit: (_) {
        if (!isHovering) return;

        setState(() => isHovering = false);
      },
      child: MaterialButton(
        color: ZupColors.brand,
        animationDuration: const Duration(milliseconds: 800),
        padding: const EdgeInsets.all(20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        height: 50,
        onPressed: widget.onPressed,
        hoverElevation: 14,
        elevation: 0,
        child: Row(
          children: [
            if (widget.icon != null) ...[
              AnimatedPadding(
                duration: Duration(milliseconds: isHovering ? 0 : 400),
                curve: Curves.decelerate,
                padding: EdgeInsets.only(right: isHovering ? 10 : 0),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 400),
                  curve: Curves.fastEaseInToSlowEaseOut,
                  width: isHovering ? 20 : 0,
                  child: ColorFiltered(
                    colorFilter: const ColorFilter.mode(ZupColors.white, BlendMode.srcIn),
                    child: widget.icon,
                  ),
                ),
              ),
            ],
            Text(
              widget.title,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: ZupColors.white,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}
