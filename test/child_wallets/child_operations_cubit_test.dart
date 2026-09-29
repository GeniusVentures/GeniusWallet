// Unit-level proof of the registry's pure logic: amount parsing, the 2-minute
// timeout edge, Check again, and the per-child lock -- all without a widget
// tree, using a fake API and a mutable clock the cubit reads through `now`.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _otherAddress = '0x5555555555555555555555555555555555eeee';
const _childAddress = '0x2222222222222222222222222222222222bbbb';
const _secondChildAddress = '0x3333333333333333333333333333333333cccc';

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
  String? lastRecoveredAmount;
  String? lastRecoveredChild;
  String? lastRevokedChild;
  ChildRegistrationMetadata? lastDetachMetadata;
  String? lastRegisteredMain;
  ChildRegistrationMetadata? lastRegisteredMetadata;
  GeniusNodeReturnValue registrationsResult;
  List<ChildRegistration> registrationEntries = const [];

  @override
  BigInt getChildBalanceAll(String childAddress) =>
      balances[childAddress] ?? BigInt.zero;

  // Comfortably above every amount these tests submit.
  @override
  String getMinionsBalance([String? tokenId]) => '10000000';

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

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) =>
      (result: registrationsResult, entries: registrationEntries);

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

    test('after notConfirmed, a new submit leaves exactly one op for that '
        'child', () {
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

      final replaced = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );

      expect(replaced, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(cubit.state.operations, hasLength(1));
      expect(cubit.state.operations.single.notConfirmed, isFalse);
      expect(cubit.state.operations.single.amountMinions, BigInt.from(500000));

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
}
