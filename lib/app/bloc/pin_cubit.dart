import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/app/bloc/pin_state.dart';

class PinCubit extends Cubit<PinState> {
  final int pinMaxLength;
  final GeniusApi geniusApi;
  PinCubit({
    required this.pinMaxLength,
    required this.geniusApi,
  }) : super(PinState(controller: TextEditingController()));

  void clearAll() {
    state.controller.clear();
    emit(state.copyWith(
      controller: state.controller,
      pinFullness: PinFullness.inProgress,
    ));
  }

  void backspace() {
    if (state.controller.text.isNotEmpty) {
      state.controller.text =
          state.controller.text.substring(0, state.controller.text.length - 1);
      emit(state.copyWith(
        pinFullness: PinFullness.completed,
      ));
    }
  }

  /// Adds [value] to the current state
  void add(String value) {
    if (state.controller.text.length < pinMaxLength) {
      final newValue = '${state.controller.text}$value';
      state.controller.text = newValue;

      if (newValue.length == pinMaxLength) {
        emit(state.copyWith(pinFullness: PinFullness.completed));
      } else {
        emit(state.copyWith(
          pinFullness: PinFullness.inProgress,
        ));
      }
    }
  }

  void pinConfirmFailed() {
    state.controller.clear();
    emit(state.copyWith(
      controller: state.controller,
      displayIncorrectPin: true,
      pinFullness: PinFullness.inProgress,
    ));
  }

  /// Verifies [pin] with the user-set pin
  Future<void> verifyPin() async {
    final pin = state.controller.text;
    final isVerified = await geniusApi.verifyUserPin(pin);

    if (isVerified) {
      emit(state.copyWith(verificationStatus: VerificationStatus.pass));
    } else {
      pinConfirmFailed();
    }
  }
}
