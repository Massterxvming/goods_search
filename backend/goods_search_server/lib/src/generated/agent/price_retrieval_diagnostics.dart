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
import '../agent/platform_search_diagnostic.dart' as _i2;
import 'package:goods_search_server/src/generated/protocol.dart' as _i3;

abstract class PriceRetrievalDiagnostics
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  PriceRetrievalDiagnostics._({
    required this.searches,
    required this.attemptedPages,
    required this.readablePages,
    required this.evidencePages,
    required this.loginRequiredPages,
    required this.verificationRequiredPages,
    required this.modelInvoked,
  });

  factory PriceRetrievalDiagnostics({
    required List<_i2.PlatformSearchDiagnostic> searches,
    required int attemptedPages,
    required int readablePages,
    required int evidencePages,
    required int loginRequiredPages,
    required int verificationRequiredPages,
    required bool modelInvoked,
  }) = _PriceRetrievalDiagnosticsImpl;

  factory PriceRetrievalDiagnostics.fromJson(
    Map<String, dynamic> jsonSerialization,
  ) {
    return PriceRetrievalDiagnostics(
      searches: _i3.Protocol().deserialize<List<_i2.PlatformSearchDiagnostic>>(
        jsonSerialization['searches'],
      ),
      attemptedPages: jsonSerialization['attemptedPages'] as int,
      readablePages: jsonSerialization['readablePages'] as int,
      evidencePages: jsonSerialization['evidencePages'] as int,
      loginRequiredPages: jsonSerialization['loginRequiredPages'] as int,
      verificationRequiredPages:
          jsonSerialization['verificationRequiredPages'] as int,
      modelInvoked: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['modelInvoked'],
      ),
    );
  }

  List<_i2.PlatformSearchDiagnostic> searches;

  int attemptedPages;

  int readablePages;

  int evidencePages;

  int loginRequiredPages;

  int verificationRequiredPages;

  bool modelInvoked;

  /// Returns a shallow copy of this [PriceRetrievalDiagnostics]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PriceRetrievalDiagnostics copyWith({
    List<_i2.PlatformSearchDiagnostic>? searches,
    int? attemptedPages,
    int? readablePages,
    int? evidencePages,
    int? loginRequiredPages,
    int? verificationRequiredPages,
    bool? modelInvoked,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'PriceRetrievalDiagnostics',
      'searches': searches.toJson(valueToJson: (v) => v.toJson()),
      'attemptedPages': attemptedPages,
      'readablePages': readablePages,
      'evidencePages': evidencePages,
      'loginRequiredPages': loginRequiredPages,
      'verificationRequiredPages': verificationRequiredPages,
      'modelInvoked': modelInvoked,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      '__className__': 'PriceRetrievalDiagnostics',
      'searches': searches.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      'attemptedPages': attemptedPages,
      'readablePages': readablePages,
      'evidencePages': evidencePages,
      'loginRequiredPages': loginRequiredPages,
      'verificationRequiredPages': verificationRequiredPages,
      'modelInvoked': modelInvoked,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _PriceRetrievalDiagnosticsImpl extends PriceRetrievalDiagnostics {
  _PriceRetrievalDiagnosticsImpl({
    required List<_i2.PlatformSearchDiagnostic> searches,
    required int attemptedPages,
    required int readablePages,
    required int evidencePages,
    required int loginRequiredPages,
    required int verificationRequiredPages,
    required bool modelInvoked,
  }) : super._(
         searches: searches,
         attemptedPages: attemptedPages,
         readablePages: readablePages,
         evidencePages: evidencePages,
         loginRequiredPages: loginRequiredPages,
         verificationRequiredPages: verificationRequiredPages,
         modelInvoked: modelInvoked,
       );

  /// Returns a shallow copy of this [PriceRetrievalDiagnostics]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PriceRetrievalDiagnostics copyWith({
    List<_i2.PlatformSearchDiagnostic>? searches,
    int? attemptedPages,
    int? readablePages,
    int? evidencePages,
    int? loginRequiredPages,
    int? verificationRequiredPages,
    bool? modelInvoked,
  }) {
    return PriceRetrievalDiagnostics(
      searches: searches ?? this.searches.map((e0) => e0.copyWith()).toList(),
      attemptedPages: attemptedPages ?? this.attemptedPages,
      readablePages: readablePages ?? this.readablePages,
      evidencePages: evidencePages ?? this.evidencePages,
      loginRequiredPages: loginRequiredPages ?? this.loginRequiredPages,
      verificationRequiredPages:
          verificationRequiredPages ?? this.verificationRequiredPages,
      modelInvoked: modelInvoked ?? this.modelInvoked,
    );
  }
}
