import 'package:flutter/material.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';

class TransactionEscrowReleaseItem extends StatelessWidget {
  final Transaction tx;

  const TransactionEscrowReleaseItem({super.key, required this.tx});

  @override
  Widget build(BuildContext context) {
    return Card(
        color: GeniusWalletColors.deepBlueMenu,
        shape: RoundedRectangleBorder(
            side: BorderSide(color: GeniusWalletColors.borderSubtle, width: 1),
            borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          title: Text("Completed job"),
        ));
  }
}
