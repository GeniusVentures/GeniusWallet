import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';

class SubmitJobCubit extends Cubit<SubmitJobState> {
  final WalletDetailsCubit walletDetailsCubit;
  final GnusCubit gnusCubit;
  final GeniusApi geniusApi;

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
      print('balance issue');
      return 0; // TODO: handle error
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
      print('token issue');
      return; //TODO: handle error
    }

    emit(state.copyWith(gnusTokenDetails: info));
  }

  Future<void> openFilePicker() async {
    emit(state.copyWith(isFilePickerOpen: true)); // Indicate picker is open

    try {
      emit(state.copyWith(filePickerError: null)); // Clear previous errors

      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
        allowMultiple: false,
        dialogTitle: "Select a valid JSON file",
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final jsonData = jsonDecode(content);
        final jobCost =
            geniusApi.requestGeniusSDKCost(jobJson: jsonEncode(jsonData));

        final isGasFetchable = jsonData != null &&
            state.gnusTokenDetails.address != null &&
            jobCost != 0;

        if (!isGasFetchable) {
          setFilePickerError('Unable to retrieve job cost');
          return;
        }

        // Get gas cost associated with uploaded job
        await getBridgeOutGasCost(jobCost);

        emit(state.copyWith(
          uploadedFileName: result.files.single.name,
          uploadedJson: jsonData,
          jobCost: jobCost,
        ));
      } else {
        setFilePickerError('No file selected.');
      }
    } catch (e) {
      if (e.runtimeType == FormatException) {
        return setFilePickerError('The Selected File is not valid json');
      }
      setFilePickerError('Failed to pick file: ${e.runtimeType}');
    } finally {
      emit(
          state.copyWith(isFilePickerOpen: false)); // Indicate picker is closed
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
      return; // TODO: handle errors
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
      return; // TODO: handle errors if bridge out fails
    }

    emit(state.copyWith(jobGasCost: jobGasCost));
  }

  Future<void> bridgeTokens() async {
    emit(state.copyWith(isBridgingTokens: true));
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
      emit(state.copyWith(isBridgingTokens: false));
      return; // TODO: handle errors
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
      emit(state.copyWith(isBridgingTokens: false));

      return; // TODO: handle errors if bridge out fails
    }

    // process the job
    geniusApi.requestGeniusSDKProcess(jobJson: jsonEncode(uploadedJson));

    fetchGnusBalanceWithDelay();

    emit(state.copyWith(txHash: txHash, isBridgingTokens: false));
  }

  // used to fetch the gnus balance of the wallet with some delay
  // fetching this immediately after doing a transaction seems to return a stale value
  Future<void> fetchGnusBalanceWithDelay() async {
    await Future.delayed(const Duration(milliseconds: 5000));
    fetchGnusBalance();
  }

  void resetState() {
    emit(state.copyWith(
        jobCost: 0,
        uploadedJson: {},
        uploadedFileName: '',
        jobGasCost: '',
        txHash: '',
        filePickerError: null));
  }

  void setFilePickerError(String errorMessage) {
    emit(state.copyWith(
      filePickerError: FilePickerError(errorMessage), // Use FilePickerError
    ));
  }

  void resetFilePickerError() {
    setFilePickerError(""); // Reset error state
  }
}
