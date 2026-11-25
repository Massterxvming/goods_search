import 'package:flutter/foundation.dart';
import 'package:goods_search_client/goods_search_client.dart';

import '../../domain/models/price_history.dart';

class ServerpodService {
  Client? _client;
  Client get _connection => _client ??= Client(
    _serverUrl,
    connectionTimeout: const Duration(seconds: 70),
  );

  static String get _serverUrl {
    const configured = String.fromEnvironment('SERVERPOD_URL');
    if (configured.isNotEmpty) {
      return configured.endsWith('/') ? configured : '$configured/';
    }
    if (kIsWeb) {
      return Uri(
        scheme: Uri.base.scheme,
        host: Uri.base.host,
        port: 8080,
        path: '/',
      ).toString();
    }
    return defaultTargetPlatform == TargetPlatform.android
        ? 'http://10.0.2.2:8080/'
        : 'http://localhost:8080/';
  }

  Future<void> checkConnection() async {
    await _connection.greeting
        .hello('goods_search')
        .timeout(const Duration(seconds: 5));
  }

  Future<MarketPriceReport> currentPrice(
    String productName, {
    required PriceHistoryRange range,
  }) => _connection.agent
      .priceHistory(
        PriceHistoryRequest(
          productName: productName,
          market: '中国大陆',
          currency: 'CNY',
          startMonth: range.startMonth,
          endMonth: range.endMonth,
        ),
      )
      .timeout(const Duration(seconds: 70));

  void dispose() => _client?.close();
}
