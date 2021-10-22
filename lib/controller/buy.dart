import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/buy/buy_cubit.dart';

import 'package:geniuswallet/bloc/buy/buy_state.dart';

class Buy extends StatefulWidget {
  final Widget child;
  Buy({Key key, this.child}) : super(key: key);

  @override
  _BuyState createState() => _BuyState();
}

class _BuyState extends State<Buy> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BuyCubit(BuyInitial()),
      child: BlocBuilder<BuyCubit, BuyState>(builder: (context, state) {
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
