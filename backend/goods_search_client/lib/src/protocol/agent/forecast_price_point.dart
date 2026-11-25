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

abstract class ForecastPricePoint implements _i1.SerializableModel {
  ForecastPricePoint._({
    required this.month,
    required this.predictedPrice,
  });

  factory ForecastPricePoint({
    required DateTime month,
    required double predictedPrice,
  }) = _ForecastPricePointImpl;

  factory ForecastPricePoint.fromJson(Map<String, dynamic> jsonSerialization) {
    return ForecastPricePoint(
      month: _i1.DateTimeJsonExtension.fromJson(jsonSerialization['month']),
      predictedPrice: (jsonSerialization['predictedPrice'] as num).toDouble(),
    );
  }

  DateTime month;

  double predictedPrice;

  /// Returns a shallow copy of this [ForecastPricePoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ForecastPricePoint copyWith({
    DateTime? month,
    double? predictedPrice,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ForecastPricePoint',
      'month': month.toJson(),
      'predictedPrice': predictedPrice,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _ForecastPricePointImpl extends ForecastPricePoint {
  _ForecastPricePointImpl({
    required DateTime month,
    required double predictedPrice,
  }) : super._(
         month: month,
         predictedPrice: predictedPrice,
       );

  /// Returns a shallow copy of this [ForecastPricePoint]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ForecastPricePoint copyWith({
    DateTime? month,
    double? predictedPrice,
  }) {
    return ForecastPricePoint(
      month: month ?? this.month,
      predictedPrice: predictedPrice ?? this.predictedPrice,
    );
  }
}
