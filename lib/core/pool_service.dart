import 'package:clock/clock.dart';
import 'package:web3kit/core/dtos/transaction_response.dart';
import 'package:web3kit/web3kit.dart';
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

  PoolService(
    this._uniswapV4StateView,
    this._uniswapV3Pool,
    this._uniswapV3PositionManager,
    this._uniswapV4PositionManager,
    this._ethereumAbiCoder,
  );

  Future<BigInt> getPoolTick(YieldDto forYield) async {
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
            fee: BigInt.from(depositOnYield.feeTier),
            token0: depositOnYield.token0.addresses[depositOnYield.network.chainId]! == EthereumConstants.zeroAddress
                ? depositOnYield.network.wrappedNativeTokenAddress
                : depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
            token1: depositOnYield.token1.addresses[depositOnYield.network.chainId]! == EthereumConstants.zeroAddress
                ? depositOnYield.network.wrappedNativeTokenAddress
                : depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
          ),
        );

        return await v3PositionManagerContract.multicall(
            data: [
              mintCalldata,
              _uniswapV3PositionManager.getRefundETHCalldata(),
            ],
            ethValue: () {
              if (depositOnYield.isToken0Native) {
                return amount0Desired;
              }

              return amount1Desired;
            }.call());
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
          fee: BigInt.from(depositOnYield.feeTier),
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
    required BigInt currentPoolTick,
  }) async {
    final isNativeDeposit = depositOnYield.isToken0Native || depositOnYield.isToken1Native;

    final actions = _ethereumAbiCoder.encodePacked([
      "uint8",
      "uint8",
      if (isNativeDeposit) "uint8",
    ], [
      V4PoolConstants.mintPositionActionValue,
      V4PoolConstants.settlePairActionValue,
      if (isNativeDeposit) V4PoolConstants.sweepActionValue,
    ]);

    final mintPositionActionParams = _ethereumAbiCoder.encode([
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
        depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
        depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
        BigInt.from(depositOnYield.feeTier),
        BigInt.from(depositOnYield.tickSpacing),
        depositOnYield.v4Hooks,
      ],
      tickLower,
      tickUpper,
      getLiquidityForAmounts(
        getSqrtPriceAtTick(currentPoolTick),
        getSqrtPriceAtTick(tickLower),
        getSqrtPriceAtTick(tickUpper),
        amount0toDeposit,
        amount1ToDeposit,
      ),
      maxAmount0ToDeposit,
      maxAmount1ToDeposit,
      recipient,
      EthereumConstants.emptyBytes,
    ]);

    final settlePairActionParams = _ethereumAbiCoder.encode([
      "address",
      "address"
    ], [
      depositOnYield.token0.addresses[depositOnYield.network.chainId]!,
      depositOnYield.token1.addresses[depositOnYield.network.chainId]!,
    ]);

    final sweepActionParams = isNativeDeposit
        ? _ethereumAbiCoder.encode([
            "address",
            "address"
          ], [
            EthereumConstants.zeroAddress,
            recipient,
          ])
        : null;

    final uniswapV4PositionManagerContract = _uniswapV4PositionManager.fromSigner(
      contractAddress: depositOnYield.positionManagerAddress,
      signer: signer,
    );

    final params = [
      mintPositionActionParams,
      settlePairActionParams,
      if (isNativeDeposit) sweepActionParams,
    ];

    final unlockData = _ethereumAbiCoder.encode([
      "bytes",
      "bytes[]"
    ], [
      actions,
      params,
    ]);

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
}
