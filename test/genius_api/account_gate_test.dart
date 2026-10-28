import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
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
}

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
}
