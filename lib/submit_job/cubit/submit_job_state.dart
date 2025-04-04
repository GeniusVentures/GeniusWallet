import 'package:genius_api/models/token.dart';

class SubmitJobState {
  final String txHash;
  final String uploadedFileName;
  final Map<String, dynamic> uploadedJson;
  final int jobCost;
  final String jobGasCost;
  final Token gnusTokenDetails;
  final double gnusBalance;
  final FilePickerError filePickerError;
  final bool isFilePickerOpen;
  final bool isBridgingTokens;

  const SubmitJobState(
      {this.txHash = '',
      this.uploadedFileName = '',
      this.uploadedJson = const {},
      this.jobCost = 0,
      this.jobGasCost = '0.00 Gwei',
      this.gnusTokenDetails = const Token(),
      this.gnusBalance = 0,
      this.filePickerError = const FilePickerError(''),
      this.isFilePickerOpen = false,
      this.isBridgingTokens = false});

  SubmitJobState copyWith(
      {String? txHash,
      String? uploadedFileName,
      Map<String, dynamic>? uploadedJson,
      int? jobCost,
      String? jobGasCost,
      Token? gnusTokenDetails,
      double? gnusBalance,
      FilePickerError? filePickerError,
      bool? isFilePickerOpen,
      bool? isBridgingTokens}) {
    return SubmitJobState(
        txHash: txHash ?? this.txHash,
        uploadedFileName: uploadedFileName ?? this.uploadedFileName,
        uploadedJson: uploadedJson ?? this.uploadedJson,
        jobCost: jobCost ?? this.jobCost,
        jobGasCost: jobGasCost ?? this.jobGasCost,
        gnusTokenDetails: gnusTokenDetails ?? this.gnusTokenDetails,
        gnusBalance: gnusBalance ?? this.gnusBalance,
        filePickerError: filePickerError ?? this.filePickerError,
        isFilePickerOpen: isFilePickerOpen ?? this.isFilePickerOpen,
        isBridgingTokens: isBridgingTokens ?? this.isBridgingTokens);
  }
}

class FilePickerError {
  final String message;

  const FilePickerError(this.message);
}
