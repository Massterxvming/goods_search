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

abstract class PlatformSearchDiagnostic
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PlatformSearchDiagnostic._({
    required this.platform,
    required this.status,
    required this.resultCount,
    required this.productPageCount,
    required this.message,
  });

  factory PlatformSearchDiagnostic({
    required String platform,
    required String status,
    required int resultCount,
    required int productPageCount,
    required String message,
  }) = _PlatformSearchDiagnosticImpl;

  factory PlatformSearchDiagnostic.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PlatformSearchDiagnostic(
      platform: jsonSerialization['platform'] as String,
      status: jsonSerialization['status'] as String,
      resultCount: jsonSerialization['resultCount'] as int,
      productPageCount: jsonSerialization['productPageCount'] as int,
      message: jsonSerialization['message'] as String,
    );
  }

  String platform;

  String status;

  int resultCount;

  int productPageCount;

  String message;

  /// Returns a shallow copy of this [PlatformSearchDiagnostic]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PlatformSearchDiagnostic copyWith({
    String? platform,
    String? status,
    int? resultCount,
    int? productPageCount,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PlatformSearchDiagnostic',
      'platform': platform,
      'status': status,
      'resultCount': resultCount,
      'productPageCount': productPageCount,
      'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PlatformSearchDiagnostic',
      'platform': platform,
      'status': status,
      'resultCount': resultCount,
      'productPageCount': productPageCount,
      'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PlatformSearchDiagnosticImpl extends PlatformSearchDiagnostic {
  _PlatformSearchDiagnosticImpl({
    required String platform,
    required String status,
    required int resultCount,
    required int productPageCount,
    required String message,
  }) : super._(
         platform: platform,
         status: status,
         resultCount: resultCount,
         productPageCount: productPageCount,
         message: message,
       );

  /// Returns a shallow copy of this [PlatformSearchDiagnostic]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PlatformSearchDiagnostic copyWith({
    String? platform,
    String? status,
    int? resultCount,
    int? productPageCount,
    String? message,
  }) {
    return PlatformSearchDiagnostic(
      platform: platform ?? this.platform,
      status: status ?? this.status,
      resultCount: resultCount ?? this.resultCount,
      productPageCount: productPageCount ?? this.productPageCount,
      message: message ?? this.message,
    );
  }
}
