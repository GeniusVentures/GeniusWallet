import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recieve_button_custom/recieve_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/recieve_button_custom/recieve_button_custom_state.dart';

class RecieveButtonCustom extends StatefulWidget {
  final Widget child;
  RecieveButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _RecieveButtonCustomState createState() => _RecieveButtonCustomState();
}

class _RecieveButtonCustomState extends State<RecieveButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecieveButtonCustomCubit(RecieveButtonCustomInitial()),
      child: BlocBuilder<RecieveButtonCustomCubit, RecieveButtonCustomState>(
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
