import 'package:goods_search_server/src/agent/price_history_service.dart';
import 'package:goods_search_server/src/generated/protocol.dart';
import 'package:test/test.dart';

import 'test_tools/serverpod_test_tools.dart';

void main() {
  withServerpod('Verified price history storage', (sessionBuilder, endpoints) {
    test(
      'persists evidence once and returns month-specific data through the endpoint',
      () async {
        final session = sessionBuilder.build();
        final current = PriceHistoryService.chinaMonth(DateTime.now());
        final past = DateTime.utc(current.year, current.month - 1);
        final key = PriceHistoryService.queryKey('集成测试鼠标', '中国大陆', 'CNY');
        final observations = List.generate(
          3,
          (i) => PriceObservation(
            queryKey: key,
            observationKey: '$key-test-$i',
            platform: '京东',
            productId: '${1001 + i}',
            sourceUrl: 'https://item.jd.com/${1001 + i}.html',
            seller: '测试商家$i',
            priceCents: 1001 + i * 1001,
            priceText: '京东价：${(1001 + i * 1001) / 100}元',
            observedAt: DateTime.utc(past.year, past.month, 10),
          ),
        );
        final store = ServerpodPriceObservationStore(session);
        await store.save(observations);
        await store.save(observations);
        expect((await store.read(key, past, current)).length, 3);
        final report = await endpoints.agent.priceHistory(
          sessionBuilder,
          PriceHistoryRequest(
            productName: '集成测试鼠标',
            market: '中国大陆',
            currency: 'CNY',
            startMonth: past,
            endMonth: past,
          ),
        );
        expect(report.history!.points.single.averagePrice, 20.02);
        expect(report.history!.points.single.quotes.length, 3);
        expect(report.history!.forecast.points, isEmpty);
        expect(report.averagePrice, isNull);
      },
    );
  });
}
