import 'package:flutter/material.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

class PositionsPage extends StatelessWidget {
  const PositionsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ZupInfoState(
          icon: Assets.icons.plusDiamond.svg(),
          title: "Info State Title",
          description: "Info State Description",
          helpButtonTitle: "Help button",
          onHelpButtonTap: () => ScaffoldMessenger.of(context).showSnackBar(
            ZupSnackBar(
              context,
              message: "Zup Snack Bar message",
            ),
          ),
        ),
      ),
    );
  }
}
