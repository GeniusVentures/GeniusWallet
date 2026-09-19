import 'package:flutter/material.dart';
import 'package:genius_wallet/squid_router/squid_util.dart';
import 'package:genius_wallet/swap/swap_quote.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class RouteDetailsCard extends StatelessWidget {
  final SwapQuote quote;
  final String fromAmount;
  final String toAmount;

  /// Symbols rather than token objects: the card renders two words, and
  /// taking the whole model would tie this widget to whatever shape the
  /// token catalogue happens to have.
  final String? fromSymbol;
  final String? toSymbol;
  final String slippage;

  const RouteDetailsCard({
    super.key,
    required this.quote,
    required this.fromAmount,
    required this.toAmount,
    required this.fromSymbol,
    required this.toSymbol,
    required this.slippage,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // A phone frame cannot hold a full-precision pair. Display only: the
    // amounts that actually move are BigInt and are never read back off this
    // string, so shortening it cannot reach the transaction.
    final showFull = GeniusBreakpoints.useDesktopLayout(context);
    final payShown = showFull ? fromAmount : capDecimals(fromAmount, 4);
    final getShown = showFull ? toAmount : capDecimals(toAmount, 4);
    final pricing = '$payShown $fromSymbol ~ $getShown $toSymbol';
    final priceImpact = '${formatPercent(quote.priceImpact)}%';

    return Container(
      // Vertical only. A horizontal margin here inset this card 16px inside
      // the two amount cards above it, which carry no outer margin of their
      // own — the column already applies the page gutter once, at its own
      // level, so anything adding a second one lands on a different edge.
      margin: const EdgeInsets.symmetric(vertical: GeniusWalletConsts.space4),
      decoration: BoxDecoration(
        color: gw.surfaceElevated,
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusMd),
        border: Border.all(color: gw.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _DetailRow(label: "Pricing", value: pricing, showDivider: true),
          _DetailRow(label: "Slippage", value: slippage, showDivider: true),
          _DetailRow(
            label: "Price Impact",
            value: priceImpact,
            showDivider: true,
            valueColor: gw.statusSuccess,
          ),
          // Each fee the route charges is its own row, named the way the
          // route named it — never summed into one figure. Empty on a
          // same-chain route, which is the normal case, not an omission.
          for (final fee in quote.feeLines)
            _DetailRow(
              label: fee.name,
              value: '\$${fee.amountUsd.toStringAsFixed(2)}',
              showDivider: true,
            ),
          _DetailRow(
            label: "Network gas",
            value: '\$${quote.gasUsd.toStringAsFixed(2)}',
          ),
        ],
      ),
    );
  }
}

/// One label/value fact row with an optional trailing divider. A widget, not
/// a helper method, so it can be pumped and inspected on its own.
class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.label,
    required this.value,
    this.showDivider = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final bool showDivider;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read, same as the card's own: forces this row to rebuild on
    // a live appearance toggle rather than freezing a colour from build time.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space10,
            vertical: GeniusWalletConsts.space6,
          ),
          // One node per row, so a screen reader reads "Boost fee, $0.10"
          // rather than two strings whose pairing is only positional.
          child: MergeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Both children flex. A fee label is whatever the route
                // called it, so neither side's width is known here, and an
                // unflexed label would starve the value of the space it
                // needs to stay on one line.
                Flexible(
                  child: Text(
                    label,
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
                ),
                Flexible(
                  child: Text(
                    value,
                    textAlign: TextAlign.end,
                    style: GeniusWalletTypography.labelMd.copyWith(
                      color: valueColor ?? gw.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          Divider(height: 1, thickness: 1, color: gw.borderSubtle),
      ],
    );
  }
}
