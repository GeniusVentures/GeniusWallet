// Unit-level proof of the registry's pure logic: amount parsing, the 2-minute
// timeout edge, Check again, and the per-child lock -- all without a widget
// tree, using a fake API and a mutable clock the cubit reads through `now`.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
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
class _FakeApi implements GeniusApi {
  _FakeApi({this.fundResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK});

  final GeniusNodeReturnValue fundResult;
  final Map<String, BigInt> balances = {};
  int fundCallCount = 0;

  @override
  BigInt getChildBalanceAll(String childAddress) =>
      balances[childAddress] ?? BigInt.zero;

  // Comfortably above every amount these tests submit.
  @override
  String getMinionsBalance([String? tokenId]) => '10000000';

  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) {
    fundCallCount++;
    return fundResult;
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
}
