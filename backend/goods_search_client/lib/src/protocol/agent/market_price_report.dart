/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import '../agent/market_price_quote.dart' as _i2;
import '../agent/market_price_source.dart' as _i3;
import '../agent/market_price_history.dart' as _i4;
import '../agent/price_retrieval_diagnostics.dart' as _i5;
import 'package:goods_search_client/src/protocol/protocol.dart' as _i6;

abstract class MarketPriceReport implements _i1.SerializableModel {
  MarketPriceReport._({
    required this.status,
    required this.message,
    required this.productName,
    required this.market,
    required this.currency,
    this.averagePrice,
    this.lowestPrice,
    this.highestPrice,
    required this.sampleCount,
    required this.sourceCount,
    required this.summary,
    required this.methodology,
    required this.limitations,
    required this.researchedAt,
    required this.cached,
    required this.quotes,
    required this.sources,
    this.history,
    this.diagnostics,
  });

  factory MarketPriceReport({
    required String status,
    required String message,
    required String productName,
    required String market,
    required String currency,
    double? averagePrice,
    double? lowestPrice,
    double? highestPrice,
    required int sampleCount,
    required int sourceCount,
    required String summary,
    required String methodology,
    required List<String> limitations,
    required DateTime researchedAt,
    required bool cached,
    required List<_i2.MarketPriceQuote> quotes,
    required List<_i3.MarketPriceSource> sources,
    _i4.MarketPriceHistory? history,
    _i5.PriceRetrievalDiagnostics? diagnostics,
  }) = _MarketPriceReportImpl;

  factory MarketPriceReport.fromJson(Map<String, dynamic> jsonSerialization) {
    return MarketPriceReport(
      status: jsonSerialization['status'] as String,
      message: jsonSerialization['message'] as String,
      productName: jsonSerialization['productName'] as String,
      market: jsonSerialization['market'] as String,
      currency: jsonSerialization['currency'] as String,
      averagePrice: (jsonSerialization['averagePrice'] as num?)?.toDouble(),
      lowestPrice: (jsonSerialization['lowestPrice'] as num?)?.toDouble(),
      highestPrice: (jsonSerialization['highestPrice'] as num?)?.toDouble(),
      sampleCount: jsonSerialization['sampleCount'] as int,
      sourceCount: jsonSerialization['sourceCount'] as int,
      summary: jsonSerialization['summary'] as String,
      methodology: jsonSerialization['methodology'] as String,
      limitations: _i6.Protocol().deserialize<List<String>>(
        jsonSerialization['limitations'],
      ),
      researchedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['researchedAt'],
      ),
      cached: _i1.BoolJsonExtension.fromJson(jsonSerialization['cached']),
      quotes: _i6.Protocol().deserialize<List<_i2.MarketPriceQuote>>(
        jsonSerialization['quotes'],
      ),
      sources: _i6.Protocol().deserialize<List<_i3.MarketPriceSource>>(
        jsonSerialization['sources'],
      ),
      history: jsonSerialization['history'] == null
          ? null
          : _i6.Protocol().deserialize<_i4.MarketPriceHistory>(
              jsonSerialization['history'],
            ),
      diagnostics: jsonSerialization['diagnostics'] == null
          ? null
          : _i6.Protocol().deserialize<_i5.PriceRetrievalDiagnostics>(
              jsonSerialization['diagnostics'],
            ),
    );
  }

  String status;

  String message;

  String productName;

  String market;

  String currency;

  double? averagePrice;

  double? lowestPrice;

  double? highestPrice;

  int sampleCount;

  int sourceCount;

  String summary;

  String methodology;

  List<String> limitations;

  DateTime researchedAt;

  bool cached;

  List<_i2.MarketPriceQuote> quotes;

  List<_i3.MarketPriceSource> sources;

  _i4.MarketPriceHistory? history;

  _i5.PriceRetrievalDiagnostics? diagnostics;

  /// Returns a shallow copy of this [MarketPriceReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarketPriceReport copyWith({
    String? status,
    String? message,
    String? productName,
    String? market,
    String? currency,
    double? averagePrice,
    double? lowestPrice,
    double? highestPrice,
    int? sampleCount,
    int? sourceCount,
    String? summary,
    String? methodology,
    List<String>? limitations,
    DateTime? researchedAt,
    bool? cached,
    List<_i2.MarketPriceQuote>? quotes,
    List<_i3.MarketPriceSource>? sources,
    _i4.MarketPriceHistory? history,
    _i5.PriceRetrievalDiagnostics? diagnostics,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarketPriceReport',
      'status': status,
      'message': message,
      'productName': productName,
      'market': market,
      'currency': currency,
      if (averagePrice != null) 'averagePrice': averagePrice,
      if (lowestPrice != null) 'lowestPrice': lowestPrice,
      if (highestPrice != null) 'highestPrice': highestPrice,
      'sampleCount': sampleCount,
      'sourceCount': sourceCount,
      'summary': summary,
      'methodology': methodology,
      'limitations': limitations.toJson(),
      'researchedAt': researchedAt.toJson(),
      'cached': cached,
      'quotes': quotes.toJson(valueToJson: (v) => v.toJson()),
      'sources': sources.toJson(valueToJson: (v) => v.toJson()),
      if (history != null) 'history': history?.toJson(),
      if (diagnostics != null) 'diagnostics': diagnostics?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MarketPriceReportImpl extends MarketPriceReport {
  _MarketPriceReportImpl({
    required String status,
    required String message,
    required String productName,
    required String market,
    required String currency,
    double? averagePrice,
    double? lowestPrice,
    double? highestPrice,
    required int sampleCount,
    required int sourceCount,
    required String summary,
    required String methodology,
    required List<String> limitations,
    required DateTime researchedAt,
    required bool cached,
    required List<_i2.MarketPriceQuote> quotes,
    required List<_i3.MarketPriceSource> sources,
    _i4.MarketPriceHistory? history,
    _i5.PriceRetrievalDiagnostics? diagnostics,
  }) : super._(
         status: status,
         message: message,
         productName: productName,
         market: market,
         currency: currency,
         averagePrice: averagePrice,
         lowestPrice: lowestPrice,
         highestPrice: highestPrice,
         sampleCount: sampleCount,
         sourceCount: sourceCount,
         summary: summary,
         methodology: methodology,
         limitations: limitations,
         researchedAt: researchedAt,
         cached: cached,
         quotes: quotes,
         sources: sources,
         history: history,
         diagnostics: diagnostics,
       );

  /// Returns a shallow copy of this [MarketPriceReport]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarketPriceReport copyWith({
    String? status,
    String? message,
    String? productName,
    String? market,
    String? currency,
    Object? averagePrice = _Undefined,
    Object? lowestPrice = _Undefined,
    Object? highestPrice = _Undefined,
    int? sampleCount,
    int? sourceCount,
    String? summary,
    String? methodology,
    List<String>? limitations,
    DateTime? researchedAt,
    bool? cached,
    List<_i2.MarketPriceQuote>? quotes,
    List<_i3.MarketPriceSource>? sources,
    Object? history = _Undefined,
    Object? diagnostics = _Undefined,
  }) {
    return MarketPriceReport(
      status: status ?? this.status,
      message: message ?? this.message,
      productName: productName ?? this.productName,
      market: market ?? this.market,
      currency: currency ?? this.currency,
      averagePrice: averagePrice is double? ? averagePrice : this.averagePrice,
      lowestPrice: lowestPrice is double? ? lowestPrice : this.lowestPrice,
      highestPrice: highestPrice is double? ? highestPrice : this.highestPrice,
      sampleCount: sampleCount ?? this.sampleCount,
      sourceCount: sourceCount ?? this.sourceCount,
      summary: summary ?? this.summary,
      methodology: methodology ?? this.methodology,
      limitations: limitations ?? this.limitations.map((e0) => e0).toList(),
      researchedAt: researchedAt ?? this.researchedAt,
      cached: cached ?? this.cached,
      quotes: quotes ?? this.quotes.map((e0) => e0.copyWith()).toList(),
      sources: sources ?? this.sources.map((e0) => e0.copyWith()).toList(),
      history: history is _i4.MarketPriceHistory?
          ? history
          : this.history?.copyWith(),
      diagnostics: diagnostics is _i5.PriceRetrievalDiagnostics?
          ? diagnostics
          : this.diagnostics?.copyWith(),
    );
  }
}
