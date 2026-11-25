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

abstract class PriceResearchRequest
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PriceResearchRequest._({
    required this.productName,
    required this.market,
    required this.currency,
    required this.historyMonths,
    required this.forecastMonths,
  });

  factory PriceResearchRequest({
    required String productName,
    required String market,
    required String currency,
    required int historyMonths,
    required int forecastMonths,
  }) = _PriceResearchRequestImpl;

  factory PriceResearchRequest.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PriceResearchRequest(
      productName: jsonSerialization['productName'] as String,
      market: jsonSerialization['market'] as String,
      currency: jsonSerialization['currency'] as String,
      historyMonths: jsonSerialization['historyMonths'] as int,
      forecastMonths: jsonSerialization['forecastMonths'] as int,
    );
  }

  String productName;

  String market;

  String currency;

  int historyMonths;

  int forecastMonths;

  /// Returns a shallow copy of this [PriceResearchRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceResearchRequest copyWith({
    String? productName,
    String? market,
    String? currency,
    int? historyMonths,
    int? forecastMonths,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceResearchRequest',
      'productName': productName,
      'market': market,
      'currency': currency,
      'historyMonths': historyMonths,
      'forecastMonths': forecastMonths,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PriceResearchRequest',
      'productName': productName,
      'market': market,
      'currency': currency,
      'historyMonths': historyMonths,
      'forecastMonths': forecastMonths,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PriceResearchRequestImpl extends PriceResearchRequest {
  _PriceResearchRequestImpl({
    required String productName,
    required String market,
    required String currency,
    required int historyMonths,
    required int forecastMonths,
  }) : super._(
         productName: productName,
         market: market,
         currency: currency,
         historyMonths: historyMonths,
         forecastMonths: forecastMonths,
       );

  /// Returns a shallow copy of this [PriceResearchRequest]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceResearchRequest copyWith({
    String? productName,
    String? market,
    String? currency,
    int? historyMonths,
    int? forecastMonths,
  }) {
    return PriceResearchRequest(
      productName: productName ?? this.productName,
      market: market ?? this.market,
      currency: currency ?? this.currency,
      historyMonths: historyMonths ?? this.historyMonths,
      forecastMonths: forecastMonths ?? this.forecastMonths,
    );
  }
}
