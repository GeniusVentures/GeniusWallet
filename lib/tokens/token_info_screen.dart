import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_detail_grid.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/cards/gw_stat_tile.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/gw_back_link.dart';
import 'package:genius_wallet/components/inputs/gw_keyboard_done_bar.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_gradient.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/utils/image_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// Bridge: push /bridge with the cubit payload, then refresh the coins so a
/// completed bridge shows up on the balance you came back to.
///
/// **074-C2 dropped a `Navigator.of(context).pop()` that used to open this
/// function.** It was there to close the "More Options" drawer this row lived
/// in; Bridge is now a direct icon on the section line, so with no drawer above
/// it that pop would have popped the PAGE and pushed /bridge onto whatever was
/// underneath.
Future<void> _pushBridgeScreen(
  BuildContext context,
  WalletDetailsCubit walletDetailsCubit,
) async {
  await GoRouter.of(context).push('/bridge', extra: walletDetailsCubit);
  walletDetailsCubit.getCoins();
}

/// Height of everything the chart shares the viewport with on desktop - back
/// chip, header, stat rail, the action line and the gaps between them. Measured
/// from the built layout rather than derived, and it only has to be close: it
/// feeds a `max()` whose floor is [_kMinChartHeight].
///
/// 074-C2 took ~38px out of it: the full-width four-tile action bar (74px plus
/// its 16px gap) became a 44px section line sharing its row with the kicker.
const double _kChromeAboveChart = 342;

/// The chart never goes below this, so a short window scrolls instead of
/// squashing the one thing the page is for.
const double _kMinChartHeight = 300;

/// How tall the chart is, given the viewport.
///
/// Pure and public ONLY so the 480 literal cannot come back unnoticed: this
/// used to be `SizedBox(height: 480)`, and with a ~530px Info+Convert column
/// beside it the page ended near 620px on a 1335px window - half the screen
/// empty, which was the whole of "wygląda słabo". A constant would pass any
/// screenshot; it fails the test that asks for two different viewports.
///
/// Mobile keeps a fixed 260 because below 768 the page is one scrolling column
/// (sketch 152-D) and there is no viewport to fill - the chart is a station on
/// the way down, not the page.
double coinChartHeight({
  required double viewportHeight,
  required bool isDesktop,
}) => isDesktop
    ? math.max(_kMinChartHeight, viewportHeight - _kChromeAboveChart)
    : 260;

/// "0 means unknown", not "zero". `CoinGeckoMarketData.fromJson` defaults every
/// numeric to `0.0` and the rank to `0`, so without this a missing field prints
/// a confident `$0.00` / `#0`. Lifted out of `CoinInfoCard` on 2026-07-28 so the
/// stat rail uses the SAME rule rather than inventing a third one.
String formatCompactCurrency(double? number) {
  if (number == 0 || number == null) {
    return "N/A";
  }
  return NumberFormat.compactSimpleCurrency().format(number);
}

String formatCompactDecimal(double? number) {
  if (number == 0 || number == null) {
    return "N/A";
  }
  return NumberFormat.compact().format(number);
}

/// A signed percentage, or "N/A" when the field never arrived.
String formatPercent(double? pct) {
  if (pct == null || pct == 0) {
    return "N/A";
  }
  final sign = pct > 0 ? '+' : '';
  return '$sign${pct.toStringAsFixed(2)}%';
}

/// A price, or "N/A". Not compact - a price is read digit by digit.
String formatPrice(double? value) {
  if (value == null || value == 0) {
    return "N/A";
  }
  return NumberFormat.currency(locale: "en_US", symbol: "\$").format(value);
}

/// sketch 152 `.sectitle`: a small uppercase section label that lives INSIDE
/// each token-detail card (Info, Convert) rather than floating above it.
Widget _buildSectionTitle(BuildContext context, String text) =>
    // Was a hand-rolled 13/w600/0.4 built off labelLarge; joins GWKicker's
    // default step (sketch 065). This call site is the one that made the case
    // for the component — a section title INSIDE a card is exactly the job the
    // transaction receipt (154-A) needs done too.
    GWKicker(text);

class TokenInfoScreen extends StatefulWidget {
  final TokenInfoArgs args;
  final WalletDetailsCubit walletDetailsCubit;
  final bool isGnusWalletConnected;

  /// Injectable market-data resolver - the seam
  /// `test/tokens/coin_page_entry_parity_test.dart` uses to drive loading,
  /// failed and retry without Hive or the network. Production callers never
  /// pass this; [_TokenInfoScreenState.initState] defaults it to the real
  /// fetch.
  final Future<Map<String, CoinGeckoMarketData?>> Function(
    List<String> coinIds,
  )?
  resolveMarketData;

  const TokenInfoScreen({
    super.key,
    required this.walletDetailsCubit,
    required this.args,
    required this.isGnusWalletConnected,
    this.resolveMarketData,
  });

  @override
  State<TokenInfoScreen> createState() => _TokenInfoScreenState();
}

/// The coin page's own read on its market data - distinct from
/// [WalletDetailsState], which is about the user's wallet, not what this
/// page is showing.
///
///  * [ready] - `args.marketData` arrived non-null. Markets and the
///    dashboard Markets panel always take this branch (neither ever opens a
///    coin with no data), so this plan adds zero new requests on those
///    routes.
///  * [loading] - `args.marketData` is null but `args.coinGeckoId` names a
///    real coin, so the page asks for it.
///  * [failed] - the ask came back with no entry for this coin, or threw.
///    Retryable - this is the branch that used to be indistinguishable from
///    [uncovered], which is the whole reason "not covered by our market data
///    provider" used to print over a rate-limited request.
///  * [uncovered] - no data AND nothing to ask for. The one state actually
///    allowed to say the provider does not cover this token.
enum _MarketDataStatus { ready, loading, failed, uncovered }

class _TokenInfoScreenState extends State<TokenInfoScreen> {
  late _MarketDataStatus _status;
  CoinGeckoMarketData? _marketData;

  @override
  void initState() {
    super.initState();
    _marketData = widget.args.marketData;
    if (_marketData != null) {
      _status = _MarketDataStatus.ready;
    } else if (widget.args.coinGeckoId != null) {
      _status = _MarketDataStatus.loading;
      _fetch();
    } else {
      _status = _MarketDataStatus.uncovered;
    }
  }

  Future<void> _fetch() async {
    final resolver =
        widget.resolveMarketData ??
        (List<String> ids) => fetchCoinsMarketData(coinIds: ids);
    try {
      final result = await resolver([widget.args.coinGeckoId!]);
      // Symbol key first, coin-id key second - the same order
      // `markets_screen.dart:146` keeps a dual lookup for, because
      // `fetchCoinsMarketData`'s own returned maps are keyed by symbol.
      final data =
          result[widget.args.symbol?.toLowerCase()] ??
          result[widget.args.coinGeckoId];
      if (!mounted) {
        return;
      }
      setState(() {
        if (data != null) {
          _marketData = data;
          _status = _MarketDataStatus.ready;
        } else {
          _status = _MarketDataStatus.failed;
        }
      });
    } catch (_) {
      if (!mounted) {
        return;
      }
      setState(() => _status = _MarketDataStatus.failed);
    }
  }

  /// Re-enters [_MarketDataStatus.loading], which unmounts the Retry button
  /// on the very next frame - that is what makes a held cursor unable to fire
  /// a second request (T-hsb-04), not a manual disabled flag: the control a
  /// second tap would need no longer exists once the first tap lands.
  void _retry() {
    setState(() => _status = _MarketDataStatus.loading);
    _fetch();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: widget.walletDetailsCubit,
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          return _buildScreenWithCubit(context, state);
        },
      ),
    );
  }

  /// **Screen when WalletDetailsCubit is available**
  Widget _buildScreenWithCubit(BuildContext context, WalletDetailsState state) {
    final selectedCoin = state.selectedCoin;
    final selectedWallet = state.selectedWallet;
    final selectedNetwork = state.selectedNetwork;
    final walletDetailsCubit = context.read<WalletDetailsCubit>();

    final isGnusBridgeEnabled =
        widget.isGnusWalletConnected &&
        selectedCoin?.symbol?.toLowerCase() == 'gnus';

    return Scaffold(
      // 071-B: the 48px Material AppBar and its hand-built "Markets / Bitcoin"
      // breadcrumb are gone. This screen now sits INSIDE the ShellRoute, so the
      // app's navbar is the top of the window like everywhere else, and the
      // title is a GWPageHeader in the body exactly as Markets/News/Transactions
      // render theirs.
      body: LayoutBuilder(
        builder: (context, constraints) {
          // sketch 152 (locked 2026-07-24): the two-panel layout switches at
          // GeniusBreakpoints.medium (768), matching the code's own
          // ResponsiveDrawer/useDesktopLayout threshold.
          final bool isDesktop =
              constraints.maxWidth > GeniusBreakpoints.medium;
          final bool isWide = constraints.maxWidth >= GeniusBreakpoints.large;

          // **The 480 literal, replaced.** `_buildMainCard` used to be
          // `SizedBox(height: 480)`; with a ~530px Info+Convert column beside it
          // the page's content ended near 620px on a 1335px window, so roughly
          // half the screen was empty. That is the whole of Jakub's "wygląda
          // słabo".
          //
          // `constraints.maxHeight` is the viewport because the Scaffold body is
          // bounded - the SingleChildScrollView below is what makes height
          // unbounded, so the number has to be read HERE, above it. The floor
          // keeps the chart usable on a short window and lets the page scroll
          // rather than squashing it.
          final double chartHeight = coinChartHeight(
            viewportHeight: constraints.maxHeight,
            isDesktop: isDesktop,
          );

          return SingleChildScrollView(
            // The Markets / News / Transactions frame: NO horizontal page
            // padding - every block carries its own 12px gutter - so the coin
            // title lands on the same x as "Markets" on the page you came from.
            // It used to be `EdgeInsets.all(space10)` around a 1200-wide centred
            // column, which put the title ~170px further in on a 1500px window.
            // Top gap is the shared `GeniusBreakpoints.pageTitleGap` every
            // content page uses. This page carried `space6`
            // (12), so it sat 52px tighter under the nav bar than every tab it
            // is reached from (Jakub, 2026-07-31).
            //
            // NOTE: the coin NAME still lands lower than those pages' titles,
            // because `_BackToMarkets` occupies the first ~26px inside this
            // padding and no other page has a back link. Aligning the name
            // itself would mean shrinking this pad below the shared value,
            // which trades one mismatch for another - left as the shared gap
            // deliberately, not overlooked.
            padding: EdgeInsets.fromLTRB(
              0,
              GeniusBreakpoints.pageTitleGap(context),
              0,
              GeniusWalletConsts.space20,
            ),
            primary: true,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: GeniusBreakpoints.xxl,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    GWBackLink(
                      label: widget.args.originLabel,
                      onTap: () => context.pop(),
                    ),
                    _header(context, selectedCoin),
                    // sketch 165 Synthesis, change 3: the actions sit on their
                    // own row under the identity block, not on the title's
                    // line, and mount OUTSIDE the `marketData != null` guard -
                    // Receive needs no market price and must survive the
                    // no-data route.
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: GeniusBreakpoints.pageGutter(context),
                      ),
                      child: _CoinActionRow(
                        selectedCoin: selectedCoin,
                        selectedWallet: selectedWallet,
                        selectedNetwork: selectedNetwork,
                        isGnusBridgeEnabled: isGnusBridgeEnabled,
                        walletDetailsCubit: walletDetailsCubit,
                        marketData: _marketData,
                      ),
                    ),
                    const SizedBox(height: GeniusWalletConsts.space8),
                    if (_marketData != null) ...[
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: GeniusBreakpoints.pageGutter(context),
                        ),
                        child: _StatRail(data: _marketData!),
                      ),
                      const SizedBox(height: GeniusWalletConsts.space8),
                    ],
                    // 075-E2 moved the wallet actions up onto the title's line,
                    // so this is a plain label for the chart card again. It
                    // stops reserving the 44px an action row needed - which is
                    // the height E2 hands back.
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: GeniusBreakpoints.pageGutter(context),
                      ),
                      child: const GWKicker('Price'),
                    ),
                    const SizedBox(height: GeniusWalletConsts.space4),
                    Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: GeniusBreakpoints.pageGutter(context),
                      ),
                      child: isWide && _marketData != null
                          // >=1024: chart | Info+Convert side by side, and the
                          // chart is EXACTLY as tall as the column beside it.
                          //
                          // Jakub 2026-07-28: *"ten graph jest znacznie
                          // większy [...] ma być dostosowane do wysokości
                          // łącznych sekcji INFO i CONVERT. Musi być IN LINE."*
                          // The viewport-derived height this replaced fixed the
                          // 480 literal's empty page but overshot in the other
                          // direction - a chart taller than everything next to
                          // it left the row ragged at the bottom.
                          //
                          // `IntrinsicHeight` asks each child how tall it wants
                          // to be and gives the row the largest answer. The
                          // side column answers honestly; the chart is wrapped
                          // so it answers ZERO (see `_FillHeight`), which makes
                          // Info+Convert the sole source of the row's height and
                          // the chart stretch to meet it.
                          ? IntrinsicHeight(
                              child: Row(
                                spacing: GeniusWalletConsts.space8,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(flex: 2, child: _chartCard(null)),
                                  Expanded(
                                    flex: 1,
                                    child: _buildActionSection(_marketData),
                                  ),
                                ],
                              ),
                            )
                          // <1024 (and the loading/failed/no-market-data
                          // cases, which never take the wide branch above
                          // since it requires _marketData != null): one
                          // column.
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              spacing: GeniusWalletConsts.space8,
                              children: [
                                // The card under the line is the chart, a
                                // loading spinner, a retryable error, or -
                                // on the route that reaches this page from
                                // the wallet's own Assets list for a token
                                // the provider genuinely does not cover -
                                // the empty state saying so. See
                                // `_chartSlot`.
                                _chartSlot(chartHeight),
                                _buildActionSection(_marketData),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// The single-column chart slot, keyed to [_status] rather than a bare
  /// null check on [_marketData] - the whole point of Task 2. A null
  /// [_marketData] used to mean exactly one thing ("not covered"); now it
  /// can also mean "still asking" or "the ask failed", and each gets its own
  /// card instead of being flattened into the same false claim.
  Widget _chartSlot(double chartHeight) {
    switch (_status) {
      case _MarketDataStatus.ready:
        return _chartCard(chartHeight);
      case _MarketDataStatus.loading:
        return _loadingCard();
      case _MarketDataStatus.failed:
        return _failedCard();
      case _MarketDataStatus.uncovered:
        return _noMarketData(context);
    }
  }

  /// Same chrome as [_noMarketData] - a `GWCard` in the chart's slot - so the
  /// page does not restyle itself between "still asking" and "gave up".
  Widget _loadingCard() => const GWCard(
    radius: GeniusWalletConsts.radiusMd,
    padding: EdgeInsets.all(GeniusWalletConsts.space8),
    child: Padding(
      padding: EdgeInsets.symmetric(vertical: GeniusWalletConsts.space20),
      child: Center(child: Loading()),
    ),
  );

  /// **T-hsb-03: this is the card that stops the app lying.** A rate limit
  /// or a timeout used to land here and print "not covered by our market
  /// data provider" - a false statement about a network failure. This card
  /// says what actually happened and offers a way back to [ready] instead of
  /// leaving the page terminal.
  Widget _failedCard() => GWCard(
    radius: GeniusWalletConsts.radiusMd,
    padding: const EdgeInsets.all(GeniusWalletConsts.space8),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const GWEmptyState(
          icon: Icons.cloud_off,
          title: 'Price could not be loaded',
          message:
              'This looks like a temporary problem reaching our market '
              'data provider, not a token we do not cover. Try again.',
        ),
        const SizedBox(height: GeniusWalletConsts.space8),
        // gradientOutline/sm - the same weight the action row's Receive and
        // Bridge already carry, so Swap stays the one filled control on this
        // surface (CTA weight rule).
        GWButton(
          variant: GWButtonVariant.gradientOutline,
          size: GWButtonSize.sm,
          label: 'Retry',
          leading: const Icon(Icons.refresh),
          onPressed: _retry,
        ),
      ],
    ),
  );

  /// Identity + price, in the app's page header instead of an AppBar crumb.
  ///
  /// **sketch 165 Synthesis, change 3: the actions no longer ride here.** They
  /// used to sit in `titleTrailing`, on the title's own line behind a
  /// hairline; they are now `_CoinActionRow`, mounted below this header on its
  /// own row. `titleTrailing` reverts to null at this call site - it is not
  /// deleted from `GWPageHeader` itself, which still has two tests of its own
  /// exercising it.
  Widget _header(BuildContext context, Coin? selectedCoin) {
    // marketData is what can be missing, not the coin - so the title falls back
    // to the wallet's own record rather than to "Token".
    final String title =
        _marketData?.name ??
        selectedCoin?.name ??
        selectedCoin?.symbol ??
        'Token';
    // **sketch 165 Synthesis, change 2: the subtitle is the ticker alone.**
    // The chain used to ride along here as `BTC  ·  Ethereum`, impersonating
    // part of the coin's own name directly under the title. It still appears
    // on the page exactly once - in Info's Network row, where a fact about
    // the token belongs. **Rank left the subtitle on 2026-07-28** - the stat
    // rail's first tile is Rank, so the page was printing it twice, six
    // pixels apart.
    final String symbol = (_marketData?.symbol ?? selectedCoin?.symbol ?? '')
        .toUpperCase();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: GeniusBreakpoints.pageGutter(context),
      ),
      child: GWPageHeader(
        title: title,
        subtitle: symbol.isEmpty ? null : symbol,
        // Jakub 2026-07-28: *"Przed Genius AI powinna być ikona tokenu,
        // zawsze."* `buildTokenIcon` is the helper Markets already uses for
        // exactly this - it takes a URL or an asset path, and falls back to a
        // placeholder circle when the image is missing or fails to load, so
        // "zawsze" holds even for a coin with no artwork.
        //
        // CoinGecko's URL first, the wallet's own asset second: the market
        // record is what names the coin in the title, so the glyph beside it
        // should come from the same source.
        leading: buildTokenIcon(
          iconPath: (_marketData?.imageUrl.isNotEmpty ?? false)
              ? _marketData!.imageUrl
              : selectedCoin?.iconPath,
          size: 40,
        ),
        // Sketch 168 E1 (Jakub, 2026-07-31): the price is pulled up against
        // the identity block and separated from it by a vertical hairline,
        // instead of hanging off the far right edge.
        trailingHugsTitle: true,
        trailing: _marketData == null
            ? null
            : _IdentityPriceGroup(data: _marketData!),
      ),
    );
  }

  /// The chart card.
  ///
  /// [height] null means "fill whatever the parent hands down" - the wide
  /// layout, where `IntrinsicHeight` has already sized the row from the
  /// Info+Convert column. A number is for the stacked layouts, which have no
  /// column to line up with.
  ///
  /// **sketch 165 Synthesis, change 5: the 24h low/high footer mounts here,
  /// inside this card, not in `crypto_live_chart.dart`.** Two reasons, either
  /// sufficient on its own: `CryptoLiveChart` takes a coin id and symbol and
  /// fetches its own series - it has no `CoinGeckoMarketData`, so a footer
  /// there means two new parameters threaded in for exactly one consumer. And
  /// `.planning/ROADMAP.md` assigns `crypto_live_chart.dart` to Phase 5 and
  /// fences Phase 7 out of it.
  ///
  /// The footer sits OUTSIDE the chart's own height (the `Expanded`/`SizedBox`
  /// below), never inside it: inside, it would eat into the plot's height and
  /// could push it under `kChartFrameMinHeight` (220), the runtime threshold
  /// that decides whether the chart draws the trading frame or the axis-free
  /// sparkline. Outside it, the card grows by the footer's height and
  /// `coinChartHeight` keeps returning exactly what it always has.
  Widget _chartCard(double? height) => GWCard(
    radius: GeniusWalletConsts.radiusMd,
    padding: const EdgeInsets.all(GeniusWalletConsts.space8),
    child: height == null
        ? Column(
            children: [
              // `_FillHeight` still answers zero to an intrinsic-height query,
              // and `Expanded` propagates that zero rather than masking it
              // (a flex child's contribution to a Column's own intrinsic
              // height is its intrinsic size divided by its flex - zero
              // divided by anything is zero) - so the wide layout's
              // `IntrinsicHeight` row still takes its height from the
              // Info+Convert column, not from this card. Only the footer's
              // own height counts.
              Expanded(
                child: _FillHeight(child: _buildGraphSection(_marketData!)),
              ),
              _ChartRangeFooter(
                low: _marketData!.low24h,
                high: _marketData!.high24h,
                now: _marketData!.currentPrice,
              ),
            ],
          )
        : Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: height, child: _buildGraphSection(_marketData!)),
              _ChartRangeFooter(
                low: _marketData!.low24h,
                high: _marketData!.high24h,
                now: _marketData!.currentPrice,
              ),
            ],
          ),
  );

  /// Jakub 2026-07-28: *"wtedy no data czy coś"*. Says so, instead of dropping
  /// three blocks and leaving a shorter page with no explanation.
  ///
  /// **074-C2 moved it into the chart card's slot** rather than above the
  /// actions. It now stands exactly where the chart stands on every other
  /// route, under the same section line, so nothing on the page changes
  /// position between a covered coin and an uncovered one. The actions and the
  /// Info card are still not part of it - Receive does not need a market price.
  Widget _noMarketData(BuildContext context) => const GWCard(
    radius: GeniusWalletConsts.radiusMd,
    padding: EdgeInsets.all(GeniusWalletConsts.space8),
    child: GWEmptyState(
      icon: Icons.show_chart,
      title: 'No market data',
      message:
          'This token is not covered by our market data provider, so there '
          'is no price, chart or market statistics for it. Everything else '
          'on this page still works.',
    ),
  );

  Widget _buildGraphSection(CoinGeckoMarketData marketData) {
    // sketch 152: the hero card owns the big price + % pill, so the chart
    // renders series-only (no built-in price header).
    return CryptoLiveChart(
      coinGeckoCoinId: marketData.id,
      tokenSymbol: marketData.symbol,
      showPriceHeader: false,
    );
  }

  /// Desktop (>=768, sketch 152 A) right column: Info above Convert, together.
  Widget _buildActionSection(CoinGeckoMarketData? marketData) {
    return Column(
      spacing: GeniusWalletConsts.space8,
      children: [
        _buildInfoSection(marketData),
        _buildConvertSection(marketData),
      ],
    );
  }

  /// The Info card alone — reused standalone on mobile (sketch 152 D) so it
  /// can be interleaved with the graph and Convert card.
  ///
  /// **Address and Network come from `widget.args`, not `state.selectedCoin`
  /// / `state.selectedNetwork` (T-hsb-02).** The wallet cubit's selection is
  /// whatever the wallet last had selected, which has nothing to do with the
  /// coin this page is showing when it was opened from Markets - printing it
  /// there was stating a foreign address as if it were this token's own.
  /// `args.walletCoin` is null from both Markets surfaces, so `CoinInfoCard`
  /// (which already omits any row whose value is null) simply drops these
  /// two rows rather than lying with them.
  Widget _buildInfoSection(CoinGeckoMarketData? marketData) {
    return CoinInfoCard(
      marketData: marketData,
      address: widget.args.walletCoin?.address,
      network: widget.args.network,
    );
  }

  /// The Convert card alone — reused standalone on mobile (sketch 152 D) so it
  /// can render directly below the chart, above the Info card.
  Widget _buildConvertSection(CoinGeckoMarketData? marketData) {
    return CoinConvertCard(tokenPrice: marketData?.currentPrice ?? 0.0);
  }
}

/// **sketch 165 Synthesis, change 3: labelled buttons on their own row under
/// the identity block, not bare glyphs riding the title line.**
///
/// Replaces `_buildActionRow` (074-C2/164-C's icon-only bar). Order is Swap,
/// then Receive, matching the Synthesis board. Swap is the page's one filled
/// control (`GWButtonVariant.gradient`); Receive is its outline twin
/// (`gradientOutline`) - the same pairing `coins_screen.dart` already ships
/// for Receive/Buy GNUS. Both `onPressed` bodies are unchanged from the
/// glyph-era row, comments included: only the chrome around them is new.
///
///  * **Receive** needs no market price, so it renders on the no-market-data
///    route too.
///  * **Bridge** is absent unless `isGnusBridgeEnabled`, `onPressed: null` on
///    a zero balance rather than hidden (a balance is a state the user can
///    change, absence is not). Sketch 165 never drew a third action; Bridge
///    takes the same `gradientOutline` treatment as Receive, the call this
///    file already made for the identical situation in sketch 164. **Flagged
///    for the walk, not settled** - two outlines beside one fill is still one
///    fill under the CTA weight rule, but nobody has judged it in place yet.
///
/// **`size: sm` (44), settled on the walk 2026-07-31.** Jakub read the 48px
/// row as too tall against the rest of the page and asked for the height the
/// homepage uses. That is `GWButtonSize.sm` - the same step the compute
/// panel's `New processing job` CTA carries (`compute_panel.dart`), so the two
/// primary surfaces now agree rather than each picking their own.
///
/// This is a size STEP on the shared component, never a hand-set height: the
/// 44 lives in `gw_button.dart`'s own ladder (`sm` 44 / `md` 48 / `lg` 56) and
/// changing it there still moves every caller together.
///
/// It does not weaken the accessibility floor DECISION constraint 2 was
/// protecting. 44x44 is exactly WCAG 2.5.5 Target Size (Enhanced, AAA), and
/// `gw_button.dart:86` records the same number as the iOS touch floor. The
/// mockup's 40 was the option that would have dropped to 2.5.8 (Minimum); it
/// stays rejected.
///
/// **`GWButton`'s disabled handling replaces `_ActionGlyph`'s `enabled`
/// field.** The old icon-only row painted its own 32px box with a manually
/// dimmed border; a labelled `GWButton` dims its own gradient/border/label
/// together whenever `onPressed == null`, so Bridge's zero-balance gate needs
/// nothing extra here.
///
/// **Tooltips and semantic labels are dropped.** The label is now the visible
/// text, so a `tooltip` would repeat it to the mouse and a `semanticLabel`
/// would repeat it to a screen reader - both read twice for no reason.
class _CoinActionRow extends StatelessWidget {
  const _CoinActionRow({
    required this.selectedCoin,
    required this.selectedWallet,
    required this.selectedNetwork,
    required this.isGnusBridgeEnabled,
    required this.walletDetailsCubit,
    required this.marketData,
  });

  final Coin? selectedCoin;
  final Wallet? selectedWallet;
  final Network? selectedNetwork;
  final bool isGnusBridgeEnabled;
  final WalletDetailsCubit walletDetailsCubit;
  final CoinGeckoMarketData? marketData;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: GeniusWalletConsts.space4,
      children: [
        GWButton(
          variant: GWButtonVariant.gradient,
          size: GWButtonSize.sm,
          label: 'Swap',
          leading: const Icon(Icons.swap_horiz),
          // **Preselection, gained in the 2026-07-28 merge.** Sketch 072 said
          // no variant may promise it, because `SwapScreen` took no parameters
          // - that was true of this branch and false of the base, which built
          // `preselectSymbol` / `preselectChainId` in Phase 8. The promise is
          // now keepable, so it is kept.
          //
          // **`marketData.symbol` FIRST, `selectedCoin` only as a fallback**,
          // which is the base branch's hard-won finding rather than a
          // preference: `selectedCoin` is the WALLET's currently-selected coin,
          // not the coin this page is showing. Opening a coin from Markets
          // leaves it null or pointing somewhere else entirely, which is why
          // preselection did nothing on exactly the route it was asked for.
          //
          // **`push`, not the base branch's `go`.** That `go` was a workaround
          // for a real crash - `/token-info` used to live OUTSIDE the
          // ShellRoute while `/swap` lived inside it, so pushing built a second
          // shell, the root navigatorKey appeared twice, and go_router asserted
          // `!keyReservation.contains(key)` while the navigation silently did
          // nothing. **071-B moved this route INSIDE the shell**, so both now
          // push onto the same navigator and the cause is gone - and `push`
          // keeps the back stack, where `go` replaced the location and lost the
          // way back to the coin. Walk this one: the failure it replaces was
          // real and was reported from a walk.
          onPressed: () => GoRouter.of(context).push(
            '/swap',
            extra: <String, dynamic>{
              'symbol': marketData?.symbol ?? selectedCoin?.symbol,
              // A weak hint, and only a preference - an unmatched chain falls
              // back rather than blocking.
              'chainId': selectedNetwork?.chainId,
            },
          ),
        ),
        GWButton(
          variant: GWButtonVariant.gradientOutline,
          size: GWButtonSize.sm,
          label: 'Receive',
          leading: const Icon(Icons.call_received),
          onPressed: () => ResponsiveDrawer.show<void>(
            context: context,
            // **The name comes from `selectedCoin` ONLY, never `marketData`.**
            // The QR shows the WALLET's address on the wallet's network, and
            // arriving here from Markets that network has nothing to do with
            // the coin you were reading about - titling this "Receive Bitcoin"
            // over an Ethereum address would be worse than saying less. When
            // there is no coin the title is just "Receive", which is what put
            // **"Receive null"** on screen before this.
            title: selectedCoin?.name == null
                ? 'Receive'
                : 'Receive ${selectedCoin!.name}',
            child: CryptoAddressQR(
              iconPath: selectedCoin?.iconPath,
              address: selectedWallet?.address ?? "",
              network: selectedNetwork?.name ?? "",
            ),
          ),
        ),
        if (isGnusBridgeEnabled)
          GWButton(
            // Bridge was not in the 164 brief, but it stands in the same row on
            // GNUS-enabled coins. Leaving it bare next to two bounded siblings
            // would read as a broken third button rather than a restrained one,
            // so it takes the same treatment. Flagged rather than assumed.
            variant: GWButtonVariant.gradientOutline,
            size: GWButtonSize.sm,
            label: 'Bridge',
            leading: const Icon(Icons.alt_route),
            onPressed: selectedCoin?.balance == 0
                ? null
                : () => _pushBridgeScreen(context, walletDetailsCubit),
          ),
      ],
    );
  }
}

/// Public only so the 070-A check can pump it without standing up a
/// `WalletDetailsCubit` and a router. It is not exported anywhere else and has
/// exactly one call site, `_buildConvertSection`.
class CoinConvertCard extends StatefulWidget {
  final double tokenPrice;

  const CoinConvertCard({super.key, required this.tokenPrice});

  @override
  State<CoinConvertCard> createState() => CoinConvertCardState();
}

class CoinConvertCardState extends State<CoinConvertCard> {
  late TextEditingController _tokenAmountController;

  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _tokenAmountController = TextEditingController(text: "1");
    _calculateTotalValue();
  }

  @override
  void dispose() {
    _tokenAmountController.dispose();
    super.dispose();
  }

  /// Reads the price straight off the widget. It used to be parsed back out of
  /// `_tokenPriceController.text`, which only existed because the display was
  /// an input - a `double` stringified into a controller and re-parsed on every
  /// keystroke. 164-A made the display a fact, so the round trip went with it.
  void _calculateTotalValue() {
    final double tokenAmount =
        double.tryParse(_tokenAmountController.text) ?? 0;

    setState(() {
      _totalValue = tokenAmount * widget.tokenPrice;
    });
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // sketch 152 `.surf` Convert card: title INSIDE the card (sectitle style),
    // then the read-only price + editable amount + total (inner field gap
    // space6).
    return GWCard(
      radius: GeniusWalletConsts.radiusMd,
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Convert"),
          const SizedBox(height: GeniusWalletConsts.space6),
          Column(
            spacing: GeniusWalletConsts.space6,
            children: [
              // The live price is a FACT, not a field (sketch 164-A, Jakub
              // 2026-07-29). It used to be a `GWTextField(readOnly: true)`
              // wearing a bordered `READ-ONLY` chip in its `suffix`, and the
              // chip was carrying the whole message on its own: the box was the
              // same height, the same radius and nearly the same edge as the
              // field directly beneath it, which you CAN type in.
              //
              // A `GWDetailGrid` row settles it structurally instead of
              // labelling it. Three things follow, and the third is the reason
              // this beat the alternatives:
              //
              //  1. The card already speaks this language one row down - the
              //     `Total` below is the same grid - so the price joins the
              //     facts rather than impersonating an input.
              //  2. The value keeps `textPrimary`. Sketch 164 measured the
              //     obvious rival (keep the box, grey the value): that is
              //     `textSecondary` on `surfaceSunken`, **6.20:1 dark but
              //     4.23:1 light** - under the 4.5:1 body floor. This variant
              //     has no such debt in either mode.
              //  3. **A `readOnly` field still takes focus in Flutter.** The
              //     old box could be tabbed into and would light up promising
              //     an edit that cannot happen; the comment that used to live
              //     here said so while shipping it anyway. A row cannot be
              //     focused, so the defect is gone rather than annotated.
              //
              // It also drops `_tokenPriceController`: the price arrived as a
              // double, went through `toString()` into a controller and came
              // back out through `double.tryParse` - a round trip that existed
              // only because the display was an input.
              GWDetailGrid(
                rows: [
                  Padding(
                    padding: kGWDetailRowPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Token price",
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textSecondary,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: "en_US",
                            symbol: "\$",
                            decimalDigits: widget.tokenPrice >= 1 ? 2 : 6,
                          ).format(widget.tokenPrice),
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              // The one editable control on this card, so it is the one that
              // gets the brand GRADIENT on focus. It lit a FLAT
              // `brandPrimaryStrong` before - structurally, not by oversight: a
              // `BorderSide` takes a single `Color`, so no `InputBorder` can be
              // a gradient, which is the whole reason `GWFocusRing` exists.
              GWKeyboardDoneBar(
                child: GWTextField(
                  controller: _tokenAmountController,
                  label: "Token amount",
                  focusRing: true,
                  fill: gw.surfaceSunken,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  onChanged: (_) => _calculateTotalValue(),
                ),
              ),
              // The card's one computed answer, given the same frame as the
              // facts it is computed from (070-A). It was a bare right-aligned
              // `bodyLarge` - the only element on the page with no structure at
              // all, which read as a caption rather than a result.
              GWDetailGrid(
                rows: [
                  Padding(
                    padding: kGWDetailRowPadding,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total",
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textPrimary,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(
                            locale: "en_US",
                            symbol: "\$",
                          ).format(_totalValue),
                          style: GeniusWalletTypography.bodySm.copyWith(
                            color: gw.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Public for the same reason as [CoinConvertCard]: so the glyph rule below can
/// be pinned by a test that pumps the card directly. One call site,
/// `_buildInfoSection`.
class CoinInfoCard extends StatelessWidget {
  final CoinGeckoMarketData? marketData;
  final String? address;
  final String? network;

  const CoinInfoCard({super.key, this.marketData, this.network, this.address});

  /// **sketch 165 Synthesis, change 8 (Jakub, 2026-07-30): no icons at all.**
  /// This card used to carry ONE accent for every info-row glyph
  /// (`brandPrimaryOnSurface`), chosen on sketch 070's four-panel comparison
  /// after a deliberate per-row rainbow measured badly in light mode - worth
  /// recording rather than losing outright, since change 8 supersedes that
  /// conclusion rather than disagreeing with it:
  ///
  /// | glyph | dark | light |
  /// |---|---|---|
  /// | `statusSuccess` (Market Cap) | 10.80 | **1.25** |
  /// | `brandTertiary` (Circulating) | 8.27 | **1.63** |
  /// | `brandPrimaryStrong` (Address) | 7.84 | **1.72** |
  /// | `statusError` (Total Supply) | 6.13 | **2.19** |
  /// | `statusNeutral` (Volume) | 4.21 | 3.19 |
  /// | `brandPrimaryOnSurface` (Network) | 10.25 | **4.23** |
  ///
  /// Network was the tell: it was the ONLY appearance-aware colour in that
  /// set and the only one that survived. The choice then was five new
  /// light-mode tokens, or the one colour that already carried both; the
  /// choice now is neither - every row is fully identified by its label
  /// alone (the glyphs were always decorative under 1.4.11), so the 22px
  /// slot and its `space6` gap are gone rather than recoloured again.
  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces this
    // subtree to rebuild on a live appearance toggle (04-04 discipline).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final textTheme = Theme.of(context).textTheme;
    // sketch 152 `.statrow`: grayish key + primary tabular value, both compact.
    final TextStyle keyStyle = (textTheme.bodySmall ?? const TextStyle())
        .copyWith(color: gw.textSecondary, fontSize: 14);
    final TextStyle valStyle = (textTheme.bodySmall ?? const TextStyle())
        .copyWith(
          color: gw.textPrimary,
          fontSize: 14,
          fontFeatures: const [FontFeature.tabularFigures()],
        );

    /// One row of the grid. The 11/12 padding this used to hard-code was
    /// `kGWDetailRowPadding` written out by hand; the row applies it itself so a
    /// TAPPABLE row's hit area covers the whole cell (see the constant's doc).
    ///
    /// **The 22px glyph slot is gone (sketch 165 Synthesis, change 8).** Every
    /// row's label now starts at the card's own left edge, with no reserved
    /// column ahead of it.
    Widget statRow(String label, Widget value) {
      return Padding(
        padding: kGWDetailRowPadding,
        child: Row(
          children: [
            Expanded(
              child: Text(
                label,
                style: keyStyle,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            value,
          ],
        ),
      );
    }

    final infoTiles = <Widget>[
      if (network != null) statRow("Network", Text(network!, style: valStyle)),
      if (address != null)
        _CopyAddressRow(
          address: address!,
          keyStyle: keyStyle,
          valStyle: valStyle,
        ),
      statRow(
        "Market Cap",
        Text(formatCompactCurrency(marketData?.marketCap), style: valStyle),
      ),
      statRow(
        "Circulating Supply",
        Text(
          formatCompactDecimal(marketData?.circulatingSupply),
          style: valStyle,
        ),
      ),
      statRow(
        "Total Supply",
        Text(formatCompactDecimal(marketData?.totalSupply), style: valStyle),
      ),
      statRow(
        "Volume",
        Text(formatCompactCurrency(marketData?.totalVolume), style: valStyle),
      ),
    ];

    // sketch 152 `.surf` Info card: the "Info" title moves INSIDE the card
    // (sectitle style) and the duplicate token-identity header row is gone —
    // the hero already shows identity.
    //
    // 070-A: the rows were a hand-written `GWDetailGrid` - 11/12 padding, a 22px
    // glyph slot, a bare `Column` with `Divider(height: 1)` between children and
    // no well around any of it - written days after the component shipped for
    // the transaction receipt. Now it IS the component, so the group reads as
    // recessed and the rules stop at the rounded corners.
    return GWCard(
      radius: GeniusWalletConsts.radiusMd,
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionTitle(context, "Info"),
          const SizedBox(height: GeniusWalletConsts.space6),
          GWDetailGrid(rows: infoTiles),
        ],
      ),
    );
  }
}

/// The Address row: the WHOLE row copies, and the copy glyph is there at rest.
///
/// It used to be an inline 15px `IconButton` at the end of the value - a target
/// you had to hit precisely, on a row whose remaining ~330px did nothing. The
/// transaction receipt settled this on 2026-07-28: the copy affordance is
/// present at rest (an affordance you must hover to discover is not one) and the
/// hit area is the whole grid cell, which is exactly why `GWDetailGrid` makes
/// its ROWS apply [kGWDetailRowPadding] instead of padding them itself.
///
/// **sketch 165 Synthesis, change 8 (2026-07-30) dropped the LEADING glyph
/// column** - the 22px slot every other Info row also lost. The TRAILING
/// `Icons.copy_rounded` is untouched: it is the copy affordance itself, not
/// decoration, and change 8 was never about it.
///
/// **`_CopyRow` is deliberately NOT promoted out of `transaction_displays.dart`
/// to serve both.** That would put it at TWO consumers, under the 3+ bar
/// `GWKicker`, `GWSelectRow` and `GWWarningNote` each had to clear - and the two
/// rows are not the same shape anyway: this one truncates 6…6, the receipt's
/// chunks 8+8 in four-character groups. Sharing them would mean two new
/// parameters for one extra consumer. What is shared is the BEHAVIOUR, which
/// is the part a user can tell apart.
///
/// ponytail: two implementations of one affordance, on purpose.
/// Ceiling: they can drift, and only a walk would notice.
/// Upgrade path: a third consumer makes the component worth building, and at
/// that point the truncation strategy becomes its parameter.
class _CopyAddressRow extends StatelessWidget {
  const _CopyAddressRow({
    required this.address,
    required this.keyStyle,
    required this.valStyle,
  });

  final String address;
  final TextStyle keyStyle;
  final TextStyle valStyle;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final a = address;
    final short = a.length > 12
        ? "${a.substring(0, 6)}...${a.substring(a.length - 6)}"
        : a;

    // Hover plumbing moved into `GWHoverable` (23-05); this widget held no
    // other state, so it is a `StatelessWidget` now.
    return GWHoverable(
      builder: (hovered) => GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          // The FULL address goes to the clipboard, never the truncated form.
          Clipboard.setData(ClipboardData(text: a));
          showAppSnackBar(context, 'Address copied to clipboard');
        },
        // Inside the detector, so the whole cell is the target.
        child: Padding(
          padding: kGWDetailRowPadding,
          child: Row(
            children: [
              Expanded(child: Text("Address", style: keyStyle)),
              Text(short, style: valStyle),
              const SizedBox(width: GeniusWalletConsts.space3),
              Icon(
                Icons.copy_rounded,
                size: 14,
                color: hovered ? gw.textPrimary : gw.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The price and its 24h pill, in `GWPageHeader`'s trailing slot.
/// Sketch 168 **E1**: a vertical hairline, then the price - the pair that gets
/// pulled up against the identity block by `trailingHugsTitle`.
///
/// **The rule is a `SizedBox` + `ColoredBox`, deliberately not a `Border` on a
/// container.** A bordered box would inherit that box's padding and stop
/// matching the identity block's own height, which is the one thing this rule
/// has to do: E2's shorter rule was rejected on the walk because at 28px it
/// read as a stray tick beside the change pill rather than as a boundary
/// between two blocks.
///
/// 44 is the identity block's height (a 40px token icon, and a 24/32 title
/// over a 14/20 subtitle comes to 56 - the rule tracks the icon, which is what
/// the eye reads as the block's edge).
class _IdentityPriceGroup extends StatelessWidget {
  const _IdentityPriceGroup({required this.data});

  final CoinGeckoMarketData data;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        const SizedBox(width: GeniusWalletConsts.space10),
        SizedBox(
          width: 1,
          height: 44,
          child: ColoredBox(color: gw.borderSubtle),
        ),
        const SizedBox(width: GeniusWalletConsts.space10),
        _PriceBlock(data: data),
      ],
    );
  }
}

class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.data});

  final CoinGeckoMarketData data;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final pct = data.priceChangePercentage24h;
    final up = pct >= 0;
    final tone = up ? gw.statusSuccess : gw.statusError;

    // Sketch 168 E1: price and change sit on ONE line, side by side, not
    // stacked. Stacked they made this block ~60px tall, which was invisible
    // while it hung on the far right of the header but would rear up the
    // moment it moved next to a 52px identity block.
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          formatPrice(data.currentPrice),
          style: GeniusWalletTypography.numericBody.copyWith(
            color: gw.textPrimary,
            fontSize: 28,
            height: 34 / 28,
            fontWeight: FontWeight.w600,
          ),
        ),
        if (pct != 0) ...[
          const SizedBox(width: GeniusWalletConsts.space6),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space4,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  up ? Icons.arrow_drop_up : Icons.arrow_drop_down,
                  size: 16,
                  color: tone,
                ),
                Text(
                  formatPercent(pct),
                  style: GeniusWalletTypography.labelMd.copyWith(
                    color: tone,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Sketch 071-B's stat rail: five tiles of data the app was already paying
/// for. **Sixth on to sketch 165 Synthesis, change 4: the range tile moved
/// out** to become `_ChartRangeFooter`, mounted under the chart instead.
///
/// **Every field here was already parsed and already cached** - the request at
/// `coin_gecko_api.dart:140` is `/coins/markets`, which returns all of them by
/// default, and they land in `marketDataBox` on a 3-minute TTL. So this row
/// costs zero new requests, which is the entire reason it is the fill for the
/// space the 480px literal used to waste.
///
/// Every number goes through the shared "0 means unknown" formatters, because
/// `fromJson` defaults numerics to `0.0` and the rank to `0` - without that a
/// coin missing a field would print `$0.00` and `#0` with total confidence.
class _StatRail extends StatelessWidget {
  const _StatRail({required this.data});

  final CoinGeckoMarketData data;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final pct = data.priceChangePercentage24h;
    final ath = data.athChangePercentage;

    final tiles = <Widget>[
      GWStatTile(
        label: 'Rank',
        value: data.marketCapRank > 0 ? '#${data.marketCapRank}' : 'N/A',
      ),
      GWStatTile(
        label: '24h change',
        value: formatPercent(pct),
        valueColor: pct == 0
            ? null
            : (pct > 0 ? gw.statusSuccess : gw.statusError),
      ),
      GWStatTile(
        label: 'Volume 24h',
        value: formatCompactCurrency(data.totalVolume),
      ),
      GWStatTile(
        label: 'Market cap',
        value: formatCompactCurrency(data.marketCap),
      ),
      GWStatTile(
        label: 'From ATH',
        value: formatPercent(ath),
        valueColor: ath == 0
            ? null
            : (ath > 0 ? gw.statusSuccess : gw.statusError),
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        // Five across needs roughly 150 each; below that they wrap rather
        // than ellipsing every value at once. **The old 6/3/2 ladder divided
        // six exactly, so every row was always full.** Five tiles has no
        // three-step ladder with that property - 5's only divisors are 1 and
        // 5 - so `perRow` here is a target column count, not a promise that
        // every row fills it, and the width below is computed per ROW rather
        // than from `perRow`. That is the actual fix for the ragged tail: a
        // partial last row asks for its OWN share of the width instead of the
        // share a full row would have gotten, so it always reaches the same
        // right edge as the rows above it.
        final int perRow = constraints.maxWidth >= 900
            ? 5
            : constraints.maxWidth >= 600
            ? 3
            : 2;
        final double gap = GeniusWalletConsts.space6.toDouble();
        // Chunked Rows under IntrinsicHeight, NOT a Wrap. A `Wrap` places its
        // children at their natural size and neither stretches nor equalises
        // them, so a taller tile in the run would stand proud of its
        // neighbours (the defect the 2026-07-29 walk found). `IntrinsicHeight`
        // + `stretch` gives every card in a run the tallest one's height, and
        // it is safe here in a way it is not around a chart: these subtrees
        // are Text and a Container, all of which answer an intrinsic-height
        // query cheaply.
        final rows = <Widget>[];
        for (var i = 0; i < tiles.length; i += perRow) {
          final chunk = tiles.sublist(i, math.min(i + perRow, tiles.length));
          // Computed from THIS row's own tile count, not `perRow` - a row of
          // 2 in a nominally-3-wide band gets wider tiles than a full row of
          // 3, and both span the rail's full width. That is what keeps a
          // partial last row from leaving a tile-sized hole at the right edge.
          final double w =
              (constraints.maxWidth - gap * (chunk.length - 1)) / chunk.length;
          rows.add(
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var j = 0; j < chunk.length; j++) ...[
                    if (j > 0) SizedBox(width: gap),
                    SizedBox(
                      width: w,
                      child: GWCard(
                        radius: GeniusWalletConsts.radiusMd,
                        padding: const EdgeInsets.symmetric(
                          horizontal: GeniusWalletConsts.space6,
                          vertical: GeniusWalletConsts.space6,
                        ),
                        child: chunk[j],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            for (var r = 0; r < rows.length; r++) ...[
              if (r > 0) SizedBox(height: gap),
              rows[r],
            ],
          ],
        );
      },
    );
  }
}

/// The 24h-range track and its position marker, keyed so the layout claims in
/// `test/tokens/coin_page_range_tile_test.dart` can measure them.
///
/// Both were invisible to every other kind of check: the track's collapse to
/// zero width is a `Stack` loose-constraint result, not a value anything reads.
const Key kCoinRangeTrackKey = Key('coin-range-track');
const Key kCoinRangeMarkerKey = Key('coin-range-marker');

/// The chart's fixed-24h-window footer (sketch 165 Synthesis, change 5). Was
/// `_RangeTile`, a stat-rail tile; the same `low`/`high`/`now` fields and the
/// same `known = low > 0 && high > low` guard move here, under the chart
/// instead of into the rail.
///
/// **The window is fixed at 24h, whatever timeframe the chart shows.**
/// DECISION constraint 3 was RESOLVED by Jakub on 2026-07-30: tracking the
/// selected timeframe was investigated and rejected on design grounds, not
/// cost. Where the chart renders its trading frame, it already draws in-plot
/// H/L plates for the SELECTED window; a footer scoped to that same window
/// would restate those two numbers in a larger font. A footer fixed at 24h is
/// a second reference the plot does not carry - the divergence on 1W/1Y is
/// the feature, not a bug.
///
/// `known == false` renders nothing at all - no hairline, no track, no N/A
/// pair. The chart card is the one place on this page that must not gain
/// furniture it cannot back up.
class _ChartRangeFooter extends StatelessWidget {
  const _ChartRangeFooter({
    required this.low,
    required this.high,
    required this.now,
  });

  final double low;
  final double high;
  final double now;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final bool known = low > 0 && high > low;
    if (!known) {
      return const SizedBox.shrink();
    }
    final double t = ((now - low) / (high - low)).clamp(0.0, 1.0);
    // The mockup's 13px, against `GWStatTile`'s 15 - the footer spans the
    // whole card rather than a tile, so the full-precision `formatPrice`
    // replaces the tile's compact form.
    final TextStyle valueStyle = GeniusWalletTypography.numericBody.copyWith(
      color: gw.textPrimary,
      fontSize: 13,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(height: GeniusWalletConsts.space6),
        // The hairline that separates the plot from the footer. A childless,
        // widthless `Container` expands to fill what it is offered - the same
        // rule that keeps the track below spanning its row rather than
        // collapsing to zero.
        Container(height: 1, color: gw.borderSubtle),
        const SizedBox(height: GeniusWalletConsts.space6),
        const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GWKicker('24h low', dense: true),
            GWKicker('24h high', dense: true),
          ],
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        // A 4px track with the current price's position along it. Decorative:
        // the numbers below say the same thing, so 1.4.11 does not bind.
        //
        // **The track is `borderStrong`, not `surfaceSunken`.** The original
        // painted the rail in the DEEPEST surface (#06080C) on top of a
        // `surfaceElevated` card (#0C0E14) — a darker-on-dark fill about
        // 1.1:1 against its own background, with a `borderSubtle` hairline
        // (1.36:1) as its only edge. It was not a faint rail; on the walk it
        // was no rail at all, and the 6px marker read as a teal dot floating
        // under the numbers with nothing beneath it. Light mode hid the bug:
        // there `surfaceSunken` is #CFD4DB, plainly visible on a white card.
        // `borderStrong` is 24% of the ink/white axis, so it reads on BOTH
        // canvases — which is the property the old pairing lacked, not extra
        // weight for its own sake.
        // `Align` on a fractional x, NOT a `LayoutBuilder` + `Positioned`.
        // Alignment.x runs -1..1 across the free space with the child's own
        // width already discounted, so `2t - 1` places the marker exactly
        // where `left: (maxWidth - 6) * t` did — and it gets there without
        // measuring. That matters: `LayoutBuilder` refuses intrinsic queries
        // outright ("does not support returning intrinsic dimensions"), and
        // the wide chart card sits under an `IntrinsicHeight` too.
        SizedBox(
          height: 4,
          child: Stack(
            children: [
              Container(
                key: kCoinRangeTrackKey,
                height: 4,
                decoration: BoxDecoration(
                  color: gw.borderStrong,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Align(
                alignment: Alignment(2 * t - 1, 0),
                child: Container(
                  key: kCoinRangeMarkerKey,
                  width: 6,
                  height: 4,
                  decoration: BoxDecoration(
                    gradient: GeniusWalletGradient.brandCta,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: GeniusWalletConsts.space4),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(formatPrice(low), style: valueStyle),
            Text(formatPrice(high), style: valueStyle),
          ],
        ),
      ],
    );
  }
}

/// Reports **zero** intrinsic height, then fills whatever height it is given.
///
/// This is what makes the chart line up with Info+Convert instead of driving
/// the row. `IntrinsicHeight` sizes a Row to the tallest child's *intrinsic*
/// height; a chart has no meaningful answer to "how tall do you want to be"
/// (and `CryptoLiveChart` contains an `Expanded`, which throws outright when
/// asked). Answering 0 hands the decision entirely to the Info+Convert column,
/// which is exactly Jakub's *"musi być IN LINE"*.
///
/// ponytail: a `RenderProxyBox` override rather than a layout algorithm.
/// Ceiling: inside a plain unbounded Column this would collapse to nothing, so
/// it is only correct under a parent that supplies a tight height - which the
/// single call site does. Upgrade path: none needed; if a second caller appears
/// it should assert its parent instead.
class _FillHeight extends SingleChildRenderObjectWidget {
  const _FillHeight({required Widget child}) : super(child: child);

  @override
  RenderObject createRenderObject(BuildContext context) => _RenderFillHeight();
}

class _RenderFillHeight extends RenderProxyBox {
  @override
  double computeMinIntrinsicHeight(double width) => 0;

  @override
  double computeMaxIntrinsicHeight(double width) => 0;
}
