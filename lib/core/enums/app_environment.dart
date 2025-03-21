enum AppEnvironment {
  prod,
  stage;

  static AppEnvironment get current {
    const env = String.fromEnvironment("env");

    if (env == AppEnvironment.stage.value) {
      return AppEnvironment.stage;
    }

    if (env == AppEnvironment.prod.value) {
      return AppEnvironment.prod;
    }

    throw UnsupportedError("Environment either not supported or not set");
  }

  String get value => switch (this) {
        prod => "prod",
        stage => "stage",
      };

  String get apiUrl => switch (this) {
        prod => "https://api.zupprotocol.xyz",
        stage => "https://staging.api.zupprotocol.xyz",
      };
}
