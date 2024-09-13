import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/routes.g.dart';

enum ZupNavigatorPaths { initial, myPositions, newPosition }

extension ZupNavigatorPathsExtension on ZupNavigatorPaths {
  String get routeName => [routePaths.positions, routePaths.positions, routePaths.add][index];
}

class ZupNavigator {
  Listenable get listenable => Routefly.listenable;
  String get currentRoute => Routefly.currentUri.path;

  void navigateToMyPositions() => Routefly.navigate(ZupNavigatorPaths.myPositions.routeName);

  void navigateToNewPosition() => Routefly.navigate(ZupNavigatorPaths.newPosition.routeName);

  void navigateToInitial() => Routefly.navigate(ZupNavigatorPaths.initial.routeName);
}
