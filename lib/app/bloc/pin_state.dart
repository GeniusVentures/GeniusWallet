import 'package:flutter/material.dart';

abstract class PinState {
  final TextEditingController controller;

  PinState({required this.controller});
}

class PinStateIncomplete extends PinState {
  PinStateIncomplete({required super.controller});
}

class PinStateComplete extends PinState {
  PinStateComplete({required super.controller});
}
