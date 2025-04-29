import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:routefly/routefly.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/zup_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final MaterialApp material = MaterialApp.router(
    localizationsDelegates: const [Web3KitLocalizations.delegate],
    routerConfig: Routefly.routerConfig(
      routes: routes,
      initialPath: ZupNavigatorPaths.initial.path,
      routeBuilder: (context, settings, child) => PageRouteBuilder(
        settings: settings,
        pageBuilder: (context, __, ___) => const SizedBox(),
      ),
    ),
  );

  testWidgets("When calling `navigateToNewPosition` it should use routefly to navigate to the new position page",
      (tester) async {
    await tester.pumpWidget(material);

    await ZupNavigator().navigateToNewPosition();

    expect(Routefly.currentUri.path, ZupNavigatorPaths.newPosition.path);
  });

  testWidgets("When calling `navigateToInitial` it should use routefly to navigate to the initial page",
      (tester) async {
    runApp(material);

    await ZupNavigator().navigateToInitial();

    expect(Routefly.currentUri.path, ZupNavigatorPaths.initial.path);
  });

  testWidgets("When calling `currentRoute` it should use routefly to get the current route", (tester) async {
    runApp(material);

    await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

    expect(ZupNavigator().currentRoute, ZupNavigatorPaths.newPosition.path);
  });

  testWidgets("When using `listenable` to listen route change events, it should delegate to Routefly listenable",
      (tester) async {
    runApp(material);

    bool listenerCalled = false;

    ZupNavigator().listenable.addListener(() => listenerCalled = true);

    await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

    expect(listenerCalled, true);
  });
}
