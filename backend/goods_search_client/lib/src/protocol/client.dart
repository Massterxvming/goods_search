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
import 'dart:async' as _i2;
import 'package:goods_search_client/src/protocol/agent/market_price_report.dart'
    as _i3;
import 'package:goods_search_client/src/protocol/agent/price_history_request.dart'
    as _i4;
import 'package:goods_search_client/src/protocol/agent/market_price_request.dart'
    as _i5;
import 'package:goods_search_client/src/protocol/agent/agent_service_status.dart'
    as _i6;
import 'package:goods_search_client/src/protocol/agent/agent_research_result.dart'
    as _i7;
import 'package:goods_search_client/src/protocol/agent/price_research_request.dart'
    as _i8;
import 'package:goods_search_client/src/protocol/greetings/greeting.dart'
    as _i9;
import 'protocol.dart' as _i10;

/// {@category Endpoint}
class EndpointAgent extends _i1.EndpointRef {
  EndpointAgent(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'agent';

  /// Reads verified monthly observations and optionally refreshes this month.
  _i2.Future<_i3.MarketPriceReport> priceHistory(
    _i4.PriceHistoryRequest query,
  ) => caller.callServerEndpoint<_i3.MarketPriceReport>(
    'agent',
    'priceHistory',
    {'query': query},
  );

  /// Surveys sourced current retail quotations and computes a sample average.
  _i2.Future<_i3.MarketPriceReport> currentPrice(
    _i5.MarketPriceRequest query,
  ) => caller.callServerEndpoint<_i3.MarketPriceReport>(
    'agent',
    'currentPrice',
    {'query': query},
  );

  /// Checks SDK availability without sending a request to a model provider.
  _i2.Future<_i6.AgentServiceStatus> status() =>
      caller.callServerEndpoint<_i6.AgentServiceStatus>(
        'agent',
        'status',
        {},
      );

  /// Runs the research-planning agent only after a model is configured.
  /// Monthly observations and simple forecasts are provided by priceHistory.
  _i2.Future<_i7.AgentResearchResult> planResearch(
    _i8.PriceResearchRequest query,
  ) => caller.callServerEndpoint<_i7.AgentResearchResult>(
    'agent',
    'planResearch',
    {'query': query},
  );
}

/// This is an example endpoint that returns a greeting message through
/// its [hello] method.
/// {@category Endpoint}
class EndpointGreeting extends _i1.EndpointRef {
  EndpointGreeting(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'greeting';

  /// Returns a personalized greeting message: "Hello {name}".
  _i2.Future<_i9.Greeting> hello(String name) =>
      caller.callServerEndpoint<_i9.Greeting>(
        'greeting',
        'hello',
        {'name': name},
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    @Deprecated(
      'Use authKeyProvider instead. This will be removed in future releases.',
    )
    super.authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )?
    onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
         host,
         _i10.Protocol(),
         securityContext: securityContext,
         streamingConnectionTimeout: streamingConnectionTimeout,
         connectionTimeout: connectionTimeout,
         onFailedCall: onFailedCall,
         onSucceededCall: onSucceededCall,
         disconnectStreamsOnLostInternetConnection:
             disconnectStreamsOnLostInternetConnection,
       ) {
    agent = EndpointAgent(this);
    greeting = EndpointGreeting(this);
  }

  late final EndpointAgent agent;

  late final EndpointGreeting greeting;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
    'agent': agent,
    'greeting': greeting,
  };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
