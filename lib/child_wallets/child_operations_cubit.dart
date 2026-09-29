import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' show GeniusNodeReturnValue;
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show minionsToGnus;
import 'package:genius_wallet/squid_router/squid_util.dart' show toBaseUnits;
import 'package:genius_wallet/utils/wallet_utils.dart';

/// Which SDK write an operation represents. Each kind arrives with its own
/// submit and resolve arm below -- fund is the first.
enum ChildOperationKind { fund }

/// How long an unresolved operation stays pending before it reads "Not
/// confirmed yet" instead.
const childOperationTimeout = Duration(minutes: 2);

/// One in-flight or timed-out SDK write. Public addresses, minions and a
/// timestamp only -- never a key, mnemonic or seed.
class ChildOperation {
  const ChildOperation({
    required this.kind,
    required this.fromAccount,
    required this.target,
    required this.main,
    this.newMain,
    this.amountMinions,
    this.baselineMinions,
    required this.submittedAt,
    this.notConfirmed = false,
  });

  final ChildOperationKind kind;
  final String fromAccount;
  final String target;
  final String main;
  final String? newMain;
  final BigInt? amountMinions;
  final BigInt? baselineMinions;
  final DateTime submittedAt;
  final bool notConfirmed;

  ChildOperation copyWith({bool? notConfirmed}) => ChildOperation(
    kind: kind,
    fromAccount: fromAccount,
    target: target,
    main: main,
    newMain: newMain,
    amountMinions: amountMinions,
    baselineMinions: baselineMinions,
    submittedAt: submittedAt,
    notConfirmed: notConfirmed ?? this.notConfirmed,
  );
}

/// [operations] in submission order. [justResolved] holds only the
/// operations the latest [ChildOperationsCubit.resolve] call resolved, and is
/// empty on every other emit -- the one-shot signal a toast listener reads.
class ChildOperationsState {
  const ChildOperationsState({
    this.operations = const [],
    this.justResolved = const [],
  });

  final List<ChildOperation> operations;
  final List<ChildOperation> justResolved;
}

/// The one app-level registry every child write goes through. Owns every
/// in-flight operation so a fund keeps resolving after its screen closes.
/// ponytail: memory-only, a restart forgets it all -- upgrade path is
/// persisting [ChildOperation]'s public addresses and amounts.
class ChildOperationsCubit extends Cubit<ChildOperationsState> {
  ChildOperationsCubit({
    required GeniusApi api,
    required AppState Function() readAppState,
    DateTime Function() now = DateTime.now,
  }) : _api = api,
       _readAppState = readAppState,
       _now = now,
       super(const ChildOperationsState());

  final GeniusApi _api;
  final AppState Function() _readAppState;
  final DateTime Function() _now;
  Timer? _pollTimer;

  /// The account the node currently runs as, or null when it isn't running.
  String? get runningAccount => _readAppState().selectedSDKAccount;

  /// [address]'s linked wallet name, or its own short address when it has
  /// none -- a badge or toast should never carry the bare word "Unlinked".
  String labelFor(String address) {
    final appState = _readAppState();
    final name = AppBloc.sdkAccountName(
      address,
      appState.sdkAccountLinks,
      appState.wallets,
    );
    return name == 'Unlinked'
        ? WalletUtils.getAddressForDisplay(address)
        : name;
  }

  /// The most recently submitted operation targeting [target], or null when
  /// none is tracked.
  ChildOperation? latestFor(String target) {
    for (final op in state.operations.reversed) {
      if (op.target.toLowerCase() == target.toLowerCase()) {
        return op;
      }
    }
    return null;
  }

  /// True while a [kind] operation on [target] is still pending -- a
  /// notConfirmed op never counts, since it has already stopped blocking.
  bool isPending(ChildOperationKind kind, String target) =>
      state.operations.any(
        (op) =>
            op.kind == kind &&
            !op.notConfirmed &&
            op.target.toLowerCase() == target.toLowerCase(),
      );

  /// True while anything submitted from [account] is still pending.
  bool hasPendingFrom(String account) => state.operations.any(
    (op) =>
        !op.notConfirmed &&
        op.fromAccount.toLowerCase() == account.toLowerCase(),
  );

  /// The balance [kind] draws on for [target]. Fund draws on the running
  /// account's own GNUS balance -- BigInt.tryParse on the SDK's decimal
  /// string, zero on a bad parse rather than a thrown exception.
  BigInt payingBalance(ChildOperationKind kind, String target) {
    switch (kind) {
      case ChildOperationKind.fund:
        return BigInt.tryParse(_api.getMinionsBalance()) ?? BigInt.zero;
    }
  }

  /// Submits [kind] against [target], or returns null with no SDK call when
  /// the node isn't running as [main] or the amount is out of range. Only
  /// appends the operation, and only emits, on `RET_OK`.
  GeniusNodeReturnValue? submit({
    required ChildOperationKind kind,
    required String target,
    required String main,
    String? newMain,
    BigInt? amountMinions,
  }) {
    final running = runningAccount;
    if (running == null || running.toLowerCase() != main.toLowerCase()) {
      return null;
    }
    if (isPending(kind, target)) {
      return null;
    }
    final amount = amountMinions;
    if (amount == null ||
        amount <= BigInt.zero ||
        amount > payingBalance(kind, target)) {
      return null;
    }

    // Read BEFORE the write, so resolve() has an honest number to compare
    // the balance against once the write lands.
    final baseline = _api.getChildBalanceAll(target);
    final result = switch (kind) {
      ChildOperationKind.fund => _api.fundChildGnus(
        minionsToGnus(amount),
        target,
      ),
    };
    if (result != GeniusNodeReturnValue.GENIUS_NODE_RET_OK) {
      return result;
    }

    emit(
      ChildOperationsState(
        operations: [
          // Drop any notConfirmed op this same kind+target already holds --
          // this submit replaces it, not adds a second entry for the child.
          for (final existing in state.operations)
            if (!(existing.kind == kind &&
                existing.notConfirmed &&
                existing.target.toLowerCase() == target.toLowerCase()))
              existing,
          ChildOperation(
            kind: kind,
            fromAccount: main,
            target: target,
            main: main,
            newMain: newMain,
            amountMinions: amount,
            baselineMinions: baseline,
            submittedAt: _now(),
          ),
        ],
      ),
    );
    // Started here, not in the constructor: a registry with nothing pending
    // never polls. Cancelled again in resolve() once nothing is left.
    _pollTimer ??= Timer.periodic(
      const Duration(seconds: 10),
      (_) => resolve(),
    );
    return result;
  }

  /// Checks each op's signal first, then times out a still-pending one past
  /// [childOperationTimeout]. "Check again" calls this same method. No-op
  /// when nothing changed, so a listener never fires on an unrelated emit.
  void resolve() {
    if (state.operations.isEmpty) {
      return;
    }
    final now = _now();
    final resolved = <ChildOperation>[];
    final remaining = <ChildOperation>[];
    var changed = false;
    for (final op in state.operations) {
      if (_signalMet(op)) {
        resolved.add(op);
        changed = true;
        continue;
      }
      if (!op.notConfirmed &&
          !now.isBefore(op.submittedAt.add(childOperationTimeout))) {
        remaining.add(op.copyWith(notConfirmed: true));
        changed = true;
      } else {
        remaining.add(op);
      }
    }
    if (!changed) {
      return;
    }
    emit(ChildOperationsState(operations: remaining, justResolved: resolved));
    // Stops once nothing left is actually pending -- a notConfirmed op never
    // resolves on its own, so polling it further would be wasted reads.
    if (remaining.every((op) => op.notConfirmed)) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  bool _signalMet(ChildOperation op) {
    switch (op.kind) {
      case ChildOperationKind.fund:
        final current = _api.getChildBalanceAll(op.target);
        return current >= (op.baselineMinions! + op.amountMinions!);
    }
  }

  @override
  Future<void> close() {
    _pollTimer?.cancel();
    return super.close();
  }
}

/// Parses a typed GNUS amount into exact minions, or the reason it can't be
/// parsed. [payer] names the account an over-balance error is about -- the
/// main's balance for Fund, the child's for Recover.
({BigInt? minions, String? error}) parseGnusAmount(
  String typed, {
  required BigInt balanceMinions,
  required String payer,
}) {
  const decimals = 6;
  final trimmed = typed.trim();
  final minions = toBaseUnits(trimmed, decimals);
  // toBaseUnits truncates rather than rejects a 7th decimal, so the
  // over-precision check has to read the typed text itself.
  if (minions != null &&
      RegExp('\\.\\d{$decimals}\\d*[1-9]').hasMatch(trimmed)) {
    return (
      minions: null,
      error: 'GNUS supports up to $decimals decimal places.',
    );
  }
  if (minions == null) {
    return (minions: null, error: 'Enter an amount.');
  }
  if (minions <= BigInt.zero) {
    return (minions: null, error: 'Enter an amount greater than zero.');
  }
  if (minions > balanceMinions) {
    return (minions: null, error: "$payer doesn't have that much GNUS.");
  }
  return (minions: minions, error: null);
}
