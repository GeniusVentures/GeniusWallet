import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/e_t_h_amount_custom/e_t_h_amount_custom_cubit.dart';

import 'package:geniuswallet/bloc/e_t_h_amount_custom/e_t_h_amount_custom_state.dart';

class ETHAmountCustom extends StatefulWidget {
  final Widget child;
  ETHAmountCustom({Key key, this.child}) : super(key: key);

  @override
  _ETHAmountCustomState createState() => _ETHAmountCustomState();
}

class _ETHAmountCustomState extends State<ETHAmountCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ETHAmountCustomCubit(ETHAmountCustomInitial()),
      child: BlocBuilder<ETHAmountCustomCubit, ETHAmountCustomState>(
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
