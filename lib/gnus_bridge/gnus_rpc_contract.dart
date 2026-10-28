import 'package:genius_wallet/dashboard/bridge/bridge_gate.dart';

/// The `gnus_*` RPC contract in Dart: error type, codes, method and event
/// names, reasons, and the gate-state mapping. The one place the wallet names
/// them.
const String kGnusRpcVersion = '1';

/// A typed JSON-RPC error. Messages are fixed strings and never interpolate
/// input or an exception.
class GnusRpcError implements Exception {
  const GnusRpcError(this.code, this.message, {this.data});

  final int code;
  final String message;
  final Map<String, Object?>? data;

  Map<String, Object?> toJson() => {
    'code': code,
    'message': message,
    if (data != null) 'data': data,
  };

  @override
  String toString() => 'GnusRpcError($code, $message)';
}

abstract final class GnusRpcCode {
  static const int userRejected = 4001;
  static const int unauthorized = 4100;
  static const int unsupportedMethod = 4200;
  static const int disconnected = 4900;
  static const int invalidParams = -32602;
  static const int internal = -32603;
  static const int busy = -32005;
  static const int costUnavailable = -32010;
  static const int insufficientFunds = -32011;
  static const int payerCannotSign = -32012;
  static const int bridgeFailed = -32013;

  /// Defined for the contract; submit returns status `bridgedNotProcessed` as
  /// a result instead.
  static const int bridgedNotProcessed = -32014;
  static const int accountSwitching = -32015;
}

abstract final class GnusRpcMethod {
  static const String getAccounts = 'gnus_getAccounts';
  static const String estimate = 'gnus_estimate';
  static const String submitJob = 'gnus_submitJob';
  static const String listJobs = 'gnus_listJobs';
  static const String getJob = 'gnus_getJob';
  static const String getEarnings = 'gnus_getEarnings';

  /// `gnus_getAddress` is retired and deliberately absent.
  static const Set<String> all = {
    getAccounts,
    estimate,
    submitJob,
    listJobs,
    getJob,
    getEarnings,
  };
}

abstract final class GnusRpcEventName {
  static const String accountsChanged = 'gnus_accountsChanged';
  static const String networkChanged = 'gnus_networkChanged';
  static const String jobUpdated = 'gnus_jobUpdated';
  static const String disconnect = 'disconnect';
}

abstract final class GnusRpcReason {
  static const String submitInFlight = 'submit_in_flight';
  static const String idempotencyKeyReused = 'idempotency_key_reused';
  static const String balanceUnavailable = 'balance_unavailable';
  static const String missingData = 'missing_data';
  static const String accountChanged = 'account_changed';
  static const String noWallet = 'no_wallet';
  static const String viewOnly = 'view_only';
  static const String child = 'child';
  static const String notEarning = 'not_earning';
  static const String wrongNetwork = 'wrong_network';
  static const String noGnus = 'no_gnus';
  static const String gnusElsewhere = 'gnus_elsewhere';
  static const String checking = 'checking';
  static const String submissionOutcomeUnknown = 'submission_outcome_unknown';
  static const String bridgeUnavailable = 'bridge_unavailable';
}

GnusRpcError _payerError(String reason) => GnusRpcError(
  GnusRpcCode.payerCannotSign,
  'Payer cannot sign',
  data: {'reason': reason},
);

GnusRpcError _fundsError(String reason) => GnusRpcError(
  GnusRpcCode.insufficientFunds,
  'Insufficient GNUS balance',
  data: {'reason': reason},
);

GnusRpcError _notReadyError(String reason) => GnusRpcError(
  GnusRpcCode.internal,
  'Wallet not ready',
  data: {'reason': reason},
);

/// The refusal for a [BridgeGateState], or null when the gate is open. Every
/// state but `enabled` refuses, `checking` included (it also stands for
/// unreadable registrations). No default branch: map any new state here.
GnusRpcError? gnusErrorForGate(BridgeGateState state) {
  switch (state) {
    case BridgeGateState.enabled:
      return null;
    case BridgeGateState.switching:
      return const GnusRpcError(
        GnusRpcCode.accountSwitching,
        'Account switch in progress',
      );
    case BridgeGateState.notStarted:
      return const GnusRpcError(GnusRpcCode.disconnected, 'Wallet not ready');
    case BridgeGateState.noWallet:
      return _payerError(GnusRpcReason.noWallet);
    case BridgeGateState.viewOnly:
      return _payerError(GnusRpcReason.viewOnly);
    case BridgeGateState.child:
      return _payerError(GnusRpcReason.child);
    case BridgeGateState.notEarning:
      return _payerError(GnusRpcReason.notEarning);
    case BridgeGateState.wrongNetwork:
      return _payerError(GnusRpcReason.wrongNetwork);
    case BridgeGateState.noGnus:
      return _fundsError(GnusRpcReason.noGnus);
    case BridgeGateState.gnusElsewhere:
      return _fundsError(GnusRpcReason.gnusElsewhere);
    case BridgeGateState.balanceUnavailable:
      return _notReadyError(GnusRpcReason.balanceUnavailable);
    case BridgeGateState.checking:
      return _notReadyError(GnusRpcReason.checking);
  }
}
