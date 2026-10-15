import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/main.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

class _NoKeyringStorage extends Fake implements FlutterSecureStorage {
  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) => Future.error(PlatformException(code: 'Libsecret error'));
}

void main() {
  test('an unusable secure store blocks startup with a keyring hint', () async {
    final storage = await LocalWalletStorage.create(
      secureStorage: _NoKeyringStorage(),
    );

    final blocked = await initSecureStorage(storage, isLinux: true);

    expect(blocked, isNotNull);
    expect(blocked!.message, contains('keyring'));
  });
}
