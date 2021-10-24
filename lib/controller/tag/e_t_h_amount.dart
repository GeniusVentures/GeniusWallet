import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/e_t_h_amount/e_t_h_amount_cubit.dart';

import 'package:geniuswallet/bloc/e_t_h_amount/e_t_h_amount_state.dart';

class ETHAmount extends StatefulWidget {
  final Widget child;
  ETHAmount({Key key, this.child}) : super(key: key);

  @override
  _ETHAmountState createState() => _ETHAmountState();
}

class _ETHAmountState extends State<ETHAmount> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ETHAmountCubit(ETHAmountInitial()),
      child: BlocBuilder<ETHAmountCubit, ETHAmountState>(
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
