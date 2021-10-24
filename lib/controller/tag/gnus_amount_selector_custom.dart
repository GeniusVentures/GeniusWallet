import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/gnus_amount_selector_custom/gnus_amount_selector_custom_cubit.dart';

import 'package:geniuswallet/bloc/gnus_amount_selector_custom/gnus_amount_selector_custom_state.dart';

class GnusAmountSelectorCustom extends StatefulWidget {
  final Widget child;
  GnusAmountSelectorCustom({Key key, this.child}) : super(key: key);

  @override
  _GnusAmountSelectorCustomState createState() =>
      _GnusAmountSelectorCustomState();
}

class _GnusAmountSelectorCustomState extends State<GnusAmountSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          GnusAmountSelectorCustomCubit(GnusAmountSelectorCustomInitial()),
      child: BlocBuilder<GnusAmountSelectorCustomCubit,
          GnusAmountSelectorCustomState>(builder: (context, state) {
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
