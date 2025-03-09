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
    "When initializing the widget, and the current route is my positions, it should selected the my positions tab",
    goldenFileName: "app_bottom_navigation_bar_initial_my_positions",
    (tester) async {
      when(() => navigator.currentRoute).thenReturn(ZupNavigatorPaths.myPositions.path);

      await tester.pumpDeviceBuilder(await goldenBuilder());
    },
  );

  zGoldenTest(
    """When the new position tab is selected, but the listener notify a new route change,
    and the new selected route is my positions, the new selected tab should be my positions""",
    goldenFileName: "app_bottom_navigation_bar_new_position_to_my_positions_listener",
    (tester) async {
      final routeListener = ChangeNotifierMock();

      when(() => navigator.listenable).thenReturn(routeListener);
      when(() => navigator.currentRoute).thenReturn(ZupNavigatorPaths.newPosition.path);

      await tester.pumpDeviceBuilder(await goldenBuilder());

      when(() => navigator.currentRoute).thenReturn(ZupNavigatorPaths.myPositions.path);
      routeListener.notify();

      await tester.pumpAndSettle();
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

  zGoldenTest(
    """When clicking the my positions tab it SHOULD NOT navigate to the my positions page
    (it's not done yet. Soon as we launch the my positions page, this test can be deleted)
    """,
    (tester) async {
      when(() => navigator.navigateToMyPositions()).thenAnswer((_) => Future.value());

      await tester.pumpDeviceBuilder(await goldenBuilder());

      await tester.tap(find.byKey(Key(ZupNavigatorPaths.myPositions.path)));
      await tester.pumpAndSettle();

      verifyNever(() => navigator.navigateToMyPositions());
    },
  );
}
