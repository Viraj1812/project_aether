// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('Please provide a feature name (e.g. "auth_feature"):');

  final String? featureName = stdin.readLineSync();

  if (featureName == null || featureName.trim().isEmpty) {
    print('No feature name provided.');
    return;
  }

  const String projectName = 'project_aether'; //! Add your project name here
  final String className = _toPascalCase(featureName);
  final String camelCaseName = _toCamelCase(featureName);
  final String basePath = 'lib/features/$featureName';

  if (Directory(basePath).existsSync()) {
    print(
      'Error: The folder "$basePath" already exists. Please choose a different feature name.',
    );
    return;
  }

  // Define folder structure
  final List<String> folders = <String>[
    '$basePath/controllers',
    '$basePath/repository',
    '$basePath/models',
    '$basePath/views',
    '$basePath/views/widgets',
  ];

  // Define file content
  final String stateNotifierContent = '''
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:$projectName/features/$featureName/controllers/${featureName}_state.dart';
import 'package:$projectName/features/$featureName/repository/${featureName}_repository.dart';

final ${camelCaseName}StateNotifierProvider = StateNotifierProvider<${className}StateNotifier, ${className}State>(
  (ref) => ${className}StateNotifier(
    ${camelCaseName}Repository: ref.read(_${camelCaseName}Repository),
  ),
);

final _${camelCaseName}Repository = Provider((ref) => ${className}Repository());

class ${className}StateNotifier extends StateNotifier<${className}State> {
  ${className}StateNotifier({
    required I${className}Repository ${camelCaseName}Repository,
  })  : _${camelCaseName}Repository = ${camelCaseName}Repository,
        super(${className}State.initial());

  final I${className}Repository _${camelCaseName}Repository;
}
''';

  final String stateContent = '''
class ${className}State {
  ${className}State({
    required this.isLoading,
  });

  ${className}State.initial();

  bool isLoading = false;

  ${className}State copyWith({
    bool? isLoading,
  }) {
    return ${className}State(
      isLoading: isLoading ?? this.isLoading,
    );
  }
}
''';

  final String repositoryContent = '''
abstract interface class I${className}Repository {}

class ${className}Repository implements I${className}Repository {}
''';

  final String screenContent = '''
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ${className}Screen extends ConsumerStatefulWidget {
  const ${className}Screen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _${className}ScreenState();
}

class _${className}ScreenState extends ConsumerState<${className}Screen> {
  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
''';

  // Create folders
  for (final String folder in folders) {
    Directory(folder).createSync(recursive: true);
    print('Created folder: $folder');
  }

  // Create files
  _createFile(
    '$basePath/controllers/${featureName}_state_notifier.dart',
    stateNotifierContent,
  );
  _createFile('$basePath/controllers/${featureName}_state.dart', stateContent);
  _createFile(
    '$basePath/repository/${featureName}_repository.dart',
    repositoryContent,
  );
  _createFile('$basePath/views/${featureName}_screen.dart', screenContent);

  print("Feature '$featureName' created successfully.");
}

void _createFile(String path, String content) {
  File(path).writeAsStringSync(content);
  print('Created file: $path');
}

String _toPascalCase(String input) {
  return input.split('_').map((String word) => word[0].toUpperCase() + word.substring(1)).join();
}

String _toCamelCase(String input) {
  final List<String> parts = input.split('_');
  return parts[0] + parts.skip(1).map((String word) => word[0].toUpperCase() + word.substring(1)).join();
}
