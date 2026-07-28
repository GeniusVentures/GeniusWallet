import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:intl/intl.dart';

/// One row of the "All Markets" table: the display payload ([coin], [data])
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

// Fixed column widths (px). Below their sum the whole table scrolls
// horizontally rather than crushing columns (desktop-first app).
const double _wRank = 44;
const double _wPrice = 110;
const double _wChange = 92;
const double _wCap = 118;
const double _wVol = 118;
const double _wSpark = 120;
const double _wCoinMin = 172;
// _wChange * 3 = 1h + 24h + 7d change columns (1h/7d are placeholders for now).
// + 8 inter-column gaps (Row spacing space6) between the 9 columns.
const double _minTableWidth =
    _wRank +
    _wCoinMin +
    _wPrice +
    _wChange * 3 +
    _wCap +
    _wVol +
    _wSpark +
    GeniusWalletConsts.space6 * 8;

/// CoinGecko/CMC-style sortable markets table (sketch 103 · H1 body / B).
class MarketsTable extends StatefulWidget {
  final List<MarketRow> rows;
  final void Function(MarketRow row) onTapRow;

  const MarketsTable({super.key, required this.rows, required this.onTapRow});

  @override
  State<MarketsTable> createState() => _MarketsTableState();
}

class _MarketsTableState extends State<MarketsTable> {
  MarketSort _sort = MarketSort.rank;
  bool _ascending = true; // rank 1 first == market cap desc

  void _onHeaderTap(MarketSort sort) {
    setState(() {
      if (_sort == sort) {
        _ascending = !_ascending;
      } else {
        _sort = sort;
        // sensible default direction per column: names A→Z, everything else
        // "biggest first" (rank is inverted: rank 1 == biggest).
        _ascending = sort == MarketSort.name || sort == MarketSort.rank;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final sorted = [...widget.rows]
      ..sort((a, b) => compareMarketRows(_sort, _ascending, a.sort, b.sort));

    final table = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _header(gw),
        for (final row in sorted) _dataRow(context, gw, row),
      ],
    );

    return LayoutBuilder(
      builder: (context, c) {
        if (c.maxWidth >= _minTableWidth) {
          return table;
        }
        // Narrow: keep columns legible and let the table scroll sideways.
        // scrollbars:false — the desktop ScrollBehavior draws a horizontal bar
        // by default; hide it (the row still scrolls by trackpad/drag).
        return ScrollConfiguration(
          behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(width: _minTableWidth, child: table),
          ),
        );
      },
    );
  }

  // ---- header ----
  Widget _header(GWColors gw) {
    Widget cell(
      String label,
      MarketSort? sort,
      double? width, {
      bool alignEnd = true,
    }) {
      final active = sort != null && sort == _sort;
      // Takes GWKicker's shared TYPE but not the widget: this header is
      // interactive (sort state + direction arrow), and a label component that
      // grew those would stop being a label. Values are byte-identical to what
      // this file carried before sketch 065 — 11 / w600 / 0.6 IS the dense
      // step; only the active-state colour is overridden here.
      final style = GWKicker.style(
        gw,
        dense: true,
      ).copyWith(color: active ? gw.textPrimary : gw.textSecondary);
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              label.toUpperCase(),
              style: style,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (active)
            // gradient-tinted sort arrow (ShaderMask — a Gradient can't be a
            // text colour directly); the child must be white for the shader.
            ShaderMask(
              shaderCallback: (bounds) =>
                  GeniusWalletGradient.brandCta.createShader(bounds),
              child: Text(
                _ascending ? ' ↑' : ' ↓',
                style: style.copyWith(color: Colors.white),
              ),
            ),
        ],
      );
      final aligned = Align(
        alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
        child: sort == null
            ? child
            : InkWell(
                onTap: () => _onHeaderTap(sort),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: child,
                ),
              ),
      );
      return width == null
          ? Expanded(child: aligned)
          : SizedBox(width: width, child: aligned);
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space8,
        vertical: GeniusWalletConsts.space6,
      ),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: gw.borderSubtle)),
      ),
      child: Row(
        // even breathing room between every column; the data row uses the same
        // spacing so headers stay aligned over their values.
        spacing: GeniusWalletConsts.space6,
        children: [
          cell('#', MarketSort.rank, _wRank, alignEnd: false),
          cell('Coin', MarketSort.name, null, alignEnd: false),
          cell('Price', MarketSort.price, _wPrice),
          // ponytail: 1h/7d are placeholder columns — no sort, no real data yet
          // (see the data row + backlog todo below).
          cell('1h %', null, _wChange),
          cell('24h %', MarketSort.change, _wChange),
          cell('7d %', null, _wChange),
          cell('Market Cap', MarketSort.marketCap, _wCap),
          cell('Volume 24h', MarketSort.volume, _wVol),
          // right-aligned like every other value column (# and Coin stay left).
          cell('Last 7d', null, _wSpark),
        ],
      ),
    );
  }

  // ---- data row ----
  Widget _dataRow(BuildContext context, GWColors gw, MarketRow row) {
    final data = row.data;
    final up = data.priceChangePercentage24h >= 0;
    final changeColor = up ? gw.statusSuccess : gw.statusError;

    return InkWell(
      onTap: () => widget.onTapRow(row),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: GeniusWalletConsts.space8,
          vertical: GeniusWalletConsts.space6,
        ),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: gw.borderSubtle)),
        ),
        child: Row(
          // matches the header Row's spacing so columns line up under labels.
          spacing: GeniusWalletConsts.space6,
          children: [
            SizedBox(
              width: _wRank,
              child: Text(
                '${data.marketCapRank}',
                style: GeniusWalletTypography.numericBody.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ),
            // coin identity
            Expanded(
              child: Row(
                children: [
                  buildTokenIcon(iconPath: data.imageUrl, size: 30),
                  const SizedBox(width: GeniusWalletConsts.space6),
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
                ],
              ),
            ),
            SizedBox(
              width: _wPrice,
              child: Text(
                _price(data.currentPrice),
                textAlign: TextAlign.right,
                style: GeniusWalletTypography.numericBody.copyWith(
                  color: gw.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            // ponytail: 1h change is a PLACEHOLDER. CoinGeckoMarketData has no
            // priceChangePercentage1h and the /coins/markets fetch does not
            // request it, so this shows "-" (a marked-absent value), never a
            // fabricated number. Ceiling: no 1h data. Upgrade path: add
            // price_change_percentage=1h,24h,7d to the fetch + a nullable model
            // field (Hive .g.dart regen + migration). Tracked in
            // .planning/todos/pending/2026-07-24-markets-1h-7d-change-columns.md
            _changePlaceholder(gw),
            SizedBox(
              width: _wChange,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
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
              ),
            ),
            // ponytail: 7d change PLACEHOLDER — same absent-data note as 1h above.
            _changePlaceholder(gw),
            SizedBox(
              width: _wCap,
              child: Text(
                _compact(data.marketCap),
                textAlign: TextAlign.right,
                style: GeniusWalletTypography.numericBody.copyWith(
                  color: gw.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: _wVol,
              child: Text(
                _compact(data.totalVolume),
                textAlign: TextAlign.right,
                style: GeniusWalletTypography.numericBody.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ),
            // Right-align the sparkline like every numeric column (and like the
            // "LAST 7D" header above it): a fixed-width chart pushed to the
            // cell's right edge leaves the same left-side breathing room every
            // other value has, instead of full-bleeding up against "Volume".
            SizedBox(
              width: _wSpark,
              height: 32,
              child: Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  width: 72,
                  child: _MiniSpark(
                    sparkline: data.sparkline,
                    color: changeColor,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ponytail: renders "-" for the not-yet-wired 1h/7d change columns (see the
  // data-row comment + backlog todo). One helper so both cells stay identical
  // and the placeholder is trivially swappable for a real value later.
  Widget _changePlaceholder(GWColors gw) {
    return SizedBox(
      width: _wChange,
      child: Text(
        '-',
        textAlign: TextAlign.right,
        style: GeniusWalletTypography.numericBody.copyWith(
          color: gw.textSecondary,
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

class _MiniSpark extends StatelessWidget {
  final List<double>? sparkline;
  final Color color;
  const _MiniSpark({required this.sparkline, required this.color});

  @override
  Widget build(BuildContext context) {
    final data = sparkline;
    if (data == null || data.isEmpty) {
      return const SizedBox.shrink();
    }
    final spots = List<FlSpot>.generate(
      data.length,
      (i) => FlSpot(i.toDouble(), data[i]),
    );
    return LineChart(
      LineChartData(
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            color: color,
            barWidth: 1.6,
            dotData: const FlDotData(show: false),
          ),
        ],
        titlesData: const FlTitlesData(show: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        lineTouchData: const LineTouchData(enabled: false),
      ),
    );
  }
}
