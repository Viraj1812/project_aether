// Package imports:
import 'package:get_it/get_it.dart';

// Project imports:
import 'package:project_aether/routes/app_router.dart';

class AppRouteHandler {
  AppRouteHandler._();

  static void initRoute() {
    GetIt.instance.registerSingleton<AppRouter>(AppRouter());
  }

  static AppRouter get route => GetIt.instance<AppRouter>();
}
