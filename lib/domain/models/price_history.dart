class PriceHistoryRange {
  const PriceHistoryRange({required this.startMonth, required this.endMonth});

  factory PriceHistoryRange.recent(int months, {DateTime? now}) {
    final china = (now ?? DateTime.now()).toUtc().add(const Duration(hours: 8));
    final end = DateTime.utc(china.year, china.month);
    return PriceHistoryRange(
      startMonth: DateTime.utc(end.year, end.month - months + 1),
      endMonth: end,
    );
  }

  final DateTime startMonth;
  final DateTime endMonth;
  int get monthCount =>
      (endMonth.year - startMonth.year) * 12 +
      endMonth.month -
      startMonth.month +
      1;
}

class HistoricalPriceQuote {
  const HistoricalPriceQuote({
    required this.platform,
    required this.productId,
    required this.url,
    required this.seller,
    required this.price,
    required this.observedAt,
    required this.evidence,
  });
  final String platform;
  final String productId;
  final Uri url;
  final String seller;
  final double price;
  final DateTime observedAt;
  final String evidence;
}

class MonthlyPricePoint {
  MonthlyPricePoint({
    required this.month,
    required this.sampleCount,
    this.averagePrice,
    this.lowestPrice,
    this.highestPrice,
    List<HistoricalPriceQuote> quotes = const [],
  }) : quotes = List.unmodifiable(quotes);
  final DateTime month;
  final double? averagePrice;
  final double? lowestPrice;
  final double? highestPrice;
  final int sampleCount;
  final List<HistoricalPriceQuote> quotes;
}

class ForecastPricePoint {
  const ForecastPricePoint({required this.month, required this.predictedPrice});
  final DateTime month;
  final double predictedPrice;
}

class PriceForecast {
  PriceForecast({
    required this.status,
    required this.message,
    required this.method,
    required this.sampleMonths,
    List<ForecastPricePoint> points = const [],
  }) : points = List.unmodifiable(points);
  final String status;
  final String message;
  final String method;
  final int sampleMonths;
  final List<ForecastPricePoint> points;
}

class MarketPriceHistory {
  MarketPriceHistory({
    required this.range,
    required this.coveredMonths,
    required this.forecast,
    required this.methodology,
    this.changePercent,
    List<MonthlyPricePoint> points = const [],
    List<String> limitations = const [],
  }) : points = List.unmodifiable(points),
       limitations = List.unmodifiable(limitations);
  final PriceHistoryRange range;
  final int coveredMonths;
  final double? changePercent;
  final List<MonthlyPricePoint> points;
  final PriceForecast forecast;
  final String methodology;
  final List<String> limitations;
}
