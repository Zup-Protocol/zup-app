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

class GoldenConfig {
  static final pcDevice = [const Device(size: Size(1912, 1040), name: "pc")];
  static final smallSquareDevice = [const Device(size: Size(800, 800), name: "square")];

  static Future<Widget> builder(Widget child) async {
    await loadAppFonts();

    return MaterialApp(
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        Web3KitLocalizations.delegate,
      ],
      home: Scaffold(
        backgroundColor: Colors.white,
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
            hasScrollBody: false,
            child: child,
          )
        ]),
      ),
      theme: ZupTheme.lightTheme,
    );
  }

  static Widget Function(Widget) localizationsWrapper() {
    return (child) => MaterialApp(
          localizationsDelegates: const [
            S.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            Web3KitLocalizations.delegate,
          ],
          home: Scaffold(body: child),
        );
  }
}

Future<DeviceBuilder> goldenDeviceBuilder(Widget child, {bool largeDevice = true}) async => DeviceBuilder()
  ..overrideDevicesForAllScenarios(devices: largeDevice ? GoldenConfig.pcDevice : GoldenConfig.smallSquareDevice)
  ..addScenario(widget: await GoldenConfig.builder(child));

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

          // ignore: avoid_print
          print("Golden file not detected. Auto-generated golden file: $goldenFileName");

          return;
        }

        rethrow;
      }
    }
  });
}
