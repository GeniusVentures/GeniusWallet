import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_state.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class PinCubit extends Cubit<PinState> {
  final int pinMaxLength;
  final GeniusApi geniusApi;
  PinCubit({required this.pinMaxLength, required this.geniusApi})
    : super(PinState(pinController: PinInputController()));

  TextEditingController get _textController =>
      state.pinController.textController;

  void clearAll() {
    _textController.clear();
    emit(
      state.copyWith(
        pinController: state.pinController,
        pinFullness: PinFullness.inProgress,
      ),
    );
  }

  void backspace() {
    if (_textController.text.isNotEmpty) {
      _textController.text = _textController.text.substring(
        0,
        _textController.text.length - 1,
      );
      emit(state.copyWith(pinFullness: PinFullness.completed));
    }
  }

  /// Adds [value] to the current state
  void add(String value) {
    if (_textController.text.length < pinMaxLength) {
      final newValue = '${_textController.text}$value';
      _textController.text = newValue;

      if (newValue.length == pinMaxLength) {
        emit(state.copyWith(pinFullness: PinFullness.completed));
      } else {
        emit(state.copyWith(pinFullness: PinFullness.inProgress));
      }
    }
  }

  void pinConfirmFailed() {
    _textController.clear();
    state.pinController.triggerError();
    emit(
      state.copyWith(
        pinController: state.pinController,
        displayIncorrectPin: true,
        pinFullness: PinFullness.inProgress,
      ),
    );
  }

  /// Verifies [pin] with the user-set pin
  Future<void> verifyPin() async {
    final pin = _textController.text;
    final isVerified = await geniusApi.verifyUserPin(pin);

    if (isVerified) {
      emit(state.copyWith(verificationStatus: VerificationStatus.pass));
    } else {
      pinConfirmFailed();
    }
  }

  void desktopOnChanged(String value) {
    if (value.length >= pinMaxLength) {
      emit(state.copyWith(pinFullness: PinFullness.completed));
    } else {
      emit(state.copyWith(pinFullness: PinFullness.inProgress));
    }
  }

  @override
  Future<void> close() {
    state.pinController.dispose();
    return super.close();
  }
}
