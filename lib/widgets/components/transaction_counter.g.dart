import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/custom/transaction_counter_custom.dart';
import 'package:auto_size_text/auto_size_text.dart';

class TransactionCounter extends StatefulWidget {
  final BoxConstraints constraints;
  final String? ovrTransactions;
  final String? ovr2345;
  const TransactionCounter(
    this.constraints, {
    Key? key,
    this.ovrTransactions,
    this.ovr2345,
  }) : super(key: key);
  @override
  _TransactionCounter createState() => _TransactionCounter();
}

class _TransactionCounter extends State<TransactionCounter> {
  _TransactionCounter();

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(),
      child: TransactionCounterCustom(
          child: Wrap(
        spacing: 12,
        alignment: WrapAlignment.center,
        runAlignment: WrapAlignment.center,
        crossAxisAlignment: WrapCrossAlignment.end,
        children: [
          AutoSizeText(
            widget.ovr2345 ?? '2,345',
            style: const TextStyle(
              fontFamily: 'Roboto',
              fontSize: 32.0,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.0,
              color: Colors.white,
            ),
            textAlign: TextAlign.left,
          ),
          const Text(
            'Transactions',
            style: TextStyle(color: GeniusWalletColors.gray500),
          )
        ],
      )),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
