import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/slippage.dart';
import 'package:zup_app/core/zup_analytics.dart';
import 'package:zup_core/zup_core.dart';

part 'deposit_cubit.freezed.dart';
part 'deposit_state.dart';

class DepositCubit extends Cubit<DepositState> with KeysMixin, V3PoolConversorsMixin {
  DepositCubit(
    this._yieldRepository,
    this._zupSingletonCache,
    this._wallet,
    this._uniswapV3Pool,
    this._cache,
    this._appCubit,
    this._zupAnalytics,
  ) : super(const DepositState.initial());

  final YieldRepository _yieldRepository;
  final ZupSingletonCache _zupSingletonCache;
  final Wallet _wallet;
  final UniswapV3Pool _uniswapV3Pool;
  final Cache _cache;
  final AppCubit _appCubit;
  final ZupAnalytics _zupAnalytics;

  final StreamController<BigInt?> _pooltickStreamController = StreamController.broadcast();
  final StreamController<YieldDto?> _selectedYieldStreamController = StreamController.broadcast();

  BigInt? _latestPoolTick;
  YieldDto? _selectedYield;
  YieldTimeFrame? _selectedYieldTimeframe;

  late final Stream<YieldDto?> selectedYieldStream = _selectedYieldStreamController.stream;
  late final Stream<BigInt?> poolTickStream = _pooltickStreamController.stream;

  YieldDto? get selectedYield => _selectedYield;
  YieldTimeFrame? get selectedYieldTimeframe => _selectedYieldTimeframe;
  BigInt? get latestPoolTick => _latestPoolTick;
  DepositSettingsDto get depositSettings => _cache.getDepositSettings();
  PoolSearchSettingsDto get poolSearchSettings => _cache.getPoolSearchSettings();

  void setup() async {
    Timer.periodic(const Duration(minutes: 1), (timer) {
      if (_pooltickStreamController.isClosed) return timer.cancel();

      if (selectedYield != null) getSelectedPoolTick();
    });
  }

  Future<void> getBestPools({
    required String token0AddressOrId,
    required String token1AddressOrId,
    bool ignoreMinLiquidity = false,
  }) async {
    try {
      _zupAnalytics.logSearch(
        token0: token0AddressOrId,
        token1: token1AddressOrId,
        network: _appCubit.selectedNetwork.label,
      );

      emit(const DepositState.loading());
      final yields = _appCubit.selectedNetwork.isAllNetworks
          ? await _yieldRepository.getAllNetworksYield(
              token0InternalId: token0AddressOrId,
              token1InternalId: token1AddressOrId,
              minTvlUsd: ignoreMinLiquidity ? 0 : poolSearchSettings.minLiquidityUSD,
              testnetMode: _appCubit.isTestnetMode,
            )
          : await _yieldRepository.getSingleNetworkYield(
              token0Address: token0AddressOrId,
              token1Address: token1AddressOrId,
              network: _appCubit.selectedNetwork,
              minTvlUsd: ignoreMinLiquidity ? 0 : poolSearchSettings.minLiquidityUSD,
            );

      if (yields.isEmpty) {
        return emit(
          DepositState.noYields(minLiquiditySearched: yields.minLiquidityUSD),
        );
      }

      emit(DepositState.success(yields));
    } catch (e) {
      emit(const DepositState.error());
    }
  }

  Future<void> selectYield(YieldDto? yieldDto, YieldTimeFrame? yieldTimeFrame) async {
    _selectedYield = yieldDto;
    _selectedYieldTimeframe = yieldTimeFrame;
    _selectedYieldStreamController.add(selectedYield);

    if (selectedYield != null) await getSelectedPoolTick();
  }

  Future<void> getSelectedPoolTick() async {
    if (selectedYield == null) return;

    _latestPoolTick = null;
    _pooltickStreamController.add(null);

    final selectedYieldBeforeCall = selectedYield;

    final uniswapV3Pool = _uniswapV3Pool.fromRpcProvider(
      contractAddress: selectedYieldBeforeCall!.poolAddress,
      rpcUrl: selectedYieldBeforeCall.network.rpcUrl,
    );

    final slot0 = await uniswapV3Pool.slot0();
    if (selectedYieldBeforeCall != selectedYield) return await getSelectedPoolTick();

    _pooltickStreamController.add(slot0.tick);
    _latestPoolTick = slot0.tick;
  }

  Future<double> getWalletTokenAmount(String tokenAddress, {required AppNetworks network}) async {
    if (_wallet.signer == null) return 0.0;

    final walletAddress = await _wallet.signer!.address;

    return await _zupSingletonCache.run(
      () async {
        try {
          return await _wallet.nativeOrTokenBalance(tokenAddress, rpcUrl: network.rpcUrl);
        } catch (_) {
          return 0.0;
        }
      },
      key: userTokenBalanceCacheKey(
        tokenAddress: tokenAddress,
        userAddress: walletAddress,
        isNative: tokenAddress == EthereumConstants.zeroAddress,
      ),
      expiration: const Duration(minutes: 10),
    );
  }

  Future<void> saveDepositSettings(Slippage slippage, Duration deadline) async {
    await _cache.saveDepositSettings(
      DepositSettingsDto(
        deadlineMinutes: deadline.inMinutes,
        maxSlippage: slippage.value.toDouble(),
      ),
    );
  }

  @override
  Future<void> close() async {
    await _pooltickStreamController.close();
    await _selectedYieldStreamController.close();
    return super.close();
  }
}
