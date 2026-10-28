import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';

import 'gnus_fakes.dart';

const _dev = 'http://localhost:3000';

final _reply = RegExp(r'window\.__gnusBridgeReply\((.*)\);$');

class _Rig {
  _Rig(this.h, {bool dev = true}) {
    bridge = GnusWebBridge(
      handler: h.build(),
      readNet: () async => SgnsNet.staging,
      deliver: (script) async => delivered.add(script),
      dev: dev,
      random: Random(1),
    );
  }

  final GnusHarness h;
  late final GnusWebBridge bridge;
  final List<String> delivered = [];

  String message(String method, {String id = 'doc-1', Object? params}) =>
      '${bridge.secretForTest}:${jsonEncode({'id': id, 'method': method, 'params': params})}';

  /// The reply objects delivered so far.
  List<Map<String, Object?>> get replies => [
    for (final script in delivered)
      jsonDecode(_reply.firstMatch(script)!.group(1)!) as Map<String, Object?>,
  ];
}

void main() {
  late GnusHarness h;
  late _Rig rig;

  setUp(() async {
    h = await GnusHarness.create();
    rig = _Rig(h);
    await pumpEventQueue();
  });

  tearDown(() => h.dispose());

  test('a secret-prefixed getAccounts from an allowed source gets the '
      'handler answer behind an origin guard', () async {
    await rig.bridge.onMessage(
      rig.message(GnusRpcMethod.getAccounts),
      source: _dev,
    );

    expect(h.connects.map((o) => o.value), [_dev]);
    expect(rig.delivered, hasLength(1));
    expect(
      rig.delivered.single,
      startsWith('if (location.origin === "$_dev")'),
    );
    final reply = rig.replies.single;
    expect(reply['id'], 'doc-1');
    expect((reply['result']! as Map)['version'], kGnusRpcVersion);
  });

  test('the shim carries the secret and version only as JSON strings', () {
    final shim = rig.bridge.shimSource;

    expect(shim, contains('var secret = "${rig.bridge.secretForTest}";'));
    expect(shim, contains('version: "$kGnusRpcVersion"'));
    expect(shim, isNot(contains('__SECRET__')));
    expect(shim, isNot(contains('__VERSION__')));
  });
}
