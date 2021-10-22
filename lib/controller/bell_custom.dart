import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/bell_custom/bell_custom_cubit.dart';

import 'package:geniuswallet/bloc/bell_custom/bell_custom_state.dart';

class BellCustom extends StatefulWidget {
  final Widget child;
  BellCustom({Key key, this.child}) : super(key: key);

  @override
  _BellCustomState createState() => _BellCustomState();
}

class _BellCustomState extends State<BellCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => BellCustomCubit(BellCustomInitial()),
      child: BlocBuilder<BellCustomCubit, BellCustomState>(
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
