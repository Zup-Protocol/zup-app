import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/extensions/route_verifier_extension.dart';

void main() {
  test("Whe calling `isMyPositions` it should return true, if the route is `/positions`", () {
    expect("/positions".isMyPositions, true);
  });

  test("Whe calling `isNewPosition` it should return true, if the route is `/create`", () {
    expect("/create".isNewPosition, true);
  });
}
