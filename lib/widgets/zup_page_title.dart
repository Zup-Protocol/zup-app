import 'package:flutter/material.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';

class ZupPageTitle extends StatelessWidget with DeviceInfoMixin {
  const ZupPageTitle(this.title, {super.key});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: TextStyle(fontSize: isMobileSize(context) ? 28 : 28, fontWeight: FontWeight.w600),
    );
  }
}
