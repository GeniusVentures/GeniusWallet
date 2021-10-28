import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/max_e_t_h_custom/max_e_t_h_custom_state.dart';

class MaxETHCustomCubit extends Cubit<MaxETHCustomState> {
  MaxETHCustomCubit(MaxETHCustomState initialState) : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
