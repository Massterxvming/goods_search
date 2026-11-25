import 'price_history.dart';

class PriceReference {
  const PriceReference({
    required this.id,
    required this.title,
    required this.url,
    this.publishedAt,
    this.platform = '',
    this.productId = '',
    this.fetchedAt,
    this.accessStatus = '',
    this.accessMessage = '',
  });
  final String id;
  final String title;
  final Uri url;
  final DateTime? publishedAt;
  final String platform;
  final String productId;
  final DateTime? fetchedAt;
  final String accessStatus;
  final String accessMessage;
}

class PlatformSearchDiagnostic {
  const PlatformSearchDiagnostic({
    required this.platform,
    required this.status,
    required this.resultCount,
    required this.productPageCount,
    required this.message,
  });
  final String platform;
  final String status;
  final int resultCount;
  final int productPageCount;
  final String message;
}

class PriceRetrievalDiagnostics {
  PriceRetrievalDiagnostics({
    required this.attemptedPages,
    required this.readablePages,
    required this.evidencePages,
    required this.loginRequiredPages,
    required this.verificationRequiredPages,
    required this.modelInvoked,
    List<PlatformSearchDiagnostic> searches = const [],
  }) : searches = List.unmodifiable(searches);
  final List<PlatformSearchDiagnostic> searches;
  final int attemptedPages;
  final int readablePages;
  final int evidencePages;
  final int loginRequiredPages;
  final int verificationRequiredPages;
  final bool modelInvoked;
}

class CurrentPriceQuote {
  const CurrentPriceQuote({
    required this.seller,
    required this.price,
    required this.evidence,
    required this.source,
  });
  final String seller;
  final double price;
  final String evidence;
  final PriceReference source;
}

class CurrentPriceReport {
  CurrentPriceReport({
    required this.status,
    required this.message,
    required this.productName,
    required this.researchedAt,
    this.averagePrice,
    this.lowestPrice,
    this.highestPrice,
    this.sourceCount = 0,
    this.summary = '',
    this.methodology = '',
    this.cached = false,
    this.history,
    this.diagnostics,
    List<String> limitations = const [],
    List<CurrentPriceQuote> quotes = const [],
    List<PriceReference> sources = const [],
  }) : limitations = List.unmodifiable(limitations),
       quotes = List.unmodifiable(quotes),
       sources = List.unmodifiable(sources);

  final String status;
  final String message;
  final String productName;
  final DateTime researchedAt;
  final double? averagePrice;
  final double? lowestPrice;
  final double? highestPrice;
  final int sourceCount;
  final String summary;
  final String methodology;
  final bool cached;
  final MarketPriceHistory? history;
  final PriceRetrievalDiagnostics? diagnostics;
  final List<String> limitations;
  final List<CurrentPriceQuote> quotes;
  final List<PriceReference> sources;
}
