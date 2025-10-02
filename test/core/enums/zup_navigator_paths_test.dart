import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/core/zup_route_params_names.dart';
import 'package:zup_app/zup_app.dart';

void main() {
  test("Zup navigator paths `initial` path should be create", () {
    expect(ZupNavigatorPaths.initial.path, routePaths.create.path);
  });

  test("Zup navigator paths `path` extension should use routefly generated paths", () {
    expect(
      ZupNavigatorPaths.newPosition.path,
      routePaths.create.path,
      reason: "New position path does not match routefly path",
    );
  });

  test("The route params names type for yields should be correct", () {
    expect(ZupNavigatorPaths.yields.routeParamsNames().runtimeType, YieldsRouteParamsNames);
  });

  test("The route params names type for new position should be correct", () {
    expect(ZupNavigatorPaths.newPosition.routeParamsNames().runtimeType, NewPositionRouteParamsNames);
  });

  test("The route params names type for initial should be correct", () {
    expect(ZupNavigatorPaths.initial.routeParamsNames().runtimeType, InitialRouteParamsNames);
  });
}
