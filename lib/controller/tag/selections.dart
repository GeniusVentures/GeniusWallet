import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/selections/selections_cubit.dart';

import 'package:geniuswallet/bloc/selections/selections_state.dart';

class Selections extends StatefulWidget {
  final Widget child;
  Selections({Key key, this.child}) : super(key: key);

  @override
  _SelectionsState createState() => _SelectionsState();
}

class _SelectionsState extends State<Selections> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectionsCubit(SelectionsInitial()),
      child: BlocBuilder<SelectionsCubit, SelectionsState>(
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
