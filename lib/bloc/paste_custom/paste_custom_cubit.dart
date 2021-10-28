import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/paste_custom/paste_custom_state.dart';

class PasteCustomCubit extends Cubit<PasteCustomState> {
  PasteCustomCubit(PasteCustomState initialState) : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
