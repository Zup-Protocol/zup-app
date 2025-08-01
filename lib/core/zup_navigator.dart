import 'package:flutter/material.dart';
import 'package:routefly/routefly.dart';
import 'package:zup_app/core/enums/networks.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/zup_route_params_names.dart';

class ZupNavigator {
  Listenable get listenable => Routefly.listenable;
  String get currentRoute => Routefly.currentUri.path;

  String? getParam(String paramName) => Routefly.query.params[paramName];

  Future<void> back(BuildContext context) async => Routefly.pop(context);

  Future<void> navigateToNewPosition() async => await Routefly.navigate(ZupNavigatorPaths.newPosition.path);

  Future<void> navigateToDeposit({
    required String? token0,
    required String? token1,
    required String? group0,
    required String? group1,
    required AppNetworks network,
  }) async {
    const depositPath = ZupNavigatorPaths.deposit;
    final depositPathParams = depositPath.routeParamsNames<ZupDepositRouteParamsNames>();

    final token0UrlParam = token0 != null ? "${depositPathParams.token0}=$token0" : "";
    final token1UrlParam = token1 != null ? "${depositPathParams.token1}=$token1" : "";
    final group0UrlParam = group0 != null ? "${depositPathParams.group0}=$group0" : "";
    final group1UrlParam = group1 != null ? "${depositPathParams.group1}=$group1" : "";
    final networkUrlParam = "${depositPathParams.network}=${network.name}";

    await Routefly.pushNavigate(
      "${depositPath.path}?$token0UrlParam&$token1UrlParam&$group0UrlParam&$group1UrlParam&$networkUrlParam",
    );
  }

  Future<void> navigateToInitial() async => await Routefly.navigate(ZupNavigatorPaths.initial.path);
}
