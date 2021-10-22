import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/menu_custom/menu_custom_state.dart';

class MenuCustomCubit extends Cubit<MenuCustomState> {
  MenuCustomCubit(MenuCustomState initialState) : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
