import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class SubmitJobCubit extends Cubit<SubmitJobState> {
  final WalletDetailsCubit walletDetailsCubit;
  final GnusCubit gnusCubit;
  final GeniusApi geniusApi;

  // flutter_bloc does not re-export kDebugMode, hence the explicit
  // foundation.dart import above (same idiom as app_bloc.dart:10).
  //
  // Task 2 (2026-07-31): resolves the armed DevMockJob scenario, or null
  // when nothing is armed or dev tools are unavailable. Gated here, in ONE
  // place, so `kDebugMode && kShowDevTools` cannot be forgotten at an
  // individual interception site (T-elz-01) - fetchGnusBalance,
  // openFilePicker and bridgeTokens all read this same getter rather than
  // repeating the gate.
  DevJobScenario? get _devJobScenario =>
      (kDebugMode && kShowDevTools) ? DevMockJob.instance.scenario.value : null;

  // ponytail: a synchronous JSON parse on the UI isolate, gated only by the
  // length check below. A file just under the cap can still block the UI
  // thread while it parses. Upgrade path: parse off-isolate (compute() /
  // Isolate.run) once a job file large enough to matter shows up in
  // practice.
  static const int _maxJobFileBytes = 5 * 1024 * 1024; // 5 MB

  SubmitJobCubit({
    required this.walletDetailsCubit,
    required this.gnusCubit,
    required this.geniusApi,
  }) : super(const SubmitJobState()) {
    _initialize();
    if (kDebugMode && kShowDevTools) {
      // Task 1 (2026-07-31): this cubit is constructed per-subtree in two
      // places (`wallet_overview.dart:60`, `router.dart:369`) and both
      // instances can be alive at once. The listener is removed in close()
      // below, under the identical gate, so a listener never outlives its
      // cubit.
      DevMockJob.instance.scenario.addListener(_onDevScenarioChanged);
    }
  }

  Future<void> _initialize() async {
    await fetchGnusTokenInfo();
    await fetchGnusBalance();
  }

  // Synchronous on purpose - ValueNotifier.addListener requires a `void
  // Function()`, not a `Future<void> Function()`. The real work is async and
  // is fired-and-forgotten through `unawaited`, which this file already
  // imports via `dart:async`.
  void _onDevScenarioChanged() {
    unawaited(_repriceForDevScenario());
  }

  // Task 1 (2026-07-31): re-prices whatever file is already chosen when the
  // armed JOB scenario changes (including changing to null, i.e. Clear).
  // Order is load-bearing: reset first, then balance, then cost - resetting
  // AFTER the cost would erase the very answer this method just computed.
  Future<void> _repriceForDevScenario() async {
    if (isClosed) {
      return;
    }
    if (state.uploadedJson.isEmpty) {
      // No file chosen - nothing to price. This is the no-op the constraint
      // demands: arming with no file chosen does nothing at all.
      return;
    }

    // Reset the cost-derived fields to their declared defaults BEFORE
    // re-pricing. Without this, a failed real re-price (e.g. Clear with no
    // native node running) would leave the fixture's 42.42 Gwei on screen
    // under a real error - this is what makes Clear honest.
    if (!isClosed) {
      emit(state.copyWith(jobCost: 0, jobGasCost: '0.00 Gwei', costError: ''));
    }

    // Re-runs the real balance (or the fixture's, if a different scenario is
    // now armed) - this is what unsticks the fixture's 99999.99 balance on
    // Clear.
    await fetchGnusBalance();

    final jobCost = await _resolveJobCost(state.uploadedJson);
    if (!isClosed) {
      emit(state.copyWith(jobCost: jobCost));
    }
  }

  // Fetches and updates balance from gnusCubit
  Future<double?> fetchGnusBalance() async {
    if (_devJobScenario != null) {
      // DEV-ONLY (Task 2, 2026-07-31): answers from the fixture instead of
      // gnusCubit, so `_initialize()` never parks a stale "Unable to fetch
      // GNUS balance" error on the state before the walk even starts.
      final balance = DevMockJob.instance.balance;
      if (!isClosed) {
        emit(state.copyWith(gnusBalance: balance));
      }
      return balance;
    }

    final resp = await gnusCubit.fetchGnusBalance();
    final balance = resp?.balance;

    if (balance == null) {
      setCostError('Unable to fetch GNUS balance');
      return 0;
    }

    // this can be long running since we delay it..
    if (!isClosed) {
      emit(state.copyWith(gnusBalance: balance));
    }

    return balance;
  }

  // Fetches and updates gnus token info from gnusCubit
  Future<void> fetchGnusTokenInfo() async {
    final info = await gnusCubit.fetchGnusInfo();

    if (info == null) {
      setCostError('Unable to fetch token information');
      return;
    }

    if (!isClosed) {
      emit(state.copyWith(gnusTokenDetails: info));
    }
  }

  Future<void> openFilePicker() async {
    if (!isClosed) {
      emit(state.copyWith(isFilePickerOpen: true)); // Indicate picker is open
    }

    try {
      resetFileError(); // Clear previous errors
      // 1c (2026-07-31): also clear a stale cost error from a prior pick (or
      // from _initialize's fetchGnusTokenInfo/fetchGnusBalance, both of
      // which fail without a live SDK). After 1b below, costError outranks
      // costUnknown, so a leftover error from an earlier attempt would
      // outrank a fresh, successful pick's own emit.
      resetCostError();

      final result = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        dialogTitle: "Select a valid JSON file",
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);

        // Trust boundary: a user-picked file. Check its length before
        // reading it fully into memory - the extension filter above is not
        // a size check.
        final fileLength = await file.length();
        if (fileLength > _maxJobFileBytes) {
          setFileError(
            'File is too large (max ${_maxJobFileBytes ~/ (1024 * 1024)} MB).',
          );
          return;
        }

        final content = await file.readAsString();
        final jsonData = jsonDecode(content);

        final jobCost = await _resolveJobCost(jsonData);

        if (!isClosed) {
          emit(
            state.copyWith(
              uploadedFileName: result.files.single.name,
              uploadedJson: jsonData,
              jobCost: jobCost,
            ),
          );
        }
      } else {
        // 2026-07-31 (D-05): cancelling the OS picker sets no error at all.
        // A dismissed dialog is a deliberate choice, not a failure - there is
        // nothing to fix, nothing to retry, and nothing was lost, so there
        // is nothing to warn about. The state keeps whatever it already
        // held; the `finally` block's `isFilePickerOpen: false` below is the
        // whole transition. This also means a cancel after a genuine
        // rejection lands the user back in a clean RESTING state, because
        // `resetFileError()` above already ran on entry to this call - they
        // reopened the picker precisely to get past that rejection, and
        // backing out of it is not a reason to re-assert it. The size cap
        // above and the `FormatException` branch below still set
        // `fileError` - this only removes the cancel path, not file
        // rejection in general.
      }
    } catch (e) {
      if (e.runtimeType == FormatException) {
        return setFileError('The Selected File is not valid json');
      }
      setFileError('Failed to pick file: ${e.runtimeType}');
    } finally {
      if (!isClosed) {
        emit(
          state.copyWith(isFilePickerOpen: false),
        ); // Indicate picker is closed
      }
    }
  }

  // Task 1 (2026-07-31): extracted out of `openFilePicker` so
  // `_repriceForDevScenario` above can call it again after a pick, when a
  // JOB scenario is armed (or changed, or cleared) with a file already
  // chosen - the whole point of this quick task. `jsonData` stays `dynamic`,
  // not `Map<String, dynamic>`: the real branch's `isGasFetchable` includes
  // a `jsonData != null` check whose current meaning depends on that.
  Future<int> _resolveJobCost(dynamic jsonData) async {
    final int jobCost;
    final devScenario = _devJobScenario;

    if (devScenario != null) {
      // DEV-ONLY (Task 2, 2026-07-31): a DevJobScenario is armed. Skip
      // both requestGeniusSDKCost and getBridgeOutGasCost entirely and
      // answer from the fixture instead, so the whole flow runs with no
      // native SDK.
      final fixture = DevMockJob.instance;
      if (fixture.costShouldFail) {
        // Pricing-failure scenario: lands the walk on exactly the state
        // Task 1 made visible - a kept file, jobCost 0, costError set.
        // If Task 1 regresses, this button reproduces a blank step 1
        // again, which is why the two tasks verify each other.
        jobCost = 0;
        if (!isClosed) {
          emit(
            state.copyWith(
              costError: DevMockJob.costErrorMessage,
              gnusBalance: fixture.balance,
            ),
          );
        }
      } else {
        jobCost = DevMockJob.jobCost;
        // Balance is emitted in the SAME emit as the gas string, not a
        // separate call - this is still the one detail that makes the panel
        // usable mid-walk. What changed here (Task 1, 2026-07-31): arming a
        // scenario AFTER a file is already chosen used to do nothing,
        // because this whole branch only ran once, at pick time. It now
        // also runs from `_repriceForDevScenario`, reached through the
        // listener registered in the constructor above - a scenario armed
        // (or cleared) after a pick pushes a re-price through that listener,
        // which is the half that was missing and the half that stuck a real
        // walk.
        if (!isClosed) {
          emit(
            state.copyWith(
              jobGasCost: DevMockJob.jobGasCost,
              gnusBalance: fixture.balance,
            ),
          );
        }
      }
    } else {
      jobCost = geniusApi.requestGeniusSDKCost(jobJson: jsonEncode(jsonData));

      final isGasFetchable =
          jsonData != null &&
          state.gnusTokenDetails.address != null &&
          jobCost != 0;

      // 1a (2026-07-31): a gas-estimate failure one line below already
      // sets costError and falls through to the emit rather than
      // returning early - that is the precedent this now matches. Before
      // this change, a pricing failure returned here instead, discarding
      // the picked file: uploadedFileName/uploadedJson/jobCost are only
      // written by the emit below, so returning early meant the file
      // vanished with no visible trace. That silence mattered beyond this
      // method - job_steps.dart's auto-advance listener and its step 0
      // footer both gate on uploadedJson being non-empty, and costError
      // only renders in step 2, so a discarded file also made step 2
      // unreachable. isGasFetchable is now used only to decide whether to
      // ATTEMPT the gas estimate, never to abandon the method.
      if (isGasFetchable) {
        // Get gas cost associated with uploaded job
        await getBridgeOutGasCost(jobCost);
      } else {
        // Do not call getBridgeOutGasCost with a zero cost - a pointless
        // RPC round trip against an amount of nothing.
        setCostError('Unable to retrieve job cost');
      }
    }

    return jobCost;
  }

  Future<void> getBridgeOutGasCost(int jobCost) async {
    final selectedNetwork = walletDetailsCubit.state.selectedNetwork;
    final chainId = selectedNetwork?.chainId;
    final rpcUrl = selectedNetwork?.rpcUrl;
    final selectedWallet = walletDetailsCubit.state.selectedWallet;
    final walletAddress = selectedWallet?.address;
    final gnusAddress = gnusCubit.state.tokenInfo?.address;

    if (selectedNetwork == null ||
        chainId == null ||
        gnusAddress == null ||
        walletAddress == null ||
        rpcUrl == null) {
      setCostError(
        'Missing required data for bridge gas estimation. Please select a wallet and network.',
      );
      return;
    }

    final resp = await geniusApi.getBrigeOutGasCost(
      sourceChainId: chainId,
      contractAddress: gnusAddress,
      rpcUrl: rpcUrl,
      address: walletAddress,
      amountToBurn: "$jobCost",
      destinationChainId: 15305752297694, // TODO: unhardcode bridge address
    );

    final jobGasCost = resp.data;

    if (!resp.isSuccess || jobGasCost == null) {
      // Pass through the underlying reason (e.g. "Not enough funds for gas
      // to bridge tokens" from web3.dart's hasEnoughFundsForGas check)
      // instead of replacing it with a generic line - that check already
      // runs, the only thing missing was its message reaching the user.
      final underlyingReason = resp.errorMessage;
      setCostError(
        underlyingReason != null && underlyingReason.isNotEmpty
            ? underlyingReason
            : 'Failed to estimate bridge gas cost.',
      );
      return;
    }

    if (!isClosed) {
      emit(state.copyWith(jobGasCost: jobGasCost));
    }
  }

  Future<void> bridgeTokens() async {
    if (!isClosed) {
      emit(state.copyWith(isBridgingTokens: true));
    }

    final devScenario = _devJobScenario;
    if (devScenario != null) {
      // DEV-ONLY (Task 2, 2026-07-31): at the very top, BEFORE the
      // precondition guard below. That guard exists only to protect the two
      // SDK calls this fixture replaces (bridgeOut, requestGeniusSDKProcess)
      // - in a dev environment with no token info it would reject every
      // submission before step 4 could ever render, which is exactly the
      // validation guard a reviewer must see justified rather than discover.
      final fixture = DevMockJob.instance;
      await Future.delayed(DevMockJob.inFlightDelay);

      switch (fixture.outcome) {
        case SubmitOutcome.done:
          if (!isClosed) {
            emit(
              state.copyWith(
                txHash: DevMockJob.txHash,
                outcome: SubmitOutcome.done,
                isBridgingTokens: false,
              ),
            );
          }
        case SubmitOutcome.bridgeFailed:
          // Nothing was spent - both hash fields stay untouched, byte
          // identical to the production bridge-failure message.
          if (!isClosed) {
            emit(
              state.copyWith(
                isBridgingTokens: false,
                outcome: SubmitOutcome.bridgeFailed,
                submitError: 'Bridge transaction failed. Please try again.',
              ),
            );
          }
        case SubmitOutcome.bridgedNotProcessed:
          // The fixture bridge hash on bridgeHash and NOT on txHash -
          // deliberately, so nothing downstream reading a non-empty txHash
          // as "job started" is fooled. The submit error is produced by
          // passing the fixture's process-failure value through the
          // cubit's own private message mapper, so this terminal shows
          // exactly what a genuine failure shows rather than dev prose.
          if (!isClosed) {
            emit(
              state.copyWith(
                isBridgingTokens: false,
                outcome: SubmitOutcome.bridgedNotProcessed,
                bridgeHash: DevMockJob.bridgeHash,
                submitError: _processErrorMessage(DevMockJob.processFailure),
              ),
            );
          }
        case SubmitOutcome.notSubmitted:
          // Unreachable - DevMockJob.outcome never returns notSubmitted.
          break;
      }

      // No delayed balance refetch here, unlike the production path below:
      // the balance is fixture-driven and intercepted in fetchGnusBalance,
      // so the refetch would sleep 5s and re-emit the identical number.
      return;
    }

    final selectedNetwork = walletDetailsCubit.state.selectedNetwork;
    final chainId = selectedNetwork?.chainId;
    final rpcUrl = selectedNetwork?.rpcUrl;
    final selectedWallet = walletDetailsCubit.state.selectedWallet;
    final walletAddress = selectedWallet?.address;
    final gnusAddress = gnusCubit.state.tokenInfo?.address;
    final uploadedJson = state.uploadedJson;

    if (selectedNetwork == null ||
        chainId == null ||
        gnusAddress == null ||
        walletAddress == null ||
        rpcUrl == null ||
        state.jobCost == 0 ||
        uploadedJson.isEmpty) {
      if (!isClosed) {
        emit(
          state.copyWith(
            isBridgingTokens: false,
            submitError:
                'Missing required data. Please select a wallet and network.',
          ),
        );
      }
      return;
    }

    final resp = await geniusApi.bridgeOut(
      sourceChainId: chainId,
      contractAddress: gnusAddress,
      rpcUrl: rpcUrl,
      address: walletAddress,
      amountToBurn: state.jobCost.toString(),
      destinationChainId: 15305752297694, // TODO: unhardcode bridge address
    );

    final txHash = resp.data;

    if (!resp.isSuccess || txHash == null) {
      // Nothing was spent - both hash fields stay untouched (still empty on
      // a fresh state).
      if (!isClosed) {
        emit(
          state.copyWith(
            isBridgingTokens: false,
            outcome: SubmitOutcome.bridgeFailed,
            submitError: 'Bridge transaction failed. Please try again.',
          ),
        );
      }

      return;
    }

    // process the job
    final processResult = geniusApi.requestGeniusSDKProcess(
      jobJson: jsonEncode(uploadedJson),
    );
    if (processResult != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      // The bridge succeeded - tokens are already burned - but the job
      // never started. Preserve the bridge hash as proof (deliberately NOT
      // txHash, so nothing downstream reading a non-empty txHash as "job
      // started" is fooled), and refresh the balance since a burn happened
      // here too even though no job was requested.
      unawaited(fetchGnusBalanceWithDelay());

      if (!isClosed) {
        emit(
          state.copyWith(
            isBridgingTokens: false,
            outcome: SubmitOutcome.bridgedNotProcessed,
            bridgeHash: txHash,
            submitError: _processErrorMessage(processResult),
          ),
        );
      }
      return;
    }

    unawaited(fetchGnusBalanceWithDelay());

    if (!isClosed) {
      emit(
        state.copyWith(
          txHash: txHash,
          outcome: SubmitOutcome.done,
          isBridgingTokens: false,
        ),
      );
    }
  }

  // used to fetch the gnus balance of the wallet with some delay
  // fetching this immediately after doing a transaction seems to return a stale value
  Future<void> fetchGnusBalanceWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 5000));
    unawaited(fetchGnusBalance());
  }

  void resetState() {
    if (!isClosed) {
      emit(
        state.copyWith(
          jobCost: 0,
          uploadedJson: {},
          uploadedFileName: '',
          jobGasCost: '',
          txHash: '',
          bridgeHash: '',
          outcome: SubmitOutcome.notSubmitted,
          submitError: '',
        ),
      );
    }
  }

  void setFileError(String errorMessage) {
    if (!isClosed) {
      emit(state.copyWith(fileError: errorMessage));
    }
  }

  void setCostError(String errorMessage) {
    if (!isClosed) {
      emit(state.copyWith(costError: errorMessage));
    }
  }

  void setSubmitError(String errorMessage) {
    if (!isClosed) {
      emit(state.copyWith(submitError: errorMessage));
    }
  }

  void resetFileError() {
    setFileError('');
  }

  void resetCostError() {
    setCostError('');
  }

  void resetSubmitError() {
    setSubmitError('');
  }

  String _processErrorMessage(GeniusNodeReturnValue result) {
    switch (result) {
      case GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED:
        return "SDK not initialized. Please restart the app and try again.";
      case GeniusNodeReturnValue.GENIUS_NODE_ERROR_PROCESS_IMAGE:
        return "Failed to process the job. Please check your input and try again.";
      case GeniusNodeReturnValue.GENIUS_NODE_ERROR_MINT:
        return "Token minting failed.";
      case GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT:
        return "Invalid job data.";
      case GeniusNodeReturnValue.GENIUS_NODE_ERROR_TRANSFER:
        return "Token transfer failed.";
      case GeniusNodeReturnValue.GENIUS_NODE_ERROR_PAY_DEV:
        return "Payment to dev failed.";
      case GeniusNodeReturnValue.GENIUS_NODE_RET_OK:
        return "";
    }
  }

  @override
  Future<void> close() {
    if (kDebugMode && kShowDevTools) {
      // Dart canonicalises instance method tear-offs from the same object,
      // so this removes the exact closure the constructor's addListener
      // added - the gate here must stay identical to the one guarding that
      // add, or the two go out of step. This cubit is constructed
      // per-subtree at `wallet_overview.dart:60` and `router.dart:369`, both
      // instances can be alive at once, and a leaked listener would emit on
      // a closed cubit the second time either drawer opens.
      DevMockJob.instance.scenario.removeListener(_onDevScenarioChanged);
    }
    return super.close();
  }
}
