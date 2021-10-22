import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/protocol_selector_custom/protocol_selector_custom_cubit.dart';

import 'package:geniuswallet/bloc/protocol_selector_custom/protocol_selector_custom_state.dart';

class ProtocolSelectorCustom extends StatefulWidget {
  final Widget child;
  ProtocolSelectorCustom({Key key, this.child}) : super(key: key);

  @override
  _ProtocolSelectorCustomState createState() => _ProtocolSelectorCustomState();
}

class _ProtocolSelectorCustomState extends State<ProtocolSelectorCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          ProtocolSelectorCustomCubit(ProtocolSelectorCustomInitial()),
      child:
          BlocBuilder<ProtocolSelectorCustomCubit, ProtocolSelectorCustomState>(
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
