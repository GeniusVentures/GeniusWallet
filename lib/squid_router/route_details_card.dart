import 'package:flutter/material.dart';
import 'package:genius_wallet/squid_router/models/squid_route_response.dart';
import 'package:genius_wallet/squid_router/models/squid_token_info.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

class RouteDetailsCard extends StatelessWidget {
  final SquidRouteResponse route;
  final String fromAmount;
  final String toAmount;
  final SquidTokenInfo? fromToken;
  final SquidTokenInfo? toToken;
  final String slippage;

  const RouteDetailsCard({
    super.key,
    required this.route,
    required this.fromAmount,
    required this.toAmount,
    required this.fromToken,
    required this.toToken,
    required this.slippage,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final pricing =
        '$fromAmount ${fromToken?.symbol} ~ $toAmount ${toToken?.symbol}';
    final priceImpact = '${route.aggregatePriceImpact}%';
    final totalFeesUsd = route.feeCosts.fold<double>(
      0.0,
      (sum, fee) => sum + double.tryParse(fee.amountUSD)!,
    );
    final fees = '\$${totalFeesUsd.toStringAsFixed(2)}';

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space4,
      ),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: Border.all(color: gw.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _row(gw, "Pricing", pricing, showDivider: true),
          _row(gw, "Slippage", slippage, showDivider: true),
          _row(
            gw,
            "Price Impact",
            priceImpact,
            showDivider: true,
            valueColor: gw.statusSuccess,
          ),
          _row(gw, "Fees", fees),
        ],
      ),
    );
  }

  Widget _row(
    GWColors gw,
    String label,
    String value, {
    bool showDivider = false,
    Color? valueColor,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space10,
            vertical: GeniusWalletConsts.space6,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              Text(
                value,
                style: GeniusWalletTypography.labelMd.copyWith(
                  color: valueColor ?? gw.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: gw.borderSubtle),
      ],
    );
  }
}
