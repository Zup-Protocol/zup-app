import 'package:flutter_test/flutter_test.dart';
import 'package:zup_app/core/enums/app_environment.dart';

void main() {
  test("'value' variable should return the correct value if the env is prod", () {
    expect(AppEnvironment.prod.value, "prod");
  });

  test("'value' variable should return the correct value if the env is stage", () {
    expect(AppEnvironment.stage.value, "stage");
  });

  test("'value' variable should return the correct value if the env is local", () {
    expect(AppEnvironment.local.value, "local");
  });

  test("'apiUrl' variable should return the correct value if the env is prod", () {
    expect(AppEnvironment.prod.apiUrl, "https://api.zupprotocol.xyz");
  });

  test("'apiUrl' variable should return the correct value if the env is stage", () {
    expect(AppEnvironment.stage.apiUrl, "https://staging.api.zupprotocol.xyz");
  });

  test("'apiUrl' variable should return the correct value if the env is local", () {
    expect(AppEnvironment.local.apiUrl, "http://localhost:3000");
  });
}
