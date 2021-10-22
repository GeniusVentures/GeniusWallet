import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/cryto_details_scroll_view/cryto_details_scroll_view_state.dart';

class CrytoDetailsScrollViewCubit extends Cubit<CrytoDetailsScrollViewState> {
  CrytoDetailsScrollViewCubit(CrytoDetailsScrollViewState initialState)
      : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
