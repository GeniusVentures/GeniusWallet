import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/recovery_phrase_field_custom/recovery_phrase_field_custom_state.dart';

class RecoveryPhraseFieldCustomCubit
    extends Cubit<RecoveryPhraseFieldCustomState> {
  RecoveryPhraseFieldCustomCubit(RecoveryPhraseFieldCustomState initialState)
      : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
