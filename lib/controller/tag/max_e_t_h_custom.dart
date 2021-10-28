import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/max_e_t_h_custom/max_e_t_h_custom_cubit.dart';

import 'package:geniuswallet/bloc/max_e_t_h_custom/max_e_t_h_custom_state.dart';

class MaxETHCustom extends StatefulWidget {
  final Widget child;
  MaxETHCustom({Key key, this.child}) : super(key: key);

  @override
  _MaxETHCustomState createState() => _MaxETHCustomState();
}

class _MaxETHCustomState extends State<MaxETHCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => MaxETHCustomCubit(MaxETHCustomInitial()),
      child: BlocBuilder<MaxETHCustomCubit, MaxETHCustomState>(
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
