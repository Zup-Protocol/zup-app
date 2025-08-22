import 'package:clock/clock.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/aerodrome_v3_pool.abi.g.dart';
import 'package:zup_app/abis/aerodrome_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/algebra/v1.2.1/pool.abi.g.dart' as algebra_1_2_1_pool;
import 'package:zup_app/abis/algebra/v1.2.1/position_manager.abi.g.dart' as algebra_1_2_1_position_manager;
import 'package:zup_app/abis/pancake_swap_infinity_cl_pool_manager.abi.g.dart';
import 'package:zup_app/abis/pancake_swap_infinity_cl_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v4_state_view.abi.g.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/mixins/v4_pool_liquidity_calculations_mixin.dart';
import 'package:zup_app/core/v4_pool_constants.dart';

class PoolService with V4PoolLiquidityCalculationsMixin {
  final UniswapV4StateView _uniswapV4StateView;
  final UniswapV3Pool _uniswapV3Pool;
  final UniswapV3PositionManager _uniswapV3PositionManager;
  final UniswapV4PositionManager _uniswapV4PositionManager;
  final EthereumAbiCoder _ethereumAbiCoder;
  final PancakeSwapInfinityClPoolManager _pancakeSwapInfinityClPoolManager;
  final PancakeSwapInfinityClPositionManager _pancakeSwapInfinityClPositionManager;
  final AerodromeV3PositionManager _aerodromeV3PositionManager;
  final AerodromeV3Pool _aerodromeV3Pool;
  final algebra_1_2_1_pool.Pool _algebra121Pool;
  final algebra_1_2_1_position_manager.PositionManager _algebra121PositionManager;

  PoolService(
    this._uniswapV4StateView,
    this._uniswapV3Pool,
    this._uniswapV3PositionManager,
    this._uniswapV4PositionManager,
    this._ethereumAbiCoder,
    this._pancakeSwapInfinityClPoolManager,
    this._pancakeSwapInfinityClPositionManager,
    this._aerodromeV3PositionManager,
    this._aerodromeV3Pool,
    this._algebra121Pool,
    this._algebra121PositionManager,
  );

  Future<BigInt> getPoolTick(YieldDto forYield) async {
    if (forYield.protocol.id.isGLiquidV3) {
      final algebraPool = _algebra121Pool.fromRpcProvider(
        contractAddress: forYield.poolAddress,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await algebraPool.globalState()).tick;
    }

    if (forYield.protocol.id.isPancakeSwapInfinityCL) {
      final pancakeSwapInfinityCLPoolManagerContract = _pancakeSwapInfinityClPoolManager.fromRpcProvider(
        contractAddress: forYield.v4PoolManager!,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await pancakeSwapInfinityCLPoolManagerContract.getSlot0(id: forYield.poolAddress)).tick;
    }

    if (forYield.protocol.id.isAerodromeOrVelodromeSlipstream) {
      final aerodromeV3Pool = _aerodromeV3Pool.fromRpcProvider(
        contractAddress: forYield.poolAddress,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await aerodromeV3Pool.slot0()).tick;
    }

    if (forYield.poolType.isV4) {
      final stateView = _uniswapV4StateView.fromRpcProvider(
        contractAddress: forYield.v4StateView!,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await stateView.getSlot0(poolId: forYield.poolAddress)).tick;
    }

    final uniswapV3Pool = _uniswapV3Pool.fromRpcProvider(
      contractAddress: forYield.poolAddress,
      rpcUrl: forYield.network.rpcUrl,
    );

    return (await uniswapV3Pool.slot0()).tick;
  }

  Future<BigInt> getSqrtPriceX96(YieldDto forYield) async {
    if (forYield.protocol.id.isPancakeSwapInfinityCL) {
      final pancakeSwapInfinityCLPoolManagerContract = _pancakeSwapInfinityClPoolManager.fromRpcProvider(
        contractAddress: forYield.v4PoolManager!,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await pancakeSwapInfinityCLPoolManagerContract.getSlot0(id: forYield.poolAddress)).sqrtPriceX96;
    }

    if (forYield.protocol.id.isGLiquidV3) {
      final algebraPool = _algebra121Pool.fromRpcProvider(
        contractAddress: forYield.poolAddress,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await algebraPool.globalState()).price;
    }

    if (forYield.protocol.id.isAerodromeOrVelodromeSlipstream) {
      final aerodromeV3Pool = _aerodromeV3Pool.fromRpcProvider(
        contractAddress: forYield.poolAddress,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await aerodromeV3Pool.slot0()).sqrtPriceX96;
    }

    if (forYield.poolType.isV4) {
      final stateView = _uniswapV4StateView.fromRpcProvider(
        contractAddress: forYield.v4StateView!,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await stateView.getSlot0(poolId: forYield.poolAddress)).sqrtPriceX96;
    }

    if (forYield.poolType.isV3) {
      final uniswapV3Pool = _uniswapV3Pool.fromRpcProvider(
        contractAddress: forYield.poolAddress,
        rpcUrl: forYield.network.rpcUrl,
      );

      return (await uniswapV3Pool.slot0()).sqrtPriceX96;
    }

    throw Exception('Unknown pool type; Cannot get sqrtPriceX96');
  }

  Future<TransactionResponse> sendV3PoolDepositTransaction(
    YieldDto depositOnYield,
    Signer signer, {
    required BigInt amount0Desired,
    required BigInt amount1Desired,
    required Duration deadline,
    required BigInt amount0Min,
    required BigInt amount1Min,
    required String recipient,
    required BigInt tickLower,
    required BigInt tickUpper,
  }) async {
    if (depositOnYield.protocol.id.isAerodromeOrVelodromeSlipstream) {
      return _sendV3DepositTransactionForSlipstream(
        depositOnYield,
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
    }

    if (depositOnYield.protocol.id.isGLiquidV3) {
      return _sendV3DepositTransactionForAlgebra121(
        depositOnYield,
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
    }

    final v3PositionManagerContract = _uniswapV3PositionManager.fromSigner(
      contractAddress: depositOnYield.positionManagerAddress,
      signer: signer,
    );

    final TransactionResponse tx = await () async {
      if (depositOnYield.isToken1Native || depositOnYield.isToken0Native) {
        final mintCalldata = _uniswapV3PositionManager.getMintCalldata(
          params: (
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: recipient,
            tickLower: tickLower,
            tickUpper: tickUpper,
            fee: BigInt.from(depositOnYield.initialFeeTier),
            token0: _getNativeV3PoolToken0Address(depositOnYield),
            token1: _getNativeV3PoolToken1Address(depositOnYield),
          ),
        );

        return await v3PositionManagerContract.multicall(
          data: [mintCalldata, _uniswapV3PositionManager.getRefundETHCalldata()],
          ethValue: () {
            if (depositOnYield.isToken0Native) {
              return amount0Desired;
            }

            return amount1Desired;
          }.call(),
        );
      }

      return await v3PositionManagerContract.mint(
        params: (
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
          fee: BigInt.from(depositOnYield.initialFeeTier),
          token0: depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
          token1: depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
        ),
      );
    }.call();

    return tx;
  }

  Future<TransactionResponse> sendV4PoolDepositTransaction(
    YieldDto depositOnYield,
    Signer signer, {
    required Duration deadline,
    required BigInt tickLower,
    required BigInt tickUpper,
    required BigInt amount0toDeposit,
    required BigInt amount1ToDeposit,
    required BigInt maxAmount0ToDeposit,
    required BigInt maxAmount1ToDeposit,
    required String recipient,
  }) async {
    if (depositOnYield.protocol.id.isPancakeSwapInfinityCL) {
      return _sendV4PoolDepositTransactionForPancakeSwap(
        depositOnYield,
        signer,
        deadline: deadline,
        tickLower: tickLower,
        tickUpper: tickUpper,
        amount0toDeposit: amount0toDeposit,
        amount1ToDeposit: amount1ToDeposit,
        maxAmount0ToDeposit: maxAmount0ToDeposit,
        maxAmount1ToDeposit: maxAmount1ToDeposit,
        recipient: recipient,
      );
    }

    final isNativeDeposit = depositOnYield.isToken0Native || depositOnYield.isToken1Native;
    final sqrtPriceX96 = await getSqrtPriceX96(depositOnYield);
    final sqrtPriceAX96 = getSqrtPriceAtTick(tickLower);
    final sqrtPriceBX96 = getSqrtPriceAtTick(tickUpper);
    final liquidity = getLiquidityForAmounts(
      sqrtPriceX96,
      sqrtPriceAX96,
      sqrtPriceBX96,
      amount0toDeposit,
      amount1ToDeposit,
    );

    final actions = _ethereumAbiCoder.encodePacked(
      ["uint8", "uint8", if (isNativeDeposit) "uint8"],
      [
        V4PoolConstants.mintPositionActionValue,
        V4PoolConstants.uniswapSettlePairActionValue,
        if (isNativeDeposit) V4PoolConstants.uniswapSweepActionValue,
      ],
    );

    final mintPositionActionParams = _ethereumAbiCoder.encode(
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
          depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
          depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
          BigInt.from(depositOnYield.initialFeeTier),
          BigInt.from(depositOnYield.tickSpacing),
          depositOnYield.v4Hooks,
        ],
        tickLower,
        tickUpper,
        liquidity,
        depositOnYield.isToken0Native ? amount0toDeposit : maxAmount0ToDeposit,
        depositOnYield.isToken1Native ? amount1ToDeposit : maxAmount1ToDeposit,
        recipient,
        EthereumConstants.emptyBytes,
      ],
    );

    final settlePairActionParams = _ethereumAbiCoder.encode(
      ["address", "address"],
      [
        depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
        depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
      ],
    );

    final sweepActionParams = isNativeDeposit
        ? _ethereumAbiCoder.encode(["address", "address"], [EthereumConstants.zeroAddress, recipient])
        : null;

    final uniswapV4PositionManagerContract = _uniswapV4PositionManager.fromSigner(
      contractAddress: depositOnYield.positionManagerAddress,
      signer: signer,
    );

    final params = [mintPositionActionParams, settlePairActionParams, if (isNativeDeposit) sweepActionParams];

    final unlockData = _ethereumAbiCoder.encode(["bytes", "bytes[]"], [actions, params]);

    return await uniswapV4PositionManagerContract.modifyLiquidities(
      deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
      unlockData: unlockData,
      ethValue: () {
        if (!isNativeDeposit) return null;
        if (depositOnYield.isToken0Native) return amount0toDeposit;

        return amount1ToDeposit;
      }.call(),
    );
  }

  Future<TransactionResponse> _sendV4PoolDepositTransactionForPancakeSwap(
    YieldDto depositOnYield,
    Signer signer, {
    required Duration deadline,
    required BigInt tickLower,
    required BigInt tickUpper,
    required BigInt amount0toDeposit,
    required BigInt amount1ToDeposit,
    required BigInt maxAmount0ToDeposit,
    required BigInt maxAmount1ToDeposit,
    required String recipient,
  }) async {
    final isNativeDeposit = depositOnYield.isToken0Native || depositOnYield.isToken1Native;
    final sqrtPriceX96 = await getSqrtPriceX96(depositOnYield);
    final sqrtPriceAX96 = getSqrtPriceAtTick(tickLower);
    final sqrtPriceBX96 = getSqrtPriceAtTick(tickUpper);
    final liquidity = getLiquidityForAmounts(
      sqrtPriceX96,
      sqrtPriceAX96,
      sqrtPriceBX96,
      amount0toDeposit,
      amount1ToDeposit,
    );

    final actions = _ethereumAbiCoder.encodePacked(
      ["uint8", "uint8", "uint8"],
      [
        V4PoolConstants.mintPositionActionValue,
        V4PoolConstants.pancakeSwapCloseCurrencyActionValue,
        V4PoolConstants.pancakeSwapCloseCurrencyActionValue,
      ],
    );

    final mintPositionActionParams = _ethereumAbiCoder.encode(
      [
        "tuple(address,address,address,address,uint24,bytes32)",
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
          depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
          depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
          depositOnYield.v4Hooks,
          depositOnYield.v4PoolManager,
          depositOnYield.initialFeeTier,
          await _getPancakeSwapInfinityPoolBytesParameters(depositOnYield),
        ],
        tickLower,
        tickUpper,
        liquidity,
        depositOnYield.isToken0Native ? amount0toDeposit : maxAmount0ToDeposit,
        depositOnYield.isToken1Native ? amount1ToDeposit : maxAmount1ToDeposit,
        recipient,
        EthereumConstants.emptyBytes,
      ],
    );

    final closeCurrency0ActionParams = _ethereumAbiCoder.encode(
      ["address"],
      [depositOnYield.token0.addresses[depositOnYield.network.chainId]!],
    );

    final closeCurrency1ActionParams = _ethereumAbiCoder.encode(
      ["address"],
      [depositOnYield.token1.addresses[depositOnYield.network.chainId]!],
    );

    final pancakeSwapV4PositionManagerContract = _pancakeSwapInfinityClPositionManager.fromSigner(
      contractAddress: depositOnYield.positionManagerAddress,
      signer: signer,
    );

    final params = [mintPositionActionParams, closeCurrency0ActionParams, closeCurrency1ActionParams];
    final payloadData = _ethereumAbiCoder.encode(["bytes", "bytes[]"], [actions, params]);

    return await pancakeSwapV4PositionManagerContract.modifyLiquidities(
      deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
      payload: payloadData,
      ethValue: () {
        if (!isNativeDeposit) return null;
        if (depositOnYield.isToken0Native) return amount0toDeposit;

        return amount1ToDeposit;
      }.call(),
    );
  }

  Future<TransactionResponse> _sendV3DepositTransactionForAlgebra121(
    YieldDto depositOnYield,
    Signer signer, {
    required BigInt amount0Desired,
    required BigInt amount1Desired,
    required Duration deadline,
    required BigInt amount0Min,
    required BigInt amount1Min,
    required String recipient,
    required BigInt tickLower,
    required BigInt tickUpper,
  }) async {
    final positionManagerContract = _algebra121PositionManager.fromSigner(
      contractAddress: depositOnYield.positionManagerAddress,
      signer: signer,
    );
    final TransactionResponse tx = await () async {
      if (depositOnYield.isToken1Native || depositOnYield.isToken0Native) {
        final mintCalldata = _algebra121PositionManager.getMintCalldata(
          params: (
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: recipient,
            tickLower: tickLower,
            tickUpper: tickUpper,
            deployer: depositOnYield.deployerAddress,
            token0: _getNativeV3PoolToken0Address(depositOnYield),
            token1: _getNativeV3PoolToken1Address(depositOnYield),
          ),
        );

        return await positionManagerContract.multicall(
          data: [mintCalldata, _algebra121PositionManager.getRefundNativeTokenCalldata()],
          ethValue: () {
            if (depositOnYield.isToken0Native) return amount0Desired;

            return amount1Desired;
          }.call(),
        );
      }

      return await positionManagerContract.mint(
        params: (
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
          deployer: depositOnYield.deployerAddress,
          token0: depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
          token1: depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
        ),
      );
    }.call();

    return tx;
  }

  Future<TransactionResponse> _sendV3DepositTransactionForSlipstream(
    YieldDto depositOnYield,
    Signer signer, {
    required BigInt amount0Desired,
    required BigInt amount1Desired,
    required Duration deadline,
    required BigInt amount0Min,
    required BigInt amount1Min,
    required String recipient,
    required BigInt tickLower,
    required BigInt tickUpper,
  }) async {
    final aerodromeV3PositionManager = _aerodromeV3PositionManager.fromSigner(
      contractAddress: depositOnYield.positionManagerAddress,
      signer: signer,
    );

    final TransactionResponse tx = await () async {
      if (depositOnYield.isToken1Native || depositOnYield.isToken0Native) {
        final mintCalldata = _aerodromeV3PositionManager.getMintCalldata(
          params: (
            amount0Desired: amount0Desired,
            amount1Desired: amount1Desired,
            deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
            amount0Min: amount0Min,
            amount1Min: amount1Min,
            recipient: recipient,
            tickLower: tickLower,
            tickUpper: tickUpper,
            tickSpacing: BigInt.from(depositOnYield.tickSpacing),
            sqrtPriceX96: BigInt.from(0),
            token0: _getNativeV3PoolToken0Address(depositOnYield),
            token1: _getNativeV3PoolToken1Address(depositOnYield),
          ),
        );

        return await aerodromeV3PositionManager.multicall(
          data: [mintCalldata, _aerodromeV3PositionManager.getRefundETHCalldata()],
          ethValue: () {
            if (depositOnYield.isToken0Native) return amount0Desired;
            return amount1Desired;
          }.call(),
        );
      }

      return await aerodromeV3PositionManager.mint(
        params: (
          amount0Desired: amount0Desired,
          amount1Desired: amount1Desired,
          deadline: BigInt.from(clock.now().add(deadline).millisecondsSinceEpoch),
          amount0Min: amount0Min,
          amount1Min: amount1Min,
          recipient: recipient,
          tickLower: tickLower,
          tickUpper: tickUpper,
          tickSpacing: BigInt.from(depositOnYield.tickSpacing),
          sqrtPriceX96: BigInt.from(0),
          token0: depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
          token1: depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
        ),
      );
    }.call();

    return tx;
  }

  String _getNativeV3PoolToken0Address(YieldDto forYield) {
    if (forYield.isToken0Native) return forYield.network.wrappedNativeTokenAddress;
    return forYield.token0.addresses[forYield.network.chainId]!;
  }

  String _getNativeV3PoolToken1Address(YieldDto forYield) {
    if (forYield.isToken1Native) return forYield.network.wrappedNativeTokenAddress;
    return forYield.token1.addresses[forYield.network.chainId]!;
  }

  Future<String> _getPancakeSwapInfinityPoolBytesParameters(YieldDto forYield) async {
    final contract = _pancakeSwapInfinityClPoolManager.fromRpcProvider(
      contractAddress: forYield.v4PoolManager!,
      rpcUrl: forYield.network.rpcUrl,
    );

    return (await contract.poolIdToPoolKey(id: forYield.poolAddress)).parameters;
  }
}
