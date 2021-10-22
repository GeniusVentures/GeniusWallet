import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recovery_phrase_selections/recovery_phrase_selections_cubit.dart';

import 'package:geniuswallet/bloc/recovery_phrase_selections/recovery_phrase_selections_state.dart';

class RecoveryPhraseSelections extends StatefulWidget {
  final Widget child;
  RecoveryPhraseSelections({Key key, this.child}) : super(key: key);

  @override
  _RecoveryPhraseSelectionsState createState() =>
      _RecoveryPhraseSelectionsState();
}

class _RecoveryPhraseSelectionsState extends State<RecoveryPhraseSelections> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RecoveryPhraseSelectionsCubit(RecoveryPhraseSelectionsInitial()),
      child: BlocBuilder<RecoveryPhraseSelectionsCubit,
          RecoveryPhraseSelectionsState>(builder: (context, state) {
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
