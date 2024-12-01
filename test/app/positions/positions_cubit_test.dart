import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/position_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/position_status.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';

import '../../mocks.dart';

void main() {
  late Wallet wallet;
  late PositionsRepository positionsRepository;
  late AppCubit appCubit;
  late Cache cache;
  late PositionsCubit sut;

  setUp(() async {
    wallet = WalletMock();
    positionsRepository = PositionsRepositoryMock();
    appCubit = AppCubitMock();
    cache = CacheMock();

    when(() => cache.getHidingClosedPositionsStatus()).thenAnswer((_) async => false);
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => appCubit.selectedNetworkStream).thenAnswer((_) => const Stream.empty());
    when(() => appCubit.selectedNetwork).thenReturn(Networks.all);
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => []);
    when(() => cache.saveHidingClosedPositionsStatus(status: any(named: "status"))).thenAnswer((_) async => () {});
    when(() => cache.getHidingClosedPositionsStatus()).thenAnswer((_) async => false);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);
  });

  test("When instantiating the cubit, and the signer is null, it should emit not connected state", () {
    when(() => wallet.signer).thenReturn(null);

    final cubit = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    expect(cubit.state, const PositionsState.notConnected());
  });

  test("When instantiating the cubit, and the signer is not null, it should get the user positions", () {
    when(() => wallet.signer).thenReturn(SignerMock());

    verify(() => positionsRepository.fetchUserPositions()).called(1); // considering the instantiation at the setup
  });

  test("""When instantiating the cubit, it should get
  the current saved hiding closed positions status
  and attribute it to the public variable""", () async {
    final initialHidingClosedPositionsState = sut.hidingClosedPositions;
    final cachedHidingClosedPositions = !initialHidingClosedPositionsState;

    when(() => cache.getHidingClosedPositionsStatus()).thenAnswer((_) async => cachedHidingClosedPositions);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero); // needed to make flutter wait until it finish the init

    expect(sut.hidingClosedPositions, cachedHidingClosedPositions);
    verify(() => cache.getHidingClosedPositionsStatus()).called(2);
  });

  group("When instantiating the cubit, it should listen for signer changes", () {
    test("When the new signer is null, it should emit not connected state and clear the user positions cached",
        () async {
      final signerStreamController = StreamController<Signer?>.broadcast();

      when(() => positionsRepository.fetchUserPositions()).thenAnswer(
        (_) async => List.generate(10, (_) => PositionDto.fixture()),
      );
      when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);

      sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

      await Future.delayed(Duration.zero); // needed to make flutter wait until it finish the init

      expectLater(sut.stream, emits(const PositionsState.notConnected()));
      signerStreamController.add(null);

      await Future.delayed(Duration.zero);

      expect(sut.state, const PositionsState.notConnected(), reason: "it should keep the state as not connected");
      expect(sut.positions, isNull, reason: "it should clear the user positions");
    });

    test("When the signer emitted is not null, it should get the user positions", () async {
      when(() => wallet.signer).thenReturn(null); // initial signer is null, then a new signer is emitted

      final signerStreamController = StreamController<Signer?>.broadcast();

      when(() => positionsRepository.fetchUserPositions()).thenAnswer(
        (_) async => List.generate(10, (_) => PositionDto.fixture()),
      );
      when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);

      sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

      signerStreamController.add(SignerMock());

      await Future.delayed(Duration.zero);

      verify(() => positionsRepository.fetchUserPositions()).called(1);
    });
  });

  group("When instantiating the cubit, it should listen for network changes", () {
    test("""When the signer is not null, it should filter the user positions,
        to only show positions on the selected network""", () async {
      const newNetwork = Networks.sepolia;
      final positions = List.generate(10, (_) => PositionDto.fixture().copyWith(network: Networks.scrollSepolia));

      final networkStreamController = StreamController<Networks>.broadcast();

      when(() => wallet.signer).thenReturn(SignerMock());
      when(() => appCubit.selectedNetworkStream).thenAnswer((_) => networkStreamController.stream);
      when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => positions);
      when(() => appCubit.selectedNetwork).thenReturn(newNetwork);

      sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

      await Future.delayed(Duration.zero);

      expectLater(
          sut.stream,
          emitsInAnyOrder(
            [const PositionsState.loading(), const PositionsState.noPositionsInNetwork()],
          ));

      networkStreamController.add(newNetwork);
    });

    test("""When the signer is null, it should not filter the user positions""", () async {
      const newNetwork = Networks.sepolia;

      final networkStreamController = StreamController<Networks>.broadcast();

      when(() => wallet.signer).thenReturn(null);
      when(() => appCubit.selectedNetworkStream).thenAnswer((_) => networkStreamController.stream);

      sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

      await Future.delayed(Duration.zero);

      sut.stream.listen((state) => throw Exception("This test should not filter the user positions"));

      networkStreamController.add(newNetwork);
    });
  });

  test("When filtering the positions, it should emit the loading state", () {
    expectLater(sut.stream, emits(const PositionsState.loading()));

    sut.filterUserPositions();
  });

  test("""When filtering the positions, it should save the param to hide closed positions in the cache""", () {
    const hidingStatus = true;

    sut.filterUserPositions(hideClosedPositions: hidingStatus);

    verify(() => cache.saveHidingClosedPositionsStatus(status: hidingStatus)).called(1);
  });

  test("When filtering positions and the user does not have any positions, it should emit no positions", () {
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => []);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    expectLater(sut.stream, emits(const PositionsState.noPositions()));

    sut.filterUserPositions();

    expect(sut.state, const PositionsState.noPositions());
  });

  test("""When filtering positions, the param to hide closed positions is true,
   and the user has positions, it should emit the positions state with
   the filtered positions (without closed positions)""", () async {
    final expectedPositions = [PositionDto.fixture().copyWith(status: PositionStatus.inRange)];

    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions()).thenAnswer(
      (_) async => [PositionDto.fixture().copyWith(status: PositionStatus.closed), ...expectedPositions],
    );

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.filterUserPositions(hideClosedPositions: true);
  });

  test("""When filtering positions, the param to hide closed positions is true,
   and the user does not have positions after the filter applied, it should
  emit the no positions state""", () async {
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions())
        .thenAnswer((_) async => [PositionDto.fixture().copyWith(status: PositionStatus.closed)]);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), const PositionsState.noPositions()]),
    );

    sut.filterUserPositions(hideClosedPositions: true);
  });

  test("""When filtering positions, the current network is not all,
       and the user has positions in the filtered network,
       it should emit the positions state with the filtered positions""", () async {
    const selectedNetwork = Networks.sepolia;
    final expectedPositions = [PositionDto.fixture().copyWith(network: selectedNetwork)];

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => [
          PositionDto.fixture().copyWith(network: Networks.scrollSepolia),
          ...expectedPositions,
        ]);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.filterUserPositions();
  });

  test("""When filtering positions, the current network is not all,
       and the user has no positions in the filtered network,
       it should emit the no positions in network state""", () async {
    const selectedNetwork = Networks.sepolia;

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => [
          PositionDto.fixture().copyWith(network: Networks.scrollSepolia),
        ]);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), const PositionsState.noPositionsInNetwork()]),
    );

    sut.filterUserPositions();
  });

  test("""When filtering positions, the current network is all,
       it should just return all the positions""", () async {
    const selectedNetwork = Networks.all;
    final expectedPositions = [
      PositionDto.fixture().copyWith(network: selectedNetwork),
      PositionDto.fixture().copyWith(network: selectedNetwork),
      PositionDto.fixture().copyWith(network: selectedNetwork),
    ];

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => expectedPositions);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.filterUserPositions();
  });

  test("""When filtering positions with hide close positions and a network that it not all,
      it should return the positions matching the filter""", () async {
    const selectedNetwork = Networks.sepolia;
    final expectedPositions = [
      PositionDto.fixture().copyWith(network: selectedNetwork, status: PositionStatus.outOfRange),
      PositionDto.fixture().copyWith(network: selectedNetwork, status: PositionStatus.inRange),
    ];

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => [
          PositionDto.fixture().copyWith(network: Networks.scrollSepolia),
          PositionDto.fixture().copyWith(network: Networks.sepolia, status: PositionStatus.closed),
          ...expectedPositions
        ]);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.filterUserPositions(hideClosedPositions: true);
  });

  test("When filtering, it should not change the cached positions array", () async {
    final expectedPositions = [
      PositionDto.fixture().copyWith(network: Networks.sepolia, status: PositionStatus.outOfRange),
      PositionDto.fixture().copyWith(network: Networks.scrollSepolia, status: PositionStatus.inRange),
    ];

    when(() => appCubit.selectedNetwork).thenReturn(Networks.all);
    when(() => wallet.signer).thenReturn(SignerMock());
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => expectedPositions);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);
    sut.filterUserPositions(hideClosedPositions: true);

    await Future.delayed(Duration.zero);

    expect(sut.positions, expectedPositions);
  });

  test("when getting the user positions it should emit the loading state", () async {
    expectLater(sut.stream, emits(const PositionsState.loading()));

    sut.getUserPositions();
  });

  test("When getting the user positions, it should get the positions from the repository", () async {
    final repository = PositionsRepositoryMock();

    when(() => repository.fetchUserPositions()).thenAnswer((_) async => []);
    when(() => wallet.signer).thenReturn(null);

    sut = PositionsCubit(wallet, repository, appCubit, cache);
    sut.getUserPositions();

    verify(() => repository.fetchUserPositions()).called(1);
  });

  test("When getting the user positions, and a error is thrown, it should emit the error state", () {
    final repository = PositionsRepositoryMock();

    when(() => repository.fetchUserPositions()).thenThrow("dale error");
    when(() => wallet.signer).thenReturn(null);

    sut = PositionsCubit(wallet, repository, appCubit, cache);
    sut.getUserPositions();

    expect(sut.state, const PositionsState.error());
  });

  test("""When getting the user positions, and the current network
   is not all, it should filter the positions""", () async {
    const selectedNetwork = Networks.sepolia;

    final expectedPositions = [
      PositionDto.fixture().copyWith(network: selectedNetwork, status: PositionStatus.outOfRange),
      PositionDto.fixture().copyWith(network: selectedNetwork, status: PositionStatus.inRange),
    ];

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
    when(() => positionsRepository.fetchUserPositions()).thenAnswer(
        (_) async => [PositionDto.fixture().copyWith(network: Networks.scrollSepolia), ...expectedPositions]);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.getUserPositions();
  });

  test("""When getting the user positions, and the user it currently hiding
  closed positions, it should filter the positions""", () async {
    const selectedNetwork = Networks.sepolia;

    final expectedPositions = [
      PositionDto.fixture().copyWith(network: selectedNetwork, status: PositionStatus.outOfRange),
      PositionDto.fixture().copyWith(network: selectedNetwork, status: PositionStatus.inRange),
    ];

    when(() => appCubit.selectedNetwork).thenReturn(selectedNetwork);
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => [
          PositionDto.fixture().copyWith(network: Networks.scrollSepolia, status: PositionStatus.closed),
          ...expectedPositions
        ]);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.getUserPositions();
  });

  test("""When getting the user positions, and the user it currently not hiding
  closed positions, it should not filter the positions""", () async {
    final expectedPositions = [
      PositionDto.fixture().copyWith(status: PositionStatus.closed),
      PositionDto.fixture().copyWith(status: PositionStatus.closed),
      PositionDto.fixture().copyWith(status: PositionStatus.outOfRange),
      PositionDto.fixture().copyWith(status: PositionStatus.inRange),
    ];

    when(() => appCubit.selectedNetwork).thenReturn(Networks.all);
    when(() => positionsRepository.fetchUserPositions()).thenAnswer((_) async => expectedPositions);

    sut = PositionsCubit(wallet, positionsRepository, appCubit, cache);

    await Future.delayed(Duration.zero);

    expectLater(
      sut.stream,
      emitsInOrder([const PositionsState.loading(), PositionsState.positions(expectedPositions)]),
    );

    sut.getUserPositions();
  });
}
