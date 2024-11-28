import 'package:flutter/material.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';

import 'package:genius_wallet/app/widgets/desktop_container.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.g.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';

import 'package:genius_wallet/widgets/components/export_history.g.dart';
import 'package:genius_wallet/widgets/components/transaction_counter.g.dart';

class TransactionsScreen extends StatelessWidget {
  const TransactionsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height, // Minimum height
            ),
            child: Container(
                padding: const EdgeInsets.all(20),
                child: const Column(
                  children: [
                    SizedBox(height: 30),
                    TransactionsAndHistoryDesktop(),
                    SizedBox(height: 50),
                    SizedBox(height: 500, child: TransactionsSlimView())
                  ],
                ))));
  }
}

class TransactionsAndHistoryDesktop extends StatelessWidget {
  const TransactionsAndHistoryDesktop({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return TransactionCounter(constraints);
          },
        ),
        const Spacer(),
        SizedBox(
          height: 30,
          width: 300,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return DateSelector(constraints);
            },
          ),
        ),
        SizedBox(
          height: 40,
          width: 120,
          child: LayoutBuilder(
            builder: (BuildContext context, BoxConstraints constraints) {
              return ExportHistory(constraints);
            },
          ),
        ),
      ],
    );
  }
}
