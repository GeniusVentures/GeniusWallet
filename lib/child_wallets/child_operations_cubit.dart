import 'dart:async';

import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart' show GeniusNodeReturnValue;
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet, minionsToGnus;
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/squid_router/squid_util.dart' show toBaseUnits;
import 'package:genius_wallet/utils/wallet_utils.dart';

/// Which SDK write an operation represents. [fund], [recover] and [revoke]
/// run only while the node runs as the main; [detach], [register] and [move]
/// only while it runs as the account they act on.
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

/// How long a fund or recover's balance baseline stays trustworthy. Until
/// then a timed-out one can still resolve and still locks its child; past it,
/// it never resolves and releases its hold and its lock.
// ponytail: other movement on the child inside this window can still read as
// the write landing, and one landing after it can read as the next fund or
// recover on that child; the upgrade path is a per-write tx hash from the SDK.
final _baselineLifetime = childOperationTimeout * 3;

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
    this.expired = false,
    this.switchedAway = false,
    this.mocked = false,
  });

  final ChildOperationKind kind;
  final String fromAccount;
  final String target;
  final String main;
  final String? newMain;
  final BigInt? amountMinions;

  /// The child's balance read at [submittedAt], just before the write.
  final BigInt? baselineMinions;
  final DateTime submittedAt;
  final bool notConfirmed;

  /// A fund or recover whose baseline is too old: it can no longer resolve,
  /// hold its amount or lock its child.
  final bool expired;

  /// A fund or recover whose node has run as another account since submit:
  /// it can never resolve, but holds and locks until it [expired].
  final bool switchedAway;

  /// Submitted to the dev mock rather than the SDK. It resolves only while
  /// reads come from the same source, never on a mix of mock and real.
  final bool mocked;

  ChildOperation copyWith({
    bool? notConfirmed,
    bool? expired,
    bool? switchedAway,
  }) => ChildOperation(
    kind: kind,
    fromAccount: fromAccount,
    target: target,
    main: main,
    newMain: newMain,
    amountMinions: amountMinions,
    baselineMinions: baselineMinions,
    submittedAt: submittedAt,
    notConfirmed: notConfirmed ?? this.notConfirmed,
    expired: expired ?? this.expired,
    switchedAway: switchedAway ?? this.switchedAway,
    mocked: mocked,
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
    Stream<AppState>? appStates,
    DateTime Function() now = DateTime.now,
    bool devTools = kShowDevTools,
    void Function()? onTransferResolved,
  }) : _api = api,
       _readAppState = readAppState,
       _now = now,
       _devTools = devTools,
       _onTransferResolved = onTransferResolved,
       super(const ChildOperationsState()) {
    // Every switch runs a pass, so a round trip between two polls can't
    // slip past resolve() unseen.
    _accountSwitches = appStates
        ?.map((s) => s.selectedSDKAccount?.toLowerCase())
        .distinct()
        .listen((_) => resolve());
  }

  final GeniusApi _api;
  final AppState Function() _readAppState;
  final DateTime Function() _now;

  /// Runs once per [resolve] pass that resolved a fund or recover, so a
  /// holdings view re-reads the balance the transfer just moved.
  final void Function()? _onTransferResolved;
  StreamSubscription<String?>? _accountSwitches;

  /// [kShowDevTools] outside tests, which can't pass a define to reach the
  /// mock. [kDebugMode] still gates it, so a release build never mocks.
  final bool _devTools;
  Timer? _pollTimer;

  /// The account the node currently runs as, or null when it isn't running.
  String? get runningAccount => _readAppState().selectedSDKAccount;

  /// True only in a dev-tools debug build with a read preset armed - every
  /// read and write below then routes to [DevMockChildWallets] instead of
  /// the SDK, so no real write can ever happen while a preset is armed.
  bool get _devMocked =>
      kDebugMode &&
      _devTools &&
      DevMockChildWallets.instance.preset.value != null;

  /// [target]'s GNUS balance, in minions, from the mock while [_devMocked],
  /// or the SDK otherwise - the one read both [payingBalance] and
  /// [_signalMet] share for fund and recover.
  BigInt _childBalance(String target) => _devMocked
      ? DevMockChildWallets.balanceFor(target)
      : _api.getChildBalance(target);

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

  /// Every tracked operation on [target], in submission order. More than
  /// one when different kinds are pending at once -- each needs its own
  /// badge.
  List<ChildOperation> operationsFor(String target) => [
    for (final op in state.operations)
      if (op.target.toLowerCase() == target.toLowerCase()) op,
  ];

  /// True while anything submitted from [account] is still pending.
  bool hasPendingFrom(String account) => state.operations.any(
    (op) =>
        !op.notConfirmed &&
        op.fromAccount.toLowerCase() == account.toLowerCase(),
  );

  /// The user's own SDK accounts -- the main picker's candidate list.
  List<String> get ownAccounts => _readAppState().sdkAccounts;

  /// Every own SDK account's registrations, keyed by lowercased main -- null
  /// when the node isn't running, no dev preset is armed, or every own
  /// account's read failed. One bad read among several is simply left out.
  // ponytail: one registrations read per own account per open or change;
  // upgrade path is an SDK by-child query.
  Map<String, List<ChildWallet>>? ownRegistrations() {
    if (!_devMocked && runningAccount == null) {
      return null;
    }
    final appState = _readAppState();
    final result = <String, List<ChildWallet>>{};
    var anyOk = false;
    for (final main in appState.sdkAccounts) {
      final registrations = _devMocked
          ? DevMockChildWallets.registrationsFor(
              DevMockChildWallets.instance.preset.value!,
              appState,
              main,
            )
          : _api.getChildRegistrations(main);
      if (!registrations.isOk) {
        continue;
      }
      anyOk = true;
      result[main.toLowerCase()] = [
        for (final entry in registrations.entries)
          ChildWallet(
            address: entry.childAddress,
            name: AppBloc.sdkAccountName(
              entry.childAddress,
              appState.sdkAccountLinks,
              appState.wallets,
            ),
            linkedWallet: AppBloc.linkedWallet(
              entry.childAddress,
              appState.sdkAccountLinks,
              appState.wallets,
            ),
            balanceGnus: minionsToGnus(_childBalance(entry.childAddress)),
          ),
      ];
    }
    return anyOk || appState.sdkAccounts.isEmpty ? result : null;
  }

  /// True for a kind that carries a GNUS amount -- fund and recover only.
  bool _hasAmount(ChildOperationKind kind) =>
      kind == ChildOperationKind.fund || kind == ChildOperationKind.recover;

  /// True while [op] is a fund or recover that has not expired: it holds its
  /// amount and locks its child until then, even timed out or switched away.
  bool _holdsBalance(ChildOperation op) => _hasAmount(op.kind) && !op.expired;

  /// Why a new Fund or Recover on [target] can't start yet, or null when it
  /// can. One at a time per child, from any account: without a tx hash, two
  /// overlapping ones on one balance can't be told apart.
  String? balanceLockReason(String target) {
    final blocking = state.operations
        .where(
          (op) =>
              _holdsBalance(op) &&
              op.target.toLowerCase() == target.toLowerCase(),
        )
        .firstOrNull;
    if (blocking == null) {
      return null;
    }
    if (blocking.notConfirmed) {
      return "An earlier transfer for this child hasn't confirmed yet. Check "
          'again, or wait a few minutes.';
    }
    return blocking.kind == ChildOperationKind.fund
        ? 'Already funding this child'
        : 'Already recovering from this child';
  }

  /// Why no new operation of any kind on [target] can start yet, or null when
  /// it can -- the one check [submit] and every menu share. A transfer and a
  /// registration change on one child never overlap: whichever lands first
  /// strands the other, as a revoke landing before a fund does.
  String? lockReason(String target) {
    final balanceLock = balanceLockReason(target);
    if (balanceLock != null) {
      return balanceLock;
    }
    // A notConfirmed one no longer blocks: it has no expiry, so a write that
    // never lands would otherwise lock its child for good.
    final change = state.operations
        .where(
          (op) =>
              !_hasAmount(op.kind) &&
              !op.notConfirmed &&
              op.target.toLowerCase() == target.toLowerCase(),
        )
        .firstOrNull;
    return switch (change?.kind) {
      ChildOperationKind.revoke => 'Already revoking this child',
      ChildOperationKind.detach => 'Already detaching this account',
      ChildOperationKind.register => 'Already registering this account',
      ChildOperationKind.move => 'Already moving this account',
      _ => null,
    };
  }

  /// Why [account] can't be deleted yet, or null when it can. Its key is the
  /// only way to reach a transfer still landing on it or its registered
  /// children, so an unreadable [registrations] refuses too.
  String? deleteLockReason(
    String account,
    Map<String, List<ChildWallet>>? registrations,
  ) {
    final paysOrReceives =
        balanceLockReason(account) != null ||
        state.operations.any(
          (op) =>
              _holdsBalance(op) &&
              op.fromAccount.toLowerCase() == account.toLowerCase(),
        );
    if (paysOrReceives || hasPendingFrom(account)) {
      return "A transfer for this account hasn't finished yet";
    }
    // A child registering or moving under [account] is not listed in its
    // registrations until it lands, and would land under a deleted key.
    final incoming = state.operations.any(
      (op) =>
          !op.notConfirmed &&
          [
            op.main,
            op.newMain,
          ].any((main) => main?.toLowerCase() == account.toLowerCase()),
    );
    if (incoming) {
      return "A child wallet change for this account hasn't finished yet";
    }
    final children = registrations?[account.toLowerCase()];
    if (children == null) {
      return "Can't check this account's child wallets right now";
    }
    if (children.isNotEmpty) {
      return 'Recover or revoke its child wallets first';
    }
    return null;
  }

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
  /// timed-out op counts too until it expires: there is no tx hash, so the
  /// SDK may still land it, and the balance read has not moved for it yet.
  // ponytail: one that never lands holds its amount until it expires; the
  // upgrade path is an SDK receipt per write.
  BigInt _committed(
    ChildOperationKind kind,
    bool Function(ChildOperation) drawsOn,
  ) => state.operations
      .where((op) => op.kind == kind && drawsOn(op) && _holdsBalance(op))
      .fold(BigInt.zero, (sum, op) => sum + op.amountMinions!);

  /// Submits [kind] against [target], or returns null with no SDK call when
  /// the side, main, lock or amount is wrong. Appends and emits only on
  /// `RET_OK`, so a refused write never shows as pending.
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
    if (lockReason(target) != null) {
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

    // Replaces the notConfirmed op of the same kind this account already
    // holds on [target], so the child keeps one badge for it. Any fund or
    // recover still on [target] has expired (the lock above refused
    // otherwise), so it can never resolve and gives its badge up too.
    bool replaces(ChildOperation existing) {
      if (existing.target.toLowerCase() != target.toLowerCase()) {
        return false;
      }
      if (_hasAmount(kind)) {
        return _hasAmount(existing.kind);
      }
      return existing.kind == kind &&
          existing.notConfirmed &&
          existing.fromAccount.toLowerCase() == requiredRunner.toLowerCase();
    }

    final op = ChildOperation(
      kind: kind,
      fromAccount: requiredRunner,
      target: target,
      main: main,
      newMain: newMain,
      amountMinions: amountMinions,
      // Read BEFORE the write, so resolve() has an honest number to compare
      // the balance against once the write lands. The other kinds resolve
      // off the registrations list instead.
      baselineMinions: _hasAmount(kind) ? _childBalance(target) : null,
      submittedAt: _now(),
      mocked: _devMocked,
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

  /// Resolves each op whose signal is met, else times it out or expires it.
  /// Signal first, so one landing on the timeout tick still reads as done.
  /// Emits only on a change, so a listener never fires on an unrelated emit.
  void resolve() {
    if (state.operations.isEmpty) {
      return;
    }
    final now = _now();
    final resolved = <ChildOperation>[];
    final remaining = <ChildOperation>[];
    var changed = false;
    for (final op in state.operations) {
      if (_signalMet(op, now)) {
        resolved.add(op);
        changed = true;
        continue;
      }
      final timesOut =
          !op.notConfirmed &&
          !now.isBefore(op.submittedAt.add(childOperationTimeout));
      // After a switch its own view may be resyncing, so it never resolves;
      // it still holds and locks until it expires, or its late write could
      // read as the next fund on this child from another account.
      final switches = _holdsBalance(op) && !op.switchedAway && !_onOwnView(op);
      final expires = _holdsBalance(op) && !_baselineTrusted(op, now);
      if (timesOut || switches || expires) {
        remaining.add(
          op.copyWith(
            notConfirmed: true,
            expired: op.expired || expires,
            switchedAway: op.switchedAway || switches,
          ),
        );
        changed = true;
      } else {
        remaining.add(op);
      }
    }
    if (!changed) {
      return;
    }
    emit(ChildOperationsState(operations: remaining, justResolved: resolved));
    if (resolved.any((op) => _hasAmount(op.kind))) {
      _onTransferResolved?.call();
    }
    // Stops once nothing left can resolve on its own: a timed-out fund or
    // recover keeps it running until it expires, so its lock lifts on time.
    if (remaining.every((op) => op.notConfirmed && !_holdsBalance(op))) {
      _pollTimer?.cancel();
      _pollTimer = null;
    }
  }

  bool _signalMet(ChildOperation op, DateTime now) {
    // The flags, not the clock or the running account, are final: a clock
    // stepped back or a switch back would otherwise trust a stale baseline.
    if (op.expired || op.switchedAway) {
      return false;
    }
    // A preset armed or cleared since submit swaps every read's source.
    if (op.mocked != _devMocked) {
      return false;
    }
    switch (op.kind) {
      case ChildOperationKind.fund:
        // ponytail: a baseline read as 0 before the child synced lets its
        // real balance appearing read as this fund landing; the upgrade path
        // is a per-write tx hash from the SDK.
        return _onOwnView(op) &&
            _baselineTrusted(op, now) &&
            _childBalance(op.target) >= op.baselineMinions! + op.amountMinions!;
      case ChildOperationKind.recover:
        // ponytail: the SDK reads an unsynced child as 0 too, so 0 never
        // counts. A recover that empties the child, as MAX does, cannot
        // confirm: it ends "Not confirmed yet" and locks the child until it
        // expires. The upgrade path is a per-write tx hash from the SDK.
        final current = _childBalance(op.target);
        return _onOwnView(op) &&
            _baselineTrusted(op, now) &&
            current > BigInt.zero &&
            current <= op.baselineMinions! - op.amountMinions!;
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

  /// True while the node runs as [op]'s own account. Its baseline came from
  /// that account's synced view of the child; another's can read it
  /// differently, so a fund or recover never resolves off it.
  bool _onOwnView(ChildOperation op) =>
      runningAccount?.toLowerCase() == op.fromAccount.toLowerCase();

  /// False once [op]'s baseline is older than [_baselineLifetime] at [at].
  bool _baselineTrusted(ChildOperation op, DateTime at) =>
      at.isBefore(op.submittedAt.add(_baselineLifetime));

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
    _accountSwitches?.cancel();
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
