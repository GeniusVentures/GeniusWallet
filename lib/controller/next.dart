import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/next/next_cubit.dart';

import 'package:geniuswallet/bloc/next/next_state.dart';

class Next extends StatefulWidget {
  final Widget child;
  Next({Key key, this.child}) : super(key: key);

  @override
  _NextState createState() => _NextState();
}

class _NextState extends State<Next> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NextCubit(NextInitial()),
      child: BlocBuilder<NextCubit, NextState>(builder: (context, state) {
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
