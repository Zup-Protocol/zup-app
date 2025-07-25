import 'dart:async';

import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/create/deposit/widgets/token_amount_input_card/token_amount_input_card_user_balance_cubit.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_core/zup_core.dart';

import '../../../../../mocks.dart';

void main() {
  late Wallet wallet;
  late Signer signer;
  const userBalance = 12.1;
  const String tokenAddress = "0x12346789";

  setUp(() async {
    wallet = WalletMock();
    signer = SignerMock();

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => signer.address).thenAnswer((_) => Future.value("0xS0M3_4ddr355"));
  });

  tearDown(() async {
    await ZupSingletonCache.shared.clear();
    resetMocktailState();
  });

  test(
    """When instanciating the cubit,
    it should start to listening for signer changes.
    If the signer changes to a non-null value,
    it should get the user token balance and emit
    the show balance state with the user token balance.
    """,
    () async {
      final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
      final Stream<Signer?> signerStream = signerStreamController0.stream;

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => signerStream);
      when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
      when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
          .thenAnswer((_) => Future.value(12.1));

      final sut0 = TokenAmountCardUserBalanceCubit(
        wallet,
        tokenAddress,
        AppNetworks.sepolia,
        ZupSingletonCache.shared,
        () {},
      );

      signerStreamController0.add(signer);

      await Future.delayed(const Duration(milliseconds: 0)); // Needed to wait for the stream to emit

      verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
      expect(sut0.state, const TokenAmountCardUserBalanceState.showUserBalance(userBalance));
    },
  );

  test(
    """When instanciating the cubit,
    it should start to listening for signer changes.
    If the signer changes to a null value,
    it should emit the hide balance state.
    """,
    () async {
      final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
      final Stream<Signer?> signerStream = signerStreamController0.stream;

      when(() => wallet.signer).thenReturn(signer);
      when(() => wallet.signerStream).thenAnswer((_) => signerStream);
      when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
      when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

      final sut0 = TokenAmountCardUserBalanceCubit(
        wallet,
        tokenAddress,
        AppNetworks.sepolia,
        ZupSingletonCache.shared,
        () {},
      );

      await Future.delayed(const Duration(milliseconds: 0)); // Needed to wait for the creation
      signerStreamController0.add(null);

      await Future.delayed(const Duration(milliseconds: 0)); // Needed to wait for the stream to emit
      expect(sut0.state, const TokenAmountCardUserBalanceState.hideUserBalance());
    },
  );

  test("When calling `getUserTokenAmount`, it should first emit the loading state", () async {
    final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
    final Stream<Signer?> signerStream = signerStreamController0.stream;

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => signerStream);
    when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    await Future.delayed(const Duration(milliseconds: 0)); // Needed to wait for the creation

    // expectLater(sut0.stream, emits(const TokenAmountCardUserBalanceState.loadingUserBalance()));

    await sut0.getUserTokenAmount();
  });

  test("When calling `getUserTokenAmount`, it should use the wallet class to get the user token balance", () async {
    final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
    final Stream<Signer?> signerStream = signerStreamController0.stream;

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => signerStream);
    when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    await sut0.getUserTokenAmount();

    verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
  });

  test("""
  When calling `getUserTokenAmount` it should use the zup singleton cache
  to get the user token balance, with a 10 minutes expiration time.
  If 10 minutes did not pass, it should not get the user token balance again.
""", () async {
    final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
    final Stream<Signer?> signerStream = signerStreamController0.stream;

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => signerStream);
    when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    const expectedUserBalance = userBalance;
    const notExpectedUserBalance = 42891.1;

    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
        .thenAnswer((_) => Future.value(expectedUserBalance));
    await sut0.getUserTokenAmount();

    when(() => wallet.tokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
        .thenAnswer((_) => Future.value(notExpectedUserBalance));
    await sut0.getUserTokenAmount();

    verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
    expect(sut0.state, const TokenAmountCardUserBalanceState.showUserBalance(expectedUserBalance));
  });

  test("""
  When calling `getUserTokenAmount` it should use the zup singleton cache
  to get the user token balance, with a 10 minutes expiration time.
  If 10 minutes pass, it should get the user token balance again.
""", () async {
    final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
    final Stream<Signer?> signerStream = signerStreamController0.stream;

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => signerStream);
    when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    const expectedUserBalance = 4311.322;
    const notExpectedUserBalance = userBalance;

    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
        .thenAnswer((_) => Future.value(notExpectedUserBalance));
    await sut0.getUserTokenAmount();

    await withClock(Clock(() => DateTime.now().add(const Duration(minutes: 11))), () async {
      when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
          .thenAnswer((_) => Future.value(expectedUserBalance));
      await sut0.getUserTokenAmount();

      verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).called(2);
      expect(sut0.state, const TokenAmountCardUserBalanceState.showUserBalance(expectedUserBalance));
    });
  });

  test("""
  When calling `getUserTokenAmount` with `ignoreCache` param true,
  it should get the user token balance again. Does not matter
  the expiration time
""", () async {
    final StreamController<Signer?> signerStreamController0 = StreamController.broadcast();
    final Stream<Signer?> signerStream = signerStreamController0.stream;

    when(() => wallet.signer).thenReturn(signer);
    when(() => wallet.signerStream).thenAnswer((_) => signerStream);
    when(() => signer.address).thenAnswer((_) => Future.value("0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c"));
    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    const expectedUserBalance = 4311.322;
    const notExpectedUserBalance = userBalance;

    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
        .thenAnswer((_) => Future.value(notExpectedUserBalance));
    await sut0.getUserTokenAmount();

    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
        .thenAnswer((_) => Future.value(expectedUserBalance));
    await sut0.getUserTokenAmount(ignoreCache: true);

    verify(() => wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).called(2);
    expect(sut0.state, const TokenAmountCardUserBalanceState.showUserBalance(expectedUserBalance));
  });

  test("when calling `updateToken` and the signer is not null, it should get the user token balance again", () async {
    const tokenAddress = "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c";
    const newTokenAddress = "0x62AC6B9dE0cD4d7FbCfB8BbBbBbBbBbBbBbBbBbB";

    when(() => wallet.signer).thenReturn(signer);
    when(() => signer.address).thenAnswer((_) => Future.value("0xS0M3_4ddr355"));
    when(() => wallet.signerStream).thenAnswer((_) => Stream.value(signer));
    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    await Future.delayed(const Duration(seconds: 0));

    await sut0.updateTokenAndNetwork(newTokenAddress, AppNetworks.sepolia, asNativeToken: false);

    verify(() => wallet.nativeOrTokenBalance(newTokenAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
  });

  test("when calling `updateToken` and the signer is null, it should not get the user token balance again", () async {
    const tokenAddress = "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c";
    const newTokenAddress = "0x62AC6B9dE0cD4d7FbCfB8BbBbBbBbBbBbBbBbBbB";

    when(() => wallet.signer).thenReturn(null);
    when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());
    when(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl"))).thenAnswer((_) => Future.value(12.1));

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    await sut0.updateTokenAndNetwork(newTokenAddress, AppNetworks.sepolia, asNativeToken: false);

    verifyNever(() => wallet.nativeOrTokenBalance(newTokenAddress, rpcUrl: any(named: "rpcUrl")));
  });

  test(
    """When calling 'updateTokenAndNetwork' with 'asNativeToken' true,
      it should pass the address zero to wallet to get the native balance""",
    () async {
      when(() => wallet.signerStream).thenAnswer((_) => const Stream.empty());

      const tokenAddress = "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c";

      final sut0 = TokenAmountCardUserBalanceCubit(
        wallet,
        tokenAddress,
        AppNetworks.sepolia,
        ZupSingletonCache.shared,
        () {},
      );

      await sut0.updateTokenAndNetwork(tokenAddress, AppNetworks.sepolia, asNativeToken: true);

      verify(() => wallet.nativeOrTokenBalance(EthereumConstants.zeroAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
    },
  );

  test(
    """When calling 'updateNativeTokenAndFetch' it should update the is native variable
    so when a new signer is emitted it will get the native balance based on the variable.
    (isNative = true testcase)""",
    () async {
      final wallet0 = WalletMock();

      final signerStreamController = StreamController<Signer?>.broadcast();
      final signerStream = signerStreamController.stream;
      when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
      when(() => wallet0.signer).thenAnswer((_) => null);

      final sut0 = TokenAmountCardUserBalanceCubit(
        wallet0,
        "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c",
        AppNetworks.sepolia,
        ZupSingletonCache.shared,
        () {},
      );

      await sut0.updateNativeTokenAndFetch(isNative: true, network: AppNetworks.sepolia);

      when(() => wallet0.signer).thenAnswer((_) => signer);

      await ZupSingletonCache.shared.clear();
      signerStreamController.add(signer);

      await Future.delayed(const Duration(seconds: 0));

      verify(() => wallet0.nativeOrTokenBalance(EthereumConstants.zeroAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
    },
  );

  test(
    """When calling 'updateNativeTokenAndFetch' it should update the is native variable
    so when a new signer is emitted it will get the native balance based on the variable.
    (isNative = false testcase)""",
    () async {
      final wallet0 = WalletMock();
      final signerStreamController = StreamController<Signer?>.broadcast();
      final signerStream = signerStreamController.stream;
      const tokenAddress = "0x99E3CfADCD8Feecb5DdF91f88998cFfB3145F78c";

      when(() => wallet0.signerStream).thenAnswer((_) => signerStream);
      when(() => wallet0.signer).thenAnswer((_) => null);

      final sut0 = TokenAmountCardUserBalanceCubit(
        wallet0,
        tokenAddress,
        AppNetworks.sepolia,
        ZupSingletonCache.shared,
        () {},
      );

      await sut0.updateNativeTokenAndFetch(isNative: false, network: AppNetworks.sepolia);

      when(() => wallet0.signer).thenAnswer((_) => signer);

      await ZupSingletonCache.shared.clear();
      signerStreamController.add(signer);

      await Future.delayed(const Duration(seconds: 0));

      verify(() => wallet0.nativeOrTokenBalance(tokenAddress, rpcUrl: any(named: "rpcUrl"))).called(1);
    },
  );

  test("When calling 'updateNativeTokenAndFetch' and the signer is null, it should not get the user token balance",
      () async {
    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    when(() => wallet.signer).thenAnswer((_) => null);

    await sut0.updateNativeTokenAndFetch(isNative: false, network: AppNetworks.sepolia);

    verifyNever(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")));
  });

  test("When calling `updateNativeTokenAndFetch` and the signer is not null, it should get the user token balance",
      () async {
    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    when(() => wallet.signer).thenAnswer((_) => signer);

    await sut0.updateNativeTokenAndFetch(isNative: false, network: AppNetworks.sepolia);

    verify(() => wallet.nativeOrTokenBalance(any(), rpcUrl: any(named: "rpcUrl")))
        .called(2); // two times because of the initial load
  });

  test("""When calling `updateNativeTokenAndFetch`
  it should update the network variable for the one passed,
  so the next time to fetch the balance it will use the new network""", () async {
    const initialNetwork = AppNetworks.sepolia;
    const nextNetwork = AppNetworks.mainnet;
    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      initialNetwork,
      ZupSingletonCache.shared,
      () {},
    );

    when(() => wallet.signer).thenAnswer((_) => signer);

    await sut0.updateNativeTokenAndFetch(isNative: false, network: nextNetwork);

    verify(() => wallet.nativeOrTokenBalance(any(), rpcUrl: nextNetwork.rpcUrl))
        .called(2); // two times because of the initial load
  });

  test("""When calling `updateTokenAndNetwork` passsing the is native true, it should update the isNative variable,
  and when a new signer is emitted it will get the native balance""", () async {
    final signerStreamController = StreamController<Signer?>.broadcast();

    when(() => wallet.signerStream).thenAnswer((_) => signerStreamController.stream);

    final sut0 = TokenAmountCardUserBalanceCubit(
      wallet,
      tokenAddress,
      AppNetworks.sepolia,
      ZupSingletonCache.shared,
      () {},
    );

    final token = TokenDto.fixture();
    const network = AppNetworks.sepolia;

    await sut0.updateTokenAndNetwork(token.addresses[network.chainId]!, network, asNativeToken: true);

    signerStreamController.add(signer);
    await Future.delayed(const Duration(seconds: 0));

    verify(() => wallet.nativeOrTokenBalance(EthereumConstants.zeroAddress, rpcUrl: any(named: "rpcUrl")))
        .called(2); // two because of the initial load
  });
}
