import 'dart:convert';

import 'package:flutter/foundation.dart'
    show debugPrint, kDebugMode, visibleForTesting;
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/web3/bridge_out_abi.dart'
    show bridgeUnavailableMessage;
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

sealed class JobCostResult {
  const JobCostResult({this.fixtureBalance});

  /// The wallet's GNUS balance, set only when the dev fixture answered. A
  /// caller that sees it must use it instead of reading the real balance.
  final double? fixtureBalance;
}

final class JobCostOk extends JobCostResult {
  const JobCostOk(this.minions, {super.fixtureBalance});

  final int minions;
}

/// The SDK could not price the job. [reason] is only set by the dev fixture.
final class JobCostFailed extends JobCostResult {
  const JobCostFailed([this.reason, double? fixtureBalance])
    : super(fixtureBalance: fixtureBalance);

  final String? reason;
}

sealed class GasEstimateResult {
  const GasEstimateResult();
}

final class GasEstimateOk extends GasEstimateResult {
  const GasEstimateOk(this.gas);

  final String gas;
}

final class GasEstimateMissingData extends GasEstimateResult {
  const GasEstimateMissingData();
}

/// [reason] is the bridge response's own error message, passed through.
/// [bridgeUnavailable] marks a chain with no `bridgeOut` at all.
final class GasEstimateFailed extends GasEstimateResult {
  const GasEstimateFailed(this.reason, {this.bridgeUnavailable = false});

  final String? reason;
  final bool bridgeUnavailable;
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

/// Nothing was burned. [reverted] when the burn was mined and reverted, so
/// it can never land later.
final class JobBridgeFailed extends JobSubmitResult {
  const JobBridgeFailed({this.reverted = false});

  final bool reverted;
}

/// The burn was sent but the network neither confirmed nor reverted it in
/// time: the GNUS may be spent. The job did not start.
final class JobBurnUnconfirmed extends JobSubmitResult {
  const JobBurnUnconfirmed(this.bridgeHash);

  final String bridgeHash;
}

final class JobMissingData extends JobSubmitResult {
  const JobMissingData();
}

/// Another submit is running from this app; nothing was burned.
final class JobBusy extends JobSubmitResult {
  const JobBusy();
}

/// Prices and submits a job: the one owner of the burn, the gas estimate, the
/// SDK cost and the SDK process calls, and of the dev fixture that stands in
/// for them. Holds no UI state and never emits; callers own state and copy.
class JobSubmission {
  JobSubmission({required this.geniusApi});

  final GeniusApi geniusApi;

  /// The largest job, encoded, that the panel or the gnus handler accepts.
  static const int maxJobBytes = 5 * 1024 * 1024;

  /// True while any instance's [submit] runs. The panel and the gnus handler
  /// burn from the same wallet, and two burns at once race on the nonce.
  static bool _submitting = false;

  // TODO: unhardcode bridge address
  static const int _bridgeDestinationChainId = 15305752297694;

  /// The one gate for every dev fixture answer in the job flow. Release builds
  /// can never open it, whatever `GW_DEV_TOOLS` says.
  static const bool devToolsEnabled = kDebugMode && kShowDevTools;

  /// The armed fixture scenario, or null when nothing is armed or the gate is
  /// closed.
  DevJobScenario? get devScenario =>
      devToolsEnabled ? DevMockJob.instance.scenario.value : null;

  /// The fixture's GNUS balance, or null when the real balance applies.
  double? get fixtureBalance =>
      devScenario != null ? DevMockJob.instance.balance : null;

  Future<JobCostResult> cost(String jobJson) async {
    final balance = fixtureBalance;
    if (balance != null) {
      if (DevMockJob.instance.costShouldFail) {
        return JobCostFailed(DevMockJob.costErrorMessage, balance);
      }
      return JobCostOk(DevMockJob.jobCost, fixtureBalance: balance);
    }

    final minions = await geniusApi.requestGeniusSDKCostAsync(jobJson: jobJson);
    if (minions == 0) {
      return const JobCostFailed();
    }
    return JobCostOk(minions);
  }

  Future<GasEstimateResult> estimateGas(JobFacts facts, int jobCost) async {
    // The fixture skips every precondition, as the dev pricing path always did.
    if (devScenario != null) {
      return const GasEstimateOk(DevMockJob.jobGasCost);
    }

    final chainId = facts.chainId;
    final rpcUrl = facts.rpcUrl;
    final walletAddress = facts.walletAddress;
    final gnusAddress = facts.gnusAddress;
    if (chainId == null ||
        rpcUrl == null ||
        walletAddress == null ||
        gnusAddress == null) {
      return const GasEstimateMissingData();
    }

    final resp = await geniusApi.getBrigeOutGasCost(
      sourceChainId: chainId,
      contractAddress: gnusAddress,
      rpcUrl: rpcUrl,
      address: walletAddress,
      amountToBurn: "$jobCost",
      destinationChainId: _bridgeDestinationChainId,
    );

    final gas = resp.data;
    if (!resp.isSuccess || gas == null) {
      return GasEstimateFailed(
        resp.errorMessage,
        bridgeUnavailable: resp.errorMessage == bridgeUnavailableMessage,
      );
    }
    return GasEstimateOk(gas);
  }

  /// Burns and processes one job, or answers [JobBusy] while another submit
  /// runs. [beforeBroadcast] sees the burn's hash before it is sent; with
  /// [expectedNode], Process runs only as that account.
  Future<JobSubmitResult> submit(
    JobFacts facts, {
    required int jobCost,
    required Map<String, dynamic> jobJson,
    Future<void> Function(String burnHash)? onBurned,
    Future<void> Function(String txHash)? beforeBroadcast,
    String? expectedNode,
  }) async {
    if (_submitting) {
      return const JobBusy();
    }
    _submitting = true;
    try {
      return await _submit(
        facts,
        jobCost: jobCost,
        jobJson: jobJson,
        onBurned: onBurned,
        beforeBroadcast: beforeBroadcast,
        expectedNode: expectedNode,
      );
    } finally {
      _submitting = false;
    }
  }

  Future<JobSubmitResult> _submit(
    JobFacts facts, {
    required int jobCost,
    required Map<String, dynamic> jobJson,
    Future<void> Function(String burnHash)? onBurned,
    Future<void> Function(String txHash)? beforeBroadcast,
    String? expectedNode,
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
      sgnsAccount: expectedNode,
      beforeBroadcast: beforeBroadcast,
    );

    final txHash = resp.data;
    if (resp.reverted) {
      return const JobBridgeFailed(reverted: true);
    }
    if (!resp.isSuccess && txHash != null) {
      return JobBurnUnconfirmed(txHash);
    }
    if (!resp.isSuccess || txHash == null) {
      return const JobBridgeFailed();
    }

    // The tokens are burned. [onBurned] lets a caller record the spend before
    // Process runs; a throw from it must not skip Process.
    if (onBurned != null) {
      try {
        await onBurned(txHash);
      } catch (e) {
        debugPrint('onBurned failed: ${e.runtimeType}');
      }
    }

    // A throw from the worker isolate must not lose the burn hash, so it
    // becomes the bridged-not-processed outcome. With [expectedNode], a switch
    // during the burn leaves the job waiting, recoverable, never misattributed.
    final GeniusNodeReturnValue? processResult;
    try {
      processResult = expectedNode == null
          ? await geniusApi.requestGeniusSDKProcessAsync(
              jobJson: jsonEncode(jobJson),
            )
          : await geniusApi.requestGeniusSDKProcessAsAccount(
              jobJson: jsonEncode(jobJson),
              expectedAccount: expectedNode,
            );
    } catch (e) {
      debugPrint('GeniusSDKProcess failed after burn: ${e.runtimeType}');
      return JobBridgedNotProcessed(
        txHash,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
      );
    }
    if (processResult == null) {
      return JobBridgedNotProcessed(
        txHash,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
      );
    }
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
      case SubmitOutcome.burnUnconfirmed:
        return const JobBurnUnconfirmed(DevMockJob.bridgeHash);
      case SubmitOutcome.notSubmitted:
        throw StateError('DevMockJob.outcome never returns notSubmitted');
    }
  }
}
