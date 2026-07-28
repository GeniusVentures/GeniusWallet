import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// This widget currently has no callers anywhere in lib/ — a repo-wide
// search for an instantiation of this class turns up nothing outside this
// file's own declaration. `banxa_buy_screen.dart` renders an equivalent
// quote block inline instead of reaching for this component. Phase 9
// re-skinned this file under 09-CONTEXT.md's D-08 without wiring it in:
// that is a deliberate choice, not an oversight, and it leaves two
// divergent copies of the same card in the codebase. The duplication's
// owner is filed as a pending todo (see .planning/todos/pending/) so a
// future edit does not land on the wrong copy without realizing it.
class QuoteCard extends StatelessWidget {
  final MakeOrderState state;
  final bool compact;
  const QuoteCard({required this.state, required this.compact, super.key});

  @override
  Widget build(BuildContext context) {
    if (!state.hasQuote) {
      return const SizedBox();
    }
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            compact
                ? 'Receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}'
                : 'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
            style: GeniusWalletTypography.bodyLg.copyWith(
              color: gw.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Wrap(
            spacing: 12,
            runSpacing: 4,
            children: [
              Text(
                'Gateway: ${state.quote!.processingFee} ${state.fiatCode}',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
              Text(
                'Network: ${state.quote!.networkFee} ${state.fiatCode}',
                style: GeniusWalletTypography.bodySm.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
