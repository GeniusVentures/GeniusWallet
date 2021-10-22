import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/send_button_custom/send_button_custom_cubit.dart';

import 'package:geniuswallet/bloc/send_button_custom/send_button_custom_state.dart';

class SendButtonCustom extends StatefulWidget {
  final Widget child;
  SendButtonCustom({Key key, this.child}) : super(key: key);

  @override
  _SendButtonCustomState createState() => _SendButtonCustomState();
}

class _SendButtonCustomState extends State<SendButtonCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => SendButtonCustomCubit(SendButtonCustomInitial()),
      child: BlocBuilder<SendButtonCustomCubit, SendButtonCustomState>(
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
