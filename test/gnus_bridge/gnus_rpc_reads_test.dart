import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/wallet.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import 'gnus_fakes.dart';

const _origin = 'https://dash.example';

final _node = gnusTestNode.toLowerCase();
final _mainNode = '0x${'b' * 128}';

Map<String, Object?> _error(Map<String, Object?> reply) =>
    reply['error']! as Map<String, Object?>;

Map<String, Object?> _result(Map<String, Object?> reply) =>
    reply['result']! as Map<String, Object?>;

Map<String, Object?> _jobParams() => {
  'job': {
    'inputs': ['a'],
  },
  'idempotencyKey': 'k',
};

void main() {
  final harnesses = <GnusHarness>[];

  Future<GnusHarness> harness() async {
    final h = await GnusHarness.create();
    harnesses.add(h);
    return h;
  }

  tearDown(() async {
    for (final h in harnesses) {
      await h.dispose();
    }
    harnesses.clear();
  });

  Future<Map<String, Object?>> accounts(GnusHarness h) =>
      viaJson(h.build(), _origin, GnusRpcMethod.getAccounts, null);

  group('gnusNodeRole', () {
    test('a node another main lists is a child of it', () {
      expect(
        gnusNodeRole(_node, {
          _mainNode.toUpperCase().replaceFirst('0X', '0x'): [
            _node.toUpperCase().replaceFirst('0X', '0x'),
          ],
        }),
        (role: 'child', main: _mainNode),
      );
    });

    test('a node with its own non-empty list is a main', () {
      expect(
        gnusNodeRole(_node, {
          _node: [_mainNode],
        }),
        (role: 'main', main: null),
      );
    });

    test('nothing registered, an empty list or no read is none', () {
      expect(gnusNodeRole(_node, {}), (role: 'none', main: null));
      expect(gnusNodeRole(_node, {_node: <String>[]}), (
        role: 'none',
        main: null,
      ));
      expect(gnusNodeRole(_node, null), (role: 'none', main: null));
    });
  });

  group('gnus_getAccounts', () {
    test('answers the contract shape on both transports', () async {
      final replies = <Map<String, Object?>>[];
      for (final transport in [viaDirect, viaJson]) {
        final h = await harness();
        h.app = AppState(
          selectedSDKAccount: gnusTestNode,
          sdkAccountLinks: {
            _node: (
              walletAddress: gnusTestWalletAddress,
              walletName: 'Test Wallet',
            ),
          },
        );
        replies.add(
          await transport(h.build(), _origin, GnusRpcMethod.getAccounts, null),
        );
      }

      expect(replies[0], equals(replies[1]));
      expect(_result(replies[0]), {
        'node': {
          'sdkAddress': _node,
          'linkedEvm': gnusTestWalletAddress.toLowerCase(),
          'role': 'none',
          'main': null,
        },
        'payer': {
          'evmAddress': gnusTestWalletAddress.toLowerCase(),
          'canSign': true,
        },
        'switching': false,
        'network': {'sdk': 'staging', 'evmChainId': 80002},
        'version': '1',
        'unit': {'symbol': 'GNUS', 'decimals': 18},
      });
    });

    test('addresses are lowercase and never cross formats', () async {
      final h = await harness();

      final node = (_result(await accounts(h))['node']! as Map)['sdkAddress'];
      final payer = (_result(await accounts(h))['payer']! as Map)['evmAddress'];

      expect(node, matches(RegExp(r'^0x[0-9a-f]{128}$')));
      expect(payer, matches(RegExp(r'^0x[0-9a-f]{40}$')));
      expect((_result(await accounts(h))['node']! as Map)['linkedEvm'], isNull);
    });

    test('the node role comes from the registrations', () async {
      final h = await harness();
      h.registrations = {
        _mainNode: [gnusTestNode],
      };
      var node = _result(await accounts(h))['node']! as Map;
      expect(node['role'], 'child');
      expect(node['main'], _mainNode);

      h.registrations = {
        _node: [_mainNode],
      };
      node = _result(await accounts(h))['node']! as Map;
      expect(node['role'], 'main');
      expect(node['main'], isNull);

      h.registrations = null;
      node = _result(await accounts(h))['node']! as Map;
      expect(node['role'], 'none');

      h.hasRegistrationReader = false;
      node = _result(await accounts(h))['node']! as Map;
      expect(node['role'], 'none');
    });

    group('payer', () {
      Future<Map<Object?, Object?>> payerWith(
        GnusHarness h,
        Wallet? wallet,
      ) async {
        h.walletDetails.push(
          WalletDetailsState(
            selectedWallet: wallet,
            selectedNetwork: gnusTestAmoy,
          ),
        );
        return _result(await accounts(h))['payer']! as Map;
      }

      test('a tracking wallet shows its address but cannot sign', () async {
        final h = await harness();
        final payer = await payerWith(
          h,
          gnusTestWallet.copyWith(walletType: WalletType.tracking),
        );
        expect(payer['evmAddress'], gnusTestWalletAddress.toLowerCase());
        expect(payer['canSign'], isFalse);
      });

      test(
        'an sgnus wallet never puts an SDK address in an EVM field',
        () async {
          final h = await harness();
          final payer = await payerWith(
            h,
            gnusTestWallet.copyWith(
              walletType: WalletType.sgnus,
              address: gnusTestNode,
            ),
          );
          expect(payer['evmAddress'], isNull);
          expect(payer['canSign'], isFalse);
        },
      );

      test('every gate state submit refuses with -32012 cannot sign', () async {
        for (final state in [
          BridgeGateState.child,
          BridgeGateState.notEarning,
          BridgeGateState.wrongNetwork,
        ]) {
          final h = await harness();
          h.gate = BridgeGate(state);
          final payer = await payerWith(h, gnusTestWallet);
          expect(payer['canSign'], isFalse, reason: state.name);
        }
      });

      test('a private-key wallet with the gate open can sign', () async {
        final h = await harness();
        final payer = await payerWith(h, gnusTestWallet);
        expect(payer['canSign'], isTrue);
      });

      test('no selected wallet is no address and cannot sign', () async {
        final h = await harness();
        final payer = await payerWith(h, null);
        expect(payer['evmAddress'], isNull);
        expect(payer['canSign'], isFalse);
      });
    });

    test('a failed SDK net read is retried on the next call', () async {
      final h = await harness();
      h.api.netThrows = true;
      final handler = h.build();

      final failed = await viaDirect(
        handler,
        _origin,
        GnusRpcMethod.getAccounts,
        null,
      );
      h.api.netThrows = false;
      final next = await viaDirect(
        handler,
        _origin,
        GnusRpcMethod.getAccounts,
        null,
      );

      expect((failed['error']! as Map)['code'], GnusRpcCode.internal);
      expect((_result(next)['network']! as Map)['sdk'], 'staging');
    });

    test('a switch in progress is reported, not refused', () async {
      final h = await harness();
      final target = '0x${'c' * 128}';
      h.api.sdkInitialized = false;
      h.app = AppState(switchingSDKAccount: target);

      final result = _result(await accounts(h));

      expect(result['switching'], isTrue);
      expect((result['node']! as Map)['sdkAddress'], target);
    });

    test('a switch keeps the current node until the target lands', () async {
      final h = await harness();
      h.app = AppState(
        selectedSDKAccount: gnusTestNode,
        switchingSDKAccount: '0x${'c' * 128}',
      );

      final result = _result(await accounts(h));

      expect(result['switching'], isTrue);
      expect((result['node']! as Map)['sdkAddress'], _node);
    });
  });

  group('readiness on every method', () {
    final calls = <(String, Object?)>[
      (GnusRpcMethod.estimate, {'job': _jobParams()['job']}),
      (GnusRpcMethod.submitJob, _jobParams()),
      (GnusRpcMethod.listJobs, null),
      (GnusRpcMethod.getJob, {'jobId': 'x'}),
      (GnusRpcMethod.getEarnings, null),
    ];

    test('a switch in progress is -32015 on all but getAccounts', () async {
      for (final (method, params) in calls) {
        final h = await harness();
        h.app = AppState(
          selectedSDKAccount: gnusTestNode,
          switchingSDKAccount: '0x${'c' * 128}',
        );

        final reply = await viaJson(h.build(), _origin, method, params);

        expect(
          _error(reply)['code'],
          GnusRpcCode.accountSwitching,
          reason: method,
        );
        expect(h.api.calls, isEmpty, reason: method);
      }
    });

    test('an SDK that is not initialized is 4900 on all six', () async {
      for (final (method, params) in [
        ...calls,
        (GnusRpcMethod.getAccounts, null),
      ]) {
        final h = await harness();
        h.api.sdkInitialized = false;

        final reply = await viaJson(h.build(), _origin, method, params);

        expect(_error(reply)['code'], GnusRpcCode.disconnected, reason: method);
      }
    });

    test('no selected SDK account and no switch is 4900 on all six', () async {
      for (final (method, params) in [
        ...calls,
        (GnusRpcMethod.getAccounts, null),
      ]) {
        final h = await harness();
        h.app = const AppState();

        final reply = await viaJson(h.build(), _origin, method, params);

        expect(_error(reply)['code'], GnusRpcCode.disconnected, reason: method);
      }
    });
  });

  group('gnus_getEarnings', () {
    test(
      'answers balance in base units with null for what is unknown',
      () async {
        for (final processing in [true, false]) {
          final h = await harness();
          h.app = AppState(
            selectedSDKAccount: gnusTestNode,
            isProcessing: processing,
          );

          final reply = await viaJson(
            h.build(),
            _origin,
            GnusRpcMethod.getEarnings,
            null,
          );

          final result = _result(reply);
          expect(result['sdkAddress'], _node);
          expect(result['balance'], '12500000000000000000');
          final status = result['processing']! as Map;
          expect(status['isProcessing'], processing);
          expect(status['jobsProcessed'], isNull);
          final earned = result['earned']! as Map;
          expect(earned['total'], isNull);
          expect(earned['history'], isNull);
          expect(earned.containsKey('total'), isTrue);
        }
      },
    );

    test('includeChildren is accepted and ignored', () async {
      final replies = <Map<String, Object?>>[];
      for (final params in <Object?>[
        null,
        {'includeChildren': true},
        {'includeChildren': false},
      ]) {
        final h = await harness();
        replies.add(
          await viaJson(h.build(), _origin, GnusRpcMethod.getEarnings, params),
        );
      }

      expect(replies[1], equals(replies[0]));
      expect(replies[2], equals(replies[0]));
    });

    test('a non-boolean includeChildren is -32602', () async {
      final h = await harness();

      final reply = await viaJson(
        h.build(),
        _origin,
        GnusRpcMethod.getEarnings,
        {'includeChildren': 'yes'},
      );

      expect(_error(reply)['code'], GnusRpcCode.invalidParams);
    });

    test('an unparseable SDK balance is -32603 balance_unavailable', () async {
      final h = await harness();
      h.api.sgnusBalance = 'not a number';

      final reply = await viaJson(
        h.build(),
        _origin,
        GnusRpcMethod.getEarnings,
        null,
      );

      expect(_error(reply)['code'], GnusRpcCode.internal);
      expect(_error(reply)['data'], {
        'reason': GnusRpcReason.balanceUnavailable,
      });
    });
  });
}
