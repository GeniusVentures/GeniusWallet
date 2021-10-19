import 'package:flutter/material.dart';
import 'package:geniuswallet/cubits/wallet_balance_cubit.dart';
import 'package:geniuswallet/widgets/symbols/amount_and_subtext.g.dart';
import 'package:flutter_bloc/flutter_bloc.dart';


class AmountAndSubtextCustom extends StatefulWidget {
  final Widget child;
  AmountAndSubtextCustom({Key key, this.child}) : super(key: key);

  @override
  _AmountAndSubtextCustomState createState() => _AmountAndSubtextCustomState();
}

class _AmountAndSubtextCustomState extends State<AmountAndSubtextCustom> {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      return AmountAndSubtext(
        constraints,
        ovrAmount:
            "\$ ${context.watch<WalletBalanceCubit>().state.balance.toString()}",
      );
    });
  }
}
