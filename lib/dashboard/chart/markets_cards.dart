import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';
import 'package:genius_wallet/dashboard/chart/markets_table.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

// `MarketRow` lives in `markets_table.dart` (its original home, restored
// 2026-08-07) — imported here, not redefined, so both renderings share one
// definition.

/// "All Markets" body: the table when it fits, cards when it does not.
///
/// Braian's actual ask, corrected 2026-08-07 (quick 260807-bxs) after a
/// same-day detour replaced the desktop table with cards unconditionally:
/// "cards ... only when the data does not fit a table". The gate is
/// literally that — this box's own measured width against the table's own
/// minimum width (`kMarketsTableMinWidth`, the sum of its column-width
/// constants) — not a device-class check like `useDesktopLayout`. A
/// hardcoded breakpoint would be a different rule that happens to agree at
/// common sizes; measuring the actual box is what makes "does the table fit"
/// true by construction rather than by coincidence.
///
/// Single call site (`markets_screen.dart`), and the ONE page-width surface
/// for "All Markets" — this is not the shared-row-widget trap from
/// 260806-hfe (a widget reused across many differently-sized containers, so
/// measuring its OWN box was the wrong signal there). Here the box this
/// `LayoutBuilder` is handed IS the page's content width, so reading it
/// directly is correct. Do not "fix" this into a `useDesktopLayout` check.
class MarketsAllSection extends StatelessWidget {
  final List<MarketRow> rows;
  final void Function(MarketRow row) onTapRow;

  const MarketsAllSection({
    super.key,
    required this.rows,
    required this.onTapRow,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        if (marketsSectionUsesTable(c.maxWidth)) {
          return MarketsTable(rows: rows, onTapRow: onTapRow);
        }
        return _MarketsCardGrid(rows: rows, onTapRow: onTapRow);
      },
    );
  }
}

/// Whether [MarketsAllSection] renders the TABLE, rather than the card grid,
/// in a box this wide.
///
/// Exists so the caller can pick its `GWSectionTitle`'s `contentTopInset`
/// from the same predicate the section itself branches on. The two must
/// agree: `GWSectionTitle` spends its bottom pad against whatever internal
/// top padding the content below declares, and the two branches here declare
/// DIFFERENT amounts — the table's header row carries `vertical: space6`, so
/// its first painted pixel sits 12px into its box, while a card grid leads
/// with a `GWCard` whose surface starts at its box edge and declares 0. Ship
/// one constant for both and the section's rendered gap is wrong on one of
/// them, which is the inconsistent-title-rhythm defect `GWSectionTitle`'s own
/// doc comment was written to kill.
bool marketsSectionUsesTable(double width) => width >= kMarketsTableMinWidth;

/// The card grid: one card per coin, one per row at phone width and two per
/// row at desktop, ordered rank ascending — the table's own default order.
/// Reached only when [MarketsAllSection] measures a box narrower than the
/// table's [kMarketsTableMinWidth].
///
/// Stateless: the sort state the table carries is gone here. Interactive
/// column sorting stayed on the table (it never left, per the correction
/// above); the card grid keeps rank order only (`markets_sort.dart` and its
/// comparator are reused, not reimplemented).
class _MarketsCardGrid extends StatelessWidget {
  final List<MarketRow> rows;
  final void Function(MarketRow row) onTapRow;

  const _MarketsCardGrid({required this.rows, required this.onTapRow});

  @override
  Widget build(BuildContext context) {
    // The module comparator, not a hardcoded `.sort` on the rank field — it
    // keeps `markets_sort.dart` and its test live and the ordering defined in
    // exactly one place, for exactly the reason above.
    final sorted = [
      ...rows,
    ]..sort((a, b) => compareMarketRows(MarketSort.rank, true, a.sort, b.sort));

    // This is the grid's OWN column count (1 vs 2), a separate question from
    // whether the grid renders at all — that gate is `MarketsAllSection`'s,
    // measured off the box (see its doc comment). A device-class check is
    // fine here specifically because a card, unlike the table, has no fixed
    // minimum width of its own to measure against — `useDesktopLayout` is
    // the only signal available for "is there room for a second column".
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
