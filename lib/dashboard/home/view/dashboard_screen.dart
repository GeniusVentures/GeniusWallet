// kDebugMode is required for the dev-only markets-fault listener gate in
// _MarketsDashboardViewState below. See app_bloc.dart:5-10 for why this is
// an explicit foundation.dart import rather than relying on material.dart.
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/chart/crypto_live_chart.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/gw_timeframe_segment.dart';
import 'package:genius_wallet/components/wallet_overview.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets.dart';
import 'package:genius_wallet/dashboard/chart/dashboard_markets_util.dart';
import 'package:genius_wallet/dashboard/transactions/sgnus_transactions_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/dev/dev_fault_injector.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/hive/models/coin_gecko_coin.dart';
import 'package:genius_wallet/screens/loading_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// The fixed height of the Overview (Compute) and Contributions panel slots,
/// in both the one- and two-column layouts.
///
/// **Raised 300 -> 340 on 2026-07-31 (Jakub).** The Compute panel's title was
/// a `GWKicker` (18px line box, no padding of its own) while Assets, Markets,
/// Transactions and the Bitcoin chart all use `GWSectionTitle`, which reserves
/// a 44px header and owns a `space8` bottom gap. That left Balance starting
/// ~38px higher than the first Assets coin: 2+44+16 there against 18+6 here.
/// Adopting the shared title costs those 38px, and the old 300 slot had no
/// room for them - the panel would have gone quietly scrollable inside its own
/// box (it sits in a `SingleChildScrollView`, so it never throws an overflow),
/// pushing the CTA below the fold and re-opening the "vanishing primary
/// action" bug plan 14-08 had just closed.
///
/// The two-column layout constrains Overview and Contributions as ONE row
/// (`_OverviewContributionsRow`), so they cannot differ there; the one-column
/// sites use the same constant so the two layouts stay in agreement.
///
/// `test/dashboard/compute_panel_height_test.dart` derives the panel's own
/// content budget from this number and asserts every state against it.
const double kDashboardPanelSlotHeight = 340;

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => DashboardScreenState();
}

class DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();

    // Delay execution until after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final walletCubit = context.read<WalletDetailsCubit>();

      if (walletCubit.state.selectedWallet != null &&
          walletCubit.state.selectedNetwork != null) {
        walletCubit.getCoins();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        fit: StackFit.expand,
        children: [
          BlocBuilder<AppBloc, AppState>(
            builder: (context, state) {
              final isDesktopLayout =
                  MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium;

              if (state.subscribeToWalletStatus == AppStatus.loaded &&
                  state.accountStatus == AppStatus.loaded) {
                if (isDesktopLayout) {
                  return const ResponsiveDashboardView();
                }
                return const OneColumnDashBoardView();
              }
              if (state.subscribeToWalletStatus == AppStatus.error ||
                  state.accountStatus == AppStatus.error) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('Something went wrong!'),
                      const SizedBox(height: GeniusWalletConsts.space6),
                      GWButton(
                        onPressed: () => _onRetry(context),
                        label: 'Retry',
                        variant: GWButtonVariant.primary,
                        leading: const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                );
              }

              return const LoadingScreen();
            },
          ),
        ],
      ),
    );
  }
}

/// Re-drives both dashboard load legs (pull-to-refresh and the failure-branch
/// Retry button share this one definition). Hoisted to file scope from
/// [OneColumnDashBoardView] (Dart's privacy unit is the library, so a
/// `_`-prefixed top-level function is reachable from every caller in this
/// file) so the two callers can never dispatch diverging reload logic.
Future<void> _onRefresh(BuildContext context) async {
  final walletCubit = context.read<WalletDetailsCubit>();
  context.read<AppBloc>().add(LoadWallets());
  if (walletCubit.state.selectedWallet != null &&
      walletCubit.state.selectedNetwork != null) {
    walletCubit.getCoins();
  }
}

/// Retry helper for the dashboard failure branch. Dispatches [FetchAccount]
/// in addition to the shared [_onRefresh] reload: `accountStatus` is written
/// ONLY by `_onFetchAccount` (app_bloc.dart:164/168/170), while
/// `_onLoadWallets` writes only `subscribeToWalletStatus` and never touches
/// `accountStatus`. Without this extra dispatch, a retry built on
/// `_onRefresh` alone could never clear an account-load failure -- the button
/// would visibly do nothing on the only leg currently reachable in shipped
/// code. Do not simplify this back down to a single dispatch.
Future<void> _onRetry(BuildContext context) async {
  final appBloc = context.read<AppBloc>();
  appBloc.add(FetchAccount());
  await _onRefresh(context);
}

class ResponsiveDashboardView extends StatelessWidget {
  const ResponsiveDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final is3Column = constraints.maxWidth > GeniusBreakpoints.xxl;

        if (is3Column) {
          return _threeColumnLayout();
        }
        return _twoColumnLayout();
      },
    );
  }

  Widget _threeColumnLayout() {
    // Tracks the slot constant rather than repeating 300: this row holds the
    // same `_OverviewContributionsRow` the other two layouts cap, and it is a
    // FLOOR here (the row sits in an `Expanded`, so a tall window gives it
    // more). Left at 300 it would be the one layout where the Compute panel
    // can still be handed less height than its content needs, which on a short
    // window pushes the CTA below the fold - the bug 14-08 closed.
    const topRowMinHeight = kDashboardPanelSlotHeight;
    const bottomRowMinHeight = 380.0;
    const totalMinHeight = topRowMinHeight + bottomRowMinHeight;

    return Padding(
      padding: const EdgeInsets.all(GeniusWalletConsts.space3),
      child: Row(
        spacing: GeniusWalletConsts.space3,
        children: [
          // 2 (not 3) against the Transactions column's flex 1: at 1920px that
          // moves the split from 1426/476 to 1268/634, buying the transactions
          // list the width sketch 029's Status + Fee columns need. The four
          // panels here give up 63-95px each; their internal ratios are
          // untouched. Sketch 038.
          Expanded(
            flex: 2,
            child: Column(
              spacing: GeniusWalletConsts.space3,
              children: [
                Expanded(
                  flex: 45,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: topRowMinHeight,
                    ),
                    child: const _OverviewContributionsRow(),
                  ),
                ),
                Expanded(
                  flex: 55,
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(
                      minHeight: bottomRowMinHeight,
                    ),
                    child: const _ChartMarketsRow(),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
                minHeight: totalMinHeight,
              ),
              child: const TransactionsDashboardView(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _twoColumnLayout() {
    return Padding(
      padding: const EdgeInsets.all(GeniusWalletConsts.space3),
      child: Column(
        spacing: GeniusWalletConsts.space3,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: kDashboardPanelSlotHeight,
            ),
            child: const _OverviewContributionsRow(),
          ),
          const Expanded(
            child: Row(
              spacing: GeniusWalletConsts.space3,
              children: [
                Expanded(
                  child: Column(
                    spacing: GeniusWalletConsts.space3,
                    children: [
                      Expanded(child: ChartDashboardView()),
                      Expanded(child: MarketsDashboardView()),
                    ],
                  ),
                ),
                Expanded(child: TransactionsDashboardView()),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OverviewContributionsRow extends StatelessWidget {
  const _OverviewContributionsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: GeniusWalletConsts.space3,
      children: [
        // OverviewDashboardView (wallet + processing) STAYS top-left at every
        // width — that is its location, confirmed by Jakub 2026-07-25. Do not
        // reorder this row to chase seam alignment; use _ChartMarketsRow for
        // that instead, which owns no fixed-position panel.
        Expanded(flex: 2, child: OverviewDashboardView()),
        Expanded(
          flex: 3,
          child: SizedBox.expand(child: ContributionsDashboardView()),
        ),
      ],
    );
  }
}

class _ChartMarketsRow extends StatelessWidget {
  const _ChartMarketsRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      spacing: GeniusWalletConsts.space3,
      children: [
        // Chart leads, Markets trails. The seam-alignment reorder (sketch 038
        // A2 — Markets first, so both rows split 40/60) was built and walked
        // live on 2026-07-25 and REJECTED: aligned seams were not worth moving
        // the chart off the left edge. The 40/60-then-60/40 zigzag is a
        // deliberate, sighted trade, not an oversight. Do not re-propose it.
        Expanded(flex: 3, child: ChartDashboardView()),
        Expanded(flex: 2, child: MarketsDashboardView()),
      ],
    );
  }
}

class OneColumnDashBoardView extends StatelessWidget {
  const OneColumnDashBoardView({super.key});

  @override
  Widget build(BuildContext context) {
    const spacing = SizedBox(height: GeniusWalletConsts.space3);

    return RefreshIndicator(
      onRefresh: () => _onRefresh(context),
      child: ListView(
        padding: const EdgeInsets.all(GeniusWalletConsts.space3),
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: kDashboardPanelSlotHeight,
            ),
            child: const OverviewDashboardView(),
          ),
          spacing,
          ConstrainedBox(
            constraints: const BoxConstraints(
              maxHeight: kDashboardPanelSlotHeight,
            ),
            child: const ContributionsDashboardView(),
          ),
          spacing,
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: const ChartDashboardView(),
          ),
          spacing,
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 350),
            child: const MarketsDashboardView(),
          ),
          spacing,
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400),
            child: const TransactionsDashboardView(),
          ),
        ],
      ),
    );
  }
}

class DashboardScrollContainer extends StatelessWidget {
  final Widget child;
  const DashboardScrollContainer({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    // Fail-soft GWColors read: this container is const-constructed at all five
    // dashboard call sites, so without a Theme dependency Element.updateChild
    // short-circuits on the identical const child and the surface renders
    // stale after an in-place appearance toggle. Reading the extension here
    // registers that dependency, which forces build() to re-run — and
    // GWDecorations.surface recomputes its appearance-aware sheen on that
    // rebuild (04-04 mechanism).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Container(
      decoration: GWDecorations.surface(
        radius: GeniusWalletConsts.radiusLg,
        border: gw.borderSubtle,
      ),
      child: Padding(
        padding: const EdgeInsets.all(GeniusWalletConsts.space6),
        child: child,
      ),
    );
  }
}

class OverviewDashboardView extends StatelessWidget {
  const OverviewDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScrollContainer(
      child: BlocBuilder<AppBloc, AppState>(
        builder: (context, state) {
          return WalletsOverview(
            geniusApi: context.read<GeniusApi>(),
            account: state.account,
          );
        },
      ),
    );
  }
}

class TransactionsDashboardView extends StatelessWidget {
  const TransactionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return DashboardScrollContainer(
      child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
        builder: (context, walletState) {
          final selectedWallet = walletState.selectedWallet;
          final isSgnusWallet = selectedWallet?.walletType == WalletType.sgnus;

          return isSgnusWallet
              ? const SgnusTransactionsScreen()
              : const TransactionsStream();
        },
      ),
    );
  }
}

class MarketsDashboardView extends StatefulWidget {
  const MarketsDashboardView({super.key});

  @override
  State<MarketsDashboardView> createState() => _MarketsDashboardViewState();
}

class _MarketsDashboardViewState extends State<MarketsDashboardView> {
  late Future<List<CoinGeckoCoin>> _marketFuture;

  @override
  void initState() {
    super.initState();
    _marketFuture = getDashboardMarketCoins();
    // DEV-ONLY, release-safe: kDebugMode and kShowDevTools both lead this
    // guard as compile-time const bools, so in a release build (or any
    // debug build without the GW_DEV_TOOLS define) this whole block
    // constant-folds to false and _onMarketsFaultChanged is never
    // registered — byte-for-byte HEAD's behavior otherwise. Registered
    // here (not read inline in build()) because DevFaultInjector.
    // instance.marketsFault is armed/disarmed from the dev-tools bubble, a
    // sibling widget with no shared Bloc/Cubit to dispatch an event
    // through the way the account fault and SGNUS fixture do — see
    // dev_fault_injector.dart's DevFaultInjector.marketsFault docs for the
    // full reasoning.
    if (kDebugMode && kShowDevTools) {
      DevFaultInjector.instance.marketsFault.addListener(
        _onMarketsFaultChanged,
      );
    }
  }

  // DEV-ONLY: re-runs the real fetch (through getDashboardMarketCoins(),
  // which reads the armed/disarmed override itself) whenever the dev
  // bubble arms or disarms a markets fault, so the panel updates
  // immediately without requiring a manual Retry press or a route
  // remount. See the listener registration above and
  // dev_fault_injector.dart's DevFaultInjector.marketsFault docs.
  void _onMarketsFaultChanged() {
    setState(() {
      _marketFuture = getDashboardMarketCoins();
    });
  }

  @override
  void dispose() {
    // DEV-ONLY, release-safe: mirrors the initState guard above — this
    // constant-folds away in release builds, so removeListener is never
    // called on a listener that was never added, and this dispose() body
    // is otherwise the trivial override it would be without any of this.
    if (kDebugMode && kShowDevTools) {
      DevFaultInjector.instance.marketsFault.removeListener(
        _onMarketsFaultChanged,
      );
    }
    super.dispose();
  }

  void _retry() {
    setState(() {
      _marketFuture = getDashboardMarketCoins();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureStateWidget<List<CoinGeckoCoin>>(
      future: _marketFuture,
      // onRetry deliberately NOT passed here (05-08 Task 3, Edit C — a
      // required structural deviation, not a pure container swap).
      // FutureStateWidget (custom_future_builder.dart:35-56) renders its
      // error path as Center > Column [error, if (onRetry != null)
      // SizedBox(12) + GWButton('Retry')] -- it appends its OWN Retry as a
      // SIBLING of whatever `error:` returns. Passing onRetry here as well
      // would leave the card below containing only the message, with a
      // second, naked Retry button underneath it. The retry moves INSIDE
      // GWErrorState instead (same callback, same chrome --
      // gw_error_state.dart:62-69 builds the identical primary GWButton
      // with a refresh icon and the same 'Retry' label), so exactly one
      // Retry exists, and it is inside the card. Do not "restore" this
      // argument in a later sweep -- that silently reintroduces the second
      // button.
      error: DashboardScrollContainer(
        // GWErrorState is NOT adaptive -- e3r (2e82ec2) gave the compact
        // tier to GWEmptyState only -- so with a retry it needs roughly
        // 224px (24+24 padding + 72 circle + 16+24 title + 16+48 button).
        // The two-column dashboard hands this panel Expanded space that
        // lands near 114px at an ordinary window height, beneath a 300px
        // overview row, so this content needs the same scroll-safe wrapper
        // Task 2 introduced for wallet_overview.dart, or closing this skin
        // gap would open a fresh RenderFlex overflow in the same commit.
        child: _MarketsErrorScrollSafe(
          child: GWErrorState(
            // Develop's string, byte-for-byte (UI-SPEC §6) -- a
            // container/skin fix, NOT a copy change. Do not let
            // GWErrorState's own default title ('Something went wrong')
            // appear, and do not reword this string toward it.
            title: "Failed to load market coins",
            onRetry: _retry,
          ),
        ),
      ),
      onData: (coins) {
        if (coins.isEmpty) {
          // Deliberately NOT wrapped in _MarketsErrorScrollSafe, unlike the
          // error branch above -- and that asymmetry is correct, not an
          // inconsistency. GWEmptyState became adaptive in quick 260721-e3r
          // (2e82ec2): it selects its own compact tier from a FINITE
          // constraints.maxHeight. Wrapping it in a scroll view would hand
          // its internal LayoutBuilder an infinite maxHeight, permanently
          // disabling that compact tier and forcing a ~192px full layout
          // into a ~114px card -- undoing the fix e3r just shipped. No
          // message, icon override or action is passed: this branch has no
          // retry affordance today and this plan adds no new user-facing
          // affordance or copy to it.
          return const DashboardScrollContainer(
            // Develop's string, byte-for-byte (UI-SPEC §6) -- see the note
            // on the error branch above; the same rule applies here.
            child: GWEmptyState(title: "No market data available"),
          );
        }
        return DashboardScrollContainer(
          child: DashboardMarkets(title: 'Markets', coins: coins),
        );
      },
    );
  }
}

/// Scroll-safe wrapper used ONLY by the Markets error branch above. This is
/// the same LayoutBuilder -> inner scroll view -> ConstrainedBox idiom
/// Task 2 applies inside wallet_overview.dart, duplicated here rather than
/// promoted to a shared GW* primitive: two call sites do not justify a new
/// public component or a new entry in the shadow-name inventory. Upgrade
/// path: promote it if a third site ever needs the same idiom.
class _MarketsErrorScrollSafe extends StatelessWidget {
  const _MarketsErrorScrollSafe({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final double minHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 0.0;
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minHeight),
            child: child,
          ),
        );
      },
    );
  }
}

class ChartDashboardView extends StatelessWidget {
  const ChartDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return const DashboardScrollContainer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ChartSectionHeader(),
          Expanded(
            child: CryptoLiveChart(
              coinGeckoCoinId: 'bitcoin',
              tokenSymbol: 'btc',
              priceHeight: 28,
            ),
          ),
        ],
      ),
    );
  }
}

/// A→ header for the Bitcoin Chart card (sketch 006): coin identity on the
/// left, a visual-only 1H·1D·1W·1M·1Y timeframe segment on the right, pushed
/// apart on one row. Reproduces GWSectionTitle's exact geometry (same
/// padding + minHeight) so this panel's title->body rhythm matches the
/// Assets/Markets/Transactions panels that still use GWSectionTitle.
class _ChartSectionHeader extends StatelessWidget {
  const _ChartSectionHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        GeniusWalletConsts.space4,
        2,
        GeniusWalletConsts.space4,
        // ~3x the shared space8 gap (per request): pushes the price/% down away
        // from the Bitcoin·BTC + timeframe row and shrinks the chart, which was
        // taking too much height. Chart-only override of the section rhythm.
        GeniusWalletConsts.space24,
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 44),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [_CoinIdentity(), GWTimeframeSegment()],
        ),
      ),
    );
  }
}

/// ₿ coin avatar + "Bitcoin" (bold) + "BTC" ticker — mirrors sketch 006's
/// IDENT block. Hardcoded to bitcoin, matching the card below it.
class _CoinIdentity extends StatelessWidget {
  const _CoinIdentity();

  // ponytail: the ₿-on-#F7931A coin avatar is the recognizable Bitcoin brand
  // LOGO mark -- WCAG's logo exemption applies, so its glyph/fill contrast
  // does not gate AA; it stays the canonical white-₿-on-orange. Ceiling:
  // hardcoded to bitcoin. Upgrade path: a coin-agnostic avatar when this card
  // stops being hardcoded to coinGeckoCoinId: 'bitcoin'.
  static const Color _bitcoinOrange = Color(0xFFF7931A);

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 30,
          height: 30,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: _bitcoinOrange,
            shape: BoxShape.circle,
          ),
          child: const Text(
            '₿',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.bold,
              height: 1,
            ),
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space3),
        Text.rich(
          // ONE line so "Bitcoin" centers in the shared 44px header at the same
          // baseline as Markets/Assets titles. A two-line name+ticker stack
          // centred its whole block, pushing the name line visibly higher.
          TextSpan(
            style: GeniusWalletTypography.titleLg.copyWith(
              color: gw.textPrimary,
              letterSpacing: -0.2,
              height: 1,
            ),
            children: [
              const TextSpan(text: 'Bitcoin'),
              TextSpan(
                text: '  ·  BTC',
                style: TextStyle(
                  color: gw.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ContributionsDashboardView extends StatelessWidget {
  const ContributionsDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    // The BlocBuilder<WalletDetailsCubit> + StreamBuilder<SGNUSConnection>
    // this used to wrap `CoinsScreen` in existed solely to compute the
    // `isGnusWalletConnected` flag - `router.dart`'s `/token-info` route
    // derives that itself now (quick task 260731-hsb), so this collapses to
    // the plain container. `CoinsScreen` runs its own `BlocBuilder`
    // internally, so it keeps rebuilding on wallet state exactly as before.
    return const DashboardScrollContainer(
      child: CoinsScreen(isUseDivider: true),
    );
  }
}
