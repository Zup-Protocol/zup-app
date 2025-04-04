import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/widgets/app_settings_dropdown.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late AppCubit appCubit;

  setUp(() {
    appCubit = AppCubitMock();

    inject.registerFactory<AppCubit>(() => appCubit);
    when(() => appCubit.isTestnetMode).thenReturn(false);
    when(() => appCubit.toggleTestnetMode()).thenAnswer((_) async {});
    when(() => appCubit.state).thenReturn(const AppState.standard());
    when(() => appCubit.stream).thenAnswer((_) => const Stream.empty());
  });

  tearDown(() {
    inject.reset();
  });

  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(const Center(child: AppSettingsDropdown()));

  zGoldenTest("App settings dropdown default", goldenFileName: "app_settings_dropdown", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When clicking the testnet mode switch, it should call the app cubit to toggle the testnet mode",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("testnet-mode-switch")));
    await tester.pumpAndSettle();

    verify(() => appCubit.toggleTestnetMode()).called(1);
  });

  zGoldenTest("When the app is in testnet mode, the switch should be on",
      goldenFileName: "app_settings_dropdown_testnet_mode_on", (tester) async {
    when(() => appCubit.isTestnetMode).thenReturn(true);

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the testnet mode text, it should call the app cubit to toggle the testnet mode",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("testnet-mode-text")));
    await tester.pumpAndSettle();

    verify(() => appCubit.toggleTestnetMode()).called(1);
  });
}
