import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/amount_and_subtext_custom/amount_and_subtext_custom_cubit.dart';

import 'package:geniuswallet/bloc/amount_and_subtext_custom/amount_and_subtext_custom_state.dart';

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
      child:
          BlocBuilder<AmountAndSubtextCustomCubit, AmountAndSubtextCustomState>(
              builder: (context, state) {
        /// TODO: @developer implement bloc and map the states to widgets as desired.
        /// For example, in a counter app you may have something like
        ///
        /// if(state is CounterInProgress){
        ///   return Text('${state.value}');
        /// } else {
        ///   return Text('0');
        /// }
        return widget.child;
      }),
    );
  }
}
