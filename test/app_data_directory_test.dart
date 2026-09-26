import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/hive/constants/cache.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory temp;
  late Directory docs;

  setUp(() {
    temp = Directory.systemTemp.createTempSync('app_data_dir_');
    docs = Directory('${temp.path}/Documents')..createSync();
  });

  tearDown(() => temp.deleteSync(recursive: true));

  String pick(String os, Map<String, String> env) => pickAppDataDirectory(
        documents: docs,
        operatingSystem: os,
        environment: env,
      ).path;

  test('existing installs are detected by the wallet box file', () {
    expect(walletBoxName, 'wallet');
  });

  group('windows', () {
    test('a new install uses LOCALAPPDATA and creates nothing', () {
      final local = '${temp.path}\\Local';
      final expected = '$local\\GeniusVentures\\GeniusWallet';

      expect(pick('windows', {'LOCALAPPDATA': local}), expected);
      expect(Directory(expected).existsSync(), isFalse);
    });

    test('an unrelated file in Documents does not make it existing', () {
      File('${docs.path}/notes.txt').writeAsStringSync('x');

      expect(
        pick('windows', {'LOCALAPPDATA': 'L'}),
        'L\\GeniusVentures\\GeniusWallet',
      );
    });

    test('a 0-byte wallet.hive keeps Documents', () {
      File('${docs.path}/wallet.hive').createSync();

      expect(pick('windows', {'LOCALAPPDATA': 'L'}), docs.path);
    });

    test('secure_storage_id alone keeps Documents', () {
      Directory('${docs.path}/secure_storage_id').createSync();

      expect(pick('windows', {'LOCALAPPDATA': 'L'}), docs.path);
    });

    test('a missing or empty LOCALAPPDATA falls back to Documents', () {
      expect(pick('windows', {}), docs.path);
      expect(pick('windows', {'LOCALAPPDATA': ''}), docs.path);
    });
  });

  group('linux', () {
    test('XDG_DATA_HOME wins when absolute', () {
      expect(
        pick('linux', {'XDG_DATA_HOME': '/x/data', 'HOME': '/home/u'}),
        '/x/data/GeniusWallet',
      );
    });

    test('an empty or relative XDG_DATA_HOME falls back to HOME', () {
      const fallback = '/home/u/.local/share/GeniusWallet';
      expect(pick('linux', {'XDG_DATA_HOME': '', 'HOME': '/home/u'}), fallback);
      expect(
        pick('linux', {'XDG_DATA_HOME': 'data', 'HOME': '/home/u'}),
        fallback,
      );
      expect(pick('linux', {'HOME': '/home/u'}), fallback);
    });

    test('wallet.hive in Documents keeps Documents', () {
      File('${docs.path}/wallet.hive').createSync();

      expect(pick('linux', {'XDG_DATA_HOME': '/x/data'}), docs.path);
    });
  });

  test('macos, android and ios keep Documents', () {
    const env = {'LOCALAPPDATA': 'L', 'XDG_DATA_HOME': '/x', 'HOME': '/h'};
    for (final os in ['macos', 'android', 'ios']) {
      expect(pick(os, env), docs.path, reason: os);
    }
  });

  test('a failed lookup is retried, a successful one is remembered', () async {
    // A marker in the fake Documents keeps the real local data folder untouched.
    File('${docs.path}/wallet.hive').createSync();
    const channel = MethodChannel('plugins.flutter.io/path_provider');
    final messenger =
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    await expectLater(appDataDirectory(), throwsA(isA<MissingPluginException>()));

    messenger.setMockMethodCallHandler(channel, (_) async => docs.path);
    final first = appDataDirectory();
    expect((await first).path, docs.path);
    expect(appDataDirectory(), same(first));
  });
}
