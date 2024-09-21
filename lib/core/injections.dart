import 'package:get_it/get_it.dart';
import 'package:zup_app/core/zup_navigator.dart';

final inject = GetIt.instance;

Future<void> setupInjections() async {
  await inject.reset();

  inject.registerLazySingleton(() => ZupNavigator());

  inject.allReady();
}
