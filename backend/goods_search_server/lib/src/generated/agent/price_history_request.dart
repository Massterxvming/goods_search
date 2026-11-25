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

abstract class PriceHistoryRequest
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PriceHistoryRequest._({
    required this.productName,
    required this.market,
    required this.currency,
    required this.startMonth,
    required this.endMonth,
  });

  factory PriceHistoryRequest({
    required String productName,
    required String market,
    required String currency,
    required DateTime startMonth,
    required DateTime endMonth,
  }) = _PriceHistoryRequestImpl;

  factory PriceHistoryRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return PriceHistoryRequest(
      productName: jsonSerialization['productName'] as String,
      market: jsonSerialization['market'] as String,
      currency: jsonSerialization['currency'] as String,
      startMonth: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['startMonth'],
      ),
      endMonth: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['endMonth'],
      ),
    );
  }

  String productName;

  String market;

  String currency;

  DateTime startMonth;

  DateTime endMonth;

  /// Returns a shallow copy of this [PriceHistoryRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceHistoryRequest copyWith({
    String? productName,
    String? market,
    String? currency,
    DateTime? startMonth,
    DateTime? endMonth,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceHistoryRequest',
      'productName': productName,
      'market': market,
      'currency': currency,
      'startMonth': startMonth.toJson(),
      'endMonth': endMonth.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PriceHistoryRequest',
      'productName': productName,
      'market': market,
      'currency': currency,
      'startMonth': startMonth.toJson(),
      'endMonth': endMonth.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PriceHistoryRequestImpl extends PriceHistoryRequest {
  _PriceHistoryRequestImpl({
    required String productName,
    required String market,
    required String currency,
    required DateTime startMonth,
    required DateTime endMonth,
  }) : super._(
         productName: productName,
         market: market,
         currency: currency,
         startMonth: startMonth,
         endMonth: endMonth,
       );

  /// Returns a shallow copy of this [PriceHistoryRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceHistoryRequest copyWith({
    String? productName,
    String? market,
    String? currency,
    DateTime? startMonth,
    DateTime? endMonth,
  }) {
    return PriceHistoryRequest(
      productName: productName ?? this.productName,
      market: market ?? this.market,
      currency: currency ?? this.currency,
      startMonth: startMonth ?? this.startMonth,
      endMonth: endMonth ?? this.endMonth,
    );
  }
}
