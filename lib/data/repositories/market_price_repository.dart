import '../../domain/models/current_price_report.dart';
import '../../domain/models/price_history.dart';
import '../services/serverpod_service.dart';

abstract interface class MarketPriceRepository {
  Future<CurrentPriceReport> research(
    String productName, {
    required PriceHistoryRange range,
  });
  void dispose();
}

class ServerpodMarketPriceRepository implements MarketPriceRepository {
  ServerpodMarketPriceRepository(this._service);
  final ServerpodService _service;

  @override
  Future<CurrentPriceReport> research(
    String productName, {
    required PriceHistoryRange range,
  }) async {
    final report = await _service.currentPrice(productName, range: range);
    final sources = report.sources
        .map(
          (source) => PriceReference(
            id: source.id,
            title: source.title,
            url: Uri.parse(source.url),
            platform: source.platform,
            productId: source.productId,
            fetchedAt: source.fetchedAt,
            accessStatus: source.accessStatus ?? '',
            accessMessage: source.accessMessage ?? '',
            publishedAt: source.publishedAt == null
                ? null
                : DateTime.tryParse(source.publishedAt!),
          ),
        )
        .toList();
    return CurrentPriceReport(
      status: report.status,
      message: report.message,
      productName: report.productName,
      researchedAt: report.researchedAt,
      averagePrice: report.averagePrice,
      lowestPrice: report.lowestPrice,
      highestPrice: report.highestPrice,
      sourceCount: report.sourceCount,
      summary: report.summary,
      methodology: report.methodology,
      cached: report.cached,
      diagnostics: report.diagnostics == null
          ? null
          : PriceRetrievalDiagnostics(
              attemptedPages: report.diagnostics!.attemptedPages,
              readablePages: report.diagnostics!.readablePages,
              evidencePages: report.diagnostics!.evidencePages,
              loginRequiredPages: report.diagnostics!.loginRequiredPages,
              verificationRequiredPages:
                  report.diagnostics!.verificationRequiredPages,
              modelInvoked: report.diagnostics!.modelInvoked,
              searches: report.diagnostics!.searches
                  .map(
                    (s) => PlatformSearchDiagnostic(
                      platform: s.platform,
                      status: s.status,
                      resultCount: s.resultCount,
                      productPageCount: s.productPageCount,
                      message: s.message,
                    ),
                  )
                  .toList(),
            ),
      history: report.history == null
          ? null
          : MarketPriceHistory(
              range: PriceHistoryRange(
                startMonth: report.history!.startMonth,
                endMonth: report.history!.endMonth,
              ),
              coveredMonths: report.history!.coveredMonths,
              changePercent: report.history!.changePercent,
              methodology: report.history!.methodology,
              limitations: report.history!.limitations,
              forecast: PriceForecast(
                status: report.history!.forecast.status,
                message: report.history!.forecast.message,
                method: report.history!.forecast.method,
                sampleMonths: report.history!.forecast.sampleMonths,
                points: report.history!.forecast.points
                    .map(
                      (p) => ForecastPricePoint(
                        month: p.month,
                        predictedPrice: p.predictedPrice,
                      ),
                    )
                    .toList(),
              ),
              points: report.history!.points
                  .map(
                    (p) => MonthlyPricePoint(
                      month: p.month,
                      averagePrice: p.averagePrice,
                      lowestPrice: p.lowestPrice,
                      highestPrice: p.highestPrice,
                      sampleCount: p.sampleCount,
                      quotes: p.quotes
                          .map(
                            (q) => HistoricalPriceQuote(
                              platform: q.platform,
                              productId: q.productId,
                              url: Uri.parse(q.url),
                              seller: q.seller,
                              price: q.price,
                              observedAt: q.observedAt,
                              evidence: q.evidence,
                            ),
                          )
                          .toList(),
                    ),
                  )
                  .toList(),
            ),
      limitations: report.limitations,
      sources: sources,
      quotes: report.quotes
          .map(
            (quote) => CurrentPriceQuote(
              seller: quote.seller,
              price: quote.price,
              evidence: quote.priceText,
              source: sources.firstWhere(
                (source) => source.id == quote.sourceId,
              ),
            ),
          )
          .toList(),
    );
  }

  @override
  void dispose() => _service.dispose();
}
