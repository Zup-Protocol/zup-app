import 'package:flutter/material.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

enum PositionStatus { inRange, outOfRange, closed, unknown }

extension PositionStatusExtension on PositionStatus {
  bool get isClosed => this == PositionStatus.closed;

  String label(BuildContext context) => [
        S.of(context).positionStatusInRange,
        S.of(context).positionStatusOutOfRange,
        S.of(context).positionStatusClosed,
        S.of(context).unknown
      ][index];

  Color get color => [
        ZupColors.green,
        ZupColors.red,
        ZupColors.gray,
        ZupColors.gray,
      ][index];

  Widget get icon => [
        Assets.icons.rectangleConnectedToLineBelow.svg(),
        Assets.icons.squareAndLineVerticalAndSquareFilled.svg(),
        Assets.icons.slashCircle.svg(),
        Assets.icons.questionmark.svg(),
      ][index];
}
