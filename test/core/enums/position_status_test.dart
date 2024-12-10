import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:zup_app/core/enums/position_status.dart';
import 'package:zup_ui_kit/zup_ui_kit.dart';

import '../../golden_config.dart';

void main() {
  test("When calling `isClosed` should return true if the status is closed", () {
    expect(PositionStatus.closed.isClosed, true);
  });

  test("When calling `isClosed` should return false if the status is not closed", () {
    expect(PositionStatus.inRange.isClosed, false);
  });

  zGoldenTest("The label should be correct for the in range status", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Builder(builder: (context) {
      expect(PositionStatus.inRange.label(context), "In Range");

      return const SizedBox.shrink();
    })));
  });

  zGoldenTest("The label should be correct for the in out of range status", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Builder(builder: (context) {
      expect(PositionStatus.outOfRange.label(context), "Out of Range");

      return const SizedBox.shrink();
    })));
  });

  zGoldenTest("The label should be correct for the closed status", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Builder(builder: (context) {
      expect(PositionStatus.closed.label(context), "Closed");

      return const SizedBox.shrink();
    })));
  });

  zGoldenTest("The label should be correct for the unknown status", (tester) async {
    await tester.pumpDeviceBuilder(await goldenDeviceBuilder(Builder(builder: (context) {
      expect(PositionStatus.unknown.label(context), "Unknown");

      return const SizedBox.shrink();
    })));
  });

  test("The color should be correct for the in range status", () {
    expect(PositionStatus.inRange.color, ZupColors.green);
  });

  test("The color should be correct for the out of range status", () {
    expect(PositionStatus.outOfRange.color, ZupColors.red);
  });

  test("The color should be correct for the closed status", () {
    expect(PositionStatus.closed.color, ZupColors.gray);
  });

  test("The color should be correct for the unknown status", () {
    expect(PositionStatus.unknown.color, ZupColors.gray);
  });
  group("Icon tests", () {
    Future<DeviceBuilder> goldenBuilder(Widget child) async => await goldenDeviceBuilder(
          Center(
            child: ColorFiltered(
              colorFilter: const ColorFilter.mode(ZupColors.black, BlendMode.srcIn),
              child: child,
            ),
          ),
          device: GoldenDevice.square,
        );

    zGoldenTest("The icon should be correct for the in range status", goldenFileName: "in_range_icon", (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(PositionStatus.inRange.icon));
    });

    zGoldenTest("The icon should be correct for the out of range status", goldenFileName: "out_of_range_icon",
        (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(PositionStatus.outOfRange.icon));
    });

    zGoldenTest("The icon should be correct for the closed status", goldenFileName: "closed_icon", (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(PositionStatus.closed.icon));
    });

    zGoldenTest("The icon should be correct for the unknown status", goldenFileName: "unknown_icon", (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(PositionStatus.unknown.icon));
    });
  });
}
