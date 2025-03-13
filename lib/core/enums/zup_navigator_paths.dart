import 'package:zup_app/zup_app.dart';

enum ZupNavigatorPaths {
  initial,
  myPositions,
  newPosition,
  deposit;

  String get path => switch (this) {
        initial => routePaths.create.path,
        myPositions => routePaths.positions,
        newPosition => routePaths.create.path,
        deposit => routePaths.create.deposit,
      };

  ({String param0, String param1})? get routeParamsName => [
        null,
        null,
        null,
        (param0: "token0", param1: "token1"),
      ][index];
}
