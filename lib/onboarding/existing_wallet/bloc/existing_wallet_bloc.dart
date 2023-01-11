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
    on<ToggleLegal>(_onToggleLegal);

    on<ImportWalletSelected>(_onImportWalletSelected);

    on<WalletSecurityEntered>(_onWalletSecurityEntered);

    on<PinCreated>(_onPinCreated);

    /// On [PinCheckFailed], send user back a screen and reset pin state
    on<PinConfirmFailed>(_onPinConfirmFailed);

    on<PinConfirmPassed>(_onPinConfirmPassed);

    on<LegalAccepted>(_onLegalAccepted);
  }

  FutureOr<void> _onPinConfirmFailed(event, emit) {
    emit(state.copyWith(currentStep: FlowStep.createPin));
  }

  FutureOr<void> _onPinCreated(event, emit) {
    emit(state.copyWith(currentStep: FlowStep.confirmPin));
  }

  FutureOr<void> _onImportWalletSelected(event, emit) => emit(
        state.copyWith(
          currentStep: FlowStep.importWalletSecurity,
          selectedWallet: event.walletName,
        ),
      );

  FutureOr<void> _onToggleLegal(event, emit) =>
      emit(state.copyWith(acceptedLegal: !state.acceptedLegal));

  FutureOr<void> _onWalletSecurityEntered(
      WalletSecurityEntered event, Emitter<ExistingWalletState> emit) async {
    //TODO: Import wallet endpoints here
    emit(state.copyWith(importWalletStatus: ExistingWalletStatus.loading));

    try {
      final wallet = await geniusApi.validateWalletImport(
        walletName: event.walletName,
        walletType: event.walletType,
        securityType: event.securityType,
        securityValue: event.pasteFieldText,
      );

      if (wallet != null) {
        emit(state.copyWith(importWalletStatus: ExistingWalletStatus.success));
      } else {
        emit(state.copyWith(importWalletStatus: ExistingWalletStatus.error));
      }
    } catch (e) {
      emit(state.copyWith(importWalletStatus: ExistingWalletStatus.error));
    }
  }

  FutureOr<void> _onPinConfirmPassed(
      PinConfirmPassed event, Emitter<ExistingWalletState> emit) {
    emit(state.copyWith(currentStep: FlowStep.importWallet));
  }

  FutureOr<void> _onLegalAccepted(
      LegalAccepted event, Emitter<ExistingWalletState> emit) {
    if (event.userExists) {
      emit(state.copyWith(currentStep: FlowStep.importWallet));
    } else {
      emit(state.copyWith(currentStep: FlowStep.createPin));
    }
  }
}
