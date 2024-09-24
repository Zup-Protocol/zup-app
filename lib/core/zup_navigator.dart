import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';

class ZupNavigator {
  Listenable get listenable => Routefly.listenable;
  String get currentRoute => Routefly.currentUri.path;

  Future<void> navigateToMyPositions() async => await Routefly.navigate(ZupNavigatorPaths.myPositions.path);

  Future<void> navigateToNewPosition() async => await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

  Future<void> navigateToInitial() async => await Routefly.navigate(ZupNavigatorPaths.initial.path);
}
