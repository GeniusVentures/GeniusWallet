import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

/// One row of the "All Markets" list: the display payload ([coin], [data])
/// plus its Flutter-free [sort] projection (see [MarketRowData]).
class MarketRow {
  final CoinGeckoCoin coin;
  final CoinGeckoMarketData data;
  final MarketRowData sort;

  MarketRow(this.coin, this.data)
    : sort = MarketRowData(
        rank: data.marketCapRank,
        name: coin.name,
        price: data.currentPrice,
        changePct: data.priceChangePercentage24h,
        marketCap: data.marketCap,
        volume: data.totalVolume,
      );
}

/// "All Markets" body: a card per coin (sketch 103 · H1 body), one per row at
/// phone width and two per row at desktop, ordered rank ascending — the
/// table's own default order.
///
/// Stateless: the sort state that made the old table stateful is gone.
/// Interactive column sorting went with the table headers it lived on; only
/// rank order remains (a decision recorded in quick 260807-bxs, which the
/// user can revisit — `markets_sort.dart` and its comparator stay live
/// specifically so a sort control could be added back above the list without
/// rework).
class MarketsCards extends StatelessWidget {
  final List<MarketRow> rows;
  final void Function(MarketRow row) onTapRow;

  const MarketsCards({super.key, required this.rows, required this.onTapRow});

  @override
  Widget build(BuildContext context) {
    // The module comparator, not a hardcoded `.sort` on the rank field — it
    // keeps `markets_sort.dart` and its test live and the ordering defined in
    // exactly one place, for exactly the reason above.
    final sorted = [
      ...rows,
    ]..sort((a, b) => compareMarketRows(MarketSort.rank, true, a.sort, b.sort));

    // The window is the authority on device class here, not a `LayoutBuilder`
    // reading this list's own box width: this list is a page-width surface
    // with one call site, and gating on a box's own width is how a previous
    // task restyled the desktop dashboard from a 376px panel that was never
    // the page.
    final int columns = GeniusBreakpoints.useDesktopLayout(context) ? 2 : 1;

    final List<Widget> cardRows = [];
    for (var i = 0; i < sorted.length; i += columns) {
      final int end = (i + columns < sorted.length)
          ? i + columns
          : sorted.length;
      final chunk = sorted.sublist(i, end);
      cardRows.add(
        Row(
          // `CrossAxisAlignment.stretch` is forbidden here: this list lives
          // inside the page's vertical `SingleChildScrollView`, so a card
          // row's incoming height is unbounded and stretch has nothing to
          // resolve against — the children would collapse to zero height,
          // the same failure the hero card's `IntrinsicHeight` comment
          // documents. `start` is visually indistinguishable from stretch
          // here because every text in a card is single-line and ellipsised,
          // so the cards are uniform height by construction.
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: GeniusWalletConsts.space12,
          children: [
            for (final row in chunk)
              Expanded(
                child: _MarketCard(row: row, onTap: () => onTapRow(row)),
              ),
            // An odd final row at 2 columns gets an empty flexible child so
            // the last card stays at its normal column width instead of
            // stretching to fill the row.
            if (chunk.length < columns) const Spacer(),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: GeniusWalletConsts.space12,
      children: cardRows,
    );
  }
}

/// A single market card: identity + price + 24h change up top, market cap
/// and 24h volume below. No chart of any kind — a locked decision from quick
/// 260807-bxs, pinned by `markets_cards_test.dart`.
class _MarketCard extends StatelessWidget {
  final MarketRow row;
  final VoidCallback onTap;

  const _MarketCard({required this.row, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final data = row.data;
    final up = data.priceChangePercentage24h >= 0;
    final changeColor = up ? gw.statusSuccess : gw.statusError;

    // Semantics + GWCard(onTap:...) mirrors the hero card's own pattern:
    // GWCard's InkWell already gives focus and Enter/Space activation
    // (WCAG 2.1.1), so this label is what a screen reader needs on top of
    // that, not a replacement for it.
    return Semantics(
      button: true,
      label: '${row.coin.name} market detail',
      child: GWCard(
        hoverLift: true,
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // top row: identity + price/change
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                buildTokenIcon(iconPath: data.imageUrl, size: 32),
                const SizedBox(width: GeniusWalletConsts.space8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        row.coin.name,
                        style: GeniusWalletTypography.titleMd.copyWith(
                          color: gw.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        row.coin.symbol.toUpperCase(),
                        style: GeniusWalletTypography.labelMd.copyWith(
                          color: gw.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: GeniusWalletConsts.space8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _price(data.currentPrice),
                      style: GeniusWalletTypography.numericBody.copyWith(
                        color: gw.textPrimary,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    // The 24h change pill, inline — the table's own copy of
                    // this and this one are the two the Rule of Three
                    // refusal in <decisions_settled> names: a shared
                    // `GWChangePill` for a second caller is the wrong
                    // abstraction AGENTS.md warns against.
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: changeColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        '${up ? '+' : ''}${data.priceChangePercentage24h.toStringAsFixed(2)}%',
                        style: GeniusWalletTypography.labelMd.copyWith(
                          color: changeColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: GeniusWalletConsts.space12),
            // stat row: market cap + 24h volume, the same GWStatTile unit
            // the hero card renders these same two figures with.
            Row(
              children: [
                Expanded(
                  child: GWStatTile(
                    label: 'Market Cap',
                    value: _compact(data.marketCap),
                  ),
                ),
                const SizedBox(width: GeniusWalletConsts.space10),
                Expanded(
                  child: GWStatTile(
                    label: 'Volume 24h',
                    value: _compact(data.totalVolume),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Second copy of the hero card's `_price`/`_compact` — the Rule of Three
  // refusal in <decisions_settled> keeps these as two copies, not three.
  static String _price(double v) {
    final decimals = v >= 1 ? 2 : 6;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimals,
    ).format(v);
  }

  static String _compact(double v) {
    if (v >= 1e12) {
      return '\$${(v / 1e12).toStringAsFixed(2)}T';
    }
    if (v >= 1e9) {
      return '\$${(v / 1e9).toStringAsFixed(1)}B';
    }
    if (v >= 1e6) {
      return '\$${(v / 1e6).toStringAsFixed(1)}M';
    }
    if (v >= 1e3) {
      return '\$${(v / 1e3).toStringAsFixed(1)}K';
    }
    return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(v);
  }
}
