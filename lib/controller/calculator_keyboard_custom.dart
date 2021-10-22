import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/calculator_keyboard_custom/calculator_keyboard_custom_cubit.dart';

import 'package:geniuswallet/bloc/calculator_keyboard_custom/calculator_keyboard_custom_state.dart';

class CalculatorKeyboardCustom extends StatefulWidget {
  final Widget child;
  CalculatorKeyboardCustom({Key key, this.child}) : super(key: key);

  @override
  _CalculatorKeyboardCustomState createState() =>
      _CalculatorKeyboardCustomState();
}

class _CalculatorKeyboardCustomState extends State<CalculatorKeyboardCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          CalculatorKeyboardCustomCubit(CalculatorKeyboardCustomInitial()),
      child: BlocBuilder<CalculatorKeyboardCustomCubit,
          CalculatorKeyboardCustomState>(builder: (context, state) {
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
