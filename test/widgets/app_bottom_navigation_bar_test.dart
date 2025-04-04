import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/app_bottom_navigation_bar.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late ZupNavigator navigator;

  setUp(() {
    navigator = ZupNavigatorMock();

    inject.registerFactory<ZupNavigator>(() => navigator);

    when(() => navigator.listenable).thenReturn(ListenableMock());
    when(() => navigator.currentRoute).thenReturn("any");
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(
        const AppBottomNavigationBar(),
        device: GoldenDevice.mobile,
      );

  zGoldenTest(
    "When initializing the widget, and the current route is new position, it should selected the new position tab",
    goldenFileName: "app_bottom_navigation_bar_initial_new_position",
    (tester) async {
      when(() => navigator.currentRoute).thenReturn(ZupNavigatorPaths.newPosition.path);

      await tester.pumpDeviceBuilder(await goldenBuilder());
    },
  );

  zGoldenTest(
    "When clicking the new position tab, it should navigate to the new position page",
    (tester) async {
      when(() => navigator.navigateToNewPosition()).thenAnswer((_) => Future.value());

      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.tap(find.byKey(Key(ZupNavigatorPaths.newPosition.path)));
      await tester.pumpAndSettle();

      verify(() => navigator.navigateToNewPosition()).called(1);
    },
  );
}
