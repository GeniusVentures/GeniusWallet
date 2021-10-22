import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/scan_custom/scan_custom_state.dart';

class ScanCustomCubit extends Cubit<ScanCustomState> {
  ScanCustomCubit(ScanCustomState initialState) : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
