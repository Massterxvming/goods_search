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
import 'package:serverpod/protocol.dart' as _i2;
import 'agent/agent_research_result.dart' as _i3;
import 'agent/agent_service_status.dart' as _i4;
import 'agent/forecast_price_point.dart' as _i5;
import 'agent/historical_price_quote.dart' as _i6;
import 'agent/market_price_history.dart' as _i7;
import 'agent/market_price_quote.dart' as _i8;
import 'agent/market_price_report.dart' as _i9;
import 'agent/market_price_request.dart' as _i10;
import 'agent/market_price_source.dart' as _i11;
import 'agent/monthly_price_point.dart' as _i12;
import 'agent/platform_search_diagnostic.dart' as _i13;
import 'agent/price_forecast.dart' as _i14;
import 'agent/price_history_request.dart' as _i15;
import 'agent/price_observation.dart' as _i16;
import 'agent/price_research_request.dart' as _i17;
import 'agent/price_retrieval_diagnostics.dart' as _i18;
import 'greetings/greeting.dart' as _i19;
export 'agent/agent_research_result.dart';
export 'agent/agent_service_status.dart';
export 'agent/forecast_price_point.dart';
export 'agent/historical_price_quote.dart';
export 'agent/market_price_history.dart';
export 'agent/market_price_quote.dart';
export 'agent/market_price_report.dart';
export 'agent/market_price_request.dart';
export 'agent/market_price_source.dart';
export 'agent/monthly_price_point.dart';
export 'agent/platform_search_diagnostic.dart';
export 'agent/price_forecast.dart';
export 'agent/price_history_request.dart';
export 'agent/price_observation.dart';
export 'agent/price_research_request.dart';
export 'agent/price_retrieval_diagnostics.dart';
export 'greetings/greeting.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'price_observation',
      dartName: 'PriceObservation',
      schema: 'public',
      module: 'goods_search',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'price_observation_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'queryKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'observationKey',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'platform',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'productId',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'sourceUrl',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'seller',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'priceCents',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int',
        ),
        _i2.ColumnDefinition(
          name: 'priceText',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'observedAt',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: false,
          dartType: 'DateTime',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'price_observation_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        ),
        _i2.IndexDefinition(
          indexName: 'price_observation_unique_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'observationKey',
            ),
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: false,
        ),
        _i2.IndexDefinition(
          indexName: 'price_observation_query_time_idx',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'queryKey',
            ),
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'observedAt',
            ),
          ],
          type: 'btree',
          isUnique: false,
          isPrimary: false,
        ),
      ],
      managed: true,
    ),
    ..._i2.Protocol.targetTableDefinitions,
  ];

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i3.AgentResearchResult) {
      return _i3.AgentResearchResult.fromJson(data) as T;
    }
    if (t == _i4.AgentServiceStatus) {
      return _i4.AgentServiceStatus.fromJson(data) as T;
    }
    if (t == _i5.ForecastPricePoint) {
      return _i5.ForecastPricePoint.fromJson(data) as T;
    }
    if (t == _i6.HistoricalPriceQuote) {
      return _i6.HistoricalPriceQuote.fromJson(data) as T;
    }
    if (t == _i7.MarketPriceHistory) {
      return _i7.MarketPriceHistory.fromJson(data) as T;
    }
    if (t == _i8.MarketPriceQuote) {
      return _i8.MarketPriceQuote.fromJson(data) as T;
    }
    if (t == _i9.MarketPriceReport) {
      return _i9.MarketPriceReport.fromJson(data) as T;
    }
    if (t == _i10.MarketPriceRequest) {
      return _i10.MarketPriceRequest.fromJson(data) as T;
    }
    if (t == _i11.MarketPriceSource) {
      return _i11.MarketPriceSource.fromJson(data) as T;
    }
    if (t == _i12.MonthlyPricePoint) {
      return _i12.MonthlyPricePoint.fromJson(data) as T;
    }
    if (t == _i13.PlatformSearchDiagnostic) {
      return _i13.PlatformSearchDiagnostic.fromJson(data) as T;
    }
    if (t == _i14.PriceForecast) {
      return _i14.PriceForecast.fromJson(data) as T;
    }
    if (t == _i15.PriceHistoryRequest) {
      return _i15.PriceHistoryRequest.fromJson(data) as T;
    }
    if (t == _i16.PriceObservation) {
      return _i16.PriceObservation.fromJson(data) as T;
    }
    if (t == _i17.PriceResearchRequest) {
      return _i17.PriceResearchRequest.fromJson(data) as T;
    }
    if (t == _i18.PriceRetrievalDiagnostics) {
      return _i18.PriceRetrievalDiagnostics.fromJson(data) as T;
    }
    if (t == _i19.Greeting) {
      return _i19.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.AgentResearchResult?>()) {
      return (data != null ? _i3.AgentResearchResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i4.AgentServiceStatus?>()) {
      return (data != null ? _i4.AgentServiceStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.ForecastPricePoint?>()) {
      return (data != null ? _i5.ForecastPricePoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.HistoricalPriceQuote?>()) {
      return (data != null ? _i6.HistoricalPriceQuote.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i7.MarketPriceHistory?>()) {
      return (data != null ? _i7.MarketPriceHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MarketPriceQuote?>()) {
      return (data != null ? _i8.MarketPriceQuote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.MarketPriceReport?>()) {
      return (data != null ? _i9.MarketPriceReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.MarketPriceRequest?>()) {
      return (data != null ? _i10.MarketPriceRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i11.MarketPriceSource?>()) {
      return (data != null ? _i11.MarketPriceSource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.MonthlyPricePoint?>()) {
      return (data != null ? _i12.MonthlyPricePoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.PlatformSearchDiagnostic?>()) {
      return (data != null
              ? _i13.PlatformSearchDiagnostic.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i14.PriceForecast?>()) {
      return (data != null ? _i14.PriceForecast.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.PriceHistoryRequest?>()) {
      return (data != null ? _i15.PriceHistoryRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.PriceObservation?>()) {
      return (data != null ? _i16.PriceObservation.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.PriceResearchRequest?>()) {
      return (data != null ? _i17.PriceResearchRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i18.PriceRetrievalDiagnostics?>()) {
      return (data != null
              ? _i18.PriceRetrievalDiagnostics.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i19.Greeting?>()) {
      return (data != null ? _i19.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i12.MonthlyPricePoint>) {
      return (data as List)
              .map((e) => deserialize<_i12.MonthlyPricePoint>(e))
              .toList()
          as T;
    }
    if (t == List<_i8.MarketPriceQuote>) {
      return (data as List)
              .map((e) => deserialize<_i8.MarketPriceQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i11.MarketPriceSource>) {
      return (data as List)
              .map((e) => deserialize<_i11.MarketPriceSource>(e))
              .toList()
          as T;
    }
    if (t == List<_i6.HistoricalPriceQuote>) {
      return (data as List)
              .map((e) => deserialize<_i6.HistoricalPriceQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i5.ForecastPricePoint>) {
      return (data as List)
              .map((e) => deserialize<_i5.ForecastPricePoint>(e))
              .toList()
          as T;
    }
    if (t == List<_i13.PlatformSearchDiagnostic>) {
      return (data as List)
              .map((e) => deserialize<_i13.PlatformSearchDiagnostic>(e))
              .toList()
          as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i3.AgentResearchResult => 'AgentResearchResult',
      _i4.AgentServiceStatus => 'AgentServiceStatus',
      _i5.ForecastPricePoint => 'ForecastPricePoint',
      _i6.HistoricalPriceQuote => 'HistoricalPriceQuote',
      _i7.MarketPriceHistory => 'MarketPriceHistory',
      _i8.MarketPriceQuote => 'MarketPriceQuote',
      _i9.MarketPriceReport => 'MarketPriceReport',
      _i10.MarketPriceRequest => 'MarketPriceRequest',
      _i11.MarketPriceSource => 'MarketPriceSource',
      _i12.MonthlyPricePoint => 'MonthlyPricePoint',
      _i13.PlatformSearchDiagnostic => 'PlatformSearchDiagnostic',
      _i14.PriceForecast => 'PriceForecast',
      _i15.PriceHistoryRequest => 'PriceHistoryRequest',
      _i16.PriceObservation => 'PriceObservation',
      _i17.PriceResearchRequest => 'PriceResearchRequest',
      _i18.PriceRetrievalDiagnostics => 'PriceRetrievalDiagnostics',
      _i19.Greeting => 'Greeting',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst(
        'goods_search.',
        '',
      );
    }

    switch (data) {
      case _i3.AgentResearchResult():
        return 'AgentResearchResult';
      case _i4.AgentServiceStatus():
        return 'AgentServiceStatus';
      case _i5.ForecastPricePoint():
        return 'ForecastPricePoint';
      case _i6.HistoricalPriceQuote():
        return 'HistoricalPriceQuote';
      case _i7.MarketPriceHistory():
        return 'MarketPriceHistory';
      case _i8.MarketPriceQuote():
        return 'MarketPriceQuote';
      case _i9.MarketPriceReport():
        return 'MarketPriceReport';
      case _i10.MarketPriceRequest():
        return 'MarketPriceRequest';
      case _i11.MarketPriceSource():
        return 'MarketPriceSource';
      case _i12.MonthlyPricePoint():
        return 'MonthlyPricePoint';
      case _i13.PlatformSearchDiagnostic():
        return 'PlatformSearchDiagnostic';
      case _i14.PriceForecast():
        return 'PriceForecast';
      case _i15.PriceHistoryRequest():
        return 'PriceHistoryRequest';
      case _i16.PriceObservation():
        return 'PriceObservation';
      case _i17.PriceResearchRequest():
        return 'PriceResearchRequest';
      case _i18.PriceRetrievalDiagnostics():
        return 'PriceRetrievalDiagnostics';
      case _i19.Greeting():
        return 'Greeting';
    }
    className = _i2.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'AgentResearchResult') {
      return deserialize<_i3.AgentResearchResult>(data['data']);
    }
    if (dataClassName == 'AgentServiceStatus') {
      return deserialize<_i4.AgentServiceStatus>(data['data']);
    }
    if (dataClassName == 'ForecastPricePoint') {
      return deserialize<_i5.ForecastPricePoint>(data['data']);
    }
    if (dataClassName == 'HistoricalPriceQuote') {
      return deserialize<_i6.HistoricalPriceQuote>(data['data']);
    }
    if (dataClassName == 'MarketPriceHistory') {
      return deserialize<_i7.MarketPriceHistory>(data['data']);
    }
    if (dataClassName == 'MarketPriceQuote') {
      return deserialize<_i8.MarketPriceQuote>(data['data']);
    }
    if (dataClassName == 'MarketPriceReport') {
      return deserialize<_i9.MarketPriceReport>(data['data']);
    }
    if (dataClassName == 'MarketPriceRequest') {
      return deserialize<_i10.MarketPriceRequest>(data['data']);
    }
    if (dataClassName == 'MarketPriceSource') {
      return deserialize<_i11.MarketPriceSource>(data['data']);
    }
    if (dataClassName == 'MonthlyPricePoint') {
      return deserialize<_i12.MonthlyPricePoint>(data['data']);
    }
    if (dataClassName == 'PlatformSearchDiagnostic') {
      return deserialize<_i13.PlatformSearchDiagnostic>(data['data']);
    }
    if (dataClassName == 'PriceForecast') {
      return deserialize<_i14.PriceForecast>(data['data']);
    }
    if (dataClassName == 'PriceHistoryRequest') {
      return deserialize<_i15.PriceHistoryRequest>(data['data']);
    }
    if (dataClassName == 'PriceObservation') {
      return deserialize<_i16.PriceObservation>(data['data']);
    }
    if (dataClassName == 'PriceResearchRequest') {
      return deserialize<_i17.PriceResearchRequest>(data['data']);
    }
    if (dataClassName == 'PriceRetrievalDiagnostics') {
      return deserialize<_i18.PriceRetrievalDiagnostics>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i19.Greeting>(data['data']);
    }
    if (dataClassName.startsWith('serverpod.')) {
      data['className'] = dataClassName.substring(10);
      return _i2.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i16.PriceObservation:
        return _i16.PriceObservation.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'goods_search';

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i2.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
