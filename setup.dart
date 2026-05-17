// ignore_for_file: avoid_print

import 'dart:io';

void main() async {
  print('===================================================');
  print('🛠️  Aether Environment Setup');
  print('===================================================');

  // 1. Validate Root Directory
  final File pubspec = File('pubspec.yaml');
  if (!pubspec.existsSync()) {
    print('❌ ERROR: pubspec.yaml not found.');
    print('💡 HEALING ACTION: You must run this script from the root of your Flutter project.');
    exit(1);
  }

  // 2. Inject Required Dependencies
  print('📦 Checking testing & linting dependencies...');
  final String pubspecContent = pubspec.readAsStringSync();
  final List<String> missingDeps = <String>[];

  if (!pubspecContent.contains('fake_cloud_firestore:')) missingDeps.add('fake_cloud_firestore');
  if (!pubspecContent.contains('flutter_lints:')) missingDeps.add('flutter_lints');

  if (missingDeps.isNotEmpty) {
    print('⚙️  Injecting missing dev_dependencies: ${missingDeps.join(', ')}...');
    final ProcessResult result = await Process.run('flutter', <String>['pub', 'add', '--dev', ...missingDeps]);
    if (result.exitCode != 0) {
      print('❌ ERROR: Failed to add dependencies. Please add them manually.');
      print(result.stderr);
      exit(1);
    }
    print('✅ Dependencies injected successfully.');
  } else {
    print('✅ All necessary dev_dependencies are present.');
  }

  // 3. Ensure Git is present and healthy
  final Directory gitDir = Directory('.git');
  if (!gitDir.existsSync()) {
    print('⚠️  No .git directory found. Initializing git...');
    final ProcessResult gitInit = await Process.run('git', <String>['init']);
    if (gitInit.exitCode != 0) {
      print('❌ ERROR: Git is not installed or accessible. The telemetry hook cannot be installed.');
      print('💡 HEALING ACTION: Install Git, run "git init", and re-run this script.');
      exit(1);
    }
  }

  final Directory hookDir = Directory('.git/hooks');
  if (!hookDir.existsSync()) {
    hookDir.createSync(recursive: true);
  }

  // 4. Generate the robust compiler script
  _generateCompilerScript();

  // 5. Safely append to pre-commit hook (do not overwrite existing hooks)
  final bool isWindows = Platform.isWindows;
  final File hookFile = File('.git/hooks/pre-commit');
  const String hookCommand = r'''
cd "$(git rev-parse --show-toplevel)" || exit 1
dart aether_compiler.dart
if [ -f AETHER_TELEMETRY.md ]; then
  git add AETHER_TELEMETRY.md
fi''';

  if (hookFile.existsSync()) {
    final String currentHook = hookFile.readAsStringSync();
    if (!currentHook.contains('aether_compiler.dart')) {
      print('🔗 Appending Aether telemetry to existing pre-commit hook...');
      hookFile.writeAsStringSync('\n# Aether Telemetry\n$hookCommand\n', mode: FileMode.append);
    } else {
      print('✅ Aether telemetry already present in pre-commit hook.');
    }
  } else {
    print('🔗 Creating new pre-commit hook...');
    hookFile.writeAsStringSync('#!/bin/sh\n# Aether Telemetry\n$hookCommand\n');
  }

  if (!isWindows) {
    final ProcessResult chmod = await Process.run('chmod', <String>['+x', '.git/hooks/pre-commit']);
    if (chmod.exitCode != 0) {
      print('⚠️  WARNING: Could not mark pre-commit hook as executable.');
    }
  }

  print('\n✅ SETUP COMPLETE. The Aether "Flight Recorder" is active.');
  print('-> You can now write code normally. Your architectural decisions will be safely logged on commit.');
  print('===================================================');
}

void _generateCompilerScript() {
  const String compilerCode = r'''
import 'dart:io';

void main() {
  final dir = Directory('lib');
  if (!dir.existsSync()) return; // Fail silently so we don't break the user's git commit

  int setStateCount = 0;
  int valueNotifierCount = 0;
  int repaintBoundaryCount = 0;
  int transactionCount = 0;
  int incrementCount = 0;
  final thoughts = <String>[];

  for (final entity in dir.listSync(recursive: true)) {
    if (entity is! File || !entity.path.endsWith('.dart')) continue;

    try {
      final lines = entity.readAsLinesSync();
      for (var i = 0; i < lines.length; i++) {
        final line = lines[i].trim();
        if (line.isEmpty || line.startsWith('//')) continue;

        if (line.contains('setState(')) setStateCount++;
        if (line.contains('ValueNotifier')) valueNotifierCount++;
        if (line.contains('RepaintBoundary')) repaintBoundaryCount++;
        if (line.contains('runTransaction')) transactionCount++;
        if (line.contains('FieldValue.increment')) incrementCount++;

        if (line.contains('// @AETHER:')) {
          final note = line.substring(line.indexOf('// @AETHER:') + 11).trim();
          thoughts.add('- **${entity.uri.pathSegments.last}** (Line ${i + 1}): $note');
        }
      }
    } catch (_) {
      // Catch read errors (e.g. encoding issues) and skip gracefully
    }
  }

  final telemetryFile = File('AETHER_TELEMETRY.md');
  final output = StringBuffer('# Aether Automated Telemetry Report\n\n');
  output.writeln('> Auto-generated by the pre-commit "Flight Recorder".\n');

  output.writeln('## 1. Architectural Fingerprint');
  if (transactionCount > 0 || incrementCount > 0) {
    output.writeln(
      '✅ Atomic operations detected (`runTransaction`: $transactionCount, `increment`: $incrementCount)',
    );
  } else {
    output.writeln('❌ No atomic operations detected.');
  }

  output.writeln('\n### UI Performance');
  output.writeln(
    '- `setState`: $setStateCount | `ValueNotifier`: $valueNotifierCount | `RepaintBoundary`: $repaintBoundaryCount',
  );

  if (valueNotifierCount > 0 || repaintBoundaryCount > 0) {
    output.writeln('✅ Targeted repaints detected.');
  } else if (setStateCount > 3) {
    output.writeln('⚠️ High `setState` usage without localized rebuilds.');
  }

  output.writeln('\n## 2. Developer Thought Log');
  if (thoughts.isNotEmpty) {
    for (final thought in thoughts) {
      output.writeln(thought);
    }
  } else {
    output.writeln('*No inline `// @AETHER:` comments found.*');
  }

  try {
    telemetryFile.writeAsStringSync(output.toString());
  } catch (_) {
    // Failsafe
  }
}
''';

  File('aether_compiler.dart').writeAsStringSync(compilerCode);
}
