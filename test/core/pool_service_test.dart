import 'package:clock/clock.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:web3kit/core/dtos/transaction_receipt.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/aerodrome_v3_pool.abi.g.dart';
import 'package:zup_app/abis/aerodrome_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/algebra/v1.2.1/pool.abi.g.dart' as algebra_1_2_1_pool;
import 'package:zup_app/abis/algebra/v1.2.1/position_manager.abi.g.dart' as algebra_1_2_1_position_manager;
import 'package:zup_app/abis/pancake_swap_infinity_cl_pool_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_state_view.abi.g.dart';
import 'package:zup_app/core/dtos/protocol_dto.dart';
import 'package:zup_app/core/dtos/token_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/pool_type.dart';
import 'package:zup_app/core/enums/protocol_id.dart';
import 'package:zup_app/core/mixins/v4_pool_liquidity_calculations_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
import 'package:zup_app/core/v4_pool_constants.dart';

import '../matchers.dart';
import '../mocks.dart';

class _V4PoolLiquidityCalculationsMixinWrapper with V4PoolLiquidityCalculationsMixin {}

void main() {
  late PoolService sut;
  late UniswapV4StateView stateView;
  late UniswapV3Pool uniswapV3Pool;
  late UniswapV3PositionManager positionManagerV3;
  late UniswapV4PositionManager positionManagerV4;
  late PancakeSwapInfinityClPoolManager pancakeSwapInfinityCLPoolManager;
  late Signer signer;
  late YieldDto currentYield;
  late TransactionResponse transactionResponse;
  late AerodromeV3PositionManager aerodromePositionManagerV3;
  late AerodromeV3Pool aerodromeV3Pool;
  late algebra_1_2_1_position_manager.PositionManager algebra121PositionManager;
  late algebra_1_2_1_pool.Pool algebra121Pool;

  late UniswapV4StateViewImpl stateViewImpl;
  late UniswapV3PoolImpl uniswapV3PoolImpl;
  late UniswapV3PositionManagerImpl positionManagerV3Impl;
  late UniswapV4PositionManagerImpl positionManagerV4Impl;
  late PancakeSwapInfinityClPoolManagerImpl pancakeSwapInfinityCLPoolManagerImpl;
  late EthereumAbiCoder ethereumAbiCoder;
  late AerodromeV3PositionManagerImpl aerodromePositionManagerV3Impl;
  late algebra_1_2_1_position_manager.PositionManagerImpl algebra121PositionManagerImpl;
  late algebra_1_2_1_pool.PoolImpl algebra121PoolImpl;
  late AerodromeV3PoolImpl aerodromeV3PoolImpl;

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
    pancakeSwapInfinityCLPoolManager = PancakeSwapInfinityCLPoolManagerMock();
    ethereumAbiCoder = EthereumAbiCoderMock();
    signer = SignerMock();
    aerodromePositionManagerV3 = AerodromeV3PositionManagerMock();
    algebra121PositionManager = Algebra121PositionManagerMock();
    algebra121Pool = Algebra121PoolMock();
    aerodromeV3Pool = AerodromeV3PoolMock();

    pancakeSwapInfinityCLPoolManagerImpl = PancakeSwapInfinityCLPoolManagerImplMock();
    stateViewImpl = UniswapV4StateViewImplMock();
    uniswapV3PoolImpl = UniswapV3PoolImplMock();
    positionManagerV3Impl = UniswapV3PositionManagerImplMock();
    positionManagerV4Impl = UniswapV4PositionManagerImplMock();
    aerodromePositionManagerV3Impl = AerodromeV3PositionManagerImplMock();
    algebra121PositionManagerImpl = Algebra121PositionManagerImplMock();
    algebra121PoolImpl = Algebra121PoolImplMock();
    aerodromeV3PoolImpl = AerodromeV3PoolImplMock();

    currentYield = YieldDto.fixture();

    sut = PoolService(
      stateView,
      uniswapV3Pool,
      positionManagerV3,
      positionManagerV4,
      ethereumAbiCoder,
      pancakeSwapInfinityCLPoolManager,
      aerodromePositionManagerV3,
      aerodromeV3Pool,
      algebra121Pool,
      algebra121PositionManager,
    );

    when(
      () => uniswapV3Pool.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"),
      ),
    ).thenReturn(uniswapV3PoolImpl);

    when(
      () => positionManagerV3.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"),
      ),
    ).thenReturn(positionManagerV3Impl);

    when(
      () => positionManagerV3.fromSigner(
        contractAddress: any(named: "contractAddress"),
        signer: any(named: "signer"),
      ),
    ).thenReturn(positionManagerV3Impl);

    when(
      () => positionManagerV4.fromSigner(
        contractAddress: any(named: "contractAddress"),
        signer: any(named: "signer"),
      ),
    ).thenReturn(positionManagerV4Impl);

    when(
      () => stateView.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"),
      ),
    ).thenReturn(stateViewImpl);

    when(
      () => positionManagerV4.fromRpcProvider(
        contractAddress: any(named: "contractAddress"),
        rpcUrl: any(named: "rpcUrl"),
      ),
    ).thenReturn(positionManagerV4Impl);

    when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
      (_) async => (
        feeProtocol: BigInt.from(0),
        observationCardinality: BigInt.from(0),
        observationCardinalityNext: BigInt.from(0),
        observationIndex: BigInt.from(0),
        sqrtPriceX96: BigInt.from(0),
        tick: BigInt.from(0),
        unlocked: true,
      ),
    );

    when(() => signer.address).thenAnswer((_) async => "0xS0M3_4ddr355");

    when(() => transactionResponse.waitConfirmation()).thenAnswer((_) async => TransactionReceipt(hash: "0x123"));
    when(() => transactionResponse.hash).thenReturn("0x123");
    when(() => stateViewImpl.getSlot0(poolId: any(named: "poolId"))).thenAnswer(
      (_) async =>
          (lpFee: BigInt.from(0), protocolFee: BigInt.from(0), sqrtPriceX96: BigInt.from(0), tick: BigInt.from(0)),
    );
  });

  test("When calling `getPoolTick` and the pool is v4, it should use the state view contract to get it", () async {
    final expectedTick = BigInt.from(87654);
    when(() => stateViewImpl.getSlot0(poolId: any(named: "poolId"))).thenAnswer(
      (_) async =>
          (lpFee: BigInt.from(0), protocolFee: BigInt.from(0), sqrtPriceX96: BigInt.from(0), tick: expectedTick),
    );
    when(() => pancakeSwapInfinityCLPoolManagerImpl.getSlot0(id: any(named: "id"))).thenAnswer(
      (_) async =>
          (lpFee: BigInt.from(0), protocolFee: BigInt.from(0), sqrtPriceX96: BigInt.from(0), tick: expectedTick),
    );
    final currentYield0 = currentYield.copyWith(poolType: PoolType.v4, v4StateView: "0x123");
    final result = await sut.getPoolTick(currentYield0);

    expect(result, expectedTick);
    verify(() => stateViewImpl.getSlot0(poolId: currentYield0.poolAddress)).called(1);
  });

  test("When calling `getPoolTick` and the pool is v3, it should use the v3 pool contract to get it", () async {
    final expectedTick = BigInt.from(2127);
    when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
      (_) async => (
        feeProtocol: BigInt.from(0),
        observationCardinality: BigInt.from(0),
        observationCardinalityNext: BigInt.from(0),
        observationIndex: BigInt.from(0),
        sqrtPriceX96: BigInt.from(0),
        tick: expectedTick,
        unlocked: true,
      ),
    );

    final currentYield0 = currentYield.copyWith(poolType: PoolType.v3);
    final result = await sut.getPoolTick(currentYield0);

    expect(result, expectedTick);
    verify(() => uniswapV3PoolImpl.slot0()).called(1);
  });

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
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x123"}),
      );

      when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
      when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
      when(
        () => positionManagerV3Impl.multicall(
          data: any(named: "data"),
          ethValue: any(named: "ethValue"),
        ),
      ).thenAnswer((_) async => transactionResponse);

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
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(
          () => positionManagerV3Impl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

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
          () => positionManagerV3.getMintCalldata(
            params: (
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
            ),
          ),
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
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(
          () => positionManagerV3Impl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

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
          () => positionManagerV3.getMintCalldata(
            params: (
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
            ),
          ),
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
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(
          () => positionManagerV3Impl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

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
          () => positionManagerV3Impl.multicall(
            ethValue: amount0Desired,
            data: any(named: "data"),
          ),
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
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => positionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => positionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
        when(
          () => positionManagerV3Impl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

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
          () => positionManagerV3Impl.multicall(
            ethValue: amount1Desired,
            data: any(named: "data"),
          ),
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

        when(
          () => positionManagerV3Impl.mint(
            params: any(named: "params"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
          feeTier: 3982,
          poolType: PoolType.v3,
          chainId: network.chainId,
          token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
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
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        poolType: PoolType.v4,
        v4StateView: "0x1",
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
      );

      verify(
        () => ethereumAbiCoder.encodePacked(
          ["uint8", "uint8", "uint8"],
          [
            V4PoolConstants.mintPositionActionValue,
            V4PoolConstants.settlePairActionValue,
            V4PoolConstants.sweepActionValue,
          ],
        ),
      ).called(1);
    },
  );

  test(
    "When calling `sendV4PoolDepositTransaction` and the token1 is native, it should encode packed the correct actions including the sweep",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
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
      );

      verify(
        () => ethereumAbiCoder.encodePacked(
          ["uint8", "uint8", "uint8"],
          [
            V4PoolConstants.mintPositionActionValue,
            V4PoolConstants.settlePairActionValue,
            V4PoolConstants.sweepActionValue,
          ],
        ),
      ).called(1);
    },
  );

  test(
    "When calling `sendV4PoolDepositTransaction` and none of the tokens are native, it should not include the sweep action",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
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
      );

      verify(
        () => ethereumAbiCoder.encodePacked(
          ["uint8", "uint8"],
          [V4PoolConstants.mintPositionActionValue, V4PoolConstants.settlePairActionValue],
        ),
      ).called(1);
    },
  );

  test("When calling `sendV4PoolDepositTransaction` the mint action params should be correctly encoded", () async {
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
    final sqrtPriceX96 = BigInt.from(2167212171927187);

    when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
    when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
    when(
      () => positionManagerV4Impl.modifyLiquidities(
        unlockData: any(named: "unlockData"),
        deadline: any(named: "deadline"),
        ethValue: any(named: "ethValue"),
      ),
    ).thenAnswer((_) async => transactionResponse);

    when(() => stateViewImpl.getSlot0(poolId: any(named: "poolId"))).thenAnswer(
      (_) async =>
          (lpFee: BigInt.from(0), protocolFee: BigInt.from(0), sqrtPriceX96: sqrtPriceX96, tick: BigInt.from(0)),
    );

    final currentYield0 = currentYield.copyWith(
      chainId: network.chainId,
      v4StateView: "0x1",
      poolType: PoolType.v4,
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
    );

    verify(
      () => ethereumAbiCoder.encode(
        [
          "tuple(address,address,int32,int24,address)",
          "int24",
          "int24",
          "uint256",
          "uint128",
          "uint128",
          "address",
          "bytes",
        ],
        [
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
            sqrtPriceX96,
            _V4PoolLiquidityCalculationsMixinWrapper().getSqrtPriceAtTick(tickLower),
            _V4PoolLiquidityCalculationsMixinWrapper().getSqrtPriceAtTick(tickUpper),
            amount0Desired,
            amount1Desired,
          ),
          amount0Max,
          amount1Max,
          recipient,
          EthereumConstants.emptyBytes,
        ],
      ),
    ).called(1);
  });

  test(
    "When calling `sendV4PoolDepositTransaction` the settle pair action params should be correctly encoded",
    () async {
      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");
      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
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
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
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
      );

      verify(
        () => ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient]),
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
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
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
      );

      verify(
        () => ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient]),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(["uint8", "uint8", "uint8"], any())).thenReturn(actionsEncoded);
      when(
        () => ethereumAbiCoder.encode([
          "tuple(address,address,int32,int24,address)",
          "int24",
          "int24",
          "uint256",
          "uint128",
          "uint128",
          "address",
          "bytes",
        ], any()),
      ).thenReturn(mintPositionActionParamsEncoded);
      when(
        () => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address]),
      ).thenReturn(settlePairActionParamsEncoded);

      when(
        () => ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient]),
      ).thenReturn(sweepActionParamsEncoded);

      when(
        () => ethereumAbiCoder.encode(
          ["bytes", "bytes[]"],
          [
            actionsEncoded,
            [mintPositionActionParamsEncoded, settlePairActionParamsEncoded, sweepActionParamsEncoded],
          ],
        ),
      ).thenReturn(unlockData);

      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(["uint8", "uint8", "uint8"], any())).thenReturn(actionsEncoded);
      when(
        () => ethereumAbiCoder.encode([
          "tuple(address,address,int32,int24,address)",
          "int24",
          "int24",
          "uint256",
          "uint128",
          "uint128",
          "address",
          "bytes",
        ], any()),
      ).thenReturn(mintPositionActionParamsEncoded);
      when(
        () => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address]),
      ).thenReturn(settlePairActionParamsEncoded);

      when(
        () => ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient]),
      ).thenReturn(sweepActionParamsEncoded);

      when(
        () => ethereumAbiCoder.encode(
          ["bytes", "bytes[]"],
          [
            actionsEncoded,
            [mintPositionActionParamsEncoded, settlePairActionParamsEncoded, sweepActionParamsEncoded],
          ],
        ),
      ).thenReturn(unlockData);

      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(["uint8", "uint8"], any())).thenReturn(actionsEncoded);
      when(
        () => ethereumAbiCoder.encode([
          "tuple(address,address,int32,int24,address)",
          "int24",
          "int24",
          "uint256",
          "uint128",
          "uint128",
          "address",
          "bytes",
        ], any()),
      ).thenReturn(mintPositionActionParamsEncoded);
      when(
        () => ethereumAbiCoder.encode(["address", "address"], [token0Address, token1Address]),
      ).thenReturn(settlePairActionParamsEncoded);

      when(
        () => ethereumAbiCoder.encode(
          ["bytes", "bytes[]"],
          [
            actionsEncoded,
            [mintPositionActionParamsEncoded, settlePairActionParamsEncoded],
          ],
        ),
      ).thenReturn(unlockData);

      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

        final currentYield0 = currentYield.copyWith(
          chainId: network.chainId,
          v4StateView: "0x1",
          poolType: PoolType.v4,
          token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
        when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

        when(
          () => positionManagerV4Impl.modifyLiquidities(
            unlockData: any(named: "unlockData"),
            deadline: any(named: "deadline"),
            ethValue: any(named: "ethValue"),
          ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

      final currentYield0 = currentYield.copyWith(
        chainId: network.chainId,
        v4StateView: "0x1",
        poolType: PoolType.v4,
        token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
        token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
      );

      when(() => ethereumAbiCoder.encodePacked(any(), any())).thenReturn("0x");
      when(() => ethereumAbiCoder.encode(any(), any())).thenReturn("0x");

      when(
        () => positionManagerV4Impl.modifyLiquidities(
          unlockData: any(named: "unlockData"),
          deadline: any(named: "deadline"),
          ethValue: any(named: "ethValue"),
        ),
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

  test(
    """"When calling `getPoolTick` and the yield protocol is pancakeswap infinity cl,
  it should use the pancakeswap inifity cl pool manager to get the tick""",
    () async {
      final expectedTick = BigInt.from(318675);

      when(
        () => pancakeSwapInfinityCLPoolManager.fromRpcProvider(
          contractAddress: any(named: "contractAddress"),
          rpcUrl: any(named: "rpcUrl"),
        ),
      ).thenReturn(pancakeSwapInfinityCLPoolManagerImpl);

      when(() => pancakeSwapInfinityCLPoolManagerImpl.getSlot0(id: any(named: "id"))).thenAnswer(
        (_) async =>
            (sqrtPriceX96: BigInt.from(0), tick: expectedTick, protocolFee: BigInt.from(0), lpFee: BigInt.from(0)),
      );

      final yield0 = currentYield.copyWith(
        protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.pancakeSwapInfinityCL),
        v4PoolManager: "0x0000001",
      );

      final receivedPoolTick = await sut.getPoolTick(yield0);
      expect(receivedPoolTick, expectedTick);

      verify(() => pancakeSwapInfinityCLPoolManagerImpl.getSlot0(id: yield0.poolAddress)).called(1);
    },
  );

  test(
    """When calling `getSqrtPriceX96` and the yield protocol is pancakeswap infinity cl,
  it should use the pancakeswap inifity cl pool manager to get the sqrtPriceX96 from the
  slot0""",
    () async {
      final expectedSqrtPriceX96 = BigInt.parse("3256723627823257362");

      final yield0 = currentYield.copyWith(
        protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.pancakeSwapInfinityCL),
        v4PoolManager: "0x0000001",
      );

      when(
        () => pancakeSwapInfinityCLPoolManager.fromRpcProvider(
          contractAddress: any(named: "contractAddress"),
          rpcUrl: any(named: "rpcUrl"),
        ),
      ).thenReturn(pancakeSwapInfinityCLPoolManagerImpl);

      when(() => pancakeSwapInfinityCLPoolManagerImpl.getSlot0(id: any(named: "id"))).thenAnswer(
        (_) async => (
          sqrtPriceX96: expectedSqrtPriceX96,
          tick: BigInt.from(0),
          protocolFee: BigInt.from(0),
          lpFee: BigInt.from(0),
        ),
      );

      final receivedSqrtPriceX96 = await sut.getSqrtPriceX96(yield0);

      expect(receivedSqrtPriceX96, expectedSqrtPriceX96);
    },
  );

  test(
    """When calling `getSqrtPriceX96` and the yield pool is v4,
  it should use the v4 state view get the sqrtPriceX96 from the
  slot0""",
    () async {
      final expectedSqrtPriceX96 = BigInt.parse("1216426515276100");

      final yield0 = currentYield.copyWith(poolType: PoolType.v4, v4StateView: "0x0000001");

      when(
        () => stateView.fromRpcProvider(
          contractAddress: any(named: "contractAddress"),
          rpcUrl: any(named: "rpcUrl"),
        ),
      ).thenReturn(stateViewImpl);

      when(() => stateViewImpl.getSlot0(poolId: any(named: "poolId"))).thenAnswer(
        (_) async => (
          sqrtPriceX96: expectedSqrtPriceX96,
          tick: BigInt.from(0),
          protocolFee: BigInt.from(0),
          lpFee: BigInt.from(0),
        ),
      );

      final receivedSqrtPriceX96 = await sut.getSqrtPriceX96(yield0);

      expect(receivedSqrtPriceX96, expectedSqrtPriceX96);
    },
  );

  test(
    """When calling `getSqrtPriceX96` and the yield pool is v3,
  it should use the pool contract get the sqrtPriceX96 from the
  slot0""",
    () async {
      final expectedSqrtPriceX96 = BigInt.parse("907219862715267517621");

      final yield0 = currentYield.copyWith(poolType: PoolType.v3, poolAddress: "0x0000001");

      when(
        () => uniswapV3Pool.fromRpcProvider(
          contractAddress: any(named: "contractAddress"),
          rpcUrl: any(named: "rpcUrl"),
        ),
      ).thenReturn(uniswapV3PoolImpl);

      when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
        (_) async => (
          feeProtocol: BigInt.from(0),
          observationCardinality: BigInt.from(0),
          observationCardinalityNext: BigInt.from(0),
          observationIndex: BigInt.from(0),
          sqrtPriceX96: expectedSqrtPriceX96,
          tick: BigInt.from(0),
          unlocked: true,
        ),
      );

      final receivedSqrtPriceX96 = await sut.getSqrtPriceX96(yield0);

      expect(receivedSqrtPriceX96, expectedSqrtPriceX96);
    },
  );

  test(
    """When calling `getSqrtPriceX96` and the yield pool type
    is unknown, it should throw an error""",
    () async {
      final yield0 = currentYield.copyWith(poolType: PoolType.unknown);

      expect(() async => await sut.getSqrtPriceX96(yield0), throwsA(isA<Exception>()));
    },
  );

  group(
    'When the protocol is aerodrome v3 or velodrome v3, it should use aerodrome smart contracts to interact with pools',
    () {
      setUp(() {
        registerFallbackValue((
          amount0Desired: BigInt.zero,
          amount0Min: BigInt.zero,
          amount1Desired: BigInt.zero,
          amount1Min: BigInt.zero,
          deadline: BigInt.zero,
          recipient: "",
          sqrtPriceX96: BigInt.zero,
          tickLower: BigInt.zero,
          tickSpacing: BigInt.zero,
          tickUpper: BigInt.zero,
          token0: "",
          token1: "",
        ));

        registerFallbackValue(YieldDto.fixture());

        when(
          () => aerodromePositionManagerV3.fromSigner(
            contractAddress: any(named: "contractAddress"),
            signer: any(named: "signer"),
          ),
        ).thenReturn(aerodromePositionManagerV3Impl);

        when(
          () => aerodromeV3Pool.fromRpcProvider(
            contractAddress: any(named: "contractAddress"),
            rpcUrl: any(named: "rpcUrl"),
          ),
        ).thenReturn(aerodromeV3PoolImpl);

        when(
          () => aerodromePositionManagerV3.getMintCalldata(params: any(named: "params")),
        ).thenReturn("0x0000000000000000000000000000000000000000000000000000000000000000");
        when(
          () => aerodromePositionManagerV3.getRefundETHCalldata(),
        ).thenReturn("0x0000000000000000000000000000000000000000000000000000000000000000");

        when(
          () => aerodromePositionManagerV3Impl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) => Future.value(transactionResponse));
      });

      test("When the protocol is aerodrome v3 it should use aerodrome v3 pool to get the pool tick", () async {
        final expectedTick = BigInt.from(1271897);

        when(() => aerodromeV3PoolImpl.slot0()).thenAnswer(
          (_) async => (
            observationCardinality: BigInt.from(0),
            observationCardinalityNext: BigInt.from(0),
            observationIndex: BigInt.from(0),
            sqrtPriceX96: BigInt.from(0),
            tick: expectedTick,
            unlocked: true,
          ),
        );

        final yield0 = currentYield.copyWith(
          protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
          poolType: PoolType.v3,
          chainId: AppNetworks.mainnet.chainId,
        );

        final receivedTick = await sut.getPoolTick(yield0);

        expect(receivedTick, expectedTick);

        verify(() => aerodromeV3PoolImpl.slot0()).called(1);
      });

      test("When the protocol is velodrome v3 it should use aerodrome v3 pool to get the pool tick", () async {
        final expectedTick = BigInt.from(11111);

        when(() => aerodromeV3PoolImpl.slot0()).thenAnswer(
          (_) async => (
            observationCardinality: BigInt.from(0),
            observationCardinalityNext: BigInt.from(0),
            observationIndex: BigInt.from(0),
            sqrtPriceX96: BigInt.from(0),
            tick: expectedTick,
            unlocked: true,
          ),
        );

        final yield0 = currentYield.copyWith(
          protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.velodromeSlipstream),
          poolType: PoolType.v3,
          chainId: AppNetworks.mainnet.chainId,
        );

        final receivedTick = await sut.getPoolTick(yield0);

        expect(receivedTick, expectedTick);

        verify(() => aerodromeV3PoolImpl.slot0()).called(1);
      });

      test(
        "when calling with token0 native, it should send a multicall transaction with the mint calldata and a native refund calldata",
        () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x123"}),
          );

          when(() => aerodromePositionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => aerodromePositionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
          when(
            () => aerodromePositionManagerV3Impl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => aerodromePositionManagerV3Impl.multicall(
              data: [mintCalldata, refundCalldata],
              ethValue: any(named: "ethValue"),
            ),
          ).called(1);
        },
      );

      test(
        "when calling with token0 native, it should correctly pass the params to get the mint calldata, with the token0 being the wrapped native address",
        () async {
          withClock(Clock.fixed(DateTime(2028)), () async {
            const mintCalldata = "0x25";
            const refundCalldata = "0x26";
            const token0Address = EthereumConstants.zeroAddress;
            const token1Address = "0x20172891";

            const network = AppNetworks.mainnet;
            final currentYield0 = currentYield.copyWith(
              protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
              poolType: PoolType.v3,
              chainId: network.chainId,
              token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
              token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
            );

            when(
              () => aerodromePositionManagerV3.getMintCalldata(params: any(named: "params")),
            ).thenReturn(mintCalldata);
            when(() => aerodromePositionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
            when(
              () => aerodromePositionManagerV3Impl.multicall(
                data: any(named: "data"),
                ethValue: any(named: "ethValue"),
              ),
            ).thenAnswer((_) async => transactionResponse);

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
              () => aerodromePositionManagerV3.getMintCalldata(
                params: (
                  amount0Desired: amount0Desired,
                  amount0Min: amount0Min,
                  amount1Desired: amount1Desired,
                  amount1Min: amount1Min,
                  deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
                  recipient: recipient,
                  tickLower: tickLower,
                  tickUpper: tickUpper,
                  tickSpacing: BigInt.from(currentYield0.tickSpacing),
                  sqrtPriceX96: BigInt.from(0),
                  token0: network.wrappedNativeTokenAddress,
                  token1: token1Address,
                ),
              ),
            ).called(1);
          });
        },
      );

      test(
        "when calling with token1 native, it should correctly pass the params to get the mint calldata, with the token1 being the wrapped native address",
        () async {
          withClock(Clock.fixed(DateTime(2028)), () async {
            const mintCalldata = "0x25";
            const refundCalldata = "0x26";
            const token0Address = "0x20172891";
            const token1Address = EthereumConstants.zeroAddress;

            const network = AppNetworks.mainnet;
            final currentYield0 = currentYield.copyWith(
              protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
              poolType: PoolType.v3,
              chainId: network.chainId,
              token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
              token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
            );

            when(
              () => aerodromePositionManagerV3.getMintCalldata(params: any(named: "params")),
            ).thenReturn(mintCalldata);
            when(() => aerodromePositionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
            when(
              () => aerodromePositionManagerV3Impl.multicall(
                data: any(named: "data"),
                ethValue: any(named: "ethValue"),
              ),
            ).thenAnswer((_) async => transactionResponse);

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
              () => aerodromePositionManagerV3.getMintCalldata(
                params: (
                  amount0Desired: amount0Desired,
                  amount0Min: amount0Min,
                  amount1Desired: amount1Desired,
                  amount1Min: amount1Min,
                  deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
                  recipient: recipient,
                  tickLower: tickLower,
                  tickUpper: tickUpper,
                  tickSpacing: BigInt.from(currentYield0.tickSpacing),
                  sqrtPriceX96: BigInt.from(0),
                  token0: token0Address,
                  token1: network.wrappedNativeTokenAddress,
                ),
              ),
            ).called(1);
          });
        },
      );

      test("when calling with token0 native, it should correctly send the token0amount as ethValue", () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";
          const token0Address = EthereumConstants.zeroAddress;
          const token1Address = "0x20172891";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
          );

          when(() => aerodromePositionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => aerodromePositionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
          when(
            () => aerodromePositionManagerV3Impl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => aerodromePositionManagerV3Impl.multicall(
              ethValue: amount0Desired,
              data: any(named: "data"),
            ),
          ).called(1);
        });
      });

      test("when calling with token1 native, it should correctly send the token1amount as ethValue", () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";
          const token1Address = EthereumConstants.zeroAddress;
          const token0Address = "0x20172891";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
          );

          when(() => aerodromePositionManagerV3.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => aerodromePositionManagerV3.getRefundETHCalldata()).thenReturn(refundCalldata);
          when(
            () => aerodromePositionManagerV3Impl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => aerodromePositionManagerV3Impl.multicall(
              ethValue: amount1Desired,
              data: any(named: "data"),
            ),
          ).called(1);
        });
      });

      test(
        "When there is no native token, it should call mint in the aerodrome position manager passing the correct params",
        () async {
          withClock(Clock.fixed(DateTime(2028)), () async {
            const token1Address = "0x315768";
            const token0Address = "0x20172891";

            when(
              () => aerodromePositionManagerV3Impl.mint(
                params: any(named: "params"),
                ethValue: any(named: "ethValue"),
              ),
            ).thenAnswer((_) async => transactionResponse);

            const network = AppNetworks.mainnet;
            final currentYield0 = currentYield.copyWith(
              protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
              feeTier: 3982,
              poolType: PoolType.v3,
              chainId: network.chainId,
              token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
              token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
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
              () => aerodromePositionManagerV3Impl.mint(
                params: (
                  token0: token0Address,
                  token1: token1Address,
                  tickSpacing: BigInt.from(currentYield0.tickSpacing),
                  tickLower: tickLower,
                  tickUpper: tickUpper,
                  amount0Desired: amount0Desired,
                  amount1Desired: amount1Desired,
                  amount0Min: amount0Min,
                  amount1Min: amount1Min,
                  recipient: recipient,
                  deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
                  sqrtPriceX96: BigInt.from(0),
                ),
                ethValue: null,
              ),
            ).called(1);
          });
        },
      );

      test(
        """When the yield protocol is aerodrome v3 and the pool does not have native token,
        it should set the sqrtPriceX96 as 0 for the pool and pass it correctly to the mint function""",
        () {
          withClock(Clock.fixed(DateTime(2028)), () async {
            const token1Address = "0x315768";
            const token0Address = "0x20172891";
            final expectedSqrtPriceX96 = BigInt.from(0);

            when(
              () => aerodromePositionManagerV3Impl.mint(
                params: any(named: "params"),
                ethValue: any(named: "ethValue"),
              ),
            ).thenAnswer((_) async => transactionResponse);
            when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
              (_) async => (
                feeProtocol: BigInt.from(0),
                sqrtPriceX96: expectedSqrtPriceX96,
                tick: BigInt.from(0),
                observationIndex: BigInt.from(0),
                observationCardinality: BigInt.from(0),
                observationCardinalityNext: BigInt.from(0),
                unlocked: false,
              ),
            );

            const network = AppNetworks.mainnet;
            final currentYield0 = currentYield.copyWith(
              protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
              feeTier: 3982,
              poolType: PoolType.v3,
              chainId: network.chainId,
              token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
              token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
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
              () => aerodromePositionManagerV3Impl.mint(
                params: any(
                  named: "params",
                  that: ObjectParamMatcher((object) => object.sqrtPriceX96 == expectedSqrtPriceX96),
                ),
                ethValue: null,
              ),
            ).called(1);
          });
        },
      );

      test(
        """When the yield protocol is aerodrome v3 and the pool does have a native token,
        it should set the sqrtPriceX96 as 0 for the pool and pass it correctly to the mint calldata""",
        () {
          withClock(Clock.fixed(DateTime(2028)), () async {
            const token1Address = EthereumConstants.zeroAddress;
            const token0Address = EthereumConstants.zeroAddress;
            final expectedSqrtPriceX96 = BigInt.from(0);

            when(
              () => aerodromePositionManagerV3Impl.mint(
                params: any(named: "params"),
                ethValue: any(named: "ethValue"),
              ),
            ).thenAnswer((_) async => transactionResponse);
            when(() => uniswapV3PoolImpl.slot0()).thenAnswer(
              (_) async => (
                feeProtocol: BigInt.from(0),
                sqrtPriceX96: expectedSqrtPriceX96,
                tick: BigInt.from(0),
                observationIndex: BigInt.from(0),
                observationCardinality: BigInt.from(0),
                observationCardinalityNext: BigInt.from(0),
                unlocked: false,
              ),
            );

            const network = AppNetworks.mainnet;
            final currentYield0 = currentYield.copyWith(
              protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
              feeTier: 3982,
              poolType: PoolType.v3,
              chainId: network.chainId,
              token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
              token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
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
              () => aerodromePositionManagerV3.getMintCalldata(
                params: any(
                  named: "params",
                  that: ObjectParamMatcher((object) => object.sqrtPriceX96 == expectedSqrtPriceX96),
                ),
              ),
            ).called(1);
          });
        },
      );

      test(
        "When the protocol is aerodrome v3, it should use the aerodrome pool contract to get the sqrtPriceX96",
        () async {
          final expectedSqrtPriceX96 = BigInt.from(12718271);
          when(() => aerodromeV3PoolImpl.slot0()).thenAnswer(
            (_) async => (
              sqrtPriceX96: expectedSqrtPriceX96,
              tick: BigInt.from(0),
              observationIndex: BigInt.from(0),
              observationCardinality: BigInt.from(0),
              observationCardinalityNext: BigInt.from(0),
              unlocked: false,
            ),
          );

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.aerodromeSlipstream),
            feeTier: 3982,
            poolType: PoolType.v3,
            chainId: network.chainId,
          );

          final actualSqrtPriceX96 = await sut.getSqrtPriceX96(currentYield0);
          expect(actualSqrtPriceX96, expectedSqrtPriceX96);

          verify(() => aerodromeV3PoolImpl.slot0()).called(1);
        },
      );

      test(
        "When the protocol is velodrome v3, it should use the aerodrome pool contract to get the sqrtPriceX96",
        () async {
          final expectedSqrtPriceX96 = BigInt.from(90876543);
          when(() => aerodromeV3PoolImpl.slot0()).thenAnswer(
            (_) async => (
              sqrtPriceX96: expectedSqrtPriceX96,
              tick: BigInt.from(0),
              observationIndex: BigInt.from(0),
              observationCardinality: BigInt.from(0),
              observationCardinalityNext: BigInt.from(0),
              unlocked: false,
            ),
          );

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.velodromeSlipstream),
            feeTier: 3982,
            poolType: PoolType.v3,
            chainId: network.chainId,
          );

          final actualSqrtPriceX96 = await sut.getSqrtPriceX96(currentYield0);
          expect(actualSqrtPriceX96, expectedSqrtPriceX96);

          verify(() => aerodromeV3PoolImpl.slot0()).called(1);
        },
      );
    },
  );

  group("When the protocol is GLiquid, it should use algebra 1.2.1 smart contracts to interact with the pool", () {
    setUp(() async {
      registerFallbackValue((
        amount0Desired: BigInt.from(0),
        amount1Desired: BigInt.from(0),
        deadline: BigInt.from(0),
        amount0Min: BigInt.from(0),
        amount1Min: BigInt.from(0),
        recipient: "",
        tickLower: BigInt.from(0),
        tickUpper: BigInt.from(0),
        deployer: "",
        token0: "",
        token1: "",
      ));

      currentYield = currentYield.copyWith(protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3));
      when(
        () => algebra121Pool.fromRpcProvider(
          contractAddress: any(named: "contractAddress"),
          rpcUrl: any(named: "rpcUrl"),
        ),
      ).thenReturn(algebra121PoolImpl);

      when(
        () => algebra121PositionManager.fromSigner(
          contractAddress: any(named: "contractAddress"),
          signer: any(named: "signer"),
        ),
      ).thenReturn(algebra121PositionManagerImpl);
    });

    test("When calling 'getPoolTick' it should return the pool tick got from algebra pool 1.2.1", () async {
      final expectedTick = BigInt.from(12871);
      when(() => algebra121PoolImpl.globalState()).thenAnswer(
        (_) async => (
          price: BigInt.from(0),
          tick: expectedTick,
          lastFee: BigInt.from(0),
          pluginConfig: BigInt.from(0),
          communityFee: BigInt.from(0),
          unlocked: false,
        ),
      );

      final actualTick = await sut.getPoolTick(currentYield);

      expect(actualTick, expectedTick);

      verify(() => algebra121PoolImpl.globalState()).called(1);
    });

    test("When calling 'getSqrtPriceX96' it should return the price from algebra pool 1.2.1", () async {
      final expectedSqrtPriceX96 = BigInt.from(12617826517);

      when(() => algebra121PoolImpl.globalState()).thenAnswer(
        (_) async => (
          price: expectedSqrtPriceX96,
          tick: BigInt.from(0),
          lastFee: BigInt.from(0),
          pluginConfig: BigInt.from(0),
          communityFee: BigInt.from(0),
          unlocked: false,
        ),
      );

      final actualSqrtPriceX96 = await sut.getSqrtPriceX96(currentYield);

      expect(actualSqrtPriceX96, expectedSqrtPriceX96);

      verify(() => algebra121PoolImpl.globalState()).called(1);
    });

    test(
      "when calling with token0 native, it should send a multicall transaction with the mint calldata and a native refund calldata",
      () async {
        const mintCalldata = "0x25";
        const refundCalldata = "0x26";

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
          protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
          poolType: PoolType.v3,
          chainId: network.chainId,
          token0: TokenDto.fixture().copyWith(addresses: {network.chainId: EthereumConstants.zeroAddress}),
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: "0x123"}),
        );

        when(() => algebra121PositionManager.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => algebra121PositionManager.getRefundNativeTokenCalldata()).thenReturn(refundCalldata);
        when(
          () => algebra121PositionManagerImpl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

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
          () => algebra121PositionManagerImpl.multicall(
            data: [mintCalldata, refundCalldata],
            ethValue: any(named: "ethValue"),
          ),
        ).called(1);
      },
    );

    test(
      "when calling with token0 native, it should correctly pass the params to get the mint calldata, with the token0 being the wrapped native address",
      () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";
          const token0Address = EthereumConstants.zeroAddress;
          const token1Address = "0x20172891";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
          );

          when(() => algebra121PositionManager.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => algebra121PositionManager.getRefundNativeTokenCalldata()).thenReturn(refundCalldata);
          when(
            () => algebra121PositionManagerImpl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => algebra121PositionManager.getMintCalldata(
              params: (
                amount0Desired: amount0Desired,
                amount0Min: amount0Min,
                amount1Desired: amount1Desired,
                amount1Min: amount1Min,
                deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
                recipient: recipient,
                tickLower: tickLower,
                tickUpper: tickUpper,
                deployer: currentYield0.deployerAddress,
                token0: network.wrappedNativeTokenAddress,
                token1: token1Address,
              ),
            ),
          ).called(1);
        });
      },
    );

    test(
      "when calling with token1 native, it should correctly pass the params to get the mint calldata, with the token1 being the wrapped native address",
      () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";
          const token0Address = "0x20172891";
          const token1Address = EthereumConstants.zeroAddress;

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
          );

          when(() => algebra121PositionManager.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => algebra121PositionManager.getRefundNativeTokenCalldata()).thenReturn(refundCalldata);
          when(
            () => algebra121PositionManagerImpl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => algebra121PositionManager.getMintCalldata(
              params: (
                amount0Desired: amount0Desired,
                amount0Min: amount0Min,
                amount1Desired: amount1Desired,
                amount1Min: amount1Min,
                deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
                recipient: recipient,
                tickLower: tickLower,
                tickUpper: tickUpper,
                deployer: currentYield0.deployerAddress,
                token0: token0Address,
                token1: network.wrappedNativeTokenAddress,
              ),
            ),
          ).called(1);
        });
      },
    );

    test("when calling with token0 native, it should correctly send the token0amount as ethValue", () async {
      withClock(Clock.fixed(DateTime(2028)), () async {
        const mintCalldata = "0x25";
        const refundCalldata = "0x26";
        const token0Address = EthereumConstants.zeroAddress;
        const token1Address = "0x20172891";

        const network = AppNetworks.mainnet;
        final currentYield0 = currentYield.copyWith(
          protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
          poolType: PoolType.v3,
          chainId: network.chainId,
          token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
          token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
        );

        when(() => algebra121PositionManager.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
        when(() => algebra121PositionManager.getRefundNativeTokenCalldata()).thenReturn(refundCalldata);
        when(
          () => algebra121PositionManagerImpl.multicall(
            data: any(named: "data"),
            ethValue: any(named: "ethValue"),
          ),
        ).thenAnswer((_) async => transactionResponse);

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
          () => algebra121PositionManagerImpl.multicall(
            ethValue: amount0Desired,
            data: any(named: "data"),
          ),
        ).called(1);
      });
    });

    test(
      "when the yield has a deployer address set, and the deposit is it a native token, it should pass it to the mint calldata",
      () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";
          const token0Address = EthereumConstants.zeroAddress;
          const token1Address = "0x20172891";
          const expectedDeployer = "0xdale";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
            deployerAddress: expectedDeployer,
          );

          when(() => algebra121PositionManager.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => algebra121PositionManager.getRefundNativeTokenCalldata()).thenReturn(refundCalldata);
          when(
            () => algebra121PositionManagerImpl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => algebra121PositionManager.getMintCalldata(
              params: any(named: "params", that: ObjectParamMatcher((object) => object.deployer == expectedDeployer)),
            ),
          ).called(1);
        });
      },
    );

    test(
      "when the yield has a deployer address set, and the deposit is with erc20, it should pass it to the mint function",
      () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const token0Address = "0x123";
          const token1Address = "0x20172891";
          const expectedDeployer = "0xdalepapi";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
            deployerAddress: expectedDeployer,
          );

          when(
            () => algebra121PositionManagerImpl.mint(params: any(named: "params")),
          ).thenAnswer((_) async => transactionResponse);

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
            () => algebra121PositionManagerImpl.mint(
              params: any(named: "params", that: ObjectParamMatcher((object) => object.deployer == expectedDeployer)),
            ),
          ).called(1);
        });
      },
    );

    test(
      "when the yield has a deployer address as zero address, and the deposit is with erc20, it should pass it to the mint function",
      () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const token0Address = "0x123";
          const token1Address = "0x20172891";
          const expectedDeployer = EthereumConstants.zeroAddress;

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
            deployerAddress: expectedDeployer,
          );

          when(
            () => algebra121PositionManagerImpl.mint(params: any(named: "params")),
          ).thenAnswer((_) async => transactionResponse);

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
            () => algebra121PositionManagerImpl.mint(
              params: any(
                named: "params",
                that: ObjectParamMatcher((object) => object.deployer == EthereumConstants.zeroAddress),
              ),
            ),
          ).called(1);
        });
      },
    );

    test(
      "when the yield has a deployer address of address zero, and the deposit is it a native token, it should pass it to the mint calldata",
      () async {
        withClock(Clock.fixed(DateTime(2028)), () async {
          const mintCalldata = "0x25";
          const refundCalldata = "0x26";
          const token0Address = EthereumConstants.zeroAddress;
          const token1Address = "0x20172891";

          const network = AppNetworks.mainnet;
          final currentYield0 = currentYield.copyWith(
            protocol: ProtocolDto.fixture().copyWith(id: ProtocolId.gliquidV3),
            poolType: PoolType.v3,
            chainId: network.chainId,
            token0: TokenDto.fixture().copyWith(addresses: {network.chainId: token0Address}),
            token1: TokenDto.fixture().copyWith(addresses: {network.chainId: token1Address}),
            deployerAddress: EthereumConstants.zeroAddress,
          );

          when(() => algebra121PositionManager.getMintCalldata(params: any(named: "params"))).thenReturn(mintCalldata);
          when(() => algebra121PositionManager.getRefundNativeTokenCalldata()).thenReturn(refundCalldata);
          when(
            () => algebra121PositionManagerImpl.multicall(
              data: any(named: "data"),
              ethValue: any(named: "ethValue"),
            ),
          ).thenAnswer((_) async => transactionResponse);

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
            () => algebra121PositionManager.getMintCalldata(
              params: any(
                named: "params",
                that: ObjectParamMatcher((object) => object.deployer == EthereumConstants.zeroAddress),
              ),
            ),
          ).called(1);
        });
      },
    );
  });
}
