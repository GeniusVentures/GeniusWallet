import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';

import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/widgets/components/date_selector.g.dart';
import 'package:genius_wallet/widgets/components/export_history.g.dart';

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
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    SizedBox(
                        height: 500,
                        width: 1342,
                        child: BlocBuilder<AppBloc, AppState>(
                            builder: (context, state) {
                          return TransactionsSlimView(
                              transactions: state.transactions);
                        }))
                  ],
                ))));
  }
}
