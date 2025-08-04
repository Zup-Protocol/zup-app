import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/dtos/deposit_settings_dto.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/pool_search_settings_dto.dart';
import 'package:zup_app/core/dtos/yield_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/mixins/keys_mixin.dart';
import 'package:zup_app/core/mixins/v3_pool_conversors_mixin.dart';
import 'package:zup_app/core/pool_service.dart';
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
    this._cache,
    this._appCubit,
    this._zupAnalytics,
    this._poolService,
  ) : super(const DepositState.initial());

  final YieldRepository _yieldRepository;
  final ZupSingletonCache _zupSingletonCache;
  final Wallet _wallet;
  final PoolService _poolService;
  final Cache _cache;
  final AppCubit _appCubit;
  final ZupAnalytics _zupAnalytics;

  final StreamController<BigInt?> _pooltickStreamController = StreamController.broadcast();
  final StreamController<YieldDto?> _selectedYieldStreamController = StreamController.broadcast();
  final Duration _poolTickExpiration = const Duration(seconds: 30);

  BigInt? _latestPoolTick;
  YieldDto? _selectedYield;

  late final Stream<YieldDto?> selectedYieldStream = _selectedYieldStreamController.stream;
  late final Stream<BigInt?> poolTickStream = _pooltickStreamController.stream;

  YieldDto? get selectedYield => _selectedYield;
  BigInt? get latestPoolTick => _latestPoolTick;
  DepositSettingsDto get depositSettings => _cache.getDepositSettings();
  PoolSearchSettingsDto get poolSearchSettings => _cache.getPoolSearchSettings();

  void setup() async {
    Timer.periodic(_poolTickExpiration, (timer) {
      if (_pooltickStreamController.isClosed) return timer.cancel();

      if (selectedYield != null) getSelectedPoolTick();
    });
  }

  Future<void> getBestPools({
    required String? token0AddressOrId,
    required String? token1AddressOrId,
    required String? group0Id,
    required String? group1Id,
    bool ignoreMinLiquidity = false,
  }) async {
    try {
      _zupAnalytics.logSearch(
        token0: token0AddressOrId,
        token1: token1AddressOrId,
        group0: group0Id,
        group1: group1Id,
        network: _appCubit.selectedNetwork.label,
      );

      emit(const DepositState.loading());
      final yields = _appCubit.selectedNetwork.isAllNetworks
          ? await _yieldRepository.getAllNetworksYield(
              blockedProtocolIds: _cache.blockedProtocolsIds,
              token0InternalId: token0AddressOrId,
              token1InternalId: token1AddressOrId,
              group0Id: group0Id,
              group1Id: group1Id,
              searchSettings: ignoreMinLiquidity ? poolSearchSettings.copyWith(minLiquidityUSD: 0) : poolSearchSettings,
              testnetMode: _appCubit.isTestnetMode,
            )
          : await _yieldRepository.getSingleNetworkYield(
              blockedProtocolIds: _cache.blockedProtocolsIds,
              token0Address: token0AddressOrId,
              token1Address: token1AddressOrId,
              group0Id: group0Id,
              group1Id: group1Id,
              network: _appCubit.selectedNetwork,
              searchSettings: ignoreMinLiquidity ? poolSearchSettings.copyWith(minLiquidityUSD: 0) : poolSearchSettings,
            );

      if (yields.isEmpty) {
        return emit(DepositState.noYields(filtersApplied: yields.filters));
      }

      emit(DepositState.success(yields));
    } catch (e) {
      emit(const DepositState.error());
    }
  }

  Future<void> selectYield(YieldDto? yieldDto) async {
    _selectedYield = yieldDto;
    _selectedYieldStreamController.add(selectedYield);

    if (selectedYield != null) {
      _latestPoolTick = BigInt.parse(yieldDto!.latestTick);
      _pooltickStreamController.add(_latestPoolTick);

      await getSelectedPoolTick(forceRefresh: true);
    }
  }

  Future<void> getSelectedPoolTick({bool forceRefresh = false}) async {
    if (selectedYield == null) return;

    final selectedYieldBeforeCall = selectedYield;

    final tick = await _zupSingletonCache.run(
      () => _poolService.getPoolTick(selectedYieldBeforeCall!),
      expiration: _poolTickExpiration - const Duration(seconds: 1),
      ignoreCache: forceRefresh,
      key: poolTickCacheKey(network: selectedYield!.network, poolAddress: selectedYield!.poolAddress),
    );

    if (selectedYieldBeforeCall != selectedYield) return await getSelectedPoolTick();

    _pooltickStreamController.add(tick);
    _latestPoolTick = tick;
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
        network: network,
      ),
      expiration: const Duration(minutes: 10),
    );
  }

  Future<void> saveDepositSettings(Slippage slippage, Duration deadline) async {
    await _cache.saveDepositSettings(
      DepositSettingsDto(deadlineMinutes: deadline.inMinutes, maxSlippage: slippage.value.toDouble()),
    );
  }

  @override
  Future<void> close() async {
    await _pooltickStreamController.close();
    await _selectedYieldStreamController.close();
    return super.close();
  }
}
