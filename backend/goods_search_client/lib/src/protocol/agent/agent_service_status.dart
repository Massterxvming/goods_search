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
import 'package:goods_search_client/src/protocol/protocol.dart' as _i2;

abstract class AgentServiceStatus implements _i1.SerializableModel {
  AgentServiceStatus._({
    required this.serviceAvailable,
    required this.sdkReady,
    required this.modelConfigured,
    required this.missingConfiguration,
    required this.message,
  });

  factory AgentServiceStatus({
    required bool serviceAvailable,
    required bool sdkReady,
    required bool modelConfigured,
    required List<String> missingConfiguration,
    required String message,
  }) = _AgentServiceStatusImpl;

  factory AgentServiceStatus.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentServiceStatus(
      serviceAvailable: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['serviceAvailable'],
      ),
      sdkReady: _i1.BoolJsonExtension.fromJson(jsonSerialization['sdkReady']),
      modelConfigured: _i1.BoolJsonExtension.fromJson(
        jsonSerialization['modelConfigured'],
      ),
      missingConfiguration: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['missingConfiguration'],
      ),
      message: jsonSerialization['message'] as String,
    );
  }

  bool serviceAvailable;

  bool sdkReady;

  bool modelConfigured;

  List<String> missingConfiguration;

  String message;

  /// Returns a shallow copy of this [AgentServiceStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AgentServiceStatus copyWith({
    bool? serviceAvailable,
    bool? sdkReady,
    bool? modelConfigured,
    List<String>? missingConfiguration,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentServiceStatus',
      'serviceAvailable': serviceAvailable,
      'sdkReady': sdkReady,
      'modelConfigured': modelConfigured,
      'missingConfiguration': missingConfiguration.toJson(),
      'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AgentServiceStatusImpl extends AgentServiceStatus {
  _AgentServiceStatusImpl({
    required bool serviceAvailable,
    required bool sdkReady,
    required bool modelConfigured,
    required List<String> missingConfiguration,
    required String message,
  }) : super._(
         serviceAvailable: serviceAvailable,
         sdkReady: sdkReady,
         modelConfigured: modelConfigured,
         missingConfiguration: missingConfiguration,
         message: message,
       );

  /// Returns a shallow copy of this [AgentServiceStatus]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AgentServiceStatus copyWith({
    bool? serviceAvailable,
    bool? sdkReady,
    bool? modelConfigured,
    List<String>? missingConfiguration,
    String? message,
  }) {
    return AgentServiceStatus(
      serviceAvailable: serviceAvailable ?? this.serviceAvailable,
      sdkReady: sdkReady ?? this.sdkReady,
      modelConfigured: modelConfigured ?? this.modelConfigured,
      missingConfiguration:
          missingConfiguration ??
          this.missingConfiguration.map((e0) => e0).toList(),
      message: message ?? this.message,
    );
  }
}
