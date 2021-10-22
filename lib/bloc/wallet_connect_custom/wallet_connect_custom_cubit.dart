import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geniuswallet/bloc/wallet_connect_custom/wallet_connect_custom_state.dart';

class WalletConnectCustomCubit extends Cubit<WalletConnectCustomState> {
  WalletConnectCustomCubit(WalletConnectCustomState initialState)
      : super(initialState);

  /// TODO: @developer add functions here that emit a different state.
  ///
  /// For example, if you're coding a counter, you may want to have a function that
  /// when called, does the following:
  ///
  /// void increment() => emit(CounterActive(state.value + 1));
}
