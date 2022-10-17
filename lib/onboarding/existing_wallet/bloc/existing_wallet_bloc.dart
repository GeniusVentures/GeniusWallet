import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'existing_wallet_event.dart';
part 'existing_wallet_state.dart';

class ExistingWalletBloc
    extends Bloc<ExistingWalletEvent, ExistingWalletState> {
  final GeniusApi geniusApi;
  ExistingWalletBloc({
    ExistingWalletState initialState = const ExistingWalletState(),
    required this.geniusApi,
  }) : super(initialState) {
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
        ),
      ),
    );

    on<PinCheckSuccessful>(onPinCheckSuccessful);

    /// On [PinCheckFailed], send user back a screen and reset pin state
    on<PinCheckFailed>((event, emit) {
      emit(state.copyWith(
        createdPin: '',
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
      PinCheckSuccessful event, Emitter<ExistingWalletState> emit) async {
    try {
      emit(state.copyWith(
        savePinStatus: ExistingWalletStatus.success,
      ));
      await geniusApi.storeUserPin(state.createdPin);
      emit(state.copyWith(savePinStatus: ExistingWalletStatus.success));
    } catch (e) {
      emit(state.copyWith(savePinStatus: ExistingWalletStatus.error));
    }
  }
}
