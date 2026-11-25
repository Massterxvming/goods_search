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
import '../agent/monthly_price_point.dart' as _i2;
import '../agent/price_forecast.dart' as _i3;
import 'package:goods_search_client/src/protocol/protocol.dart' as _i4;

abstract class MarketPriceHistory implements _i1.SerializableModel {
  MarketPriceHistory._({
    required this.startMonth,
    required this.endMonth,
    required this.coveredMonths,
    this.changePercent,
    required this.points,
    required this.forecast,
    required this.methodology,
    required this.limitations,
  });

  factory MarketPriceHistory({
    required DateTime startMonth,
    required DateTime endMonth,
    required int coveredMonths,
    double? changePercent,
    required List<_i2.MonthlyPricePoint> points,
    required _i3.PriceForecast forecast,
    required String methodology,
    required List<String> limitations,
  }) = _MarketPriceHistoryImpl;

  factory MarketPriceHistory.fromJson(Map<String, dynamic> jsonSerialization) {
    return MarketPriceHistory(
      startMonth: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startMonth'],
      ),
      endMonth: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['endMonth'],
      ),
      coveredMonths: jsonSerialization['coveredMonths'] as int,
      changePercent: (jsonSerialization['changePercent'] as num?)?.toDouble(),
      points: _i4.Protocol().deserialize<List<_i2.MonthlyPricePoint>>(
        jsonSerialization['points'],
      ),
      forecast: _i4.Protocol().deserialize<_i3.PriceForecast>(
        jsonSerialization['forecast'],
      ),
      methodology: jsonSerialization['methodology'] as String,
      limitations: _i4.Protocol().deserialize<List<String>>(
        jsonSerialization['limitations'],
      ),
    );
  }

  DateTime startMonth;

  DateTime endMonth;

  int coveredMonths;

  double? changePercent;

  List<_i2.MonthlyPricePoint> points;

  _i3.PriceForecast forecast;

  String methodology;

  List<String> limitations;

  /// Returns a shallow copy of this [MarketPriceHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarketPriceHistory copyWith({
    DateTime? startMonth,
    DateTime? endMonth,
    int? coveredMonths,
    double? changePercent,
    List<_i2.MonthlyPricePoint>? points,
    _i3.PriceForecast? forecast,
    String? methodology,
    List<String>? limitations,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarketPriceHistory',
      'startMonth': startMonth.toJson(),
      'endMonth': endMonth.toJson(),
      'coveredMonths': coveredMonths,
      if (changePercent != null) 'changePercent': changePercent,
      'points': points.toJson(valueToJson: (v) => v.toJson()),
      'forecast': forecast.toJson(),
      'methodology': methodology,
      'limitations': limitations.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MarketPriceHistoryImpl extends MarketPriceHistory {
  _MarketPriceHistoryImpl({
    required DateTime startMonth,
    required DateTime endMonth,
    required int coveredMonths,
    double? changePercent,
    required List<_i2.MonthlyPricePoint> points,
    required _i3.PriceForecast forecast,
    required String methodology,
    required List<String> limitations,
  }) : super._(
         startMonth: startMonth,
         endMonth: endMonth,
         coveredMonths: coveredMonths,
         changePercent: changePercent,
         points: points,
         forecast: forecast,
         methodology: methodology,
         limitations: limitations,
       );

  /// Returns a shallow copy of this [MarketPriceHistory]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarketPriceHistory copyWith({
    DateTime? startMonth,
    DateTime? endMonth,
    int? coveredMonths,
    Object? changePercent = _Undefined,
    List<_i2.MonthlyPricePoint>? points,
    _i3.PriceForecast? forecast,
    String? methodology,
    List<String>? limitations,
  }) {
    return MarketPriceHistory(
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
      coveredMonths: coveredMonths ?? this.coveredMonths,
      changePercent: changePercent is double?
          ? changePercent
          : this.changePercent,
      points: points ?? this.points.map((e0) => e0.copyWith()).toList(),
      forecast: forecast ?? this.forecast.copyWith(),
      methodology: methodology ?? this.methodology,
      limitations: limitations ?? this.limitations.map((e0) => e0).toList(),
    );
  }
}
