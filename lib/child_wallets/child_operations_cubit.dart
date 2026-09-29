import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' show GeniusNodeReturnValue;
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show minionsToGnus;
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/squid_router/squid_util.dart' show toBaseUnits;
import 'package:genius_wallet/utils/wallet_utils.dart';

/// Which SDK write an operation represents. Each kind arrives with its own
/// submit and resolve arm below. [fund], [recover] and [revoke] are
/// main-side: they run only while the node runs as the main. [detach],
/// [register] and [move] are child-side: they run only while the node runs
/// as the account being detached, registered or moved.
enum ChildOperationKind { fund, recover, revoke, detach, register, move }

/// True for a kind that runs on the child's own node rather than the main's
/// -- [ChildOperationsCubit.submit] then requires the node to already be
/// running as `target`, not `main`.
bool _isChildSide(ChildOperationKind kind) =>
    kind == ChildOperationKind.detach ||
    kind == ChildOperationKind.register ||
    kind == ChildOperationKind.move;

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
    this.carriedMinions,
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

  /// The timed-out attempt(s) this op replaced, still able to land late.
  final BigInt? carriedMinions;
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
    carriedMinions: carriedMinions,
    baselineMinions: baselineMinions,
    submittedAt: submittedAt,
    notConfirmed: notConfirmed ?? this.notConfirmed,
  );

  /// Everything this op waits to see land: its own amount plus
  /// [carriedMinions]. Zero for a kind without an amount.
  BigInt get totalMinions =>
      (amountMinions ?? BigInt.zero) + (carriedMinions ?? BigInt.zero);
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

  /// True only in a dev-tools debug build with a read preset armed - every
  /// read and write below then routes to [DevMockChildWallets] instead of
  /// the SDK, so no real write can ever happen while a preset is armed.
  bool get _devMocked =>
      kDebugMode &&
      kShowDevTools &&
      DevMockChildWallets.instance.preset.value != null;

  /// [target]'s GNUS balance, in minions, from the mock while [_devMocked],
  /// or the SDK otherwise - the one read both [payingBalance] and
  /// [_signalMet] share for fund and recover.
  BigInt _childBalance(String target) => _devMocked
      ? DevMockChildWallets.balanceFor(target)
      : _api.getChildBalanceAll(target);

  /// [address]'s linked wallet name, or its own short address when it has
  /// none -- a badge or toast should never carry the bare word "Unlinked".
  String labelFor(String address) {
    final name = nameFor(address);
    return name == 'Unlinked'
        ? WalletUtils.getAddressForDisplay(address)
        : name;
  }

  /// [address]'s linked wallet name, or the literal word "Unlinked" when it
  /// has none -- unlike [labelFor], for the one place "Unlinked" itself is
  /// the intended copy (the main picker's row title, paired with the short
  /// address as its own subtitle).
  String nameFor(String address) {
    final appState = _readAppState();
    return AppBloc.sdkAccountName(
      address,
      appState.sdkAccountLinks,
      appState.wallets,
    );
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

  /// The user's own SDK accounts -- the main picker's candidate list.
  List<String> get ownAccounts => _readAppState().sdkAccounts;

  /// True for a kind that carries a GNUS amount -- fund and recover only.
  bool _hasAmount(ChildOperationKind kind) =>
      kind == ChildOperationKind.fund || kind == ChildOperationKind.recover;

  /// The balance [kind] still has free for [target]: the running account's
  /// own GNUS for Fund, the child's for Recover, less what this registry has
  /// already sent against it (see [_committed]). Zero on a bad balance parse.
  BigInt payingBalance(ChildOperationKind kind, String target) {
    switch (kind) {
      case ChildOperationKind.fund:
        final running = runningAccount?.toLowerCase();
        return _lessCommitted(
          _devMocked
              ? DevMockChildWallets.mainBalanceMinions
              : BigInt.tryParse(_api.getMinionsBalance()) ?? BigInt.zero,
          kind,
          (op) => op.fromAccount.toLowerCase() == running,
        );
      case ChildOperationKind.recover:
        return _lessCommitted(
          _childBalance(target),
          kind,
          (op) => op.target.toLowerCase() == target.toLowerCase(),
        );
      case ChildOperationKind.revoke:
      case ChildOperationKind.detach:
      case ChildOperationKind.register:
      case ChildOperationKind.move:
        return BigInt.zero;
    }
  }

  /// [balance] less [_committed], floored at zero.
  BigInt _lessCommitted(
    BigInt balance,
    ChildOperationKind kind,
    bool Function(ChildOperation) drawsOn,
  ) {
    final free = balance - _committed(kind, drawsOn);
    return free < BigInt.zero ? BigInt.zero : free;
  }

  /// The amounts of every tracked [kind] op [drawsOn] the same balance. A
  /// timed-out op counts too: there is no tx hash, so the SDK may still land
  /// it, and the balance read has not moved for it yet.
  // ponytail: one that never lands holds its amount until restart or a
  // resolve; the upgrade path is an SDK receipt per write.
  BigInt _committed(
    ChildOperationKind kind,
    bool Function(ChildOperation) drawsOn,
  ) => state.operations
      .where((op) => op.kind == kind && drawsOn(op))
      .fold(BigInt.zero, (sum, op) => sum + op.totalMinions);

  /// Submits [kind] against [target], or returns null with no SDK call when
  /// the node runs as the wrong side, the chosen main is the account itself
  /// (or a move's current main), [kind] is already pending on [target], or
  /// the amount is out of range. Appends and emits only on `RET_OK`.
  GeniusNodeReturnValue? submit({
    required ChildOperationKind kind,
    required String target,
    required String main,
    String? newMain,
    BigInt? amountMinions,
  }) {
    final running = runningAccount;
    final requiredRunner = _isChildSide(kind) ? target : main;
    if (running == null ||
        running.toLowerCase() != requiredRunner.toLowerCase()) {
      return null;
    }
    // Checked here, not only by the picker's exclusions: an account can
    // never become its own child, and a move to the main it already has is
    // no move at all.
    final selfReferential = switch (kind) {
      ChildOperationKind.register => main.toLowerCase() == target.toLowerCase(),
      ChildOperationKind.move =>
        newMain == null ||
            {
              target.toLowerCase(),
              main.toLowerCase(),
            }.contains(newMain.toLowerCase()),
      _ => false,
    };
    if (selfReferential) {
      return null;
    }
    if (isPending(kind, target)) {
      return null;
    }
    if (_hasAmount(kind)) {
      final amount = amountMinions;
      if (amount == null ||
          amount <= BigInt.zero ||
          amount > payingBalance(kind, target)) {
        return null;
      }
    }

    bool replaces(ChildOperation existing) =>
        existing.kind == kind &&
        existing.notConfirmed &&
        existing.target.toLowerCase() == target.toLowerCase();
    // A timed-out attempt can still land late, so a retry inherits its
    // baseline and amount: it resolves only once both have landed, never on
    // the abandoned attempt's money alone.
    final replaced = _hasAmount(kind)
        ? state.operations.where(replaces).firstOrNull
        : null;
    // Read BEFORE the write, so resolve() has an honest number to compare
    // the balance against once the write lands. Revoke and detach resolve
    // off the registrations list instead, so neither has a use for a
    // balance baseline.
    final baseline = _hasAmount(kind)
        ? replaced?.baselineMinions ?? _childBalance(target)
        : null;
    final op = ChildOperation(
      kind: kind,
      fromAccount: requiredRunner,
      target: target,
      main: main,
      newMain: newMain,
      amountMinions: amountMinions,
      carriedMinions: replaced?.totalMinions,
      baselineMinions: baseline,
      submittedAt: _now(),
    );
    // No real SDK write may ever be issued while a preset is armed --
    // submitWrite is the only path a write takes from here.
    final result = _devMocked
        ? DevMockChildWallets.instance.submitWrite(op)
        : switch (kind) {
            ChildOperationKind.fund => _api.fundChildGnus(
              minionsToGnus(amountMinions!),
              target,
            ),
            ChildOperationKind.recover => _api.recoverFromChildGnus(
              minionsToGnus(amountMinions!),
              target,
            ),
            ChildOperationKind.revoke => _api.revokeChild(target),
            ChildOperationKind.detach => _api.detachChild(
              const ChildRegistrationMetadata(),
            ),
            ChildOperationKind.register => _api.registerChild(
              main,
              const ChildRegistrationMetadata(),
            ),
            ChildOperationKind.move => _api.replaceMain(
              newMain!,
              const ChildRegistrationMetadata(),
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
            if (!replaces(existing)) existing,
          op,
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
        final current = _childBalance(op.target);
        return current >= (op.baselineMinions! + op.totalMinions);
      case ChildOperationKind.recover:
        final current = _childBalance(op.target);
        return current <= (op.baselineMinions! - op.totalMinions);
      case ChildOperationKind.revoke:
      case ChildOperationKind.detach:
        return _listedUnder(op.main, op.target) == false;
      case ChildOperationKind.register:
        return _listedUnder(op.main, op.target) == true;
      case ChildOperationKind.move:
        // Both halves have to be an OK, definite read -- a non-OK read of
        // either main leaves this pending rather than guessing.
        return _listedUnder(op.main, op.target) == false &&
            _listedUnder(op.newMain!, op.target) == true;
    }
  }

  /// Whether an OK read of [main]'s registrations lists [target],
  /// case-insensitively -- or null when the read itself wasn't OK. Callers
  /// only resolve on a definite true or false, never on an unknown read, so
  /// revoke, detach and register all stay pending through a failed read.
  bool? _listedUnder(String main, String target) {
    final registrations = _devMocked
        ? DevMockChildWallets.registrationsFor(
            DevMockChildWallets.instance.preset.value!,
            _readAppState(),
            main,
          )
        : _api.getChildRegistrations(main);
    if (!registrations.isOk) {
      return null;
    }
    return registrations.entries.any(
      (r) => r.childAddress.toLowerCase() == target.toLowerCase(),
    );
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
