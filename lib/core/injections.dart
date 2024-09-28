import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/app/positions/positions_cubit.dart';
import 'package:zup_app/core/cache.dart';
import 'package:zup_app/core/repositories/positions_repository.dart';
import 'package:zup_app/core/zup_navigator.dart';
import 'package:zup_app/widgets/zup_cached_image.dart';

final inject = GetIt.instance;

Future<void> setupInjections() async {
  await inject.reset();

  inject.registerLazySingleton<ZupNavigator>(() => ZupNavigator());
  inject.registerLazySingleton<Wallet>(() => Wallet.shared);
  inject.registerLazySingleton<AppCubit>(() => AppCubit(inject<Wallet>()));
  inject.registerLazySingleton<PositionsRepository>(() => PositionsRepository());
  inject.registerSingletonAsync<SharedPreferencesWithCache>(
    () async => await SharedPreferencesWithCache.create(cacheOptions: const SharedPreferencesWithCacheOptions()),
  );
  inject.registerLazySingleton<Cache>(() => Cache(inject<SharedPreferencesWithCache>()));
  inject.registerLazySingleton<ZupCachedImage>(() => ZupCachedImage());
  inject.registerLazySingleton<PositionsCubit>(
      () => PositionsCubit(inject<Wallet>(), inject<PositionsRepository>(), inject<AppCubit>(), inject<Cache>()));

  await inject.allReady();
}
