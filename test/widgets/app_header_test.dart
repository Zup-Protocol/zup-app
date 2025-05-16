import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/app_header/app_header.dart';

import '../golden_config.dart';
import '../mocks.dart';

void main() {
  late AppCubit appCubit;
  late ZupNavigator zupNavigator;

  setUp(() async {
    await Web3Kit.initializeForTest();

    appCubit = AppCubitMock();
    zupNavigator = ZupNavigatorMock();

    final listenable = ListenableMock();

    GetIt.I.registerFactory<AppCubit>(() => appCubit);
    GetIt.I.registerLazySingleton<ZupNavigator>(() => zupNavigator);

    when(() => zupNavigator.listenable).thenReturn(listenable);
    when(() => zupNavigator.currentRoute).thenReturn("any");
    when(() => appCubit.selectedNetwork).thenReturn(AppNetworks.mainnet);
    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => const Stream.empty());
    when(() => appCubit.isTestnetMode).thenReturn(false);
    when(() => appCubit.stream).thenAnswer((_) => const Stream.empty());
    when(() => appCubit.state).thenReturn(const AppState.standard());
    when(() => zupNavigator.navigateToInitial()).thenAnswer((_) => Future.value());

    when(() => zupNavigator.navigateToNewPosition()).thenAnswer((_) => Future.value());
  });

  tearDown(() => GetIt.I.reset());

  Future<DeviceBuilder> goldenBuilder({bool isMobile = false}) async => await goldenDeviceBuilder(
        const AppHeader(height: 80),
        device: isMobile ? GoldenDevice.mobile : GoldenDevice.pc,
      );

  zGoldenTest("Zup Header Default", goldenFileName: "zup_header", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When the current route is new position, it should select the new position button",
      goldenFileName: "zup_header_new_position", (tester) async {
    when(() => zupNavigator.currentRoute).thenReturn(ZupNavigatorPaths.newPosition.path);

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When clicking the logo button, it should navigate to the initial route", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("logo-button")));

    verify(() => zupNavigator.navigateToInitial()).called(1);
  });

  zGoldenTest("When clicking the new position button, it should navigate to the new position route", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("new-position-button")));

    verify(() => zupNavigator.navigateToNewPosition()).called(1);
  });

  // zGoldenTest("All the networks in the $Networks enum should be passed to the network switcher", (tester) async {
  //   await tester.pumpDeviceBuilder(await goldenBuilder());

  //   final networkSwitcher = (find.byType(NetworkSwitcher)).first.evaluate().first.widget as NetworkSwitcher;

  //   expect(networkSwitcher.networks.length, Networks.values.length);
  // });

  // zGoldenTest("The parameters passed to the network switcher should match the $Networks enum order", (tester) async {
  //   await tester.pumpDeviceBuilder(await goldenBuilder());

  //   final networkSwitcher = (find.byType(NetworkSwitcher)).first.evaluate().first.widget as NetworkSwitcher;

  //   Networks.values.forEachIndexed((index, network) {
  //     expect(
  //       networkSwitcher.networks[index].chainInfo,
  //       network.chainInfo,
  //       reason: "ChainInfo in network switcher does not match ${network.label} from $Networks",
  //     );

  //     expect(
  //       networkSwitcher.networks[index].icon.toString(),
  //       network.icon.toString(),
  //       reason: "Icon in network switcher does not match ${network.label} from $Networks",
  //     );

  //     expect(
  //       networkSwitcher.networks[index].title,
  //       network.label,
  //       reason: "Title in network switcher does not match ${network.label} from $Networks",
  //     );
  //   });
  // });

  // zGoldenTest("The initial network of the Network switcher, should be the one defined in the app cubit",
  //     (tester) async {
  //   when(() => appCubit.selectedNetwork).thenReturn(Networks.sepolia);

  //   await tester.pumpDeviceBuilder(await goldenBuilder());

  //   final networkSwitcher = (find.byType(NetworkSwitcher)).first.evaluate().first.widget as NetworkSwitcher;

  //   expect(networkSwitcher.initialNetworkIndex, Networks.sepolia.index);
  // });

  // zGoldenTest(
  //     "When selecting a network in the network switcher and the chain info is not null, it should update network in the the app cubit",
  //     (tester) async {
  //   const network = Networks.scrollSepolia;

  //   await tester.pumpDeviceBuilder(await goldenBuilder());

  //   await tester.tap(find.byType(NetworkSwitcher));
  //   await tester.pumpAndSettle();

  //   await tester.tap(find.text(network.label));
  //   await tester.pumpAndSettle();

  //   verify(() => appCubit.updateAppNetwork(network)).called(1);
  // });

  zGoldenTest(
      "When an event about the route is emitted, and the new route is New position, it should select New position button",
      goldenFileName: "zup_header_new_position_event", (tester) async {
    final changeNotifier = ChangeNotifierMock();

    when(() => zupNavigator.listenable).thenReturn(changeNotifier);
    await tester.pumpDeviceBuilder(await goldenBuilder());

    when(() => zupNavigator.currentRoute).thenReturn(ZupNavigatorPaths.newPosition.path);
    changeNotifier.notify();
  });

  zGoldenTest(
      "When an event about the route is emitted, but the new route is not My positions or New position, it should not select any button",
      goldenFileName: "zup_header_generic_route_event", (tester) async {
    final changeNotifier = ChangeNotifierMock();

    when(() => zupNavigator.listenable).thenReturn(changeNotifier);
    await tester.pumpDeviceBuilder(await goldenBuilder());

    when(() => zupNavigator.currentRoute).thenReturn("some_crazy_route");
    changeNotifier.notify();
  });

  zGoldenTest(
    "When the running device is mobile size, the app header should hide the tab buttons and make the network switcher compact",
    goldenFileName: "zup_header_mobile",
    (tester) async {
      await tester.pumpDeviceBuilder(await goldenBuilder(isMobile: true));
    },
  );
}
