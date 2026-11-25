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
import 'package:serverpod/serverpod.dart' as _i1;
import '../agent/forecast_price_point.dart' as _i2;
import 'package:goods_search_server/src/generated/protocol.dart' as _i3;

abstract class PriceForecast
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PriceForecast._({
    required this.status,
    required this.method,
    required this.message,
    required this.sampleMonths,
    required this.points,
  });

  factory PriceForecast({
    required String status,
    required String method,
    required String message,
    required int sampleMonths,
    required List<_i2.ForecastPricePoint> points,
  }) = _PriceForecastImpl;

  factory PriceForecast.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceForecast(
      status: jsonSerialization['status'] as String,
      method: jsonSerialization['method'] as String,
      message: jsonSerialization['message'] as String,
      sampleMonths: jsonSerialization['sampleMonths'] as int,
      points: _i3.Protocol().deserialize<List<_i2.ForecastPricePoint>>(
        jsonSerialization['points'],
      ),
    );
  }

  String status;

  String method;

  String message;

  int sampleMonths;

  List<_i2.ForecastPricePoint> points;

  /// Returns a shallow copy of this [PriceForecast]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceForecast copyWith({
    String? status,
    String? method,
    String? message,
    int? sampleMonths,
    List<_i2.ForecastPricePoint>? points,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceForecast',
      'status': status,
      'method': method,
      'message': message,
      'sampleMonths': sampleMonths,
      'points': points.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PriceForecast',
      'status': status,
      'method': method,
      'message': message,
      'sampleMonths': sampleMonths,
      'points': points.toJson(valueToJson: (v) => v.toJsonForProtocol()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PriceForecastImpl extends PriceForecast {
  _PriceForecastImpl({
    required String status,
    required String method,
    required String message,
    required int sampleMonths,
    required List<_i2.ForecastPricePoint> points,
  }) : super._(
         status: status,
         method: method,
         message: message,
         sampleMonths: sampleMonths,
         points: points,
       );

  /// Returns a shallow copy of this [PriceForecast]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceForecast copyWith({
    String? status,
    String? method,
    String? message,
    int? sampleMonths,
    List<_i2.ForecastPricePoint>? points,
  }) {
    return PriceForecast(
      status: status ?? this.status,
      method: method ?? this.method,
      message: message ?? this.message,
      sampleMonths: sampleMonths ?? this.sampleMonths,
      points: points ?? this.points.map((e0) => e0.copyWith()).toList(),
    );
  }
}
