import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/dashboard/gnus/cubit/gnus_cubit.dart';
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/submit_job/job_submission.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Same cap as the submit panel's file limit, which is private to it.
const int kGnusMaxJobBytes = 5 * 1024 * 1024;

const int _maxIdempotencyKeyLength = 128;
const int _defaultListLimit = 20;
const int _maxListLimit = 100;
const int _maxCursorLength = 512;
const int _maxSelectorLength = 256;
const Duration _idempotencyWindow = Duration(hours: 24);

/// The seam that decides whether a submit may spend. [cost] is the contract
/// base-unit string, [gas] the contract gas map or null, [payer] the lowercased
/// EVM address and [nodeAccount] the lowercased SDK address.
typedef GnusConfirm =
    Future<bool> Function({
      required String origin,
      required String cost,
      required Map<String, String>? gas,
      required String payer,
      required String nodeAccount,
    });

/// The default confirm: nothing spends until a real prompt replaces it.
Future<bool> rejectGnusConfirm({
  required String origin,
  required String cost,
  required Map<String, String>? gas,
  required String payer,
  required String nodeAccount,
}) async => false;

/// Answers the `gnus_*` contract for any transport. Takes `(origin, method,
/// params)`, returns a JSON-encodable result and throws only [GnusRpcError].
/// Holds no domain rule of its own: the gate, the owner and the store decide.
class GnusRpcHandler {
  GnusRpcHandler({
    required GeniusApi geniusApi,
    required AppState Function() readAppState,
    required WalletDetailsCubit walletDetails,
    required GnusCubit gnusCubit,
    required BridgeGate Function({bool fresh}) resolveGate,
    required GnusJobStore store,
    GnusConfirm confirm = rejectGnusConfirm,
    DateTime Function()? now,
  }) : _geniusApi = geniusApi,
       _jobs = JobSubmission(geniusApi: geniusApi),
       _readAppState = readAppState,
       _walletDetails = walletDetails,
       _gnusCubit = gnusCubit,
       _resolveGate = resolveGate,
       _store = store,
       _confirm = confirm,
       _now = now ?? DateTime.now;

  final GeniusApi _geniusApi;
  final JobSubmission _jobs;
  final AppState Function() _readAppState;
  final WalletDetailsCubit _walletDetails;
  final GnusCubit _gnusCubit;
  final BridgeGate Function({bool fresh}) _resolveGate;
  final GnusJobStore _store;
  final GnusConfirm _confirm;
  final DateTime Function() _now;

  /// `origin|idempotencyKey` of the submit holding the wallet's one burn slot,
  /// or null. Set synchronously before the first await of a submit, so two
  /// calls can never both pass the check.
  String? _inFlightSlot;

  Future<Object?> handle(String origin, String method, Object? params) async {
    final name = GnusRpcMethod.all.contains(method) ? method : 'unsupported';
    try {
      final result = await _dispatch(origin, method, params);
      debugPrint('gnus_rpc $name $origin ok');
      return result;
    } on GnusRpcError catch (e) {
      debugPrint('gnus_rpc $name $origin ${e.code}');
      rethrow;
    } catch (e) {
      debugPrint('gnus_rpc $name $origin internal ${e.runtimeType}');
      throw const GnusRpcError(GnusRpcCode.internal, 'Internal error');
    }
  }

  Future<Object?> _dispatch(String origin, String method, Object? params) {
    if (!GnusRpcMethod.all.contains(method)) {
      throw const GnusRpcError(
        GnusRpcCode.unsupportedMethod,
        'Method not supported',
      );
    }
    final args = _paramsMap(params);
    switch (method) {
      case GnusRpcMethod.submitJob:
        return _submitJob(origin, args);
      case GnusRpcMethod.listJobs:
        return _listJobs(args);
      case GnusRpcMethod.getJob:
        return _getJob(origin, args);
      default:
        throw const GnusRpcError(
          GnusRpcCode.unsupportedMethod,
          'Method not supported',
        );
    }
  }

  Map<String, Object?> _paramsMap(Object? params) {
    if (params == null) {
      return const {};
    }
    if (params is Map && params.keys.every((k) => k is String)) {
      return {for (final e in params.entries) e.key as String: e.value};
    }
    throw _invalidParams('params');
  }

  GnusRpcError _invalidParams(String name) =>
      GnusRpcError(GnusRpcCode.invalidParams, 'Invalid params: $name');

  /// A non-empty JSON object that encodes and fits [kGnusMaxJobBytes].
  Map<String, dynamic> _jobParam(Object? value) {
    if (value is! Map ||
        value.isEmpty ||
        !value.keys.every((k) => k is String)) {
      throw _invalidParams('job');
    }
    final job = Map<String, dynamic>.from(value);
    final String encoded;
    try {
      encoded = jsonEncode(job);
    } catch (_) {
      throw _invalidParams('job');
    }
    if (utf8.encode(encoded).length > kGnusMaxJobBytes) {
      throw _invalidParams('job');
    }
    return job;
  }

  String _idempotencyKeyParam(Object? value) {
    if (value is! String ||
        value.isEmpty ||
        value.length > _maxIdempotencyKeyLength) {
      throw _invalidParams('idempotencyKey');
    }
    return value;
  }

  int _limitParam(Object? value) {
    if (value == null) {
      return _defaultListLimit;
    }
    final int limit;
    if (value is int) {
      limit = value;
    } else if (value is double &&
        value.isFinite &&
        value == value.truncateToDouble()) {
      // JS numbers can cross a transport as doubles.
      limit = value.toInt();
    } else {
      throw _invalidParams('limit');
    }
    if (limit < 1 || limit > _maxListLimit) {
      throw _invalidParams('limit');
    }
    return limit;
  }

  String? _cursorParam(Object? value) {
    if (value == null) {
      return null;
    }
    if (value is! String || value.isEmpty || value.length > _maxCursorLength) {
      throw _invalidParams('cursor');
    }
    return value;
  }

  /// The one selector `gnus_getJob` was given, as `(name, value)`.
  (String, String) _jobSelectorParam(Map<String, Object?> args) {
    final given = [
      for (final name in const ['jobId', 'burnTxHash', 'idempotencyKey'])
        if (args[name] != null) name,
    ];
    if (given.length != 1) {
      throw _invalidParams('selector');
    }
    final value = args[given.single];
    if (value is! String ||
        value.isEmpty ||
        value.length > _maxSelectorLength) {
      throw _invalidParams(given.single);
    }
    return (given.single, value);
  }

  /// Switching and not-ready refusals shared by every method that needs the
  /// node.
  String _requireReadyNode() {
    final app = _readAppState();
    if (app.switchingSDKAccount != null) {
      throw const GnusRpcError(
        GnusRpcCode.accountSwitching,
        'Account switch in progress',
      );
    }
    final node = app.selectedSDKAccount;
    if (!_geniusApi.isSdkInitialized || node == null) {
      throw const GnusRpcError(GnusRpcCode.disconnected, 'Wallet not ready');
    }
    return node.toLowerCase();
  }

  Future<Object?> _listJobs(Map<String, Object?> args) async {
    final limit = _limitParam(args['limit']);
    final cursor = _cursorParam(args['cursor']);
    final node = _requireReadyNode();
    try {
      final page = _store.page(sdkAddress: node, limit: limit, cursor: cursor);
      return {
        'jobs': [for (final job in page.jobs) job.toContract()],
        'nextCursor': page.nextCursor,
      };
    } on FormatException {
      throw _invalidParams('cursor');
    }
  }

  /// The record plus `result: null`, or null when nothing matches. A record of
  /// another node account counts as not found.
  Future<Object?> _getJob(String origin, Map<String, Object?> args) async {
    final (name, value) = _jobSelectorParam(args);
    final node = _requireReadyNode();
    final job = switch (name) {
      'jobId' => _store.byJobId(value),
      'burnTxHash' => _store.byBurnHash(value),
      _ => _store.byIdempotencyKey(origin, value),
    };
    if (job == null || job.sdkAddress.toLowerCase() != node) {
      return null;
    }
    return {...job.toContract(), 'result': null};
  }

  GnusRpcError _submitInFlight() => const GnusRpcError(
    GnusRpcCode.busy,
    'A submit is already in flight',
    data: {'reason': GnusRpcReason.submitInFlight},
  );

  Future<Object?> _submitJob(String origin, Map<String, Object?> args) async {
    final job = _jobParam(args['job']);
    final idempotencyKey = _idempotencyKeyParam(args['idempotencyKey']);
    final nodeAccount = _requireReadyNode();

    // A retry of the call still in flight is busy, not a replay: nothing is
    // recorded for it yet.
    final slot = '$origin|$idempotencyKey';
    if (_inFlightSlot == slot) {
      throw _submitInFlight();
    }
    final first = _store.byIdempotencyKey(
      origin,
      idempotencyKey,
      notBefore: _now().toUtc().subtract(_idempotencyWindow),
    );
    if (first != null) {
      if (first.bodyHash != gnusJobBodyHash(job)) {
        throw const GnusRpcError(
          GnusRpcCode.invalidParams,
          'Idempotency key reused',
          data: {'reason': GnusRpcReason.idempotencyKeyReused},
        );
      }
      return _submitReply(
        first.burnTxHash,
        first.sdkAddress,
        first.status,
        jobId: first.jobId,
      );
    }
    if (_inFlightSlot != null) {
      throw _submitInFlight();
    }
    _inFlightSlot = slot;
    try {
      return await _burnAndRecord(origin, job, idempotencyKey, nodeAccount);
    } finally {
      _inFlightSlot = null;
    }
  }

  Future<Object?> _burnAndRecord(
    String origin,
    Map<String, dynamic> job,
    String idempotencyKey,
    String nodeAccount,
  ) async {
    final networkBefore = _walletDetails.state.selectedNetwork;
    final token = await _gnusCubit.fetchGnusInfo();

    // One synchronous block from here to the facts: the gate, the wallet and
    // the network are read together so they describe the same moment.
    final details = _walletDetails.state;
    final wallet = details.selectedWallet;
    final network = details.selectedNetwork;
    if (network != networkBefore) {
      throw const GnusRpcError(
        GnusRpcCode.internal,
        'Wallet not ready',
        data: {'reason': GnusRpcReason.accountChanged},
      );
    }
    final gateError = gnusErrorForGate(_resolveGate(fresh: true).state);
    if (gateError != null) {
      throw gateError;
    }
    final facts = JobFacts(
      chainId: network?.chainId,
      rpcUrl: network?.rpcUrl,
      walletAddress: wallet?.address,
      gnusAddress: token?.address,
    );

    final priced = await _jobs.cost(jsonEncode(job));
    final int minions = switch (priced) {
      JobCostFailed(:final reason) => throw GnusRpcError(
        GnusRpcCode.costUnavailable,
        'Cost unavailable',
        data: reason == null ? null : {'reason': reason},
      ),
      JobCostOk(minions: final cost) => cost,
    };
    final cost = gnusCostBaseUnits(minions);
    if (cost == null) {
      throw const GnusRpcError(GnusRpcCode.costUnavailable, 'Cost unavailable');
    }

    final gasResult = await _jobs.estimateGas(facts, minions);
    final gas = switch (gasResult) {
      GasEstimateOk(:final gas) => gnusGasPrice(
        gas,
        network?.nativeSymbol ?? network?.symbol,
      ),
      GasEstimateMissingData() || GasEstimateFailed() => null,
    };

    final payer = facts.walletAddress?.toLowerCase();
    if (payer == null) {
      throw const GnusRpcError(
        GnusRpcCode.internal,
        'Wallet not ready',
        data: {'reason': GnusRpcReason.missingData},
      );
    }
    final bool confirmed;
    try {
      confirmed = await _confirm(
        origin: origin,
        cost: cost,
        gas: gas,
        payer: payer,
        nodeAccount: nodeAccount,
      );
    } catch (e) {
      debugPrint('gnus_rpc confirm failed ${e.runtimeType}');
      throw const GnusRpcError(
        GnusRpcCode.userRejected,
        'User rejected the request',
      );
    }
    if (!confirmed) {
      throw const GnusRpcError(
        GnusRpcCode.userRejected,
        'User rejected the request',
      );
    }

    final submittedAt = _now().toUtc();
    final bodyHash = gnusJobBodyHash(job);
    GnusJob record(String burnTxHash, GnusJobStatus status) => GnusJob(
      jobId: null,
      burnTxHash: burnTxHash,
      sdkAddress: nodeAccount,
      origin: origin,
      idempotencyKey: idempotencyKey,
      submittedAt: submittedAt,
      cost: cost,
      status: status,
      bodyHash: bodyHash,
    );

    // Written the moment the burn lands, as bridgedNotProcessed: if the app is
    // killed before Process returns, the record says the spend happened and
    // the job is unconfirmed, never a false submitted.
    final result = await _jobs.submit(
      facts,
      jobCost: minions,
      jobJson: job,
      onBurned: (burnHash) =>
          _store.put(record(burnHash, GnusJobStatus.bridgedNotProcessed)),
    );
    switch (result) {
      case JobDone(:final txHash):
        await _store.put(record(txHash, GnusJobStatus.submitted));
        return _submitReply(txHash, nodeAccount, GnusJobStatus.submitted);
      case JobBridgedNotProcessed(:final bridgeHash):
        await _store.put(record(bridgeHash, GnusJobStatus.bridgedNotProcessed));
        return _submitReply(
          bridgeHash,
          nodeAccount,
          GnusJobStatus.bridgedNotProcessed,
        );
      case JobBridgeFailed():
        throw const GnusRpcError(GnusRpcCode.bridgeFailed, 'Bridge failed');
      case JobMissingData():
        throw const GnusRpcError(
          GnusRpcCode.internal,
          'Wallet not ready',
          data: {'reason': GnusRpcReason.missingData},
        );
    }
  }

  Map<String, Object?> _submitReply(
    String burnTxHash,
    String sdkAddress,
    GnusJobStatus status, {
    String? jobId,
  }) => {
    'jobId': jobId,
    'burnTxHash': burnTxHash,
    'sdkAddress': sdkAddress,
    'status': status.name,
  };
}
