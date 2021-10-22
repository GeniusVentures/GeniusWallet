import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/link_to_data_selector_custom/link_to_data_selector_custom_state.dart';

class LinkToDataSelectorCustomCubit
    extends Cubit<LinkToDataSelectorCustomState> {
  LinkToDataSelectorCustomCubit(LinkToDataSelectorCustomState initialState)
      : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
