import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';

class QuoteCard extends StatelessWidget {
  final MakeOrderState state;
  final bool compact;
  const QuoteCard({required this.state, required this.compact, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!state.hasQuote) return const SizedBox();
    return GWCard(
      padding: const EdgeInsets.all(GeniusWalletConsts.space6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            compact
                ? 'Receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}'
                : 'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
            style: GeniusWalletTypography.titleMd,
          ),
          const SizedBox(height: GeniusWalletConsts.space2),
          Wrap(
            spacing: GeniusWalletConsts.space6,
            runSpacing: GeniusWalletConsts.space2,
            children: [
              Text(
                'Gateway: ${state.quote!.processingFee} ${state.fiatCode}',
                style: GeniusWalletTypography.bodySm
                    .copyWith(color: GeniusWalletColors.textSecondary),
              ),
              Text(
                'Network: ${state.quote!.networkFee} ${state.fiatCode}',
                style: GeniusWalletTypography.bodySm
                    .copyWith(color: GeniusWalletColors.textSecondary),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
