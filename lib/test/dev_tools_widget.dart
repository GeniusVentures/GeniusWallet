import 'package:flutter/material.dart';
import 'package:genius_wallet/reown/test/test_buy_buttons.dart';
import 'package:genius_wallet/reown/test/test_swap_buttons.dart';
import 'package:genius_wallet/test/dev_tools_state.dart';
import 'package:genius_wallet/test/test_transaction_button.dart';

class DevToolsWidget extends StatefulWidget {
  const DevToolsWidget({super.key});

  @override
  State<DevToolsWidget> createState() => _DevToolsWidgetState();
}

class _DevToolsWidgetState extends State<DevToolsWidget> {
  final ValueNotifier<bool> devTools = DevToolsState().showDevTools;

  @override
  void initState() {
    super.initState();
    devTools.addListener(_onToggle);
  }

  void _onToggle() => setState(() {});

  @override
  void dispose() {
    devTools.removeListener(_onToggle);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!devTools.value) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8),
      child: const Row(
        children: [
          Text('Dev', style: TextStyle(color: Colors.white, fontSize: 14)),
          SizedBox(width: 12),
          TestTransactionButton(),
          TestSwapButtons(),
          TestBuyButtons()
        ],
      ),
    );
  }
}
