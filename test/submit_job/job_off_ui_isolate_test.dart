// Proof for phase 42 plan 02: the SDK cost and process calls are awaited, not
// made inline, and nothing else in the job flow can reach the SDK.
//
// Honest limit: under `flutter test` a synchronous fake would not block
// anything either, so the two widget tests prove that the flow awaits the call
// and the UI stays live around it. Proof that the real FFI runs on a worker
// comes from the deleted sync API, the genius_api source guard below, and the
// phase 48 device walk.
//
// ignore_for_file: implementation_imports
import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/submit_job/job_submission.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Overrides exactly the four members the job flow may reach: the two async
/// SDK calls, the gas estimate and the burn. Everything else, including any
/// synchronous member, throws through `noSuchMethod`. [served] records the
/// order the flow used them in. The two SDK calls hold on a gate when one is
/// set, so a test can keep a call pending.
class _AsyncOnlyGeniusApi implements GeniusApi {
  final List<String> served = [];

  Completer<int>? costGate;
  Completer<GeniusNodeReturnValue>? processGate;

  @override
  Future<int> requestGeniusSDKCostAsync({required String jobJson}) {
    served.add('requestGeniusSDKCostAsync');
    return costGate?.future ?? Future.value(10);
  }

  @override
  Future<GeniusNodeReturnValue> requestGeniusSDKProcessAsync({
    required String jobJson,
  }) {
    served.add('requestGeniusSDKProcessAsync');
    return processGate?.future ??
        Future.value(GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
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
    served.add('getBrigeOutGasCost');
    return ApiResponse.success('1.00 Gwei');
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
    served.add('bridgeOut');
    return ApiResponse.success('0xHASH');
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeFilePickerPlatform extends FilePickerPlatform {
  FilePickerResult? Function()? resultBuilder;

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
  }) async => resultBuilder?.call();
}

/// Answers both fetches from the seed so `SubmitJobCubit._initialize()` never
/// reaches the asset-backed path.
class _SeededGnusCubit extends GnusCubit {
  _SeededGnusCubit(super.coinService, super.walletDetailsCubit, Token token)
    : _token = token {
    emit(state.copyWith(tokenInfo: token));
  }

  final Token _token;

  @override
  Future<Token?> fetchGnusInfo() async => _token;

  @override
  Future<Coin?> fetchGnusBalance() async => const Coin(balance: 1000);
}

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

const _facts = JobFacts(
  chainId: 1,
  rpcUrl: 'https://example.invalid',
  walletAddress: '0xWALLET',
  gnusAddress: '0xGNUS',
);

const _job = {'job': 'spec'};

class _Harness {
  _Harness(this.cubit, this.walletDetailsCubit, this.gnusCubit);

  final SubmitJobCubit cubit;
  final WalletDetailsCubit walletDetailsCubit;
  final GnusCubit gnusCubit;

  Future<void> dispose() async {
    await cubit.close();
    await gnusCubit.close();
    await walletDetailsCubit.close();
  }
}

_Harness _build(
  _AsyncOnlyGeniusApi geniusApi, {
  int seedJobCost = 0,
  Map<String, dynamic> seedUploadedJson = const {},
}) {
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
    jobCost: seedJobCost,
    uploadedJson: seedUploadedJson,
  );
  return _Harness(cubit, walletDetailsCubit, gnusCubit);
}

String _withoutComments(String source) => source
    .split('\n')
    .where((line) => !line.trimLeft().startsWith('//'))
    .join('\n');

Widget _screen(SubmitJobCubit cubit) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
  home: BlocProvider<SubmitJobCubit>.value(
    value: cubit,
    child: const SubmitJobScreen(),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FilePickerPlatform originalFilePickerPlatform;
  late _FakeFilePickerPlatform fakeFilePicker;
  late Directory tempDir;

  setUp(() {
    originalFilePickerPlatform = FilePickerPlatform.instance;
    fakeFilePicker = _FakeFilePickerPlatform();
    FilePickerPlatform.instance = fakeFilePicker;
    tempDir = Directory.systemTemp.createTempSync('job_off_ui_isolate_test');
  });

  tearDown(() {
    FilePickerPlatform.instance = originalFilePickerPlatform;
    tempDir.deleteSync(recursive: true);
    DevMockJob.instance.clear();
  });

  group('the job flow reaches only the async SDK calls', () {
    test('owner: cost, gas estimate, burn, process in that order', () async {
      final api = _AsyncOnlyGeniusApi();
      final owner = JobSubmission(geniusApi: api);

      final cost = await owner.cost('{}');
      final gas = await owner.estimateGas(_facts, 10);
      final done = await owner.submit(_facts, jobCost: 10, jobJson: _job);

      expect(cost, isA<JobCostOk>());
      expect(gas, isA<GasEstimateOk>());
      expect(done, isA<JobDone>());
      expect(api.served, [
        'requestGeniusSDKCostAsync',
        'getBrigeOutGasCost',
        'bridgeOut',
        'requestGeniusSDKProcessAsync',
      ]);
    });

    test('any other member throws, so the fake would catch a stray call', () {
      final api = _AsyncOnlyGeniusApi();

      expect(
        () => (api as dynamic).getProcessingStatus(),
        throwsA(isA<NoSuchMethodError>()),
      );
    });

    test('a real cubit on the same fake lands SubmitOutcome.done', () async {
      final api = _AsyncOnlyGeniusApi();
      final harness = _build(api, seedJobCost: 10, seedUploadedJson: _job);
      addTearDown(harness.dispose);

      await harness.cubit.bridgeTokens();

      expect(harness.cubit.state.outcome, SubmitOutcome.done);
      expect(harness.cubit.state.txHash, '0xHASH');
    });
  });

  group('source guards', () {
    final syncCall = RegExp(r'\brequestGeniusSDK(Cost|Process)\(');

    test('no file under lib/ calls a synchronous SDK cost or process', () {
      expect(syncCall.hasMatch('x.requestGeniusSDKProcess('), isTrue);
      expect(syncCall.hasMatch('x.requestGeniusSDKCost('), isTrue);
      expect(syncCall.hasMatch('x.requestGeniusSDKCostAsync('), isFalse);
      expect(syncCall.hasMatch('x.requestGeniusSDKProcessAsync('), isFalse);

      final offenders = <String>[];
      for (final entity in Directory('lib').listSync(recursive: true)) {
        if (entity is! File || !entity.path.endsWith('.dart')) {
          continue;
        }
        if (syncCall.hasMatch(_withoutComments(entity.readAsStringSync()))) {
          offenders.add(entity.path);
        }
      }

      expect(offenders, isEmpty);
    });

    test('genius_api makes the cost and process FFI calls only off-isolate', () {
      final mainHandleCall = RegExp(
        r'_ffiBridgePrebuilt\s*\.\s*sgnsLib\s*\.\s*GeniusSDK(GetCost|Process)\(',
      );
      expect(
        mainHandleCall.hasMatch('_ffiBridgePrebuilt.sgnsLib.GeniusSDKProcess('),
        isTrue,
      );
      expect(
        mainHandleCall.hasMatch(
          '_ffiBridgePrebuilt\n    .sgnsLib\n    .GeniusSDKGetCost(',
        ),
        isTrue,
      );

      final source = _withoutComments(
        File('packages/genius_api/lib/src/genius_api.dart').readAsStringSync(),
      );

      expect(mainHandleCall.hasMatch(source), isFalse);
      expect(syncCall.hasMatch(source), isFalse);
      expect('Isolate.run('.allMatches(source).length, greaterThanOrEqualTo(2));
    });
  });

  group('widget frames', () {
    testWidgets(
      'the panel keeps pumping frames while the cost call is pending',
      (tester) async {
        final api = _AsyncOnlyGeniusApi()..costGate = Completer<int>();
        final harness = _build(api);
        addTearDown(harness.dispose);
        final file = File('${tempDir.path}/job.json')
          ..writeAsStringSync('{"job":"spec"}');
        fakeFilePicker.resultBuilder = () => FilePickerResult([
          PlatformFile(path: file.path, name: 'job.json', size: 14),
        ]);
        var frames = 0;
        tester.binding.addPersistentFrameCallback((_) => frames++);

        await tester.pumpWidget(_screen(harness.cubit));
        await tester.pump();

        late Future<void> pick;
        await tester.runAsync(() async {
          pick = harness.cubit.openFilePicker();
          while (!api.served.contains('requestGeniusSDKCostAsync')) {
            await Future<void>.delayed(const Duration(milliseconds: 5));
          }
        });

        for (var i = 0; i < 10; i++) {
          final before = frames;
          await tester.pump(const Duration(milliseconds: 100));

          expect(frames, before + 1);
          expect(tester.binding.hasScheduledFrame, isTrue);
          expect(harness.cubit.state.isFilePickerOpen, isTrue);
          expect(find.byType(GWSpinner), findsWidgets);
        }

        api.costGate!.complete(10);
        await tester.runAsync(() => pick);
        await tester.pump();

        expect(harness.cubit.state.jobCost, 10);
        expect(harness.cubit.state.isFilePickerOpen, isFalse);
        expect(harness.cubit.state.uploadedFileName, 'job.json');
      },
    );

    testWidgets(
      'the panel keeps pumping frames while the process call is pending',
      (tester) async {
        final api = _AsyncOnlyGeniusApi()
          ..processGate = Completer<GeniusNodeReturnValue>();
        final harness = _build(api, seedJobCost: 10, seedUploadedJson: _job);
        addTearDown(harness.dispose);
        var frames = 0;
        tester.binding.addPersistentFrameCallback((_) => frames++);

        await tester.pumpWidget(_screen(harness.cubit));
        await tester.pump();

        final submit = harness.cubit.bridgeTokens();
        await tester.pump();
        expect(api.served, contains('requestGeniusSDKProcessAsync'));

        for (var i = 0; i < 10; i++) {
          final before = frames;
          await tester.pump(const Duration(milliseconds: 100));

          expect(frames, before + 1);
          expect(tester.binding.hasScheduledFrame, isTrue);
          expect(harness.cubit.state.isBridgingTokens, isTrue);
          expect(find.byType(GWSpinner), findsWidgets);
        }

        api.processGate!.complete(GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
        await submit;
        await tester.pump();

        expect(harness.cubit.state.outcome, SubmitOutcome.done);
        expect(harness.cubit.state.txHash, '0xHASH');
        expect(harness.cubit.state.isBridgingTokens, isFalse);

        // Lets the 5 s delayed balance refetch fire so no timer is left pending.
        await tester.pump(const Duration(seconds: 6));
      },
    );
  });
}
