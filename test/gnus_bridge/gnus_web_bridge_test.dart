import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';

import 'gnus_fakes.dart';

const _dev = 'http://localhost:3000';

final _reply = RegExp(r'window\.__gnusBridgeReply\((.*)\);$');

class _Rig {
  _Rig(
    this.h, {
    bool dev = true,
    GnusConnect? connect,
    Future<SgnsNet> Function()? readNet,
  }) {
    bridge = GnusWebBridge(
      handler: h.build(connect: connect),
      readNet: readNet ?? () async => SgnsNet.staging,
      deliver: (script) async => delivered.add(script),
      dev: dev,
      random: Random(1),
    );
  }

  final GnusHarness h;
  late final GnusWebBridge bridge;
  final List<String> delivered = [];

  String message(String method, {String id = 'doc-1', Object? params}) {
    final body = jsonEncode({'id': id, 'method': method, 'params': params});
    return '${bridge.secretForTest}:$body';
  }

  /// The reply objects delivered so far.
  List<Map<String, Object?>> get replies => [
    for (final script in delivered)
      jsonDecode(_reply.firstMatch(script)!.group(1)!) as Map<String, Object?>,
  ];

  /// The error codes of the replies delivered so far.
  List<Object?> get errorCodes => [
    for (final reply in replies) (reply['error']! as Map)['code'],
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

  test('the user agent marker names the app and the contract version', () {
    expect(gnusUserAgentSuffix, matches(RegExp(r'^ GeniusWallet/\S* gnus/1$')));
  });

  test('the shim carries the secret and version only as JSON strings', () {
    final shim = rig.bridge.shimSource;

    expect(shim, contains('var secret = "${rig.bridge.secretForTest}";'));
    expect(shim, contains('version: "$kGnusRpcVersion"'));
    expect(shim, isNot(contains('__SECRET__')));
    expect(shim, isNot(contains('__VERSION__')));
  });

  group('input the page controls', () {
    test(
      'a message without the right secret, or malformed, does nothing',
      () async {
        final secret = rig.bridge.secretForTest;
        String body(Map<String, Object?> m) => '$secret:${jsonEncode(m)}';
        const method = GnusRpcMethod.getAccounts;
        final inputs = [
          jsonEncode({'id': 'a', 'method': method}),
          ':${jsonEncode({'id': 'a', 'method': method})}',
          '${'0' * secret.length}:${jsonEncode({'id': 'a', 'method': method})}',
          '$secret:not json',
          '$secret:[]',
          body({'method': method}),
          body({'id': 7, 'method': method}),
          body({'id': '', 'method': method}),
          body({'id': 'a', 'method': 5}),
          body({'id': 'a' * 65, 'method': method}),
          secret,
          '',
        ];
        rig.bridge.pageCommitted('$_dev/');

        for (final raw in inputs) {
          await rig.bridge.onMessage(raw, source: _dev);
        }

        expect(rig.delivered, isEmpty);
        expect(h.connects, isEmpty);
      },
    );

    test('quotes and script tags stay inside the JSON of the reply', () async {
      const id = '"});alert(1);//</script>\n';
      await rig.bridge.onMessage(
        rig.message('x"</script>', id: id),
        source: _dev,
      );

      expect(rig.delivered, hasLength(1));
      final script = rig.delivered.single;
      expect(script, startsWith('if (location.origin === "$_dev") window.'));
      expect(script.split('\n'), hasLength(1));
      expect(rig.replies.single['id'], id);
      expect(rig.errorCodes, [GnusRpcCode.unsupportedMethod]);
    });
  });

  group('who is calling', () {
    test('a source that is not an origin gets 4100 and no prompt', () async {
      rig.bridge.pageCommitted('$_dev/page');

      for (final source in ['', 'null', 'about:blank', 'file:///x']) {
        await rig.bridge.onMessage(
          rig.message(GnusRpcMethod.getAccounts),
          source: source,
        );
      }

      expect(rig.errorCodes, List.filled(4, GnusRpcCode.unauthorized));
      expect(h.connects, isEmpty);
    });

    test('a page nobody can vouch for, such as one leaving before the next '
        'commits, is dropped unanswered', () async {
      rig.bridge.pageCommitted('$_dev/page');

      await rig.bridge.onMessage(
        rig.message(GnusRpcMethod.getAccounts),
        source: null,
      );

      expect(rig.delivered, isEmpty);
      expect(h.connects, isEmpty);
    });

    test(
      'an off-list source gets 4100 and the handler is not called',
      () async {
        rig.bridge.pageCommitted('$_dev/');

        await rig.bridge.onMessage(
          rig.message(GnusRpcMethod.getAccounts),
          source: 'https://evil.example/path',
        );

        expect(h.connects, isEmpty);
        expect(rig.errorCodes, [GnusRpcCode.unauthorized]);
      },
    );

    test('the payload cannot name the caller', () async {
      final body = jsonEncode({
        'id': 'a',
        'method': GnusRpcMethod.getAccounts,
        'origin': _dev,
        'params': {'origin': _dev},
      });

      await rig.bridge.onMessage(
        '${rig.bridge.secretForTest}:$body',
        source: 'https://evil.example',
      );

      expect(h.connects, isEmpty);
    });

    test('a non-dev session rejects the dev origin', () async {
      final prod = _Rig(h, dev: false);

      await prod.bridge.onMessage(
        prod.message(GnusRpcMethod.getAccounts),
        source: _dev,
      );

      expect(h.connects, isEmpty);
      expect(prod.errorCodes, [GnusRpcCode.unauthorized]);
    });

    test('a failed net read answers an internal error', () async {
      final broken = _Rig(h, readNet: () async => throw StateError('x'));

      await broken.bridge.onMessage(
        broken.message(GnusRpcMethod.getAccounts),
        source: _dev,
      );

      expect(h.connects, isEmpty);
      expect(broken.errorCodes, [GnusRpcCode.internal]);
    });
  });

  group('a page that moved on', () {
    test('a new document while the prompt is open drops the reply', () async {
      final answer = Completer<bool>();
      final held = _Rig(
        h,
        connect: ({required GnusOrigin origin}) => answer.future,
      );
      held.bridge.pageCommitted('$_dev/');

      final call = held.bridge.onMessage(
        held.message(GnusRpcMethod.getAccounts),
        source: _dev,
      );
      await pumpEventQueue();
      held.bridge.pageCommitted('$_dev/next');
      answer.complete(true);
      await call;

      expect(held.delivered, isEmpty);
    });

    test(
      'a new document before the net read returns never reaches the handler',
      () async {
        final net = Completer<SgnsNet>();
        final held = _Rig(h, readNet: () => net.future);

        final call = held.bridge.onMessage(
          held.message(GnusRpcMethod.getAccounts),
          source: _dev,
        );
        await pumpEventQueue();
        held.bridge.pageCommitted('$_dev/next');
        net.complete(SgnsNet.staging);
        await call;

        expect(h.connects, isEmpty);
        expect(held.delivered, isEmpty);
      },
    );

    test('a reply for a page that has not moved is delivered', () async {
      rig.bridge.pageCommitted('$_dev/');

      await rig.bridge.onMessage(
        rig.message(GnusRpcMethod.getAccounts),
        source: _dev,
      );

      expect(rig.delivered, hasLength(1));
    });
  });

  group('events', () {
    final other = AppState(selectedSDKAccount: '0x${'d' * 128}');

    /// Connects the dev origin and starts its page, as a real load does.
    Future<void> connectedPage(_Rig r) async {
      r.bridge.pageCommitted('$_dev/');
      await r.bridge.onMessage(
        r.message(GnusRpcMethod.getAccounts),
        source: _dev,
      );
      r.delivered.clear();
    }

    List<String> events(_Rig r) => [
      for (final script in r.delivered)
        if (script.contains('__gnusBridgeEvent(')) script,
    ];

    test(
      'an accountsChanged reaches the page behind the origin guard',
      () async {
        await connectedPage(rig);

        h.pushApp(other);
        await pumpEventQueue();

        final sent = events(rig);
        expect(sent, hasLength(1));
        expect(
          sent.single,
          startsWith(
            'if (location.origin === "$_dev") window.__gnusBridgeEvent('
            '"${GnusRpcEventName.accountsChanged}", {',
          ),
        );
      },
    );

    test('a page that is not connected gets nothing', () async {
      rig.bridge.pageCommitted('$_dev/');
      await pumpEventQueue();

      h.pushApp(other);
      await pumpEventQueue();

      expect(rig.delivered, isEmpty);
    });

    test('a revoked origin gets nothing', () async {
      await connectedPage(rig);

      await h.connections.revoke(webOrigin(_dev));
      h.pushApp(other);
      await pumpEventQueue();

      expect(events(rig), isEmpty);
    });

    test('the next document ends the earlier subscription', () async {
      await connectedPage(rig);

      rig.bridge.pageCommitted('https://evil.example/');
      await pumpEventQueue();
      h.pushApp(other);
      await pumpEventQueue();

      expect(rig.delivered, isEmpty);
    });

    test('a reload of the same page keeps exactly one subscription', () async {
      await connectedPage(rig);

      rig.bridge.pageCommitted('$_dev/again');
      await pumpEventQueue();
      h.pushApp(other);
      await pumpEventQueue();

      expect(events(rig), hasLength(1));
    });

    test('dispose ends delivery, and later documents stay quiet', () async {
      await connectedPage(rig);

      await rig.bridge.dispose();
      rig.bridge.pageCommitted('$_dev/');
      await pumpEventQueue();
      h.pushApp(other);
      await pumpEventQueue();

      expect(rig.delivered, isEmpty);
    });
  });
}
