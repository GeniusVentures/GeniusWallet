import 'squid_fee_cost.dart';
import 'squid_gas_cost.dart';

class SquidRouteResponse {
  final String routeId;
  final String fromChain;
  final String toChain;
  final String fromToken;
  final String toToken;
  final String fromAmount;
  final String toAmount;
  final List<Map<String, dynamic>> route;
  final List<SquidGasCost> gasCosts;
  final List<SquidFeeCost> feeCosts;
  final String exchangeRate;
  final String aggregatePriceImpact;

  SquidRouteResponse({
    required this.routeId,
    required this.fromChain,
    required this.toChain,
    required this.fromToken,
    required this.toToken,
    required this.fromAmount,
    required this.toAmount,
    required this.route,
    required this.gasCosts,
    required this.feeCosts,
    required this.exchangeRate,
    required this.aggregatePriceImpact,
  });

  factory SquidRouteResponse.fromJson(Map<String, dynamic> json) {
    return SquidRouteResponse(
      routeId: json['routeId'],
      fromChain: json['fromChain'],
      toChain: json['toChain'],
      fromToken: json['fromToken'],
      toToken: json['toToken'],
      fromAmount: json['fromAmount'],
      toAmount: json['toAmount'],
      route: List<Map<String, dynamic>>.from(json['route']),
      gasCosts: (json['gasCosts'] as List)
          .map((e) => SquidGasCost.fromJson(e))
          .toList(),
      feeCosts: (json['feeCosts'] as List)
          .map((e) => SquidFeeCost.fromJson(e))
          .toList(),
      exchangeRate: json['exchangeRate'],
      aggregatePriceImpact: json['aggregatePriceImpact'],
    );
  }
}
