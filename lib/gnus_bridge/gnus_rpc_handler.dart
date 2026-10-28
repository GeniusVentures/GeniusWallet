import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/models/token.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';
import 'package:genius_wallet/gnus_bridge/gnus_amounts.dart';
import 'package:genius_wallet/gnus_bridge/gnus_connection_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_job_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/reown/utilities.dart';
import 'package:genius_wallet/services/coins_service.dart';
import 'package:genius_wallet/submit_job/job_submission.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

const int _maxJobDepth = 32;
const int _maxIdempotencyKeyLength = 128;
const int _defaultListLimit = 20;
const int _maxListLimit = 100;
const int _maxCursorLength = 512;
const int _maxSelectorLength = 256;
const Duration _idempotencyWindow = Duration(hours: 24);
const int _recordWriteAttempts = 3;
const Duration _recordRetryDelay = Duration(seconds: 2);
const int _maxPromptsPerWindow = 3;
const Duration _promptWindow = Duration(minutes: 1);

/// A confirm still open after this is a rejection, so a prompt that never
/// completes cannot hold the wallet's one burn slot.
const Duration kGnusConfirmTimeout = Duration(minutes: 10);

/// The seam that decides whether a submit may spend. [cost] and [gas] are the
/// contract values, [payer] and [nodeAccount] lowercased addresses. After
/// [kGnusConfirmTimeout] the handler rejects and ignores a late answer.
typedef GnusConfirm =
    Future<bool> Function({
      required String origin,
      required String cost,
      required Map<String, String>? gas,
      required String payer,
      required String nodeAccount,
    });

/// The seam that asks the user whether [origin] may use the bridge at all.
/// Like the confirm, it is a rejection after [kGnusConfirmTimeout].
typedef GnusConnect = Future<bool> Function({required String origin});

/// The default connect: nothing connects until a real prompt replaces it.
Future<bool> rejectGnusConnect({required String origin}) async => false;

/// The default confirm: nothing spends until a real prompt replaces it.
Future<bool> rejectGnusConfirm({
  required String origin,
  required String cost,
  required Map<String, String>? gas,
  required String payer,
  required String nodeAccount,
}) async => false;

/// The node account's role from the child registrations: a child when another
/// main lists it, a main when its own list is non-empty, else none. Keys and
/// values compare lowercased. Whether a child may spend stays the gate's call.
({String role, String? main}) gnusNodeRole(
  String node,
  Map<String, Iterable<String>>? registrations,
) {
  if (registrations == null) {
    return (role: 'none', main: null);
  }
  final self = node.toLowerCase();
  var ownsChildren = false;
  for (final entry in registrations.entries) {
    final main = entry.key.toLowerCase();
    final children = entry.value.map((child) => child.toLowerCase());
    if (main == self) {
      ownsChildren = children.isNotEmpty;
    } else if (children.contains(self)) {
      return (role: 'child', main: main);
    }
  }
  return (role: ownsChildren ? 'main' : 'none', main: null);
}

/// One event for the page: [name] is a `GnusRpcEventName` value.
class GnusEvent {
  const GnusEvent(this.name, this.payload);

  final String name;
  final Map<String, Object?> payload;
}

/// What one call has done so far. Per call, never shared: concurrent calls
/// each hold their own.
class _CallScope {
  bool connected = false;
}

final RegExp _evmAddress = RegExp(r'^0x[0-9a-f]{40}$');

/// Answers the `gnus_*` contract for any transport. Takes `(origin, method,
/// params)`, returns a JSON-encodable result and throws only [GnusRpcError].
/// Holds no domain rule of its own: the gate, the owner and the store decide.
class GnusRpcHandler {
  GnusRpcHandler({
    required GeniusApi geniusApi,
    required AppState Function() readAppState,
    required WalletDetailsCubit walletDetails,
    required CoinService coinService,
    required BridgeGate Function({bool fresh}) resolveGate,
    required GnusJobStore store,
    required GnusConnectionStore connections,
    required Stream<AppState> appStates,
    Map<String, List<ChildWallet>>? Function()? readRegistrations,
    Stream<Object?>? registrationChanges,
    GnusConfirm confirm = rejectGnusConfirm,
    GnusConnect connect = rejectGnusConnect,
    DateTime Function()? now,
  }) : _geniusApi = geniusApi,
       _jobs = JobSubmission(geniusApi: geniusApi),
       _readAppState = readAppState,
       _walletDetails = walletDetails,
       _coins = coinService,
       _resolveGate = resolveGate,
       _store = store,
       _connections = connections,
       _readRegistrations = readRegistrations,
       _confirm = confirm,
       _connect = connect,
       _now = now ?? DateTime.now {
    _lastKey = _stateKey();
    _lastChainId = _walletDetails.state.selectedNetwork?.chainId;
    // The first state is a baseline, not a change.
    _enqueue(() async {
      final payload = await _accountsPayload();
      _lastPayload = payload == null ? null : jsonEncode(payload);
    });
    _subscriptions = [
      appStates.listen((_) => _onStateChange()),
      _walletDetails.stream.listen((_) => _onStateChange()),
      ?registrationChanges?.listen((_) => _enqueue(_publishAccounts)),
    ];
  }

  final GeniusApi _geniusApi;
  final JobSubmission _jobs;
  final AppState Function() _readAppState;
  final WalletDetailsCubit _walletDetails;
  final CoinService _coins;
  final BridgeGate Function({bool fresh}) _resolveGate;
  final GnusJobStore _store;
  final GnusConnectionStore _connections;
  final Map<String, List<ChildWallet>>? Function()? _readRegistrations;
  final GnusConfirm _confirm;
  final GnusConnect _connect;
  final DateTime Function() _now;

  /// `origin|idempotencyKey` of the submit holding the wallet's one burn slot,
  /// or null. Set synchronously before the first await of a submit, so two
  /// calls can never both pass the check.
  String? _inFlightSlot;

  /// The newest record of every burn this handler made, by
  /// `origin|idempotencyKey`. A same-key retry answers from here before the
  /// store; after a restart the intent written before the burn stops it.
  final Map<String, GnusJob> _burned = {};

  /// Origins with a prompt on screen, and when each origin's recent prompts
  /// were opened. In memory only; an origin's entry goes when it empties.
  final Set<String> _promptOpen = {};
  final Map<String, List<DateTime>> _promptTimes = {};

  final StreamController<GnusEvent> _events = StreamController.broadcast();
  late final List<StreamSubscription<Object?>> _subscriptions;
  Future<void> _queue = Future<void>.value();
  String? _lastKey;
  String? _lastPayload;
  int? _lastChainId;
  bool _disposed = false;

  /// Every event, for every origin. Transports must not forward this: use
  /// [eventsFor].
  @visibleForTesting
  Stream<GnusEvent> get events => _events.stream;

  /// `gnus_accountsChanged`, `gnus_networkChanged` and `gnus_jobUpdated` for
  /// [origin], while it is connected, and `gnus_jobUpdated` only for its own
  /// jobs. Checked per event, so a revoke stops delivery and a later connect
  /// resumes it without resubscribing. Transports forward only this stream.
  Stream<GnusEvent> eventsFor(String origin) => _events.stream.where(
    (event) =>
        _connections.isConnected(origin) &&
        (event.name != GnusRpcEventName.jobUpdated ||
            event.payload['origin'] == origin),
  );

  /// Stops listening and closes [events]. Safe to call twice.
  Future<void> dispose() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _events.close();
  }

  void _emit(String name, Map<String, Object?> payload) {
    if (!_disposed) {
      _events.add(GnusEvent(name, payload));
    }
  }

  /// Runs recomputes one at a time, so two emissions cannot interleave across
  /// the awaits inside a payload read.
  void _enqueue(Future<void> Function() job) {
    _queue = _queue.then((_) async {
      if (_disposed) {
        return;
      }
      try {
        await job();
      } catch (e) {
        debugPrint('gnus_rpc event failed ${e.runtimeType}');
      }
    });
  }

  /// Everything an accounts payload depends on that an emission can change,
  /// cheap to compare. It leaves out the processing feed, which ticks AppState
  /// about once a second, so those ticks never read registrations.
  String _stateKey() {
    final app = _readAppState();
    final details = _walletDetails.state;
    return jsonEncode([
      app.selectedSDKAccount,
      app.switchingSDKAccount,
      app.sdkAccounts,
      [
        for (final e in app.sdkAccountLinks.entries)
          '${e.key}>${e.value.walletAddress}',
      ],
      _geniusApi.isSdkInitialized,
      details.selectedWallet?.address,
      details.selectedWallet?.walletType.name,
      details.selectedNetwork?.chainId,
    ]);
  }

  void _onStateChange() {
    if (_disposed) {
      return;
    }
    final key = _stateKey();
    if (key == _lastKey) {
      return;
    }
    _lastKey = key;
    _enqueue(_publishChange);
  }

  Future<void> _publishChange() async {
    final chainId = _walletDetails.state.selectedNetwork?.chainId;
    if (chainId != _lastChainId) {
      _lastChainId = chainId;
      // The SDK half never changes inside a session: the SDK net applies only
      // after a restart. Do not fake it.
      _emit(GnusRpcEventName.networkChanged, {
        'sdk': (await _readSgnsNet()).name,
        'evmChainId': chainId,
      });
    }
    await _publishAccounts();
  }

  /// Emits the accounts payload when it differs from the last one. A node that
  /// is not ready clears the last payload, so its return is announced.
  Future<void> _publishAccounts() async {
    final payload = await _accountsPayload();
    if (payload == null) {
      _lastPayload = null;
      return;
    }
    final encoded = jsonEncode(payload);
    if (encoded == _lastPayload) {
      return;
    }
    _lastPayload = encoded;
    _emit(GnusRpcEventName.accountsChanged, payload);
  }

  /// Writes [job] and announces it when a record already stored under the same
  /// burn hash changes status. A first write is not a status change.
  Future<void> _putAnnouncing(GnusJob job) async {
    final before = _store.byBurnHash(job.burnTxHash)?.status;
    await _store.put(job);
    if (before != null && before != job.status) {
      _emit(GnusRpcEventName.jobUpdated, job.toContract());
    }
  }

  /// Keeps [job] as [slot]'s answer, then writes it and the burn hash onto
  /// [intent]. Never throws: the burn has happened, so the reply must not
  /// depend on the write. A failed write is retried until a newer record wins.
  Future<void> _record(String slot, GnusJob job, GnusSubmitIntent intent) {
    _burned[slot] = job;
    return _write(slot, job, intent.withBurn(job.burnTxHash), 1);
  }

  Future<void> _write(
    String slot,
    GnusJob job,
    GnusSubmitIntent intent,
    int attempt,
  ) async {
    if (_disposed || !identical(_burned[slot], job)) {
      return;
    }
    try {
      await _putAnnouncing(job);
      await _store.putIntent(intent);
    } catch (e) {
      debugPrint('gnus_rpc record write failed ${e.runtimeType} $attempt');
      if (attempt < _recordWriteAttempts) {
        unawaited(
          Future<void>.delayed(
            _recordRetryDelay * attempt,
            () => _write(slot, job, intent, attempt + 1),
          ),
        );
      }
    }
  }

  /// The SDK network applies only after a restart, so one read serves the
  /// handler's lifetime. A failed read is not kept, so the next call retries.
  Future<SgnsNet>? _sgnsNet;

  Future<SgnsNet> _readSgnsNet() => _sgnsNet ??= _geniusApi
      .sgnsNet()
      .catchError((Object e, StackTrace stack) {
        _sgnsNet = null;
        Error.throwWithStackTrace(e, stack);
      });

  Future<Object?> handle(String origin, String method, Object? params) async {
    final name = GnusRpcMethod.all.contains(method) ? method : 'unsupported';
    final scope = _CallScope();
    try {
      final result = await _dispatch(origin, method, params, scope);
      _requireStillConnected(origin, scope);
      debugPrint('gnus_rpc $name $origin ok');
      return result;
    } on GnusRpcError catch (e) {
      // A call that was connected when it began and is not now was in flight
      // at a revoke, whatever it found on the way.
      final error = _revoked(origin, scope) ? _unauthorized : e;
      debugPrint('gnus_rpc $name $origin ${error.code}');
      if (identical(error, e)) {
        rethrow;
      }
      throw error;
    } catch (e) {
      debugPrint('gnus_rpc $name $origin internal ${e.runtimeType}');
      throw const GnusRpcError(GnusRpcCode.internal, 'Internal error');
    }
  }

  static const _unauthorized = GnusRpcError(
    GnusRpcCode.unauthorized,
    'Unauthorized',
  );

  bool _revoked(String origin, _CallScope scope) =>
      scope.connected && !_connections.isConnected(origin);

  void _requireStillConnected(String origin, _CallScope scope) {
    if (_revoked(origin, scope)) {
      throw _unauthorized;
    }
  }

  Future<Object?> _dispatch(
    String origin,
    String method,
    Object? params,
    _CallScope scope,
  ) {
    if (!GnusRpcMethod.all.contains(method)) {
      throw const GnusRpcError(
        GnusRpcCode.unsupportedMethod,
        'Method not supported',
      );
    }
    final args = _paramsMap(params);
    switch (method) {
      case GnusRpcMethod.estimate:
        return _estimate(origin, scope, args);
      case GnusRpcMethod.submitJob:
        return _submitJob(origin, scope, args);
      case GnusRpcMethod.listJobs:
        return _listJobs(origin, scope, args);
      case GnusRpcMethod.getJob:
        return _getJob(origin, scope, args);
      case GnusRpcMethod.getAccounts:
        return _getAccounts(origin, scope);
      case GnusRpcMethod.getEarnings:
        return _getEarnings(origin, scope, args);
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

  /// A non-empty JSON object no deeper than [_maxJobDepth] that encodes and
  /// fits [JobSubmission.maxJobBytes]. The depth cap comes first: the encoder and the
  /// SDK's parser both recurse, and a deep enough job would crash the process.
  Map<String, dynamic> _jobParam(Object? value) {
    if (value is! Map ||
        value.isEmpty ||
        !value.keys.every((k) => k is String) ||
        !_withinJobDepth(value, 1)) {
      throw _invalidParams('job');
    }
    final job = Map<String, dynamic>.from(value);
    final String encoded;
    try {
      encoded = jsonEncode(job);
    } catch (_) {
      throw _invalidParams('job');
    }
    if (utf8.encode(encoded).length > JobSubmission.maxJobBytes) {
      throw _invalidParams('job');
    }
    return job;
  }

  /// False past [_maxJobDepth] levels, which also stops a map that contains
  /// itself.
  bool _withinJobDepth(Object? value, int depth) {
    if (depth > _maxJobDepth) {
      return false;
    }
    if (value is Map) {
      return value.values.every((child) => _withinJobDepth(child, depth + 1));
    }
    if (value is List) {
      return value.every((child) => _withinJobDepth(child, depth + 1));
    }
    return true;
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

  /// Returns once [origin] is connected, asking the user the first time. A
  /// decline, a timeout or a throw from the seam is a rejection.
  Future<void> _requireConnected(String origin, _CallScope scope) async {
    if (_connections.isConnected(origin)) {
      scope.connected = true;
      return;
    }
    final approved = await _prompt(origin, () => _connect(origin: origin));
    if (!approved) {
      throw const GnusRpcError(
        GnusRpcCode.userRejected,
        'User rejected the request',
      );
    }
    try {
      await _connections.connect(origin, _now().toUtc());
    } catch (e) {
      debugPrint('gnus_rpc connection write failed ${e.runtimeType}');
      throw const GnusRpcError(GnusRpcCode.internal, 'Internal error');
    }
    scope.connected = true;
  }

  /// Runs [show] as [origin]'s one open prompt. A second prompt while one is
  /// open, or a fourth inside the window, is -32005 and shows nothing. A
  /// decline, a timeout and a throw all answer false.
  Future<bool> _prompt(String origin, Future<bool> Function() show) async {
    if (_promptOpen.contains(origin)) {
      throw _confirmOpen();
    }
    final now = _now();
    final recent = [
      for (final at in _promptTimes[origin] ?? const <DateTime>[])
        if (now.difference(at) < _promptWindow) at,
    ];
    if (recent.length >= _maxPromptsPerWindow) {
      _promptTimes[origin] = recent;
      throw const GnusRpcError(
        GnusRpcCode.busy,
        'Busy',
        data: {'reason': GnusRpcReason.rateLimited},
      );
    }
    _promptTimes[origin] = [...recent, now];
    _promptOpen.add(origin);
    try {
      // Re-typed first: a seam written `async => throw` returns a
      // Future<Never>, whose timeout cannot answer false.
      return await show()
          .then<bool>((answer) => answer)
          .timeout(kGnusConfirmTimeout, onTimeout: () => false);
    } catch (e) {
      debugPrint('gnus_rpc prompt failed ${e.runtimeType}');
      return false;
    } finally {
      _promptOpen.remove(origin);
    }
  }

  GnusRpcError _confirmOpen() => const GnusRpcError(
    GnusRpcCode.busy,
    'Busy',
    data: {'reason': GnusRpcReason.confirmOpen},
  );

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

  Future<Object?> _listJobs(
    String origin,
    _CallScope scope,
    Map<String, Object?> args,
  ) async {
    final limit = _limitParam(args['limit']);
    final cursor = _cursorParam(args['cursor']);
    await _requireConnected(origin, scope);
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
  Future<Object?> _getJob(
    String origin,
    _CallScope scope,
    Map<String, Object?> args,
  ) async {
    final (name, value) = _jobSelectorParam(args);
    await _requireConnected(origin, scope);
    final node = _requireReadyNode();
    final job = switch (name) {
      'jobId' => _store.byJobId(value),
      'burnTxHash' => _store.byBurnHash(value),
      _ => _store.byIdempotencyKey(origin, value),
    };
    if (name == 'idempotencyKey') {
      final pending = _pendingJob(origin, value, node, job?.submittedAt);
      if (pending != null) {
        return pending;
      }
    }
    if (job == null || job.sdkAddress.toLowerCase() != node) {
      return null;
    }
    return {...job.toContract(), 'result': null};
  }

  /// The intent that blocks a same-key submit, so a page that lost the reply
  /// can find it, unless a record written at or after it ([recordedAt]) says
  /// more. An unreadable intent still answers.
  Map<String, Object?>? _pendingJob(
    String origin,
    String key,
    String node,
    DateTime? recordedAt,
  ) {
    final GnusSubmitIntent? intent;
    try {
      intent = _store.unresolvedIntent(origin, key);
    } on FormatException {
      return {
        ...GnusSubmitIntent.unreadableContract(origin, key),
        'result': null,
      };
    }
    if (intent == null ||
        intent.sdkAddress.toLowerCase() != node ||
        (recordedAt != null && !recordedAt.isBefore(intent.createdAt))) {
      return null;
    }
    return {...intent.toContract(), 'result': null};
  }

  /// Prices [job] through the owner: the whole-GNUS SDK cost, its contract
  /// base-unit string, and the dev fixture's balance when one answered.
  Future<({int minions, String cost, double? fixtureBalance})> _priceJob(
    Map<String, dynamic> job,
  ) async {
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
    return (
      minions: minions,
      cost: cost,
      fixtureBalance: priced.fixtureBalance,
    );
  }

  /// The GNUS token on [network], or null when it is unknown there.
  Future<Token?> _gnusToken(Network? network) async {
    if (network == null) {
      return null;
    }
    try {
      return await _coins.fetchGnusInfo(network);
    } catch (e) {
      debugPrint('gnus_rpc token read failed ${e.runtimeType}');
      return null;
    }
  }

  /// The GNUS balance of the payer in [facts], as the exact integer the token
  /// contract holds, or null when it cannot be read.
  Future<BigInt?> _payerBalance(double? fixtureBalance, JobFacts facts) async {
    if (fixtureBalance != null) {
      final units = gnusBalanceBaseUnits(fixtureBalance);
      return units == null ? null : BigInt.parse(units);
    }
    final payer = facts.walletAddress;
    final token = facts.gnusAddress;
    final rpcUrl = facts.rpcUrl;
    if (payer == null || token == null || rpcUrl == null) {
      return null;
    }
    try {
      return await _geniusApi.readTokenBalance(
        address: payer,
        contractAddress: token,
        rpcUrl: rpcUrl,
      );
    } catch (e) {
      debugPrint('gnus_rpc balance read failed ${e.runtimeType}');
      return null;
    }
  }

  /// The contract gas map, null when it cannot be estimated, and the owner's
  /// result, which a submit refuses on. [GasEstimateFailed.reason] is never
  /// forwarded.
  Future<({Map<String, String>? gas, GasEstimateResult result})> _gasPrice(
    JobFacts facts,
    int minions,
    String? nativeSymbol,
  ) async {
    final result = await _jobs.estimateGas(facts, minions);
    return (
      gas: result is GasEstimateOk
          ? gnusGasPrice(result.gas, nativeSymbol)
          : null,
      result: result,
    );
  }

  /// A read: it prices the job and reports what the payer holds, ignores the
  /// gate, and never prompts or burns. A balance it cannot read stays null
  /// rather than failing the call; a submit fails closed on the same value.
  Future<Object?> _estimate(
    String origin,
    _CallScope scope,
    Map<String, Object?> args,
  ) async {
    final job = _jobParam(args['job']);
    await _requireConnected(origin, scope);
    _requireReadyNode();

    final details = _walletDetails.state;
    final network = details.selectedNetwork;
    final token = await _gnusToken(network);
    final facts = JobFacts(
      chainId: network?.chainId,
      rpcUrl: network?.rpcUrl,
      walletAddress: details.selectedWallet?.address,
      gnusAddress: token?.address,
    );

    final priced = await _priceJob(job);
    final balance = await _payerBalance(priced.fixtureBalance, facts);
    final gas = await _gasPrice(
      facts,
      priced.minions,
      network?.nativeSymbol ?? network?.symbol,
    );
    return {
      'cost': priced.cost,
      'gas': gas.gas,
      'balance': balance?.toString(),
      'network': {
        'sdk': (await _readSgnsNet()).name,
        'evmChainId': network?.chainId,
      },
    };
  }

  /// Stops the burn if the origin was revoked or anything the user approved
  /// has moved since the confirm opened. The prompt can stay open for minutes.
  void _recheckAfterConfirm({
    required String origin,
    required String nodeAccount,
    required String payer,
    required int? chainId,
  }) {
    if (!_connections.isConnected(origin)) {
      throw _unauthorized;
    }
    final app = _readAppState();
    if (app.switchingSDKAccount != null) {
      throw const GnusRpcError(
        GnusRpcCode.accountSwitching,
        'Account switch in progress',
      );
    }
    final details = _walletDetails.state;
    if (app.selectedSDKAccount?.toLowerCase() != nodeAccount ||
        details.selectedWallet?.address.toLowerCase() != payer ||
        details.selectedNetwork?.chainId != chainId) {
      throw const GnusRpcError(
        GnusRpcCode.accountSwitching,
        'Account changed',
        data: {'reason': GnusRpcReason.accountChanged},
      );
    }
    final gateError = gnusErrorForGate(_resolveGate(fresh: true).state);
    if (gateError != null) {
      throw gateError;
    }
  }

  /// The `gnus_getAccounts` result, or null when the node is not ready (the
  /// 4900 case). A switch in progress is a result with `switching: true`, so a
  /// page can see why every other method answers -32015.
  Future<Map<String, Object?>?> _accountsPayload() async {
    final app = _readAppState();
    final switchingTo = app.switchingSDKAccount;
    final selected = app.selectedSDKAccount;
    final String? nodeRaw;
    if (switchingTo != null) {
      nodeRaw = selected ?? switchingTo;
    } else {
      nodeRaw = _geniusApi.isSdkInitialized ? selected : null;
    }
    if (nodeRaw == null) {
      return null;
    }
    final node = nodeRaw.toLowerCase();

    final linked = app.sdkAccountLinks[node]?.walletAddress.toLowerCase();
    final registrations = _readRegistrations?.call();
    final role = gnusNodeRole(
      node,
      registrations == null
          ? null
          : {
              for (final entry in registrations.entries)
                entry.key: [for (final child in entry.value) child.address],
            },
    );

    final details = _walletDetails.state;
    final wallet = details.selectedWallet;
    final payerAddress = wallet?.address.toLowerCase();
    // False exactly when a submit would refuse the payer with -32012.
    final canSign =
        wallet != null &&
        walletCanSign(wallet) &&
        gnusErrorForGate(_resolveGate().state)?.code !=
            GnusRpcCode.payerCannotSign;

    return {
      'node': {
        'sdkAddress': node,
        'linkedEvm': linked != null && _evmAddress.hasMatch(linked)
            ? linked
            : null,
        'role': role.role,
        'main': role.main,
      },
      'payer': {
        'evmAddress': payerAddress != null && _evmAddress.hasMatch(payerAddress)
            ? payerAddress
            : null,
        'canSign': canSign,
      },
      'switching': switchingTo != null,
      'network': {
        'sdk': (await _readSgnsNet()).name,
        'evmChainId': details.selectedNetwork?.chainId,
      },
      'version': kGnusRpcVersion,
      'unit': {'symbol': 'GNUS', 'decimals': kGnusDecimals},
    };
  }

  Future<Object?> _getAccounts(String origin, _CallScope scope) async {
    await _requireConnected(origin, scope);
    final payload = await _accountsPayload();
    if (payload == null) {
      throw const GnusRpcError(GnusRpcCode.disconnected, 'Wallet not ready');
    }
    return payload;
  }

  /// The node's balance and processing flag. `jobsProcessed` and `earned.*`
  /// are null until the SDK reports them, never 0. `includeChildren` is
  /// accepted and ignored.
  // ponytail: isProcessing is false both when idle and while the processing
  // feed has never ticked or is unavailable. Upgrade path: expose
  // processingFeedStatus as a field once the contract has a place for it.
  Future<Object?> _getEarnings(
    String origin,
    _CallScope scope,
    Map<String, Object?> args,
  ) async {
    final includeChildren = args['includeChildren'];
    if (includeChildren != null && includeChildren is! bool) {
      throw _invalidParams('includeChildren');
    }
    await _requireConnected(origin, scope);
    final node = _requireReadyNode();
    final balance = sgnusBalanceBaseUnits(_geniusApi.getSGNUSBalance());
    if (balance == null) {
      throw const GnusRpcError(
        GnusRpcCode.internal,
        'Wallet not ready',
        data: {'reason': GnusRpcReason.balanceUnavailable},
      );
    }
    return {
      'sdkAddress': node,
      'balance': balance,
      'processing': {
        'isProcessing': _readAppState().isProcessing,
        'jobsProcessed': null,
      },
      'earned': {'total': null, 'history': null},
    };
  }

  GnusRpcError _submitInFlight() => const GnusRpcError(
    GnusRpcCode.busy,
    'A submit is already in flight',
    data: {'reason': GnusRpcReason.submitInFlight},
  );

  static const _keyReused = GnusRpcError(
    GnusRpcCode.invalidParams,
    'Idempotency key reused',
    data: {'reason': GnusRpcReason.idempotencyKeyReused},
  );

  /// A submit for [idempotencyKey] began and its result was never recorded:
  /// it may have burned. [intent] is null when its record is unreadable.
  GnusRpcError _outcomeUnknown(
    String idempotencyKey,
    GnusSubmitIntent? intent,
  ) => GnusRpcError(
    GnusRpcCode.internal,
    'Submission outcome unknown',
    data: {
      'reason': GnusRpcReason.submissionOutcomeUnknown,
      'idempotencyKey': idempotencyKey,
      'burnTxHash': intent?.burnTxHash,
      'sdkAddress': intent?.sdkAddress,
      'payer': intent?.payer,
      'cost': intent?.cost,
      'createdAt': intent?.createdAt.toIso8601String(),
    },
  );

  Future<Object?> _submitJob(
    String origin,
    _CallScope scope,
    Map<String, Object?> args,
  ) async {
    final job = _jobParam(args['job']);
    final idempotencyKey = _idempotencyKeyParam(args['idempotencyKey']);
    await _requireConnected(origin, scope);
    final nodeAccount = _requireReadyNode();

    // A retry of the call still in flight is busy, not a replay: nothing is
    // recorded for it yet.
    final slot = '$origin|$idempotencyKey';
    if (_inFlightSlot == slot) {
      throw _submitInFlight();
    }
    final notBefore = _now().toUtc().subtract(_idempotencyWindow);
    final remembered = _burned[slot];
    final first =
        remembered != null && !remembered.submittedAt.isBefore(notBefore)
        ? remembered
        : _store.byIdempotencyKey(origin, idempotencyKey, notBefore: notBefore);
    final bodyHash = gnusJobBodyHash(job);
    if (first != null) {
      if (first.bodyHash != bodyHash) {
        throw _keyReused;
      }
      return _submitReply(
        first.burnTxHash,
        first.sdkAddress,
        first.status,
        jobId: first.jobId,
      );
    }
    // An intent with no job record: the app died, or every write failed,
    // after the intent was written. Whether it burned is unknown, so it must
    // never burn again, however old it is.
    final GnusSubmitIntent? pending;
    try {
      pending = _store.unresolvedIntent(origin, idempotencyKey);
    } on FormatException {
      throw _outcomeUnknown(idempotencyKey, null);
    }
    if (pending != null) {
      if (pending.bodyHash != bodyHash) {
        throw _keyReused;
      }
      throw _outcomeUnknown(idempotencyKey, pending);
    }
    if (_promptOpen.contains(origin)) {
      throw _confirmOpen();
    }
    if (_inFlightSlot != null) {
      throw _submitInFlight();
    }
    _inFlightSlot = slot;
    try {
      return await _burnAndRecord(
        origin,
        job,
        idempotencyKey,
        nodeAccount,
        slot,
      );
    } finally {
      _inFlightSlot = null;
    }
  }

  Future<Object?> _burnAndRecord(
    String origin,
    Map<String, dynamic> job,
    String idempotencyKey,
    String nodeAccount,
    String slot,
  ) async {
    final networkBefore = _walletDetails.state.selectedNetwork;
    final token = await _gnusToken(networkBefore);

    // One synchronous block from here to the facts: the gate, the wallet and
    // the network are read together so they describe the same moment.
    final details = _walletDetails.state;
    final wallet = details.selectedWallet;
    final network = details.selectedNetwork;
    if (network != networkBefore) {
      throw const GnusRpcError(
        GnusRpcCode.accountSwitching,
        'Account changed',
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
    final payer = facts.walletAddress?.toLowerCase();
    if (payer == null ||
        facts.gnusAddress == null ||
        facts.rpcUrl == null ||
        facts.chainId == null) {
      throw const GnusRpcError(
        GnusRpcCode.internal,
        'Wallet not ready',
        data: {'reason': GnusRpcReason.missingData},
      );
    }

    final priced = await _priceJob(job);
    final minions = priced.minions;
    final cost = priced.cost;

    // Fails closed: with no balance, affordability cannot be checked, and a
    // submit is the one call that spends. The estimate leaves it null.
    final balance = await _payerBalance(priced.fixtureBalance, facts);
    if (balance == null) {
      throw const GnusRpcError(
        GnusRpcCode.internal,
        'Wallet not ready',
        data: {'reason': GnusRpcReason.balanceUnavailable},
      );
    }
    // The token's own rule, in base units: the burn fails below the amount.
    if (BigInt.parse(cost) > balance) {
      throw const GnusRpcError(
        GnusRpcCode.insufficientFunds,
        'Insufficient GNUS balance',
      );
    }

    final gasPrice = await _gasPrice(
      facts,
      minions,
      network?.nativeSymbol ?? network?.symbol,
    );
    if (gasPrice.result is GasEstimateMissingData) {
      throw const GnusRpcError(
        GnusRpcCode.internal,
        'Wallet not ready',
        data: {'reason': GnusRpcReason.missingData},
      );
    }
    // A chain with no bridgeOut is a refusal of its own, before any confirm.
    final estimate = gasPrice.result;
    if (estimate is GasEstimateFailed && estimate.bridgeUnavailable) {
      throw const GnusRpcError(
        GnusRpcCode.bridgeFailed,
        'Bridge unavailable',
        data: {'reason': GnusRpcReason.bridgeUnavailable},
      );
    }
    // The panel's rule: the estimate builds the burn's own transaction, so a
    // failed estimate (no gas funds, a reverting call) is a failed burn.
    if (estimate is GasEstimateFailed) {
      throw const GnusRpcError(GnusRpcCode.costUnavailable, 'Cost unavailable');
    }
    final gas = gasPrice.gas;

    final confirmed = await _prompt(
      origin,
      () => _confirm(
        origin: origin,
        cost: cost,
        gas: gas,
        payer: payer,
        nodeAccount: nodeAccount,
      ),
    );
    if (!confirmed) {
      throw const GnusRpcError(
        GnusRpcCode.userRejected,
        'User rejected the request',
      );
    }

    _recheckAfterConfirm(
      origin: origin,
      nodeAccount: nodeAccount,
      payer: payer,
      chainId: facts.chainId,
    );

    final submittedAt = _now().toUtc();
    final bodyHash = gnusJobBodyHash(job);
    final intent = GnusSubmitIntent(
      origin: origin,
      idempotencyKey: idempotencyKey,
      bodyHash: bodyHash,
      payer: payer,
      sdkAddress: nodeAccount,
      cost: cost,
      createdAt: submittedAt,
    );
    // Fails closed: with no durable intent, a restart would forget this key
    // and a same-key retry could burn twice.
    try {
      await _store.putIntent(intent);
    } catch (e) {
      debugPrint('gnus_rpc intent write failed ${e.runtimeType}');
      throw const GnusRpcError(GnusRpcCode.internal, 'Internal error');
    }
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
    // The signed burn's hash is on disk before it is sent. From then on the
    // intent is never removed: a send with no answer may still have burned.
    String? signedHash;
    var hashWritten = false;
    final result = await _jobs.submit(
      facts,
      jobCost: minions,
      jobJson: job,
      beforeBroadcast: (hash) async {
        signedHash = hash;
        await _store.putIntent(intent.withBurn(hash));
        hashWritten = true;
      },
      onBurned: (burnHash) => _record(
        slot,
        record(burnHash, GnusJobStatus.bridgedNotProcessed),
        intent,
      ),
      expectedNode: nodeAccount,
    );
    switch (result) {
      case JobDone(:final txHash):
        await _record(slot, record(txHash, GnusJobStatus.submitted), intent);
        return _submitReply(txHash, nodeAccount, GnusJobStatus.submitted);
      case JobBridgedNotProcessed(:final bridgeHash):
        await _record(
          slot,
          record(bridgeHash, GnusJobStatus.bridgedNotProcessed),
          intent,
        );
        return _submitReply(
          bridgeHash,
          nodeAccount,
          GnusJobStatus.bridgedNotProcessed,
        );
      case JobBridgeFailed(:final reverted):
        final signed = signedHash;
        // A reverted burn is settled on chain, so the key may be retried.
        if (signed == null || reverted) {
          await _dropIntent(origin, idempotencyKey);
          throw const GnusRpcError(GnusRpcCode.bridgeFailed, 'Bridge failed');
        }
        if (!hashWritten) {
          throw const GnusRpcError(GnusRpcCode.internal, 'Internal error');
        }
        throw _outcomeUnknown(idempotencyKey, intent.withBurn(signed));
      case JobBurnUnconfirmed(:final bridgeHash):
        await _record(
          slot,
          record(bridgeHash, GnusJobStatus.unconfirmed),
          intent,
        );
        return _submitReply(bridgeHash, nodeAccount, GnusJobStatus.unconfirmed);
      case JobBusy():
        await _dropIntent(origin, idempotencyKey);
        throw _submitInFlight();
      case JobMissingData():
        await _dropIntent(origin, idempotencyKey);
        throw const GnusRpcError(
          GnusRpcCode.internal,
          'Wallet not ready',
          data: {'reason': GnusRpcReason.missingData},
        );
    }
  }

  /// Nothing burned, so the key may be retried. A failed delete leaves the
  /// intent, and a retry is then refused rather than risking a second burn.
  Future<void> _dropIntent(String origin, String idempotencyKey) async {
    try {
      await _store.deleteIntent(origin, idempotencyKey);
    } catch (e) {
      debugPrint('gnus_rpc intent delete failed ${e.runtimeType}');
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
