import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/gnus_bridge/gnus_connection_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce/hive.dart';

final gnusTestNode = '0xAA${'a' * 126}';
const gnusTestWalletAddress = '0xAbCd567890123456789012345678901234567890';
const gnusTestBurnHash =
    '0xbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb';

const gnusTestAmoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  nativeSymbol: 'POL',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

const gnusTestWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: WalletType.privateKey,
  balance: 0,
  address: gnusTestWalletAddress,
);

/// Records the calls the handler makes through the owner, in order, and answers
/// them from settable fields. Anything it does not override throws.
class FakeGnusApi implements GeniusApi {
  bool sdkInitialized = true;
  int costResponse = 1234;
  bool costThrows = false;
  ApiResponse<String> gasResponse = ApiResponse.success('1.00 Gwei');
  ApiResponse<String> burnResponse = ApiResponse.success(gnusTestBurnHash);
  GeniusNodeReturnValue processResponse =
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  SgnsNet net = SgnsNet.staging;
  String sgnusBalance = '12.5';

  /// The payer's GNUS balance in whole GNUS, and the payer it was last read for.
  double gnusBalance = 5000;
  bool balanceReadable = true;
  String? balanceReadFor;

  /// Runs when the process call starts, before it answers.
  Future<void> Function()? onProcess;

  /// Runs when the burn lands, before it answers.
  void Function()? onBurn;

  /// The hash a signed burn carries when [burnResponse] has none: a send the
  /// node refused after signing. Null means the burn failed before signing.
  String? signedHashOnError;

  /// Burns that got past `beforeBroadcast` and were sent.
  int broadcasts = 0;

  /// Ordered: `cost`, `gas`, `burn`, `process`.
  final List<String> calls = [];

  int count(String call) => calls.where((c) => c == call).length;

  /// The account the SDK itself reports running as.
  String? sdkAccount = gnusTestNode;

  @override
  bool get isSdkInitialized => sdkInitialized;

  @override
  String? getSelectedAccountAddress() => sdkAccount;

  bool netThrows = false;

  /// Runs when the SDK net read starts, before it answers.
  Future<void> Function()? onNet;

  @override
  Future<SgnsNet> sgnsNet() async {
    await onNet?.call();
    if (netThrows) {
      throw const FileSystemException('override unreadable');
    }
    return net;
  }

  @override
  String getSGNUSBalance() => sgnusBalance;

  @override
  Future<int> requestGeniusSDKCostAsync({required String jobJson}) async {
    calls.add('cost');
    if (costThrows) {
      throw StateError('worker died');
    }
    return costResponse;
  }

  @override
  Future<ApiResponse<String>> getBrigeOutGasCost({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
  }) async {
    calls.add('gas');
    return gasResponse;
  }

  @override
  Future<ApiResponse<String>> bridgeOut({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
    bool shouldMintTokens = false,
    String? sgnsAccount,
    Future<void> Function(String txHash)? beforeBroadcast,
  }) async {
    calls.add('burn');
    final signed = burnResponse.data ?? signedHashOnError;
    if (signed != null) {
      try {
        await beforeBroadcast?.call(signed);
      } catch (e) {
        return ApiResponse.error('$e');
      }
      broadcasts++;
    }
    onBurn?.call();
    return burnResponse;
  }

  @override
  Future<BigInt> readTokenBalance({
    required String address,
    required String contractAddress,
    required String rpcUrl,
  }) async {
    balanceReadFor = address;
    if (!balanceReadable) {
      throw StateError('rpc down');
    }
    return BigInt.parse(gnusBalanceBaseUnits(gnusBalance)!);
  }

  @override
  Future<GeniusNodeReturnValue> requestGeniusSDKProcessAsync({
    required String jobJson,
  }) async {
    calls.add('process');
    await onProcess?.call();
    return processResponse;
  }

  @override
  Future<GeniusNodeReturnValue?> requestGeniusSDKProcessAsAccount({
    required String jobJson,
    required String expectedAccount,
  }) async {
    if (sdkAccount?.toLowerCase() != expectedAccount.toLowerCase()) {
      return null;
    }
    return requestGeniusSDKProcessAsync(jobJson: jobJson);
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Answers the token read from the seed, so no asset is touched.
class SeededCoinService extends CoinService {
  bool tokenKnown = true;

  @override
  Future<Token?> fetchGnusInfo(Network network) async =>
      tokenKnown ? const Token(address: '0xGNUS') : const Token();
}

class PushableWalletDetails extends WalletDetailsCubit {
  PushableWalletDetails({
    required super.initialState,
    required super.geniusApi,
    required super.networkTokensProvider,
  });

  void push(WalletDetailsState next) => emit(next);
}

class RecordedConfirm {
  RecordedConfirm({
    required this.origin,
    required this.cost,
    required this.gas,
    required this.payer,
    required this.nodeAccount,
  });

  final String origin;
  final String cost;
  final Map<String, String>? gas;
  final String payer;
  final String nodeAccount;
}

int _boxCounter = 0;

/// The real store, with every write able to fail as a full disk would.
class FlakyGnusJobStore extends GnusJobStore {
  FlakyGnusJobStore(super.box);

  bool failWrites = false;

  /// Fails only the write that puts a signed burn's hash onto an intent.
  bool failHashWrites = false;

  @override
  Future<void> put(GnusJob job) async {
    if (failWrites) {
      throw const FileSystemException('disk full');
    }
    await super.put(job);
  }

  @override
  Future<void> putIntent(GnusSubmitIntent intent) async {
    if (failWrites || (failHashWrites && intent.burnTxHash != null)) {
      throw const FileSystemException('disk full');
    }
    await super.putIntent(intent);
  }
}

/// One wallet, one network, one node account, an in-memory job box and a fixed
/// clock: everything a handler test needs, with nothing real behind it.
class GnusHarness {
  GnusHarness._(this.api, this.walletDetails, this.box, this.connectionBox) {
    store = FlakyGnusJobStore(box);
    connections = GnusConnectionStore(connectionBox);
  }

  static Future<GnusHarness> create({
    Box<String>? box,
    FakeGnusApi? api,
  }) async {
    api ??= FakeGnusApi();
    final walletDetails = PushableWalletDetails(
      initialState: const WalletDetailsState(
        selectedWallet: gnusTestWallet,
        selectedNetwork: gnusTestAmoy,
      ),
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final opened =
        box ??
        await Hive.openBox<String>(
          'gnusTest${_boxCounter++}',
          bytes: Uint8List(0),
        );
    final connectionBox = await Hive.openBox<String>(
      'gnusConnTest${_boxCounter++}',
      bytes: Uint8List(0),
    );
    return GnusHarness._(api, walletDetails, opened, connectionBox);
  }

  final FakeGnusApi api;
  final PushableWalletDetails walletDetails;
  final SeededCoinService coins = SeededCoinService();
  final Box<String> box;
  final Box<String> connectionBox;
  late final FlakyGnusJobStore store;
  late GnusConnectionStore connections;

  AppState app = AppState(selectedSDKAccount: gnusTestNode);
  final StreamController<AppState> appStates = StreamController.broadcast();
  final StreamController<Object?> registrationChanges =
      StreamController.broadcast();
  final List<GnusRpcHandler> _handlers = [];

  /// Sets the app state and announces it, as the app bloc does.
  void pushApp(AppState next) {
    app = next;
    appStates.add(next);
  }

  BridgeGate gate = const BridgeGate(BridgeGateState.enabled);
  DateTime clock = DateTime.utc(2026, 10, 27, 12);
  final List<RecordedConfirm> confirms = [];

  /// The origins the default connect was asked about, in order.
  final List<String> connects = [];

  Future<bool> _approveConnect({required String origin}) async {
    connects.add(origin);
    return true;
  }

  /// Main address to the children it lists, or null when the read fails.
  Map<String, List<String>>? registrations = {};
  bool hasRegistrationReader = true;
  int registrationReads = 0;

  Map<String, List<ChildWallet>>? _readRegistrations() {
    registrationReads++;
    final own = registrations;
    if (own == null) {
      return null;
    }
    return {
      for (final entry in own.entries)
        entry.key: [
          for (final child in entry.value)
            ChildWallet(
              address: child,
              name: 'child',
              linkedWallet: null,
              balanceGnus: '0',
            ),
        ],
    };
  }

  /// A handler that connects every origin and confirms every submit, and
  /// records what it was shown.
  GnusRpcHandler build({GnusConfirm? confirm, GnusConnect? connect}) =>
      _handler(
        connect: connect ?? _approveConnect,
        confirm:
            confirm ??
            ({
              required String origin,
              required String cost,
              required Map<String, String>? gas,
              required String payer,
              required String nodeAccount,
            }) async {
              confirms.add(
                RecordedConfirm(
                  origin: origin,
                  cost: cost,
                  gas: gas,
                  payer: payer,
                  nodeAccount: nodeAccount,
                ),
              );
              return true;
            },
      );

  /// A handler built with no confirm argument, as the app wires it today. It
  /// connects every origin, so only the confirm is under test.
  GnusRpcHandler buildDefaultConfirm() => _handler(connect: _approveConnect);

  GnusRpcHandler _handler({GnusConfirm? confirm, GnusConnect? connect}) {
    final handler = _create(confirm: confirm, connect: connect);
    _handlers.add(handler);
    return handler;
  }

  GnusRpcHandler _create({GnusConfirm? confirm, GnusConnect? connect}) {
    BridgeGate resolve({bool fresh = false}) => gate;
    DateTime now() => clock;
    if (confirm == null) {
      return GnusRpcHandler(
        geniusApi: api,
        readAppState: () => app,
        walletDetails: walletDetails,
        coinService: coins,
        resolveGate: resolve,
        store: store,
        connections: connections,
        appStates: appStates.stream,
        registrationChanges: registrationChanges.stream,
        readRegistrations: hasRegistrationReader ? _readRegistrations : null,
        connect: connect ?? rejectGnusConnect,
        now: now,
      );
    }
    return GnusRpcHandler(
      geniusApi: api,
      readAppState: () => app,
      walletDetails: walletDetails,
      coinService: coins,
      resolveGate: resolve,
      store: store,
      connections: connections,
      appStates: appStates.stream,
      registrationChanges: registrationChanges.stream,
      confirm: confirm,
      connect: connect ?? rejectGnusConnect,
      readRegistrations: hasRegistrationReader ? _readRegistrations : null,
      now: now,
    );
  }

  Future<void> dispose({bool closeBox = true}) async {
    for (final handler in _handlers) {
      await handler.dispose();
    }
    await appStates.close();
    await registrationChanges.close();
    await walletDetails.close();
    await connectionBox.close();
    if (closeBox) {
      await box.close();
    }
  }
}

/// A transport that hands the handler's maps over untouched.
Future<Map<String, Object?>> viaDirect(
  GnusRpcHandler handler,
  String origin,
  String method,
  Object? params,
) async {
  try {
    return {'result': await handler.handle(origin, method, params)};
  } on GnusRpcError catch (e) {
    return {'error': e.toJson()};
  }
}

/// A transport that serialises the request and the reply, as a WebView or
/// WalletConnect does.
Future<Map<String, Object?>> viaJson(
  GnusRpcHandler handler,
  String origin,
  String method,
  Object? params,
) async {
  final Object? sent = jsonDecode(jsonEncode(params));
  final reply = await viaDirect(handler, origin, method, sent);
  return Map<String, Object?>.from(jsonDecode(jsonEncode(reply)) as Map);
}
