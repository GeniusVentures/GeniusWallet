import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/next_custom/next_custom_cubit.dart';

import 'package:geniuswallet/bloc/next_custom/next_custom_state.dart';

class NextCustom extends StatefulWidget {
  final Widget child;
  NextCustom({Key key, this.child}) : super(key: key);

  @override
  _NextCustomState createState() => _NextCustomState();
}

class _NextCustomState extends State<NextCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NextCustomCubit(NextCustomInitial()),
      child: BlocBuilder<NextCustomCubit, NextCustomState>(
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
