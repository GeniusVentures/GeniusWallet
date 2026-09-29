// Unit-level proof of the registry's pure logic: amount parsing, the 2-minute
// timeout edge, Check again, and the per-child lock -- all without a widget
// tree, using a fake API and a mutable clock the cubit reads through `now`.
import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart'
    show ChildWallet, minionsToGnus;
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _otherAddress = '0x5555555555555555555555555555555555eeee';
const _childAddress = '0x2222222222222222222222222222222222bbbb';
const _secondChildAddress = '0x3333333333333333333333333333333333cccc';
const _newMainAddress = '0x7777777777777777777777777777777777ffff';
const _earlierTransferReason =
    "An earlier transfer for this child hasn't confirmed yet. Check again, "
    'or wait a few minutes.';

const _appState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress],
  wallets: [],
  sdkAccountLinks: <String, SDKAccountLink>{},
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// A refused fund is exercised at the widget level in
/// child_operation_actions_test.dart -- this fake always returns OK.
class _FakeApi implements GeniusApi {
  _FakeApi({
    this.registrationsResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  });

  final Map<String, BigInt> balances = {};
  int fundCallCount = 0;
  int recoverCallCount = 0;
  int revokeCallCount = 0;
  int detachCallCount = 0;
  int registerCallCount = 0;
  int moveCallCount = 0;
  String? lastRecoveredAmount;
  String? lastRecoveredChild;
  String? lastRevokedChild;
  ChildRegistrationMetadata? lastDetachMetadata;
  String? lastRegisteredMain;
  ChildRegistrationMetadata? lastRegisteredMetadata;
  String? lastMoveNewMain;
  ChildRegistrationMetadata? lastMoveMetadata;
  GeniusNodeReturnValue registrationsResult;
  List<ChildRegistration> registrationEntries = const [];

  /// Per-main override, keyed by lowercased main address -- only move's tests
  /// need the old and new main to answer a registrations read differently.
  /// Falls back to [registrationEntries] for any main not listed here, so
  /// every single-main test above is unaffected.
  Map<String, List<ChildRegistration>> registrationEntriesByMain = const {};

  /// Same per-main override, for the read's own OK/not-OK result -- move's
  /// "one half fails" test needs the new main's read to fail while the old
  /// main's still succeeds.
  Map<String, GeniusNodeReturnValue> registrationsResultByMain = const {};

  @override
  BigInt getChildBalanceAll(String childAddress) =>
      balances[childAddress] ?? BigInt.zero;

  // Comfortably above every amount these tests submit, unless a test lowers
  // it to prove the paying-balance check.
  String minionsBalance = '10000000';

  @override
  String getMinionsBalance([String? tokenId]) => minionsBalance;

  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) {
    fundCallCount++;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  GeniusNodeReturnValue recoverFromChildGnus(
    String amountGnus,
    String childAddress,
  ) {
    recoverCallCount++;
    lastRecoveredAmount = amountGnus;
    lastRecoveredChild = childAddress;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  GeniusNodeReturnValue revokeChild(String childAddress) {
    revokeCallCount++;
    lastRevokedChild = childAddress;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  /// How many times [getChildRegistrations] has been called -- proves a
  /// dev-mocked read never reaches this fake at all.
  int childRegistrationsCallCount = 0;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) {
    childRegistrationsCallCount++;
    return (
      result:
          registrationsResultByMain[mainAddress.toLowerCase()] ??
          registrationsResult,
      entries:
          registrationEntriesByMain[mainAddress.toLowerCase()] ??
          registrationEntries,
    );
  }

  @override
  GeniusNodeReturnValue detachChild(ChildRegistrationMetadata metadata) {
    detachCallCount++;
    lastDetachMetadata = metadata;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  GeniusNodeReturnValue registerChild(
    String mainAddress,
    ChildRegistrationMetadata metadata,
  ) {
    registerCallCount++;
    lastRegisteredMain = mainAddress;
    lastRegisteredMetadata = metadata;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  GeniusNodeReturnValue replaceMain(
    String newMainAddress,
    ChildRegistrationMetadata metadata,
  ) {
    moveCallCount++;
    lastMoveNewMain = newMainAddress;
    lastMoveMetadata = metadata;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  group('parseGnusAmount', () {
    final balance = BigInt.from(2000000); // 2.000000 GNUS

    final messages = <String, String>{
      '': 'Enter an amount.',
      'abc': 'Enter an amount.',
      '0': 'Enter an amount greater than zero.',
      '0.0000001': 'GNUS supports up to 6 decimal places.',
      '1.1234567': 'GNUS supports up to 6 decimal places.',
    };

    messages.forEach((typed, expected) {
      test('"$typed" -> "$expected"', () {
        final result = parseGnusAmount(
          typed,
          balanceMinions: balance,
          payer: 'Main Wallet',
        );
        expect(result.minions, isNull);
        expect(result.error, expected);
      });
    });

    test('a trailing zero past the 6th decimal passes, truncated', () {
      final result = parseGnusAmount(
        '1.1234560',
        balanceMinions: balance,
        payer: 'Main Wallet',
      );
      expect(result.error, isNull);
      expect(result.minions, BigInt.from(1123456));
    });

    test('the exact balance passes', () {
      final result = parseGnusAmount(
        '2.0',
        balanceMinions: balance,
        payer: 'Main Wallet',
      );
      expect(result.error, isNull);
      expect(result.minions, balance);
    });

    test('one minion over balance names the payer', () {
      final result = parseGnusAmount(
        '2.000001',
        balanceMinions: balance,
        payer: 'Main Wallet',
      );
      expect(result.minions, isNull);
      expect(result.error, "Main Wallet doesn't have that much GNUS.");
    });
  });

  group('the 2-minute timeout', () {
    test('stays pending at 1:59.999, becomes notConfirmed at exactly 2:00', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      now = submittedAt.add(
        const Duration(minutes: 1, seconds: 59, milliseconds: 999),
      );
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isFalse);
      expect(cubit.state.justResolved, isEmpty);

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });

    test('a signal and the timeout landing in the same pass resolves', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      api.balances[_childAddress] = BigInt.from(1000000);
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });
  });

  group('Check again', () {
    test('resolves a notConfirmed op once the balance has since risen', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);

      api.balances[_childAddress] = BigInt.from(1000000);
      cubit.resolve();

      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test('stays Not confirmed yet when the balance has not moved', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      cubit.resolve();

      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });
  });

  group('the per-child lock', () {
    test('a second submit for the same child while pending is refused', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      expect(api.fundCallCount, 1);

      final second = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );

      expect(second, isNull);
      expect(api.fundCallCount, 1);
      expect(cubit.state.operations, hasLength(1));

      cubit.close();
    });

    test('a different child is independent', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      final other = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _secondChildAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      expect(other, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.fundCallCount, 2);
      expect(cubit.state.operations, hasLength(2));

      cubit.close();
    });

    test('a pending recover locks a fund on the same child too', () {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(3000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      expect(
        cubit.balanceLockReason(_childAddress.toUpperCase()),
        'Already recovering from this child',
      );
      final fund = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(fund, isNull);
      expect(api.fundCallCount, 0);

      cubit.close();
    });

    test('a timed-out fund locks a new fund and a recover on that child until '
        'it expires, then a new fund takes its place', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(3000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(
        cubit.balanceLockReason(_childAddress),
        "An earlier transfer for this child hasn't confirmed yet. Check "
        'again, or wait a few minutes.',
      );

      final fund = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      final recover = cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(fund, isNull);
      expect(recover, isNull);
      expect(api.fundCallCount, 1);
      expect(api.recoverCallCount, 0);

      // Another child is not locked by it.
      final other = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _secondChildAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(other, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);

      now = submittedAt.add(const Duration(minutes: 6));
      cubit.resolve();
      expect(cubit.operationsFor(_childAddress).single.expired, isTrue);
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.balanceLockReason(_childAddress), isNull);

      final next = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(next, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      final op = cubit.operationsFor(_childAddress).single;
      expect(op.amountMinions, BigInt.from(500000));
      expect(op.notConfirmed, isFalse);

      cubit.close();
    });

    test('Check again seeing a timed-out fund land releases the lock', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      api.balances[_childAddress] = BigInt.from(1000000);
      cubit.resolve();
      expect(cubit.state.justResolved, hasLength(1));
      expect(cubit.balanceLockReason(_childAddress), isNull);

      final next = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(next, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);

      cubit.close();
    });

    test('an expired recover never resolves, and the next recover reads a '
        'fresh baseline', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(100000000); // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(10000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      // An hour later the child has spent 15 GNUS of its own; the recover
      // of 10 never landed.
      now = submittedAt.add(const Duration(hours: 1));
      api.balances[_childAddress] = BigInt.from(85000000);
      cubit.resolve();
      expect(cubit.state.operations.single.expired, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(5000000),
      );
      expect(
        cubit.state.operations.single.baselineMinions,
        BigInt.from(85000000),
      );

      api.balances[_childAddress] = BigInt.from(80000000);
      cubit.resolve();
      expect(cubit.state.operations, isEmpty);
      expect(
        cubit.state.justResolved.single.amountMinions,
        BigInt.from(5000000),
      );

      cubit.close();
    });

    test('an expired fund stays expired when the clock steps back', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      now = submittedAt.add(const Duration(minutes: 6));
      cubit.resolve();
      expect(cubit.state.operations.single.expired, isTrue);

      // An NTP correction puts the wall clock back inside the window, and
      // the balance now reads as the fund landing.
      now = submittedAt.add(const Duration(minutes: 3));
      api.balances[_childAddress] = BigInt.from(1000000);
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations.single.expired, isTrue);
      expect(cubit.balanceLockReason(_childAddress), isNull);

      cubit.close();
    });

    test('after the child moves, a fund from its new main is refused while the '
        "old main's timed-out fund can still land", () {
      var now = DateTime(2024);
      var running = _mainAddress;
      final api = _FakeApi()..minionsBalance = '100000000'; // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => AppState(
          selectedSDKAccount: running,
          sdkAccounts: const [_mainAddress, _newMainAddress],
          wallets: const [],
          sdkAccountLinks: const <String, SDKAccountLink>{},
        ),
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(5000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      running = _newMainAddress;
      final result = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _newMainAddress,
        amountMinions: BigInt.from(10000000),
      );
      expect(result, isNull);
      expect(api.fundCallCount, 1);

      // Only the old main's own 5 can land, and it resolves only its own op,
      // once the node runs as the old main again.
      running = _mainAddress;
      api.balances[_childAddress] = BigInt.from(5000000);
      cubit.resolve();
      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved.single.fromAccount, _mainAddress);
      expect(
        cubit.state.justResolved.single.amountMinions,
        BigInt.from(5000000),
      );

      cubit.close();
    });

    test('a retry from the new main is refused while its own timed-out fund '
        'can still land, so the old main landing never reads as it', () {
      var now = DateTime(2024);
      var running = _mainAddress;
      final api = _FakeApi()..minionsBalance = '100000000'; // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => AppState(
          selectedSDKAccount: running,
          sdkAccounts: const [_mainAddress, _newMainAddress],
          wallets: const [],
          sdkAccountLinks: const <String, SDKAccountLink>{},
        ),
        now: () => now,
      );
      final start = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(10000000),
      );
      now = start.add(childOperationTimeout);
      cubit.resolve();

      running = _newMainAddress;
      final early = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _newMainAddress,
        amountMinions: BigInt.from(5000000),
      );
      expect(early, isNull);

      // The old main's 10 lands and resolves its own op on its own view.
      running = _mainAddress;
      api.balances[_childAddress] = BigInt.from(10000000);
      cubit.resolve();
      expect(cubit.state.justResolved.single.fromAccount, _mainAddress);

      running = _newMainAddress;

      final fund = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _newMainAddress,
        amountMinions: BigInt.from(5000000),
      );
      expect(fund, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      now = start.add(childOperationTimeout * 2);
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);

      final retry = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _newMainAddress,
        amountMinions: BigInt.from(5000000),
      );
      expect(retry, isNull);
      expect(api.fundCallCount, 2);
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations.single.notConfirmed, isTrue);

      cubit.close();
    });

    test('the node running as another account is refused, no SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _otherAddress,
        amountMinions: BigInt.from(1000000),
      );

      expect(result, isNull);
      expect(api.fundCallCount, 0);

      cubit.close();
    });

    test('a timed-out recover never resolves while the node runs as another '
        'account, and keeps its lock until it expires', () {
      var now = DateTime(2024);
      var running = _mainAddress;
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(100000000); // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => AppState(
          selectedSDKAccount: running,
          sdkAccounts: const [_mainAddress, _otherAddress],
          wallets: const [],
          sdkAccountLinks: const <String, SDKAccountLink>{},
        ),
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(10000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      // The switch lands and the other account's view reads the child
      // part-synced: non-zero and below the recover's target.
      now = submittedAt.add(const Duration(minutes: 3));
      running = _otherAddress;
      api.balances[_childAddress] = BigInt.from(50000000);
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.operations.single.expired, isFalse);
      expect(cubit.balanceLockReason(_childAddress), _earlierTransferReason);

      now = submittedAt.add(const Duration(minutes: 6));
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations.single.expired, isTrue);
      expect(cubit.balanceLockReason(_childAddress), isNull);

      cubit.close();
    });

    test('a fund whose node switches away and back inside one poll never '
        'resolves, and keeps its hold and lock until it expires', () async {
      var now = DateTime(2024);
      var running = _mainAddress;
      AppState appState() => AppState(
        selectedSDKAccount: running,
        sdkAccounts: const [_mainAddress, _otherAddress],
        wallets: const [],
        sdkAccountLinks: const <String, SDKAccountLink>{},
      );
      final appStates = StreamController<AppState>.broadcast();
      final api = _FakeApi(); // the main holds 10 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: appState,
        appStates: appStates.stream,
        now: () => now,
      );
      final submittedAt = now;
      final amount = BigInt.from(10000000);
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: amount,
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      now = submittedAt.add(const Duration(minutes: 3));
      for (final account in [_otherAddress, _mainAddress]) {
        running = account;
        appStates.add(appState());
        await Future<void>.delayed(Duration.zero);
      }
      api.balances[_childAddress] = amount;
      cubit.resolve();

      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations.single.expired, isFalse);
      expect(cubit.balanceLockReason(_childAddress), _earlierTransferReason);
      expect(
        cubit.payingBalance(ChildOperationKind.fund, _secondChildAddress),
        BigInt.zero,
      );

      now = submittedAt.add(const Duration(minutes: 6));
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations.single.expired, isTrue);
      expect(cubit.balanceLockReason(_childAddress), isNull);
      expect(
        cubit.payingBalance(ChildOperationKind.fund, _secondChildAddress),
        amount,
      );

      await cubit.close();
      await appStates.close();
    });

    test(
      "after a switch, the new main can't fund the child until the old "
      "main's timed-out fund expires, so its late landing never toasts",
      () async {
        var now = DateTime(2024);
        var running = _mainAddress;
        AppState appState() => AppState(
          selectedSDKAccount: running,
          sdkAccounts: const [_mainAddress, _newMainAddress],
          wallets: const [],
          sdkAccountLinks: const <String, SDKAccountLink>{},
        );
        final appStates = StreamController<AppState>.broadcast();
        final api = _FakeApi()..minionsBalance = '100000000'; // 100 GNUS
        final cubit = ChildOperationsCubit(
          api: api,
          readAppState: appState,
          appStates: appStates.stream,
          now: () => now,
        );
        final submittedAt = now;
        cubit.submit(
          kind: ChildOperationKind.fund,
          target: _childAddress,
          main: _mainAddress,
          amountMinions: BigInt.from(10000000),
        );
        now = submittedAt.add(childOperationTimeout);
        cubit.resolve();

        now = submittedAt.add(const Duration(minutes: 3));
        running = _newMainAddress;
        appStates.add(appState());
        await Future<void>.delayed(Duration.zero);
        GeniusNodeReturnValue? fundFromNewMain() => cubit.submit(
          kind: ChildOperationKind.fund,
          target: _childAddress,
          main: _newMainAddress,
          amountMinions: BigInt.from(5000000),
        );
        expect(fundFromNewMain(), isNull);
        expect(cubit.balanceLockReason(_childAddress), _earlierTransferReason);

        // The old main's write lands late, seen from the new main's view.
        now = submittedAt.add(const Duration(minutes: 4));
        api.balances[_childAddress] = BigInt.from(10000000);
        cubit.resolve();
        expect(cubit.state.justResolved, isEmpty);

        now = submittedAt
            .add(const Duration(minutes: 6))
            .subtract(const Duration(milliseconds: 1));
        cubit.resolve();
        expect(fundFromNewMain(), isNull);
        expect(api.fundCallCount, 1);

        now = submittedAt.add(const Duration(minutes: 6));
        cubit.resolve();
        expect(cubit.state.justResolved, isEmpty);
        expect(cubit.balanceLockReason(_childAddress), isNull);

        // The new fund's baseline already includes the old landing, so it
        // stays pending instead of reading that landing as its own.
        expect(fundFromNewMain(), GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
        cubit.resolve();
        expect(cubit.state.justResolved, isEmpty);
        expect(cubit.operationsFor(_childAddress).single.notConfirmed, isFalse);

        await cubit.close();
        await appStates.close();
      },
    );

    test('hasPendingFrom is true only while pending, case-insensitively', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      expect(cubit.hasPendingFrom(_mainAddress), isFalse);

      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      expect(cubit.hasPendingFrom(_mainAddress), isTrue);
      expect(cubit.hasPendingFrom(_mainAddress.toUpperCase()), isTrue);

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();
      expect(cubit.hasPendingFrom(_mainAddress), isFalse);

      cubit.close();
    });
  });

  group('the paying balance', () {
    test('two funds to different children cannot jointly exceed the main '
        'balance', () {
      var now = DateTime(2024);
      final api = _FakeApi()..minionsBalance = '100000000'; // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      final first = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(60000000),
      );
      expect(first, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);

      final available = cubit.payingBalance(
        ChildOperationKind.fund,
        _secondChildAddress,
      );
      expect(available, BigInt.from(40000000));
      expect(
        parseGnusAmount(
          '60',
          balanceMinions: available,
          payer: 'Main Wallet',
        ).error,
        "Main Wallet doesn't have that much GNUS.",
      );
      final second = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _secondChildAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(60000000),
      );
      expect(second, isNull);
      expect(api.fundCallCount, 1);

      // Timed out is not the same as not sent: the first fund may still
      // land, so it keeps holding its share of the balance.
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(
        cubit.payingBalance(ChildOperationKind.fund, _secondChildAddress),
        BigInt.from(40000000),
      );

      final rest = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _secondChildAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(40000000),
      );
      expect(rest, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.fundCallCount, 2);

      cubit.close();
    });

    test('an expired fund releases its hold on the paying balance', () {
      var now = DateTime(2024);
      final api = _FakeApi()..minionsBalance = '100000000'; // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(60000000),
      );

      now = submittedAt.add(const Duration(minutes: 6));
      cubit.resolve();
      expect(
        cubit.payingBalance(ChildOperationKind.fund, _secondChildAddress),
        BigInt.from(100000000),
      );

      cubit.close();
    });

    test('a timed-out recover still holds its share of the child balance', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(100000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(60000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      final again = cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(60000000),
      );

      expect(again, isNull);
      expect(api.recoverCallCount, 1);
      expect(
        cubit.payingBalance(ChildOperationKind.recover, _childAddress),
        BigInt.from(40000000),
      );

      cubit.close();
    });
  });

  group('recover', () {
    test('payingBalance reads the child, not the running account', () {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(3000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      expect(
        cubit.payingBalance(ChildOperationKind.recover, _childAddress),
        BigInt.from(3000000),
      );

      cubit.close();
    });

    test('above the child balance is refused, no SDK call', () {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(1000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000001),
      );

      expect(result, isNull);
      expect(api.recoverCallCount, 0);

      cubit.close();
    });

    test('the full child balance passes and reaches the SDK', () {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(1000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.recoverCallCount, 1);
      expect(api.lastRecoveredAmount, '1.000000');
      expect(api.lastRecoveredChild, _childAddress);

      cubit.close();
    });

    test('resolves once the child balance falls to exactly baseline minus '
        'amount, not above it', () {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(2000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      api.balances[_childAddress] = BigInt.from(1000001);
      cubit.resolve();
      expect(cubit.state.operations, hasLength(1));
      expect(cubit.state.justResolved, isEmpty);

      api.balances[_childAddress] = BigInt.from(1000000);
      cubit.resolve();
      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test('the node running as another account is refused, no SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _otherAddress,
        amountMinions: BigInt.from(1000000),
      );

      expect(result, isNull);
      expect(api.recoverCallCount, 0);

      cubit.close();
    });
    test('a zero balance read never resolves a recover: the SDK reads an '
        'unsynced child as zero too', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(100000000); // 100 GNUS
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(10000000),
      );
      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      api.balances[_childAddress] = BigInt.zero;
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });

    test('a recover of the whole balance ends Not confirmed yet', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(1000000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );

      api.balances[_childAddress] = BigInt.zero;
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();
      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });
  });

  group('revoke', () {
    test(
      'submit calls the revoke wrapper with the child, no amount needed',
      () {
        final api = _FakeApi()
          ..registrationEntries = const [
            ChildRegistration(
              childAddress: _childAddress,
              mainAddress: _mainAddress,
              sequence: 0,
            ),
          ];
        final cubit = ChildOperationsCubit(
          api: api,
          readAppState: () => _appState,
        );

        final result = cubit.submit(
          kind: ChildOperationKind.revoke,
          target: _childAddress,
          main: _mainAddress,
        );

        expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
        expect(api.revokeCallCount, 1);
        expect(api.lastRevokedChild, _childAddress);

        cubit.close();
      },
    );

    test('an OK read of the main without the child resolves', () {
      final api = _FakeApi()
        ..registrationEntries = const [
          ChildRegistration(
            childAddress: _childAddress,
            mainAddress: _mainAddress,
            sequence: 0,
          ),
        ];
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.revoke,
        target: _childAddress,
        main: _mainAddress,
      );

      api.registrationEntries = const [];
      cubit.resolve();

      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test(
      'the same list with the child in a different case does not resolve',
      () {
        final api = _FakeApi()
          ..registrationEntries = const [
            ChildRegistration(
              childAddress: _childAddress,
              mainAddress: _mainAddress,
              sequence: 0,
            ),
          ];
        final cubit = ChildOperationsCubit(
          api: api,
          readAppState: () => _appState,
        );
        cubit.submit(
          kind: ChildOperationKind.revoke,
          target: _childAddress,
          main: _mainAddress,
        );

        api.registrationEntries = [
          ChildRegistration(
            childAddress: _childAddress.toUpperCase(),
            mainAddress: _mainAddress,
            sequence: 0,
          ),
        ];
        cubit.resolve();

        expect(cubit.state.operations, hasLength(1));
        expect(cubit.state.justResolved, isEmpty);

        cubit.close();
      },
    );

    test('a non-OK read never resolves and times out to notConfirmed', () {
      var now = DateTime(2024);
      final api =
          _FakeApi(
              registrationsResult:
                  GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
            )
            ..registrationEntries = const [
              ChildRegistration(
                childAddress: _childAddress,
                mainAddress: _mainAddress,
                sequence: 0,
              ),
            ];
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.revoke,
        target: _childAddress,
        main: _mainAddress,
      );

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });

    test('the node running as another account is refused, no SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.revoke,
        target: _childAddress,
        main: _otherAddress,
      );

      expect(result, isNull);
      expect(api.revokeCallCount, 0);

      cubit.close();
    });
  });

  group('detach', () {
    test('submit calls the detach wrapper with empty metadata, running as the '
        'account itself, not the old main', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.detach,
        target: _mainAddress,
        main: _otherAddress,
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.detachCallCount, 1);
      expect(api.lastDetachMetadata, const ChildRegistrationMetadata());

      cubit.close();
    });

    test('running as the old main, not the account itself, is refused, no '
        'SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );

      final result = cubit.submit(
        kind: ChildOperationKind.detach,
        target: _mainAddress,
        main: _otherAddress,
      );

      expect(result, isNull);
      expect(api.detachCallCount, 0);

      cubit.close();
    });

    test('an OK read of the old main without the account resolves', () {
      final api = _FakeApi()
        ..registrationEntries = const [
          ChildRegistration(
            childAddress: _mainAddress,
            mainAddress: _otherAddress,
            sequence: 0,
          ),
        ];
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.detach,
        target: _mainAddress,
        main: _otherAddress,
      );

      api.registrationEntries = const [];
      cubit.resolve();

      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test('a non-OK read never resolves and times out to notConfirmed', () {
      var now = DateTime(2024);
      final api =
          _FakeApi(
              registrationsResult:
                  GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
            )
            ..registrationEntries = const [
              ChildRegistration(
                childAddress: _mainAddress,
                mainAddress: _otherAddress,
                sequence: 0,
              ),
            ];
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.detach,
        target: _mainAddress,
        main: _otherAddress,
      );

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });
  });

  group('register', () {
    test('submit calls the register wrapper with the chosen main and empty '
        'metadata, running as the account itself', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.registerCallCount, 1);
      expect(api.lastRegisteredMain, _otherAddress);
      expect(api.lastRegisteredMetadata, const ChildRegistrationMetadata());

      cubit.close();
    });

    test('running as the chosen main, not the account itself, is refused, '
        'no SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );

      final result = cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      expect(result, isNull);
      expect(api.registerCallCount, 0);

      cubit.close();
    });

    test('an OK read of the chosen main listing the account resolves', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      api.registrationEntries = const [
        ChildRegistration(
          childAddress: _mainAddress,
          mainAddress: _otherAddress,
          sequence: 0,
        ),
      ];
      cubit.resolve();

      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test('never listed times out to notConfirmed, not resolved', () {
      var now = DateTime(2024);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });

    test('a non-OK read never resolves either', () {
      final api =
          _FakeApi(
              registrationsResult:
                  GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
            )
            ..registrationEntries = const [
              ChildRegistration(
                childAddress: _mainAddress,
                mainAddress: _otherAddress,
                sequence: 0,
              ),
            ];
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      cubit.resolve();

      expect(cubit.state.operations, hasLength(1));
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });

    test('registering the account as its own child is refused, no SDK '
        'call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _mainAddress.toUpperCase(),
      );

      expect(result, isNull);
      expect(api.registerCallCount, 0);
      expect(cubit.state.operations, isEmpty);

      cubit.close();
    });

    test('submitting again while pending is refused', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      final second = cubit.submit(
        kind: ChildOperationKind.register,
        target: _mainAddress,
        main: _otherAddress,
      );

      expect(second, isNull);
      expect(api.registerCallCount, 1);

      cubit.close();
    });
  });

  group('move', () {
    test('submit calls the replace-main wrapper with the new main and empty '
        'metadata, running as the account itself', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.moveCallCount, 1);
      expect(api.lastMoveNewMain, _newMainAddress);
      expect(api.lastMoveMetadata, const ChildRegistrationMetadata());

      cubit.close();
    });

    test('running as the old main, not the account itself, is refused, no '
        'SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(selectedSDKAccount: _otherAddress),
      );

      final result = cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      expect(result, isNull);
      expect(api.moveCallCount, 0);

      cubit.close();
    });

    test('moving to the account itself or to its current main is refused, '
        'no SDK call', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );

      final toSelf = cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _mainAddress.toUpperCase(),
      );
      final toSameMain = cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _otherAddress.toUpperCase(),
      );

      expect(toSelf, isNull);
      expect(toSameMain, isNull);
      expect(api.moveCallCount, 0);
      expect(cubit.state.operations, isEmpty);

      cubit.close();
    });

    test('a second move for the same account while pending is refused', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      final second = cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      expect(second, isNull);
      expect(api.moveCallCount, 1);

      cubit.close();
    });

    test('an OK read of the old main without the account AND an OK read of '
        'the new main listing it resolves', () {
      final api = _FakeApi()
        ..registrationEntriesByMain = {
          _otherAddress.toLowerCase(): const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _otherAddress,
              sequence: 0,
            ),
          ],
          _newMainAddress.toLowerCase(): const [],
        };
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      // Only the new main has picked it up so far -- still pending.
      api.registrationEntriesByMain = {
        _otherAddress.toLowerCase(): const [
          ChildRegistration(
            childAddress: _mainAddress,
            mainAddress: _otherAddress,
            sequence: 0,
          ),
        ],
        _newMainAddress.toLowerCase(): const [
          ChildRegistration(
            childAddress: _mainAddress,
            mainAddress: _newMainAddress,
            sequence: 0,
          ),
        ],
      };
      cubit.resolve();
      expect(cubit.state.operations, hasLength(1));
      expect(cubit.state.justResolved, isEmpty);

      // Now both halves agree.
      api.registrationEntriesByMain = {
        _otherAddress.toLowerCase(): const [],
        _newMainAddress.toLowerCase(): const [
          ChildRegistration(
            childAddress: _mainAddress,
            mainAddress: _newMainAddress,
            sequence: 0,
          ),
        ],
      };
      cubit.resolve();
      expect(cubit.state.operations, isEmpty);
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test(
      'the same lists with the account in a different case still resolve',
      () {
        final api = _FakeApi()
          ..registrationEntriesByMain = {
            _otherAddress.toLowerCase(): const [],
            _newMainAddress.toLowerCase(): [
              ChildRegistration(
                childAddress: _mainAddress.toUpperCase(),
                mainAddress: _newMainAddress,
                sequence: 0,
              ),
            ],
          };
        final cubit = ChildOperationsCubit(
          api: api,
          readAppState: () => _appState,
        );
        cubit.submit(
          kind: ChildOperationKind.move,
          target: _mainAddress,
          main: _otherAddress,
          newMain: _newMainAddress,
        );

        cubit.resolve();

        expect(cubit.state.operations, isEmpty);
        expect(cubit.state.justResolved, hasLength(1));

        cubit.close();
      },
    );

    test('a non-OK read of the new main alone leaves it pending, then times '
        'out to notConfirmed', () {
      var now = DateTime(2024);
      final api = _FakeApi()
        ..registrationEntriesByMain = {_otherAddress.toLowerCase(): const []}
        ..registrationsResultByMain = {
          _newMainAddress.toLowerCase():
              GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
        };
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        now: () => now,
      );
      final submittedAt = now;
      cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      cubit.resolve();
      expect(cubit.state.operations, hasLength(1));
      expect(cubit.state.justResolved, isEmpty);

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });

    test('only the old main clearing, with the new main not yet listing it, '
        'stays pending', () {
      final api = _FakeApi()
        ..registrationEntriesByMain = {
          _otherAddress.toLowerCase(): const [],
          _newMainAddress.toLowerCase(): const [],
        };
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
      );
      cubit.submit(
        kind: ChildOperationKind.move,
        target: _mainAddress,
        main: _otherAddress,
        newMain: _newMainAddress,
      );

      cubit.resolve();

      expect(cubit.state.operations, hasLength(1));
      expect(cubit.state.justResolved, isEmpty);

      cubit.close();
    });
  });

  group('a dev preset armed or cleared mid-flight', () {
    tearDown(() {
      DevMockChildWallets.instance.clear();
      DevMockChildWallets.instance.setWriteMode(
        DevChildWalletsWriteMode.confirm,
      );
    });

    test('a real fund never resolves on the mock balance an armed preset '
        'reads', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        devTools: true,
      );
      cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      expect(api.fundCallCount, 1);

      // The mock reads any unknown child as 250 GNUS.
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations, hasLength(1));

      DevMockChildWallets.instance.clear();
      api.balances[_childAddress] = BigInt.from(1000000);
      cubit.resolve();
      expect(cubit.state.justResolved, hasLength(1));

      cubit.close();
    });

    test('a mock fund never resolves on the real balance once the preset is '
        'cleared', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _appState,
        devTools: true,
      );
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      DevMockChildWallets.instance.setWriteMode(
        DevChildWalletsWriteMode.timeout,
      );
      final result = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(api.fundCallCount, 0);

      DevMockChildWallets.instance.clear();
      api.balances[_childAddress] = BigInt.from(300000000); // 300 GNUS
      cubit.resolve();
      expect(cubit.state.justResolved, isEmpty);
      expect(cubit.state.operations, hasLength(1));

      cubit.close();
    });
  });

  group('ownRegistrations', () {
    tearDown(() => DevMockChildWallets.instance.clear());

    test('null when nothing runs and no preset is armed', () {
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () =>
            const AppState(sdkAccounts: [_mainAddress, _otherAddress]),
      );
      expect(cubit.ownRegistrations(), isNull);
    });

    test("null once any one own account's read comes back non-OK", () {
      final api = _FakeApi()
        ..registrationsResultByMain = {
          _otherAddress.toLowerCase():
              GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
        };
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(
          selectedSDKAccount: _mainAddress,
          sdkAccounts: [_mainAddress, _otherAddress],
        ),
      );
      expect(cubit.ownRegistrations(), isNull);
    });

    test('keys the result by lowercased main', () {
      final api = _FakeApi()
        ..registrationEntriesByMain = {
          _mainAddress.toLowerCase(): const [
            ChildRegistration(
              childAddress: _childAddress,
              mainAddress: _mainAddress,
              sequence: 0,
            ),
          ],
        };
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => const AppState(
          selectedSDKAccount: _mainAddress,
          sdkAccounts: [_mainAddress],
        ),
      );
      final result = cubit.ownRegistrations();
      expect(result, isNotNull);
      expect(result!.keys, [_mainAddress.toLowerCase()]);
      expect(result[_mainAddress.toLowerCase()], hasLength(1));
    });

    test('names, linked wallets and balances match what ChildWalletsCubit '
        'builds for the same entries', () {
      const wallet = Wallet(
        coinType: TWCoinType.TWCoinTypeEthereum,
        walletName: 'Linked wallet',
        currencySymbol: 'ETH',
        walletType: WalletType.privateKey,
        balance: 0,
        address: _childAddress,
      );
      const links = {
        _childAddress: (
          walletAddress: _childAddress,
          walletName: 'Linked wallet',
        ),
      };
      const appState = AppState(
        selectedSDKAccount: _mainAddress,
        sdkAccounts: [_mainAddress],
        wallets: [wallet],
        sdkAccountLinks: links,
      );
      final api = _FakeApi()
        ..registrationEntriesByMain = {
          _mainAddress.toLowerCase(): const [
            ChildRegistration(
              childAddress: _childAddress,
              mainAddress: _mainAddress,
              sequence: 0,
            ),
          ],
        }
        ..balances[_childAddress] = BigInt.from(2500000);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => appState,
      );

      final built = cubit
          .ownRegistrations()![_mainAddress.toLowerCase()]!
          .single;
      final expected = ChildWallet(
        address: _childAddress,
        name: AppBloc.sdkAccountName(
          _childAddress,
          appState.sdkAccountLinks,
          appState.wallets,
        ),
        linkedWallet: AppBloc.linkedWallet(
          _childAddress,
          appState.sdkAccountLinks,
          appState.wallets,
        ),
        balanceGnus: minionsToGnus(BigInt.from(2500000)),
      );
      expect(built.address, expected.address);
      expect(built.name, expected.name);
      expect(built.linkedWallet, expected.linkedWallet);
      expect(built.balanceGnus, expected.balanceGnus);
    });

    test('with a preset armed and no running account it answers from the mock, '
        "and the fake's own registrations read count stays 0", () {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      final api = _FakeApi();
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () =>
            const AppState(sdkAccounts: [_mainAddress, _otherAddress]),
        devTools: true,
      );

      final result = cubit.ownRegistrations();

      expect(result, isNotNull);
      expect(api.childRegistrationsCallCount, 0);
    });
  });
}
