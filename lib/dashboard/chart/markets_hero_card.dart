import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/chart_axis.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart' show chartYBounds;
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/gw_timeframe_segment.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart'
    as coin_gecko_api;
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

/// The card's 24H/7D/30D/1Y tabs, paired with the day count each one asks
/// `fetchHistoricalPrices` for. One list, not two — the labels the segment
/// renders and the days the fetch uses cannot drift apart because the test
/// reads this mapping instead of restating it.
const List<({String label, int days})> kMarketsHeroTimeframeRanges = [
  (label: '24H', days: 1),
  (label: '7D', days: 7),
  (label: '30D', days: 30),
  (label: '1Y', days: 365),
];

/// A plotted series plus the real window it spans. A record, not a class — it
/// carries no behaviour and needs no equality.
typedef _MarketsHeroSeries = ({
  List<double> values,
  DateTime start,
  DateTime end,
});

/// Picks the bottom-axis date format from the plotted window's span.
///
/// Top-level and pure for the same reason every rule in `chart_axis.dart` is:
/// an axis-format bug looks like a working chart in every screenshot. Six
/// identical day labels across a 24-hour window is the same class of lie as
/// six identical clock-time labels across a week — which is what this card's
/// old fixed-7-day assumption produced in the other direction.
DateFormat chooseAxisDateFormat(Duration window) {
  if (window <= const Duration(hours: 30)) {
    return DateFormat('h:mm a');
  }
  if (window <= const Duration(days: 95)) {
    return DateFormat('MMM d');
  }
  return DateFormat('MMM yyyy');
}

/// The hero chart's height in the WIDE (`IntrinsicHeight` row) layout.
///
/// **253, and the "falsification" that kept it at 180 was itself wrong.**
/// 078-S6 derived that growing this from 180 to 253 costs the wide card no
/// height, because the `Spacer` at [_MarketsHeroCardState.build] absorbs the
/// difference inside an `IntrinsicHeight` row driven by the taller LEFT column
/// (301 = 46 icon + 20 + 48 price + 16 + 24 pill + 24 + 1 rule + 24 + 39 stat
/// + 20 + 39 stat). `markets_hero_height_test.dart` appeared to refute that:
/// it measured 619.0 at 180 and 692.0 at 253, the full 73px of growth, and the
/// hypothesis was recorded as dead.
///
/// **That test never reached the wide layout.** Its host wraps the card in
/// `SizedBox(width: 1200)` and its comments claim the width exercises the
/// `IntrinsicHeight` branch - but it never set the test surface, which
/// defaults to 800x600, so the `SizedBox` was clamped and the card rendered
/// **stacked**. The stacked branch passes `fill: false`, which omits the
/// `Spacer` and the `IntrinsicHeight` entirely, so of course the card grew by
/// exactly the chart's delta. It was measuring the one layout where the claim
/// was never made.
///
/// Re-measured 2026-07-30 with `tester.view.physicalSize` actually set to
/// 1400x1000: the `IntrinsicHeight` row reports **301.0** - the derivation to
/// the pixel - and the card holds **367.0** at both 180 and 253, with the
/// chart's lower edge landing on the stat row at y=334 either way. The
/// original arithmetic was right; the instrument was wrong.
///
/// **The 301.0/367.0 derivation flipped columns on 2026-08-07 (quick
/// 260807-bxs) — the numbers did not move, but which column produces them
/// did, and that is the real change.** The stat block became a `Wrap`
/// (`kMarketsHeroStatTileWidth`) instead of a fixed 2x2 grid, so the LEFT
/// column's own height is no longer one constant — it is 242 when all four
/// tiles share one row, or 301 when three do and the fourth wraps to a
/// second row (the practical range at any width the wide branch actually
/// reaches; a stat block narrow enough to wrap to one tile per row would
/// need a card far narrower than the wide branch's own `medium` floor).
/// **The RIGHT column — `GWTimeframeSegment` + `space8` + this constant —
/// never changes with the stat block at all, and measures a hard 301.0 of
/// its own**, re-confirmed directly (not the "~299, two pixels of headroom"
/// approximation the original plan estimated). Because the right column's
/// fixed 301.0 is always `>=` the left column's 242-to-301 range, the right
/// column now drives `IntrinsicHeight` unconditionally, at every width the
/// wide branch renders — the left column can no longer be the one to watch.
/// The literals happen to read the same (367.0/367.0, 301.0/301.0 before
/// and after) purely because the right column's true fixed value equals the
/// old left-driven one to the pixel; `markets_hero_height_test.dart`'s
/// reason string records the derivation, not just the number, for exactly
/// this reason — a future stat-block or chart change could easily move one
/// side without moving the other, and the test should say which side it is
/// watching.
const double kMarketsHeroChartHeight = 253;

/// The height used when the card STACKS (below `GeniusBreakpoints.medium`).
///
/// DERIVED from `kChartFrameMinHeight`, not a restated literal: the stacked
/// hero now sits exactly at the threshold, because axis labels at phone width
/// were asked for (BXS-02) and `chartUsesFrame` only grants the frame to a box
/// that clears it. The ~40px this costs over the old 180 is repaid by the
/// smaller type step on the same branch (see the price/`Text` below) — Task 1
/// measures the real before/after and reports it in the plan's SUMMARY rather
/// than assuming the repayment is exact. `chartUsesFrame` still measures the
/// box it is actually handed (`c.maxHeight` in `_HeroChart`), so nothing here
/// is a per-surface flag — the stacked layout earns the frame by growing its
/// box, the same runtime rule the wide layout and the coin page both follow.
///
/// The stacked layout still has neither `Spacer` nor `IntrinsicHeight` (it
/// stacks in an unbounded `Column`, where a `Spacer` would throw), so every
/// pixel added here is still a pixel the card grows on the narrowest screens —
/// which is why this cannot be raised casually.
const double kMarketsHeroChartHeightStacked = kChartFrameMinHeight;

/// Fixed width for each tile in the stat block's `Wrap` (2026-08-07, quick
/// 260807-bxs) — Braian's ask was "a flex so we can show more data in a row
/// instead of always a 2 column structure", which needs a per-tile width:
/// an un-widthed tile sizes to its own shortest content ('Rank' / '#1') and
/// the four tiles would never line up as columns the way a stat grid reads.
///
/// **152, measured, not guessed.** `GWStatTile`'s label is a bare `GWKicker`
/// with no `maxLines`/`overflow` of its own (unlike, say, the Markets
/// table's header cells, which wrap the same dense-kicker TEXT STYLE in an
/// explicit ellipsis) — so a tile narrower than its label wraps to two
/// lines instead of truncating. 'All-Time High', the widest of the four
/// fixed labels, wraps at 150px and clears at 151px in this exact test
/// harness; 152 is that measured threshold plus 1px of margin, not a round
/// number picked by eye. Going narrower would wrap that one label on every
/// wide render; going wider buys nothing (every label already fits) while
/// costing tiles-per-row.
///
/// This IS the ceiling on a single tile's width, too — a `SizedBox`, not a
/// flexible `Expanded`, so a tile never grows to fill leftover space on an
/// extra-wide card, which is the "absurd width" Braian named.
///
/// **The consequence, stated plainly:** the wide card's ~543px left column
/// fits three unwrapped tiles per row (3 * 152 + 2 * `space10` = 496), not
/// four (4 * 152 + 3 * `space10` = 656) — the fourth wraps to its own
/// second row. All four only share one row above roughly 1700px of total
/// card width. This is still the improvement asked for: "more data in a
/// row instead of always a 2 column structure" is true at every width from
/// 402px (2 per row, unchanged from before) up through 1400px (3 per row)
/// to a genuinely wide card (4 per row) — it was never a promise that
/// every desktop width shows all four abreast, and the alternative (a
/// narrower tile that wraps 'All-Time High') is worse.
const double kMarketsHeroStatTileWidth = 152;

/// Markets hero (sketch 103 · H1 "Refined split"): identity + oversized price
/// + a flowed stat block on the left (as many tiles per row as fit, not a
/// fixed 2x2 grid — see [kMarketsHeroStatTileWidth]), the chart with a
/// timeframe selector on the right. Data for whichever range is selected
/// comes from [MarketsHeroCard.fetchHistoricalPrices]; the 7D default reads
/// the already-fetched [CoinGeckoMarketData] and triggers no request.
class MarketsHeroCard extends StatefulWidget {
  final CoinGeckoCoin coin;
  final CoinGeckoMarketData data;
  final VoidCallback? onTap;

  /// The historical-price fetch, typed to match
  /// `coin_gecko_api.fetchHistoricalPrices` exactly and defaulting to it as a
  /// tear-off.
  ///
  /// `@visibleForTesting`, not premature configurability: the real function
  /// opens a Hive box, and real Hive I/O inside `testWidgets` hangs forever in
  /// this repo (`.planning/todos/completed/2026-07-29-real-hive-io-inside-
  /// testwidgets-hangs-forever.md`). Without this seam the 24H/30D/1Y wiring
  /// would have no runnable check at all.
  @visibleForTesting
  final Future<Map<int, double>> Function(String coinId, {int days})
  fetchHistoricalPrices;

  const MarketsHeroCard({
    super.key,
    required this.coin,
    required this.data,
    this.onTap,
    this.fetchHistoricalPrices = coin_gecko_api.fetchHistoricalPrices,
  });

  @override
  State<MarketsHeroCard> createState() => _MarketsHeroCardState();
}

class _MarketsHeroCardState extends State<MarketsHeroCard> {
  // Defaults to the 7D entry — the range widget.data.sparkline actually
  // covers.
  int _selectedIndex = 1;

  // Null means the FREE path: 7D plots widget.data.sparkline, which
  // fetchCoinsMarketData already retrieved, with a synthesised last-7-days
  // window. Any other tab sets this to a real fetch.
  Future<_MarketsHeroSeries>? _seriesFuture;

  void _onTimeframeTap(int index) {
    setState(() {
      _selectedIndex = index;
      final range = kMarketsHeroTimeframeRanges[index];
      _seriesFuture = range.label == '7D' ? null : _startFetch(range.days);
    });
  }

  // `setState` does not rebuild synchronously, so `FutureStateWidget`'s
  // `FutureBuilder` only attaches its error listener on the NEXT frame — a
  // real gap a fast-rejecting future (an immediate empty-map response) can
  // cross before anything is listening, which Dart reports as a zone-level
  // "Unhandled exception" even though `FutureStateWidget` handles it a
  // moment later. `..ignore()` registers a synchronous, silent listener at
  // creation time so that report never fires; it does not touch how the
  // SAME future delivers its real value or error to `FutureStateWidget`
  // (Futures support multiple independent listeners).
  Future<_MarketsHeroSeries> _startFetch(int days) =>
      _fetchSeries(days)..ignore();

  Future<_MarketsHeroSeries> _fetchSeries(int days) async {
    final raw = await widget.fetchHistoricalPrices(widget.coin.id, days: days);
    // `fetchHistoricalPrices` never throws (see <measured_facts>) — every
    // failure path returns either a stale cache entry or an empty map, so an
    // empty map is the ONLY failure signal that reaches here. Rendering it as
    // an empty chart would be exactly the silent blank BXS-03 forbids, so
    // this throws instead, which is what routes FutureStateWidget below to
    // its retry-affordance error branch.
    if (raw.isEmpty) {
      throw StateError(
        'No historical prices returned for ${widget.coin.id} ($days d)',
      );
    }
    // Sort ascending before projecting to values. CoinGecko returns the keys
    // in order today and the map preserves insertion order, but the series
    // the chart plots should not rest on two undocumented behaviours
    // agreeing (T-bxs-03).
    final keys = raw.keys.toList()..sort();
    return (
      values: [for (final k in keys) raw[k]!],
      start: DateTime.fromMillisecondsSinceEpoch(keys.first * 1000),
      end: DateTime.fromMillisecondsSinceEpoch(keys.last * 1000),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final data = widget.data;
    final up = data.priceChangePercentage24h >= 0;
    final changeColor = up ? gw.statusSuccess : gw.statusError;

    // A local function, not a lifted `StatelessWidget`: it closes over `gw`,
    // `data`, `changeColor` and `up`, and hoisting it would mean threading
    // four constructor arguments to serve one call site. AGENTS.md's
    // widgets-not-helper-methods rule targets extracted `_buildFoo()` methods
    // on a State class that rebuild the whole enclosing widget; `buildLeft`
    // matches `buildRight`'s already-established shape below for exactly this
    // situation, and matching it is the smaller, more consistent diff — do
    // not "fix" this into a StatelessWidget.
    Widget buildLeft({required bool wide}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // identity
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTokenIcon(iconPath: data.imageUrl, size: 46),
            const SizedBox(width: GeniusWalletConsts.space6),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.coin.name,
                  // titleLg (18) wide, titleMd (16) narrow — a breakpoint
                  // choice between two tokens, not a measured search.
                  style:
                      (wide
                              ? GeniusWalletTypography.titleLg
                              : GeniusWalletTypography.titleMd)
                          .copyWith(color: gw.textPrimary, letterSpacing: -0.2),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space10),
        // Price is a FIXED style on both branches (never AutoSizeText): a
        // width-driven font search re-keys skia's ParagraphCache every resize
        // frame and freezes the macOS embedder (see crypto_simple_chart.dart's
        // note). This branch is a breakpoint choice between two fixed styles,
        // which does not reintroduce that per-frame search.
        //
        // The WIDE branch keeps 48 verbatim, with no token behind it.
        // BXS-01 only asked for the narrow price to stop running the full
        // card width, so only the narrow branch changes — but the reason
        // this one is still pinned as-is moved on 2026-08-07: the right
        // column (timeframe segment + fixed-height chart) is a hard 301.0,
        // independent of anything on the left, and now drives the pinned
        // `IntrinsicHeight` row unconditionally (the left column's own
        // height varies with the stat block's `Wrap` — 242 to 301 depending
        // on tiles-per-row — but can no longer exceed the right's fixed
        // value). Shrinking this price would not buy the row anything
        // anymore; it is not the ceiling. See `kMarketsHeroChartHeight`'s
        // doc comment and `markets_hero_height_test.dart` for the measured
        // derivation.
        wide
            ? Text(
                _price(data.currentPrice),
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 48,
                  height: 1,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -2,
                  color: gw.textPrimary,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                _price(data.currentPrice),
                style: GeniusWalletTypography.numericDisplay.copyWith(
                  color: gw.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
        const SizedBox(height: GeniusWalletConsts.space8),
        // % pill + absolute 24h change
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ChangePill(
              percent: data.priceChangePercentage24h,
              color: changeColor,
            ),
            const SizedBox(width: GeniusWalletConsts.space6),
            Flexible(
              child: Text(
                '${_absChange(data)} · 24h',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space12),
        Container(height: 1, color: gw.borderSubtle),
        const SizedBox(height: GeniusWalletConsts.space12),
        // Stat block: Rank, Market Cap, Volume 24h, All-Time High — as many
        // as fit per row instead of a fixed 2x2 grid (2026-08-07, quick
        // 260807-bxs). `Wrap`, never a `LayoutBuilder`-driven column count:
        // on the wide branch `left` is a child of an `IntrinsicHeight` `Row`
        // below, and `LayoutBuilder` throws when asked for an intrinsic
        // dimension ("does not support returning intrinsic dimensions") —
        // `Wrap` implements intrinsics natively, so it is the one flow
        // primitive that survives being measured that way. Order is
        // unchanged from the old 2x2 reading order (Rank, Market Cap /
        // Volume 24h, All-Time High), so at the narrow width where exactly
        // two tiles still fit per row this renders identically to before.
        Wrap(
          spacing: GeniusWalletConsts.space10,
          runSpacing: GeniusWalletConsts.space10,
          children: [
            SizedBox(
              width: kMarketsHeroStatTileWidth,
              child: GWStatTile(label: 'Rank', value: '#${data.marketCapRank}'),
            ),
            SizedBox(
              width: kMarketsHeroStatTileWidth,
              child: GWStatTile(
                label: 'Market Cap',
                value: _compact(data.marketCap),
              ),
            ),
            SizedBox(
              width: kMarketsHeroStatTileWidth,
              child: GWStatTile(
                label: 'Volume 24h',
                value: _compact(data.totalVolume),
              ),
            ),
            SizedBox(
              width: kMarketsHeroStatTileWidth,
              child: GWStatTile(
                label: 'All-Time High',
                value: _price(data.ath),
              ),
            ),
          ],
        ),
      ],
    );

    // Wide layout drops the chart to the BOTTOM of the row so its lower edge
    // lines up with the LAST thing in the left column (Jakub 2026-07-24;
    // re-stated 2026-08-07 when the stat block became a `Wrap` and its
    // second row stopped existing as a fixed reference point). The mechanism
    // does not care what that last thing IS — a plain `Spacer()` above the
    // fixed-height chart absorbs whatever height difference the
    // IntrinsicHeight row inherits from the taller `left` column, so the
    // chart's bottom edge always tracks the left column's bottom edge,
    // whether that is a second stat row (before) or the stat block's single
    // flowed row (now). The Spacer is the ONLY flex child and it is an empty
    // box — intrinsic height 0 — so fl_chart is never intrinsic-measured
    // (that is what froze the embedder when the chart itself was the
    // Expanded child). Narrow layout stacks in an unbounded Column where a
    // Spacer would throw, so it is omitted there.
    Widget buildRight({required bool fill}) {
      final Widget chart;
      final future = _seriesFuture;
      if (future == null) {
        // FREE path (7D): the already-fetched sparkline, windowed as the
        // last 7 days — the same window CoinGecko's sparkline_in_7d covers.
        final now = DateTime.now();
        chart = _HeroChart(
          values: data.sparkline ?? const [],
          start: now.subtract(const Duration(days: 7)),
          end: now,
        );
      } else {
        // `FutureStateWidget` is the right tool, not just a convenience: it
        // is already this screen's loading/error idiom two levels up
        // (`markets_screen.dart`), it supplies the spinner, the retry button
        // and a snackbar for free, and because `FutureBuilder` drops results
        // from a future it is no longer watching, rapid tab taps cannot
        // paint a stale series — no request token needed.
        chart = FutureStateWidget<_MarketsHeroSeries>(
          future: future,
          onRetry: () => setState(() {
            _seriesFuture = _startFetch(
              kMarketsHeroTimeframeRanges[_selectedIndex].days,
            );
          }),
          error: Center(
            child: Text(
              "Couldn't load ${kMarketsHeroTimeframeRanges[_selectedIndex].label} prices",
              style: GeniusWalletTypography.bodySm.copyWith(
                color: gw.textSecondary,
              ),
            ),
          ),
          onData: (series) => _HeroChart(
            values: series.values,
            start: series.start,
            end: series.end,
          ),
        );
      }

      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: GWTimeframeSegment(
              labels: [for (final r in kMarketsHeroTimeframeRanges) r.label],
              initialIndex: _selectedIndex,
              onChanged: _onTimeframeTap,
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space8),
          if (fill) const Spacer(),
          SizedBox(
            height: fill
                ? kMarketsHeroChartHeight
                : kMarketsHeroChartHeightStacked,
            child: chart,
          ),
        ],
      );
    }

    final content = LayoutBuilder(
      builder: (context, c) {
        // `wide` is the AND of the box and the window, not the box alone: the
        // window (`useDesktopLayout`) is the authority on device class — a
        // mobile app at a wide `MediaQuery` width is still mobile, and a
        // desktop window between 769-791px (content 745-767px) still stacks
        // the card even though the window itself reads "desktop". Reading
        // only `c.maxWidth` (the literal instruction) would let this card's
        // layout branch and its type step disagree in exactly those two real
        // cases; one bool feeding BOTH `buildLeft`'s type step and the layout
        // branch below makes that impossible by construction.
        final wide =
            c.maxWidth >= GeniusBreakpoints.medium &&
            GeniusBreakpoints.useDesktopLayout(context);
        if (!wide) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              buildLeft(wide: false),
              const SizedBox(height: GeniusWalletConsts.space12),
              buildRight(fill: false),
            ],
          );
        }
        // IntrinsicHeight is load-bearing: this Row lives inside the page's
        // vertical SingleChildScrollView, so its incoming height is unbounded.
        // `CrossAxisAlignment.stretch` then has nothing to stretch to and the
        // Expanded children collapse to zero size — fl_chart renders into a
        // 0-height box and throws "Cannot hit test a render box with no size",
        // blanking the whole Markets page. IntrinsicHeight gives the Row a
        // concrete height (the taller of left/right) so stretch resolves. This
        // is exactly what the News hero does (crypto_news_screen.dart).
        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(flex: 5, child: buildLeft(wide: true)),
              const SizedBox(width: GeniusWalletConsts.space16),
              Expanded(flex: 7, child: buildRight(fill: true)),
            ],
          ),
        );
      },
    );

    // RepaintBoundary: this card holds an fl_chart (expensive to repaint) and a
    // 1px hairline border at ~12% alpha. Without isolation, scrolling the page
    // re-rasterises the whole card every frame, and at fractional sub-pixel
    // scroll offsets the hairline edge (esp. the right/vertical border, next to
    // the chart) drops below visibility on some frames — the flicker Jakub saw.
    // Boundary → the card rasters once and just translates as a cached layer.
    return RepaintBoundary(
      child: Semantics(
        button: widget.onTap != null,
        label: '${widget.coin.name} market detail',
        child: InkWell(
          borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
          onTap: widget.onTap,
          child: Container(
            decoration: GWDecorations.surface(
              radius: GeniusWalletConsts.radiusLg,
            ),
            padding: const EdgeInsets.all(GeniusWalletConsts.space16),
            child: content,
          ),
        ),
      ),
    );
  }

  String _price(double v) {
    final decimals = v >= 1 ? 2 : 6;
    return NumberFormat.currency(
      symbol: '\$',
      decimalDigits: decimals,
    ).format(v);
  }

  String _absChange(CoinGeckoMarketData d) {
    final v = d.priceChange24h;
    final decimals = d.currentPrice >= 1 ? 2 : 4;
    return '${v >= 0 ? '+' : '−'}\$${v.abs().toStringAsFixed(decimals)}';
  }

  String _compact(double v) {
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

class _ChangePill extends StatelessWidget {
  final double percent;
  final Color color;
  const _ChangePill({required this.percent, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        '${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(2)}%',
        style: GeniusWalletTypography.labelMd.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

/// The hero chart, on the SAME runtime A/B rule as the coin page: scheme B's
/// trading frame when the box it is handed clears [kChartFrameMinHeight],
/// today's axis-free chart below it.
///
/// Until 2026-07-30 this surface only ever got 078's colour rules - trend
/// colour and the `borderControl` contrast fix - because it sat at 180px and
/// the frame needs 220. It is 253 in the wide layout now (see
/// [kMarketsHeroChartHeight] for why that is free), so the frame applies where
/// there is room and does not where there is not.
///
/// **One widget with a `framed` bool rather than the two `StatelessWidget`s
/// `crypto_live_chart.dart` splits into.** That file's split earns itself: its
/// two schemes differ in their Y-window handling (`chartBandedBounds`) and in
/// carrying `_HighLowPlate`s, so they are genuinely two charts. Here the line,
/// the fill, the touch behaviour and the tooltip are byte-identical between
/// branches and only the frame parts differ, so two widgets would be one widget
/// copied twice.
///
/// Takes the plotted [values] plus the real [start]/[end] the window spans
/// (quick 260807-bxs) — the caller passes either a fetched series or, on the
/// free 7D path, the bundled sparkline windowed as the last 7 days. Neither
/// branch hardcodes a 7-day assumption anymore.
class _HeroChart extends StatelessWidget {
  final List<double> values;
  final DateTime start;
  final DateTime end;
  const _HeroChart({
    required this.values,
    required this.start,
    required this.end,
  });

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final data = values;
    if (data.isEmpty) {
      return Center(
        child: Text(
          'Chart unavailable',
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textSecondary,
          ),
        ),
      );
    }
    final spots = List<FlSpot>.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );
    // One trend-colour rule now covers every chart surface (078-S2). Before
    // this, the hero ran a THIRD rule of its own — a fixed
    // gradientGreen -> gradientBlue regardless of direction — while
    // `CryptoLiveChart` was always mint and the two sparklines (
    // `crypto_simple_chart.dart:53-55`) colour by sign. Uses the LOCAL `up`
    // (first vs last point of the plotted series), not
    // `data.priceChangePercentage24h`: the series on screen can be any of the
    // four ranges, so a 24h-signed colour on a 30D/1Y line would be the same
    // class of lie this whole task is removing.
    final bool up = data.last >= data.first;
    final Color trend = up ? gw.statusSuccess : gw.statusError;

    // Hover tooltip (same effect as the dashboard's CryptoLiveChart): a
    // touched point shows its time, price, and % change vs the window start.
    // Interpolated linearly across the real [start, end] window rather than a
    // fixed 7-day span — points are assumed evenly spaced across it, which
    // holds for CoinGecko's `market_chart` buckets and for `sparkline_in_7d`.
    //
    // ponytail: points are assumed evenly spaced across the window. Ceiling:
    // a real gap in the series (a stale cache entry mid-fetch) would draw
    // evenly regardless. Upgrade path: carry a timestamp per point instead of
    // interpolating from the endpoints.
    final double first = data.first;
    final int n = data.length;
    final Duration window = end.difference(start);
    DateTime timeAt(double x) =>
        n > 1 ? start.add(window * (x / (n - 1))) : start;

    return LayoutBuilder(
      builder: (context, c) {
        // Measured off the box actually handed to the plot, never off a
        // per-surface flag — 078-S4's whole point. `c.maxHeight` is the
        // `SizedBox` in `buildRight`, so the stacked layout's 180 lands below
        // the threshold and the wide layout's 253 above it.
        final bool framed = chartUsesFrame(c.maxHeight);
        final (yLo, yHi) = chartYBounds(spots);

        // Grid lines and right-axis labels BOTH iterate from the axis baseline
        // by `interval`, so handing them the SAME step is what makes every
        // label land on a gridline by construction.
        final (_, step) = chartTickStep(
          yLo,
          yHi,
          chartYTickCount(c.maxHeight - kChartTimeRowHeight),
        );

        final chart = LineChart(
          LineChartData(
            minY: framed ? yLo : null,
            maxY: framed ? yHi : null,
            gridData: FlGridData(
              show: framed,
              drawVerticalLine: false,
              horizontalInterval: step,
              getDrawingHorizontalLine: (_) => FlLine(
                color: gw.borderSubtle.withValues(alpha: 0.06),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              show: framed,
              leftTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: const AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: framed,
                  reservedSize: kChartAxisGutter,
                  interval: step,
                  // MUST stay false, or fl_chart also prints the raw padded
                  // min/max, which are not on the nice-number ladder.
                  minIncluded: false,
                  maxIncluded: false,
                  getTitlesWidget: (value, meta) => SideTitleWidget(
                    meta: meta,
                    space: 8,
                    child: Text(
                      axisMoneyLabel(value, step),
                      style: TextStyle(
                        fontSize: 11,
                        color: gw.textSecondary,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            lineBarsData: [
              LineChartBarData(
                spots: spots,
                isCurved: true,
                color: trend,
                barWidth: 2.5,
                dotData: const FlDotData(show: false),
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      trend.withValues(alpha: 0.18),
                      trend.withValues(alpha: 0.0),
                    ],
                    // Same non-zero-baseline honesty as the main chart
                    // (`crypto_live_chart.dart`): the scale never claims a zero
                    // floor, so an edge-to-edge fill would run to one it does not
                    // have. Unchanged by the frame - `kChartFillFadeStop` is
                    // derived from `belowBarLargestRect`, which is the highest
                    // spot to the plot floor either way.
                    stops: const [0.0, kChartFillFadeStop],
                  ),
                ),
              ),
            ],
            borderData: FlBorderData(show: false),
            lineTouchData: LineTouchData(
              enabled: true,
              handleBuiltInTouches: true,
              getTouchedSpotIndicator: (barData, spotIndexes) {
                return spotIndexes.map((index) {
                  return TouchedSpotIndicatorData(
                    // borderControl (3.30:1 dark / 3.10:1 light) clears WCAG
                    // 1.4.11's 3:1 gate; borderStrong (2.10:1) did not — same
                    // token, same reason as the main chart's crosshair.
                    FlLine(color: gw.borderControl, strokeWidth: 1),
                    FlDotData(
                      getDotPainter: (spot, percent, bar, i) =>
                          FlDotCirclePainter(
                            radius: 4,
                            color: trend,
                            strokeWidth: 3,
                            strokeColor: trend.withValues(alpha: 0.26),
                          ),
                    ),
                  );
                }).toList();
              },
              touchTooltipData: LineTouchTooltipData(
                fitInsideHorizontally: true,
                fitInsideVertically: true,
                tooltipBorderRadius: BorderRadius.circular(10),
                tooltipBorder: BorderSide(color: gw.borderSubtle),
                getTooltipColor: (touchedSpot) => gw.surfaceElevated,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    final double pct = first > 0
                        ? ((spot.y - first) / first) * 100
                        : 0;
                    final Color pctColor = pct >= 0
                        ? gw.statusSuccess
                        : gw.statusError;
                    final int decimals = spot.y >= 1 ? 2 : 6;
                    return LineTooltipItem(
                      '${DateFormat('MMM d, h:mm a').format(timeAt(spot.x))}\n',
                      GeniusWalletTypography.labelMd.copyWith(
                        color: gw.textSecondary,
                        fontWeight: FontWeight.w500,
                      ),
                      children: [
                        TextSpan(
                          text: NumberFormat.currency(
                            symbol: '\$',
                            decimalDigits: decimals,
                          ).format(spot.y),
                          style: GeniusWalletTypography.numericBody.copyWith(
                            color: gw.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        TextSpan(
                          text:
                              '  ${pct >= 0 ? '+' : ''}${pct.toStringAsFixed(2)}%',
                          style: GeniusWalletTypography.labelMd.copyWith(
                            color: pctColor,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    );
                  }).toList();
                },
              ),
            ),
          ),
        );

        if (!framed) {
          return chart;
        }

        // A plain Row of Texts, NOT fl_chart's bottom titles — fl_chart anchors
        // its x intervals to `baselineX`, which cannot be lined up with the
        // sparkline's index positions without fighting the library. Same
        // reasoning, same constants as `crypto_live_chart.dart`'s frame.
        //
        // The format is chosen from the real window, not fixed to dates:
        // clock time for a ~1-day window (24H), day-and-month for weeks/
        // months (7D/30D), month-and-year beyond ~a quarter (1Y). Six
        // identical day labels across a 24H window would be the same class
        // of lie six identical clock times across a week used to be.
        final DateFormat labelFormat = chooseAxisDateFormat(window);
        return Column(
          children: [
            Expanded(child: chart),
            SizedBox(
              height: kChartTimeRowHeight,
              child: Padding(
                padding: const EdgeInsets.only(right: kChartAxisGutter),
                child: LayoutBuilder(
                  builder: (context, rowConstraints) {
                    final int count = chartXLabelCount(
                      plotWidth: rowConstraints.maxWidth,
                      sampleCount: spots.length,
                    );
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(count, (b) {
                        final int ix = count > 1
                            ? ((b / (count - 1)) * (spots.length - 1)).round()
                            : 0;
                        return Text(
                          labelFormat.format(timeAt(spots[ix].x)),
                          style: TextStyle(
                            fontSize: 11,
                            color: gw.textSecondary,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        );
                      }),
                    );
                  },
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
