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

abstract class HistoricalPriceQuote implements _i1.SerializableModel {
  HistoricalPriceQuote._({
    required this.platform,
    required this.productId,
    required this.url,
    required this.seller,
    required this.price,
    required this.observedAt,
    required this.evidence,
  });

  factory HistoricalPriceQuote({
    required String platform,
    required String productId,
    required String url,
    required String seller,
    required double price,
    required DateTime observedAt,
    required String evidence,
  }) = _HistoricalPriceQuoteImpl;

  factory HistoricalPriceQuote.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return HistoricalPriceQuote(
      platform: jsonSerialization['platform'] as String,
      productId: jsonSerialization['productId'] as String,
      url: jsonSerialization['url'] as String,
      seller: jsonSerialization['seller'] as String,
      price: (jsonSerialization['price'] as num).toDouble(),
      observedAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['observedAt'],
      ),
      evidence: jsonSerialization['evidence'] as String,
    );
  }

  String platform;

  String productId;

  String url;

  String seller;

  double price;

  DateTime observedAt;

  String evidence;

  /// Returns a shallow copy of this [HistoricalPriceQuote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  HistoricalPriceQuote copyWith({
    String? platform,
    String? productId,
    String? url,
    String? seller,
    double? price,
    DateTime? observedAt,
    String? evidence,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'HistoricalPriceQuote',
      'platform': platform,
      'productId': productId,
      'url': url,
      'seller': seller,
      'price': price,
      'observedAt': observedAt.toJson(),
      'evidence': evidence,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _HistoricalPriceQuoteImpl extends HistoricalPriceQuote {
  _HistoricalPriceQuoteImpl({
    required String platform,
    required String productId,
    required String url,
    required String seller,
    required double price,
    required DateTime observedAt,
    required String evidence,
  }) : super._(
         platform: platform,
         productId: productId,
         url: url,
         seller: seller,
         price: price,
         observedAt: observedAt,
         evidence: evidence,
       );

  /// Returns a shallow copy of this [HistoricalPriceQuote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  HistoricalPriceQuote copyWith({
    String? platform,
    String? productId,
    String? url,
    String? seller,
    double? price,
    DateTime? observedAt,
    String? evidence,
  }) {
    return HistoricalPriceQuote(
      platform: platform ?? this.platform,
      productId: productId ?? this.productId,
      url: url ?? this.url,
      seller: seller ?? this.seller,
      price: price ?? this.price,
      observedAt: observedAt ?? this.observedAt,
      evidence: evidence ?? this.evidence,
    );
  }
}
