import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';
import 'package:genius_wallet/dashboard/chart/markets_table.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
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
        // `c.maxWidth` IS the content width the card grid needs for its own
        // column math (2026-08-07 correction) — passed straight through
        // rather than having `_MarketsCardGrid` open a second `LayoutBuilder`
        // for the same box. `LayoutBuilder` is safe in this file: the
        // `IntrinsicHeight` constraint that rules it out is specific to the
        // hero card's left column, not this page-width list.
        return _MarketsCardGrid(
          rows: rows,
          onTapRow: onTapRow,
          maxWidth: c.maxWidth,
        );
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

/// The NARROWEST a market card may be before its own content degrades, in px
/// — which is what decides how many columns the grid packs (2026-08-07,
/// quick 260807-bxs). Braian's own estimate was 256; measured instead of
/// trusted, because the card's real bottleneck is narrower than it looks at
/// first glance.
///
/// **It is a packing threshold, not a cap on the rendered card.** The cards
/// themselves `Expanded` to fill their row ("we dont need the card narrower
/// just make it flex" — Braian, same day), so a rendered card is normally
/// WIDER than this. Pinning each card at this width instead left the row's
/// remainder as dead space on the right. The name is kept for what the
/// number means to the column arithmetic; read it as "a card below this
/// stops being legible", never as "a card is this wide".
///
/// **The binding constraints, both measured directly against the running
/// card, not guessed:**
/// - The two `GWStatTile`s split the card's content width evenly minus one
///   `space10` gap. Their `GWKicker` labels ('Market Cap' / 'Volume 24h')
///   wrap to two lines below 116px of PER-TILE width — bisected precisely,
///   same as the hero card's own tile-label measurement earlier this task.
/// - The price/change-pill column never wraps or shrinks (it must not, per
///   the brief) — at the fixture's price ($63,480.00) it is a fixed 142.5px,
///   which is the real reason the coin NAME column crushes toward zero
///   width well before the stat tiles show any problem: at a 256px card the
///   name rendered at 15.5px wide (effectively invisible, not merely
///   ellipsised — a coin's name is the one thing on this card that must
///   stay legible).
///
/// Both constraints converge empirically at the SAME card width: 285px
/// still wraps a stat tile's label, 286px does not. 287 is that measured
/// threshold plus 1px of margin, matching this task's own convention (the
/// hero card's stat-tile width used the identical "+1px" margin rule).
///
/// **This conflicts with Braian's stated target of 3 columns near 846px
/// (`kMarketsTableMinWidth`), and that conflict is reported rather than
/// hidden.** 3 columns at `kMarketsTableMinWidth` would need a max width of
/// roughly 266px (even at ZERO inter-card gap, 3 * 287 alone already
/// exceeds 846) — 21px narrower than the measured 287px floor. Shipping
/// 266 would wrap the stat-tile labels on every 3-column render, not as an
/// edge case but as the normal state, and crush the coin name harder than
/// the already-tight 256px case measured above. 287 was chosen over 266:
/// content legibility over hitting the exact column count. The real
/// column pattern this produces is documented on `_MarketsCardGrid`.
const double kMarketsCardMaxWidth = 287;

/// The card grid: as many columns as `kMarketsCardMaxWidth` and the box
/// actually allow — `columns = max(1, (available + gap) ~/ (maxWidth +
/// gap))` — continuous, with no device-class check anywhere in it. Reached
/// only when [MarketsAllSection] measures a box narrower than the table's
/// [kMarketsTableMinWidth]. Cards are ordered rank ascending, the table's
/// own default order.
///
/// **Measured column counts (2026-08-07), not the 3/2/1 originally asked
/// for — see [kMarketsCardMaxWidth]'s doc comment for why:**
/// - 402px (phone): 1 column.
/// - 600px: 2 columns.
/// - 846px (just under the table's own threshold): 2 columns, not 3 — the
///   honest per-card minimum (287px) is 21px wider than 3 columns at this
///   width would allow without wrapping the stat tiles and crushing the
///   coin name.
///
/// Stateless: the sort state the table carries is gone here. Interactive
/// column sorting stayed on the table (it never left, per the correction
/// above); the card grid keeps rank order only (`markets_sort.dart` and its
/// comparator are reused, not reimplemented).
class _MarketsCardGrid extends StatelessWidget {
  final List<MarketRow> rows;
  final void Function(MarketRow row) onTapRow;
  final double maxWidth;

  const _MarketsCardGrid({
    required this.rows,
    required this.onTapRow,
    required this.maxWidth,
  });

  @override
  Widget build(BuildContext context) {
    // The module comparator, not a hardcoded `.sort` on the rank field — it
    // keeps `markets_sort.dart` and its test live and the ordering defined in
    // exactly one place, for exactly the reason above.
    final sorted = [
      ...rows,
    ]..sort((a, b) => compareMarketRows(MarketSort.rank, true, a.sort, b.sort));

    const double gap = GeniusWalletConsts.space12;
    // `~/` truncates like `floor()` for non-negative operands, which these
    // always are (`maxWidth` is a real `LayoutBuilder` box, `gap` a
    // constant) — no columns fit at all only when `maxWidth` is smaller
    // than a single card, and `max(1, ...)` below covers that floor.
    final int rawColumns = ((maxWidth + gap) / (kMarketsCardMaxWidth + gap))
        .floor();
    final int columns = rawColumns < 1 ? 1 : rawColumns;

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
          //
          // NO `spacing:` here, deliberately — `Row.spacing` inserts a gap
          // between EVERY adjacent pair of children, including the ones
          // before the filler slots below. Those extra gaps are not in
          // `columns`' own width budget (only `columns - 1` gaps are, one
          // between each pair of COLUMN SLOTS), and adding them caused a
          // real overflow at 600px width during this fix (22px, caught by
          // the widget test, not shipped). Gaps are inserted by hand
          // instead, between slots only.
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // `Expanded`, not `SizedBox(width: kMarketsCardMaxWidth)`:
            // `kMarketsCardMaxWidth` decides HOW MANY columns fit, and the
            // cards then flex to fill the row evenly (Braian, 2026-08-07:
            // "we dont need the card narrower just make it flex"). Pinning
            // each card at the max instead left the row's remainder as dead
            // space on the right — the box rarely divides evenly by 287 —
            // which read as a ragged right edge against the full-width
            // table the same page shows one breakpoint up.
            //
            // The empty trailing slots matter: a short final row pads to
            // `columns` flex slots so its cards keep the SAME width as the
            // rows above. Without them a lone last card would flex to the
            // full row and the grid would end on an odd, oversized card.
            for (var j = 0; j < columns; j++) ...[
              if (j > 0) const SizedBox(width: gap),
              Expanded(
                child: j < chunk.length
                    ? _MarketCard(
                        row: chunk[j],
                        onTap: () => onTapRow(chunk[j]),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
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
