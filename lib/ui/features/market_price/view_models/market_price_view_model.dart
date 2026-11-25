import 'package:flutter/foundation.dart';

import '../../../../data/repositories/market_price_repository.dart';
import '../../../../domain/models/current_price_report.dart';
import '../../../../domain/models/price_history.dart';

class MarketPriceViewModel extends ChangeNotifier {
  MarketPriceViewModel(this._repository);
  final MarketPriceRepository _repository;
  bool _busy = false;
  bool _disposed = false;
  CurrentPriceReport? _report;
  String? _error;
  PriceHistoryRange _range = PriceHistoryRange.recent(6);
  bool _customRange = false;

  bool get isLoading => _busy;
  CurrentPriceReport? get report => _report;
  String? get error => _error;
  PriceHistoryRange get range => _range;
  bool get isCustomRange => _customRange;

  void selectRange(PriceHistoryRange value, {bool custom = false}) {
    if (_busy || _disposed) return;
    _range = value;
    _customRange = custom;
    // A changed range needs an explicit query so old results cannot be mistaken
    // for results for the newly selected window.
    _report = null;
    _error = null;
    notifyListeners();
  }

  Future<void> research(String productName) async {
    if (_busy || _disposed) return;
    _busy = true;
    _report = null;
    _error = null;
    notifyListeners();
    try {
      final result = await _repository.research(
        productName.trim(),
        range: _range,
      );
      if (_disposed) return;
      if ([
            'completed',
            'insufficient_data',
            'needs_clarification',
          ].contains(result.status) ||
          result.history != null) {
        _report = result;
      } else {
        _error = result.message;
      }
    } catch (_) {
      if (_disposed) return;
      _error = '暂时无法完成调研，请检查网络或稍后重试。';
    } finally {
      if (!_disposed) {
        _busy = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
