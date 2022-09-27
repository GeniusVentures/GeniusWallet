import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/app/bloc/pin_state.dart';

class PinCubit extends Cubit<PinState> {
  final int pinMaxLength;
  PinCubit({
    required this.pinMaxLength,
  }) : super(PinStateIncomplete(controller: TextEditingController()));

  void clearAll() {
    state.controller.clear();
    emit(PinStateIncomplete(controller: state.controller));
  }

  void backspace() {
    if (state.controller.text.isNotEmpty) {
      state.controller.text =
          state.controller.text.substring(0, state.controller.text.length - 1);
      emit(PinStateIncomplete(controller: state.controller));
    }
  }

  /// Adds [value] to the current state
  void add(String value) {
    if (state.controller.text.length < pinMaxLength) {
      final newValue = '${state.controller.text}$value';
      state.controller.text = newValue;

      if (newValue.length == pinMaxLength) {
        emit(PinStateComplete(controller: state.controller));
      } else {
        emit(PinStateIncomplete(controller: state.controller));
      }
    }
  }
}
