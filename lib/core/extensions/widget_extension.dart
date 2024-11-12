import 'package:flutter/material.dart';
import 'package:zup_app/widgets/zup_skeletonizer.dart';

extension WidgetExtension on Widget {
  Widget redacted({bool enabled = true}) => ZupSkeletonizer(enabled: enabled, child: this);
}
