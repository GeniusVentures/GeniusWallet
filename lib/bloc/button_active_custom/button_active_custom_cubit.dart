import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/button_active_custom/button_active_custom_state.dart';

class ButtonActiveCustomCubit extends Cubit<ButtonActiveCustomState> {
  ButtonActiveCustomCubit(ButtonActiveCustomState initialState)
      : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
