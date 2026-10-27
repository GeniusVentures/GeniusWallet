import 'dart:convert';
import 'dart:typed_data';

import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
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
  ApiResponse<String> gasResponse = ApiResponse.success('1.00 Gwei');
  ApiResponse<String> burnResponse = ApiResponse.success(gnusTestBurnHash);
  GeniusNodeReturnValue processResponse =
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  /// Runs when the process call starts, before it answers.
  Future<void> Function()? onProcess;

  /// Ordered: `cost`, `gas`, `burn`, `process`.
  final List<String> calls = [];

  int count(String call) => calls.where((c) => c == call).length;

  @override
  bool get isSdkInitialized => sdkInitialized;

  @override
  Future<int> requestGeniusSDKCostAsync({required String jobJson}) async {
    calls.add('cost');
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
  }) async {
    calls.add('burn');
    return burnResponse;
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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Answers both fetches from the seed, so no asset or network is touched.
class SeededGnusCubit extends GnusCubit {
  SeededGnusCubit(
    super.coinService,
    super.walletDetailsCubit,
    Token tokenInfo,
  ) {
    emit(state.copyWith(tokenInfo: tokenInfo));
  }

  double balance = 5000;

  @override
  Future<Token?> fetchGnusInfo() async => state.tokenInfo;

  @override
  Future<Coin?> fetchGnusBalance() async => Coin(balance: balance);
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

/// One wallet, one network, one node account, an in-memory job box and a fixed
/// clock: everything a handler test needs, with nothing real behind it.
class GnusHarness {
  GnusHarness._(this.api, this.walletDetails, this.gnus, this.box) {
    store = GnusJobStore(box);
  }

  static Future<GnusHarness> create({Box<String>? box}) async {
    final api = FakeGnusApi();
    final walletDetails = PushableWalletDetails(
      initialState: const WalletDetailsState(
        selectedWallet: gnusTestWallet,
        selectedNetwork: gnusTestAmoy,
      ),
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final gnus = SeededGnusCubit(
      CoinService(),
      walletDetails,
      const Token(address: '0xGNUS'),
    );
    final opened =
        box ??
        await Hive.openBox<String>(
          'gnusTest${_boxCounter++}',
          bytes: Uint8List(0),
        );
    return GnusHarness._(api, walletDetails, gnus, opened);
  }

  final FakeGnusApi api;
  final PushableWalletDetails walletDetails;
  final SeededGnusCubit gnus;
  final Box<String> box;
  late final GnusJobStore store;

  AppState app = AppState(selectedSDKAccount: gnusTestNode);
  BridgeGate gate = const BridgeGate(BridgeGateState.enabled);
  DateTime clock = DateTime.utc(2026, 10, 27, 12);
  final List<RecordedConfirm> confirms = [];

  /// A handler that confirms every submit and records what it was shown.
  GnusRpcHandler build({GnusConfirm? confirm}) => _handler(
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

  /// A handler built with no confirm argument, as the app wires it today.
  GnusRpcHandler buildDefaultConfirm() => _handler();

  GnusRpcHandler _handler({GnusConfirm? confirm}) {
    BridgeGate resolve({bool fresh = false}) => gate;
    DateTime now() => clock;
    if (confirm == null) {
      return GnusRpcHandler(
        geniusApi: api,
        readAppState: () => app,
        walletDetails: walletDetails,
        gnusCubit: gnus,
        resolveGate: resolve,
        store: store,
        now: now,
      );
    }
    return GnusRpcHandler(
      geniusApi: api,
      readAppState: () => app,
      walletDetails: walletDetails,
      gnusCubit: gnus,
      resolveGate: resolve,
      store: store,
      confirm: confirm,
      now: now,
    );
  }

  Future<void> dispose({bool closeBox = true}) async {
    await gnus.close();
    await walletDetails.close();
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
