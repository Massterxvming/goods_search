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

abstract class MarketPriceRequest
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MarketPriceRequest._({
    required this.productName,
    required this.market,
    required this.currency,
  });

  factory MarketPriceRequest({
    required String productName,
    required String market,
    required String currency,
  }) = _MarketPriceRequestImpl;

  factory MarketPriceRequest.fromJson(Map<String, dynamic> jsonSerialization) {
    return MarketPriceRequest(
      productName: jsonSerialization['productName'] as String,
      market: jsonSerialization['market'] as String,
      currency: jsonSerialization['currency'] as String,
    );
  }

  String productName;

  String market;

  String currency;

  /// Returns a shallow copy of this [MarketPriceRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarketPriceRequest copyWith({
    String? productName,
    String? market,
    String? currency,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarketPriceRequest',
      'productName': productName,
      'market': market,
      'currency': currency,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'MarketPriceRequest',
      'productName': productName,
      'market': market,
      'currency': currency,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MarketPriceRequestImpl extends MarketPriceRequest {
  _MarketPriceRequestImpl({
    required String productName,
    required String market,
    required String currency,
  }) : super._(
         productName: productName,
         market: market,
         currency: currency,
       );

  /// Returns a shallow copy of this [MarketPriceRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarketPriceRequest copyWith({
    String? productName,
    String? market,
    String? currency,
  }) {
    return MarketPriceRequest(
      productName: productName ?? this.productName,
      market: market ?? this.market,
      currency: currency ?? this.currency,
    );
  }
}
