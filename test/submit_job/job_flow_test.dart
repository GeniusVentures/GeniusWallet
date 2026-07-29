// Widget-level coverage for phase 14 plan 06 - the step list, the five step
// bodies (including the three terminals), and the two hosts (drawer +
// full-screen). Terminal-reachability and provider-hazard tests drive a REAL
// SubmitJobCubit through hand-written fakes (the same pattern
// `submit_job_outcome_test.dart`/`submit_job_errors_test.dart` established in
// plan 05 - `implements GeniusApi` + `noSuchMethod` forward, since the real
// GeniusApi's constructor dlopens the native SuperGenius framework and
// crashes flutter test's host environment); everything else pumps the step
// widgets directly against a hand-built [SubmitJobState] - faster and does
// not depend on async cubit plumbing for what is fundamentally a rendering
// question.
//
// ignore_for_file: implementation_imports
import 'package:file_picker/file_picker.dart';
import 'package:file_picker/src/platform/file_picker_platform_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_api/web3/api_response.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/data/gw_copy_row.dart';
import 'package:genius_wallet/components/loading/gw_spinner.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/submit_job/view/job_drawer.dart';
import 'package:genius_wallet/submit_job/view/submit_job_screen.dart';
import 'package:genius_wallet/submit_job/view/widgets/job_step_list.dart';
import 'package:genius_wallet/submit_job/view/widgets/job_steps.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Hand-written fake for [GeniusApi] covering only the two calls
/// `bridgeTokens()` makes - `implements` + `noSuchMethod` forward, not
/// `extends`, for the reason documented on the pattern's first use in plan 05.
class _FakeGeniusApi implements GeniusApi {
  _FakeGeniusApi({
    required this.bridgeOutResponse,
    required this.processResponse,
  });

  ApiResponse<String> bridgeOutResponse;
  GeniusNodeReturnValue processResponse;

  @override
  Future<ApiResponse<String>> bridgeOut({
    required String contractAddress,
    required String rpcUrl,
    required String address,
    required String amountToBurn,
    required int sourceChainId,
    required int destinationChainId,
    bool shouldMintTokens = false,
  }) async => bridgeOutResponse;

  @override
  GeniusNodeReturnValue requestGeniusSDKProcess({required String jobJson}) =>
      processResponse;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// [FilePickerPlatform] fake - the package's own DI seam, same pattern as
/// `submit_job_errors_test.dart`.
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

/// Seeds [GnusCubit.state.tokenInfo] synchronously, bypassing the real
/// (asset-backed) `fetchGnusInfo()` call `SubmitJobCubit._initialize()` fires
/// on construction.
class _SeededGnusCubit extends GnusCubit {
  _SeededGnusCubit(
    super.coinService,
    super.walletDetailsCubit,
    Token tokenInfo,
  ) {
    emit(state.copyWith(tokenInfo: tokenInfo));
  }
}

/// Seeds `jobCost`/`gnusBalance`/`uploadedJson` directly, bypassing
/// `openFilePicker()` for tests that only care about downstream rendering.
class _SeededSubmitJobCubit extends SubmitJobCubit {
  _SeededSubmitJobCubit({
    required super.walletDetailsCubit,
    required super.gnusCubit,
    required super.geniusApi,
    int jobCost = 0,
    double gnusBalance = 0,
    Map<String, dynamic> uploadedJson = const {},
  }) {
    emit(
      state.copyWith(
        jobCost: jobCost,
        gnusBalance: gnusBalance,
        uploadedJson: uploadedJson,
      ),
    );
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

_Harness _build({
  ApiResponse<String>? bridgeOutResponse,
  GeniusNodeReturnValue? processResponse,
  int seedJobCost = 0,
  double seedGnusBalance = 0,
  Map<String, dynamic> seedUploadedJson = const {},
}) {
  final geniusApi = _FakeGeniusApi(
    bridgeOutResponse: bridgeOutResponse ?? ApiResponse.success('0xHASH'),
    processResponse:
        processResponse ?? GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
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
    jobCost: seedJobCost,
    gnusBalance: seedGnusBalance,
    uploadedJson: seedUploadedJson,
  );
  return _Harness(cubit, walletDetailsCubit, gnusCubit);
}

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
  home: Scaffold(body: child),
);

Widget _drawerHost(SubmitJobCubit cubit) => _host(
  Builder(
    builder: (context) => ElevatedButton(
      onPressed: () => JobDrawer.show(context, cubit: cubit),
      child: const Text('open'),
    ),
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('JobStepList', () {
    const steps = <JobStep>[
      JobStep(
        title: 'Choose a file',
        summary: 'job.json',
        body: Text('choose body'),
      ),
      JobStep(title: 'Cost', summary: '10 GNUS', body: Text('cost body')),
      JobStep(title: 'Confirm', body: Text('confirm body')),
    ];

    testWidgets(
      'a step before the current index renders its title and its one-line '
      'summary, not its body',
      (tester) async {
        await tester.pumpWidget(
          _host(const JobStepList(steps: steps, currentIndex: 1)),
        );

        expect(find.text('Choose a file'), findsOneWidget);
        expect(find.text('job.json'), findsOneWidget);
        expect(find.text('choose body'), findsNothing);
      },
    );

    testWidgets('the current step renders its title and its body', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const JobStepList(steps: steps, currentIndex: 1)),
      );

      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('cost body'), findsOneWidget);
      // The collapsed summary is hidden while the step is current.
      expect(find.text('10 GNUS'), findsNothing);
    });

    testWidgets('a step after the current index renders its title only', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const JobStepList(steps: steps, currentIndex: 1)),
      );

      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('confirm body'), findsNothing);
    });

    testWidgets('completed steps remain on screen rather than being replaced', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const JobStepList(steps: steps, currentIndex: 2)),
      );

      expect(find.text('Choose a file'), findsOneWidget);
      expect(find.text('job.json'), findsOneWidget);
      expect(find.text('Cost'), findsOneWidget);
      expect(find.text('10 GNUS'), findsOneWidget);
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('confirm body'), findsOneWidget);
    });

    testWidgets('when no tap handler is supplied, no step is re-openable', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(const JobStepList(steps: steps, currentIndex: 1)),
      );

      expect(find.byType(InkWell), findsNothing);
    });
  });

  group('JobChooseFileBody', () {
    testWidgets('shows a spinner and the preparing line while the picker is '
        'open', (tester) async {
      await tester.pumpWidget(
        _host(
          const JobChooseFileBody(
            state: SubmitJobState(isFilePickerOpen: true),
          ),
        ),
      );
      // No pumpAndSettle - GWSpinner animates indefinitely by construction.
      await tester.pump();

      expect(find.byType(GWSpinner), findsOneWidget);
      expect(find.text('Preparing your job'), findsOneWidget);
    });

    testWidgets('a picker failure renders inline, not as a toast', (
      tester,
    ) async {
      await tester.pumpWidget(
        _host(
          const JobChooseFileBody(
            state: SubmitJobState(fileError: 'No file selected.'),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No file selected.'), findsOneWidget);
      expect(find.byType(SnackBar), findsNothing);
    });
  });

  group('JobCostBody', () {
    testWidgets(
      'a zero cost renders a neutral working-it-out line, not an accusation',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const JobCostBody(
              state: SubmitJobState(jobCost: 0, uploadedJson: {'job': 'spec'}),
            ),
          ),
        );
        await tester.pump();

        expect(find.text('Working out what this job costs'), findsOneWidget);
        expect(find.textContaining('enough GNUS'), findsNothing);
      },
    );

    testWidgets(
      'a cost above the balance renders a warning note naming the shortfall '
      'as a number',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const JobCostBody(
              state: SubmitJobState(
                jobCost: 10,
                gnusBalance: 4,
                uploadedJson: {'job': 'spec'},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.text('You need 6.00 more GNUS to start this job.'),
          findsOneWidget,
        );
      },
    );

    testWidgets(
      'a cost exactly equal to the balance is not treated as insufficient',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const JobCostBody(
              state: SubmitJobState(
                jobCost: 10,
                gnusBalance: 10,
                uploadedJson: {'job': 'spec'},
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.textContaining('more GNUS'), findsNothing);
      },
    );
  });

  group('JobInFlightBody', () {
    testWidgets(
      'renders the bridge and the job start as two separately labelled '
      'operations',
      (tester) async {
        await tester.pumpWidget(_host(const JobInFlightBody()));
        await tester.pump();

        expect(find.text('Bridging GNUS'), findsOneWidget);
        expect(find.text('Starting the job'), findsOneWidget);
        expect(find.byType(GWSpinner), findsNWidgets(2));
      },
    );
  });

  group('JobResultBody', () {
    testWidgets(
      'the done terminal shows a copyable transaction row and does not '
      'claim the balance has already updated',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const JobResultBody(
              state: SubmitJobState(
                outcome: SubmitOutcome.done,
                txHash: '0xDONEHASH1234567890',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Job started'), findsOneWidget);
        expect(find.byType(GWCopyRow), findsOneWidget);
        expect(find.text('Your balance is updating'), findsOneWidget);
      },
    );

    testWidgets(
      'the bridged-only terminal shows a copyable bridge hash and the '
      'mapped SDK message, with no button of its own',
      (tester) async {
        await tester.pumpWidget(
          _host(
            const JobResultBody(
              state: SubmitJobState(
                outcome: SubmitOutcome.bridgedNotProcessed,
                bridgeHash: '0xBRIDGEHASH1234567890',
                submitError:
                    'Failed to process the job. Please check your input '
                    'and try again.',
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tokens sent, job not started'), findsOneWidget);
        expect(find.byType(GWCopyRow), findsOneWidget);
        expect(
          find.text(
            'Failed to process the job. Please check your input and try '
            'again.',
          ),
          findsOneWidget,
        );
        // The body itself never renders a button - retry/no-retry is a
        // footer concern, proven end-to-end below.
        expect(find.byType(GWButton), findsNothing);
      },
    );

    testWidgets('the bridge-failed terminal states plainly that nothing was '
        'sent', (tester) async {
      await tester.pumpWidget(
        _host(
          const JobResultBody(
            state: SubmitJobState(outcome: SubmitOutcome.bridgeFailed),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Nothing was sent'), findsOneWidget);
      expect(find.textContaining('No GNUS left your wallet'), findsOneWidget);
    });
  });

  group('reaching all three terminals end to end, through a real cubit', () {
    testWidgets(
      'done: reachable, shows its own content, footer offers only Close',
      (tester) async {
        final harness = _build(
          bridgeOutResponse: ApiResponse.success('0xDONEHASH'),
          processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          seedJobCost: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);
        await harness.cubit.bridgeTokens();

        final manualIndex = ValueNotifier<int>(1);
        addTearDown(manualIndex.dispose);
        await tester.pumpWidget(
          _host(
            BlocProvider<SubmitJobCubit>.value(
              value: harness.cubit,
              child: Column(
                children: [
                  JobFlowBody(manualIndex: manualIndex),
                  JobFlowFooter(manualIndex: manualIndex),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Job started'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);
        expect(find.textContaining('Try'), findsNothing);

        // The success branch fires the load-bearing 5s delayed balance
        // refetch (`submit_job_cubit.dart:277`, `:292-295`) - flush it
        // before the test ends so flutter_test's fake clock has no pending
        // Timer left over.
        await tester.pump(const Duration(seconds: 6));
      },
    );

    testWidgets(
      'bridgedNotProcessed: reachable, shows its own content, and the '
      'footer offers NO retry - only Close',
      (tester) async {
        final harness = _build(
          bridgeOutResponse: ApiResponse.success('0xBRIDGEHASH'),
          processResponse:
              GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE,
          seedJobCost: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);
        await harness.cubit.bridgeTokens();

        final manualIndex = ValueNotifier<int>(1);
        addTearDown(manualIndex.dispose);
        await tester.pumpWidget(
          _host(
            BlocProvider<SubmitJobCubit>.value(
              value: harness.cubit,
              child: Column(
                children: [
                  JobFlowBody(manualIndex: manualIndex),
                  JobFlowFooter(manualIndex: manualIndex),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Tokens sent, job not started'), findsOneWidget);
        expect(harness.cubit.state.bridgeHash, isNotEmpty);
        expect(find.text('Close'), findsOneWidget);
        // The whole point of the override: no retry CTA anywhere in the
        // rendered tree, body or footer.
        expect(find.text('Try starting the job again'), findsNothing);
        expect(find.textContaining('Try'), findsNothing);

        // The bridged-not-processed branch also fires the delayed refetch
        // (`submit_job_cubit.dart:262`) - flush it for the same reason.
        await tester.pump(const Duration(seconds: 6));
      },
    );

    testWidgets(
      'bridgeFailed: reachable, shows its own content, and the footer '
      'offers a free retry',
      (tester) async {
        final harness = _build(
          bridgeOutResponse: ApiResponse.error('chain unreachable'),
          processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          seedJobCost: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);
        await harness.cubit.bridgeTokens();

        final manualIndex = ValueNotifier<int>(1);
        addTearDown(manualIndex.dispose);
        await tester.pumpWidget(
          _host(
            BlocProvider<SubmitJobCubit>.value(
              value: harness.cubit,
              child: Column(
                children: [
                  JobFlowBody(manualIndex: manualIndex),
                  JobFlowFooter(manualIndex: manualIndex),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(find.text('Nothing was sent'), findsOneWidget);
        expect(find.text('Try again'), findsOneWidget);
        expect(find.text('Close'), findsOneWidget);
      },
    );

    testWidgets(
      'a user holding exactly the job cost can buy - Continue is enabled at '
      'the boundary',
      (tester) async {
        final harness = _build(
          seedJobCost: 10,
          seedGnusBalance: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);

        final manualIndex = ValueNotifier<int>(1);
        addTearDown(manualIndex.dispose);
        await tester.pumpWidget(
          _host(
            BlocProvider<SubmitJobCubit>.value(
              value: harness.cubit,
              child: JobFlowFooter(manualIndex: manualIndex),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final continueButton = tester.widget<GWButton>(find.byType(GWButton));
        expect(continueButton.onPressed, isNotNull);

        await tester.tap(find.text('Continue'));
        await tester.pump();

        expect(manualIndex.value, 2);
      },
    );
  });

  group('JobDrawer - the provider hazard with no precedent in this repo', () {
    late FilePickerPlatform originalFilePickerPlatform;
    late _FakeFilePickerPlatform fakeFilePicker;

    setUp(() {
      originalFilePickerPlatform = FilePickerPlatform.instance;
      fakeFilePicker = _FakeFilePickerPlatform()..resultBuilder = () => null;
      FilePickerPlatform.instance = fakeFilePicker;
    });

    tearDown(() {
      FilePickerPlatform.instance = originalFilePickerPlatform;
    });

    testWidgets('provides the cubit to both its body and its footer subtrees', (
      tester,
    ) async {
      final harness = _build();
      addTearDown(harness.dispose);

      await tester.pumpWidget(_drawerHost(harness.cubit));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      // Body subtree resolved the cubit - step 1's title rendered rather
      // than throwing a ProviderNotFoundException.
      expect(find.text('Choose a file'), findsOneWidget);
      // Footer subtree resolved the SAME cubit, independently. Tapping its
      // CTA must reach the real cubit instead of throwing.
      expect(find.text('Choose a JSON file'), findsOneWidget);
      await tester.tap(find.text('Choose a JSON file'));
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(harness.cubit.state.fileError, 'No file selected.');
    });

    testWidgets(
      'dismissing during a landed result and reopening shows the same '
      'result, not a reset flow',
      (tester) async {
        final harness = _build(
          bridgeOutResponse: ApiResponse.success('0xDONEHASH'),
          processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          seedJobCost: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);
        await harness.cubit.bridgeTokens();

        await tester.pumpWidget(_drawerHost(harness.cubit));
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('Job started'), findsOneWidget);

        // Dismiss via the barrier, not the Close CTA (which resets state).
        // The panel is 420 wide, right-aligned in the default 800x600 test
        // surface, so x=10 is barrier, not panel - same measurement
        // `responsive_drawer_body_padding_test.dart` uses.
        await tester.tapAt(const Offset(10, 300));
        await tester.pumpAndSettle();

        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        expect(find.text('Job started'), findsOneWidget);
        expect(harness.cubit.state.outcome, SubmitOutcome.done);

        // Flush the load-bearing 5s delayed balance refetch before the test
        // ends - see the earlier terminal-reachability tests.
        await tester.pump(const Duration(seconds: 6));
      },
    );

    testWidgets(
      'closing the drawer from its footer dismisses the drawer, not the '
      'underlying route',
      (tester) async {
        final harness = _build(
          bridgeOutResponse: ApiResponse.success('0xDONEHASH'),
          processResponse: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          seedJobCost: 10,
          seedUploadedJson: const {'job': 'spec'},
        );
        addTearDown(harness.dispose);
        await harness.cubit.bridgeTokens();

        await tester.pumpWidget(
          _host(
            Builder(
              builder: (rootContext) => ElevatedButton(
                onPressed: () => Navigator.of(rootContext).push(
                  MaterialPageRoute<void>(
                    builder: (routeContext) => Scaffold(
                      body: Builder(
                        builder: (drawerContext) => ElevatedButton(
                          onPressed: () => JobDrawer.show(
                            drawerContext,
                            cubit: harness.cubit,
                          ),
                          child: const Text('the underlying route'),
                        ),
                      ),
                    ),
                  ),
                ),
                child: const Text('root'),
              ),
            ),
          ),
        );

        await tester.tap(find.text('root'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('the underlying route'));
        await tester.pumpAndSettle();

        expect(find.text('Job started'), findsOneWidget);

        await tester.tap(find.text('Close'));
        await tester.pumpAndSettle();

        // The underlying route is still on screen - Close popped only the
        // drawer, not the route it was opened from.
        expect(find.text('the underlying route'), findsOneWidget);
        expect(find.text('root'), findsNothing);

        // Flush the load-bearing 5s delayed balance refetch before the test
        // ends - see the earlier terminal-reachability tests.
        await tester.pump(const Duration(seconds: 6));
      },
    );
  });

  group('SubmitJobScreen (full-screen host)', () {
    testWidgets('renders the same step list and step bodies as the drawer', (
      tester,
    ) async {
      final harness = _build();
      addTearDown(harness.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
          home: BlocProvider<SubmitJobCubit>.value(
            value: harness.cubit,
            child: const SubmitJobScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('New processing job'), findsOneWidget);
      expect(find.text('Choose a file'), findsOneWidget);
      expect(find.text('Choose a JSON file'), findsOneWidget);
    });
  });
}
