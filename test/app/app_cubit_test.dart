import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/enums/networks.dart';

import '../mocks.dart';

void main() {
  late AppCubit sut;
  late Wallet wallet;

  setUp(() async {
    registerFallbackValue(const ChainInfo(hexChainId: ""));
    await Web3Kit.initializeForTest();

    wallet = WalletMock();
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());

    sut = AppCubit(wallet);
  });

  test("When calling the `selectedNetwork` after initializing the cubit, it should return the initial selected network",
      () {
    expect(sut.selectedNetwork, Networks.all);
  });

  test("""When an event is emitted that the signer changed,
      and the current signer is not in the selected network,
      it should ask to change the network""", () async {
    final wallet0 = WalletMock();
    final signerStreamController = StreamController<Signer?>.broadcast();
    final signerStream = signerStreamController.stream;
    final signer = SignerMock();
    const signerNetwork = "0x7521";

    when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
    when(() => wallet0.connectedNetwork).thenAnswer((_) async => const ChainInfo(hexChainId: signerNetwork));
    when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

    final sut0 = AppCubit(wallet0)..updateAppNetwork(Networks.arbitrum);

    signerStreamController.add(signer);

    await Future.delayed(const Duration(milliseconds: 100));

    verify(
      () => wallet0.switchOrAddNetwork(
        ChainInfo(
          hexChainId: sut0.selectedNetwork.chainInfo!.hexChainId,
          chainName: sut0.selectedNetwork.chainInfo!.chainName,
          blockExplorerUrls: sut0.selectedNetwork.chainInfo!.blockExplorerUrls,
          nativeCurrency: sut0.selectedNetwork.chainInfo!.nativeCurrency,
          rpcUrls: sut0.selectedNetwork.chainInfo!.rpcUrls,
          iconsURLs: sut0.selectedNetwork.chainInfo!.iconsURLs,
        ),
      ),
    ).called(1);
  });

  test("""When an event is emitted that the signer changed,
      and the current signer is not in the selected network,
    but the current network chainInfo is null, it should not ask
    to change the network""", () async {
    final wallet0 = WalletMock();
    final signerStreamController = StreamController<Signer?>.broadcast();
    final signerStream = signerStreamController.stream;
    final signer = SignerMock();
    const signerNetwork = "0x7521";

    when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
    when(() => wallet0.connectedNetwork).thenAnswer((_) async => const ChainInfo(hexChainId: signerNetwork));
    when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

    AppCubit(wallet0).updateAppNetwork(Networks.all); // "network" with null chainInfo

    signerStreamController.add(signer);

    await Future.delayed(const Duration(milliseconds: 100));

    verifyNever(() => wallet0.switchOrAddNetwork(any()));
  });

  test("""When an event is emitted that the signer changed,
      and the current signer is in the selected network,
      it should not ask to change the network""", () async {
    final wallet0 = WalletMock();
    final signerStreamController = StreamController<Signer?>.broadcast();
    final signerStream = signerStreamController.stream;
    final signer = SignerMock();
    final signerNetwork = Networks.arbitrum.chainInfo!.hexChainId;

    when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
    when(() => wallet0.connectedNetwork).thenAnswer((_) async => ChainInfo(hexChainId: signerNetwork));
    when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

    AppCubit(wallet0).updateAppNetwork(Networks.arbitrum);

    signerStreamController.add(signer);

    await Future.delayed(const Duration(milliseconds: 100));

    verifyNever(() => wallet0.switchOrAddNetwork(any()));
  });

  test("""When an event is emitted that the signer changed,
      but the signer is null, it should not ask to change the network""", () async {
    final wallet0 = WalletMock();
    final signerStreamController = StreamController<Signer?>.broadcast();
    final signerStream = signerStreamController.stream;

    when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
    when(() => wallet0.connectedNetwork).thenAnswer((_) async => const ChainInfo(hexChainId: ""));
    when(() => wallet0.switchOrAddNetwork(any())).thenAnswer((_) async {});

    AppCubit(wallet0).updateAppNetwork(Networks.arbitrum);

    signerStreamController.add(null);

    await Future.delayed(const Duration(milliseconds: 100));

    verifyNever(() => wallet0.switchOrAddNetwork(any()));
  });

  test("When calling `updateAppNetwork` it should update the selected network variable", () async {
    sut.updateAppNetwork(Networks.base);

    expect(sut.selectedNetwork, Networks.base);
  });

  test("""When calling `updateAppNetwork` it should emit the state `networkChanged` with the new network
      but it should finish with the event `standard` """, () async {
    const network = Networks.base;

    expectLater(sut.stream, emitsInOrder([const AppState.networkChanged(network), const AppState.standard()]));

    sut.updateAppNetwork(network);

    expect(sut.state, const AppState.standard());
  });
}
