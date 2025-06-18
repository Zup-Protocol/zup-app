import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/core/dtos/transaction_receipt.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_state_view.abi.g.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/mixins/v4_pool_liquidity_calculations_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/v4_pool_constants.dart';

import '../mocks.dart';

class _V4PoolLiquidityCalculationsMixinWrapper with V4PoolLiquidityCalculationsMixin {}

void main() {
  late PoolService sut;
  late UniswapV4StateView stateView;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PositionManager positionManagerV3;
  late UniswapV4PositionManager positionManagerV4;
  late Signer signer;
  late YieldDto currentYield;
  late TransactionResponse transactionResponse;

  late UniswapV4StateViewImpl stateViewImpl;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late UniswapV3PositionManagerImpl positionManagerV3Impl;
  late UniswapV4PositionManagerImpl positionManagerV4Impl;
  late EthereumAbiCoder ethereumAbiCoder;

  setUp(() {
    registerFallbackValue((
      amount0Desired: BigInt.zero,
      amount0Min: BigInt.zero,
      amount1Desired: BigInt.zero,
      amount1Min: BigInt.zero,
      deadline: BigInt.zero,
      fee: BigInt.zero,
      recipient: "",
      tickLower: BigInt.zero,
      tickUpper: BigInt.zero,
      token0: "",
      token1: "",
    ));
    registerFallbackValue(SignerMock());
    registerFallbackValue(BigInt.zero);

    transactionResponse = TransactionResponseMock();
    stateView = UniswapV4StateViewMock();
    uniswapV3Pool = UniswapV3PoolMock();
    positionManagerV3 = UniswapV3PositionManagerMock();
    positionManagerV4 = UniswapV4PositionManagerMock();
    ethereumAbiCoder = EthereumAbiCoderMock();
    signer = SignerMock();

    stateViewImpl = UniswapV4StateViewImplMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    positionManagerV3Impl = UniswapV3PositionManagerImplMock();
    positionManagerV4Impl = UniswapV4PositionManagerImplMock();

    currentYield = YieldDto.fixture();

    sut = PoolService(stateView, uniswapV3Pool, positionManagerV3, positionManagerV4, ethereumAbiCoder);

    when(() => stateView.fromRpcProvider(contractAddress: any(named: "contractAddress"), rpcUrl: any(named: "rpcUrl")))
        .thenReturn(stateViewImpl);

    when(() => uniswapV3Pool.fromRpcProvider(
          contractAddress: any(named: "contractAddress"),
          rpcUrl: any(named: "rpcUrl"),
        )).thenReturn(uniswapV3PoolImpl);

    when(() => positionManagerV3.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"))).thenReturn(positionManagerV3Impl);

    when(() =>
            positionManagerV3.fromSigner(contractAddress: any(named: "contractAddress"), signer: any(named: "signer")))
        .thenReturn(positionManagerV3Impl);

    when(() =>
            positionManagerV4.fromSigner(contractAddress: any(named: "contractAddress"), signer: any(named: "signer")))
        .thenReturn(positionManagerV4Impl);

    when(() => positionManagerV4.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"))).thenReturn(positionManagerV4Impl);

    when(() => signer.address).thenAnswer((_) async => "0xS0M3_4ddr355");

    when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async => TransactionReceipt(hash: "0x123"));
    when(() => transactionResponse.hash).thenReturn("0x123");
  });

  test(
    "When calling `getPoolTick` and the pool is v4, it should use the state view contract to get it",
    () async {
      final expectedTick = BigInt.from(87654);
      when(() => stateViewImpl.getSlot0(poolId: any(named: "poolId"))).thenAnswer((_) async => (
            lpFee: BigInt.from(0),
            protocolFee: BigInt.from(0),
            sqrtPriceX96: BigInt.from(0),
            tick: expectedTick,
          ));
      final currentYield0 = currentYield.copyWith(poolType: PoolType.v4, v4StateView: "0x123");
      final result = await sut.getPoolTick(currentYield0);

      expect(result, expectedTick);
      verify(() => stateViewImpl.getSlot0(poolId: currentYield0.poolAddress)).called(1);
    },
  );

  test(
    "When calling `getPoolTick` and the pool is v3, it should use the v3 pool contract to get it",
    () async {
      final expectedTick = BigInt.from(2127);
      when(() => uniswapV3PoolImpl.slot0()).thenAnswer((_) async => (
            feeProtocol: BigInt.from(0),
            observationCardinality: BigInt.from(0),
            observationCardinalityNext: BigInt.from(0),
            observationIndex: BigInt.from(0),
            sqrtPriceX96: BigInt.from(0),
            tick: expectedTick,
            unlocked: true
          ));

      final currentYield0 = currentYield.copyWith(poolType: PoolType.v3);
      final result = await sut.getPoolTick(currentYield0);

      expect(result, expectedTick);
      verify(() => uniswapV3PoolImpl.slot0()).called(1);
    },
  );

  test(
    """when calling `sendV3PoolDepositTransaction` with token0 native,
    it should send a multicall transaction with the mint calldata and a native 
    refund calldata""",
    () async {
      const mintCalldata = "0x25";
      const refundCalldata = "0x26";

      const network = AppNetworks.mainnet;
      final currentYield0 = currentYield.copyWith(
          poolType: PoolType.v3,
          chainId: network.chainId,
          token0: TokenDto.fixture().copyWith(addresses: {
            network.chainId: EthereumConstants.zeroAddress,
          }),
          token1: TokenDto.fixture().copyWith(addresses: {
            network.chainId: "0x123",
          }));

      when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
      when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
      when(() => positionManagerV3Impl.multicall(data: any(named: "data"), ethValue: any(named: "ethValue")))
          .thenAnswer(
        (_) async => transactionResponse,
      );

      final amount0Desired = BigInt.from(100);
      final amount1Desired = BigInt.from(100);
      const deadline = Duration.zero;
      final amount0Min = BigInt.from(12);
      final amount1Min = BigInt.from(12);
      final recipient = await signer.address;
      final tickLower = BigInt.from(0);
      final tickUpper = BigInt.from(0);

      await sut.sendV3PoolDepositTransaction(
        currentYield0,
        signer,
        amount0Desired: amount0Desired,
        amount1Desired: amount1Desired,
        deadline: deadline,
        amount0Min: amount0Min,
        amount1Min: amount1Min,
        recipient: recipient,
        tickLower: tickLower,
        tickUpper: tickUpper,
      );

      verify(
        () => positionManagerV3Impl.multicall(
          data: [mintCalldata, refundCalldata],
          ethValue: any(named: "ethValue"),
        ),
      ).called(1);
    },
  );

  test(
    """when calling `sendV3PoolDepositTransaction` with token0 native, it should correctly
    pass the params to get the mint calldata, with the token0 being the wrapped native address""",
    () async {
      withClock(Clock.fixed(DateTime(2028)), () async {
        const mintCalldata = "0x25";
        const refundCalldata = "0x26";
        const token0Address = EthereumConstants.zeroAddress;
        const token1Address = "0x20172891";

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}));

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(() => positionManagerV3Impl.multicall(data: any(named: "data"), ethValue: any(named: "ethValue")))
            .thenAnswer(
          (_) async => transactionResponse,
        );

        final amount0Desired = BigInt.from(4311);
        final amount1Desired = BigInt.from(1031900);
        const deadline = Duration(days: 1);
        final amount0Min = BigInt.from(1390);
        final amount1Min = BigInt.from(432);
        final recipient = await signer.address;
        final tickLower = BigInt.from(321);
        final tickUpper = BigInt.from(1222);

        await sut.sendV3PoolDepositTransaction(
          currentYield0,
          signer,
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: deadline,
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
        );

        verify(
          () => positionManagerV3.getMintCalldata(params: (
            amount0Desired: amount0Desired,
            amount0Min: amount0Min,
            amount1Desired: amount1Desired,
            amount1Min: amount1Min,
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            fee: BigInt.from(currentYield0.feeTier),
            recipient: recipient,
            tickLower: tickLower,
            tickUpper: tickUpper,
            token0: network.wrappedNativeTokenAddress,
            token1: token1Address,
          )),
        ).called(1);
      });
    },
  );

  test(
    """when calling `sendV3PoolDepositTransaction` with token1 native, it should correctly
    pass the params to get the mint calldata, with the token1 being the wrapped native address""",
    () async {
      withClock(Clock.fixed(DateTime(2028)), () async {
        const mintCalldata = "0x25";
        const refundCalldata = "0x26";
        const token0Address = "0x20172891";
        const token1Address = EthereumConstants.zeroAddress;

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}));

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(() => positionManagerV3Impl.multicall(data: any(named: "data"), ethValue: any(named: "ethValue")))
            .thenAnswer(
          (_) async => transactionResponse,
        );

        final amount0Desired = BigInt.from(100);
        final amount1Desired = BigInt.from(31);
        const deadline = Duration.zero;
        final amount0Min = BigInt.from(320);
        final amount1Min = BigInt.from(12);
        final recipient = await signer.address;
        final tickLower = BigInt.from(32);
        final tickUpper = BigInt.from(14489);

        await sut.sendV3PoolDepositTransaction(
          currentYield0,
          signer,
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: deadline,
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
        );

        verify(
          () => positionManagerV3.getMintCalldata(params: (
            amount0Desired: amount0Desired,
            amount0Min: amount0Min,
            amount1Desired: amount1Desired,
            amount1Min: amount1Min,
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            fee: BigInt.from(currentYield0.feeTier),
            recipient: recipient,
            tickLower: tickLower,
            tickUpper: tickUpper,
            token0: token0Address,
            token1: network.wrappedNativeTokenAddress,
          )),
        ).called(1);
      });
    },
  );

  test(
    """when calling `sendV3PoolDepositTransaction` with token0 native, it should correctly
  send the token0amount as ethValue""",
    () async {
      withClock(Clock.fixed(DateTime(2028)), () async {
        const mintCalldata = "0x25";
        const refundCalldata = "0x26";
        const token0Address = EthereumConstants.zeroAddress;
        const token1Address = "0x20172891";

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}));

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(() => positionManagerV3Impl.multicall(data: any(named: "data"), ethValue: any(named: "ethValue")))
            .thenAnswer(
          (_) async => transactionResponse,
        );

        final amount0Desired = BigInt.from(4311);
        final amount1Desired = BigInt.from(1031900);
        const deadline = Duration(days: 1);
        final amount0Min = BigInt.from(1390);
        final amount1Min = BigInt.from(432);
        final recipient = await signer.address;
        final tickLower = BigInt.from(321);
        final tickUpper = BigInt.from(1222);

        await sut.sendV3PoolDepositTransaction(
          currentYield0,
          signer,
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: deadline,
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
        );

        verify(
          () => positionManagerV3Impl.multicall(ethValue: amount0Desired, data: any(named: "data")),
        ).called(1);
      });
    },
  );

  test(
    """when calling `sendV3PoolDepositTransaction` with token1 native, it should correctly
  send the token1amount as ethValue""",
    () async {
      withClock(Clock.fixed(DateTime(2028)), () async {
        const mintCalldata = "0x25";
        const refundCalldata = "0x26";
        const token1Address = EthereumConstants.zeroAddress;
        const token0Address = "0x20172891";

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}));

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(() => positionManagerV3Impl.multicall(data: any(named: "data"), ethValue: any(named: "ethValue")))
            .thenAnswer(
          (_) async => transactionResponse,
        );

        final amount0Desired = BigInt.from(4311);
        final amount1Desired = BigInt.from(1031900);
        const deadline = Duration(days: 1);
        final amount0Min = BigInt.from(1390);
        final amount1Min = BigInt.from(432);
        final recipient = await signer.address;
        final tickLower = BigInt.from(321);
        final tickUpper = BigInt.from(1222);

        await sut.sendV3PoolDepositTransaction(
          currentYield0,
          signer,
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: deadline,
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
        );

        verify(
          () => positionManagerV3Impl.multicall(ethValue: amount1Desired, data: any(named: "data")),
        ).called(1);
      });
    },
  );

  test(
    """When calling `sendV3PoolDepositTransaction` and there is no native token,
  it should call `mint` in the v3 position manager passing the correct params""",
    () {
      withClock(Clock.fixed(DateTime(2028)), () async {
        const token1Address = "0x315768";
        const token0Address = "0x20172891";

        when(() => positionManagerV3Impl.mint(params: any(named: "params"), ethValue: any(named: "ethValue")))
            .thenAnswer(
          (_) async => transactionResponse,
        );

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
            feeTier: 3982,
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}));

        final amount0Desired = BigInt.from(4311);
        final amount1Desired = BigInt.from(1031900);
        const deadline = Duration(days: 1);
        final amount0Min = BigInt.from(1390);
        final amount1Min = BigInt.from(432);
        final recipient = await signer.address;
        final tickLower = BigInt.from(321);
        final tickUpper = BigInt.from(1222);

        await sut.sendV3PoolDepositTransaction(
          currentYield0,
          signer,
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: deadline,
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
        );

        verify(
          () => positionManagerV3Impl.mint(
            params: (
              token0: token0Address,
              token1: token1Address,
              fee: BigInt.from(currentYield0.feeTier),
              tickLower: tickLower,
              tickUpper: tickUpper,
              amount0Desired: amount0Desired,
              amount1Desired: amount1Desired,
              amount0Min: amount0Min,
              amount1Min: amount1Min,
              recipient: recipient,
              deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            ),
            ethValue: null,
          ),
        ).called(1);
      });
    },
  );

  test(
      "When calling `sendV4PoolDepositTransaction` and the token0 is native, it should encode packed the correct actions including the sweep",
      () async {
    when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
    when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
    when(
      () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
    ).thenAnswer((_) async => transactionResponse);

    const network = AppNetworks.mainnet;
    final amount0Desired = BigInt.from(4311);
    final amount1Desired = BigInt.from(1031900);
    const deadline = Duration(days: 1);
    final amount0Max = BigInt.from(4312);
    final amount1Max = BigInt.from(1031901);
    final recipient = await signer.address;
    final tickLower = BigInt.from(321);
    final tickUpper = BigInt.from(1222);
    final currentPoolTick = BigInt.from(123);
    final currentYield0 = currentYield.copyWith(
      chainId: network.chainId,
      token0: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
      token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}),
    );

    await sut.sendV4PoolDepositTransaction(
      currentYield0,
      signer,
      deadline: deadline,
      tickLower: tickLower,
      tickUpper: tickUpper,
      amount0toDeposit: amount0Desired,
      amount1ToDeposit: amount1Desired,
      maxAmount0ToDeposit: amount0Max,
      maxAmount1ToDeposit: amount1Max,
      recipient: recipient,
      currentPoolTick: currentPoolTick,
    );

    verify(() => ethereumAbiCoder.encodePacked([
          "uint8",
          "uint8",
          "uint8"
        ], [
          V4PoolConstants.mintPositionActionValue,
          V4PoolConstants.settlePairActionValue,
          V4PoolConstants.sweepActionValue
        ])).called(1);
  });

  test(
      "When calling `sendV4PoolDepositTransaction` and the token1 is native, it should encode packed the correct actions including the sweep",
      () async {
    when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
    when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
    when(
      () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
    ).thenAnswer((_) async => transactionResponse);

    const network = AppNetworks.mainnet;
    final amount0Desired = BigInt.from(4311);
    final amount1Desired = BigInt.from(1031900);
    const deadline = Duration(days: 1);
    final amount0Max = BigInt.from(4312);
    final amount1Max = BigInt.from(1031901);
    final recipient = await signer.address;
    final tickLower = BigInt.from(321);
    final tickUpper = BigInt.from(1222);
    final currentPoolTick = BigInt.from(123);
    final currentYield0 = currentYield.copyWith(
      chainId: network.chainId,
      token1: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
      token0: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}),
    );

    await sut.sendV4PoolDepositTransaction(
      currentYield0,
      signer,
      deadline: deadline,
      tickLower: tickLower,
      tickUpper: tickUpper,
      amount0toDeposit: amount0Desired,
      amount1ToDeposit: amount1Desired,
      maxAmount0ToDeposit: amount0Max,
      maxAmount1ToDeposit: amount1Max,
      recipient: recipient,
      currentPoolTick: currentPoolTick,
    );

    verify(() => ethereumAbiCoder.encodePacked([
          "uint8",
          "uint8",
          "uint8"
        ], [
          V4PoolConstants.mintPositionActionValue,
          V4PoolConstants.settlePairActionValue,
          V4PoolConstants.sweepActionValue
        ])).called(1);
  });

  test(
      "When calling `sendV4PoolDepositTransaction` and none of the tokens are native, it should not include the sweep action",
      () async {
    when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
    when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
    when(
      () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
    ).thenAnswer((_) async => transactionResponse);

    const network = AppNetworks.mainnet;
    final amount0Desired = BigInt.from(4311);
    final amount1Desired = BigInt.from(1031900);
    const deadline = Duration(days: 1);
    final amount0Max = BigInt.from(4312);
    final amount1Max = BigInt.from(1031901);
    final recipient = await signer.address;
    final tickLower = BigInt.from(321);
    final tickUpper = BigInt.from(1222);
    final currentPoolTick = BigInt.from(123);
    final currentYield0 = currentYield.copyWith(
      chainId: network.chainId,
      token0: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x2"}),
      token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x1"}),
    );

    await sut.sendV4PoolDepositTransaction(
      currentYield0,
      signer,
      deadline: deadline,
      tickLower: tickLower,
      tickUpper: tickUpper,
      amount0toDeposit: amount0Desired,
      amount1ToDeposit: amount1Desired,
      maxAmount0ToDeposit: amount0Max,
      maxAmount1ToDeposit: amount1Max,
      recipient: recipient,
      currentPoolTick: currentPoolTick,
    );

    verify(() => ethereumAbiCoder.encodePacked([
          "uint8",
          "uint8",
        ], [
          V4PoolConstants.mintPositionActionValue,
          V4PoolConstants.settlePairActionValue,
        ])).called(1);
  });

  test(
    "When calling `sendV4PoolDepositTransaction` the mint action params should be correctly encoded",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      const token0Address = "0x1";
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
      );

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(() => ethereumAbiCoder.encode([
            "tuple(address,address,int32,int24,address)",
            "int24",
            "int24",
            "uint256",
            "uint128",
            "uint128",
            "address",
            "bytes"
          ], [
            [
              token0Address,
              token1Address,
              BigInt.from(currentYield0.feeTier),
              BigInt.from(currentYield0.tickSpacing),
              currentYield0.v4Hooks,
            ],
            tickLower,
            tickUpper,
            _V4PoolLiquidityCalculationsMixinWrapper().getLiquidityForAmounts(
              _V4PoolLiquidityCalculationsMixinWrapper().getSqrtPriceAtTick(currentPoolTick),
              _V4PoolLiquidityCalculationsMixinWrapper().getSqrtPriceAtTick(tickLower),
              _V4PoolLiquidityCalculationsMixinWrapper().getSqrtPriceAtTick(tickUpper),
              amount0Desired,
              amount1Desired,
            ),
            amount0Max,
            amount1Max,
            recipient,
            EthereumConstants.emptyBytes,
          ])).called(1);
    },
  );

  test(
    "When calling `sendV4PoolDepositTransaction` the settle pair action params should be correctly encoded",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      const token0Address = "0x1";
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
      );

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(() => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address])).called(1);
    },
  );

  test(
    "When calling `sendV4PoolDepositTransaction` and the token0 is native the sweep action params should be correctly encoded",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      const token0Address = EthereumConstants.zeroAddress;
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
      );

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => ethereumAbiCoder.encode(
          ["address", "address"],
          [EthereumConstants.zeroAddress, recipient],
        ),
      ).called(1);
    },
  );

  test(
    "When calling `sendV4PoolDepositTransaction` and the token1 is native the sweep action params should be correctly encoded",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      const token0Address = "0x2";
      const token1Address = EthereumConstants.zeroAddress;
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => ethereumAbiCoder.encode(
          ["address", "address"],
          [EthereumConstants.zeroAddress, recipient],
        ),
      ).called(1);
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` and the token0 is native,
    it should send the correct unlock data to the contract to add liquidity""",
    () async {
      const actionsEncoded = "0xhvaaa";
      const mintPositionActionParamsEncoded = "0xaaaa";
      const settlePairActionParamsEncoded = "0xbbbb";
      const sweepActionParamsEncoded = "0xcccc";
      const unlockData = "0xaaaaa77777AAA";

      const token0Address = EthereumConstants.zeroAddress;
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(["uint8", "uint8", "uint8"], any())).thenReturn(actionsEncoded);
      when(() => ethereumAbiCoder.encode([
            "tuple(address,address,int32,int24,address)",
            "int24",
            "int24",
            "uint256",
            "uint128",
            "uint128",
            "address",
            "bytes"
          ], any())).thenReturn(mintPositionActionParamsEncoded);
      when(() => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address]))
          .thenReturn(settlePairActionParamsEncoded);

      when(() => ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient]))
          .thenReturn(sweepActionParamsEncoded);

      when(() => ethereumAbiCoder.encode([
            "bytes",
            "bytes[]"
          ], [
            actionsEncoded,
            [mintPositionActionParamsEncoded, settlePairActionParamsEncoded, sweepActionParamsEncoded]
          ])).thenReturn(unlockData);

      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: unlockData,
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` and the token1 is native,
    it should send the correct unlock data to the contract to add liquidity""",
    () async {
      const actionsEncoded = "0xhvaaa";
      const mintPositionActionParamsEncoded = "0xaaaa";
      const settlePairActionParamsEncoded = "0xbbbb";
      const sweepActionParamsEncoded = "0xcccc";
      const unlockData = "0xaaaaa77777AAA";

      const token1Address = EthereumConstants.zeroAddress;
      const token0Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(["uint8", "uint8", "uint8"], any())).thenReturn(actionsEncoded);
      when(() => ethereumAbiCoder.encode([
            "tuple(address,address,int32,int24,address)",
            "int24",
            "int24",
            "uint256",
            "uint128",
            "uint128",
            "address",
            "bytes"
          ], any())).thenReturn(mintPositionActionParamsEncoded);
      when(() => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address]))
          .thenReturn(settlePairActionParamsEncoded);

      when(() => ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient]))
          .thenReturn(sweepActionParamsEncoded);

      when(() => ethereumAbiCoder.encode([
            "bytes",
            "bytes[]"
          ], [
            actionsEncoded,
            [mintPositionActionParamsEncoded, settlePairActionParamsEncoded, sweepActionParamsEncoded]
          ])).thenReturn(unlockData);

      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: unlockData,
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` and none of the tokens are native,
    it should send the correct unlock data to the contract to add liquidity (without sweep)""",
    () async {
      const actionsEncoded = "0xhvaaa";
      const mintPositionActionParamsEncoded = "0xaaaa";
      const settlePairActionParamsEncoded = "0xbbbb";
      const unlockData = "0xaaaaa77777AAA";

      const token0Address = "0x1";
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(["uint8", "uint8"], any())).thenReturn(actionsEncoded);
      when(() => ethereumAbiCoder.encode([
            "tuple(address,address,int32,int24,address)",
            "int24",
            "int24",
            "uint256",
            "uint128",
            "uint128",
            "address",
            "bytes"
          ], any())).thenReturn(mintPositionActionParamsEncoded);
      when(() => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address]))
          .thenReturn(settlePairActionParamsEncoded);

      when(() => ethereumAbiCoder.encode([
            "bytes",
            "bytes[]"
          ], [
            actionsEncoded,
            [mintPositionActionParamsEncoded, settlePairActionParamsEncoded]
          ])).thenReturn(unlockData);

      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: unlockData,
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
      ).called(1);
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` it should send the correct deadline to the contract to add liquidity
    (now + deadline)""",
    () async {
      withClock(Clock(() => DateTime(2022, 1, 1)), () async {
        const token0Address = "0x1";
        const token1Address = "0x2";
        const network = AppNetworks.mainnet;
        final amount0Desired = BigInt.from(4311);
        final amount1Desired = BigInt.from(1031900);
        const deadline = Duration(days: 1);
        final amount0Max = BigInt.from(4312);
        final amount1Max = BigInt.from(1031901);
        final recipient = await signer.address;
        final tickLower = BigInt.from(321);
        final tickUpper = BigInt.from(1222);
        final currentPoolTick = BigInt.from(123);
        final currentYield0 = currentYield.copyWith(
          chainId: network.chainId,
          token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
        when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

        when(
          () => positionManagerV4Impl.modifyLiquidities(
              unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
        ).thenAnswer((_) async => transactionResponse);

        await sut.sendV4PoolDepositTransaction(
          currentYield0,
          signer,
          deadline: deadline,
          tickLower: tickLower,
          tickUpper: tickUpper,
          amount0toDeposit: amount0Desired,
          amount1ToDeposit: amount1Desired,
          maxAmount0ToDeposit: amount0Max,
          maxAmount1ToDeposit: amount1Max,
          recipient: recipient,
          currentPoolTick: currentPoolTick,
        );

        verify(
          () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"),
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            ethValue: any(named: "ethValue"),
          ),
        ).called(1);
      });
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` and none of the tokens are native, it should not send any eth value""",
    () async {
      const token0Address = "0x1";
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: null,
        ),
      ).called(1);
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` and the token0 is native, it should send the eth value from the 
    token0amount""",
    () async {
      const token0Address = EthereumConstants.zeroAddress;
      const token1Address = "0x2";
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: amount0Desired,
        ),
      ).called(1);
    },
  );

  test(
    """When calling `sendV4PoolDepositTransaction` and the token1 is native, it should send the eth value from the 
    token1amount""",
    () async {
      const token0Address = "0x1";
      const token1Address = EthereumConstants.zeroAddress;
      const network = AppNetworks.mainnet;
      final amount0Desired = BigInt.from(4311);
      final amount1Desired = BigInt.from(1031900);
      const deadline = Duration(days: 1);
      final amount0Max = BigInt.from(4312);
      final amount1Max = BigInt.from(1031901);
      final recipient = await signer.address;
      final tickLower = BigInt.from(321);
      final tickUpper = BigInt.from(1222);
      final currentPoolTick = BigInt.from(123);
      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

      when(
        () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"), deadline: any(named: "deadline"), ethValue: any(named: "ethValue")),
      ).thenAnswer((_) async => transactionResponse);

      await sut.sendV4PoolDepositTransaction(
        currentYield0,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0Desired,
        amount1ToDeposit: amount1Desired,
        maxAmount0ToDeposit: amount0Max,
        maxAmount1ToDeposit: amount1Max,
        recipient: recipient,
        currentPoolTick: currentPoolTick,
      );

      verify(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: amount1Desired,
        ),
      ).called(1);
    },
  );
}
