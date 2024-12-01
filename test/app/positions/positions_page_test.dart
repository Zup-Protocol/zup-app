import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:golden_toolkit/golden_toolkit.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/app/positions/positions_page.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';
import 'package:zup_app/core/injections.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

import '../../golden_config.dart';
import '../../mocks.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late AppCubit appCubit;
  late ZupNavigator navigator;
  late PositionsCubit positionsCubit;
  late PositionsRepository positionsRepository;
  late Wallet wallet;
  late Cache cache;

  setUp(() async {
    await Web3Kit.initializeForTest();

    navigator = ZupNavigatorMock();
    appCubit = AppCubitMock();
    wallet = WalletMock();
    positionsRepository = PositionsRepositoryMock();
    cache = CacheMock();

    when(() => cache.getHidingClosedPositionsStatus()).thenAnswer((_) async => false);
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => const Stream.empty());
    when(() => appCubit.selectedNetwork).thenReturn(Networks.all);
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => []);
    when(() => cache.saveHidingClosedPositionsStatus(status: any(named: "status"))).thenAnswer((_) async => () {});

    positionsCubit = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    inject.registerFactory<AppCubit>(() => appCubit);
    inject.registerFactory<ZupNavigator>(() => navigator);
    inject.registerFactory<PositionsCubit>(() => positionsCubit);
    inject.registerFactory<ZupCachedImage>(() => mockZupCachedImage());
  });

  tearDown(() => inject.reset());

  Future<DeviceBuilder> goldenBuilder() async => await goldenDeviceBuilder(const Scaffold(body: PositionsPage()));

  zGoldenTest("When the state is not connected, it should show the not connected page",
      goldenFileName: "positions_page_not_connected", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.notConnected());
  });

  zGoldenTest("When the user is connected, it should show the `(hide || show) closed positions` button",
      goldenFileName: "positions_page_show_or_hide_closed_positions_button", (tester) async {
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => [PositionDto.fixture()]);
    when(() => wallet.signer).thenReturn(SignerMock());

    positionsCubit.getUserPositions();

    await tester.pumpDeviceBuilder(await goldenBuilder());
  });

  zGoldenTest("When the state is not connected, it should not show the `(hide || show) closed positions` button",
      goldenFileName: "positions_page_show_or_hide_closed_positions_button_not_connected", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.notConnected());
  });

  zGoldenTest("When the state is error, it should not show the `(hide || show) closed positions` button",
      goldenFileName: "positions_page_show_or_hide_closed_positions_button_error", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.error());
  });

  zGoldenTest("""When clicking on the hide closed positions button,
   it should hide the closed positions and change the button text to 'Show'""",
      goldenFileName: "positions_page_hide_closed_positions", (tester) async {
    when(() => positionsRepository.fetchUserPositions()).thenAnswer(
      (_) async => [PositionDto.fixture().copyWith(status: PositionStatus.closed)],
    );
    when(() => wallet.signer).thenReturn(SignerMock());

    positionsCubit.getUserPositions();

    await tester.pumpDeviceBuilder(await goldenBuilder());

    expect(find.byKey(const Key("position-card-0")),
        findsOneWidget); // making sure that at least one position was in the screen before

    await tester.tap(find.byKey(const Key("hide-show-closed-positions")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("""When clicking on the show closed positions button,
      it should show the closed positions, and change the button text to 'Hide'""",
      goldenFileName: "positions_page_show_closed_positions", (tester) async {
    when(() => positionsRepository.fetchUserPositions()).thenAnswer(
      (_) async => [PositionDto.fixture().copyWith(status: PositionStatus.closed)],
    );
    when(() => wallet.signer).thenReturn(SignerMock());

    positionsCubit.getUserPositions();

    await tester.pumpDeviceBuilder(await goldenBuilder());
    await tester.tap(find.byKey(const Key("hide-show-closed-positions")));
    await tester.pumpAndSettle();

    expect(
      find.byKey(const Key("position-card-0")),
      findsNothing,
    ); // making sure that no position was in the screen before

    await tester.tap(find.byKey(const Key("hide-show-closed-positions")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the `new position` button, it should go to the new position page", (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) => Future.value());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    await tester.tap(find.byKey(const Key("new-position-button")));

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest("When the state is error, it should show the error state", goldenFileName: "positions_page_error_state",
      (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.error());
  });

  zGoldenTest("When the state is loading, it should show the loading state",
      goldenFileName: "positions_page_loading_state", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.loading());
  });

  zGoldenTest("When the state is no positions, it should show the no positions state",
      goldenFileName: "positions_page_no_positions_state", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.noPositions());
  });

  zGoldenTest("When the state is no positions in network, it should show the no positions in network state",
      goldenFileName: "positions_page_no_positions_in_network_state", (tester) async {
    when(() => appCubit.selectedNetwork).thenReturn(Networks.sepolia);
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.noPositionsInNetwork());
  });

  zGoldenTest("When the state is positions, it should show the positions state",
      goldenFileName: "positions_page_positions_state", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    final positions = [PositionDto.fixture(), PositionDto.fixture().copyWith(), PositionDto.fixture()];

    (positionsCubit as BlocBase).emit(PositionsState.positions(positions));
  });

  zGoldenTest("When the state is not connected to the wallet, it should show the not connected state",
      goldenFileName: "positions_page_not_connected_state", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.notConnected());
  });

  zGoldenTest("When clicking the helper button in the not connected state, it should open the connect modal",
      goldenFileName: "positions_page_not_connected_helper_button_click", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder(), wrapper: GoldenConfig.localizationsWrapper());

    (positionsCubit as BlocBase).emit(const PositionsState.notConnected());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();
  });

  zGoldenTest("When clicking the helper button in the no positions state, it should navigate to new positions page",
      (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) => Future.value());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.noPositions());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest(
      "When clicking the helper button in the no positions in network state, it should navigate to new positions page",
      (tester) async {
    when(() => navigator.navigateToNewPosition()).thenAnswer((_) => Future.value());

    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.noPositionsInNetwork());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => navigator.navigateToNewPosition()).called(1);
  });

  zGoldenTest("When clicking the helper button in the error state, it should refetch positions", (tester) async {
    await tester.pumpDeviceBuilder(await goldenBuilder());

    (positionsCubit as BlocBase).emit(const PositionsState.error());
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key("help-button")));
    await tester.pumpAndSettle();

    verify(() => positionsRepository.fetchUserPositions())
        .called(2); // two calls because of the first call and the refetch
  });

  zGoldenTest("When showing positions from other network, it should include a helper text below the positions",
      goldenFileName: "positions_page_positions_state_other_network", (tester) async {
    when(() => appCubit.selectedNetwork).thenReturn(Networks.sepolia);

    await tester.pumpDeviceBuilder(await goldenBuilder());

    final positions = [PositionDto.fixture(), PositionDto.fixture().copyWith(), PositionDto.fixture()];

    (positionsCubit as BlocBase).emit(PositionsState.positions(positions));
  });
}
