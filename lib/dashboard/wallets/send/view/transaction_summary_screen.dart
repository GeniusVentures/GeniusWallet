import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/close_button_header.g.dart';
import 'package:genius_wallet/widgets/components/successful_transaction_details.g.dart';

class TransactionSummaryScreen extends StatelessWidget {
  final Transaction transaction;
  final Wallet wallet;
  const TransactionSummaryScreen({
    Key? key,
    required this.transaction,
    required this.wallet,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Container(
          height: MediaQuery.of(context).size.height,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return CloseButtonHeader(
                      constraints,
                      ovrSendBitcoin: 'Transaction Summary',
                    );
                  },
                ),
              ),
              // FractionallySizedBox(heightFactor: 5),
              const Flexible(
                child: FractionallySizedBox(
                  heightFactor: 0.1,
                ),
              ),
              Image.asset('assets/images/transaction_successful_checkmark.png'),
              const SizedBox(height: 20),
              const Text('Transaction Successful!'),
              const SizedBox(height: 30),
              SizedBox(
                height: 430,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return SuccessfulTransactionDetails(
                      constraints,
                      ovrTransactionValue: transaction.amount,
                      ovrUserBalance: wallet.balance.toString(),
                      ovrReceiverWalletID: transaction.toAddress,
                      ovrTransactionID: transaction.hash,
                      ovrGasFee: transaction.fees,
                      ovrTransactionTimestamp: transaction.timeStamp,
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
