import 'package:flutter/material.dart';
import 'package:zup_core/extensions/extensions.dart';
import 'package:zup_core/mixins/device_info_mixin.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class ZupPageTitle extends StatefulWidget {
  const ZupPageTitle(this.title, {super.key});

  final String title;

  @override
  State<ZupPageTitle> createState() => _ZupPageTitleState();
}

class _ZupPageTitleState extends State<ZupPageTitle> with DeviceInfoMixin {
  @override
  Widget build(BuildContext context) {
    return Text(
      widget.title,
      style: TextStyle(
        fontSize: isMobileSize(context) ? 28 : 28,
        fontWeight: FontWeight.w600,
        color: ZupThemeColors.primaryText.themed(context.brightness),
      ),
    );
  }
}
