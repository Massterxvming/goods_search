import 'dart:io';
import 'dart:math';

/// Creates matching local PostgreSQL and Serverpod credentials once.
void main() {
  final backendDirectory = File.fromUri(Platform.script).parent.parent;
  final environmentFile = File('${backendDirectory.path}/.env');
  final passwordsFile = File(
    '${backendDirectory.path}/goods_search_server/config/passwords.yaml',
  );

  if (environmentFile.existsSync() && passwordsFile.existsSync()) {
    stdout.writeln('Backend credentials already exist; kept existing values.');
    return;
  }

  if (environmentFile.existsSync() || passwordsFile.existsSync()) {
    stderr.writeln(
      'Only one credential file exists. Restore its matching file before '
      'running setup again: backend/.env and '
      'backend/goods_search_server/config/passwords.yaml.',
    );
    exitCode = 1;
    return;
  }

  final random = Random.secure();
  String secret() => List.generate(
    32,
    (_) => random.nextInt(256).toRadixString(16).padLeft(2, '0'),
  ).join();

  final developmentPassword = secret();
  final testPassword = secret();

  environmentFile.writeAsStringSync(
    '# Generated local credentials. Do not commit.\n'
    'GOODS_SEARCH_DATABASE_PASSWORD=$developmentPassword\n'
    'GOODS_SEARCH_TEST_DATABASE_PASSWORD=$testPassword\n',
  );
  passwordsFile.writeAsStringSync(
    '# Generated local credentials. Do not commit.\n'
    'development:\n'
    '  database: "$developmentPassword"\n'
    '  serviceSecret: "${secret()}"\n'
    'test:\n'
    '  database: "$testPassword"\n'
    '  serviceSecret: "${secret()}"\n',
  );

  if (!Platform.isWindows) {
    Process.runSync('chmod', ['600', environmentFile.path, passwordsFile.path]);
  }

  stdout.writeln('Created local development and test database credentials.');
}
