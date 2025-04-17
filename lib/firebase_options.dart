import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:zup_app/core/env.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    throw UnsupportedError(
      'DefaultFirebaseOptions have not been configured for the platform: $defaultTargetPlatform',
    );
  }

  static FirebaseOptions web = const FirebaseOptions(
    apiKey: Env.firebaseWebApiKey,
    appId: Env.firebaseWebAppId,
    messagingSenderId: Env.firebaseWebMessagingSenderId,
    projectId: Env.firebaseWebProjectId,
    authDomain: Env.firebaseWebAuthDomain,
    storageBucket: Env.firebaseWebStorageBucket,
    measurementId: Env.firebaseWebMeasurementId,
  );
}
