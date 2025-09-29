import "dart:typed_data";

import "package:flutter/material.dart";
import "package:flutter_localizations/flutter_localizations.dart";
import "package:flutter_test/flutter_test.dart";
import "package:freezed_annotation/freezed_annotation.dart";
import "package:golden_toolkit/golden_toolkit.dart";
import "package:web3kit/web3kit.dart";
import "package:zup_app/l10n/gen/app_localizations.dart";
import "package:zup_app/theme/theme.dart";

import "mocks.dart";

enum GoldenDevice {
  pc,
  mobile,
  square,
  pcAndMobile;

  List<Device> get devices {
    switch (this) {
      case GoldenDevice.pc:
        return GoldenConfig.pcDevice;
      case GoldenDevice.mobile:
        return GoldenConfig.mobileDevice;
      case GoldenDevice.square:
        return GoldenConfig.smallSquareDevice;
      case GoldenDevice.pcAndMobile:
        return [...GoldenConfig.pcDevice, ...GoldenConfig.mobileDevice];
    }
  }
}

class GoldenConfig {
  static final pcDevice = [const Device(size: Size(1912, 1040), name: "pc")];
  static final smallSquareDevice = [const Device(size: Size(800, 800), name: "square")];
  static final mobileDevice = [const Device(size: Size(375, 812), name: "mobile")];

  static final scrollController = ScrollController();
  static final navigatorKey = GlobalKey<NavigatorState>();

  static Future<Widget> builder(Widget child, {bool darkMode = false}) async {
    await loadAppFonts();

    return MaterialApp(
      navigatorKey: navigatorKey,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        Web3KitLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(
          controller: scrollController,
          slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
        ),
      ),
      theme: darkMode ? AppTheme.darkTheme : AppTheme.lightTheme,
    );
  }

  static Widget Function(Widget) localizationsWrapper({GlobalKey<ScaffoldMessengerState>? scaffoldMessengerKey}) {
    return (child) => MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        Web3KitLocalizations.delegate,
      ],
      theme: AppTheme.lightTheme,
      home: Scaffold(
        body: CustomScrollView(
          controller: scrollController,
          slivers: [SliverFillRemaining(hasScrollBody: false, child: child)],
        ),
      ),
    );
  }
}

Future<DeviceBuilder> goldenDeviceBuilder(
  Widget child, {
  GoldenDevice device = GoldenDevice.pc,
  bool darkMode = false,
}) async => DeviceBuilder()
  ..overrideDevicesForAllScenarios(devices: device.devices)
  ..addScenario(widget: await GoldenConfig.builder(child, darkMode: darkMode));

@isTest
void zGoldenTest(
  String description,
  Future<void> Function(WidgetTester tester) test, {
  String? goldenFileName,
  Uint8List? overrideMockedNetworkImage,
}) {
  return testGoldens(description, (tester) async {
    await mockHttpImage(() async => await test(tester), overrideImage: overrideMockedNetworkImage);

    await tester.pumpAndSettle();

    if (goldenFileName != null) {
      try {
        await screenMatchesGolden(tester, goldenFileName);
      } catch (e) {
        if ((e as TestFailure).message!.contains("non-existent file")) {
          autoUpdateGoldenFiles = true;
          await screenMatchesGolden(tester, goldenFileName);
          autoUpdateGoldenFiles = false;

          debugPrint("Golden file not detected. Auto-generated golden file: $goldenFileName");

          return;
        }

        rethrow;
      }
    }
  });
}
