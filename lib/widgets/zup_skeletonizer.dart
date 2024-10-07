import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zup_ui_kit/zup_colors.dart';

class ZupSkeletonizer extends StatelessWidget {
  const ZupSkeletonizer({super.key, required this.child, this.enabled = true});

  final effect = const SoldColorEffect(color: ZupColors.gray6);

  Widget sliver() => SliverSkeletonizer(
        effect: effect,
        enabled: enabled,
        child: child,
      );

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: effect,
      child: child,
    );
  }
}
