import 'package:genius_api/models/token.dart';

/// Which of `SubmitJobCubit.bridgeTokens()`'s three terminal branches the
/// last attempt landed on.
///
/// The bridge call and the process call are two independent operations -
/// money can move successfully while the job still fails to start - so a
/// single hash field cannot tell those two outcomes apart. This enum is the
/// discriminator; [SubmitJobState.bridgeHash] is the separate field that
/// carries proof for the middle branch. A distinct field (rather than
/// reusing [SubmitJobState.txHash]) matters because some consumers treat a
/// non-empty [SubmitJobState.txHash] as proof the job started - writing the
/// burned-token hash there without a discriminator would raise a success
/// message on a failed job.
enum SubmitOutcome {
  /// Nothing has been submitted yet, or the state has just been reset.
  notSubmitted,

  /// The bridge succeeded AND the job started.
  /// [SubmitJobState.txHash] carries proof.
  done,

  /// The bridge succeeded but `requestGeniusSDKProcess` failed to start the
  /// job. The tokens are already burned - [SubmitJobState.bridgeHash]
  /// carries proof. Deliberately NOT [SubmitJobState.txHash], so nothing
  /// downstream that treats a non-empty [SubmitJobState.txHash] as "job
  /// started" is fooled.
  bridgedNotProcessed,

  /// The bridge itself failed. Nothing was spent - both hash fields stay
  /// empty.
  bridgeFailed,
}

class SubmitJobState {
  /// Set only when [outcome] is [SubmitOutcome.done] - proof the job
  /// started.
  final String txHash;

  /// Set only when [outcome] is [SubmitOutcome.bridgedNotProcessed] - proof
  /// the tokens were burned even though the job never started.
  final String bridgeHash;

  final SubmitOutcome outcome;
  final String uploadedFileName;
  final Map<String, dynamic> uploadedJson;
  final int jobCost;
  final String jobGasCost;
  final Token gnusTokenDetails;
  final double gnusBalance;

  /// The picker was cancelled, the picked file wasn't valid JSON, an
  /// oversized file was refused, or some other picker-level throw.
  /// Surfaced as a toast titled for the picker.
  final String fileError;

  /// The job cannot be priced yet - a failed balance fetch, token-info
  /// fetch, cost lookup, missing precondition, or gas estimate. Rendered
  /// inline next to the cost, not as a toast, because it describes a state
  /// rather than an event.
  final String costError;

  /// A failure raised at commit time - missing data at the start of
  /// `bridgeTokens()`, the bridge itself failing, or the job failing to
  /// start after a successful bridge. Surfaced as a toast.
  final String submitError;

  final bool isFilePickerOpen;
  final bool isBridgingTokens;

  const SubmitJobState({
    this.txHash = '',
    this.bridgeHash = '',
    this.outcome = SubmitOutcome.notSubmitted,
    this.uploadedFileName = '',
    this.uploadedJson = const {},
    this.jobCost = 0,
    this.jobGasCost = '0.00 Gwei',
    this.gnusTokenDetails = const Token(),
    this.gnusBalance = 0,
    this.fileError = '',
    this.costError = '',
    this.submitError = '',
    this.isFilePickerOpen = false,
    this.isBridgingTokens = false,
  });

  SubmitJobState copyWith({
    String? txHash,
    String? bridgeHash,
    SubmitOutcome? outcome,
    String? uploadedFileName,
    Map<String, dynamic>? uploadedJson,
    int? jobCost,
    String? jobGasCost,
    Token? gnusTokenDetails,
    double? gnusBalance,
    String? fileError,
    String? costError,
    String? submitError,
    bool? isFilePickerOpen,
    bool? isBridgingTokens,
  }) {
    return SubmitJobState(
      txHash: txHash ?? this.txHash,
      bridgeHash: bridgeHash ?? this.bridgeHash,
      outcome: outcome ?? this.outcome,
      uploadedFileName: uploadedFileName ?? this.uploadedFileName,
      uploadedJson: uploadedJson ?? this.uploadedJson,
      jobCost: jobCost ?? this.jobCost,
      jobGasCost: jobGasCost ?? this.jobGasCost,
      gnusTokenDetails: gnusTokenDetails ?? this.gnusTokenDetails,
      gnusBalance: gnusBalance ?? this.gnusBalance,
      fileError: fileError ?? this.fileError,
      costError: costError ?? this.costError,
      submitError: submitError ?? this.submitError,
      isFilePickerOpen: isFilePickerOpen ?? this.isFilePickerOpen,
      isBridgingTokens: isBridgingTokens ?? this.isBridgingTokens,
    );
  }
}
