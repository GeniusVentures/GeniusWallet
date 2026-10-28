import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

import 'gnus_fakes.dart';

const _origin = 'https://dash.example';

// Test constants that never held funds.
final Uint8List _keyBytes = Uint8List.fromList(List.generate(32, (i) => i + 1));
const _phrase =
    'alpha bravo charlie delta echo foxtrot golf hotel india juliet kilo lima';

String _hex(List<int> bytes) =>
    bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();

String _unpadded(String base64Text) => base64Text.replaceAll('=', '');

final String _keyHex = _hex(_keyBytes);
final List<int> _phraseBytes = utf8.encode(_phrase);

// Compared case-insensitively against lowercased text.
final List<String> _hexForms = [
  _keyHex,
  '0x$_keyHex',
  _hex(_phraseBytes),
].map((form) => form.toLowerCase()).toList();

// Compared exactly. Unpadded forms are prefixes of the padded ones, so they
// catch both.
final List<String> _exactForms = [
  _phrase,
  _unpadded(base64.encode(_keyBytes)),
  _unpadded(base64Url.encode(_keyBytes)),
  _unpadded(base64.encode(_phraseBytes)),
  _unpadded(base64Url.encode(_phraseBytes)),
];

bool _leaks(String text) {
  final lower = text.toLowerCase();
  return _hexForms.any(lower.contains) || _exactForms.any(text.contains);
}

bool _leaksJson(Object? item) => _leaks(jsonEncode(item));

/// Answers the SDK like the base fake, but carries the fixtures in every text
/// path an error or a read could surface.
class _LeakyApi extends FakeGnusApi {
  bool costLeaks = false;
  bool balanceLeaks = false;
  bool netLeaks = false;

  @override
  String? getSelectedAccountMnemonic() => _phrase;

  @override
  Future<int> requestGeniusSDKCostAsync({required String jobJson}) async {
    if (costLeaks) {
      calls.add('cost');
      throw StateError(_phrase);
    }
    return super.requestGeniusSDKCostAsync(jobJson: jobJson);
  }

  @override
  Future<BigInt> readTokenBalance({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) async {
    if (balanceLeaks) {
      throw StateError('read failed $_keyHex');
    }
    return super.readTokenBalance(
      address: address,
      contractAddress: contractAddress,
      rpcUrl: rpcUrl,
    );
  }

  @override
  Future<SgnsNet> sgnsNet() async {
    if (netLeaks) {
      throw FileSystemException(_keyHex);
    }
    return super.sgnsNet();
  }
}

/// Everything the handler put where a page, a log or a prompt could see it.
class _Collected {
  final List<Map<String, Object?>> replies = [];
  final List<Map<String, Object?>> events = [];
  final List<Map<String, Object?>> prompts = [];
  final List<String> logs = [];
}

class _Rig {
  _Rig(this.handler, this.collected);

  final GnusRpcHandler handler;
  final _Collected collected;

  Future<void> call(String method, Object? params) async {
    collected.replies.add(await viaJson(handler, _origin, method, params));
  }
}

const _jobParams = {
  'job': {
    'inputs': ['a'],
  },
};

Map<String, Object?> _submitParams(String key) => {
  ..._jobParams,
  'idempotencyKey': key,
};

Future<void> _scenario(
  _Collected collected,
  Future<void> Function(_Rig rig, GnusHarness h) body, {
  void Function(_LeakyApi api)? arrange,
  bool connected = true,
  bool approveConnect = true,
  bool approveConfirm = true,
}) async {
  final api = _LeakyApi();
  arrange?.call(api);
  final h = await GnusHarness.create(api: api);
  h.walletDetails.push(
    WalletDetailsState(
      selectedWallet: gnusTestWallet.copyWith(walletName: _phrase),
      selectedNetwork: gnusTestAmoy,
    ),
  );
  if (connected) {
    await h.connections.connect(_origin, h.clock);
  }
  final handler = h.build(
    connect: ({required String origin}) async {
      collected.prompts.add({'origin': origin});
      return approveConnect;
    },
    confirm:
        ({
          required String origin,
          required String cost,
          required Map<String, String>? gas,
          required String payer,
          required String nodeAccount,
        }) async {
          collected.prompts.add({
            'origin': origin,
            'cost': cost,
            'gas': gas,
            'payer': payer,
            'nodeAccount': nodeAccount,
          });
          return approveConfirm;
        },
  );
  final subscription = handler.eventsFor(_origin).listen((event) {
    collected.events.add({'name': event.name, 'payload': event.payload});
  });
  await pumpEventQueue();
  await body(_Rig(handler, collected), h);
  await pumpEventQueue();
  await subscription.cancel();
  await h.dispose();
}

/// Drives every method on its happy path and each failure path, with the
/// fixtures planted in every fake text path.
Future<_Collected> _sweep() async {
  final c = _Collected();

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.getAccounts, null);
    await rig.call(GnusRpcMethod.estimate, _jobParams);
    await rig.call(GnusRpcMethod.submitJob, _submitParams('k1'));
    await rig.call(GnusRpcMethod.listJobs, null);
    await rig.call(GnusRpcMethod.getJob, {'idempotencyKey': 'k1'});
    await rig.call(GnusRpcMethod.getEarnings, null);
    h.pushApp(AppState(selectedSDKAccount: '0x${'d' * 128}'));
    await pumpEventQueue();
  });

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.estimate, _jobParams);
    await rig.call(GnusRpcMethod.submitJob, _submitParams('cost-throws'));
  }, arrange: (api) => api.costLeaks = true);

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.estimate, _jobParams);
    await rig.call(GnusRpcMethod.submitJob, _submitParams('cost-zero'));
  }, arrange: (api) => api.costResponse = 0);

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.estimate, _jobParams);
    await rig.call(GnusRpcMethod.submitJob, _submitParams('balance'));
  }, arrange: (api) => api.balanceLeaks = true);

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.estimate, _jobParams);
    await rig.call(GnusRpcMethod.submitJob, _submitParams('gas'));
  }, arrange: (api) => api.gasResponse = ApiResponse.error(_keyHex));

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.submitJob, _submitParams('burn'));
  }, arrange: (api) => api.burnResponse = ApiResponse.error(_phrase));

  await _scenario(
    c,
    (rig, h) async {
      await rig.call(GnusRpcMethod.submitJob, _submitParams('signed'));
      await rig.call(GnusRpcMethod.getJob, {'idempotencyKey': 'signed'});
    },
    arrange: (api) {
      api.burnResponse = ApiResponse.error(_keyHex);
      api.signedHashOnError = '0x${'c' * 64}';
    },
  );

  await _scenario(
    c,
    (rig, h) async {
      await rig.call(GnusRpcMethod.submitJob, _submitParams('process'));
      await rig.call(GnusRpcMethod.listJobs, null);
    },
    arrange: (api) => api.processResponse =
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
  );

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.getAccounts, null);
    await rig.call(GnusRpcMethod.estimate, _jobParams);
  }, arrange: (api) => api.netLeaks = true);

  await _scenario(
    c,
    (rig, h) async {
      await rig.call(GnusRpcMethod.getAccounts, null);
    },
    connected: false,
    approveConnect: false,
  );

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.submitJob, _submitParams('declined'));
  }, approveConfirm: false);

  await _scenario(
    c,
    (rig, h) async {
      for (var i = 0; i < 4; i++) {
        await rig.call(GnusRpcMethod.getAccounts, null);
      }
    },
    connected: false,
    approveConnect: false,
  );

  await _scenario(c, (rig, h) async {
    await rig.call(GnusRpcMethod.submitJob, {'job': 'not a map'});
    await rig.call(GnusRpcMethod.listJobs, {'limit': -1});
    await rig.call('gnus_nope', null);
  });

  return c;
}

void main() {
  late DebugPrintCallback original;
  late List<String> lines;

  setUp(() {
    original = debugPrint;
    lines = [];
    debugPrint = (String? message, {int? wrapWidth}) {
      lines.add(message ?? '');
    };
  });

  tearDown(() {
    debugPrint = original;
  });

  group('the detector', () {
    test('flags each form of the key and the phrase', () {
      final forms = [
        _keyHex,
        _keyHex.toUpperCase(),
        '0x$_keyHex',
        '0X${_keyHex.toUpperCase()}',
        base64.encode(_keyBytes),
        _unpadded(base64Url.encode(_keyBytes)),
        _phrase,
        _hex(_phraseBytes),
        base64.encode(_phraseBytes),
        _unpadded(base64Url.encode(_phraseBytes)),
      ];

      for (final form in forms) {
        expect(_leaks('error: $form at'), isTrue, reason: form);
        expect(_leaksJson({'message': form}), isTrue, reason: form);
      }
    });

    test('does not flag the burn hash or the node address', () {
      expect(_leaks(gnusTestBurnHash), isFalse);
      expect(_leaks(gnusTestNode), isFalse);
      expect(_leaks(gnusTestWalletAddress), isFalse);
      expect(
        _leaks('gnus_rpc gnus_submitJob https://dash.example 4001'),
        isFalse,
      );
    });
  });

  test('no reply, event, prompt or log line carries a key or phrase', () async {
    final c = await _sweep();
    final logs = [...lines];

    expect(c.replies.length, greaterThanOrEqualTo(30));
    expect(c.events, isNotEmpty);
    expect(c.prompts, isNotEmpty);
    expect(logs.where((l) => l.startsWith('gnus_rpc ')), isNotEmpty);
    expect(
      c.replies.where((r) => r.containsKey('result')),
      isNotEmpty,
      reason: 'the happy path answered',
    );
    expect(
      c.replies.where((r) => r.containsKey('error')),
      isNotEmpty,
      reason: 'the failure paths answered',
    );
    expect(
      c.prompts.where((p) => p.containsKey('payer')),
      isNotEmpty,
      reason: 'a confirm was shown',
    );
    for (final reply in c.replies) {
      expect(_leaksJson(reply), isFalse, reason: jsonEncode(reply));
    }
    for (final event in c.events) {
      expect(_leaksJson(event), isFalse, reason: jsonEncode(event));
    }
    for (final prompt in c.prompts) {
      expect(_leaksJson(prompt), isFalse, reason: jsonEncode(prompt));
    }
    for (final line in logs) {
      expect(_leaks(line), isFalse, reason: line);
    }
  });
}
