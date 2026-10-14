import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';

const _bundled = '{"net_id": 333, "node_type": "Full", "subnet_id": 333}';

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
    ).writeAsStringSync(jsonEncode({'net_id': netId, 'node_type': 'Light'}));
  }

  Future<Map<String, dynamic>> merged() async =>
      jsonDecode(await mergeSgnsConfig(_bundled, overrides))
          as Map<String, dynamic>;

  test('no override file returns the bundle verbatim', () async {
    expect(await mergeSgnsConfig(_bundled, overrides), _bundled);
  });

  test('an override for a net that no longer ships is ignored', () async {
    writeOverride(963);

    final config = await merged();

    expect(config['net_id'], 333);
    expect(config['node_type'], 'Full');
    expect(await readSgnsNet(overrides), SgnsNet.staging);
  });

  test('an unknown or non-int net_id falls back to the bundle', () async {
    writeOverride(999);
    expect((await merged())['net_id'], 333);

    writeOverride('369');
    expect((await merged())['net_id'], 333);
  });

  test('choosing staging deletes a stale override file', () async {
    writeOverride(369);

    expect(await writeSgnsNet(overrides, SgnsNet.staging), isFalse);
    expect(File('${overrides.path}/sgns_config.json').existsSync(), isFalse);
  });
}
