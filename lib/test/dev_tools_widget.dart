import 'package:flutter/material.dart';
import 'package:genius_wallet/reown/test/test_buy_buttons.dart';
import 'package:genius_wallet/reown/test/test_swap_buttons.dart';
import 'package:genius_wallet/test/test_transaction_button.dart';

class DevToolsWidget extends StatelessWidget {
  const DevToolsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Text('Dev', style: TextStyle(color: Colors.white, fontSize: 14)),
          SizedBox(width: 12),
          TestTransactionButton(),
          TestSwapButtons(),
          TestBuyButtons(),
        ],
      ),
    );
  }
}
