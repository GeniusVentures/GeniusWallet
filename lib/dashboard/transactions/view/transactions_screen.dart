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
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: SafeArea(
        child: Container(
          height: screenHeight,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: Column(
            children: [
              // You can add a header or filter here if needed
              Expanded(
                child: BlocBuilder<AppBloc, AppState>(
                  builder: (context, state) {
                    return const DashboardScrollContainer(
                      child: TransactionsSlimView(),
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
