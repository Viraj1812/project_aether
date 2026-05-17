// Project imports:
import 'package:project_aether/config/env/my_env.dart';

class AppEnv {
  static String baseUrl = MyEnv.baseUrl;
  static String sentryUrl = MyEnv.sentryUrl;
  static String preferenceHelperEncryptionKey = MyEnv.preferenceHelperEncryptionKey;
}
