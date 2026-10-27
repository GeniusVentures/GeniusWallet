import 'dart:convert';

import 'package:flutter/foundation.dart' show kDebugMode, visibleForTesting;
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_job.dart';
import 'package:genius_wallet/submit_job/cubit/submit_job_state.dart';

/// The wallet, network and GNUS token a job call acts on, read once by the
/// caller and passed by value so a wallet switch mid-call cannot retarget it.
class JobFacts {
  const JobFacts({
    required this.chainId,
    required this.rpcUrl,
    required this.walletAddress,
    required this.gnusAddress,
  });

  final int? chainId;
  final String? rpcUrl;
  final String? walletAddress;
  final String? gnusAddress;
}

sealed class JobSubmitResult {
  const JobSubmitResult();
}

final class JobDone extends JobSubmitResult {
  const JobDone(this.txHash);

  final String txHash;
}

/// The burn went through but the job never started.
final class JobBridgedNotProcessed extends JobSubmitResult {
  const JobBridgedNotProcessed(this.bridgeHash, this.processResult);

  final String bridgeHash;
  final GeniusNodeReturnValue processResult;
}

final class JobBridgeFailed extends JobSubmitResult {
  const JobBridgeFailed();
}

final class JobMissingData extends JobSubmitResult {
  const JobMissingData();
}

/// Prices and submits a job: the one owner of the burn, the gas estimate, the
/// SDK cost and the SDK process calls, and of the dev fixture that stands in
/// for them. Holds no UI state and never emits; callers own state and copy.
class JobSubmission {
  JobSubmission({required this.geniusApi});

  final GeniusApi geniusApi;

  // TODO: unhardcode bridge address
  static const int _bridgeDestinationChainId = 15305752297694;

  /// The one gate for every dev fixture answer in the job flow. Release builds
  /// can never open it, whatever `GW_DEV_TOOLS` says.
  static const bool devToolsEnabled = kDebugMode && kShowDevTools;

  /// The armed fixture scenario, or null when nothing is armed or the gate is
  /// closed.
  DevJobScenario? get devScenario =>
      devToolsEnabled ? DevMockJob.instance.scenario.value : null;

  Future<JobSubmitResult> submit(
    JobFacts facts, {
    required int jobCost,
    required Map<String, dynamic> jobJson,
  }) async {
    // Sits before the precondition guard: that guard protects the two calls
    // the fixture replaces, and a dev environment with no token info would
    // otherwise reject every submission.
    if (devScenario != null) {
      await Future.delayed(DevMockJob.inFlightDelay);
      return devSubmitResult(DevMockJob.instance.outcome);
    }

    final chainId = facts.chainId;
    final rpcUrl = facts.rpcUrl;
    final walletAddress = facts.walletAddress;
    final gnusAddress = facts.gnusAddress;
    if (chainId == null ||
        rpcUrl == null ||
        walletAddress == null ||
        gnusAddress == null ||
        jobCost == 0 ||
        jobJson.isEmpty) {
      return const JobMissingData();
    }

    final resp = await geniusApi.bridgeOut(
      sourceChainId: chainId,
      contractAddress: gnusAddress,
      rpcUrl: rpcUrl,
      address: walletAddress,
      amountToBurn: jobCost.toString(),
      destinationChainId: _bridgeDestinationChainId,
    );

    final txHash = resp.data;
    if (!resp.isSuccess || txHash == null) {
      return const JobBridgeFailed();
    }

    final processResult = geniusApi.requestGeniusSDKProcess(
      jobJson: jsonEncode(jobJson),
    );
    if (processResult != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      return JobBridgedNotProcessed(txHash, processResult);
    }
    return JobDone(txHash);
  }

  /// Pure mapping of a fixture outcome, split out because the gate cannot
  /// open under `flutter test`.
  @visibleForTesting
  static JobSubmitResult devSubmitResult(SubmitOutcome outcome) {
    switch (outcome) {
      case SubmitOutcome.done:
        return const JobDone(DevMockJob.txHash);
      case SubmitOutcome.bridgeFailed:
        return const JobBridgeFailed();
      case SubmitOutcome.bridgedNotProcessed:
        return const JobBridgedNotProcessed(
          DevMockJob.bridgeHash,
          DevMockJob.processFailure,
        );
      case SubmitOutcome.notSubmitted:
        throw StateError('DevMockJob.outcome never returns notSubmitted');
    }
  }
}
