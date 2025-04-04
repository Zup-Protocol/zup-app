import 'package:zup_core/zup_core.dart';

enum AppEnvironment {
  prod,
  local,
  stage;

  static AppEnvironment get current {
    const env = String.fromEnvironment("env");

    if (env.equals(AppEnvironment.stage.value)) {
      return AppEnvironment.stage;
    }

    if (env.equals(AppEnvironment.prod.value)) {
      return AppEnvironment.prod;
    }

    if (env.equals(AppEnvironment.local.value)) {
      return AppEnvironment.local;
    }

    throw UnsupportedError("Environment either not supported or not set");
  }

  String get value => switch (this) {
        prod => "prod",
        stage => "stage",
        local => "local",
      };

  String get apiUrl => switch (this) {
        prod => "https://api.zupprotocol.xyz",
        stage => "https://staging.api.zupprotocol.xyz",
        local => "http://localhost:3000",
      };
}
