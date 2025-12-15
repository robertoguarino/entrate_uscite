import 'package:flutter/foundation.dart';
import 'app_env.dart';

class AppConfig {
  static final AppEnv env = _detectEnv();

  static AppEnv _detectEnv() {
    if (kReleaseMode) {
      return AppEnv.prod; // build / store
    } else {
      return AppEnv.dev; // debug + profile
    }
  }

  static bool get isDev => env == AppEnv.dev;
  static bool get isProd => env == AppEnv.prod;
}
