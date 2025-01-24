import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/app_bloc.dart';
import 'package:genius_wallet/app/utils/breakpoints.dart';
import 'package:genius_wallet/dashboard/home/widgets/containers.dart';

import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';

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
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                child: Column(
                  children: [
                    SizedBox(
                        height: GeniusBreakpoints.useDesktopLayout(context)
                            ? MediaQuery.of(context).size.height - 30
                            : MediaQuery.of(context).size.height - 200,
                        width: 1342,
                        child: BlocBuilder<AppBloc, AppState>(
                            builder: (context, state) {
                          return DashboardViewNoFlexContainer(
                              child: TransactionsSlimView(
                                  transactions: state.transactions));
                        }))
                  ],
                ))));
  }
}
