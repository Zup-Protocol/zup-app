import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:zup_app/core/enums/app_environment.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for the platform: $defaultTargetPlatform',
    );
  }

  static FirebaseOptions web = FirebaseOptions(
    apiKey: AppEnvironment.current.firebaseWebApiKey,
    appId: AppEnvironment.current.firebaseWebAppId,
    messagingSenderId: AppEnvironment.current.firebaseWebMessagingSenderId,
    projectId: AppEnvironment.current.firebaseWebProjectId,
    authDomain: AppEnvironment.current.firebaseWebAuthDomain,
    storageBucket: AppEnvironment.current.firebaseWebStorageBucket,
    measurementId: AppEnvironment.current.firebaseWebMeasurementId,
  );
}
