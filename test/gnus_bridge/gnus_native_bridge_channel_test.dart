import 'dart:convert';
import 'dart:math';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_native_bridge_channel.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';

import 'gnus_fakes.dart';

const _name = 'ai.gnus.genius_wallet/gnus_bridge.test';
const _channel = MethodChannel(_name);
const _dev = 'http://localhost:3000';
final _reply = RegExp(r'window\.__gnusBridgeReply\((.*)\);$');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late GnusHarness h;
  late GnusNativeBridgeChannel client;
  late GnusWebBridge session;
  late List<MethodCall> sent;
  late List<String> delivered;
  var installAnswer = true;

  setUp(() async {
    h = await GnusHarness.create();
    delivered = [];
    sent = [];
    installAnswer = true;
    session = GnusWebBridge(
      handler: h.build(),
      readNet: () async => SgnsNet.staging,
      deliver: (script) async => delivered.add(script),
      dev: true,
      random: Random(1),
    );
    client = GnusNativeBridgeChannel(channel: _channel);
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, (call) async {
          sent.add(call);
          return call.method == 'install' ? installAnswer : null;
        });
  });

  tearDown(() async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);
    await h.dispose();
  });

  /// The native side reports a message, as Android, iOS and macOS do.
  Future<void> native(Object? args) async {
    final data = const StandardMethodCodec().encodeMethodCall(
      MethodCall('message', args),
    );
    await TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .handlePlatformMessage(_name, data, (_) {});
    await pumpEventQueue();
  }

  String body(String method) =>
      '${session.secretForTest}:${jsonEncode({'id': 'a', 'method': method})}';

  final allowed = gnusAllowedOrigins(SgnsNet.staging, dev: true);

  test('install sends the canonical allowlist and the shim', () async {
    final ok = await client.install(7, session, allowed);

    expect(ok, isTrue);
    final call = sent.single;
    expect(call.method, 'install');
    final args = call.arguments as Map;
    expect(args['webViewId'], 7);
    expect(args['origins'], [for (final o in allowed) o.value]);
    expect(args['shim'], session.shimSource);
  });

  test('a message from an off-list source gets 4100', () async {
    await client.install(7, session, allowed);

    await native({
      'webViewId': 7,
      'message': body(GnusRpcMethod.getAccounts),
      'source': 'https://evil.example',
    });

    expect(h.connects, isEmpty);
  });

  test(
    'a message from an allowed, connectable source gets the answer',
    () async {
      await client.install(7, session, allowed);
      session.pageStarted('$_dev/');

      await native({
        'webViewId': 7,
        'message': body(GnusRpcMethod.getAccounts),
        'source': _dev,
      });

      final reply =
          jsonDecode(_reply.firstMatch(delivered.single)!.group(1)!) as Map;
      expect((reply['result'] as Map)['version'], kGnusRpcVersion);
    },
  );

  test(
    'a macOS shaped source, with the default port left out, matches',
    () async {
      await client.install(7, session, allowed);

      await native({
        'webViewId': 7,
        'message': body(GnusRpcMethod.getAccounts),
        'source': 'http://localhost:3000',
      });

      expect(h.connects.map((o) => o.value), [_dev]);
    },
  );

  test('an unknown view or a malformed report is ignored', () async {
    await client.install(7, session, allowed);

    await native({
      'webViewId': 8,
      'message': body(GnusRpcMethod.getAccounts),
      'source': _dev,
    });
    await native({'webViewId': 7, 'message': 5, 'source': _dev});
    await native({'webViewId': 7, 'message': body('x'), 'source': null});
    await native({'webViewId': '7', 'message': body('x'), 'source': _dev});
    await native('not a map');

    expect(h.connects, isEmpty);
    expect(delivered, isEmpty);
  });

  test('an install the platform refuses leaves no session behind', () async {
    installAnswer = false;

    final ok = await client.install(7, session, allowed);
    await native({
      'webViewId': 7,
      'message': body(GnusRpcMethod.getAccounts),
      'source': _dev,
    });

    expect(ok, isFalse);
    expect(h.connects, isEmpty);
  });

  test('a missing installer reads as no bridge', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(_channel, null);

    expect(await client.install(7, session, allowed), isFalse);
  });

  test('uninstall tells the platform and forgets the view', () async {
    await client.install(7, session, allowed);

    await client.uninstall(7);
    await native({
      'webViewId': 7,
      'message': body(GnusRpcMethod.getAccounts),
      'source': _dev,
    });

    expect(sent.last.method, 'uninstall');
    expect(h.connects, isEmpty);
  });
}
