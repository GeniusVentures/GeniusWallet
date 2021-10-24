import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/genius_checkbox_custom/genius_checkbox_custom_cubit.dart';

import 'package:geniuswallet/bloc/genius_checkbox_custom/genius_checkbox_custom_state.dart';

class GeniusCheckboxCustom extends StatefulWidget {
  final Widget child;
  GeniusCheckboxCustom({Key key, this.child}) : super(key: key);

  @override
  _GeniusCheckboxCustomState createState() => _GeniusCheckboxCustomState();
}

class _GeniusCheckboxCustomState extends State<GeniusCheckboxCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GeniusCheckboxCustomCubit(GeniusCheckboxCustomInitial()),
      child: BlocBuilder<GeniusCheckboxCustomCubit, GeniusCheckboxCustomState>(
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
