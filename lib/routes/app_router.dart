// Package imports:
import 'package:auto_route/auto_route.dart';
import 'package:project_aether/features/home/views/home_screen.dart';
// Project imports:
import 'package:project_aether/features/splash/views/splash_screen.dart';

part 'app_router.gr.dart';

@AutoRouterConfig()
class AppRouter extends RootStackRouter {
  @override
  List<AutoRoute> get routes => <AutoRoute>[
        AutoRoute(page: SplashRoute.page, initial: true),
        AutoRoute(page: HomeRoute.page),
      ];
}
