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
import '../agent/historical_price_quote.dart' as _i2;
import 'package:goods_search_client/src/protocol/protocol.dart' as _i3;

abstract class MonthlyPricePoint implements _i1.SerializableModel {
  MonthlyPricePoint._({
    required this.month,
    this.averagePrice,
    this.lowestPrice,
    this.highestPrice,
    required this.sampleCount,
    required this.quotes,
  });

  factory MonthlyPricePoint({
    required DateTime month,
    double? averagePrice,
    double? lowestPrice,
    double? highestPrice,
    required int sampleCount,
    required List<_i2.HistoricalPriceQuote> quotes,
  }) = _MonthlyPricePointImpl;

  factory MonthlyPricePoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return MonthlyPricePoint(
      month: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['month']),
      averagePrice: (jsonSerialization['averagePrice'] as num?)?.toDouble(),
      lowestPrice: (jsonSerialization['lowestPrice'] as num?)?.toDouble(),
      highestPrice: (jsonSerialization['highestPrice'] as num?)?.toDouble(),
      sampleCount: jsonSerialization['sampleCount'] as int,
      quotes: _i3.Protocol().deserialize<List<_i2.HistoricalPriceQuote>>(
        jsonSerialization['quotes'],
      ),
    );
  }

  DateTime month;

  double? averagePrice;

  double? lowestPrice;

  double? highestPrice;

  int sampleCount;

  List<_i2.HistoricalPriceQuote> quotes;

  /// Returns a shallow copy of this [MonthlyPricePoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MonthlyPricePoint copyWith({
    DateTime? month,
    double? averagePrice,
    double? lowestPrice,
    double? highestPrice,
    int? sampleCount,
    List<_i2.HistoricalPriceQuote>? quotes,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MonthlyPricePoint',
      'month': month.toJson(),
      if (averagePrice != null) 'averagePrice': averagePrice,
      if (lowestPrice != null) 'lowestPrice': lowestPrice,
      if (highestPrice != null) 'highestPrice': highestPrice,
      'sampleCount': sampleCount,
      'quotes': quotes.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MonthlyPricePointImpl extends MonthlyPricePoint {
  _MonthlyPricePointImpl({
    required DateTime month,
    double? averagePrice,
    double? lowestPrice,
    double? highestPrice,
    required int sampleCount,
    required List<_i2.HistoricalPriceQuote> quotes,
  }) : super._(
         month: month,
         averagePrice: averagePrice,
         lowestPrice: lowestPrice,
         highestPrice: highestPrice,
         sampleCount: sampleCount,
         quotes: quotes,
       );

  /// Returns a shallow copy of this [MonthlyPricePoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MonthlyPricePoint copyWith({
    DateTime? month,
    Object? averagePrice = _Undefined,
    Object? lowestPrice = _Undefined,
    Object? highestPrice = _Undefined,
    int? sampleCount,
    List<_i2.HistoricalPriceQuote>? quotes,
  }) {
    return MonthlyPricePoint(
      month: month ?? this.month,
      averagePrice: averagePrice is double? ? averagePrice : this.averagePrice,
      lowestPrice: lowestPrice is double? ? lowestPrice : this.lowestPrice,
      highestPrice: highestPrice is double? ? highestPrice : this.highestPrice,
      sampleCount: sampleCount ?? this.sampleCount,
      quotes: quotes ?? this.quotes.map((e0) => e0.copyWith()).toList(),
    );
  }
}
