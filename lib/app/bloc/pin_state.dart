import 'package:flutter/material.dart';

class PinState {
  final TextEditingController controller;
  final bool displayIncorrectPin;

  /// Status taht indicates whether the user passed or failed their verification with their set pin
  final VerificationStatus verificationStatus;

  /// Status that indicates progress on user entering their pin
  final PinFullness pinFullness;

  /// Status of async operation for saving the user's pin
  final SavePinStatus savePinStatus;

  PinState({
    required this.controller,
    this.displayIncorrectPin = false,
    this.verificationStatus = VerificationStatus.initial,
    this.pinFullness = PinFullness.initial,
    this.savePinStatus = SavePinStatus.initial,
  });

  PinState copyWith({
    TextEditingController? controller,
    bool? displayIncorrectPin,
    VerificationStatus? verificationStatus,
    PinFullness? pinFullness,
    SavePinStatus? savePinStatus,
  }) {
    return PinState(
      controller: controller ?? this.controller,
      displayIncorrectPin: displayIncorrectPin ?? this.displayIncorrectPin,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      pinFullness: pinFullness ?? this.pinFullness,
      savePinStatus: savePinStatus ?? this.savePinStatus,
    );
  }
}

enum SavePinStatus {
  initial,
  loading,
  success,
  error,
}

enum PinFullness {
  initial,
  inProgress,
  completed,
}

enum VerificationStatus {
  initial,
  pass,
  fail,
}
