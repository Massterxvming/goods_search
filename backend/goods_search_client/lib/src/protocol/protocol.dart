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
import 'agent/agent_research_result.dart' as _i2;
import 'agent/agent_service_status.dart' as _i3;
import 'agent/forecast_price_point.dart' as _i4;
import 'agent/historical_price_quote.dart' as _i5;
import 'agent/market_price_history.dart' as _i6;
import 'agent/market_price_quote.dart' as _i7;
import 'agent/market_price_report.dart' as _i8;
import 'agent/market_price_request.dart' as _i9;
import 'agent/market_price_source.dart' as _i10;
import 'agent/monthly_price_point.dart' as _i11;
import 'agent/platform_search_diagnostic.dart' as _i12;
import 'agent/price_forecast.dart' as _i13;
import 'agent/price_history_request.dart' as _i14;
import 'agent/price_research_request.dart' as _i15;
import 'agent/price_retrieval_diagnostics.dart' as _i16;
import 'greetings/greeting.dart' as _i17;
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
export 'agent/price_research_request.dart';
export 'agent/price_retrieval_diagnostics.dart';
export 'greetings/greeting.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

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

    if (t == _i2.AgentResearchResult) {
      return _i2.AgentResearchResult.fromJson(data) as T;
    }
    if (t == _i3.AgentServiceStatus) {
      return _i3.AgentServiceStatus.fromJson(data) as T;
    }
    if (t == _i4.ForecastPricePoint) {
      return _i4.ForecastPricePoint.fromJson(data) as T;
    }
    if (t == _i5.HistoricalPriceQuote) {
      return _i5.HistoricalPriceQuote.fromJson(data) as T;
    }
    if (t == _i6.MarketPriceHistory) {
      return _i6.MarketPriceHistory.fromJson(data) as T;
    }
    if (t == _i7.MarketPriceQuote) {
      return _i7.MarketPriceQuote.fromJson(data) as T;
    }
    if (t == _i8.MarketPriceReport) {
      return _i8.MarketPriceReport.fromJson(data) as T;
    }
    if (t == _i9.MarketPriceRequest) {
      return _i9.MarketPriceRequest.fromJson(data) as T;
    }
    if (t == _i10.MarketPriceSource) {
      return _i10.MarketPriceSource.fromJson(data) as T;
    }
    if (t == _i11.MonthlyPricePoint) {
      return _i11.MonthlyPricePoint.fromJson(data) as T;
    }
    if (t == _i12.PlatformSearchDiagnostic) {
      return _i12.PlatformSearchDiagnostic.fromJson(data) as T;
    }
    if (t == _i13.PriceForecast) {
      return _i13.PriceForecast.fromJson(data) as T;
    }
    if (t == _i14.PriceHistoryRequest) {
      return _i14.PriceHistoryRequest.fromJson(data) as T;
    }
    if (t == _i15.PriceResearchRequest) {
      return _i15.PriceResearchRequest.fromJson(data) as T;
    }
    if (t == _i16.PriceRetrievalDiagnostics) {
      return _i16.PriceRetrievalDiagnostics.fromJson(data) as T;
    }
    if (t == _i17.Greeting) {
      return _i17.Greeting.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.AgentResearchResult?>()) {
      return (data != null ? _i2.AgentResearchResult.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i3.AgentServiceStatus?>()) {
      return (data != null ? _i3.AgentServiceStatus.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ForecastPricePoint?>()) {
      return (data != null ? _i4.ForecastPricePoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.HistoricalPriceQuote?>()) {
      return (data != null ? _i5.HistoricalPriceQuote.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i6.MarketPriceHistory?>()) {
      return (data != null ? _i6.MarketPriceHistory.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.MarketPriceQuote?>()) {
      return (data != null ? _i7.MarketPriceQuote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.MarketPriceReport?>()) {
      return (data != null ? _i8.MarketPriceReport.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.MarketPriceRequest?>()) {
      return (data != null ? _i9.MarketPriceRequest.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.MarketPriceSource?>()) {
      return (data != null ? _i10.MarketPriceSource.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.MonthlyPricePoint?>()) {
      return (data != null ? _i11.MonthlyPricePoint.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.PlatformSearchDiagnostic?>()) {
      return (data != null
              ? _i12.PlatformSearchDiagnostic.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i13.PriceForecast?>()) {
      return (data != null ? _i13.PriceForecast.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i14.PriceHistoryRequest?>()) {
      return (data != null ? _i14.PriceHistoryRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i15.PriceResearchRequest?>()) {
      return (data != null ? _i15.PriceResearchRequest.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i16.PriceRetrievalDiagnostics?>()) {
      return (data != null
              ? _i16.PriceRetrievalDiagnostics.fromJson(data)
              : null)
          as T;
    }
    if (t == _i1.getType<_i17.Greeting?>()) {
      return (data != null ? _i17.Greeting.fromJson(data) : null) as T;
    }
    if (t == List<String>) {
      return (data as List).map((e) => deserialize<String>(e)).toList() as T;
    }
    if (t == List<_i11.MonthlyPricePoint>) {
      return (data as List)
              .map((e) => deserialize<_i11.MonthlyPricePoint>(e))
              .toList()
          as T;
    }
    if (t == List<_i7.MarketPriceQuote>) {
      return (data as List)
              .map((e) => deserialize<_i7.MarketPriceQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i10.MarketPriceSource>) {
      return (data as List)
              .map((e) => deserialize<_i10.MarketPriceSource>(e))
              .toList()
          as T;
    }
    if (t == List<_i5.HistoricalPriceQuote>) {
      return (data as List)
              .map((e) => deserialize<_i5.HistoricalPriceQuote>(e))
              .toList()
          as T;
    }
    if (t == List<_i4.ForecastPricePoint>) {
      return (data as List)
              .map((e) => deserialize<_i4.ForecastPricePoint>(e))
              .toList()
          as T;
    }
    if (t == List<_i12.PlatformSearchDiagnostic>) {
      return (data as List)
              .map((e) => deserialize<_i12.PlatformSearchDiagnostic>(e))
              .toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.AgentResearchResult => 'AgentResearchResult',
      _i3.AgentServiceStatus => 'AgentServiceStatus',
      _i4.ForecastPricePoint => 'ForecastPricePoint',
      _i5.HistoricalPriceQuote => 'HistoricalPriceQuote',
      _i6.MarketPriceHistory => 'MarketPriceHistory',
      _i7.MarketPriceQuote => 'MarketPriceQuote',
      _i8.MarketPriceReport => 'MarketPriceReport',
      _i9.MarketPriceRequest => 'MarketPriceRequest',
      _i10.MarketPriceSource => 'MarketPriceSource',
      _i11.MonthlyPricePoint => 'MonthlyPricePoint',
      _i12.PlatformSearchDiagnostic => 'PlatformSearchDiagnostic',
      _i13.PriceForecast => 'PriceForecast',
      _i14.PriceHistoryRequest => 'PriceHistoryRequest',
      _i15.PriceResearchRequest => 'PriceResearchRequest',
      _i16.PriceRetrievalDiagnostics => 'PriceRetrievalDiagnostics',
      _i17.Greeting => 'Greeting',
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
      case _i2.AgentResearchResult():
        return 'AgentResearchResult';
      case _i3.AgentServiceStatus():
        return 'AgentServiceStatus';
      case _i4.ForecastPricePoint():
        return 'ForecastPricePoint';
      case _i5.HistoricalPriceQuote():
        return 'HistoricalPriceQuote';
      case _i6.MarketPriceHistory():
        return 'MarketPriceHistory';
      case _i7.MarketPriceQuote():
        return 'MarketPriceQuote';
      case _i8.MarketPriceReport():
        return 'MarketPriceReport';
      case _i9.MarketPriceRequest():
        return 'MarketPriceRequest';
      case _i10.MarketPriceSource():
        return 'MarketPriceSource';
      case _i11.MonthlyPricePoint():
        return 'MonthlyPricePoint';
      case _i12.PlatformSearchDiagnostic():
        return 'PlatformSearchDiagnostic';
      case _i13.PriceForecast():
        return 'PriceForecast';
      case _i14.PriceHistoryRequest():
        return 'PriceHistoryRequest';
      case _i15.PriceResearchRequest():
        return 'PriceResearchRequest';
      case _i16.PriceRetrievalDiagnostics():
        return 'PriceRetrievalDiagnostics';
      case _i17.Greeting():
        return 'Greeting';
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
      return deserialize<_i2.AgentResearchResult>(data['data']);
    }
    if (dataClassName == 'AgentServiceStatus') {
      return deserialize<_i3.AgentServiceStatus>(data['data']);
    }
    if (dataClassName == 'ForecastPricePoint') {
      return deserialize<_i4.ForecastPricePoint>(data['data']);
    }
    if (dataClassName == 'HistoricalPriceQuote') {
      return deserialize<_i5.HistoricalPriceQuote>(data['data']);
    }
    if (dataClassName == 'MarketPriceHistory') {
      return deserialize<_i6.MarketPriceHistory>(data['data']);
    }
    if (dataClassName == 'MarketPriceQuote') {
      return deserialize<_i7.MarketPriceQuote>(data['data']);
    }
    if (dataClassName == 'MarketPriceReport') {
      return deserialize<_i8.MarketPriceReport>(data['data']);
    }
    if (dataClassName == 'MarketPriceRequest') {
      return deserialize<_i9.MarketPriceRequest>(data['data']);
    }
    if (dataClassName == 'MarketPriceSource') {
      return deserialize<_i10.MarketPriceSource>(data['data']);
    }
    if (dataClassName == 'MonthlyPricePoint') {
      return deserialize<_i11.MonthlyPricePoint>(data['data']);
    }
    if (dataClassName == 'PlatformSearchDiagnostic') {
      return deserialize<_i12.PlatformSearchDiagnostic>(data['data']);
    }
    if (dataClassName == 'PriceForecast') {
      return deserialize<_i13.PriceForecast>(data['data']);
    }
    if (dataClassName == 'PriceHistoryRequest') {
      return deserialize<_i14.PriceHistoryRequest>(data['data']);
    }
    if (dataClassName == 'PriceResearchRequest') {
      return deserialize<_i15.PriceResearchRequest>(data['data']);
    }
    if (dataClassName == 'PriceRetrievalDiagnostics') {
      return deserialize<_i16.PriceRetrievalDiagnostics>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i17.Greeting>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
