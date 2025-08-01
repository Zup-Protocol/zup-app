import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/zup_app.dart';

enum ZupNavigatorPaths {
  initial,
  newPosition,
  deposit;

  String get path => switch (this) {
    initial => routePaths.create.path,
    newPosition => routePaths.create.path,
    deposit => routePaths.create.deposit,
  };

  T routeParamsNames<T extends ZupRouteParamsNames>() {
    final params = switch (this) {
      initial => ZupInitialRouteParamsNames(),
      newPosition => ZupNewPositionRouteParamsNames(),
      deposit => ZupDepositRouteParamsNames(),
    };

    return params as T;
  }
}
