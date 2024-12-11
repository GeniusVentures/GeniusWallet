import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/dashboard/wallets/cubit/wallet_details_cubit.dart';

class SubmitJobState {
  final String? txHash;
  final String? uploadedFileName;
  final Map<String, dynamic>? uploadedJson;
  final int? jobCost;
  final String? jobGasCost;
  final Token? gnusTokenDetails;
  final double? gnusBalance;
  const SubmitJobState(
      {this.uploadedFileName,
      this.uploadedJson,
      this.jobCost,
      this.jobGasCost,
      this.gnusTokenDetails,
      this.gnusBalance,
      this.txHash});

  SubmitJobState copyWith(
      {String? uploadedFileName,
      Map<String, dynamic>? uploadedJson,
      int? jobCost,
      String? jobGasCost,
      Token? gnusTokenDetails,
      double? gnusBalance,
      String? txHash}) {
    return SubmitJobState(
        uploadedFileName: uploadedFileName ?? this.uploadedFileName,
        uploadedJson: uploadedJson ?? this.uploadedJson,
        jobCost: jobCost ?? this.jobCost,
        jobGasCost: jobGasCost ?? this.jobGasCost,
        gnusTokenDetails: gnusTokenDetails ?? this.gnusTokenDetails,
        gnusBalance: gnusBalance ?? this.gnusBalance,
        txHash: txHash ?? this.txHash);
  }
}

class SubmitJobCubit extends Cubit<SubmitJobState> {
  final WalletDetailsCubit walletDetailsCubit;
  final GnusCubit gnusCubit;
  final GeniusApi geniusApi;

  SubmitJobCubit(
      {required this.walletDetailsCubit,
      required this.gnusCubit,
      required this.geniusApi,
      Token? gnusTokenDetails,
      String? uploadedFileName,
      Map<String, dynamic>? uploadedJson,
      int? jobCost,
      String? jobGasCost,
      double? gnusBalance,
      String? txHash})
      : super(SubmitJobState(
            uploadedFileName: uploadedFileName,
            uploadedJson: uploadedJson,
            jobCost: jobCost ?? 0,
            jobGasCost: jobGasCost ?? '0',
            gnusTokenDetails: gnusTokenDetails,
            gnusBalance: gnusBalance,
            txHash: txHash)) {
    // Automatically fetch necessary data on cubit initialization
    _initialize();
  }

  Future<void> _initialize() async {
    await fetchGnusTokenInfo();
    await fetchGnusBalance();
  }

  // Fetches and updates balance from gnusCubit
  Future<void> fetchGnusBalance() async {
    final resp = await gnusCubit.fetchGnusBalance();
    final balance = resp?.balance;

    if (balance == null) {
      print('balance issue');
      return; // TODO: handle error
    }

    emit(state.copyWith(gnusBalance: balance));
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
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.isNotEmpty) {
        final file = File(result.files.single.path!);
        final content = await file.readAsString();
        final jsonData = jsonDecode(content);
        final jobCost =
            geniusApi.requestGeniusSDKCost(jobJson: jsonEncode(jsonData));

        final isGasFetchable =
            jsonData != null && state.gnusTokenDetails != null && jobCost != 0;

        if (!isGasFetchable) {
          print('gas is not fetchable');
          return; // TODO: handle possible error
        }

        // get gas cost associated with uploaded job
        await getBridgeOutGasCost(jobCost);

        emit(state.copyWith(
          uploadedFileName: result.files.single.name,
          uploadedJson: jsonData,
          jobCost: jobCost,
        ));
      }
    } catch (e) {
      // TODO: handle any error with file picker
      resetState();
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
        rpcUrl == null ||
        state.jobCost == null) {
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

    // refresh gnus balance
    await fetchGnusBalance();

    final txHash = resp.data;

    if (!resp.isSuccess || txHash == null) {
      return; // TODO: handle errors if bridge out fails
    }

    emit(state.copyWith(txHash: txHash));
  }

  void resetState() {
    emit(state.copyWith(
      jobCost: null,
      uploadedJson: null,
      uploadedFileName: null,
      jobGasCost: null,
      txHash: null,
    ));
  }
}
