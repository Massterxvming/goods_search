import 'package:serverpod/serverpod.dart';

import '../generated/protocol.dart';
import 'agent_service_client.dart';
import 'price_history_service.dart';

class AgentEndpoint extends Endpoint {
  /// Reads verified monthly observations and optionally refreshes this month.
  Future<MarketPriceReport> priceHistory(
    Session session,
    PriceHistoryRequest query,
  ) async {
    final client = AgentServiceClient();
    try {
      return await PriceHistoryService(
        store: ServerpodPriceObservationStore(session),
        lookup: client.currentPrice,
      ).research(query);
    } finally {
      client.close();
    }
  }

  /// Surveys sourced current retail quotations and computes a sample average.
  Future<MarketPriceReport> currentPrice(
    Session session,
    MarketPriceRequest query,
  ) async {
    final client = AgentServiceClient();
    try {
      return await client.currentPrice(query);
    } finally {
      client.close();
    }
  }

  /// Checks SDK availability without sending a request to a model provider.
  Future<AgentServiceStatus> status(Session session) async {
    final client = AgentServiceClient();
    try {
      return await client.getStatus();
    } finally {
      client.close();
    }
  }

  /// Runs the research-planning agent only after a model is configured.
  /// Monthly observations and simple forecasts are provided by priceHistory.
  Future<AgentResearchResult> planResearch(
    Session session,
    PriceResearchRequest query,
  ) async {
    final client = AgentServiceClient();
    try {
      return await client.planResearch(query);
    } finally {
      client.close();
    }
  }
}
