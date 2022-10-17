import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';

part 'verification_state.dart';

class VerificationCubit extends Cubit<VerificationState> {
  final GeniusApi geniusApi;
  VerificationCubit({
    required this.geniusApi,
  }) : super(VerificationState.initial);

  /// Verifies [pin] with the user-set pin
  Future<void> verifyPin(String pin) async {
    final userPin = await geniusApi.getUserPin();

    if (pin == userPin) {
      emit(VerificationState.pass);
    } else {
      emit(VerificationState.fail);
    }
  }
}
