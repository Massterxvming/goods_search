import 'dart:io';

import 'package:serverpod/serverpod.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

/// The starting point of the Serverpod server.
void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(args, Protocol(), Endpoints());

  // Serve the Flutter preview on the web port (8082) alongside the API.
  final webDirectory = Directory(
    Platform.environment['GOODS_SEARCH_WEB_DIR'] ?? '../../build/web',
  );
  pod.webServer.addRoute(
    FlutterRoute(
      webDirectory,
      cacheControlFactory: pod.runMode == ServerpodRunMode.development
          ? StaticRoute.noStore()
          : null,
    ),
  );

  // Start the server.
  await pod.start();
}
