import 'package:flutter/material.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/cards/gw_row_rhythm.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:go_router/go_router.dart';

class DashboardMarkets extends StatefulWidget {
  final List<CoinGeckoCoin> coins;
  final String? title;

  const DashboardMarkets({super.key, required this.coins, this.title});

  @override
  State<DashboardMarkets> createState() => _DashboardMarketsState();
}

class _DashboardMarketsState extends State<DashboardMarkets> {
  late Future<Map<String, CoinGeckoMarketData?>> _future;

  @override
  void initState() {
    super.initState();
    _future = fetchCoinsMarketData(
      coinIds: widget.coins.map((coin) => coin.id).toList(),
    );
  }

  void _retry() {
    setState(() {
      _future = fetchCoinsMarketData(
        coinIds: widget.coins.map((coin) => coin.id).toList(),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    // The GWColors read that used to sit here has moved down into
    // `_MarketRows`, which is now the only consumer (the row separators). It is
    // still a fail-soft read registering the InheritedWidget dependency, just
    // one level lower - see that widget's own build.
    return FutureStateWidget<Map<String, CoinGeckoMarketData?>>(
      future: _future,
      error: const Text("Failed to load market data"),
      onRetry: _retry,
      onData: (marketData) {
        if (marketData.isEmpty) {
          return const Center(child: Text("No market data available"));
        }

        // The availability test that used to run inline here, moved WHOLE into
        // `dashboardMarketRows` so the filter rule and the cap live together
        // and cannot be applied in the wrong order.
        final pricedSymbols = <String>{
          for (final coin in widget.coins)
            if (marketData[coin.symbol.toLowerCase()] != null)
              coin.symbol.toLowerCase(),
        };
        final visibleCoins = dashboardMarketRows(widget.coins, pricedSymbols);

        // Real "Markets" panel header above the rows (003-A) via the shared
        // GWSectionTitle, not a title crammed into the first list item.
        return LayoutBuilder(
          builder: (context, constraints) {
            // BOUNDEDNESS decides the whole shape (phase 25). Bounded - every
            // desktop host - means fill the slot and scroll inside it, which is
            // what shipped. Unbounded - the one-column mobile dashboard, whose
            // ListView now caps nothing - means HUG, because `Expanded` under an
            // unbounded main-axis constraint is a `RenderFlex` assertion rather
            // than a layout ("children have non-zero flex but incoming height
            // constraints are unbounded"). `Flexible` asserts identically, so
            // loosening the fit does not save it; the hug branch has to carry no
            // flex child at all.
            //
            // A BOOL, read once per layout from a bounded two-value set - which
            // is what the freeze rule (37639d5) permits. It is not a dimension
            // derived continuously from constraints, so it cannot take a new
            // value every frame and cannot thrash the paragraph cache.
            //
            // `LayoutBuilder` throws if an ancestor queries intrinsic dimensions
            // of its subtree; checked, and no host does. The one-column host is
            // a `ListView` and both desktop hosts are flex rows, none of which
            // runs an intrinsic pass. Same hazard `wallet_overview.dart` records
            // for its own LayoutBuilder.
            final bool hug = !constraints.maxHeight.isFinite;

            // ONE rows widget feeding both branches, so they cannot drift into
            // rendering different lists.
            final rows = _MarketRows(
              coins: visibleCoins,
              marketData: marketData,
            );

            return Column(
              mainAxisSize: hug ? MainAxisSize.min : MainAxisSize.max,
              children: [
                GWSectionTitle(
                  title: widget.title ?? 'Markets',
                  trailing: GWViewAllLink(onTap: () => context.go('/markets')),
                  // DECLARED, not measured through a probe - 260807-wbu.
                  // `CryptoSparkLineChart` used to be a bare `ListTile` with
                  // no `contentPadding`, so its first painted pixel sat
                  // 16.75px below its own layout box purely as Material's
                  // default two-line tile centring - a fact nobody chose,
                  // rediscovered by measurement
                  // (`gw_section_title_rhythm_test.dart`). The row now
                  // declares its own top inset via `kGWRowPadding`
                  // (`lib/components/cards/gw_row_rhythm.dart`), so this
                  // panel states that same number, `kGWRowSeparatorGap` (12),
                  // instead of a measured fact about a Material snap.
                  //
                  // The panel FULLY ABSORBS it now: the derived bottom pad
                  // moves from 0 to `space2` (4), and the rendered R2 moves
                  // from 26.75 to exactly 26 - this panel joins the app's
                  // shared 26 rather than overshooting it by three quarters
                  // of a pixel. `gw_section_title_rhythm_test.dart`'s
                  // `CONTRACT` loop already runs the C = 12 iteration, so no
                  // new case was needed for this to be covered.
                  //
                  // UNCHANGED by phase 25's `ListView.separated` -> plain column
                  // swap below, because the first row is still the same
                  // `CryptoSparkLineChart` and that inset describes the ROW, not
                  // its host. The one thing the swap could have moved is the
                  // list's own leading pad, and a `ListView` with a null
                  // `padding` inherits the ambient `MediaQuery` vertical padding
                  // - which `DashboardScreen`'s `SafeArea` has already consumed
                  // by the time it reaches here, so there was none to lose.
                  // Neither this panel nor its rows is test-mountable (the widget
                  // fetches in `initState`), so that is confirmed on device.
                  contentTopInset: kGWRowSeparatorGap,
                ),
                if (hug)
                  rows
                else
                  Expanded(child: SingleChildScrollView(child: rows)),
              ],
            );
          },
        );
      },
    );
  }
}

/// The Markets panel's rows, built eagerly.
///
/// A widget rather than a `_buildRows()` method returning a `Widget`
/// (`AGENTS.md`), and a plain `Column` rather than the `ListView.separated`
/// this replaced: the list is capped at [kDashboardMarketsCap], so there is no
/// laziness left worth a second layout pass, and a lazy list cannot be handed
/// the unbounded height the mobile dashboard now gives this panel.
class _MarketRows extends StatelessWidget {
  const _MarketRows({required this.coins, required this.marketData});

  final List<CoinGeckoCoin> coins;
  final Map<String, CoinGeckoMarketData?> marketData;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    // Flattened HERE, in build, the same way `transactions_slim_view._body`
    // interleaves its day/row/divider entries - it keeps the per-row locals
    // (`coin`, `data`) in scope without a `Builder` layer per row.
    final entries = <Widget>[];
    for (var i = 0; i < coins.length; i++) {
      if (i > 0) {
        // `Divider`, not a bare `Container` - 260807-wbu. Same pixel as every
        // other row rule in the app (`transactions_slim_view.dart`,
        // `markets_table.dart`), but this site drew it as a plain
        // `Container(height: 1, color: gw.borderSubtle)` instead - a known,
        // unresolved inconsistency sketch 019's README recorded. Aligned here
        // while this file was already open for the row-rhythm change.
        entries.add(Divider(height: 1, thickness: 1, color: gw.borderSubtle));
      }
      final coin = coins[i];
      // Non-null by construction: `dashboardMarketRows` only ever returns coins
      // whose symbol IS in the priced set it was handed.
      final data = marketData[coin.symbol.toLowerCase()]!;
      entries.add(
        CryptoSparkLineChart(
          onTap: () {
            // Same payload shape as `markets_screen.dart`'s `_openToken` - this
            // panel had no `coin` key at all before, so it gains an identity it
            // never carried.
            context.push(
              '/token-info',
              extra: TokenInfoArgs(
                coinGeckoId: coin.id,
                symbol: coin.symbol,
                marketData: data,
              ),
            );
          },
          title: coin.name,
          symbol: coin.symbol,
          iconPath: data.imageUrl,
          currentPrice: data.currentPrice,
          high24h: data.high24h,
          low24h: data.low24h,
          priceChangePercent: data.priceChangePercentage24h,
          sparkline: data.sparkline,
        ),
      );
    }

    return Column(
      // stretch, because a `Column` centres by default where a `ListView`
      // stretched: without it every row would shrink to its own intrinsic width
      // and the hairlines would stop running full-bleed.
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: entries,
    );
  }
}
