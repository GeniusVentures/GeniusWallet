import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recovery_phrase_field_custom/recovery_phrase_field_custom_cubit.dart';

import 'package:geniuswallet/bloc/recovery_phrase_field_custom/recovery_phrase_field_custom_state.dart';

class RecoveryPhraseFieldCustom extends StatefulWidget {
  final Widget child;
  RecoveryPhraseFieldCustom({Key key, this.child}) : super(key: key);

  @override
  _RecoveryPhraseFieldCustomState createState() =>
      _RecoveryPhraseFieldCustomState();
}

class _RecoveryPhraseFieldCustomState extends State<RecoveryPhraseFieldCustom> {
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          RecoveryPhraseFieldCustomCubit(RecoveryPhraseFieldCustomInitial()),
      child: BlocBuilder<RecoveryPhraseFieldCustomCubit,
          RecoveryPhraseFieldCustomState>(builder: (context, state) {
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
