import 'package:goods_search_server/src/agent/price_history_service.dart';
import 'package:goods_search_server/src/generated/protocol.dart';
import 'package:test/test.dart';

final now = DateTime.utc(2026, 11, 17, 12);

PriceHistoryRequest query({int start = 9, int end = 11}) => PriceHistoryRequest(
  productName: '测试鼠标',
  market: '中国大陆',
  currency: 'CNY',
  startMonth: DateTime.utc(2026, start),
  endMonth: DateTime.utc(2026, end),
);

PriceObservation observation(
  int month,
  int product,
  int cents, {
  int day = 10,
  String? key,
}) => PriceObservation(
  queryKey: key ?? PriceHistoryService.queryKey('测试鼠标', '中国大陆', 'CNY'),
  observationKey: '$month-$product-$day',
  platform: '京东',
  productId: '$product',
  sourceUrl: 'https://item.jd.com/$product.html',
  seller: '测试商家',
  priceCents: cents,
  priceText: '京东价：${cents / 100}元',
  observedAt: DateTime.utc(2026, month, day),
);

List<PriceObservation> monthSamples(int month, int cents) =>
    List.generate(3, (i) => observation(month, 1001 + i, cents));

MarketPriceReport currentReport() => MarketPriceReport(
  status: 'insufficient_data',
  message: '样本不足',
  productName: '测试鼠标',
  market: '中国大陆',
  currency: 'CNY',
  sampleCount: 1,
  sourceCount: 1,
  summary: '',
  methodology: '',
  limitations: [],
  researchedAt: now,
  cached: true,
  quotes: [
    MarketPriceQuote(
      sourceId: 's1',
      seller: '商家',
      price: 10.01,
      priceText: '京东价：10.01元',
    ),
  ],
  sources: [
    MarketPriceSource(
      id: 's1',
      title: '商品页',
      url: 'https://item.jd.com/1001.html',
      platform: '京东',
      productId: '1001',
      fetchedAt: now,
    ),
  ],
);

class MemoryStore implements PriceObservationStore {
  final items = <String, PriceObservation>{};
  @override
  Future<void> save(List<PriceObservation> observations) async {
    for (final item in observations) {
      items.putIfAbsent(item.observationKey, () => item);
    }
  }

  @override
  Future<List<PriceObservation>> read(
    String key,
    DateTime start,
    DateTime endExclusive,
  ) async => items.values
      .where(
        (s) =>
            s.queryKey == key &&
            !s.observedAt.isBefore(start) &&
            s.observedAt.isBefore(endExclusive),
      )
      .toList();
}

void main() {
  test(
    'rejects reversed, future, non-month and older-than-24-month intervals before lookup',
    () async {
      var calls = 0;
      final service = PriceHistoryService(
        store: MemoryStore(),
        clock: () => now,
        lookup: (_) async {
          calls++;
          return currentReport();
        },
      );
      for (final invalid in [
        query(start: 11, end: 10),
        query(end: 12),
        query()..startMonth = DateTime.utc(2024, 11),
        query()..startMonth = DateTime.utc(2026, 9, 2),
      ]) {
        expect((await service.research(invalid)).status, 'invalid_request');
      }
      expect(calls, 0);
      expect(
        PriceHistoryService.validate(
          query()..startMonth = DateTime.utc(2024, 12),
          now,
        ),
        isNull,
      );
    },
  );

  test(
    'queries historical-only ranges without calling a current-price model',
    () async {
      final store = MemoryStore();
      await store.save(monthSamples(9, 10000));
      final service = PriceHistoryService(
        store: store,
        clock: () => now,
        lookup: (_) async => throw StateError('must not fetch today'),
      );
      final report = await service.research(query(end: 10));
      expect(report.averagePrice, isNull);
      expect(report.history!.points.map((p) => p.averagePrice), [100, null]);
      expect(report.history!.forecast.points, isEmpty);
    },
  );

  test(
    'repeated cached quotes stay one observation and cannot fill previous months',
    () async {
      final store = MemoryStore();
      final service = PriceHistoryService(
        store: store,
        clock: () => now,
        lookup: (_) async => currentReport(),
      );
      await service.research(query());
      final report = await service.research(query());
      expect(store.items.length, 1);
      expect(report.history!.points.map((p) => p.sampleCount), [0, 0, 1]);
      expect(
        report.history!.points.every((p) => p.averagePrice == null),
        isTrue,
      );
    },
  );

  test(
    'uses latest SKU observation, cents rounding, outlier filtering and explicit gaps',
    () {
      final history = PriceHistoryService.buildHistory(query(), [
        observation(9, 1001, 1001),
        observation(9, 1002, 2002),
        observation(9, 1003, 3003),
        observation(9, 1001, 2002, day: 11),
        observation(9, 1004, 9999999),
        observation(9, 2000, 1000, key: 'another product'),
        ...monthSamples(11, 1500),
      ], now);
      expect(history.points.map((p) => p.averagePrice), [23.36, null, 15]);
      expect(history.points.map((p) => p.sampleCount), [3, 0, 3]);
      expect(
        history.points.first.quotes.first.observedAt,
        DateTime.utc(2026, 9, 11),
      );
      expect(history.coveredMonths, 2);
      expect(history.changePercent, -35.79);
      expect(history.forecast.status, 'insufficient_data');
    },
  );

  test(
    'groups at China calendar-month boundaries and excludes third-party URLs',
    () {
      final boundary = observation(10, 1001, 1000)
        ..observedAt = DateTime.utc(2026, 9, 30, 16);
      final thirdParty = observation(10, 1004, 1000)
        ..sourceUrl = 'https://price.example/1004';
      final history = PriceHistoryService.buildHistory(query(), [
        boundary,
        observation(10, 1002, 1000),
        observation(10, 1003, 1000),
        thirdParty,
      ], now);
      expect(history.points[0].sampleCount, 0);
      expect(history.points[1].sampleCount, 3);
      expect(history.points[1].averagePrice, 10);
    },
  );

  test(
    'produces a reproducible three-month linear forecast only from a current consecutive history',
    () {
      final history = PriceHistoryService.buildHistory(query(), [
        ...monthSamples(9, 10000),
        ...monthSamples(10, 9000),
        ...monthSamples(11, 8000),
      ], now);
      expect(history.forecast.status, 'available');
      expect(history.forecast.sampleMonths, 3);
      expect(history.forecast.points.map((p) => p.predictedPrice), [
        70,
        60,
        50,
      ]);
      expect(history.forecast.points.map((p) => p.month), [
        DateTime.utc(2026, 12),
        DateTime.utc(2027, 1),
        DateTime.utc(2027, 2),
      ]);
      expect(history.changePercent, -20);
    },
  );

  test(
    'does not predict from stale history, gaps, sparse samples or an unstable trend',
    () {
      for (final samples in [
        [...monthSamples(9, 10000), ...monthSamples(10, 9000)],
        [...monthSamples(9, 10000), ...monthSamples(11, 8000)],
        [
          ...monthSamples(9, 10000),
          ...monthSamples(10, 9000),
          observation(11, 1001, 8000),
        ],
        [
          ...monthSamples(9, 10000),
          ...monthSamples(10, 5000),
          ...monthSamples(11, 1000),
        ],
      ]) {
        final forecast = PriceHistoryService.buildHistory(
          query(),
          samples,
          now,
        ).forecast;
        expect(forecast.points, isEmpty);
        expect(forecast.status, 'insufficient_data');
      }
      final stale = PriceHistoryService.buildHistory(query(start: 8, end: 10), [
        ...monthSamples(8, 10000),
        ...monthSamples(9, 9000),
        ...monthSamples(10, 8000),
      ], now).forecast;
      expect(stale.points, isEmpty);
    },
  );

  test(
    'persistence rejects stale pages, invalid money and non-platform products',
    () {
      final valid = currentReport();
      final key = PriceHistoryService.queryKey(
        valid.productName,
        valid.market,
        valid.currency,
      );
      expect(
        PriceHistoryService.observationsFromReport(valid, key, now).length,
        1,
      );
      for (final source in [
        valid.sources.single.copyWith(
          url: 'https://item.jd.com.evil.example/1001.html',
        ),
        valid.sources.single.copyWith(
          fetchedAt: now.subtract(const Duration(hours: 1)),
        ),
        valid.sources.single.copyWith(productId: '2002'),
      ]) {
        expect(
          PriceHistoryService.observationsFromReport(
            valid.copyWith(sources: [source]),
            key,
            now,
          ),
          isEmpty,
        );
      }
      expect(
        PriceHistoryService.observationsFromReport(
          valid.copyWith(quotes: [valid.quotes.single.copyWith(price: 1.001)]),
          key,
          now,
        ),
        isEmpty,
      );
    },
  );
}
