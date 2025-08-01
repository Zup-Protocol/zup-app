abstract class ZupRouteParamsNames<T> {}

class ZupDepositRouteParamsNames extends ZupRouteParamsNames {
  final String token0 = "token0";
  final String token1 = "token1";
  final String group0 = "group0";
  final String group1 = "group1";
  final String network = "network";
}

class ZupInitialRouteParamsNames extends ZupRouteParamsNames {
  ZupInitialRouteParamsNames();
}

class ZupNewPositionRouteParamsNames extends ZupRouteParamsNames {
  ZupNewPositionRouteParamsNames();
}
