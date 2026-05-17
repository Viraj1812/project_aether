// Flutter imports:
// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/config/env/app_env.dart';
import 'package:project_aether/config/sentry/sentry.dart';
import 'package:project_aether/constants/pref_keys.dart';
import 'package:project_aether/main.dart';
import 'package:project_aether/routes/app_route_handler.dart';

enum Environment { dev, prod }

class AppConfig {
  Environment? appEnvironment;
  Future<void> setAppConfig({required Environment environment}) async {
    appEnvironment = environment;
    await _initializeApp(environment: environment);
    await PreferenceHelper.setStringPrefValue(
      key: PreferenceKeys.environment,
      value: environment.name,
    );

    await InitSentry().runAppWithSentry(
      EasyLocalization(
        supportedLocales: const <Locale>[
          Locale('en'),
          Locale('hi'),
        ],
        path: 'assets/l10n',
        fallbackLocale: const Locale('en'),
        child: const AppWidget(),
      ),
      environment: environment,
    );
  }

  Future<String> getEnvironment() async {
    final String environment = PreferenceHelper.getStringPrefValue(key: PreferenceKeys.environment);
    return environment;
  }

  Future<void> _initializeApp({required Environment environment}) async {
    WidgetsFlutterBinding.ensureInitialized();
    AppRouteHandler.initRoute();
    await EasyLocalization.ensureInitialized();
    await Firebase.initializeApp();
    await SystemChrome.setPreferredOrientations(
      <DeviceOrientation>[DeviceOrientation.portraitUp, DeviceOrientation.portraitDown],
    );

    await PreferenceHelper.init(
      encryptionKey: AppEnv.preferenceHelperEncryptionKey,
    );
  }
}
