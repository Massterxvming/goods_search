import 'dart:convert';

import 'package:goods_search_server/src/agent/agent_service_client.dart';
import 'package:goods_search_server/src/generated/protocol.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:test/test.dart';

PriceResearchRequest query({int historyMonths = 12}) => PriceResearchRequest(
  productName: '测试显卡型号',
  market: '中国大陆',
  currency: 'CNY',
  historyMonths: historyMonths,
  forecastMonths: 3,
);

http.Response jsonResponse(Object value, int code) => http.Response.bytes(
  utf8.encode(jsonEncode(value)),
  code,
  headers: {'content-type': 'application/json; charset=utf-8'},
);

void main() {
  test(
    'current-price RPC forwards only query fields and preserves sourced numeric results',
    () async {
      final client = AgentServiceClient(
        client: MockClient((request) async {
          expect(request.url.path, '/v1/market-price');
          expect(jsonDecode(request.body), {
            'productName': '测试鼠标',
            'market': '中国大陆',
            'currency': 'CNY',
          });
          return jsonResponse({
            'status': 'completed',
            'message': '调研完成',
            'productName': '测试鼠标',
            'market': '中国大陆',
            'currency': 'CNY',
            'averagePrice': 20.02,
            'lowestPrice': 10.01,
            'highestPrice': 30.03,
            'sampleCount': 3,
            'sourceCount': 3,
            'summary': '三条报价',
            'methodology': '等权平均',
            'limitations': [],
            'researchedAt': '2026-11-16T12:00:00.000Z',
            'cached': false,
            'quotes': [
              {
                'sourceId': 's1',
                'seller': '商家',
                'price': 10.01,
                'priceText': '页面价10.01元',
              },
            ],
            'sources': [
              {
                'id': 's1',
                'title': '商品页',
                'url': 'https://item.jd.com/1001.html',
                'publishedAt': null,
                'platform': '京东',
                'productId': '1001',
                'fetchedAt': '2026-11-16T12:00:00.000Z',
                'accessStatus': 'readable',
                'accessMessage': '已读取商品页正文。',
              },
            ],
            'diagnostics': {
              'searches': [
                {
                  'platform': '京东',
                  'status': 'completed',
                  'resultCount': 1,
                  'productPageCount': 1,
                  'message': '找到1个详情链接。',
                },
              ],
              'attemptedPages': 1,
              'readablePages': 1,
              'evidencePages': 1,
              'loginRequiredPages': 0,
              'verificationRequiredPages': 0,
              'modelInvoked': true,
            },
          }, 200);
        }),
      );
      addTearDown(client.close);
      final result = await client.currentPrice(
        MarketPriceRequest(
          productName: ' 测试鼠标 ',
          market: '中国大陆',
          currency: 'CNY',
        ),
      );
      expect(result.status, 'completed');
      expect(result.averagePrice, 20.02);
      expect(result.quotes.single.price, 10.01);
      expect(result.sources.single.url, 'https://item.jd.com/1001.html');
      expect(result.sources.single.platform, '京东');
      expect(result.sources.single.productId, '1001');
      expect(result.sources.single.accessStatus, 'readable');
      expect(result.diagnostics!.searches.single.productPageCount, 1);
      expect(result.diagnostics!.modelInvoked, isTrue);
      expect(result.sources.single.fetchedAt!.isUtc, isTrue);
      expect(result.researchedAt.isUtc, isTrue);
    },
  );

  test(
    'current-price input is rejected before forwarding unsupported currencies',
    () async {
      var called = false;
      final client = AgentServiceClient(
        client: MockClient((_) async {
          called = true;
          return http.Response('', 500);
        }),
      );
      addTearDown(client.close);
      final result = await client.currentPrice(
        MarketPriceRequest(
          productName: '测试鼠标',
          market: '中国大陆',
          currency: 'USD',
        ),
      );
      expect(result.status, 'invalid_request');
      expect(result.averagePrice, isNull);
      expect(called, isFalse);
    },
  );

  test(
    'current-price malformed upstream data returns a failure without prices',
    () async {
      final client = AgentServiceClient(
        client: MockClient(
          (_) async => http.Response('<html>error</html>', 502),
        ),
      );
      addTearDown(client.close);
      final result = await client.currentPrice(
        MarketPriceRequest(
          productName: '测试鼠标',
          market: '中国大陆',
          currency: 'CNY',
        ),
      );
      expect(result.status, 'service_unavailable');
      expect(result.averagePrice, isNull);
      expect(result.quotes, isEmpty);
    },
  );

  test(
    'reports SDK readiness separately from missing model configuration',
    () async {
      final client = AgentServiceClient(
        client: MockClient((request) async {
          expect(request.url.path, '/v1/status');
          return jsonResponse({
            'serviceAvailable': true,
            'sdkReady': true,
            'modelConfigured': false,
            'missingConfiguration': ['AGENT_MODEL_API_KEY'],
            'message': '模型尚未配置。',
          }, 200);
        }),
      );
      addTearDown(client.close);
      final status = await client.getStatus();
      expect(status.serviceAvailable, isTrue);
      expect(status.sdkReady, isTrue);
      expect(status.modelConfigured, isFalse);
      expect(status.missingConfiguration, ['AGENT_MODEL_API_KEY']);
    },
  );

  test(
    'maps connection errors to an unavailable service without throwing',
    () async {
      final client = AgentServiceClient(
        client: MockClient((_) async {
          throw http.ClientException('Local service stopped');
        }),
      );
      addTearDown(client.close);
      expect((await client.getStatus()).serviceAvailable, isFalse);
      expect(
        (await client.planResearch(query())).status,
        'service_unavailable',
      );
    },
  );

  test(
    'forwards only bridge fields and preserves the unconfigured result',
    () async {
      final client = AgentServiceClient(
        client: MockClient((request) async {
          expect(request.url.path, '/v1/research-plan');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(
            body.keys,
            unorderedEquals([
              'productName',
              'market',
              'currency',
              'historyMonths',
              'forecastMonths',
            ]),
          );
          expect(body['productName'], '测试显卡型号');
          return jsonResponse({
            'status': 'not_configured',
            'message': '模型 API 尚未配置。',
            'summary': null,
            'requiredData': [],
            'steps': [],
          }, 503);
        }),
      );
      addTearDown(client.close);
      final result = await client.planResearch(query());
      expect(result.status, 'not_configured');
      expect(result.summary, isNull);
      expect(result.steps, isEmpty);
    },
  );

  test('invalid ranges are rejected before forwarding a request', () async {
    var called = false;
    final client = AgentServiceClient(
      client: MockClient((_) async {
        called = true;
        return http.Response('', 500);
      }),
    );
    addTearDown(client.close);
    expect(
      (await client.planResearch(query(historyMonths: 0))).status,
      'invalid_request',
    );
    expect(called, isFalse);
  });

  test('malformed upstream data produces a defined failure', () async {
    final client = AgentServiceClient(
      client: MockClient(
        (_) async => http.Response('<html>not JSON</html>', 200),
      ),
    );
    addTearDown(client.close);
    expect((await client.getStatus()).sdkReady, isFalse);
    expect((await client.planResearch(query())).status, 'service_unavailable');
  });
}
