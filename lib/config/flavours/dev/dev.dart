// Project imports:
import 'package:project_aether/config/flavours/app.dart';

void main() async {
  await AppConfig().setAppConfig(environment: Environment.dev);
}
