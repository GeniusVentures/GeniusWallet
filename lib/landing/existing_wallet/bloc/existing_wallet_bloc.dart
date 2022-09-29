import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

part 'existing_wallet_event.dart';
part 'existing_wallet_state.dart';

class ExistingWalletBloc
    extends Bloc<ExistingWalletEvent, ExistingWalletState> {
  ExistingWalletBloc({ExistingWalletState initialState = const ExistingWalletState()})
      : super(initialState) {
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

    on<WalletSecurityEntered>(onWalletSecurityEntered);

    on<PinCreated>(
      (event, emit) => emit(
        state.copyWith(
          createdPin: event.pin,
          currentStep: FlowStep.confirmPin,
          failedPinVerification: false,
        ),
      ),
    );

    on<PinCheckSuccessful>(onPinCheckSuccessful);

    /// On [PinCheckFailed], send user back a screen and reset pin state
    on<PinCheckFailed>((event, emit) {
      emit(state.copyWith(
        failedPinVerification: true,
        createdPin: '',
        currentStep: FlowStep.createPin,
      ));
    });
  }

  FutureOr<void> onWalletSecurityEntered(
      WalletSecurityEntered event, Emitter<ExistingWalletState> emit) {
    /// TODO: Can check the [state] here and validate wallet information. Then send another event failing
    /// import if necessary
    emit(state.copyWith(
      currentStep: FlowStep.createPin,
    ));
  }

  FutureOr<void> onPinCheckSuccessful(
      PinCheckSuccessful event, Emitter<ExistingWalletState> emit) {
    ///TODO: Can check the [state] here and send the pin to the API.
    emit(state.copyWith());
  }
}
