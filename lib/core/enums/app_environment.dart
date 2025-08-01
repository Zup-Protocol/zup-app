import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:zup_core/zup_core.dart';

enum AppEnvironment {
  prod,
  local,
  test,
  stage;

  static AppEnvironment get current {
    const env = String.fromEnvironment("env");

    if (env.equals(AppEnvironment.stage.value)) {
      return stage;
    }

    if (env.equals(AppEnvironment.prod.value)) {
      return prod;
    }

    if (env.equals(AppEnvironment.local.value)) {
      return local;
    }

    if (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST')) {
      return test;
    }

    throw UnsupportedError("Environment either not supported or not set");
  }

  String get value => switch (this) {
    prod => "prod",
    stage => "stage",
    local => "local",
    test => "test",
  };

  String get apiUrl => switch (this) {
    prod => "https://api.zupprotocol.xyz",
    stage => "https://staging.api.zupprotocol.xyz",
    local => "http://localhost:3000",
    test => "http://test-env",
  };
}
