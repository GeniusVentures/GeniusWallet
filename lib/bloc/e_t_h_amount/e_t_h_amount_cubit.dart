import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/e_t_h_amount/e_t_h_amount_state.dart';

class ETHAmountCubit extends Cubit<ETHAmountState> {
  ETHAmountCubit(ETHAmountState initialState) : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
