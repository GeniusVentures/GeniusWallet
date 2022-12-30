import 'package:equatable/equatable.dart';

class NewPinState extends Equatable {
  final String pinToConfirm;
  final PinConfirmStatus pinConfirmStatus;
  final PinSaveStatus pinSaveStatus;

  const NewPinState({
    this.pinToConfirm = '',
    this.pinConfirmStatus = PinConfirmStatus.initial,
    this.pinSaveStatus = PinSaveStatus.initial,
  });

  NewPinState copyWith({
    String? pinToConfirm,
    PinConfirmStatus? pinConfirmStatus,
    PinSaveStatus? pinSaveStatus,
  }) {
    return NewPinState(
      pinToConfirm: pinToConfirm ?? this.pinToConfirm,
      pinConfirmStatus: pinConfirmStatus ?? this.pinConfirmStatus,
      pinSaveStatus: pinSaveStatus ?? this.pinSaveStatus,
    );
  }

  @override
  List<Object?> get props => [
        pinToConfirm,
        pinConfirmStatus,
        pinSaveStatus,
      ];
}

/// Status for whether the pins entered match or not
enum PinConfirmStatus {
  initial,
  awaitingVerification,
  passed,
  failed,
}

/// Status for whether the confirmed pin was successfully saved
enum PinSaveStatus {
  initial,
  loading,
  saved,
  error,
}
