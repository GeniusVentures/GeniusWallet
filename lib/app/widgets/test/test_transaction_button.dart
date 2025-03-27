import 'dart:math';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/widgets/components/toast/toast_manager.dart';
import 'package:provider/provider.dart';

class TestTransactionButton extends StatelessWidget {
  const TestTransactionButton({super.key});

  @override
  Widget build(BuildContext context) {
    final txController = context.read<GeniusApi>().getTransactionsController();
    final rand = Random();

    return Container(
      decoration: BoxDecoration(
        color: Colors.greenAccent.withOpacity(0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        tooltip: "Add Test Transaction",
        icon: const Icon(FontAwesomeIcons.tableList, color: Colors.greenAccent),
        onPressed: () {
          final now = DateTime.now();

          final directions = TransactionDirection.values;
          final randomDirection = directions[rand.nextInt(directions.length)];

          final types = TransactionType.values;
          final randomType = types[rand.nextInt(types.length)];

          final fakeTx = Transaction(
            hash: "0x${now.millisecondsSinceEpoch}",
            fromAddress: "0xFromMocked",
            recipients: [
              const TransferRecipients(amount: "0.5", toAddr: "0xToMocked"),
            ],
            coinSymbol: "ETH",
            fees: "0.001",
            transactionDirection: randomDirection,
            timeStamp: now,
            type: randomType,
            transactionStatus: TransactionStatus.completed,
            isSGNUS: rand.nextBool(),
          );

          txController.addTransaction(fakeTx);

          ToastManager().showToast(
            context: context,
            title: "Transaction Added",
            message: "Added: $randomType | ${randomDirection.name}",
            type: ToastType.success,
          );
        },
      ),
    );
  }
}
