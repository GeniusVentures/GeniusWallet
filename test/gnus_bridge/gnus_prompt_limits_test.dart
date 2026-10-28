import 'dart:async';

import 'package:fake_async/fake_async.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';

import 'gnus_fakes.dart';

final _origin = webOrigin('https://dash.example');
final _other = webOrigin('https://other.example');
const _accounts = GnusRpcMethod.getAccounts;
const _submit = GnusRpcMethod.submitJob;

Map<String, Object?> _params(String key) => {
  'job': {
    'inputs': ['a'],
  },
  'idempotencyKey': key,
};

Map<String, Object?> _error(Map<String, Object?> reply) =>
    reply['error']! as Map<String, Object?>;

Object? _reason(Map<String, Object?> reply) =>
    (_error(reply)['data'] as Map?)?['reason'];

void main() {
  late GnusHarness h;

  setUp(() async {
    h = await GnusHarness.create();
  });

  tearDown(() => h.dispose());

  Future<bool> approveConfirm({
    required GnusOrigin origin,
    required String cost,
    required Map<String, String>? gas,
    required String payer,
    required String nodeAccount,
  }) async => true;

  group('one open prompt per origin', () {
    test('a second call during a connect gets confirm_open at once', () async {
      final held = Completer<bool>();
      final asked = <GnusOrigin>[];
      final handler = h.build(
        connect: ({required GnusOrigin origin}) {
          asked.add(origin);
          return origin == _origin ? held.future : Future.value(true);
        },
      );

      final first = viaJson(handler, _origin, _accounts, null);
      await pumpEventQueue();
      final second = await viaJson(handler, _origin, _accounts, null);
      final otherOrigin = await viaJson(handler, _other, _accounts, null);

      expect(_error(second)['code'], GnusRpcCode.busy);
      expect(_reason(second), GnusRpcReason.confirmOpen);
      expect(otherOrigin['result'], isNotNull);
      expect(asked, [_origin, _other]);

      held.complete(true);
      expect((await first)['result'], isNotNull);
    });

    test(
      'a submit during a confirm gets confirm_open, reads still pass',
      () async {
        await h.connections.connect(_origin, h.clock);
        final held = Completer<bool>();
        var asked = 0;
        final handler = h.build(
          confirm:
              ({
                required GnusOrigin origin,
                required String cost,
                required Map<String, String>? gas,
                required String payer,
                required String nodeAccount,
              }) {
                asked++;
                return asked == 1 ? Future.value(true) : held.future;
              },
        );
        final recorded = await viaJson(
          handler,
          _origin,
          _submit,
          _params('k0'),
        );
        expect(recorded['result'], isNotNull);

        final open = viaJson(handler, _origin, _submit, _params('k1'));
        await pumpEventQueue();
        final refused = await viaJson(handler, _origin, _submit, _params('k2'));
        final read = await viaJson(handler, _origin, _accounts, null);
        final replay = await viaJson(handler, _origin, _submit, _params('k0'));

        expect(_reason(refused), GnusRpcReason.confirmOpen);
        expect(h.api.count('burn'), 1);
        expect(read['result'], isNotNull);
        expect(replay, recorded);
        expect(asked, 2);

        held.complete(false);
        expect(_error(await open)['code'], GnusRpcCode.userRejected);
      },
    );
  });

  group('three prompts a minute', () {
    test('the fourth is rate_limited with no prompt, then it clears', () async {
      var asked = 0;
      final handler = h.build(
        connect: ({required GnusOrigin origin}) async {
          asked++;
          return false;
        },
      );

      for (var i = 0; i < 3; i++) {
        final reply = await viaJson(handler, _origin, _accounts, null);
        expect(_error(reply)['code'], GnusRpcCode.userRejected);
      }
      final limited = await viaJson(handler, _origin, _accounts, null);
      final otherOrigin = await viaJson(handler, _other, _accounts, null);

      expect(_error(limited)['code'], GnusRpcCode.busy);
      expect(_reason(limited), GnusRpcReason.rateLimited);
      expect(_error(otherOrigin)['code'], GnusRpcCode.userRejected);
      expect(asked, 4);

      h.clock = h.clock.add(const Duration(seconds: 61));
      final later = await viaJson(handler, _origin, _accounts, null);

      expect(_error(later)['code'], GnusRpcCode.userRejected);
      expect(asked, 5);
    });

    test('a connect and two confirms use up the three', () async {
      final handler = h.build(confirm: approveConfirm);

      expect(
        (await viaJson(handler, _origin, _accounts, null))['result'],
        isNotNull,
      );
      expect(
        (await viaJson(handler, _origin, _submit, _params('k1')))['result'],
        isNotNull,
      );
      h.api.burnResponse = ApiResponse.success('0xsecond');
      expect(
        (await viaJson(handler, _origin, _submit, _params('k2')))['result'],
        isNotNull,
      );
      final third = await viaJson(handler, _origin, _submit, _params('k3'));

      expect(_reason(third), GnusRpcReason.rateLimited);
      expect(h.api.count('burn'), 2);
    });

    test('a prompt that timed out counts toward the three', () {
      var asked = 0;
      final handler = h.build(
        connect: ({required GnusOrigin origin}) {
          asked++;
          return Completer<bool>().future;
        },
      );
      final replies = <Map<String, Object?>>[];

      fakeAsync((async) {
        for (var i = 0; i < 4; i++) {
          viaJson(handler, _origin, _accounts, null).then(replies.add);
          async.elapse(kGnusConfirmTimeout);
        }
      });

      expect(replies.map((r) => _error(r)['code']), [
        GnusRpcCode.userRejected,
        GnusRpcCode.userRejected,
        GnusRpcCode.userRejected,
        GnusRpcCode.busy,
      ]);
      expect(asked, 3);
    });
  });

  group('a revoke lands on calls in flight', () {
    test('a read that finishes after the revoke is 4100', () async {
      await h.connections.connect(_origin, h.clock);
      final release = Completer<void>();
      h.api.onNet = () => release.future;
      final handler = h.build();

      final read = viaJson(handler, _origin, _accounts, null);
      await pumpEventQueue();
      await h.connections.revoke(_origin);
      release.complete();
      final reply = await read;

      expect(_error(reply)['code'], GnusRpcCode.unauthorized);
      expect(reply['result'], isNull);
    });

    test('a revoke and a reconnect during the call still answers', () async {
      await h.connections.connect(_origin, h.clock);
      final release = Completer<void>();
      h.api.onNet = () => release.future;
      final handler = h.build();

      final read = viaJson(handler, _origin, _accounts, null);
      await pumpEventQueue();
      await h.connections.revoke(_origin);
      await h.connections.connect(_origin, h.clock);
      release.complete();

      expect((await read)['result'], isNotNull);
    });

    test('a submit revoked during its confirm burns nothing', () async {
      await h.connections.connect(_origin, h.clock);
      final held = Completer<bool>();
      final handler = h.build(
        confirm:
            ({
              required GnusOrigin origin,
              required String cost,
              required Map<String, String>? gas,
              required String payer,
              required String nodeAccount,
            }) => held.future,
      );

      final submit = viaJson(handler, _origin, _submit, _params('k1'));
      await pumpEventQueue();
      await h.connections.revoke(_origin);
      held.complete(true);
      final reply = await submit;

      expect(_error(reply)['code'], GnusRpcCode.unauthorized);
      expect(h.api.count('burn'), 0);
      expect(h.store.intentFor(_origin.value, 'k1'), isNull);
    });

    test('a call that failed before the check keeps its own code', () async {
      final handler = h.build();

      final neverConnected = await viaJson(handler, _origin, _accounts, [1]);
      final unknown = await viaJson(handler, _origin, 'gnus_nope', null);
      await h.connections.connect(_origin, h.clock);
      await h.connections.revoke(_origin);
      final revoked = await viaJson(handler, _origin, _accounts, [1]);

      expect(_error(neverConnected)['code'], GnusRpcCode.invalidParams);
      expect(_error(unknown)['code'], GnusRpcCode.unsupportedMethod);
      expect(_error(revoked)['code'], GnusRpcCode.invalidParams);
    });

    test(
      'a declined connect keeps 4001 for an origin never connected',
      () async {
        final handler = h.build(
          connect: ({required GnusOrigin origin}) async => false,
        );

        final reply = await viaJson(handler, _origin, _accounts, null);

        expect(_error(reply)['code'], GnusRpcCode.userRejected);
      },
    );
  });
}
