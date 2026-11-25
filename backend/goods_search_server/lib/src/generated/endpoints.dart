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
import '../agent/agent_endpoint.dart' as _i2;
import '../greetings/greeting_endpoint.dart' as _i3;
import 'package:goods_search_server/src/generated/agent/price_history_request.dart'
    as _i4;
import 'package:goods_search_server/src/generated/agent/market_price_request.dart'
    as _i5;
import 'package:goods_search_server/src/generated/agent/price_research_request.dart'
    as _i6;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'agent': _i2.AgentEndpoint()
        ..initialize(
          server,
          'agent',
          null,
        ),
      'greeting': _i3.GreetingEndpoint()
        ..initialize(
          server,
          'greeting',
          null,
        ),
    };
    connectors['agent'] = _i1.EndpointConnector(
      name: 'agent',
      endpoint: endpoints['agent']!,
      methodConnectors: {
        'priceHistory': _i1.MethodConnector(
          name: 'priceHistory',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<_i4.PriceHistoryRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i2.AgentEndpoint).priceHistory(
                session,
                params['query'],
              ),
        ),
        'currentPrice': _i1.MethodConnector(
          name: 'currentPrice',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<_i5.MarketPriceRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i2.AgentEndpoint).currentPrice(
                session,
                params['query'],
              ),
        ),
        'status': _i1.MethodConnector(
          name: 'status',
          params: {},
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async =>
                  (endpoints['agent'] as _i2.AgentEndpoint).status(session),
        ),
        'planResearch': _i1.MethodConnector(
          name: 'planResearch',
          params: {
            'query': _i1.ParameterDescription(
              name: 'query',
              type: _i1.getType<_i6.PriceResearchRequest>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['agent'] as _i2.AgentEndpoint).planResearch(
                session,
                params['query'],
              ),
        ),
      },
    );
    connectors['greeting'] = _i1.EndpointConnector(
      name: 'greeting',
      endpoint: endpoints['greeting']!,
      methodConnectors: {
        'hello': _i1.MethodConnector(
          name: 'hello',
          params: {
            'name': _i1.ParameterDescription(
              name: 'name',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call:
              (
                _i1.Session session,
                Map<String, dynamic> params,
              ) async => (endpoints['greeting'] as _i3.GreetingEndpoint).hello(
                session,
                params['name'],
              ),
        ),
      },
    );
  }
}
