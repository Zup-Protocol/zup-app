import 'package:zup_app/routes.g.dart';

enum ZupNavigatorPaths { initial, myPositions, newPosition }

extension ZupNavigatorPathsExtension on ZupNavigatorPaths {
  String get path => [routePaths.positions, routePaths.positions, routePaths.create][index];
}
