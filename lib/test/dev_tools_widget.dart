import 'package:flutter/material.dart';
import 'package:genius_wallet/reown/test/test_buy_buttons.dart';
import 'package:genius_wallet/reown/test/test_swap_buttons.dart';
import 'package:genius_wallet/test/test_transaction_button.dart';
import 'package:go_router/go_router.dart';

class DevToolsWidget extends StatelessWidget {
  const DevToolsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          const Text('Dev', style: TextStyle(color: Colors.white, fontSize: 14)),
          const SizedBox(width: 12),
          const TestTransactionButton(),
          const TestSwapButtons(),
          const TestBuyButtons(),
          TextButton(
            onPressed: () => context.push('/dev/token-probe'),
            child: const Text('Tokens'),
          ),
          TextButton(
            onPressed: () => context.push('/design_gallery'),
            child: const Text('Gallery'),
          ),
        ],
      ),
    );
  }
}
