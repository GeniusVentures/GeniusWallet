import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/chart/markets_hero_card.dart';
import 'package:genius_wallet/dashboard/chart/markets_sort.dart';
import 'package:genius_wallet/dashboard/chart/markets_table.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:go_router/go_router.dart';

/// Markets page (sketch 103 · H1 "Refined split"): a hero card for the native
/// token over a sortable "All Markets" table. Data flows through the same two
/// chained fetches as before — coins, then market data — each with its own
/// error/retry.
class MarketsScreen extends StatefulWidget {
  const MarketsScreen({super.key});

  @override
  State<MarketsScreen> createState() => _MarketsScreenState();
}

class _MarketsScreenState extends State<MarketsScreen> {
  late Future<List<CoinGeckoCoin>> _coinsFuture;
  List<String>? _cachedCoinIds;
  Future<Map<String, CoinGeckoMarketData?>>? _marketDataFuture;

  @override
  void initState() {
    super.initState();
    _coinsFuture = getMarketCoins();
  }

  void _retryCoins() {
    setState(() {
      _coinsFuture = getMarketCoins();
      _marketDataFuture = null;
      _cachedCoinIds = null;
    });
  }

  void _retryMarketData() {
    if (_cachedCoinIds == null || _cachedCoinIds!.isEmpty) {
      return;
    }
    setState(() {
      _marketDataFuture = fetchCoinsMarketData(coinIds: _cachedCoinIds!);
    });
  }

  void _openToken(CoinGeckoCoin coin, CoinGeckoMarketData data) {
    context.push(
      '/token-info',
      extra: {"isGnusWalletConnected": false, "marketData": data, "coin": coin},
    );
  }

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // topCenter: centred horizontally (symmetric margins) and top-pinned so the
    // 64px navbar→title gap holds. Shared xxl cap → the 'Markets' title lands at
    // the same X as Transactions / News, while keeping left padding on a wide
    // window (a left-flush box loses it).
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        // top space32 (64) — navbar→title gap unified with Transactions/Swap.
        //
        // Horizontal gutter is 0 HERE and 12 on each child instead. It used to
        // be 12 here, which put it OUTSIDE the data view's SingleChildScrollView
        // — and a scroll viewport clips. The hero card carries
        // `GeniusWalletElevation.card` (blurRadius 16), so its shadow was being
        // sliced flat against the viewport edge and the card read as cut off
        // rather than raised. Same class of bug as quick 260720-gzq. Moving the
        // gutter inside the viewport gives the shadow 12 of its 16 to render
        // into; the last 4 are below visibility at this alpha.
        padding: const EdgeInsets.fromLTRB(0, GeniusWalletConsts.space32, 0, 8),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: GeniusBreakpoints.xxl),
          child: Column(
            children: [
              // Carries the page gutter itself so it stays on the same axis as
              // the hero card and the table, which now carry it inside the
              // scroll viewport (see the Padding above).
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: GWPageHeader(title: "Markets"),
              ),
              // Expanded at the COLUMN level so EVERY state — the loading
              // spinner, the error/empty `_centered`, and the data scroll view
              // — gets a bounded height. Without it the non-data states return a
              // bare `Center` into a MainAxisSize.max Column slot with unbounded
              // height and collapse to zero size ("Cannot hit test a render box
              // with no size" → blank Markets page). Mirrors the News screen's
              // `Expanded(child: FutureStateWidget(...))`.
              Expanded(
                child: FutureStateWidget<List<CoinGeckoCoin>>(
                  future: _coinsFuture,
                  onRetry: _retryCoins,
                  error: _centered("Failed to load market coins", gw),
                  onData: (coins) {
                    if (coins.isEmpty) {
                      return _centered("No market data available", gw);
                    }
                    _cachedCoinIds = coins.map((coin) => coin.id).toList();
                    return FutureStateWidget<Map<String, CoinGeckoMarketData?>>(
                      future:
                          _marketDataFuture ??
                          (_marketDataFuture = fetchCoinsMarketData(
                            coinIds: _cachedCoinIds!,
                          )),
                      onRetry: _retryMarketData,
                      error: _centered("Failed to load market data", gw),
                      onData: (marketData) {
                        if (marketData.isEmpty) {
                          return _centered("No market data available", gw);
                        }
                        return _buildContent(coins, marketData);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    List<CoinGeckoCoin> coins,
    Map<String, CoinGeckoMarketData?> marketData,
  ) {
    // Original dual lookup: market data keys can be the coin id OR the symbol.
    CoinGeckoMarketData? lookup(CoinGeckoCoin c) =>
        marketData[c.id] ?? marketData[c.symbol.toLowerCase()];

    CoinGeckoCoin? featuredCoin;
    for (final c in coins) {
      if (c.id == kNativeMarketCoinId) {
        featuredCoin = c;
        break;
      }
    }
    final CoinGeckoMarketData? featuredData = featuredCoin != null
        ? lookup(featuredCoin)
        : null;

    final rows = <MarketRow>[];
    for (final c in coins) {
      if (featuredCoin != null && c.id == featuredCoin.id) {
        continue;
      }
      final d = lookup(c);
      // hide coins with no market data (as the dashboard panel does)
      if (d == null) {
        continue;
      }
      rows.add(MarketRow(c, d));
    }

    final hasHero = featuredCoin != null && featuredData != null;

    // The bounded height comes from the Expanded wrapping FutureStateWidget in
    // build(); this just fills it and scrolls.
    // scrollbars:false — the desktop ScrollBehavior draws a vertical bar on the
    // page's own scroll by default; hide it (still scrolls by trackpad/drag),
    // matching the horizontal scroll inside MarketsTable (Jakub 2026-07-24).
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        // 12 horizontal: the page gutter now lives INSIDE the viewport rather
        // than outside it, so the hero card's blurRadius-16 shadow has room to
        // render instead of being clipped flat by the scroll viewport. The
        // 'Markets' title carries the same 12, so the alignment the previous
        // comment protected is unchanged — only the clipping is.
        padding: const EdgeInsets.fromLTRB(
          12,
          GeniusWalletConsts.space6,
          12,
          GeniusWalletConsts.space20,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHero) ...[
              MarketsHeroCard(
                coin: featuredCoin,
                data: featuredData,
                onTap: () => _openToken(featuredCoin!, featuredData),
              ),
              const SizedBox(height: GeniusWalletConsts.space12),
            ],
            const GWSectionTitle(title: 'All Markets'),
            MarketsTable(
              rows: rows,
              onTapRow: (r) => _openToken(r.coin, r.data),
            ),
          ],
        ),
      ),
    );
  }

  Widget _centered(String message, GWColors gw) => Center(
    child: Text(
      message,
      style: GeniusWalletTypography.bodyMd.copyWith(color: gw.textSecondary),
    ),
  );
}
