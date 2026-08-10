import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dashboard/transactions/sgnus_transactions_screen.dart';
import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  /// The page's filter, lifted out of `TransactionsSlimView`'s State by sketch
  /// 195: the trigger that sets it now lives in [GWPageHeader.trailing], two
  /// widgets ABOVE the list, so the value has to live where both can see it.
  ///
  /// It stays on the SCREEN rather than moving into a cubit because it is view
  /// state and nothing outside this route reads it - the dashboard panel keeps
  /// its own copy in the slim view, untouched.
  Filters _filter = Filters.all;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // No mesh, at either width. The phone page wrapped its body in
      // `GWMeshBackground` until 2026-08-09, which made `/transactions` the one
      // content tab with a moving branded field behind its rows while `/assets`
      // and Crypto News sat on the flat canvas. A bare `Scaffold` paints
      // `scaffoldBackgroundColor`, which `theme.dart` sets to `gw.surfaceBase`
      // - the same colour `assets_screen.dart`'s own bare `Scaffold` resolves,
      // in both appearances.
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            context.read<WalletDetailsCubit>().getCoins();
          },
          child: BlocBuilder<WalletDetailsCubit, WalletDetailsState>(
            builder: (context, walletState) {
              final selectedWallet = walletState.selectedWallet;
              final isSgnusWallet =
                  selectedWallet?.walletType == WalletType.sgnus;

              // The PAGE scrolls, not the list inside it. Sketch 023-V3: with
              // the cards hugging their content, nothing below them is
              // scrollable, so the scroll has to live here or a long history
              // has nowhere to go.
              //
              // Two things fall out of that, both wanted. `RefreshIndicator`
              // now arms anywhere on the page instead of only over the list
              // card - 15-05 measured 220px of a 1280px page (the rail column)
              // as dead to pull-to-refresh, because the rail's own
              // SingleChildScrollView fits its content and so refuses the drag.
              // And `AlwaysScrollableScrollPhysics` keeps refresh working when
              // the content is SHORTER than the viewport, which is exactly the
              // case this sketch exists to create.
              return SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                // topCenter: centred horizontally (symmetric left/right margins,
                // like before) and pinned to the TOP so the 64px navbar→title gap
                // holds. Every content page shares ONE cap (xxl) below, so a
                // centred box lands each page title at the SAME X across
                // Transactions / Markets / News - without stripping the left
                // padding that a left-flush box loses on a wide window.
                child: Align(
                  alignment: Alignment.topCenter,
                  // The Padding sits OUTSIDE the ConstrainedBox, and the order is
                  // load-bearing in BOTH directions.
                  //
                  // Narrow: a max-width only constrains a viewport WIDER than it,
                  // so at phone width the ConstrainedBox does nothing at all and
                  // the gutter has to come from here. A frame that leans on the
                  // cap alone glues its content to the window bezel - the exact
                  // defect the 06-01 walk found in `wallet_creation_screen.dart`.
                  //
                  // Wide: with the Padding outside, the cap applies to the
                  // CONTENT, so the content box is a clean 1280 and the gutter is
                  // additive (1304 of window used). Nested the other way the
                  // content would come out at 1280 - 24 = 1256 and quietly
                  // disagree with Markets' own arithmetic. Do not "simplify" the
                  // two into one.
                  //
                  // 12/8 matches `markets_screen.dart:68` deliberately, replacing
                  // this screen's old EdgeInsets.all(16): two sibling tabs with
                  // different page gutters is the kind of difference nobody can
                  // name but everybody sees.
                  child: Padding(
                    // Gap and gutter both come from `GeniusBreakpoints`, shared
                    // with the other page headers so every title lands at the
                    // same X - at BOTH widths, not just desktop. Bottom 8.
                    padding: EdgeInsets.fromLTRB(
                      GeniusBreakpoints.pageGutter(context),
                      GeniusBreakpoints.pageTitleGap(context),
                      GeniusBreakpoints.pageGutter(context),
                      GeniusWalletConsts.space8,
                    ),
                    child: ConstrainedBox(
                      // xxl (1536), unified with Markets and News so the three
                      // content pages share ONE width and the title lands in the
                      // same place. Was 1600 (sketch 024-C); narrowed by Jakub's
                      // call for a consistent page frame across the tabs.
                      constraints: const BoxConstraints(
                        maxWidth: GeniusBreakpoints.xxl,
                      ),
                      // The header's trigger belongs to the NARROW presentation
                      // only, and this builder is how it learns which one is on
                      // screen. `GeniusBreakpoints.medium` against the CONTENT
                      // box, not against the window: that is the identical test
                      // `TransactionsSlimView._page` makes on the identical
                      // constraints (both children of this stretched Column fill
                      // this same ConstrainedBox), and a MediaQuery read would
                      // disagree with it across a ~24px band - the width of the
                      // gutters - which is exactly where the page would show two
                      // filter controls or none.
                      child: LayoutBuilder(
                        builder: (context, constraints) {
                          final bool wide =
                              constraints.maxWidth >= GeniusBreakpoints.medium;

                          return Column(
                            // stretch, so the header and the branch both take the
                            // full capped width instead of shrink-wrapping to
                            // their intrinsic content.
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            // min, because the Column now sits in a scroll view
                            // and an unbounded height has no "rest of the screen"
                            // to take. This is the same edit as dropping the
                            // Expanded below: the page is as tall as its content.
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // GWPageHeader owns its own space8 bottom gap - no
                              // SizedBox after it. Adding one is how this page
                              // would drift out of vertical alignment with
                              // Markets and Swap.
                              //
                              // This is now the page's ONLY title: page: true
                              // tells TransactionsSlimView to emit its two-card
                              // layout, which carries no GWSectionTitle. A second
                              // "Transactions" on screen means the flag did not
                              // reach the slim view - check the two pass-throughs
                              // below before touching anything here.
                              //
                              // The header carries the page's filter trigger on
                              // the phone (sketch 195, scheme G2) - the slot
                              // Crypto News already fills with its freshness
                              // stamp, and a control that costs the page no
                              // vertical space at all, which is what let the flat
                              // filter track leave the card below.
                              //
                              // NOT on the wide page: there the branch below
                              // renders `_FilterRail`, which shows all nine
                              // filters and their counts permanently. A second
                              // door to the same state, 20px from the first, is
                              // two controls for one filter.
                              GWPageHeader(
                                title: 'Transactions',
                                trailing: wide
                                    ? null
                                    : _FilterTrigger(
                                        sgnus: isSgnusWallet,
                                        selected: _filter,
                                        onChanged: (f) =>
                                            setState(() => _filter = f),
                                      ),
                              ),
                              // No Expanded: it would demand a bounded height the
                              // enclosing scroll view cannot give, and "fill the
                              // window" is exactly the behaviour sketch 023
                              // removed.
                              //
                              // No `const` on either branch any more: both now
                              // carry the page's live filter. That is the whole
                              // price of scheme G2 and it was accepted with it.
                              isSgnusWallet
                                  ? SgnusTransactionsScreen(
                                      page: true,
                                      selectedFilter: _filter,
                                      onFilterChanged: (f) =>
                                          setState(() => _filter = f),
                                    )
                                  : TransactionsStream(
                                      page: true,
                                      selectedFilter: _filter,
                                      onFilterChanged: (f) =>
                                          setState(() => _filter = f),
                                    ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// [TransactionsFilterTrigger] with the transactions it needs.
///
/// The trigger has to read the SAME list the page below it renders, for two
/// reasons: it hides itself on an empty scope, and the drawer it opens prints
/// a count per filter. So it takes a second subscription to whichever source
/// this route already chose - a cheap `BlocBuilder` on a cubit that is already
/// in the tree, or a second listener on a `BehaviorSubject` that is broadcast
/// by construction.
///
/// The alternative was passing the list UP from the two data widgets, which
/// means either a callback fired during their build or moving both data reads
/// into this screen - and the SGNUS one owns a polling timer that belongs with
/// its own widget. A duplicated read of an in-memory list is the smaller cost,
/// and it keeps `TransactionsStream` and `SgnusTransactionsScreen` as the only
/// two things that know how their data arrives.
class _FilterTrigger extends StatelessWidget {
  const _FilterTrigger({
    required this.sgnus,
    required this.selected,
    required this.onChanged,
  });

  final bool sgnus;
  final Filters selected;
  final ValueChanged<Filters> onChanged;

  @override
  Widget build(BuildContext context) {
    if (!sgnus) {
      return BlocBuilder<TransactionsCubit, List<Transaction>>(
        builder: (context, transactions) => TransactionsFilterTrigger(
          transactions: transactions,
          selected: selected,
          onChanged: onChanged,
        ),
      );
    }

    return StreamBuilder<List<Transaction>>(
      stream: context.read<GeniusApi>().getSGNUSTransactionsStream(),
      builder: (context, snapshot) => TransactionsFilterTrigger(
        // The same predicate `SgnusTransactionsScreen` applies before handing
        // the list on, and the same one the slim view's own
        // `isShowOnlySGNUSTransactions` scope applies after it - so all three
        // count the same rows.
        transactions: (snapshot.data ?? const <Transaction>[])
            .where((tx) => tx.isSGNUS ?? false)
            .toList(),
        selected: selected,
        onChanged: onChanged,
      ),
    );
  }
}
