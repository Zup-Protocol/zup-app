import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/app_cache.dart';
import 'package:zup_app/core/dtos/pool_search_filters_dto.dart';
import 'package:zup_app/core/dtos/yields_dto.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_analytics.dart';

part 'yields_cubit.freezed.dart';
part 'yields_state.dart';

class YieldsCubit extends Cubit<YieldsState> {
  YieldsCubit(this.appCubit, this.appCache, this.yieldRepository, this.zupAnalytics)
    : super(const YieldsState.initial());

  final AppCubit appCubit;
  final ZupAnalytics zupAnalytics;
  final AppCache appCache;
  final YieldRepository yieldRepository;

  Future<void> fetchYields({
    required String? token0AddressOrId,
    required String? token1AddressOrId,
    required String? group0Id,
    required String? group1Id,
    bool ignoreMinLiquidity = false,
  }) async {
    try {
      zupAnalytics.logSearch(
        token0: token0AddressOrId,
        token1: token1AddressOrId,
        group0: group0Id,
        group1: group1Id,
        network: appCubit.selectedNetwork.label,
      );

      emit(const YieldsState.loading());

      final yields = appCubit.selectedNetwork.isAllNetworks
          ? await yieldRepository.getAllNetworksYield(
              blockedProtocolIds: appCache.blockedProtocolsIds,
              token0InternalId: token0AddressOrId,
              token1InternalId: token1AddressOrId,
              group0Id: group0Id,
              group1Id: group1Id,
              searchSettings: ignoreMinLiquidity
                  ? appCache.getPoolSearchSettings().copyWith(minLiquidityUSD: 0)
                  : appCache.getPoolSearchSettings(),
              testnetMode: appCubit.isTestnetMode,
            )
          : await yieldRepository.getSingleNetworkYield(
              blockedProtocolIds: appCache.blockedProtocolsIds,
              token0Address: token0AddressOrId,
              token1Address: token1AddressOrId,
              group0Id: group0Id,
              group1Id: group1Id,
              network: appCubit.selectedNetwork,
              searchSettings: ignoreMinLiquidity
                  ? appCache.getPoolSearchSettings().copyWith(minLiquidityUSD: 0)
                  : appCache.getPoolSearchSettings(),
            );

      if (yields.isEmpty) {
        return emit(YieldsState.noYields(filtersApplied: yields.filters));
      }

      emit(YieldsState.success(yields));
    } catch (e, stackTrace) {
      emit(YieldsState.error(e.toString(), stackTrace.toString()));
    }
  }
}
