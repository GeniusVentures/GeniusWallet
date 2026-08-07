import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/cards/gw_view_all_link.dart';
import 'package:genius_wallet/components/coins/assets_totals.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/qr/crypto_address_qr.dart';
import 'package:genius_wallet/dashboard/assets/assets_sort.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/services/coin_gecko/coin_gecko_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/tokens/token_info_args.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// How many rows the DASHBOARD Assets panel renders (phase 25). The rest live
/// behind the panel's `View all`, on `/assets`.
///
/// Dashboard only: a coin PICKER reuse (`onCoinSelected != null`) still gets
/// the whole wallet, because picking from a truncated list is not a preview,
/// it is a missing coin.
const int kDashboardAssetsCap = 5;

class CoinsScreen extends StatefulWidget {
  final Function(Coin)? onCoinSelected;
  final List<Coin?>? filterCoins;
  final bool? isUseDivider;

  const CoinsScreen({
    super.key,
    this.onCoinSelected,
    this.filterCoins,
    this.isUseDivider,
  });

  @override
  CoinsScreenState createState() => CoinsScreenState();
}

class CoinsScreenState extends State<CoinsScreen> {
  Map<String, CoinGeckoMarketData?> _marketData = {};
  bool _isFetchingMarketData = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();

    // periodically fetch market data to keep wallet balance up to date
    _refreshTimer = Timer.periodic(const Duration(minutes: 1), (timer) {
      final state = context.read<WalletDetailsCubit>().state;
      if (state.coinsStatus == WalletStatus.successful &&
          state.coins.isNotEmpty) {
        _fetchMarketData(state.coins);
      }
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchMarketData(List<Coin> coins) async {
    // DEV-ONLY: while mock-mode is ON, skip the network entirely and feed
    // rows the seeded offline prices instead. This also no-ops the 1-min
    // refresh timer and the BlocListener's successful-branch fetch, and
    // skips _calculateTotalValue (the balance is already set by
    // injectMockCoins).
    if (kDebugMode && context.read<WalletDetailsCubit>().mockMode) {
      setState(() {
        _marketData = DevMockHoldings.instance.marketData;
        _isFetchingMarketData = false;
      });
      return;
    }

    if (_isFetchingMarketData || coins.isEmpty) {
      return;
    }
    setState(() => _isFetchingMarketData = true);

    final coinGeckoCoinsList = await fetchAllCoinGeckoCoins();

    final List<String> coinGeckoIds = coins
        .map((walletCoin) {
          // if there is a coin gecko id set use that instead of trying to match ( trying to match can have issues as symbols are not unique and the names may not match )
          if (walletCoin.coinGeckoId != null) {
            return walletCoin.coinGeckoId!;
          }
          final matchingCoin = coinGeckoCoinsList.firstWhere(
            (coin) =>
                coin.symbol.toLowerCase() == walletCoin.symbol?.toLowerCase(),
            orElse: () =>
                CoinGeckoCoin(id: '', symbol: '', name: 'Unknown Token'),
          );
          return matchingCoin.id.isNotEmpty ? matchingCoin.id : null;
        })
        .whereType<String>()
        .toList();

    if (coinGeckoIds.isNotEmpty) {
      final marketData = await fetchCoinsMarketData(coinIds: coinGeckoIds);

      if (!mounted) {
        return;
      }

      setState(() {
        _marketData = marketData;
        _isFetchingMarketData = false;
      });

      _calculateTotalValue(coins);
    } else {
      setState(() => _isFetchingMarketData = false);
    }
  }

  void _calculateTotalValue(List<Coin> coins) {
    final totalValue = assetsTotal(_valueHoldings(coins));
    final formattedTotal = totalValue.toStringAsFixed(2);

    context.read<WalletDetailsCubit>().setSelectedWalletBalance(formattedTotal);
  }

  /// Builds the (balance, price) records the totals helper folds over, keyed
  /// by `coin.symbol?.toLowerCase()` - the same key `_fetchMarketData` writes.
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

  /// The pct-carrying variant used by the header's 24h-change subline.
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

  /// Opens the address-QR receive drawer for the empty-wallet footer.
  ///
  /// ponytail: there is no dedicated `/receive` route in router.dart - the
  /// receive UI is the reusable [CryptoAddressQR] shown in a [ResponsiveDrawer].
  /// Ceiling: no send-flow deep-link / amount request. Upgrade path: a proper
  /// `/receive` screen if receive grows beyond "show my address".
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
          final walletCubit = context.read<WalletDetailsCubit>();

          // Fail-soft read: registers the InheritedWidget dependency that
          // forces this subtree to rebuild on a live appearance toggle.
          final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

          if (state.coinsStatus == WalletStatus.loading) {
            return Container(
              decoration: GWDecorations.surface(border: gw.borderSubtle),
              child: const Center(child: Loading()),
            );
          }

          if (state.coins.isEmpty) {
            return const GWEmptyState(
              icon: Icons.account_balance_wallet_outlined,
              title: 'No coins yet',
              message:
                  'Your holdings will appear here once you receive a token.',
            );
          }

          final filteredCoins = state.coins
              .where(
                (coin) =>
                    widget.filterCoins?.contains(coin) == false ||
                    widget.filterCoins == null,
              )
              .toList();

          // Dashboard-only chrome (header + empty-wallet footer) AND the top-5
          // cap. A future coin-picker reuse passes onCoinSelected and gets the
          // bare, uncapped list.
          final bool isDashboard = widget.onCoinSelected == null;

          // Display order: `compareAssetsByValue`, the SHARED authority the
          // `/assets` page sorts by (`assets_sort.dart`, phase 25-02). Descending
          // (`ascending: false`) is that page's default, so the panel's top 5 is
          // literally the head of the page's list - the two surfaces cannot
          // disagree about which coins are "the top 5" or what order they come
          // in, which is the defect a widget-local sort here would guarantee.
          //
          // It REPLACES the old GNUS-first partition, and that is a real change
          // worth naming: GNUS is no longer pinned absolutely, it wins as a
          // TIE-BREAK among equal-ranking rows (step 4 of the comparator). In a
          // wallet where every balance is zero - Jakub's - every priced row ties
          // at value 0 and GNUS is still first. In a funded wallet a larger
          // holding now outranks it. Consistency with `/assets` is what bought
          // that; the comparator is the one place to change it if it is wrong.
          //
          // The (coin, row) PAIR rather than sorting bare `AssetRowData` and
          // looking the coin back up by symbol: a wallet may legitimately hold
          // two entries with the same symbol on different networks, and a
          // symbol-keyed lookup would hand both rows the same coin. Same shape
          // `assets_screen.dart:_project` builds.
          //
          // ponytail: that projection is duplicated here rather than shared -
          // `assets_sort.dart` is Flutter-free by design and knows nothing about
          // `Coin`, and the two plans in this phase were fenced from each other's
          // files. Ceiling: the two can drift. Upgrade path now that both have
          // landed: one `assetRowFor(Coin, CoinGeckoMarketData?)` beside the
          // comparator, and delete both copies.
          final pairs = filteredCoins.map(
            (coin) {
              final data = _marketData[coin.symbol?.toLowerCase()];
              return (
                coin: coin,
                row: AssetRowData(
                  name: coin.name ?? '',
                  symbol: coin.symbol ?? '',
                  balance: coin.balance ?? 0.0,
                  price: data?.currentPrice ?? 0.0,
                  // The ABSENCE of a map entry is the "no market data"
                  // signal, and it must never be flattened into a price of
                  // zero on the way in (T-25-01): a coin the feed has never
                  // heard of and a coin quoting 0.00 rank in different tiers.
                  hasMarketData: data != null,
                ),
              );
            },
          ).toList()..sort((a, b) => compareAssetsByValue(false, a.row, b.row));

          final orderedCoins = [
            for (final pair
                in isDashboard ? pairs.take(kDashboardAssetsCap) : pairs)
              pair.coin,
          ];

          final double total = assetsTotal(_valueHoldings(state.coins));
          final double dayChange = assetsDayChange(
            _changeHoldings(state.coins),
          );
          final double pctOfTotal = total == 0 ? 0 : dayChange / total * 100;

          return SingleChildScrollView(
            child: Column(
              children: [
                // Assets header - sketch 178 SCHEME A, 2026-08-07. This is a
                // REVERT of scheme C, which shipped earlier the same day and
                // which Jakub rejected on the phone hours later:
                //
                //   The Assets section on the dashboard looks fine in itself,
                //   but Assets was supposed to respect the SAME component -
                //   the same colour and everything - as Transactions, as
                //   Compute, as Markets. So that has to change.
                //
                // Scheme C demoted the word Assets to an 11px uppercase
                // secondary kicker and gave the big type to the number. The
                // cost was recorded in this very comment at the time: Markets,
                // Transactions and Compute all name themselves in 18px white
                // `titleLg` and Assets stopped matching. That recorded cost is
                // exactly what he objected to, and the fallback named there,
                // scheme A, is what is built below. So: the title goes back to
                // the plain `String` path every other section uses, and the
                // total moves to a band of its own directly beneath it.
                //
                // MEASURED COST: +48px of panel header (46 -> 94), pinned by
                // `assets_header_scheme_a_test.dart` from the exported
                // constants. That is 4 less than the sketch's 52, for two
                // reasons stated at their own sites below: no spacer under the
                // band, and the total at 24 rather than an untokened 28.
                //
                // The desktop consequence, since this file is ONE file for both
                // surfaces and `ContributionsDashboardView` mounts it there
                // too: the desktop Assets panel grows the same 48px, inside a
                // slot whose `SingleChildScrollView` absorbs it. Nothing
                // overflows; roughly one row scrolls out of first view. Do NOT
                // fork this header by breakpoint to avoid that. Two different
                // Assets headers in one app is the inconsistency he is
                // complaining about, relocated.
                //
                // THE RENDERED TITLE GAP, with its whole history, because the
                // number he approved is not the number that has been shipping:
                //
                //   before scheme C   slack 10, pad  0, C=20  ->  R2 = 30
                //   scheme C          slack  0, pad  0, C=20  ->  R2 = 20
                //   scheme A (here)   slack 10, pad 16, C= 0  ->  R2 = 26
                //
                // He approved 30 on 2026-08-06. Scheme C's two-line block ate
                // the whole 44px reservation, so there was no centring slack
                // left and the rendered gap silently became 20. Scheme A moves
                // it to 26, which is the value every other panel renders. It is
                // a move back TOWARD what he approved, not away from it, and it
                // is named at the checkpoint rather than slipped through.
                //
                // A DOC DEBT this task cannot pay: `gw_section_title_rhythm_test.dart`
                // is byte-pinned by this task (its md5 is a gate), and its
                // library doc table lists Assets at `C=20 / R2=30` while its
                // `ROW INSET - CoinCardRow (Assets)` case labels its output as
                // the Assets gap. Both describe the pre-scheme-A panel and are
                // now stale. The ASSERTIONS there stay correct and green -
                // `CoinCardRow` really does bring more inset than the pad can
                // absorb - so this is documentation debt, recorded here, to be
                // paid in a docs-only pass.
                //
                // The value-empty footer's `if (isDashboard && total == 0)`
                // branch further down is untouched by all of this, and
                // `state.coins.isEmpty` still returns a `GWEmptyState` above
                // this header, so the band never renders against no data.
                if (isDashboard) ...[
                  GWSectionTitle(
                    // The plain `String` path, the same one Markets,
                    // Transactions, Compute and the four news sections take.
                    // That identity IS the change: one component, one size, one
                    // colour, one position across all four dashboard sections.
                    title: 'Assets',
                    // `contentTopInset` is DELIBERATELY absent, and the default
                    // 0 is correct rather than merely accepted.
                    //
                    // The parameter is a MEASURED description of the first
                    // widget under the title. Until now that widget was a
                    // `CoinCardRow`, whose `ListTile` snaps to a default tile
                    // height and centres its content, putting its first painted
                    // pixel ~20px below its own layout box. Hence the 20 that
                    // used to sit here.
                    //
                    // After this change the first widget under the title is the
                    // total band, which paints at its own top pixel and has no
                    // slack of its own. Leaving the 20 behind would spend the
                    // component's bottom pad against slack that is no longer
                    // there and render a 30px gap under a band that cannot
                    // absorb it, re-breaking the rhythm the component exists to
                    // hold. The 20 has not vanished; it moved one widget
                    // further down, where nothing needs to declare it.
                    //
                    // `go`, not `push` - `/assets` IS a bottom-nav destination
                    // as of sketch 182 scheme S7 (2026-08-07). The premise that
                    // justified `push` here was that Assets was a content page
                    // with no tab, and S7 falsified it by giving Assets the
                    // bar's second slot. Two entrances to one route with
                    // different back behaviour reads as randomness, so this one
                    // now matches the tab. The precedent is already in the
                    // tree: `transactions_slim_view.dart:363` makes exactly
                    // this call for `/transactions`, with exactly this reason.
                    //
                    // What it gives up, stated because it is a real trade and
                    // the same one `/transactions` already made: `go` replaces
                    // the dashboard rather than stacking on it, so the
                    // dashboard is disposed and its market-data refresh timer
                    // is torn down and re-armed on the way back.
                    //
                    // There is no guard for "the section is short": a link that
                    // appears and disappears as balances move reads as a bug,
                    // and `/assets` is a full view with a search and a sort even
                    // when it lists three rows.
                    trailing: GWViewAllLink(onTap: () => context.go('/assets')),
                  ),
                  _AssetsTotalBand(
                    total: total,
                    dayChange: dayChange,
                    pctOfTotal: pctOfTotal,
                  ),
                ],
                // NO spacer between the band and the first `CoinCardRow`, and
                // that absence is a decision. The row's own ~20px ListTile
                // centring snap IS the gap, and it is byte-for-byte the
                // total-to-first-row relationship that shipped under scheme C.
                // The sketch drew 14px here; adding it would render 34 below
                // the band against 26 above it and read bottom-heavy. Do not
                // add it later.
                for (int i = 0; i < orderedCoins.length; i++) ...[
                  CoinCardRow(
                    onTap: () {
                      final coin = orderedCoins[i];
                      if (widget.onCoinSelected != null) {
                        widget.onCoinSelected!(coin);
                      } else {
                        // Still load-bearing for `/bridge`
                        // (`BridgeScreen(fromToken: ...selectedCoin)`,
                        // `router.dart`) and the Swap preselection fallback -
                        // this selection is a WALLET action, unrelated to the
                        // coin-page payload below.
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
                      }
                    },
                    iconPath: orderedCoins[i].iconPath ?? "",
                    balance: orderedCoins[i].balance ?? 0.0,
                    name: orderedCoins[i].name ?? "",
                    symbol: orderedCoins[i].symbol ?? "",
                    marketData:
                        _marketData[orderedCoins[i].symbol?.toLowerCase()],
                  ),
                  if ((isDashboard || (widget.isUseDivider ?? false)) &&
                      i < orderedCoins.length - 1)
                    Divider(height: 1, thickness: 1, color: gw.borderSubtle),
                ],
                // Value-empty footer: the truly-no-coins case is handled above
                // by the state.coins.isEmpty -> GWEmptyState branch; this strip
                // covers a wallet that HAS coins but holds no value (total==0).
                if (isDashboard && total == 0)
                  Padding(
                    // top space8 mirrors the header's bottom space8 so the gap
                    // above the CTAs matches the Assets→first-row gap.
                    padding: const EdgeInsets.only(
                      top: GeniusWalletConsts.space8,
                    ),
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
                            // Full brand-CTA gradient (#0AD89C→#0AAEE6) - the
                            // GNUS-logo gradient the walk picked, replacing the
                            // flat neon #14C8FF primary fill.
                            variant: GWButtonVariant.gradient,
                            size: GWButtonSize.sm,
                            label: 'Buy GNUS',
                            expand: true,
                            onPressed: () => context.push(
                              '/buy',
                              extra: {'origin': 'MARKETS'},
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

/// The portfolio total, in a full-width band of its own directly under the
/// Assets section title. Sketch 178 scheme A, 2026-08-07.
///
/// A `StatelessWidget` rather than a `_buildBand()` helper, per AGENTS.md: it
/// gets its own element, its own rebuild boundary and its own type for a
/// finder to name.
class _AssetsTotalBand extends StatelessWidget {
  const _AssetsTotalBand({
    required this.total,
    required this.dayChange,
    required this.pctOfTotal,
  });

  final double total;
  final double dayChange;
  final double pctOfTotal;

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this subtree to rebuild on a live appearance toggle.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final currencyFormatter = NumberFormat.currency(symbol: "\$");

    return Padding(
      // LOAD-BEARING, and the reason is structural: this band is a SIBLING of
      // `GWSectionTitle` in the parent Column, not a child of it, so it does
      // not inherit the title's own `space4` horizontal inset. Without this
      // padding the total hangs 8px to the left of the word Assets, which is
      // the one alignment the whole change is about.
      padding: const EdgeInsets.symmetric(
        horizontal: GeniusWalletConsts.space4,
      ),
      child: Row(
        // CENTRE, not `baseline`. Jakub, 2026-08-07: "zmiana procentowa nie
        // jest wysrodkowana [...] chcialbym aby znajdowala sie na samym jej
        // srodku [...] troszeczke podniesiona do gory."
        //
        // Baseline alignment WAS the defect. It pins a 13px label's baseline
        // to a 24px number's baseline, so the label's figure body - which is
        // ~9.5 tall against the total's ~18 - hangs off the bottom of the
        // total's mass instead of sitting across its middle. Measured on real
        // Inter by pixel-scanning the painted ink (see the OPTICAL CENTRING
        // case in `assets_header_scheme_a_test.dart`): the percentage's figure
        // centre sat 4.13px BELOW the total's. `end` is worse at 5.63.
        //
        // `center` matches the two LINE BOXES' centres, and because both
        // children draw the same face at the same ascent:descent ratio, their
        // figure bodies land on the same centre too: measured residual 0.13px,
        // which is 0.39 of a device pixel at 3x. That is why there is no nudge
        // token here and must not be one - a hand-tuned offset would be a
        // literal standing in for a residual too small to see.
        //
        // Costs no height. `center` sizes the Row to max(32, 18) = 32, the
        // same 32 baseline alignment produced, so the 94px header holds.
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            currencyFormatter.format(total),
            // `numericHeadline` AS SHIPPED (24 / 32), with no `height`
            // override. Scheme C carried `height: 28 / 24` here and that
            // override was never a styling choice: it existed solely to make a
            // two-line block consume `GWSectionTitle`'s 44px reservation
            // exactly. There is no reservation to squeeze into any more, so
            // outside it the override is a bug rather than a feature - it would
            // only tighten this band's line box for no reason.
            //
            // 24 rather than the sketch's 28 for the same reason the band costs
            // 32 and not 36: there is no 28px token, and 28/32 and 24/32 have
            // the SAME 32px line box, so the on-token size is free.
            style: GeniusWalletTypography.numericHeadline.copyWith(
              fontWeight: FontWeight.w700,
              color: gw.textPrimary,
            ),
          ),
          // Guarded exactly as scheme C guarded it. The percentage's 18px line
          // box is shorter than the total's 32, and `center` sizes the Row to
          // the taller child, so this branch adds and removes WIDTH, never
          // height: the band measures 32 in both the funded and the all-zero
          // state. That was true under baseline alignment too and it survives
          // the switch, which is the reason the switch was safe to make.
          //
          // PERCENT ONLY here, still. The band has room for the dollar figure
          // the pre-2026-08-07 header carried (measured: it fits with 15.73px
          // to spare at `$1,234,567.89`), and restoring it is a named
          // follow-up, held back only so it does not confound the review of
          // the title treatment this change is actually for.
          if (total > 0) ...[
            const SizedBox(width: GeniusWalletConsts.space4),
            Text(
              '${dayChange >= 0 ? '+' : ''}${pctOfTotal.toStringAsFixed(2)}%',
              style: GeniusWalletTypography.labelMd.copyWith(
                color: dayChange >= 0 ? gw.statusSuccess : gw.statusError,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
