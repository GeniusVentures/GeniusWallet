import 'package:flutter/material.dart';
import 'package:genius_wallet/squid_router/models/squid_route_response.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';

class RouteDetailsCard extends StatelessWidget {
  final SquidRouteResponse route;
  final String fromAmount;
  final String toAmount;
  final SquidTokenInfo? fromToken;
  final SquidTokenInfo? toToken;
  final String slippage;

  const RouteDetailsCard(
      {super.key,
      required this.route,
      required this.fromAmount,
      required this.toAmount,
      required this.fromToken,
      required this.toToken,
      required this.slippage});

  @override
  Widget build(BuildContext context) {
    final pricing =
        '$fromAmount ${fromToken?.symbol} ~ $toAmount ${toToken?.symbol}';
    final priceImpact = '${route.aggregatePriceImpact}%';
    final totalFeesUsd = route.feeCosts.fold<double>(
      0.0,
      (sum, fee) => sum + double.tryParse(fee.amountUSD)!,
    );
    final fees = '\$${totalFeesUsd.toStringAsFixed(2)}';

    return Card(
      color: GeniusWalletColors.deepBlueCardColor,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row("Pricing", pricing, showDivider: true),
          _row("Slippage", slippage, showDivider: true),
          _row("Price Impact", priceImpact, showDivider: true),
          _row("Fees", fees),
        ],
      ),
    );
  }

  Widget _row(String label, String value, {bool showDivider = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label,
                  style: const TextStyle(color: Colors.white70, fontSize: 14)),
              Text(value,
                  style: const TextStyle(color: Colors.white, fontSize: 14)),
            ],
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: GeniusWalletColors.deepBlueTertiary,
          ),
      ],
    );
  }
}
