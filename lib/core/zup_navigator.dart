import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/routes.g.dart';

enum ZupNavigatorPaths { home, myPositions, newPosition }

extension ZupNavigatorPathsExtension on ZupNavigatorPaths {
  String get routeName => [routePaths.path, routePaths.positions, routePaths.add][index];
}

class ZupNavigator {
  Listenable get listenable => Routefly.listenable;
  String get currentRoute => Routefly.currentUri.path;

  void navigateToMyPositions({bool addToStack = true}) {
    addToStack
        ? Routefly.pushNavigate(ZupNavigatorPaths.myPositions.routeName)
        : Routefly.navigate(ZupNavigatorPaths.myPositions.routeName);
  }

  void navigateToNewPosition({bool addToStack = true}) {
    addToStack
        ? Routefly.pushNavigate(ZupNavigatorPaths.newPosition.routeName)
        : Routefly.navigate(ZupNavigatorPaths.newPosition.routeName);
  }
}
