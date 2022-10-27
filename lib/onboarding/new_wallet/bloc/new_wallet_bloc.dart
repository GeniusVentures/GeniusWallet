import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'new_wallet_event.dart';
part 'new_wallet_state.dart';

class NewWalletBloc extends Bloc<NewWalletEvent, NewWalletState> {
  final GeniusApi api;
  NewWalletBloc({
    NewWalletState initialState = const NewWalletState(),
    required this.api,
  }) : super(initialState) {
    on<LoadRecoveryPhrase>(onLoadRecoveryPhrase);

    on<RecoveryPhraseContinue>(((event, emit) {
      emit(state.copyWith(
        currentStep: NewWalletStep.verifyRecoveryPhrase,
        shuffledWords: List.from(state.recoveryWords)..shuffle(),
      ));
    }));

    on<RecoveryWordTapped>((event, emit) {
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
    });

    on<RecoveryVerificationContinue>((event, emit) {
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
    });

    on<ToggleCheckbox>((event, emit) {
      emit(state.copyWith(acceptedWarning: !state.acceptedWarning));
    });

    on<ChangeStep>(
        (event, emit) => emit(state.copyWith(currentStep: event.step)));
  }

  FutureOr<void> onLoadRecoveryPhrase(
      LoadRecoveryPhrase event, Emitter<NewWalletState> emit) async {
    emit(state.copyWith(recoveryPhraseStatus: NewWalletStatus.loading));

    try {
      final recoveryWords = await api.getRecoveryPhrase();
      emit(state.copyWith(
        recoveryPhraseStatus: NewWalletStatus.loaded,
        recoveryWords: recoveryWords,
      ));
    } catch (e) {
      emit(state.copyWith(recoveryPhraseStatus: NewWalletStatus.error));
    }
  }
}
