import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/submit_job/view/widgets/job_steps.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Hand-written fake for [GeniusApi] - the only two calls `bridgeTokens()`
/// makes are `bridgeOut` and `requestGeniusSDKProcess`, so those are the
/// only two overridden here. `implements` + a `noSuchMethod` forward (the
/// same mechanism the language uses for hand-rolled test doubles, no
/// package required) is used instead of extending the real `GeniusApi` -
/// its constructor eagerly `dlopen`s the native SuperGenius framework,
/// which does not exist in `flutter test`'s host environment and would
/// crash construction before a single test ran.
class _FakeGeniusApi implements GeniusApi {
  ApiResponse<String> bridgeOutResponse;
  GeniusNodeReturnValue processResponse;

  _FakeGeniusApi({
    required this.bridgeOutResponse,
    required this.processResponse,
  });

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
    return bridgeOutResponse;
  }

  @override
  GeniusNodeReturnValue requestGeniusSDKProcess({required String jobJson}) {
    return processResponse;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Seeds [GnusCubit.state.tokenInfo] synchronously via the protected
/// `emit`, bypassing the real (asset-backed) `fetchGnusInfo()` call that
/// `SubmitJobCubit._initialize()` fires in the background on construction.
class _SeededGnusCubit extends GnusCubit {
  _SeededGnusCubit(
    super.coinService,
    super.walletDetailsCubit,
    Token tokenInfo,
  ) {
    emit(state.copyWith(tokenInfo: tokenInfo));
  }
}

/// Seeds `jobCost`/`uploadedJson` so `bridgeTokens()`'s precondition guard
/// passes, bypassing `openFilePicker()` (which calls the real, unmocked
/// `FilePicker` plugin).
class _SeededSubmitJobCubit extends SubmitJobCubit {
  _SeededSubmitJobCubit({
    required super.walletDetailsCubit,
    required super.gnusCubit,
    required super.geniusApi,
  }) {
    emit(state.copyWith(jobCost: 10, uploadedJson: const {'job': 'spec'}));
  }
}

const _wallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: '0xWALLET',
);

const _network = Network(
  name: 'Test network',
  symbol: 'ETH',
  chainId: 1,
  rpcUrl: 'https://example.invalid',
);

const _token = Token(address: '0xGNUS');

class _Harness {
  final SubmitJobCubit cubit;
  final WalletDetailsCubit walletDetailsCubit;
  final GnusCubit gnusCubit;

  _Harness(this.cubit, this.walletDetailsCubit, this.gnusCubit);

  Future<void> dispose() async {
    await cubit.close();
    await gnusCubit.close();
    await walletDetailsCubit.close();
  }
}

_Harness _build({
  required ApiResponse<String> bridgeOutResponse,
  required GeniusNodeReturnValue processResponse,
}) {
  final geniusApi = _FakeGeniusApi(
    bridgeOutResponse: bridgeOutResponse,
    processResponse: processResponse,
  );
  final walletDetailsCubit = WalletDetailsCubit(
    initialState: const WalletDetailsState(
      selectedWallet: _wallet,
      selectedNetwork: _network,
    ),
    geniusApi: geniusApi,
    networkTokensProvider: NetworkTokensProvider(),
  );
  final gnusCubit = _SeededGnusCubit(CoinService(), walletDetailsCubit, _token);
  final cubit = _SeededSubmitJobCubit(
    walletDetailsCubit: walletDetailsCubit,
    gnusCubit: gnusCubit,
    geniusApi: geniusApi,
  );

  return _Harness(cubit, walletDetailsCubit, gnusCubit);
}

/// One test per `<behavior>` bullet in 14-05-PLAN.md's Task 1, covering
/// `bridgeTokens()`'s three terminal branches. The assertion that carries
/// the most weight is the bridged-only case: it must check the bridge hash
/// is non-empty, not merely that the outcome enum is set. An implementation
/// that sets the enum and still drops the hash would leave the user in
/// exactly the position this phase exists to fix.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('fresh state defaults to notSubmitted with empty hashes', () {
    const state = SubmitJobState();
    expect(state.outcome, SubmitOutcome.notSubmitted);
    expect(state.txHash, isEmpty);
    expect(state.bridgeHash, isEmpty);
  });

  test(
    'bridge fails -> outcome bridgeFailed, both hash fields empty',
    () async {
      final harness = _build(
        bridgeOutResponse: ApiResponse.error(
          'Bridge transaction failed. Please try again.',
        ),
        processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
      );
      addTearDown(harness.dispose);

      await harness.cubit.bridgeTokens();

      expect(harness.cubit.state.outcome, SubmitOutcome.bridgeFailed);
      expect(harness.cubit.state.txHash, isEmpty);
      expect(harness.cubit.state.bridgeHash, isEmpty);
    },
  );

  test('bridge succeeds, job fails to start -> bridgedNotProcessed AND the '
      'bridge hash is preserved', () async {
    final harness = _build(
      bridgeOutResponse: ApiResponse.success('0xBRIDGEHASH'),
      processResponse: GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE,
    );
    addTearDown(harness.dispose);

    await harness.cubit.bridgeTokens();

    expect(harness.cubit.state.outcome, SubmitOutcome.bridgedNotProcessed);
    // The assertion that matters most - see the doc comment above.
    expect(harness.cubit.state.bridgeHash, isNotEmpty);
    expect(harness.cubit.state.bridgeHash, '0xBRIDGEHASH');
    // The success hash must stay empty so nothing downstream reading a
    // non-empty txHash as "job started" is fooled.
    expect(harness.cubit.state.txHash, isEmpty);
  });

  test('bridge and job both succeed -> outcome done, tx hash set', () async {
    final harness = _build(
      bridgeOutResponse: ApiResponse.success('0xDONEHASH'),
      processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    );
    addTearDown(harness.dispose);

    await harness.cubit.bridgeTokens();

    expect(harness.cubit.state.outcome, SubmitOutcome.done);
    expect(harness.cubit.state.txHash, '0xDONEHASH');
    expect(harness.cubit.state.bridgeHash, isEmpty);
  });

  // The bridge-failure footer's `Try again` calls `bridgeTokens()` a second
  // time, and `resolveJobStepIndex` reads `outcome` BEFORE `isBridgingTokens`.
  // If the retry does not clear the terminal outcome, the flow stays pinned on
  // step 4 for the whole attempt: the in-flight step never renders and the
  // retry button stays live over an in-flight bridge. Asserting through the
  // resolver rather than the raw fields is deliberate - the resolver's field
  // precedence is the half that made this a bug.
  test('retry after a bridge failure enters the in-flight step instead of '
      'staying on the failure footer', () async {
    final harness = _build(
      bridgeOutResponse: ApiResponse.error(
        'Bridge transaction failed. Please try again.',
      ),
      processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    );
    addTearDown(harness.dispose);

    await harness.cubit.bridgeTokens();
    expect(harness.cubit.state.outcome, SubmitOutcome.bridgeFailed);
    expect(resolveJobStepIndex(harness.cubit.state, 2), 4);

    final emitted = <SubmitJobState>[];
    final subscription = harness.cubit.stream.listen(emitted.add);
    await harness.cubit.bridgeTokens();
    await subscription.cancel();

    final inFlight = emitted.first;
    expect(inFlight.isBridgingTokens, isTrue);
    expect(inFlight.outcome, SubmitOutcome.notSubmitted);
    // The previous failure's toast text must not outlive the attempt it
    // described.
    expect(inFlight.submitError, isEmpty);
    expect(resolveJobStepIndex(inFlight, 2), 3);
  });

  test('resetState clears outcome and both hash fields', () async {
    final harness = _build(
      bridgeOutResponse: ApiResponse.success('0xDONEHASH'),
      processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    );
    addTearDown(harness.dispose);

    await harness.cubit.bridgeTokens();
    expect(harness.cubit.state.outcome, SubmitOutcome.done);

    harness.cubit.resetState();

    expect(harness.cubit.state.outcome, SubmitOutcome.notSubmitted);
    expect(harness.cubit.state.txHash, isEmpty);
    expect(harness.cubit.state.bridgeHash, isEmpty);
  });
}
