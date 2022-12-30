import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_state.dart';

class NewPinCubit extends Cubit<NewPinState> {
  final GeniusApi api;
  NewPinCubit({required this.api}) : super(const NewPinState());

  /// Saves the current pin to state to confirm later
  void pinEntered(String pin) {
    emit(state.copyWith(
      pinToConfirm: pin,
      pinConfirmStatus: PinConfirmStatus.awaitingVerification,
    ));
  }

  /// Compared [currentPin] with [state.pinToConfirm] and
  /// saves the pins if they match.
  ///
  /// Emits a [PinConfirmStatus.failed] status otherwise.
  Future<void> pinConfirmSubmitted(String currentPin) async {
    if (currentPin == state.pinToConfirm) {
      emit(state.copyWith(
        pinSaveStatus: PinSaveStatus.loading,
        pinConfirmStatus: PinConfirmStatus.passed,
      ));

      try {
        await api.storeUserPin(currentPin);
        emit(state.copyWith(pinSaveStatus: PinSaveStatus.saved));
      } catch (e) {
        emit(state.copyWith(pinSaveStatus: PinSaveStatus.error));
      }
    } else {
      emit(
        state.copyWith(
          pinConfirmStatus: PinConfirmStatus.failed,
        ),
      );
    }
  }
}
