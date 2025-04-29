import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';

class ZupNavigator {
  Listenable get listenable => Routefly.listenable;
  String get currentRoute => Routefly.currentUri.path;

  String? getParam(String paramName) => Routefly.query.params[paramName];

  Future<void> back(BuildContext context) async => Routefly.pop(context);

  Future<void> navigateToNewPosition() async => await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

  Future<void> navigateToDeposit(String token0, String token1, Networks network) async {
    const depositPath = ZupNavigatorPaths.deposit;

    await Routefly.pushNavigate(
      "${depositPath.path}?${depositPath.routeParamsName!.param0}=$token0&${depositPath.routeParamsName!.param1}=$token1&${depositPath.routeParamsName!.param3}=${network.name}",
    );
  }

  Future<void> navigateToInitial() async => await Routefly.navigate(ZupNavigatorPaths.initial.path);
}
