import 'package:confetti/confetti.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/abis/erc_20.abi.g.dart';
import 'package:zup_app/abis/uniswap_position_manager.abi.g.dart';
import 'package:zup_app/abis/uniswap_v3_pool.abi.g.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/debouncer.dart';
import 'package:zup_app/core/enums/app_environment.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';
import 'package:zup_app/core/repositories/tokens_repository.dart';
import 'package:zup_app/core/repositories/yield_repository.dart';
import 'package:zup_app/core/zup_links.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/gen/assets.gen.dart';
import 'package:zup_app/widgets/token_selector_modal/token_selector_modal_cubit.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';
import 'package:zup_core/zup_core.dart';

final inject = GetIt.instance;

abstract class InjectInstanceNames {
  static const appScrollController = 'app_scroll_controller';
  static const zupPeriodicTask5Seconds = 'zup_periodic_task_5_seconds';
  static const zupPeriodicTask1Minute = 'zup_periodic_task_1_minute';
  static final lottieClick = Assets.lotties.click.path;
  static final lottieEmpty = Assets.lotties.empty.path;
  static final lottieRadar = Assets.lotties.radar.path;
  static final lottieMatching = Assets.lotties.matching.path;
  static final lottieSearching = Assets.lotties.seaching.path;
  static const zupAPIDio = 'zup_api_dio';
  static const confettiController10s = 'confetti_controller_10s';
}

Future<void> setupInjections() async {
  await inject.reset();

  inject.registerLazySingleton<Dio>(
    () => Dio(BaseOptions(baseUrl: AppEnvironment.current.apiUrl))
      ..interceptors.add(
        LogInterceptor(request: true, requestBody: true, responseBody: true, error: true),
      ),
    instanceName: InjectInstanceNames.zupAPIDio,
  );

  inject.registerSingletonAsync<SharedPreferencesWithCache>(
    () async => await SharedPreferencesWithCache.create(
      cacheOptions: SharedPreferencesWithCacheOptions(allowList: CacheKey.keys),
    ),
  );
  inject.registerLazySingleton<Cache>(() => Cache(inject<SharedPreferencesWithCache>()));
  inject.registerLazySingleton<ZupNavigator>(() => ZupNavigator());
  inject.registerLazySingleton<Wallet>(() => Wallet.shared);
  inject.registerLazySingleton<AppCubit>(() => AppCubit(inject<Wallet>(), inject<Cache>()));
  inject.registerLazySingleton<PositionsRepository>(() => PositionsRepository());
  inject.registerLazySingleton<ZupCachedImage>(() => ZupCachedImage());
  inject.registerLazySingleton<TokensRepository>(
      () => TokensRepository(inject<Dio>(instanceName: InjectInstanceNames.zupAPIDio)));
  inject.registerLazySingleton<TokenSelectorModalCubit>(
    () => TokenSelectorModalCubit(inject<TokensRepository>(), inject<AppCubit>(), inject<Wallet>()),
  );
  inject.registerLazySingleton<Debouncer>(() => Debouncer(milliseconds: 500));
  inject.registerLazySingleton<YieldRepository>(
    () => YieldRepository(inject<Dio>(instanceName: InjectInstanceNames.zupAPIDio)),
  );
  inject.registerLazySingleton<ZupHolder>(() => ZupHolder());
  inject.registerLazySingleton<Erc20>(() => Erc20());
  inject.registerLazySingleton<GlobalKey<NavigatorState>>(() => GlobalKey<NavigatorState>());
  inject.registerLazySingleton<UniswapPositionManager>(() => UniswapPositionManager());
  inject.registerLazySingleton<ZupSingletonCache>(() => ZupSingletonCache.shared);
  inject.registerFactory<ZupLinks>(() => ZupLinks());

  inject.registerLazySingleton<ScrollController>(
    () => ScrollController(),
    instanceName: InjectInstanceNames.appScrollController,
  );
  inject.registerLazySingleton<LottieBuilder>(
    () => Assets.lotties.click.lottie(),
    instanceName: InjectInstanceNames.lottieClick,
  );
  inject.registerLazySingleton<LottieBuilder>(
    () => Assets.lotties.empty.lottie(),
    instanceName: InjectInstanceNames.lottieEmpty,
  );
  inject.registerLazySingleton<LottieBuilder>(
    () => Assets.lotties.radar.lottie(),
    instanceName: InjectInstanceNames.lottieRadar,
  );
  inject.registerLazySingleton<LottieBuilder>(
    () => Assets.lotties.matching.lottie(),
    instanceName: InjectInstanceNames.lottieMatching,
  );
  inject.registerLazySingleton<LottieBuilder>(
    () => Assets.lotties.seaching.lottie(),
    instanceName: InjectInstanceNames.lottieSearching,
  );

  // WARNING: this should always be factory following the instructions
  inject.registerFactory(
    () => ZupPeriodicTask(duration: const Duration(seconds: 5)),
    instanceName: InjectInstanceNames.zupPeriodicTask5Seconds,
  );

  // WARNING: this should always be factory following the instructions
  inject.registerFactory(
    () => ZupPeriodicTask(duration: const Duration(minutes: 1)),
    instanceName: InjectInstanceNames.zupPeriodicTask1Minute,
  );

  inject.registerLazySingleton<UniswapV3Pool>(() => UniswapV3Pool());

  // WARNING: this should be factory, as it's a controller and can/should be disposed
  inject.registerFactory<ConfettiController>(
    () => ConfettiController(duration: const Duration(seconds: 10)),
    instanceName: InjectInstanceNames.confettiController10s,
  );

  await inject.allReady();
}
