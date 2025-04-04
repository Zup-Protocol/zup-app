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

  ({String param0, String param1})? get routeParamsName => switch (this) {
        initial => null,
        newPosition => null,
        deposit => (param0: "token0", param1: "token1"),
      };
}
