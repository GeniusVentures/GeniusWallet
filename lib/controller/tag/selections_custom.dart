import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/selections_custom/selections_custom_cubit.dart';

import 'package:geniuswallet/bloc/selections_custom/selections_custom_state.dart';

class SelectionsCustom extends StatefulWidget {
  final Widget child;
  SelectionsCustom({Key key, this.child}) : super(key: key);

  @override
  _SelectionsCustomState createState() => _SelectionsCustomState();
}

class _SelectionsCustomState extends State<SelectionsCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SelectionsCustomCubit(SelectionsCustomInitial()),
      child: BlocBuilder<SelectionsCustomCubit, SelectionsCustomState>(
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
