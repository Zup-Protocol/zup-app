import 'package:zup_app/routes.g.dart';

enum ZupNavigatorPaths { initial, myPositions, newPosition, deposit }

extension ZupNavigatorPathsExtension on ZupNavigatorPaths {
  String get path => [
        routePaths.positions,
        routePaths.positions,
        routePaths.create.path,
        routePaths.create.deposit,
      ][index];

  ({String param0, String param1})? get routeParamsName => [
        null,
        null,
        null,
        (param0: "token0", param1: "token1"),
      ][index];
}
