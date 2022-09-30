import 'dart:async';

import 'package:clipboard/clipboard.dart';
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

    on<CopyRecoveryPhrase>(onCopyRecoveryPhrase);
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

  FutureOr<void> onCopyRecoveryPhrase(
      CopyRecoveryPhrase event, Emitter<NewWalletState> emit) async {
    emit(state.copyWith(
      recoveryPhraseCopied: NewWalletStatus.loading,
    ));
    try {
      await FlutterClipboard.copy(state.recoveryWords.join(" "));
      emit(state.copyWith(
        recoveryPhraseCopied: NewWalletStatus.loaded,
      ));
    } catch (e) {
      emit(state.copyWith(
        recoveryPhraseCopied: NewWalletStatus.error,
      ));
    }
  }
}
