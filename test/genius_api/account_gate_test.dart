import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_api/web3/bridge_out_abi.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

final _recorded = '0x${'a' * 128}';
final _other = '0x${'b' * 128}';

class _NoStorage extends Fake implements LocalWalletStorage {}

/// The real gate with the native calls replaced. A switch lands the moment it
/// first reads the start account, so the order of [events] is the order in
/// which the SDK would have seen them.
class _GateApi extends GeniusApi {
  _GateApi() : super(secureStorage: _NoStorage());

  String account = _recorded;
  final List<String> events = [];

  /// Lets a select reach the real native worker, which cannot load the SDK
  /// under test and dies.
  bool reachWorker = false;
  Future<void> Function()? onProcess;

  @override
  String? getSelectedAccountAddress() => account;

  @override
  String? getStartAccountAddress() {
    if (reachWorker) {
      return _recorded;
    }
    account = _other;
    events.add('switch');
    return null;
  }

  @override
  Future<GeniusNodeReturnValue> requestGeniusSDKProcessAsync({
    required String jobJson,
  }) async {
    events.add('process as $account');
    await onProcess?.call();
    events.add('process done');
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  GeniusNodeReturnValue mintResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  @override
  GeniusNodeReturnValue mintTokens(
    int amount,
    String transactionHash,
    String chainId,
    String tokenId,
  ) {
    events.add('mint $amount $transactionHash on $chainId as $account');
    return mintResult;
  }
}

Future<ApiResponse<String>> _credit(
  _GateApi api,
  BridgeOutForm form, {
  ApiResponse<String>? burn,
}) => api.creditBurn(
  burn ?? ApiResponse.success('0xBURN'),
  form: form,
  minions: 5000000,
  account: _recorded,
  chainId: 7,
);

void main() {
  test('a switch requested after the check waits until Process ends', () async {
    final api = _GateApi();
    Future<GeniusNodeReturnValue>? switching;
    api.onProcess = () async {
      switching = api.selectGeniusAccountAsync(_other);
      await pumpEventQueue();
    };

    final result = await api.requestGeniusSDKProcessAsAccount(
      jobJson: '{}',
      expectedAccount: _recorded,
    );
    await switching;

    expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
    expect(api.events, ['process as $_recorded', 'process done', 'switch']);
  });

  test('a select whose worker dies frees the gate', () async {
    final api = _GateApi()..reachWorker = true;

    await expectLater(api.selectGeniusAccountAsync(_other), throwsA(anything));
    final result = await api
        .requestGeniusSDKProcessAsAccount(
          jobJson: '{}',
          expectedAccount: _recorded,
        )
        .timeout(const Duration(seconds: 5));

    expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
  });

  test('a switch queued first makes Process refuse to run', () async {
    final api = _GateApi();

    final switching = api.selectGeniusAccountAsync(_other);
    final result = await api.requestGeniusSDKProcessAsAccount(
      jobJson: '{}',
      expectedAccount: _recorded,
    );
    await switching;

    expect(result, isNull);
    expect(api.events, ['switch']);
  });

  group('crediting a burn', () {
    test(
      'a 5-arg burn is left to the relayer: the wallet never mints',
      () async {
        final api = _GateApi();

        final result = await _credit(api, BridgeOutForm.fiveArg);

        expect(result.isSuccess, isTrue);
        expect(result.data, '0xBURN');
        expect(api.events, isEmpty);
      },
    );

    test('a 3-arg burn is minted once, as the confirmed account', () async {
      final api = _GateApi();

      final result = await _credit(api, BridgeOutForm.threeArg);

      expect(result.isSuccess, isTrue);
      expect(result.data, '0xBURN');
      expect(api.events, ['mint 5000000 0xBURN on 7 as $_recorded']);
    });

    test('a switch queued ahead of the mint leaves the burn recoverable, '
        'never minted for the other account', () async {
      final api = _GateApi();

      final switching = api.selectGeniusAccountAsync(_other);
      final result = await _credit(api, BridgeOutForm.threeArg);
      await switching;

      expect(api.events, ['switch']);
      expect(result.isSuccess, isFalse);
      expect(result.reverted, isFalse);
      expect(result.data, '0xBURN');
      expect(result.errorMessage, bridgeCreditFailedMessage);
    });

    test('a failed mint keeps the hash as a recoverable outcome', () async {
      final api = _GateApi()
        ..mintResult = GeniusNodeReturnValue.GENIUS_NODE_ERROR_MINT;

      final result = await _credit(api, BridgeOutForm.threeArg);

      expect(result.isSuccess, isFalse);
      expect(result.data, '0xBURN');
      expect(result.errorMessage, bridgeCreditFailedMessage);
    });

    test('an unconfirmed 3-arg burn is not minted', () async {
      final api = _GateApi();
      final burn = ApiResponse.unconfirmed('0xBURN', 'reset');

      final result = await _credit(api, BridgeOutForm.threeArg, burn: burn);

      expect(result, same(burn));
      expect(api.events, isEmpty);
    });
  });
}
