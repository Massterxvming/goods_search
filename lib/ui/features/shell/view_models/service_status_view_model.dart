import 'package:flutter/foundation.dart';

import '../../../../data/repositories/backend_repository.dart';

enum ServiceStatus { checking, online, offline }

class ServiceStatusViewModel extends ChangeNotifier {
  ServiceStatusViewModel(this._repository);
  final BackendRepository _repository;
  ServiceStatus _status = ServiceStatus.checking;
  bool _busy = false;
  bool _disposed = false;

  ServiceStatus get status => _status;

  Future<void> refresh() async {
    if (_busy || _disposed) return;
    _busy = true;
    _status = ServiceStatus.checking;
    notifyListeners();

    var result = ServiceStatus.offline;
    try {
      await _repository.checkConnection();
      result = ServiceStatus.online;
    } catch (_) {
      // Demo navigation stays available when the local server is stopped.
    }
    if (_disposed) return;
    _busy = false;
    _status = result;
    notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    _repository.dispose();
    super.dispose();
  }
}
