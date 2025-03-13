import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:routefly/routefly.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/app_layout.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/l10n/gen/app_localizations.dart';
import 'package:zup_app/zup_app.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late AppCubit appCubit;

  setUp(() async {
    await Web3Kit.initializeForTest();

    appCubit = AppCubitMock();

    inject.registerFactory<ZupLinks>(() => ZupLinksMock());
    inject.registerFactory<ZupNavigator>(() => ZupNavigator());
    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ScrollController>(
      () => ScrollController(),
      instanceName: InjectInstanceNames.appScrollController,
    );

    when(() => appCubit.selectedNetwork).thenReturn(Networks.sepolia);
  });

  Future<DeviceBuilder> goldenBuilder({bool isMobile = false}) async => await goldenDeviceBuilder(
        MaterialApp.router(
          localizationsDelegates: const [
            S.delegate,
            Web3KitLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          routerConfig: Routefly.routerConfig(
            routes: routes,
            initialPath: ZupNavigatorPaths.newPosition.path,
            routeBuilder: (context, settings, child) => PageRouteBuilder(
              settings: settings,
              pageBuilder: (context, __, ___) => const AppPage(),
            ),
          ),
        ),
        device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
      );

  zGoldenTest("When the device size is a mobile, it should have a bottom navbar instead of a top app bar",
      goldenFileName: "app_layout_navbar", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true), wrapper: GoldenConfig.localizationsWrapper());
  });

  zGoldenTest("When the device size is a desktop, it should have a top app bar to navigate, instead of a bottom navbar",
      goldenFileName: "app_layout_top_app_bar", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: false), wrapper: GoldenConfig.localizationsWrapper());
  });

  zGoldenTest("When scrolling down, it should have a footer (desktop version)",
      goldenFileName: "app_layout_footer_desktop", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.drag(find.byKey(const Key("screen")).first, const Offset(0, -500));
  });

  zGoldenTest("When scrolling down, it should have a footer (mobile version)",
      goldenFileName: "app_layout_footer_mobile", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true), wrapper: GoldenConfig.localizationsWrapper());

    await tester.drag(find.byKey(const Key("screen")).first, const Offset(0, -500));
  });
}
