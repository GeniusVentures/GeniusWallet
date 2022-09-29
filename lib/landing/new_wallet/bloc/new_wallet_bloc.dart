import 'package:flutter_bloc/flutter_bloc.dart';

part 'new_wallet_event.dart';
part 'new_wallet_state.dart';

class NewWalletBloc extends Bloc<NewWalletEvent, NewWalletState> {
  NewWalletBloc({
    NewWalletState initialState = const NewWalletState(),
  }) : super(initialState) {
    on<NewWalletEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
