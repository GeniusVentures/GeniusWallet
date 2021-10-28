import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recovery_phrase_selections_custom/recovery_phrase_selections_custom_cubit.dart';

import 'package:geniuswallet/bloc/recovery_phrase_selections_custom/recovery_phrase_selections_custom_state.dart';

class RecoveryPhraseSelectionsCustom extends StatefulWidget {
  final Widget child;
  RecoveryPhraseSelectionsCustom({Key key, this.child}) : super(key: key);

  @override
  _RecoveryPhraseSelectionsCustomState createState() =>
      _RecoveryPhraseSelectionsCustomState();
}

class _RecoveryPhraseSelectionsCustomState
    extends State<RecoveryPhraseSelectionsCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RecoveryPhraseSelectionsCustomCubit(
          RecoveryPhraseSelectionsCustomInitial()),
      child: BlocBuilder<RecoveryPhraseSelectionsCustomCubit,
          RecoveryPhraseSelectionsCustomState>(builder: (context, state) {
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
