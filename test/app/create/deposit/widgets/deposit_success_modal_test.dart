import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:url_launcher_platform_interface/url_launcher_platform_interface.dart';
import 'package:zup_app/app/create/deposit/widgets/deposit_success_modal.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../../../golden_config.dart';
import '../../../../mocks.dart';

void main() {
  late ConfettiController confettiController;

  setUp(() {
    UrlLauncherPlatform.instance = UrlLauncherPlatformCustomMock();

    confettiController = ConfettiControllerMock();

    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
    inject.registerFactory<ConfettiController>(
      () => confettiController,
      instanceName: InjectInstanceNames.confettiController10s,
    );

    when(() => confettiController.state).thenReturn(ConfettiControllerState.stoppedAndCleared);
    when(() => confettiController.duration).thenReturn(Duration.zero);
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder({
    YieldDto? customYield,
    bool showAsBottomSheet = false,
  }) async =>
      await goldenDeviceBuilder(Builder(builder: (context) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          DepositSuccessModal.show(
            context,
            depositedYield: customYield ?? YieldDto.fixture().copyWith(),
            showAsBottomSheet: showAsBottomSheet,
          );
        });

        return const SizedBox.shrink();
      }));

  zGoldenTest(
    "When calling .show in the deposit success modal, it should be displayed",
    goldenFileName: "deposit_success_modal",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

      await tester.pumpAndSettle();
    },
  );

  zGoldenTest("When the widget is initialized, the confetti should be played", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    await tester.pumpAndSettle();

    verify(() => confettiController.play()).called(1);
  });

  zGoldenTest("When the widget is disposed, the confetti controller should be disposed", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.pumpWidget(Container()); // dispose it by pumping a new widget

    verify(() => confettiController.dispose()).called(1);
  });

  zGoldenTest(
    "When clicking to view the position the the dex, it should launch the protocol website attached to the yield",
    (tester) async {
      const protocolUrl = "https://dale.com.zup";

      await tester.pumpDeviceBuilder(
          await goldenBuilder(
              customYield: YieldDto.fixture().copyWith(protocol: ProtocolDto.fixture().copyWith(url: protocolUrl))),
          wrapper: GoldenConfig.localizationsWrapper());
      await tester.pumpAndSettle();

      await tester.tap(find.byKey(const Key("view-position-button")));
      await tester.pumpAndSettle();

      expect(UrlLauncherPlatformCustomMock.lastLaunchedUrl, protocolUrl);
    },
  );

  zGoldenTest("When clicking the close button, the modal should be closed",
      goldenFileName: "deposit_success_modal_close_button_tap", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("close-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When passing showAsBottomSheet to true, the modal should be displayed as a bottom sheet",
      goldenFileName: "deposit_success_modal_bottom_sheet", (tester) async {
    await tester.pumpDeviceBuilder(
      await goldenBuilder(showAsBottomSheet: true),
      wrapper: GoldenConfig.localizationsWrapper(),
    );
    await tester.pumpAndSettle();
  });
}
