import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/tw/hd_wallet.dart';

part 'new_wallet_event.dart';
part 'new_wallet_state.dart';

class NewWalletBloc extends Bloc<NewWalletEvent, NewWalletState> {
  final GeniusApi api;
  final HDWallet wallet;
  NewWalletBloc(
      {NewWalletState initialState = const NewWalletState(),
      required this.api,
      required this.wallet})
      : super(initialState) {
    on<LoadRecoveryPhrase>(onLoadRecoveryPhrase);

    on<RecoveryPhraseContinue>(_onRecoveryPhraseContinue);

    on<RecoveryWordTapped>(_onRecoveryWordTapped);

    on<RecoveryVerificationContinue>(_onRecoveryVerificationContinue);

    on<ToggleCheckbox>(_onToggleCheckbox);

    on<AgreementAccepted>(_onAgreementAccepted);

    on<AddWallet>(_onAddWallet);

    on<PinCreated>(_onPinCreated);

    on<PinConfirmPassed>(_onPinConfirmPassed);

    on<PinConfirmFailed>(_onPinConfirmFailed);
  }

  FutureOr<void> _onToggleCheckbox(event, emit) {
    emit(state.copyWith(acceptedWarning: !state.acceptedWarning));
  }

  FutureOr<void> _onRecoveryVerificationContinue(
      RecoveryVerificationContinue event, Emitter emit) {
    if (listEquals(state.selectedWords, state.recoveryWords)) {
      emit(state.copyWith(
        verificationStatus: VerificationStatus.passed,
      ));
    } else {
      emit(state.copyWith(
        verificationStatus: VerificationStatus.failed,
        selectedWords: [],
      ));
    }
  }

  FutureOr<void> _onRecoveryWordTapped(RecoveryWordTapped event, Emitter emit) {
    final newSelectedWords = [
      ...state.selectedWords,
      event.wordTapped,
    ];
    emit(
      state.copyWith(
        selectedWords: newSelectedWords,
        verificationStatus: VerificationStatus.inProgress,
      ),
    );
  }

  FutureOr<void> _onRecoveryPhraseContinue(
      RecoveryPhraseContinue event, Emitter emit) {
    emit(state.copyWith(
      currentStep: NewWalletStep.verifyRecoveryPhrase,
      shuffledWords: List.from(state.recoveryWords)..shuffle(),
    ));
  }

  FutureOr<void> onLoadRecoveryPhrase(
      LoadRecoveryPhrase event, Emitter<NewWalletState> emit) async {
    emit(state.copyWith(recoveryPhraseStatus: NewWalletStatus.loading));

    try {
      final recoveryWords = await api.getRecoveryPhrase(wallet);

      emit(state.copyWith(
          recoveryPhraseStatus: NewWalletStatus.loaded,
          recoveryWords: recoveryWords));
    } catch (e) {
      emit(state.copyWith(recoveryPhraseStatus: NewWalletStatus.error));
    }
  }

  Future<void> _onAddWallet(AddWallet event, Emitter emit) async {
    await api.saveWallet(event.wallet);
  }

  FutureOr<void> _onPinCreated(PinCreated event, Emitter<NewWalletState> emit) {
    emit(state.copyWith(currentStep: NewWalletStep.confirmPin));
  }

  FutureOr<void> _onPinConfirmPassed(
      PinConfirmPassed event, Emitter<NewWalletState> emit) {
    emit(state.copyWith(currentStep: NewWalletStep.copyPhrase));
  }

  FutureOr<void> _onPinConfirmFailed(
      PinConfirmFailed event, Emitter<NewWalletState> emit) {
    emit(state.copyWith(currentStep: NewWalletStep.createPin));
  }

  FutureOr<void> _onAgreementAccepted(
      AgreementAccepted event, Emitter<NewWalletState> emit) {
    if (event.userExists) {
      emit(state.copyWith(currentStep: NewWalletStep.copyPhrase));
    } else {
      emit(state.copyWith(currentStep: NewWalletStep.createPin));
    }
  }
}
