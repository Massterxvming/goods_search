import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../generated/protocol.dart';

/// Server-only connection to the local TypeScript Agents SDK process.
class AgentServiceClient {
  AgentServiceClient({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri =
          baseUri ??
          Uri.parse(
            Platform.environment['AGENT_SERVICE_URL'] ??
                'http://127.0.0.1:8093/',
          );

  final http.Client _client;
  final Uri _baseUri;

  Future<MarketPriceReport> currentPrice(MarketPriceRequest query) async {
    MarketPriceReport empty(String status, String message) => MarketPriceReport(
      status: status,
      message: message,
      productName: query.productName,
      market: query.market,
      currency: query.currency,
      sampleCount: 0,
      sourceCount: 0,
      summary: '',
      methodology: '',
      limitations: [],
      researchedAt: DateTime.now().toUtc(),
      cached: false,
      quotes: [],
      sources: [],
    );
    final product = query.productName.trim();
    if (product.length < 2 ||
        product.length > 120 ||
        query.market.trim().isEmpty ||
        query.market.length > 80 ||
        query.currency != 'CNY') {
      return empty('invalid_request', '请填写具体商品和市场，目前支持人民币报价。');
    }
    try {
      final response = await _client
          .post(
            _baseUri.resolve('v1/market-price'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'productName': product,
              'market': query.market.trim(),
              'currency': query.currency,
            }),
          )
          .timeout(const Duration(seconds: 65));
      final report = MarketPriceReport.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
      const expected = {
        200: {'completed', 'insufficient_data', 'needs_clarification'},
        400: {'invalid_request'},
        429: {'busy'},
        502: {'failed'},
        503: {'not_configured'},
        504: {'failed'},
      };
      if (!(expected[response.statusCode]?.contains(report.status) ?? false)) {
        return empty('failed', '调研服务返回了无法识别的结果。');
      }
      return report;
    } catch (_) {
      return empty('service_unavailable', '调研服务暂不可用，请稍后重试。');
    }
  }

  Future<AgentServiceStatus> getStatus() async {
    try {
      final response = await _client
          .get(_baseUri.resolve('v1/status'))
          .timeout(const Duration(seconds: 2));
      if (response.statusCode != 200) throw const FormatException();
      return AgentServiceStatus.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
    } catch (_) {
      return AgentServiceStatus(
        serviceAvailable: false,
        sdkReady: false,
        modelConfigured: false,
        missingConfiguration: [],
        message: 'Agent 服务暂不可用，请先启动本地 Agent 服务。',
      );
    }
  }

  Future<AgentResearchResult> planResearch(PriceResearchRequest query) async {
    if (query.productName.trim().isEmpty ||
        query.productName.length > 200 ||
        query.market.trim().isEmpty ||
        query.market.length > 80 ||
        !RegExp(r'^[A-Z]{3}$').hasMatch(query.currency) ||
        query.historyMonths < 1 ||
        query.historyMonths > 120 ||
        query.forecastMonths < 0 ||
        query.forecastMonths > 12) {
      return _empty('invalid_request', '请检查商品、市场、币种和查询月份。');
    }
    try {
      final response = await _client
          .post(
            _baseUri.resolve('v1/research-plan'),
            headers: {'Content-Type': 'application/json'},
            // Keep Serverpod's serialization metadata out of the bridge contract.
            body: jsonEncode({
              'productName': query.productName.trim(),
              'market': query.market.trim(),
              'currency': query.currency,
              'historyMonths': query.historyMonths,
              'forecastMonths': query.forecastMonths,
            }),
          )
          .timeout(const Duration(seconds: 35));
      final result = AgentResearchResult.fromJson(
        jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>,
      );
      const expected = {
        200: 'planned',
        400: 'invalid_request',
        429: 'busy',
        502: 'failed',
        503: 'not_configured',
        504: 'failed',
      };
      if (expected[response.statusCode] != result.status) {
        return _empty('failed', 'Agent 服务返回了无法识别的结果。');
      }
      return result;
    } catch (_) {
      return _empty('service_unavailable', 'Agent 服务暂不可用，请稍后重试。');
    }
  }

  static AgentResearchResult _empty(String status, String message) =>
      AgentResearchResult(
        status: status,
        message: message,
        requiredData: [],
        steps: [],
      );

  void close() => _client.close();
}
