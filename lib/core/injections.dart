import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

final inject = GetIt.instance;

abstract class InjectInstanceNames {
  static const appScrollController = 'app_scroll_controller';
  static const zupPeriodicTask5Seconds = 'zup_periodic_task_5_seconds';
  static final lottieClick = Assets.lotties.click.path;
  static final lottieGhost = Assets.lotties.ghost.path;
}

Future<void> setupInjections() async {
  await inject.reset();

  inject.registerLazySingleton<ZupNavigator>(() => ZupNavigator());
  inject.registerLazySingleton<Wallet>(() => Wallet.shared);
  inject.registerLazySingleton<AppCubit>(() => AppCubit(inject<Wallet>()));
  inject.registerLazySingleton<PositionsRepository>(() => PositionsRepository());
  inject.registerSingletonAsync<SharedPreferencesWithCache>(
      () async => await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions()));
  inject.registerLazySingleton<Cache>(() => Cache(inject<SharedPreferencesWithCache>()));
  inject.registerLazySingleton<ZupCachedImage>(() => ZupCachedImage());
  inject.registerLazySingleton<PositionsCubit>(
      () => PositionsCubit(inject<Wallet>(), inject<PositionsRepository>(), inject<AppCubit>(), inject<Cache>()));
  inject.registerLazySingleton<TokensRepository>(() => TokensRepository());
  inject.registerLazySingleton<TokenSelectorModalCubit>(
    () => TokenSelectorModalCubit(inject<TokensRepository>(), inject<AppCubit>()),
  );
  inject.registerLazySingleton<Debouncer>(() => Debouncer(milliseconds: 500));
  inject.registerLazySingleton<YieldRepository>(() => YieldRepository());
  inject.registerLazySingleton<ZupHolder>(() => ZupHolder());
  inject.registerLazySingleton<ZupSingletonCache>(() => ZupSingletonCache.shared);
  inject.registerLazySingleton<ScrollController>(
    () => ScrollController(),
    instanceName: InjectInstanceNames.appScrollController,
  );
  inject.registerLazySingleton<LottieBuilder>(() => Assets.lotties.click.lottie(),
      instanceName: InjectInstanceNames.lottieClick);

  inject.registerLazySingleton<LottieBuilder>(() => Assets.lotties.ghost.lottie(),
      instanceName: InjectInstanceNames.lottieGhost);

  // WARNING: this should always be factory following the instructions
  inject.registerFactory(
    () => ZupPeriodicTask(duration: const Duration(seconds: 5)),
    instanceName: InjectInstanceNames.zupPeriodicTask5Seconds,
  );
  inject.registerLazySingleton<UniswapV3Pool>(() => UniswapV3Pool());

  await inject.allReady();
}
