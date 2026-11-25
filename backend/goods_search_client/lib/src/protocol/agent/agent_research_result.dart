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

abstract class AgentResearchResult implements _i1.SerializableModel {
  AgentResearchResult._({
    required this.status,
    required this.message,
    this.summary,
    required this.requiredData,
    required this.steps,
  });

  factory AgentResearchResult({
    required String status,
    required String message,
    String? summary,
    required List<String> requiredData,
    required List<String> steps,
  }) = _AgentResearchResultImpl;

  factory AgentResearchResult.fromJson(Map<String, dynamic> jsonSerialization) {
    return AgentResearchResult(
      status: jsonSerialization['status'] as String,
      message: jsonSerialization['message'] as String,
      summary: jsonSerialization['summary'] as String?,
      requiredData: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['requiredData'],
      ),
      steps: _i2.Protocol().deserialize<List<String>>(
        jsonSerialization['steps'],
      ),
    );
  }

  String status;

  String message;

  String? summary;

  List<String> requiredData;

  List<String> steps;

  /// Returns a shallow copy of this [AgentResearchResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  AgentResearchResult copyWith({
    String? status,
    String? message,
    String? summary,
    List<String>? requiredData,
    List<String>? steps,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'AgentResearchResult',
      'status': status,
      'message': message,
      if (summary != null) 'summary': summary,
      'requiredData': requiredData.toJson(),
      'steps': steps.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _AgentResearchResultImpl extends AgentResearchResult {
  _AgentResearchResultImpl({
    required String status,
    required String message,
    String? summary,
    required List<String> requiredData,
    required List<String> steps,
  }) : super._(
         status: status,
         message: message,
         summary: summary,
         requiredData: requiredData,
         steps: steps,
       );

  /// Returns a shallow copy of this [AgentResearchResult]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  AgentResearchResult copyWith({
    String? status,
    String? message,
    Object? summary = _Undefined,
    List<String>? requiredData,
    List<String>? steps,
  }) {
    return AgentResearchResult(
      status: status ?? this.status,
      message: message ?? this.message,
      summary: summary is String? ? summary : this.summary,
      requiredData: requiredData ?? this.requiredData.map((e0) => e0).toList(),
      steps: steps ?? this.steps.map((e0) => e0).toList(),
    );
  }
}
