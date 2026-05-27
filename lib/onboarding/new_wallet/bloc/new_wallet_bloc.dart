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

    on<RecoveryWordAssign>(_onRecoveryWordAssign);

    on<RecoveryVerificationContinue>(_onRecoveryVerificationContinue);

    on<RecoveryVerificationContinueForMobile>(
        _onRecoveryVerificationContinueForMobile);

    on<ToggleCheckbox>((event, emit) {
      emit(state.copyWith(acceptedWarning: !state.acceptedWarning));
    });

    on<AgreementAccepted>(_onAgreementAccepted);

    on<AddWallet>((event, emit) async {
      await api.saveWallet(event.wallet);
    });

    on<PinCreated>((event, emit) {
      emit(state.copyWith(currentStep: NewWalletStep.confirmPin));
    });

    on<PinConfirmPassed>((event, emit) {
      emit(state.copyWith(currentStep: NewWalletStep.copyPhrase));
    });

    on<PinConfirmFailed>((event, emit) {
      emit(state.copyWith(currentStep: NewWalletStep.createPin));
    });

    on<GoBack>(_onGoBack);
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

  bool checkMatchingOrder(
      List<String> recoveryWords, List<String> shuffledWords) {
    // Create a mapping from words to their indices in recoveryWords
    Map<String, int> indexMap = {};
    for (int i = 0; i < recoveryWords.length; i++) {
      indexMap[recoveryWords[i]] = i;
    }

    // Get the indices of shuffledWords based on recoveryWords
    List<int> indices = [];
    for (String word in shuffledWords) {
      if (indexMap.containsKey(word)) {
        indices.add(indexMap[word]!);
      }
    }

    // Check if the indices are in sorted order
    for (int i = 1; i < indices.length; i++) {
      if (indices[i] < indices[i - 1]) {
        return false;
      }
    }

    return true;
  }

  FutureOr<void> _onRecoveryVerificationContinueForMobile(
      RecoveryVerificationContinueForMobile event, Emitter emit) {
    if (checkMatchingOrder(state.recoveryWords, state.selectedWords)) {
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

  FutureOr<void> _onRecoveryWordAssign(RecoveryWordAssign event, Emitter emit) {
    final newSelectedWords = event.recoverywords;
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

  FutureOr<void> _onAgreementAccepted(
      AgreementAccepted event, Emitter<NewWalletState> emit) {
    if (event.userExists) {
      emit(state.copyWith(currentStep: NewWalletStep.copyPhrase));
    } else {
      emit(state.copyWith(currentStep: NewWalletStep.createPin));
    }
  }

  void _onGoBack(GoBack event, Emitter<NewWalletState> emit) {
    switch (state.currentStep) {
      case NewWalletStep.agreement:
        break; // First step — PopScope handles route pop
      case NewWalletStep.createPin:
        emit(state.copyWith(currentStep: NewWalletStep.agreement));
      case NewWalletStep.confirmPin:
        emit(state.copyWith(currentStep: NewWalletStep.createPin));
      case NewWalletStep.copyPhrase:
        emit(state.copyWith(currentStep: NewWalletStep.agreement));
      case NewWalletStep.verifyRecoveryPhrase:
        emit(state.copyWith(currentStep: NewWalletStep.copyPhrase));
    }
  }
}
