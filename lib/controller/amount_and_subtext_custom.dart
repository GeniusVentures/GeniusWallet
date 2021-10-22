import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/amount_and_subtext_custom/amount_and_subtext_custom_cubit.dart';

import 'package:geniuswallet/bloc/amount_and_subtext_custom/amount_and_subtext_custom_state.dart';
import 'package:geniuswallet/widgets/symbols/amount_and_subtext.g.dart';

class AmountAndSubtextCustom extends StatefulWidget {
  final Widget child;

  AmountAndSubtextCustom({Key key, this.child}) : super(key: key);

  @override
  _AmountAndSubtextCustomState createState() => _AmountAndSubtextCustomState();
}

class _AmountAndSubtextCustomState extends State<AmountAndSubtextCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
        create: (_) =>
            AmountAndSubtextCustomCubit(AmountAndSubtextCustomInitial()),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            return BlocBuilder<AmountAndSubtextCustomCubit,
                AmountAndSubtextCustomState>(
                builder: (context, state) {
                  return AmountAndSubtext(constraints,
                    ovrAmount: state.GetAmount(), ovrText: state.SubText);
                });
          },
        ));
  }
}
