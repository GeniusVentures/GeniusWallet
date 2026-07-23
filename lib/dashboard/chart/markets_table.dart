import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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
const double _minTableWidth =
    _wRank + _wCoinMin + _wPrice + _wChange + _wCap + _wVol + _wSpark;

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
        if (c.maxWidth >= _minTableWidth) return table;
        // Narrow: keep columns legible and let the table scroll sideways.
        return SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: SizedBox(width: _minTableWidth, child: table),
        );
      },
    );
  }

  // ---- header ----
  Widget _header(GWColors gw) {
    Widget cell(String label, MarketSort? sort, double? width,
        {bool alignEnd = true}) {
      final active = sort != null && sort == _sort;
      final style = GeniusWalletTypography.labelMd.copyWith(
        color: active ? gw.textPrimary : gw.textSecondary,
        fontSize: 11,
        height: 16 / 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.6,
      );
      final child = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(label.toUpperCase(),
                style: style, maxLines: 1, overflow: TextOverflow.ellipsis),
          ),
          if (active)
            Text(_ascending ? ' ↑' : ' ↓', style: style),
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
      return width == null ? Expanded(child: aligned) : SizedBox(width: width, child: aligned);
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
        children: [
          cell('#', MarketSort.rank, _wRank, alignEnd: false),
          cell('Coin', MarketSort.name, null, alignEnd: false),
          cell('Price', MarketSort.price, _wPrice),
          cell('24h %', MarketSort.change, _wChange),
          cell('Market Cap', MarketSort.marketCap, _wCap),
          cell('Volume 24h', MarketSort.volume, _wVol),
          cell('Last 7d', null, _wSpark, alignEnd: false),
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
          children: [
            SizedBox(
              width: _wRank,
              child: Text(
                '${data.marketCapRank}',
                style: GeniusWalletTypography.numericBody
                    .copyWith(color: gw.textSecondary),
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
                          style: GeniusWalletTypography.titleMd
                              .copyWith(color: gw.textPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          row.coin.symbol.toUpperCase(),
                          style: GeniusWalletTypography.labelMd
                              .copyWith(color: gw.textSecondary),
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
            SizedBox(
              width: _wChange,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
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
            SizedBox(
              width: _wCap,
              child: Text(
                _compact(data.marketCap),
                textAlign: TextAlign.right,
                style: GeniusWalletTypography.numericBody
                    .copyWith(color: gw.textPrimary),
              ),
            ),
            SizedBox(
              width: _wVol,
              child: Text(
                _compact(data.totalVolume),
                textAlign: TextAlign.right,
                style: GeniusWalletTypography.numericBody
                    .copyWith(color: gw.textSecondary),
              ),
            ),
            SizedBox(
              width: _wSpark,
              height: 32,
              child: _MiniSpark(sparkline: data.sparkline, color: changeColor),
            ),
          ],
        ),
      ),
    );
  }

  String _price(double v) {
    final decimals = v >= 1 ? 2 : 6;
    return NumberFormat.currency(symbol: '\$', decimalDigits: decimals).format(v);
  }

  String _compact(double v) {
    if (v >= 1e12) return '\$${(v / 1e12).toStringAsFixed(2)}T';
    if (v >= 1e9) return '\$${(v / 1e9).toStringAsFixed(1)}B';
    if (v >= 1e6) return '\$${(v / 1e6).toStringAsFixed(1)}M';
    if (v >= 1e3) return '\$${(v / 1e3).toStringAsFixed(1)}K';
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
    if (data == null || data.isEmpty) return const SizedBox.shrink();
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
