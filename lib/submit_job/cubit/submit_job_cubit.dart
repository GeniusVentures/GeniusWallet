import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class SubmitJobCubit extends Cubit<SubmitJobState> {
  final WalletDetailsCubit walletDetailsCubit;
  final GnusCubit gnusCubit;
  final GeniusApi geniusApi;

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
  }

  Future<void> _initialize() async {
    await fetchGnusTokenInfo();
    await fetchGnusBalance();
  }

  // Fetches and updates balance from gnusCubit
  Future<double?> fetchGnusBalance() async {
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

        final jobCost = geniusApi.requestGeniusSDKCost(
          jobJson: jsonEncode(jsonData),
        );

        final isGasFetchable =
            jsonData != null &&
            state.gnusTokenDetails.address != null &&
            jobCost != 0;

        if (!isGasFetchable) {
          setCostError('Unable to retrieve job cost');
          return;
        }

        // Get gas cost associated with uploaded job
        await getBridgeOutGasCost(jobCost);

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
        setFileError('No file selected.');
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
}
