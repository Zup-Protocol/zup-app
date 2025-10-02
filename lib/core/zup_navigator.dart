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

  Future<void> navigateToYields({
    required String? token0,
    required String? token1,
    required String? group0,
    required String? group1,
    required AppNetworks network,
  }) async {
    const yieldsPath = ZupNavigatorPaths.yields;
    final yieldsPathParamNames = yieldsPath.routeParamsNames<YieldsRouteParamsNames>();

    final token0UrlParam = token0 != null ? "${yieldsPathParamNames.token0}=$token0" : "";
    final token1UrlParam = token1 != null ? "${yieldsPathParamNames.token1}=$token1" : "";
    final group0UrlParam = group0 != null ? "${yieldsPathParamNames.group0}=$group0" : "";
    final group1UrlParam = group1 != null ? "${yieldsPathParamNames.group1}=$group1" : "";
    final networkUrlParam = "${yieldsPathParamNames.network}=${network.name}";

    return await Routefly.pushNavigate(
      "${yieldsPath.path}?$token0UrlParam&$token1UrlParam&$group0UrlParam&$group1UrlParam&$networkUrlParam",
    );
  }

  Future<void> navigateToInitial() async => await Routefly.navigate(ZupNavigatorPaths.initial.path);
}
