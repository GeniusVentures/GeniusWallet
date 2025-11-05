import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_order/create_order_state.dart';
class QuoteCard extends StatelessWidget {
  final MakeOrderState state;
  final bool compact;
  const QuoteCard({required this.state, required this.compact, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (!state.hasQuote) return const SizedBox();
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              compact
                  ? 'Receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}'
                  : 'You will receive: ${state.quote!.cryptoAmount} ${state.cryptoCode}',
            ),
            const SizedBox(height: 4),
            Wrap(
              spacing: 12,
              runSpacing: 4,
              children: [
                Text(
                    'Gateway: ${state.quote!.processingFee} ${state.fiatCode}'),
                Text('Network: ${state.quote!.networkFee} ${state.fiatCode}'),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
