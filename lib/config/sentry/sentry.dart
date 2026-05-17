// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// Project imports:
import 'package:project_aether/config/env/app_env.dart';
import 'package:project_aether/config/flavours/app.dart';
// Package imports:
import 'package:sentry_flutter/sentry_flutter.dart';

class InitSentry {
  Future<void> runAppWithSentry(
    Widget widget, {
    required Environment environment,
  }) async {
    final String sentryDSN = AppEnv.sentryUrl;

    kReleaseMode
        ? runZonedGuarded(() async {
            await SentryFlutter.init(
              (SentryFlutterOptions options) {
                options
                  ..dsn = sentryDSN
                  ..attachScreenshot = true
                  ..environment = environment.name
                  ..attachThreads = true
                  ..attachStacktrace = true
                  ..reportPackages = false
                  ..attachThreads = true;
              },
            );

            runApp(SentryScreenshotWidget(child: widget));
          }, (Object exception, StackTrace stackTrace) async {
            await Sentry.captureException(exception, stackTrace: stackTrace);
          })
        : runApp(widget);
  }
}
