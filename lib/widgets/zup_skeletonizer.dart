import 'package:flutter/material.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:zup_ui_kit/zup_colors.dart';

class ZupSkeletonizer extends StatelessWidget {
  const ZupSkeletonizer({super.key, required this.child, this.enabled = true});

  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    return Skeletonizer(
      enabled: enabled,
      effect: const SoldColorEffect(color: ZupColors.gray6),
      child: child,
    );
  }
}
