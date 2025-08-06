import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_ui_kit/zup_colors.dart';

class ZupSkeletonizer extends StatefulWidget {
  const ZupSkeletonizer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  final darkModeEffect = const SoldColorEffect(color: ZupColors.black4);
  final lightMode = const SoldColorEffect(color: ZupColors.gray6);

  Widget sliver(BuildContext context) {
    return SliverSkeletonizer(
      effect: context.brightness.isDark ? darkModeEffect : lightMode,
      enabled: enabled,
      child: child,
    );
  }

  @override
  State<ZupSkeletonizer> createState() => _ZupSkeletonizerState();
}

class _ZupSkeletonizerState extends State<ZupSkeletonizer> {
  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: widget.enabled,
      effect: context.brightness.isDark ? widget.darkModeEffect : widget.lightMode,
      child: widget.child,
    );
  }
}
