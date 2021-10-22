import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/button_active_custom/button_active_custom_cubit.dart';

import 'package:geniuswallet/bloc/button_active_custom/button_active_custom_state.dart';

class ButtonActiveCustom extends StatefulWidget {
  final Widget child;
  ButtonActiveCustom({Key key, this.child}) : super(key: key);

  @override
  _ButtonActiveCustomState createState() => _ButtonActiveCustomState();
}

class _ButtonActiveCustomState extends State<ButtonActiveCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => ButtonActiveCustomCubit(ButtonActiveCustomInitial()),
      child: BlocBuilder<ButtonActiveCustomCubit, ButtonActiveCustomState>(
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
