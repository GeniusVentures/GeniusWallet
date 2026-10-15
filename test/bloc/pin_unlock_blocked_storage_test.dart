import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

class _BlockedStoreApi implements GeniusApi {
  @override
  Future<bool> verifyUserPin(String pin) =>
      Future.error(const SecureStorageWriteError());

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test('a blocked store is not reported as a wrong PIN', () async {
    final cubit = PinCubit(pinMaxLength: 4, geniusApi: _BlockedStoreApi());
    addTearDown(cubit.close);
    for (final digit in ['1', '3', '5', '7']) {
      cubit.add(digit);
    }

    await cubit.verifyPin();

    expect(cubit.state.displayIncorrectPin, isFalse);
  });
}
