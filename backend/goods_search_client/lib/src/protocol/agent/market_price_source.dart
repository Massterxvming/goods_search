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

abstract class MarketPriceSource implements _i1.SerializableModel {
  MarketPriceSource._({
    required this.id,
    required this.title,
    required this.url,
    this.publishedAt,
    required this.platform,
    required this.productId,
    this.fetchedAt,
    this.accessStatus,
    this.accessMessage,
  });

  factory MarketPriceSource({
    required String id,
    required String title,
    required String url,
    String? publishedAt,
    required String platform,
    required String productId,
    DateTime? fetchedAt,
    String? accessStatus,
    String? accessMessage,
  }) = _MarketPriceSourceImpl;

  factory MarketPriceSource.fromJson(Map<String, dynamic> jsonSerialization) {
    return MarketPriceSource(
      id: jsonSerialization['id'] as String,
      title: jsonSerialization['title'] as String,
      url: jsonSerialization['url'] as String,
      publishedAt: jsonSerialization['publishedAt'] as String?,
      platform: jsonSerialization['platform'] as String,
      productId: jsonSerialization['productId'] as String,
      fetchedAt: jsonSerialization['fetchedAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['fetchedAt']),
      accessStatus: jsonSerialization['accessStatus'] as String?,
      accessMessage: jsonSerialization['accessMessage'] as String?,
    );
  }

  String id;

  String title;

  String url;

  String? publishedAt;

  String platform;

  String productId;

  DateTime? fetchedAt;

  String? accessStatus;

  String? accessMessage;

  /// Returns a shallow copy of this [MarketPriceSource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  MarketPriceSource copyWith({
    String? id,
    String? title,
    String? url,
    String? publishedAt,
    String? platform,
    String? productId,
    DateTime? fetchedAt,
    String? accessStatus,
    String? accessMessage,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'MarketPriceSource',
      'id': id,
      'title': title,
      'url': url,
      if (publishedAt != null) 'publishedAt': publishedAt,
      'platform': platform,
      'productId': productId,
      if (fetchedAt != null) 'fetchedAt': fetchedAt?.toJson(),
      if (accessStatus != null) 'accessStatus': accessStatus,
      if (accessMessage != null) 'accessMessage': accessMessage,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _MarketPriceSourceImpl extends MarketPriceSource {
  _MarketPriceSourceImpl({
    required String id,
    required String title,
    required String url,
    String? publishedAt,
    required String platform,
    required String productId,
    DateTime? fetchedAt,
    String? accessStatus,
    String? accessMessage,
  }) : super._(
         id: id,
         title: title,
         url: url,
         publishedAt: publishedAt,
         platform: platform,
         productId: productId,
         fetchedAt: fetchedAt,
         accessStatus: accessStatus,
         accessMessage: accessMessage,
       );

  /// Returns a shallow copy of this [MarketPriceSource]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  MarketPriceSource copyWith({
    String? id,
    String? title,
    String? url,
    Object? publishedAt = _Undefined,
    String? platform,
    String? productId,
    Object? fetchedAt = _Undefined,
    Object? accessStatus = _Undefined,
    Object? accessMessage = _Undefined,
  }) {
    return MarketPriceSource(
      id: id ?? this.id,
      title: title ?? this.title,
      url: url ?? this.url,
      publishedAt: publishedAt is String? ? publishedAt : this.publishedAt,
      platform: platform ?? this.platform,
      productId: productId ?? this.productId,
      fetchedAt: fetchedAt is DateTime? ? fetchedAt : this.fetchedAt,
      accessStatus: accessStatus is String? ? accessStatus : this.accessStatus,
      accessMessage: accessMessage is String?
          ? accessMessage
          : this.accessMessage,
    );
  }
}
