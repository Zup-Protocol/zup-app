import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/enums/app_theme_mode.dart';
import 'package:zup_app/core/enums/networks.dart';

import '../mocks.dart';

void main() {
  late AppCubit sut;
  late Wallet wallet;
  late Cache cache;

  setUp(() async {
    registerFallbackValue(const ChainInfo(hexChainId: ""));
    registerFallbackValue(AppThemeMode.system);
    await Web3Kit.initializeForTest();

    wallet = WalletMock();
    cache = CacheMock();
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
    when(() => cache.getTestnetMode()).thenReturn(false);
    when(() => cache.themeMode).thenReturn(AppThemeMode.system);
    when(() => cache.saveTestnetMode(isTestnetMode: any(named: "isTestnetMode"))).thenAnswer((_) => Future.value());
    when(() => cache.saveThemeMode(any())).thenAnswer((_) async {});

    sut = AppCubit(wallet, cache);
  });

  test(
    "When calling the `selectedNetwork` after initializing the cubit, it should return the initial selected network",
    () {
      expect(sut.selectedNetwork, AppNetworks.allNetworks);
    },
  );

  test(
    """When an event is emitted that the signer changed,
      and the current signer is not in the selected network,
      it should ask to change the network""",
    () async {
      final wallet0 = WalletMock();
      final signerStreamController = StreamController<Signer?>.broadcast();
      final signerStream = signerStreamController.stream;
      final signer = SignerMock();
      const signerNetwork = "0x7521";

      when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
      when(() => wallet0.connectedNetwork).thenAnswer((_) async => const ChainInfo(hexChainId: signerNetwork));
      when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

      final sut0 = AppCubit(wallet0, cache)..updateAppNetwork(AppNetworks.sepolia);

      signerStreamController.add(signer);

      await Future.delayed(const Duration(milliseconds: 100));

      verify(
        () => wallet0.switchOrAddNetwork(
          ChainInfo(
            hexChainId: sut0.selectedNetwork.chainInfo.hexChainId,
            chainName: sut0.selectedNetwork.chainInfo.chainName,
            blockExplorerUrls: sut0.selectedNetwork.chainInfo.blockExplorerUrls,
            nativeCurrency: sut0.selectedNetwork.chainInfo.nativeCurrency,
            rpcUrls: sut0.selectedNetwork.chainInfo.rpcUrls,
            iconsURLs: sut0.selectedNetwork.chainInfo.iconsURLs,
          ),
        ),
      ).called(1);
    },
  );

  test(
    """When an event is emitted that the signer changed,
      and the current signer is in the selected network,
      it should not ask to change the network""",
    () async {
      final wallet0 = WalletMock();
      final signerStreamController = StreamController<Signer?>.broadcast();
      final signerStream = signerStreamController.stream;
      final signer = SignerMock();
      final signerNetwork = AppNetworks.sepolia.chainInfo.hexChainId;

      when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
      when(() => wallet0.connectedNetwork).thenAnswer((_) async => ChainInfo(hexChainId: signerNetwork));
      when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

      AppCubit(wallet0, cache).updateAppNetwork(AppNetworks.sepolia);

      signerStreamController.add(signer);

      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(() => wallet0.switchOrAddNetwork(any()));
    },
  );

  test(
    """When an event is emitted that the signer changed,
      but the signer is null, it should not ask to change the network""",
    () async {
      final wallet0 = WalletMock();
      final signerStreamController = StreamController<Signer?>.broadcast();
      final signerStream = signerStreamController.stream;

      when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
      when(() => wallet0.connectedNetwork).thenAnswer((_) async => const ChainInfo(hexChainId: ""));
      when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

      AppCubit(wallet0, cache).updateAppNetwork(AppNetworks.sepolia);

      signerStreamController.add(null);

      await Future.delayed(const Duration(milliseconds: 100));

      verifyNever(() => wallet0.switchOrAddNetwork(any()));
    },
  );

  test("When calling `updateAppNetwork` it should update the selected network variable", () async {
    sut.updateAppNetwork(AppNetworks.sepolia);

    expect(sut.selectedNetwork, AppNetworks.sepolia);
  });

  test(
    """When calling `updateAppNetwork` it should emit the state `networkChanged` with the new network
      but it should finish with the event `standard` """,
    () async {
      const network = AppNetworks.sepolia;

      expectLater(sut.stream, emitsInOrder([const AppState.networkChanged(network), const AppState.standard()]));

      sut.updateAppNetwork(network);

      expect(sut.state, const AppState.standard());
    },
  );

  test("When changing the network, it should add an event to the network stream", () {
    const network = AppNetworks.sepolia;

    expectLater(sut.selectedNetworkStream, emits(network));

    sut.updateAppNetwork(network);
  });

  test("When initializing the cubit, the `isTestnetMode` variable should be false by default", () {
    expect(sut.isTestnetMode, false);
  });

  test(
    "When initializing the cubit, it should set the `isTestnetMode` variable to the one saved in the cache",
    () async {
      when(() => cache.getTestnetMode()).thenReturn(true);

      final sut0 = AppCubit(wallet, cache);

      expect(sut0.isTestnetMode, true);
    },
  );

  test(
    "If the cached testnet mode is true when initializing the cubit, the initial selected network should be sepolia",
    () async {
      when(() => cache.getTestnetMode()).thenReturn(true);
      final sut0 = AppCubit(wallet, cache);

      expect(sut0.selectedNetwork, AppNetworks.sepolia);
    },
  );

  test(
    "If the cached testnet mode is true when initializing the cubit, the state testnetModeChanged should be emitted",
    () async {
      when(() => cache.getTestnetMode()).thenReturn(true);

      final sut0 = AppCubit(wallet, cache);
      expect(sut0.state, const AppState.testnetModeChanged(true));
    },
  );

  test("When calling `toggleTestnetMode` it should update the `isTestnetMode` variable to the opposite", () async {
    final currentTestnetMode = sut.isTestnetMode;

    await sut.toggleTestnetMode();
    expect(sut.isTestnetMode, !currentTestnetMode);
  });

  test(
    """When calling `toggleTestnetMode` for true it should emit a `networkChanged`
  for the sepolia network and change the selected network variable""",
    () async {
      expectLater(
        sut.stream,
        emitsInOrder([const AppState.networkChanged(AppNetworks.sepolia), const AppState.standard()]),
      );

      await sut.toggleTestnetMode(); // assuming it starts by default as false

      expect(sut.selectedNetwork, AppNetworks.sepolia);
    },
  );

  test(
    """When calling `toggleTestnetMode` for false it should emit a `networkChanged`
  for a mainnet network and update the selected network variable""",
    () async {
      when(() => cache.getTestnetMode()).thenReturn(true);

      final sut0 = AppCubit(wallet, cache);

      expectLater(
        sut0.stream,
        emitsInOrder([const AppState.networkChanged(AppNetworks.allNetworks), const AppState.standard()]),
      );

      await sut0.toggleTestnetMode();

      expect(sut0.selectedNetwork, AppNetworks.allNetworks);
    },
  );

  test(
    "When calling `toggleTestnetMode` it should save the `isTestnetMode` variable in the cache after toggling",
    () async {
      final oldTestnetMode = sut.isTestnetMode;

      await sut.toggleTestnetMode();

      verify(() => cache.saveTestnetMode(isTestnetMode: !oldTestnetMode)).called(1);
    },
  );

  test(
    """When calling `toggleTestnetMode` for true and there is a signer with a different connected
  network, it should try to switch the wallet network for the default testnet network""",
    () async {
      final signer = SignerMock();
      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.connectedNetwork).thenAnswer((_) async => const ChainInfo(hexChainId: "0x32"));

      await sut.toggleTestnetMode(); // assuming it starts by default as false

      verify(() => wallet.switchOrAddNetwork(AppNetworks.sepolia.chainInfo)).called(1);
    },
  );

  test(
    "When calling `toggleTestnetMode` from false to true it should emit the `testnetModeChanged` state with the new value",
    () async {
      expectLater(sut.stream, emitsInOrder([anything, anything, const AppState.testnetModeChanged(true)]));

      await sut.toggleTestnetMode(); // assuming it starts by default as false
    },
  );

  test(
    "When calling `toggleTestnetMode` from true to false it should emit the `testnetModeChanged` state with the new value",
    () async {
      when(() => cache.getTestnetMode()).thenReturn(true);
      final sut0 = AppCubit(wallet, cache);

      expectLater(sut0.stream, emitsInOrder([anything, anything, const AppState.testnetModeChanged(false)]));

      await sut0.toggleTestnetMode();
    },
  );

  test(
    "When calling `currentChainId` it should get exactly the chain id of the current selected network in the cubit",
    () async {
      sut.updateAppNetwork(AppNetworks.scroll);
      expect(sut.currentChainId, AppNetworks.scroll.chainId);
    },
  );
  test(
    "When initializing the cubit, it should immediately get the cached theme mode and assign it to the variable",
    () {
      const cachedValue = AppThemeMode.dark;
      when(() => cache.themeMode).thenReturn(cachedValue);
      final sut0 = AppCubit(wallet, cache);

      expect(sut0.currentThemeMode, cachedValue);
    },
  );

  test(
    "When calling 'updateAppThemeMode' and passing the same as the current, it should not save in the cache",
    () async {
      await sut.updateAppThemeMode(sut.currentThemeMode);

      verifyNever(() => cache.saveThemeMode(sut.currentThemeMode));
    },
  );

  test(
    "When calling 'updateAppThemeMode' and passing a different as the current, it should save in the cache",
    () async {
      await sut.updateAppThemeMode(AppThemeMode.dark);

      verify(() => cache.saveThemeMode(AppThemeMode.dark)).called(1);
    },
  );

  test("When calling 'updateAppThemeMode' it should emit the `themeChanged` state with the new value", () async {
    expectLater(sut.stream, emitsInOrder([const AppState.themeChanged(AppThemeMode.dark)]));

    await sut.updateAppThemeMode(AppThemeMode.dark);
  });

  test("When calling 'updateAppThemeMode' it should update the `currentThemeMode` variable", () async {
    await sut.updateAppThemeMode(AppThemeMode.dark);

    expect(sut.currentThemeMode, AppThemeMode.dark);
  });
}
