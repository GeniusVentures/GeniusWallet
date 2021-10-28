import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/paste_custom/paste_custom_cubit.dart';

import 'package:geniuswallet/bloc/paste_custom/paste_custom_state.dart';

class PasteCustom extends StatefulWidget {
  final Widget child;
  PasteCustom({Key key, this.child}) : super(key: key);

  @override
  _PasteCustomState createState() => _PasteCustomState();
}

class _PasteCustomState extends State<PasteCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasteCustomCubit(PasteCustomInitial()),
      child: BlocBuilder<PasteCustomCubit, PasteCustomState>(
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
