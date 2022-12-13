import 'package:flow_builder/flow_builder.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/buy/bloc/buy_bloc.dart';
import 'package:genius_wallet/dashboard/wallets/buy/view/enter_amount_screen.dart';
import 'package:go_router/go_router.dart';

class BuyFlow extends StatelessWidget {
  const BuyFlow({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlowBuilder(
      onGeneratePages: (state, pages) {
        return [
          const MaterialPage(child: EnterAmountScreen()),
        ];
      },
      state: context.watch<BuyBloc>().state,
      onComplete: (value) {
        context.go('/dashboard');
      },
    );
  }
}
