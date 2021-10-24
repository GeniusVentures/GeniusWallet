import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/paste/paste_cubit.dart';

import 'package:geniuswallet/bloc/paste/paste_state.dart';

class Paste extends StatefulWidget {
  final Widget child;
  Paste({Key key, this.child}) : super(key: key);

  @override
  _PasteState createState() => _PasteState();
}

class _PasteState extends State<Paste> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => PasteCubit(PasteInitial()),
      child: BlocBuilder<PasteCubit, PasteState>(builder: (context, state) {
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
