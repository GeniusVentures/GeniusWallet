import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/exit_button_custom/exit_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/exit_button_custom/exit_button_custom_state.dart';

class ExitButtonCustom extends StatefulWidget {
  final Widget child;
  ExitButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _ExitButtonCustomState createState() => _ExitButtonCustomState();
}

class _ExitButtonCustomState extends State<ExitButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ExitButtonCustomCubit(ExitButtonCustomInitial()),
      child: BlocBuilder<ExitButtonCustomCubit, ExitButtonCustomState>(
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
