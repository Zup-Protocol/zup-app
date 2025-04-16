import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied()
abstract class Env {
  @EnviedField(varName: 'FIREBASE_WEB_API_KEY')
  static const String firebaseWebApiKey = _Env.firebaseWebApiKey;

  @EnviedField(varName: 'FIREBASE_WEB_AUTH_DOMAIN')
  static const String firebaseWebAuthDomain = _Env.firebaseWebAuthDomain;

  @EnviedField(varName: 'FIREBASE_WEB_PROJECT_ID')
  static const String firebaseWebProjectId = _Env.firebaseWebProjectId;

  @EnviedField(varName: 'FIREBASE_WEB_STORAGE_BUCKET')
  static const String firebaseWebStorageBucket = _Env.firebaseWebStorageBucket;

  @EnviedField(varName: 'FIREBASE_WEB_MESSAGING_SENDER_ID')
  static const String firebaseWebMessagingSenderId = _Env.firebaseWebMessagingSenderId;

  @EnviedField(varName: 'FIREBASE_WEB_APP_ID')
  static const String firebaseWebAppId = _Env.firebaseWebAppId;

  @EnviedField(varName: 'FIREBASE_WEB_MEASUREMENT_ID')
  static const String firebaseWebMeasurementId = _Env.firebaseWebMeasurementId;
}
