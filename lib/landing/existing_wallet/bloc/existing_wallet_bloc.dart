import 'package:flutter_bloc/flutter_bloc.dart';

part 'existing_wallet_event.dart';
part 'existing_wallet_state.dart';

class ExistingWalletBloc
    extends Bloc<ExistingWalletEvent, ExistingWalletState> {
  ExistingWalletBloc() : super(ExistingWalletState()) {
    on<ToggleLegal>((event, emit) =>
        emit(state.copyWith(acceptedLegal: !state.acceptedLegal)));

    on<ChangeStep>(
        (event, emit) => emit(state.copyWith(currentStep: event.step)));

    on<ImportWalletSelected>(
      (event, emit) => emit(
        state.copyWith(
          currentStep: FlowStep.importWalletSecurity,
          selectedWallet: event.walletName,
        ),
      ),
    );
  }
}
