import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/test/dev_overrides.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:provider/provider.dart';

class TestTransactionButton extends StatelessWidget {
  const TestTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final txController =
        context.read<GeniusApi>().getSGNUSTransactionsController();

    return IconButton(
      tooltip: "Add SGNUS Test Transaction",
      icon: const Icon(FontAwesomeIcons.tableList, color: Colors.greenAccent),
      onPressed: () {
        final fakeTx = getFakeTransaction(true);
        txController.addTransaction(fakeTx);

        ToastManager().showToast(
          context: context,
          title: "Transaction Added",
          message: "Added: ${fakeTx.type} | ${fakeTx.transactionDirection}",
          type: ToastType.success,
        );
      },
    );
  }
}
