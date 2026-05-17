// Flutter imports:
// Package imports:
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:master_utility/master_utility.dart';
// Project imports:
import 'package:project_aether/constants/logarte.dart';
import 'package:project_aether/constants/theme.dart';
import 'package:project_aether/routes/app_route_handler.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AppWidget extends StatelessWidget {
  const AppWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MasterUtilityMaterialApp(
        home: MaterialApp.router(
          routerConfig: AppRouteHandler.route.config(
            navigatorObservers: () {
              return <NavigatorObserver>[
                SentryNavigatorObserver(),
                LogarteNavigatorObserver(logarte),
              ];
            },
          ),
          scrollBehavior: const ScrollBehavior().copyWith(overscroll: false),
          theme: AppTheme.lightTheme,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          debugShowCheckedModeBanner: false,
        ),
      ),
    );
  }
}
