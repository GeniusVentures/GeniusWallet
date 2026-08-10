import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/coins/assets_total_band.dart';
import 'package:genius_wallet/components/coins/assets_totals.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
// `DashboardScrollContainer` lives in the dashboard screen's own file. Importing
// it from here is the SAME move `transactions_slim_view.dart` already makes for
// the same reason: it is the app's one panel container, and re-creating its
// recipe as a local `GWCard(padding: space3)` would render identical pixels
// today and drift the day the panel changes.
import 'package:genius_wallet/dashboard/assets/assets_market_data.dart';
import 'package:genius_wallet/dashboard/assets/assets_sort.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// The `/assets` page: every coin in the selected wallet, searchable and
/// sortable by value. The destination the dashboard's Assets `View all` points
/// at once that section is capped at its top 5 (plan 25-01).
///
/// Sketch 177 variant **D as Jakub simplified it**: a page header, a search
/// field, and ONE sort control keyed on value whose tap toggles the direction.
/// No name sort, no 24h sort.
///
/// **Framed by sketch 187 scheme C (Jakub, 2026-08-08, quick 260808-whb): two
/// panels, drawn with the homepage's own `DashboardScrollContainer`.** Panel 1
/// is the portfolio total, panel 2 the search, the count/sort line and the
/// rows. The decision that settled it is a fact about the app rather than a
/// preference: `/transactions` already boxes its list on a phone
/// (`transactions_slim_view.dart:483`), Markets draws a `GWCard` per coin and
/// News one per article, so **this page was the only unboxed list in the
/// app**. The cost is stated rather than hidden - a boxed row has 348px of
/// content at 390pt where a flat one has 362 - and it is the cost the
/// neighbouring tab already pays.
///
/// The back link went with the same change; see the note at its old site in
/// `_pageChildren`.
///
/// **This page starts NO periodic refresh.** `CoinsScreen` owns a 1-minute
/// timer and `fetchCoinsMarketData` is backed by a 3-minute Hive cache shared
/// process-wide, so whichever surface is alive keeps the cache warm for both.
/// A second timer would double the app's request volume against a rate-limited
/// free API and could get both surfaces throttled (threat T-25-02-03).
/// Freshness here comes from one fetch on arrival plus an explicit
/// `RefreshIndicator`: a deliberate user gesture beats a hidden timer.
///
/// **This page is READ-ONLY against `WalletDetailsCubit`, with exactly one
/// exception**: `selectCoin` on row tap, which is load-bearing for `/bridge`.
/// It never writes the wallet balance back - two surfaces writing one total
/// would race and corrupt the displayed balance (threat T-25-02-04).
class AssetsScreen extends StatefulWidget {
  const AssetsScreen({super.key, this.resolveMarketData});

  /// Test seam only. Null in every production call site, where it falls back
  /// to [resolveAssetsMarketData]. Without it a widget test throws on the
  /// first Hive box lookup before a single row renders - see
  /// `assets_market_data.dart` for why the WHOLE resolution sits behind it
  /// rather than only the final network call.
  final AssetsMarketDataResolver? resolveMarketData;

  @override
  State<AssetsScreen> createState() => _AssetsScreenState();
}

class _AssetsScreenState extends State<AssetsScreen> {
  /// Keyed by lowercase symbol, the key `fetchCoinsMarketData` writes and
  /// `CoinCardRow` reads.
  Map<String, CoinGeckoMarketData?> _marketData = {};
  bool _isFetching = false;

  /// Descending is the default, and it is not persisted. "What do I hold" is
  /// the question this page exists to answer, and landing on a page still
  /// filtered by a query typed days ago is the classic stale-filter defect
  /// (D-3). Both fields live in `State` rather than in `build`, so they
  /// survive a rebuild (keyboard, market data arriving, an appearance toggle)
  /// and a round trip to `/token-info` and back.
  bool _ascending = false;
  String _query = '';

  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // DEVIATION from the plan's D-5 step 1, and it is load-bearing rather than
    // belt-and-braces. `BlocListener` fires on a state CHANGE only. This page
    // is reached FROM the dashboard, where `coinsStatus` is already
    // `successful` and no further change is coming, so the listener alone
    // would never fire and the page would sit permanently priceless - every
    // row reading $0.00 and every holding wrongly ranked into the unpriced
    // tier. `CoinsScreen` does not hit this because it mounts at app start,
    // while coins are still `initial`.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      final cubit = context.read<WalletDetailsCubit>();
      final state = cubit.state;
      if (state.coinsStatus == WalletStatus.initial &&
          state.selectedNetwork != null) {
        // Deep-linked or reached before the wallet finished loading: ask, and
        // let the listener below pick the answer up.
        cubit.getCoins();
      } else if (state.coins.isNotEmpty) {
        _fetchMarketData(state.coins);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchMarketData(List<Coin> coins) async {
    // DEV-ONLY: while mock-mode is ON, skip the network entirely and feed rows
    // the seeded offline prices. Mirrored from `coins_screen.dart:75-81`
    // deliberately - without it the dev bubble's scenarios light up the
    // dashboard and leave `/assets` blank, and the page is unwalkable on a
    // wallet where every balance is zero.
    if (kDebugMode && context.read<WalletDetailsCubit>().mockMode) {
      setState(() {
        _marketData = DevMockHoldings.instance.marketData;
        _isFetching = false;
      });
      return;
    }

    if (_isFetching || coins.isEmpty) {
      return;
    }
    setState(() => _isFetching = true);

    final resolver = widget.resolveMarketData ?? resolveAssetsMarketData;

    try {
      final data = await resolver(coins);
      if (!mounted) {
        return;
      }
      setState(() {
        _marketData = data;
        _isFetching = false;
      });
    } catch (_) {
      // A failed refresh must not blank a page that is already showing prices,
      // and it must not strand `_isFetching` at true - that would wedge the
      // page priceless for the rest of its life, including across
      // pull-to-refresh. Keep the last good map and let the user retry.
      if (!mounted) {
        return;
      }
      setState(() => _isFetching = false);
    }
    // ponytail: a failure here is silent - no toast, no error row. The wallet
    // total simply reads what the last good fetch said. Upgrade path: surface
    // it once this page has a place to put a non-blocking error that does not
    // fight the five states in the table below.
  }

  /// Opens the address-QR receive drawer for the empty-wallet footer.
  ///
  /// ponytail: DUPLICATES `CoinsScreenState._showReceive`
  /// (`coins_screen.dart:172-187`). It cannot be extracted because that file
  /// belongs to plan 25-01 and is fenced for this wave. Upgrade path after
  /// 25-01 lands: promote to a shared `showReceiveDrawer(context, state)` and
  /// delete both copies. Ceiling: until then the two drawers can drift.
  void _showReceive(WalletDetailsState state) {
    final address = state.selectedWallet?.address;
    if (address == null || address.isEmpty) {
      return;
    }
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Receive',
      child: CryptoAddressQR(
        address: address,
        network:
            state.selectedNetwork?.name ?? state.selectedNetwork?.symbol ?? '',
        iconPath: state.selectedNetwork?.iconPath,
      ),
    );
  }

  /// The (balance, price) records the totals helper folds over, keyed by
  /// `coin.symbol?.toLowerCase()` - the same key [_marketData] is written
  /// with.
  List<({double balance, double price})> _valueHoldings(List<Coin> coins) {
    final holdings = <({double balance, double price})>[];
    for (final coin in coins) {
      final marketData = _marketData[coin.symbol?.toLowerCase()];
      if (marketData != null) {
        holdings.add((
          balance: coin.balance ?? 0.0,
          price: marketData.currentPrice,
        ));
      }
    }
    return holdings;
  }

  /// The pct-carrying variant behind the header's 24h-change subline.
  List<({double balance, double price, double pct})> _changeHoldings(
    List<Coin> coins,
  ) {
    final holdings = <({double balance, double price, double pct})>[];
    for (final coin in coins) {
      final marketData = _marketData[coin.symbol?.toLowerCase()];
      if (marketData != null) {
        holdings.add((
          balance: coin.balance ?? 0.0,
          price: marketData.currentPrice,
          pct: marketData.priceChangePercentage24h,
        ));
      }
    }
    return holdings;
  }

  /// Projects a wallet [Coin] onto the primitive [AssetRowData] the shared
  /// ordering rule works in, keeping the coin itself alongside so the row it
  /// produces is still tappable.
  ///
  /// The pair, rather than sorting bare [AssetRowData] and looking the coin
  /// back up by symbol: a wallet may legitimately hold two entries with the
  /// same symbol on different networks, and a symbol-keyed lookup would hand
  /// both rows the same coin. `compareAssetsByValue` - the shared authority
  /// `sortAssets` itself delegates to - is applied directly instead, so the
  /// order is byte-identical to what plan 25-01's `sortAssets(...).take(5)`
  /// produces.
  ({Coin coin, AssetRowData row}) _project(Coin coin) {
    final data = _marketData[coin.symbol?.toLowerCase()];
    return (
      coin: coin,
      row: AssetRowData(
        name: coin.name ?? '',
        symbol: coin.symbol ?? '',
        balance: coin.balance ?? 0.0,
        price: data?.currentPrice ?? 0.0,
        hasMarketData: data != null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<WalletDetailsCubit, WalletDetailsState>(
      listener: (context, state) {
        final walletCubit = context.read<WalletDetailsCubit>();

        if (state.coinsStatus == WalletStatus.initial &&
            state.selectedNetwork != null) {
          walletCubit.getCoins();
        }

        if (state.coinsStatus == WalletStatus.successful) {
          _fetchMarketData(state.coins);
        }
      },
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, state) {
          // Fail-soft read: registers the InheritedWidget dependency that
          // forces this subtree to rebuild on a live appearance toggle.
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

          return Scaffold(
            body: SafeArea(
              child: RefreshIndicator(
                onRefresh: () async {
                  context.read<WalletDetailsCubit>().getCoins();
                },
                // The PAGE scrolls, and it is the ONLY thing that scrolls.
                // Nothing below may introduce a list, a grid or a second
                // scroll view - an inner scrollable is the exact defect this
                // whole phase exists to remove.
                //
                // AlwaysScrollableScrollPhysics keeps pull-to-refresh armed
                // when the content is SHORTER than the viewport, which is the
                // normal case for a wallet holding a handful of coins.
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Padding(
                      // THE SHARED PAGE FRAME, and this screen was the one
                      // page-header surface not using it (quick 260808-whb).
                      // It hardcoded `space32` (64) on top and 12 on each
                      // child, while Transactions, Markets, News, Swap,
                      // Feedback and Banxa all call these two helpers - which
                      // at phone width are 24 and 6. Measured, the Assets
                      // title used to sit 40px lower and 6px further in than
                      // the Transactions title on the same device.
                      //
                      // The gutter is charged ONCE here now; every child below
                      // sits at 0 and the panels take it from this padding.
                      padding: EdgeInsets.fromLTRB(
                        GeniusBreakpoints.pageGutter(context),
                        GeniusBreakpoints.pageTitleGap(context),
                        GeniusBreakpoints.pageGutter(context),
                        GeniusWalletConsts.space8,
                      ),
                      child: ConstrainedBox(
                        // xxl, unified with Transactions / Markets / News so
                        // the page title lands at the same X on every content
                        // page.
                        constraints: const BoxConstraints(
                          maxWidth: GeniusBreakpoints.xxl,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          mainAxisSize: MainAxisSize.min,
                          children: _pageChildren(context, state, gw),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _pageChildren(
    BuildContext context,
    WalletDetailsState state,
    GWColors gw,
  ) {
    final coins = state.coins;

    // S1, S2 and S3 all require an EMPTY coin list, so "the controls are
    // mounted" reduces to "there is something to search". The load and error
    // branches are gated on `coins.isEmpty` on purpose: a refresh over an
    // already-populated list must never blank the page.
    final bool hasCoins = coins.isNotEmpty;

    final pairs = coins.map(_project).toList()
      ..sort((a, b) => compareAssetsByValue(_ascending, a.row, b.row));
    final visible = pairs
        .where((p) => matchesAssetQuery(_query, p.row))
        .toList();

    return [
      // The page's ONLY title, sitting at the frame's own gutter - the same X
      // `transactions_screen.dart:114` puts "Transactions" at. Mount no
      // `GWSectionTitle` under it or the screen prints "Assets" twice at two
      // sizes, which is the duplicate-title defect flagged on Transactions.
      //
      // NO `GWBackLink` any more (sketch 187 C, 2026-08-08). It read
      // "< HOME" and was written when the only way onto this page was the
      // dashboard panel's `View all`. `/assets` has been the bar's second
      // tab since sketch 182 scheme S7 (`nav_destinations.dart:143`), and a
      // tab has no back: Home is one tap away on the same screen, 5px lower.
      // The sibling tab `/transactions` carries no back link either, so this
      // deletion makes the two agree rather than making Assets unusual.
      // The page's ONLY title. Mount no `GWSectionTitle` under it or the
      // screen prints "Assets" twice at two sizes, which is the
      // duplicate-title defect flagged on Transactions.
      //
      // Its left inset now lives in the COMPONENT
      // (`gwPageHeaderContentInset`), applied 2026-08-08 at Jakub's
      // instruction to every page title rather than to this one - so Assets,
      // Activity, Markets and News all head their content column instead of
      // their container.
      //
      // NO `GWBackLink` any more (sketch 187 C, 2026-08-08). It read
      // "< HOME" and was written when the only way onto this page was the
      // dashboard panel's `View all`. `/assets` has been the bar's second
      // tab since sketch 182 scheme S7 (`nav_destinations.dart:143`), and a
      // tab has no back: Home is one tap away on the same screen, 5px lower.
      // The sibling tab `/transactions` carries no back link either, so this
      // deletion makes the two agree rather than making Assets unusual.
      const GWPageHeader(title: 'Assets'),

      // PANEL 1 - the total. `DashboardScrollContainer` unchanged from the
      // homepage: `GWDecorations.surface`, `radiusLg`, `borderSubtle`, and
      // `space3` of padding at phone width.
      DashboardScrollContainer(child: _totalPanel(state)),
      const SizedBox(height: GeniusWalletConsts.space3),

      // PANEL 2 - the controls and the list. `space3` above it is the gap
      // `OneColumnDashBoardView` puts between every pair of homepage panels,
      // so the two pages share one rhythm.
      DashboardScrollContainer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (hasCoins) ...[
              // Full card width, NO `space4` wall. That is the dashboard's own
              // answer for a full-width child: `coins_screen.dart`'s
              // Receive / Buy GNUS row runs edge to edge inside the panel
              // while `GWSectionTitle` and the rows take the wall. A field is
              // a full-width child; its own border is the edge the eye reads.
              GWSearchField(
                controller: _searchController,
                hint: 'Search assets',
                // Neither callback may trigger a fetch. The query reaches
                // `matchesAssetQuery` and nothing else (threat T-25-02-02).
                onChanged: (value) => setState(() => _query = value),
                onClear: () {
                  _searchController.clear();
                  setState(() => _query = '');
                },
              ),
              const SizedBox(height: GeniusWalletConsts.space6),
              Padding(
                // `space4`, the same wall `GWSectionTitle` charges inside a
                // panel (`gw_section_title.dart:168`) and the same one
                // `kGWRowWall` gives every `CoinCardRow` below, so the count,
                // the sort control and the rows share one left edge.
                padding: const EdgeInsets.symmetric(
                  horizontal: GeniusWalletConsts.space4,
                ),
                // Lower-case: GWKicker upper-cases it itself and its doc
                // forbids callers pre-calling toUpperCase().
                child: GWKicker(
                  visible.length == pairs.length
                      ? '${pairs.length} assets'
                      : '${visible.length} of ${pairs.length} assets',
                  dense: true,
                  trailing: _AssetsSortToggle(
                    ascending: _ascending,
                    onTap: () => setState(() => _ascending = !_ascending),
                  ),
                ),
              ),
              const SizedBox(height: GeniusWalletConsts.space4),
            ],
            ..._body(context, state, gw, pairs: pairs, visible: visible),
          ],
        ),
      ),
    ];
  }

  /// Panel 1's contents: a kicker over the portfolio total.
  ///
  /// [AssetsTotalBand] is the DASHBOARD's band, not a copy of it - promoted out
  /// of `coins_screen.dart` in this same task precisely so the panel and this
  /// page cannot disagree about a number the user reads as one fact. It brings
  /// its own `space4` wall and its own `numericHeadline` 24/32 at w700, so
  /// nothing here restates them.
  ///
  /// A `GWKicker` rather than a `GWSectionTitle`: the page header two widgets
  /// up already says "Assets", and a second title-weight string is the
  /// duplicate-title defect. The kicker is the same 11px dense label panel 2
  /// uses for its count, so the two panels are labelled in one voice.
  Widget _totalPanel(WalletDetailsState state) {
    final double total = assetsTotal(_valueHoldings(state.coins));
    final double dayChange = assetsDayChange(_changeHoldings(state.coins));
    final double pctOfTotal = total == 0 ? 0 : dayChange / total * 100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space4),
          child: GWKicker('total value', dense: true),
        ),
        // `space2` - the title-to-subtitle gap this app already uses between a
        // label and the line it introduces (`coin_card_row.dart:109`).
        const SizedBox(height: GeniusWalletConsts.space2),
        AssetsTotalBand(
          total: total,
          dayChange: dayChange,
          pctOfTotal: pctOfTotal,
        ),
      ],
    );
  }

  /// The five states of D-2. S3 and S4 are structurally different, not just
  /// differently worded: S3 has nothing to search so its controls are not
  /// mounted at all, while S4 keeps them mounted because the query IS the
  /// reason the list is empty and the user needs the field to clear it. S4
  /// offers no CTA - the user is not out of assets, they are out of matches.
  List<Widget> _body(
    BuildContext context,
    WalletDetailsState state,
    GWColors gw, {
    required List<({Coin coin, AssetRowData row})> pairs,
    required List<({Coin coin, AssetRowData row})> visible,
  }) {
    // S1
    if (state.coinsStatus == WalletStatus.loading && state.coins.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: GeniusWalletConsts.space24),
          child: Center(child: Loading()),
        ),
      ];
    }

    // S2
    if (state.coinsStatus == WalletStatus.error && state.coins.isEmpty) {
      return [
        GWErrorState(
          message: 'Failed to load your assets.',
          onRetry: () => context.read<WalletDetailsCubit>().getCoins(),
        ),
      ];
    }

    // S3 - no coins at all. The Receive / Buy GNUS pair is the same recipe
    // `coins_screen.dart:353-389` shows on a valueless wallet: one
    // gradientOutline plus one filled gradient, which is the single filled
    // CTA the weight rule allows on a surface.
    if (state.coins.isEmpty) {
      return [
        const GWEmptyState(
          icon: Icons.account_balance_wallet_outlined,
          title: 'No coins yet',
          message: 'Your holdings will appear here once you receive a token.',
        ),
        Padding(
          // Full card width and `space8` above, byte for byte the recipe the
          // dashboard's own value-empty footer uses (`coins_screen.dart:481`).
          padding: const EdgeInsets.only(top: GeniusWalletConsts.space8),
          child: Row(
            children: [
              Expanded(
                child: GWButton(
                  variant: GWButtonVariant.gradientOutline,
                  size: GWButtonSize.sm,
                  label: 'Receive',
                  expand: true,
                  onPressed: () => _showReceive(state),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Expanded(
                child: GWButton(
                  variant: GWButtonVariant.gradient,
                  size: GWButtonSize.sm,
                  label: 'Buy GNUS',
                  expand: true,
                  onPressed: () =>
                      context.push('/buy', extra: {'origin': 'MARKETS'}),
                ),
              ),
            ],
          ),
        ),
      ];
    }

    // S4 - coins present, the query matches none of them.
    if (visible.isEmpty) {
      return const [
        GWEmptyState(
          icon: Icons.search_off,
          title: 'No assets found',
          message:
              'Nothing matches that search. Clear it to see all your assets.',
        ),
      ];
    }

    // S5 - the rows. A `for` loop, NOT a list or grid widget of any kind: the
    // page's single SingleChildScrollView is the one scroll.
    //
    // ponytail: every row is built eagerly, so a wallet holding hundreds of
    // tokens builds them all. Upgrade path: a CustomScrollView with a sliver
    // list, once that is a real wallet and not a hypothesis.
    final walletCubit = context.read<WalletDetailsCubit>();
    return [
      for (int i = 0; i < visible.length; i++) ...[
        CoinCardRow(
          onTap: () {
            final coin = visible[i].coin;
            // Load-bearing for `/bridge` (`BridgeScreen(fromToken:
            // ...selectedCoin)`) and the Swap preselection fallback. This is
            // the ONE cubit write this page performs.
            walletCubit.selectCoin(coin);
            context.push(
              '/token-info',
              extra: TokenInfoArgs(
                coinGeckoId: coin.coinGeckoId,
                symbol: coin.symbol,
                marketData: _marketData[coin.symbol?.toLowerCase()],
                walletCoin: coin,
                network: state.selectedNetwork?.name,
                originLabel: 'ASSETS',
              ),
            );
          },
          iconPath: visible[i].coin.iconPath ?? '',
          balance: visible[i].coin.balance ?? 0.0,
          name: visible[i].coin.name ?? '',
          symbol: visible[i].coin.symbol ?? '',
          marketData: _marketData[visible[i].coin.symbol?.toLowerCase()],
        ),
        if (i < visible.length - 1)
          Divider(height: 1, thickness: 1, color: gw.borderSubtle),
      ],
    ];
  }
}

/// The one sort control: label `VALUE` plus the CURRENT direction as an arrow
/// (D-4).
///
/// The sketch draws `⇅`. That is a sortABLE hint, not a state - it shows both
/// directions at once and so says nothing about which one is active. This
/// shows the direction the list is actually in, because that is the fact the
/// user needs to read. The glyphs are the same `↑` / `↓` `markets_table.dart`
/// already uses, so the app carries one sort-arrow vocabulary.
///
/// **Three independent channels tell the two states apart:**
///
///  1. **Shape.** `↓` vs `↑`. A shape difference rather than a colour one, so
///     it survives colour blindness and satisfies WCAG 1.4.1 with no second
///     cue.
///  2. **Contrast.** The arrow is painted at `textPrimary` (#FFFFFF, 19.4:1 on
///     `surfaceBase` #0B0D12) because the arrow IS the state indicator and a
///     state indicator should be the loudest thing in its control. The label
///     stays at `textSecondary` (#8A8F9D, 6.01:1 - the same figure
///     `coin_card_row.dart:145-147` records for this token on this canvas).
///     `textPrimary` is also the only one of the candidates that passes in
///     BOTH themes (14.0:1 as #10131A on the light canvas #DCE0E6), so this
///     control needs nothing from the light pass.
///  3. **Semantics.** A glyph-only direction is invisible to VoiceOver, and
///     Jakub reviews on an iPhone.
///
/// A gradient arrow was the runner-up and was rejected on meaning, not on
/// contrast: in `markets_table` the gradient distinguishes ONE active key from
/// six inactive ones, whereas here there is exactly one key and it is
/// permanently active, so the gradient would carry no information. Adopt it
/// the day a second sort key arrives. Raw `GeniusWalletGradient.brandCta` as
/// the shader was rejected outright: its stops measure 1.40:1 and 1.95:1 on
/// the light canvas.
class _AssetsSortToggle extends StatelessWidget {
  const _AssetsSortToggle({required this.ascending, required this.onTap});

  final bool ascending;
  final VoidCallback onTap;

  /// Material's own minimum touch target. `GWKicker`'s dense line box is 16pt
  /// tall, so the label alone is nowhere near it.
  ///
  /// A named constant rather than a `space*` token deliberately: 48 lands on
  /// the 4-pt grid, but it measures a TARGET, not a gap, and the spacing
  /// tokens are for gaps. `GWTextField`'s `leadingIcon` gutter names the same
  /// 48x48 box for the same reason.
  static const double _minTapTarget = 48;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final style = GWKicker.style(gw, dense: true);

    return InkWell(
      onTap: onTap,
      // Matches markets_table's own sort header. The element must not change
      // size under the cursor - `gw_back_link.dart` states that rule for
      // interactive chrome. Desktop only; iOS is the review surface.
      borderRadius: BorderRadius.circular(6),
      child: Semantics(
        button: true,
        // excludeSemantics: the raw children announce "VALUE ↓", which tells a
        // screen-reader user nothing about the direction. This replaces that
        // with the sentence. The InkWell above still contributes the tap
        // action, so the control stays activatable.
        excludeSemantics: true,
        label: ascending
            ? 'Sort by value, lowest first'
            : 'Sort by value, highest first',
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            minWidth: _minTapTarget,
            minHeight: _minTapTarget,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('VALUE', style: style),
              Text(
                ascending ? ' ↑' : ' ↓',
                style: style.copyWith(color: gw.textPrimary),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
