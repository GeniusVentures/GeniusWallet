import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/transactions/sgnus_transactions_screen.dart';

import 'package:genius_wallet/dashboard/transactions/view/transactions_stream.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
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

              return Center(
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: ConstrainedBox(
                    // xl (1280), NOT Markets' xxl. Markets earns 1536 because a
                    // coin grid spends extra width by adding columns; a
                    // transaction list does not add columns, and sketch 020's
                    // variant C — the wide table that would have — was rejected
                    // for breaking Phase 12's one-anatomy rule. 1280 is where a
                    // 220px rail beside a row stops gaining anything.
                    constraints: const BoxConstraints(
                      maxWidth: GeniusBreakpoints.xl,
                    ),
                    child: Column(
                      // stretch, so the header and the branch both take the
                      // full capped width instead of shrink-wrapping to their
                      // intrinsic content.
                      crossAxisAlignment: CrossAxisAlignment.stretch,
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
                        Expanded(
                          child: isSgnusWallet
                              ? const SgnusTransactionsScreen(page: true)
                              : const TransactionsStream(page: true),
                        ),
                      ],
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
