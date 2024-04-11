import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/widgets/app_screen_view.dart';
import 'package:genius_wallet/widgets/components/back_button_header.g.dart';
import 'package:genius_wallet/widgets/components/custom/detailed_transaction_status_custom.dart';
import 'package:genius_wallet/widgets/components/historic_transaction_detail_view.g.dart';

class TransactionInformationScreen extends StatelessWidget {
  final Transaction transaction;
  const TransactionInformationScreen({
    Key? key,
    required this.transaction,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppScreenView(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 50,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return BackButtonHeader(
                      constraints,
                      ovrTitle: 'Transaction Information',
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 40,
                width: 121,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return DetailedTransactionStatusCustom();
                  },
                ),
              ),
              const SizedBox(height: 30),
              SizedBox(
                height: 500,
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constraints) {
                    return HistoricTransactionDetailView(
                      constraints,
                      ovrTransactionAmount: transaction.amount,
                      ovrCryptoType: transaction.coinSymbol,
                      ovrReceiverWalletID: transaction.toAddress,
                      ovrTransactionID: transaction.hash,
                      ovrTransactionFee: transaction.fees,
                      ovrTransactionType: transaction.transactionDirection ==
                              TransactionDirection.received
                          ? 'Incoming'
                          : 'Outgoing',
                      ovrTransactionTypeArrow: transaction
                                  .transactionDirection ==
                              TransactionDirection.received
                          ? Image.asset('assets/images/green_arrow_right.png')
                          : Image.asset('assets/images/red_arrow_left.png'),
                      ovrTransactionTimestamp: transaction.timeStamp,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
