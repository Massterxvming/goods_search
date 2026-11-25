import 'dart:convert';
import 'dart:math' as math;

import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';

typedef CurrentPriceLookup =
    Future<MarketPriceReport> Function(
      MarketPriceRequest query,
    );

/// The stored timestamp is the page fetch time, never the search index date.
abstract interface class PriceObservationStore {
  Future<void> save(List<PriceObservation> observations);
  Future<List<PriceObservation>> read(
    String queryKey,
    DateTime start,
    DateTime endExclusive,
  );
}

class ServerpodPriceObservationStore implements PriceObservationStore {
  ServerpodPriceObservationStore(this._session);
  final Session _session;

  @override
  Future<void> save(List<PriceObservation> observations) async {
    if (observations.isEmpty) return;
    // Cached responses and concurrent searches must not create extra samples.
    await PriceObservation.db.insert(
      _session,
      observations,
      ignoreConflicts: true,
    );
  }

  @override
  Future<List<PriceObservation>> read(
    String queryKey,
    DateTime start,
    DateTime endExclusive,
  ) => PriceObservation.db.find(
    _session,
    where: (t) =>
        t.queryKey.equals(queryKey) &
        (t.observedAt >= start) &
        (t.observedAt < endExclusive),
    orderBy: (t) => t.observedAt,
  );
}

/// History is built from verified platform observations, not LLM recollection.
class PriceHistoryService {
  PriceHistoryService({
    required PriceObservationStore store,
    required CurrentPriceLookup lookup,
    DateTime Function()? clock,
  }) : _store = store,
       _lookup = lookup,
       _clock = clock ?? DateTime.now;

  final PriceObservationStore _store;
  final CurrentPriceLookup _lookup;
  final DateTime Function() _clock;

  static DateTime chinaMonth(DateTime date) {
    final china = date.toUtc().add(const Duration(hours: 8));
    return DateTime.utc(china.year, china.month);
  }

  static String queryKey(String product, String market, String currency) =>
      jsonEncode([
        'platform-product-v2',
        product.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase(),
        market.trim(),
        currency,
      ]);

  static String? validate(PriceHistoryRequest query, DateTime now) {
    final current = chinaMonth(now);
    final earliest = DateTime.utc(current.year, current.month - 23);
    if (query.productName.trim().length < 2 ||
        query.productName.trim().length > 120 ||
        query.market.trim() != '中国大陆' ||
        query.currency != 'CNY') {
      return '请填写具体商品，目前支持中国大陆人民币报价。';
    }
    for (final date in [query.startMonth, query.endMonth]) {
      if (date != DateTime.utc(date.year, date.month)) {
        return '查询区间请按月份选择。';
      }
    }
    if (query.startMonth.isAfter(query.endMonth) ||
        query.startMonth.isBefore(earliest) ||
        query.endMonth.isAfter(current)) {
      return '请选择最近24个月内的有效起止月份，结束月份不能晚于本月。';
    }
    return null;
  }

  Future<MarketPriceReport> research(PriceHistoryRequest query) async {
    final now = _clock().toUtc();
    final error = validate(query, now);
    if (error != null) return _empty(query, 'invalid_request', error, now);
    final current = chinaMonth(now);
    final includesCurrent = query.endMonth == current;
    final report = includesCurrent
        ? await _lookup(
            MarketPriceRequest(
              productName: query.productName.trim(),
              market: query.market.trim(),
              currency: query.currency,
            ),
          )
        : _empty(
            query,
            'insufficient_data',
            '此区间仅查询已核验的历史采样，不将今日在售价填入过去月份。',
            now,
          );
    final key = queryKey(query.productName, query.market, query.currency);
    await _store.save(observationsFromReport(report, key, _clock().toUtc()));
    // Calendar months follow the shopping market's timezone (UTC+8).
    final observations = await _store.read(
      key,
      query.startMonth.subtract(const Duration(hours: 8)),
      DateTime.utc(
        query.endMonth.year,
        query.endMonth.month + 1,
      ).subtract(const Duration(hours: 8)),
    );
    return report.copyWith(
      history: buildHistory(query, observations, _clock().toUtc()),
    );
  }

  /// Defense at the persistence boundary, in addition to the Agent's checks.
  static List<PriceObservation> observationsFromReport(
    MarketPriceReport report,
    String key,
    DateTime now,
  ) {
    if (!['completed', 'insufficient_data'].contains(report.status)) return [];
    final result = <String, PriceObservation>{};
    for (final quote in report.quotes) {
      final sources = report.sources.where((s) => s.id == quote.sourceId);
      if (sources.length != 1) continue;
      final source = sources.single;
      final time = source.fetchedAt?.toUtc();
      if (time == null ||
          time.isBefore(now.subtract(const Duration(minutes: 15))) ||
          time.isAfter(now.add(const Duration(minutes: 1))) ||
          !isPlatformProduct(source.platform, source.productId, source.url) ||
          !quote.price.isFinite ||
          quote.price <= 0 ||
          quote.price > 1000000 ||
          (quote.price * 100 - (quote.price * 100).round()).abs() > 0.0001 ||
          quote.priceText.trim().isEmpty) {
        continue;
      }
      final observationKey = jsonEncode([
        key,
        source.platform,
        source.productId,
        time.toIso8601String(),
      ]);
      result[observationKey] = PriceObservation(
        queryKey: key,
        observationKey: observationKey,
        platform: source.platform,
        productId: source.productId,
        sourceUrl: source.url,
        seller: quote.seller,
        priceCents: (quote.price * 100).round(),
        priceText: quote.priceText,
        observedAt: time,
      );
    }
    return result.values.toList();
  }

  static bool isPlatformProduct(String platform, String id, String address) {
    final uri = Uri.tryParse(address);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        uri.hasPort ||
        !RegExp(r'^\d{1,24}$').hasMatch(id)) {
      return false;
    }
    return switch (platform) {
      '京东' =>
        uri.host == 'item.jd.com' && uri.path == '/$id.html' && !uri.hasQuery,
      '淘宝' =>
        uri.host == 'item.taobao.com' &&
            uri.path == '/item.htm' &&
            uri.query == 'id=$id',
      '天猫' =>
        uri.host == 'detail.tmall.com' &&
            uri.path == '/item.htm' &&
            uri.query == 'id=$id',
      '拼多多' =>
        uri.host == 'mobile.yangkeduo.com' &&
            uri.path == '/goods.html' &&
            uri.query == 'goods_id=$id',
      _ => false,
    };
  }

  static MarketPriceHistory buildHistory(
    PriceHistoryRequest query,
    List<PriceObservation> observations,
    DateTime now,
  ) {
    final key = queryKey(query.productName, query.market, query.currency);
    final byMonth = <DateTime, Map<String, PriceObservation>>{};
    for (final item in observations) {
      if (item.queryKey != key ||
          item.priceCents <= 0 ||
          item.priceCents > 100000000 ||
          item.observedAt.isAfter(now) ||
          !isPlatformProduct(item.platform, item.productId, item.sourceUrl)) {
        continue;
      }
      final month = chinaMonth(item.observedAt);
      if (month.isBefore(query.startMonth) || month.isAfter(query.endMonth)) {
        continue;
      }
      final products = byMonth.putIfAbsent(month, () => {});
      final product = '${item.platform}:${item.productId}';
      final previous = products[product];
      if (previous == null || item.observedAt.isAfter(previous.observedAt)) {
        products[product] = item;
      }
    }
    final points = <MonthlyPricePoint>[];
    for (
      var month = query.startMonth;
      !month.isAfter(query.endMonth);
      month = DateTime.utc(month.year, month.month + 1)
    ) {
      var samples = byMonth[month]?.values.toList() ?? <PriceObservation>[];
      samples.sort((a, b) => a.priceCents.compareTo(b.priceCents));
      if (samples.length >= 3) {
        final middle = samples.length ~/ 2;
        final median = samples.length.isOdd
            ? samples[middle].priceCents.toDouble()
            : (samples[middle - 1].priceCents + samples[middle].priceCents) / 2;
        samples = samples
            .where(
              (s) =>
                  s.priceCents >= median / 2.5 && s.priceCents <= median * 2.5,
            )
            .toList();
      }
      final enough = samples.length >= 3;
      points.add(
        MonthlyPricePoint(
          month: month,
          averagePrice: enough
              ? (samples.fold<int>(0, (sum, s) => sum + s.priceCents) /
                            samples.length)
                        .round() /
                    100
              : null,
          lowestPrice: enough ? samples.first.priceCents / 100 : null,
          highestPrice: enough ? samples.last.priceCents / 100 : null,
          sampleCount: samples.length,
          quotes: samples
              .map(
                (s) => HistoricalPriceQuote(
                  platform: s.platform,
                  productId: s.productId,
                  url: s.sourceUrl,
                  seller: s.seller,
                  price: s.priceCents / 100,
                  observedAt: s.observedAt,
                  evidence: s.priceText,
                ),
              )
              .toList(),
        ),
      );
    }
    final first = points.first.averagePrice;
    final last = points.last.averagePrice;
    return MarketPriceHistory(
      startMonth: query.startMonth,
      endMonth: query.endMonth,
      coveredMonths: points.where((p) => p.averagePrice != null).length,
      changePercent: points.length >= 2 && first != null && last != null
          ? ((last / first - 1) * 10000).round() / 100
          : null,
      points: points,
      forecast: forecast(points, now),
      methodology:
          '按中国大陆自然月汇总同一查询的已核验平台在售价。每月每个平台商品ID仅取最后一次采样，至少3个不同商品ID才计算等权均价；超出中位数2.5倍范围的异常报价剔除。缺失月份不补值、不连线。',
      limitations: [
        '历史采样库从接入后开始积累，无法由今日商品页还原过去两年的价格。',
        '月度采样均价不代表整月订单成交均价；本月尚未结束，各月商家样本可能不同。',
        '仅匹配相同商品查询、市场和币种；品牌、型号、规格不同请分别查询。',
      ],
    );
  }

  static PriceForecast forecast(List<MonthlyPricePoint> points, DateTime now) {
    final current = chinaMonth(now);
    final consecutive = <MonthlyPricePoint>[];
    for (final point in points.reversed) {
      if (point.averagePrice == null) break;
      consecutive.insert(0, point);
    }
    PriceForecast unavailable(String message) => PriceForecast(
      status: 'insufficient_data',
      method: 'linear_regression',
      message: message,
      sampleMonths: consecutive.length,
      points: [],
    );
    if (points.isEmpty ||
        points.last.month != current ||
        consecutive.length < 3) {
      return unavailable('需要截至本月连续至少3个月、每月不少于3个商品样本的核验均价，暂不生成预测。');
    }
    // Use up to six recent comparable monthly samples for a short projection.
    final fit = consecutive.skip(math.max(0, consecutive.length - 6)).toList();
    final n = fit.length;
    final xMean = (n - 1) / 2;
    final yMean = fit.fold<double>(0, (sum, p) => sum + p.averagePrice!) / n;
    var numerator = 0.0;
    var denominator = 0.0;
    for (var i = 0; i < n; i++) {
      numerator += (i - xMean) * (fit[i].averagePrice! - yMean);
      denominator += math.pow(i - xMean, 2);
    }
    final slope = numerator / denominator;
    final latest = fit.last.averagePrice!;
    final predictions = List.generate(
      3,
      (i) => ForecastPricePoint(
        month: DateTime.utc(current.year, current.month + i + 1),
        predictedPrice: ((yMean + slope * (n + i - xMean)) * 100).round() / 100,
      ),
    );
    if (predictions.any(
      (p) =>
          !p.predictedPrice.isFinite ||
          p.predictedPrice < latest / 2 ||
          p.predictedPrice > latest * 2,
    )) {
      return unavailable('近期采样波动过大，简单线性外推不稳定，暂不提供预测数值。');
    }
    return PriceForecast(
      status: 'available',
      method: 'linear_regression',
      sampleMonths: n,
      message: '根据最近$n个连续月份的核验均价，线性外推未来3个月。仅供观察趋势，未考虑促销、新品、供需或商家样本变化。',
      points: predictions,
    );
  }

  static MarketPriceReport _empty(
    PriceHistoryRequest query,
    String status,
    String message,
    DateTime now,
  ) => MarketPriceReport(
    status: status,
    message: message,
    productName: query.productName.trim(),
    market: query.market.trim(),
    currency: query.currency,
    sampleCount: 0,
    sourceCount: 0,
    summary: '',
    methodology: '',
    limitations: [],
    researchedAt: now,
    cached: false,
    quotes: [],
    sources: [],
  );
}
