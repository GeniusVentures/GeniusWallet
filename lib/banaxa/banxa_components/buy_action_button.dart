import 'package:flutter/material.dart';
class BuyActionButtons extends StatelessWidget {
  final bool compact;
  final bool canGetQuote;
  final VoidCallback onGetQuote;
  final bool showRetry;
  final VoidCallback? onRetry;

  const BuyActionButtons({
    required this.compact,
    required this.canGetQuote,
    required this.onGetQuote,
    required this.showRetry,
    this.onRetry,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: canGetQuote ? onGetQuote : null,
            child: const Text('Get Quote'),
          ),
          if (showRetry)
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
        ],
      );
    } else {
      return Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: canGetQuote ? onGetQuote : null,
              child: const Text('Get Quote'),
            ),
          ),
          if (showRetry)
            IconButton(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              tooltip: 'Retry',
            ),
        ],
      );
    }
  }
}
