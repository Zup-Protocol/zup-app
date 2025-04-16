import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  String get firebaseWebApiKey {
    return dotenv.env["FIREBASE_WEB_API_KEY"] ??= throw UnsupportedError("FIREBASE_WEB_API_KEY not set");
  }

  String get firebaseWebAppId {
    return dotenv.env["FIREBASE_WEB_APP_ID"] ??= throw UnsupportedError("FIREBASE_WEB_APP_ID not set");
  }

  String get firebaseWebMessagingSenderId {
    return dotenv.env["FIREBASE_WEB_MESSAGING_SENDER_ID"] ??=
        throw UnsupportedError("FIREBASE_WEB_MESSAGING_SENDER_ID not set");
  }

  String get firebaseWebProjectId {
    return dotenv.env["FIREBASE_WEB_PROJECT_ID"] ??= throw UnsupportedError("FIREBASE_WEB_PROJECT_ID not set");
  }

  String get firebaseWebAuthDomain {
    return dotenv.env["FIREBASE_WEB_AUTH_DOMAIN"] ??= throw UnsupportedError("FIREBASE_WEB_AUTH_DOMAIN not set");
  }

  String get firebaseWebStorageBucket {
    return dotenv.env["FIREBASE_WEB_STORAGE_BUCKET"] ??= throw UnsupportedError("FIREBASE_WEB_STORAGE_BUCKET not set");
  }

  String get firebaseWebMeasurementId {
    return dotenv.env["FIREBASE_WEB_MEASUREMENT_ID"] ??= throw UnsupportedError("FIREBASE_WEB_MEASUREMENT_ID not set");
  }
}
