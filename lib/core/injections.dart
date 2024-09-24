import 'package:get_it/get_it.dart';
import 'package:web3kit/web3kit.dart';
import 'package:zup_app/app/app_cubit/app_cubit.dart';
import 'package:zup_app/core/zup_navigator.dart';

final inject = GetIt.instance;

Future<void> setupInjections() async {
  await inject.reset();

  inject.registerLazySingleton<ZupNavigator>(() => ZupNavigator());
  inject.registerLazySingleton<Wallet>(() => Wallet.shared);
  inject.registerLazySingleton<AppCubit>(() => AppCubit(inject<Wallet>()));

  await inject.allReady();
}
