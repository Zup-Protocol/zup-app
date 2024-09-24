import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/zup_navigator_paths.dart';
import 'package:zup_app/routes.g.dart';

void main() {
  test("Zup navigator paths `initial` path should be positions", () {
    expect(ZupNavigatorPaths.initial.path, routePaths.positions);
  });

  test("Zup navigator paths `path` extension should use routefly generated paths", () {
    expect(
      ZupNavigatorPaths.myPositions.path,
      routePaths.positions,
      reason: "My positions path does not match routefly path",
    );

    expect(
      ZupNavigatorPaths.newPosition.path,
      routePaths.create,
      reason: "New position path does not match routefly path",
    );
  });
}
