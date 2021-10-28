import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/crypto_item_custom/crypto_item_custom_state.dart';

class CryptoItemCustomCubit extends Cubit<CryptoItemCustomState> {
  CryptoItemCustomCubit(CryptoItemCustomState initialState)
      : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
