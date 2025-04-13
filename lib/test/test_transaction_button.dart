import 'dart:math';
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
    final txController = context.read<GeniusApi>().getTransactionsController();

    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: "Add Test Transaction",
        icon: const Icon(FontAwesomeIcons.tableList, color: Colors.greenAccent),
        onPressed: () {
          final fakeTx = getFakeTransaction();
          txController.addTransaction(fakeTx);

          ToastManager().showToast(
            context: context,
            title: "Transaction Added",
            message: "Added: ${fakeTx.type} | ${fakeTx.transactionDirection}",
            type: ToastType.success,
          );
        },
      ),
    );
  }
}
