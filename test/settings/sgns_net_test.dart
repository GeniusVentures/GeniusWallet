import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';

const _bundled = '{"net_id": 144, "node_type": "Light", "subnet_id": 0}';

void main() {
  late Directory root;
  late Directory overrides;

  setUp(() {
    root = Directory.systemTemp.createTempSync('sgns_net_test');
    overrides = Directory('${root.path}/overrides');
  });

  tearDown(() => root.deleteSync(recursive: true));

  void writeOverride(Object netId) {
    overrides.createSync(recursive: true);
    File(
      '${overrides.path}/sgns_config.json',
    ).writeAsStringSync(jsonEncode({'net_id': netId, 'node_type': 'Full'}));
  }

  Future<Map<String, dynamic>> merged() async =>
      jsonDecode(await mergeSgnsConfig(_bundled, overrides))
          as Map<String, dynamic>;

  test('no override file returns the bundle verbatim', () async {
    expect(await mergeSgnsConfig(_bundled, overrides), _bundled);
  });

  test('only net_id is taken from the override', () async {
    writeOverride(963);

    final config = await merged();

    expect(config['net_id'], 963);
    expect(config['node_type'], 'Light');
  });

  test('an unknown or non-int net_id falls back to the bundle', () async {
    writeOverride(999);
    expect((await merged())['net_id'], 144);

    writeOverride('369');
    expect((await merged())['net_id'], 144);
  });

  test('write main, read it back, then dev deletes the file once', () async {
    expect(await writeSgnsNet(overrides, SgnsNet.main), isTrue);
    expect(await readSgnsNet(overrides), SgnsNet.main);

    expect(await writeSgnsNet(overrides, SgnsNet.dev), isTrue);
    expect(File('${overrides.path}/sgns_config.json').existsSync(), isFalse);
    expect(await writeSgnsNet(overrides, SgnsNet.dev), isFalse);
  });
}
