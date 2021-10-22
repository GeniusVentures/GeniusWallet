import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/max_e_t_h/max_e_t_h_cubit.dart';

import 'package:geniuswallet/bloc/max_e_t_h/max_e_t_h_state.dart';

class MaxETH extends StatefulWidget {
  final Widget child;
  MaxETH({Key key, this.child}) : super(key: key);

  @override
  _MaxETHState createState() => _MaxETHState();
}

class _MaxETHState extends State<MaxETH> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaxETHCubit(MaxETHInitial()),
      child: BlocBuilder<MaxETHCubit, MaxETHState>(builder: (context, state) {
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
