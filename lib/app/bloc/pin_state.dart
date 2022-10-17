import 'package:flutter/material.dart';

abstract class PinState {
  final TextEditingController controller;
  final bool displayIncorrectPin;

  PinState({
    required this.controller,
    this.displayIncorrectPin = false,
  });
}

class PinStateIncomplete extends PinState {
  PinStateIncomplete({
    required super.controller,
    super.displayIncorrectPin,
  });
}

class PinStateComplete extends PinState {
  PinStateComplete({
    required super.controller,
    super.displayIncorrectPin,
  });
}
