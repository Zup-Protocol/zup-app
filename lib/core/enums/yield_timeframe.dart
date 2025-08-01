import 'package:flutter/material.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';

enum YieldTimeFrame { day, week, month, threeMonth }

extension YieldTimeFrameExtension on YieldTimeFrame {
  bool get isDay => this == YieldTimeFrame.day;
  bool get isWeek => this == YieldTimeFrame.week;
  bool get isMonth => this == YieldTimeFrame.month;
  bool get isThreeMonth => this == YieldTimeFrame.threeMonth;

  String label(BuildContext context) {
    return switch (this) {
      YieldTimeFrame.day => S.of(context).twentyFourHours,
      YieldTimeFrame.week => S.of(context).week,
      YieldTimeFrame.month => S.of(context).month,
      YieldTimeFrame.threeMonth => S.of(context).threeMonths,
    };
  }

  String compactDaysLabel(BuildContext context) => switch (this) {
    YieldTimeFrame.day => S.of(context).twentyFourHoursCompact,
    YieldTimeFrame.week => S.of(context).weekCompact,
    YieldTimeFrame.month => S.of(context).monthCompact,
    YieldTimeFrame.threeMonth => S.of(context).threeMonthsCompact,
  };
}
