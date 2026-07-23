import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/dashboard/transactions/sgnus_transactions_screen.dart';

import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              // card — 15-05 measured 220px of a 1280px page (the rail column)
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
                // Transactions / Markets / News — without stripping the left
                // padding that a left-flush box loses on a wide window.
                child: Align(
                  alignment: Alignment.topCenter,
                  // The Padding sits OUTSIDE the ConstrainedBox, and the order is
                  // load-bearing in BOTH directions.
                  //
                  // Narrow: a max-width only constrains a viewport WIDER than it,
                  // so at phone width the ConstrainedBox does nothing at all and
                  // the gutter has to come from here. A frame that leans on the
                  // cap alone glues its content to the window bezel — the exact
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
                    // top 64 (space32) navbar→title gap; sides 12, bottom 8.
                    // This frame is now UNIFIED across Transactions / Markets /
                    // News — all three left-align to the window with a 12px
                    // gutter and an xxl cap, so the page title lands at the same
                    // X on every content page (Jakub's call).
                    padding: const EdgeInsets.fromLTRB(
                      12,
                      GeniusWalletConsts.space32,
                      12,
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
                      child: Column(
                        // stretch, so the header and the branch both take the
                        // full capped width instead of shrink-wrapping to their
                        // intrinsic content.
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        // min, because the Column now sits in a scroll view and
                        // an unbounded height has no "rest of the screen" to
                        // take. This is the same edit as dropping the Expanded
                        // below: the page is as tall as its content.
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // GWPageHeader owns its own space8 bottom gap — no
                          // SizedBox after it. Adding one is how this page would
                          // drift out of vertical alignment with Markets and
                          // Swap.
                          //
                          // This is now the page's ONLY title: page: true tells
                          // TransactionsSlimView to emit its two-card layout,
                          // which carries no GWSectionTitle. A second
                          // "Transactions" on screen means the flag did not reach
                          // the slim view — check the two pass-throughs below
                          // before touching anything here.
                          const GWPageHeader(title: 'Transactions'),
                          // No Expanded: it would demand a bounded height the
                          // enclosing scroll view cannot give, and "fill the
                          // window" is exactly the behaviour sketch 023 removed.
                          isSgnusWallet
                              ? const SgnusTransactionsScreen(page: true)
                              : const TransactionsStream(page: true),
                        ],
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
