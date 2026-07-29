// ignore_for_file: implementation_imports
//
// file_picker's FilePickerPlatform lives under src/ (not re-exported from
// the public `package:file_picker/file_picker.dart` barrel), but it is the
// package's own documented seam for swapping in a fake platform
// implementation in tests - `extends FilePickerPlatform` and overriding
// `pickFiles` is the sanctioned pattern every platform implementation
// (macos/windows/linux) itself uses, not a private-API reach-around.
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Hand-written fake for [GeniusApi] covering every call this test drives:
/// the cost lookup, the gas estimate, the bridge call and the process call.
/// `implements` + a `noSuchMethod` forward - not extending the real
/// `GeniusApi`, whose constructor dlopens the native SuperGenius framework
/// and would crash in `flutter test`'s host environment.
class _FakeGeniusApi implements GeniusApi {
  int requestGeniusSDKCostResponse = 10;
  ApiResponse<String> getBrigeOutGasCostResponse = ApiResponse.success(
    '1.00 Gwei',
  );
  ApiResponse<String> bridgeOutResponse = ApiResponse.success('0xHASH');
  GeniusNodeReturnValue processResponse =
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  @override
  int requestGeniusSDKCost({required String jobJson}) =>
      requestGeniusSDKCostResponse;

  @override
  Future<ApiResponse<String>> getBrigeOutGasCost({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
  }) async {
    return getBrigeOutGasCostResponse;
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
    return bridgeOutResponse;
  }

  @override
  GeniusNodeReturnValue requestGeniusSDKProcess({required String jobJson}) =>
      processResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// [FilePickerPlatform] fake - the package's own DI seam. Configure
/// [resultBuilder] to answer a pick, or [errorToThrow] to simulate any
/// other picker-level throw.
class _FakeFilePickerPlatform extends FilePickerPlatform {
  FilePickerResult? Function()? resultBuilder;
  Exception? errorToThrow;

  @override
  Future<FilePickerResult?> pickFiles({
    String? dialogTitle,
    String? initialDirectory,
    FileType type = FileType.any,
    List<String>? allowedExtensions,
    Function(FilePickerStatus)? onFileLoading,
    int compressionQuality = 0,
    bool allowMultiple = false,
    bool withData = false,
    bool withReadStream = false,
    bool lockParentWindow = false,
    bool readSequential = false,
    bool cancelUploadOnWindowBlur = true,
  }) async {
    if (errorToThrow != null) {
      throw errorToThrow!;
    }
    return resultBuilder?.call();
  }
}

/// Overrides the two `GnusCubit` fetch methods `SubmitJobCubit` calls so
/// this suite never touches the real (asset-backed) `CoinService` path -
/// every test controls exactly what each fetch returns, and nothing
/// contaminates a channel this test isn't exercising. [tokenInfo], if
/// non-null, is also seeded onto `state.tokenInfo` directly (read by
/// `bridgeTokens()`/`getBridgeOutGasCost()` from `gnusCubit.state`, not
/// from the fetch's return value).
class _SeededGnusCubit extends GnusCubit {
  final Token? tokenInfoToReturn;
  final Coin? coinToReturn;

  _SeededGnusCubit(
    super.coinService,
    super.walletDetailsCubit, {
    Token? tokenInfo,
    this.coinToReturn,
  }) : tokenInfoToReturn = tokenInfo {
    if (tokenInfo != null) {
      emit(state.copyWith(tokenInfo: tokenInfo));
    }
  }

  @override
  Future<Token?> fetchGnusInfo() async => tokenInfoToReturn;

  @override
  Future<Coin?> fetchGnusBalance() async => coinToReturn;
}

/// Seeds `jobCost`/`uploadedJson` so `bridgeTokens()`'s precondition guard
/// passes without going through `openFilePicker()`.
class _SeededSubmitJobCubit extends SubmitJobCubit {
  _SeededSubmitJobCubit({
    required super.walletDetailsCubit,
    required super.gnusCubit,
    required super.geniusApi,
    int jobCost = 0,
    Map<String, dynamic> uploadedJson = const {},
  }) {
    emit(state.copyWith(jobCost: jobCost, uploadedJson: uploadedJson));
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
  final _FakeGeniusApi geniusApi;

  _Harness(this.cubit, this.walletDetailsCubit, this.gnusCubit, this.geniusApi);

  Future<void> dispose() async {
    await cubit.close();
    await gnusCubit.close();
    await walletDetailsCubit.close();
  }
}

/// [selectNetworkAndWallet] defaults to true (the "happy path" precondition
/// data is present); tests that exercise the "missing preconditions"
/// origins set it false. [tokenInfo]/[coin] default to valid values so
/// `_initialize()`'s background fetch never raises an unrelated costError;
/// tests D/E override them to `null` deliberately.
_Harness _build({
  bool selectNetworkAndWallet = true,
  Token? tokenInfo = _token,
  Coin? coin = const Coin(balance: 1000),
  int seedJobCost = 0,
  Map<String, dynamic> seedUploadedJson = const {},
}) {
  final geniusApi = _FakeGeniusApi();
  final walletDetailsCubit = WalletDetailsCubit(
    initialState: WalletDetailsState(
      selectedWallet: selectNetworkAndWallet ? _wallet : null,
      selectedNetwork: selectNetworkAndWallet ? _network : null,
    ),
    geniusApi: geniusApi,
    networkTokensProvider: NetworkTokensProvider(),
  );
  final gnusCubit = _SeededGnusCubit(
    CoinService(),
    walletDetailsCubit,
    tokenInfo: tokenInfo,
    coinToReturn: coin,
  );
  final cubit = _SeededSubmitJobCubit(
    walletDetailsCubit: walletDetailsCubit,
    gnusCubit: gnusCubit,
    geniusApi: geniusApi,
    jobCost: seedJobCost,
    uploadedJson: seedUploadedJson,
  );

  return _Harness(cubit, walletDetailsCubit, gnusCubit, geniusApi);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FilePickerPlatform originalFilePickerPlatform;
  late _FakeFilePickerPlatform fakeFilePicker;
  late Directory tempDir;

  setUp(() {
    originalFilePickerPlatform = FilePickerPlatform.instance;
    fakeFilePicker = _FakeFilePickerPlatform();
    FilePickerPlatform.instance = fakeFilePicker;
    tempDir = Directory.systemTemp.createTempSync('submit_job_errors_test');
  });

  tearDown(() {
    FilePickerPlatform.instance = originalFilePickerPlatform;
    tempDir.deleteSync(recursive: true);
  });

  group('file channel', () {
    test('no file selected -> fileError only', () async {
      final harness = _build();
      addTearDown(harness.dispose);
      fakeFilePicker.resultBuilder = () => null;

      await harness.cubit.openFilePicker();

      expect(harness.cubit.state.fileError, 'No file selected.');
      expect(harness.cubit.state.costError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test('invalid JSON -> fileError only', () async {
      final harness = _build();
      addTearDown(harness.dispose);
      final file = File('${tempDir.path}/bad.json')
        ..writeAsStringSync('not json at all {{{');
      fakeFilePicker.resultBuilder = () => FilePickerResult([
        PlatformFile(path: file.path, name: 'bad.json', size: 20),
      ]);

      await harness.cubit.openFilePicker();

      expect(
        harness.cubit.state.fileError,
        'The Selected File is not valid json',
      );
      expect(harness.cubit.state.costError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test('any other picker throw -> fileError only', () async {
      final harness = _build();
      addTearDown(harness.dispose);
      fakeFilePicker.errorToThrow = Exception('picker exploded');

      await harness.cubit.openFilePicker();

      expect(harness.cubit.state.fileError, startsWith('Failed to pick file:'));
      expect(harness.cubit.state.costError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test('oversized file is refused before it is read', () async {
      final harness = _build();
      addTearDown(harness.dispose);
      final file = File('${tempDir.path}/huge.json');
      // Sparse-truncate to just over the 5 MB cap rather than writing real
      // content - the file must never be parsed, so its content does not
      // matter, only its length.
      file.openSync(mode: FileMode.write)
        ..truncateSync(5 * 1024 * 1024 + 1)
        ..closeSync();
      fakeFilePicker.resultBuilder = () => FilePickerResult([
        PlatformFile(
          path: file.path,
          name: 'huge.json',
          size: 5 * 1024 * 1024 + 1,
        ),
      ]);

      await harness.cubit.openFilePicker();

      expect(harness.cubit.state.fileError, contains('too large'));
      expect(harness.cubit.state.fileError, contains('5'));
      // Never parsed - jobCost/uploadedJson stay at their defaults.
      expect(harness.cubit.state.jobCost, 0);
      expect(harness.cubit.state.uploadedJson, isEmpty);
      expect(harness.cubit.state.costError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });
  });

  group('cost channel', () {
    test('balance fetch failure -> costError only', () async {
      final harness = _build(coin: null);
      addTearDown(harness.dispose);

      await harness.cubit.fetchGnusBalance();

      expect(harness.cubit.state.costError, 'Unable to fetch GNUS balance');
      expect(harness.cubit.state.fileError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test('token-info fetch failure -> costError only', () async {
      final harness = _build(tokenInfo: null);
      addTearDown(harness.dispose);

      await harness.cubit.fetchGnusTokenInfo();

      expect(
        harness.cubit.state.costError,
        'Unable to fetch token information',
      );
      expect(harness.cubit.state.fileError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test('cost lookup returns zero -> costError only', () async {
      final harness = _build();
      addTearDown(harness.dispose);
      // A valid, priceable-looking token detail must already be on the
      // cubit's own state (not just gnusCubit's) for isGasFetchable's other
      // two conditions to hold, isolating the jobCost == 0 cause.
      await harness.cubit.fetchGnusTokenInfo();
      harness.geniusApi.requestGeniusSDKCostResponse = 0;
      final file = File('${tempDir.path}/job.json')
        ..writeAsStringSync('{"job":"spec"}');
      fakeFilePicker.resultBuilder = () => FilePickerResult([
        PlatformFile(path: file.path, name: 'job.json', size: 14),
      ]);

      await harness.cubit.openFilePicker();

      expect(harness.cubit.state.costError, 'Unable to retrieve job cost');
      expect(harness.cubit.state.fileError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test('missing preconditions for gas estimation -> costError only', () async {
      final harness = _build(selectNetworkAndWallet: false);
      addTearDown(harness.dispose);
      await harness.cubit.fetchGnusTokenInfo();
      harness.geniusApi.requestGeniusSDKCostResponse = 10;
      final file = File('${tempDir.path}/job.json')
        ..writeAsStringSync('{"job":"spec"}');
      fakeFilePicker.resultBuilder = () => FilePickerResult([
        PlatformFile(path: file.path, name: 'job.json', size: 14),
      ]);

      await harness.cubit.openFilePicker();

      expect(
        harness.cubit.state.costError,
        'Missing required data for bridge gas estimation. Please select a wallet and network.',
      );
      expect(harness.cubit.state.fileError, isEmpty);
      expect(harness.cubit.state.submitError, isEmpty);
    });

    test(
      'gas estimate failure - the underlying reason reaches state, not a generic replacement',
      () async {
        final harness = _build();
        addTearDown(harness.dispose);
        await harness.cubit.fetchGnusTokenInfo();
        harness.geniusApi.requestGeniusSDKCostResponse = 10;
        harness.geniusApi.getBrigeOutGasCostResponse = ApiResponse.error(
          'Not enough funds for gas to bridge tokens',
        );
        final file = File('${tempDir.path}/job.json')
          ..writeAsStringSync('{"job":"spec"}');
        fakeFilePicker.resultBuilder = () => FilePickerResult([
          PlatformFile(path: file.path, name: 'job.json', size: 14),
        ]);

        await harness.cubit.openFilePicker();

        expect(
          harness.cubit.state.costError,
          'Not enough funds for gas to bridge tokens',
        );
        expect(
          harness.cubit.state.costError,
          isNot('Failed to estimate bridge gas cost.'),
        );
        expect(harness.cubit.state.fileError, isEmpty);
        expect(harness.cubit.state.submitError, isEmpty);
      },
    );
  });

  group('submit channel', () {
    test('bridgeTokens missing required data -> submitError only', () async {
      final harness = _build(); // jobCost stays 0 - the guard's own trigger.
      addTearDown(harness.dispose);

      await harness.cubit.bridgeTokens();

      expect(
        harness.cubit.state.submitError,
        'Missing required data. Please select a wallet and network.',
      );
      expect(harness.cubit.state.fileError, isEmpty);
      expect(harness.cubit.state.costError, isEmpty);
    });

    test('bridge call itself fails -> submitError only', () async {
      final harness = _build(
        seedJobCost: 10,
        seedUploadedJson: const {'job': 'spec'},
      );
      addTearDown(harness.dispose);
      harness.geniusApi.bridgeOutResponse = ApiResponse.error(
        'chain unreachable',
      );

      await harness.cubit.bridgeTokens();

      expect(
        harness.cubit.state.submitError,
        'Bridge transaction failed. Please try again.',
      );
      expect(harness.cubit.state.fileError, isEmpty);
      expect(harness.cubit.state.costError, isEmpty);
    });

    test(
      'process call fails after a successful bridge -> submitError only',
      () async {
        final harness = _build(
          seedJobCost: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);
        harness.geniusApi.bridgeOutResponse = ApiResponse.success('0xHASH');
        harness.geniusApi.processResponse =
            GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE;

        await harness.cubit.bridgeTokens();

        expect(harness.cubit.state.submitError, isNotEmpty);
        expect(harness.cubit.state.fileError, isEmpty);
        expect(harness.cubit.state.costError, isEmpty);
      },
    );
  });

  group('emit-after-close safety', () {
    test('fetchGnusTokenInfo after close does not throw', () async {
      final harness = _build(tokenInfo: null);
      await harness.cubit.close();
      await harness.gnusCubit.close();
      await harness.walletDetailsCubit.close();

      await expectLater(harness.cubit.fetchGnusTokenInfo(), completes);
    });

    test('the error setter after close does not throw', () async {
      final harness = _build();
      await harness.cubit.close();
      await harness.gnusCubit.close();
      await harness.walletDetailsCubit.close();

      expect(() => harness.cubit.setCostError('after close'), returnsNormally);
      expect(() => harness.cubit.resetState(), returnsNormally);
    });
  });
}
