import '../services/serverpod_service.dart';

abstract interface class BackendRepository {
  Future<void> checkConnection();
  void dispose();
}

class ServerpodBackendRepository implements BackendRepository {
  ServerpodBackendRepository(this._service);
  final ServerpodService _service;

  @override
  Future<void> checkConnection() => _service.checkConnection();

  @override
  void dispose() => _service.dispose();
}
