import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operation_status.dart'
    show resolvedText;
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/squid_router/squid_util.dart' show toBaseUnits;
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

// Pure-Dart coverage of the DevMockChildWallets fixture class only - it
// cannot go through ChildWalletsCubit here: `kShowDevTools` is a
// `bool.fromEnvironment` const that is `false` under `flutter test` (no
// `--dart-define` is passed by the test runner), so the cubit's gated
// branch is unreachable in this environment. That is also why the preset's
// effect on the real cubit and screen is proven in
// test/child_wallets/child_wallets_screen_test.dart instead, through a
// delegating fake `GeniusApi`. The write seam below is proven the same way,
// through a fake whose writes and reads delegate to this mock.
const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _siblingAddress = '0x2222222222222222222222222222222222bbbb';
const _otherMainAddress = '0x4444444444444444444444444444444444dddd';
const _childAddress = '0x6666666666666666666666666666666666aaaa';

const _sdkAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress, _siblingAddress],
  wallets: [
    Wallet(
      coinType: TWCoinType.TWCoinTypeEthereum,
      walletName: 'Sibling Wallet',
      currencySymbol: 'ETH',
      walletType: WalletType.privateKey,
      balance: 0,
      address: _siblingAddress,
    ),
  ],
  sdkAccountLinks: <String, SDKAccountLink>{
    _siblingAddress: (
      walletAddress: _siblingAddress,
      walletName: 'Sibling Wallet',
    ),
  },
);

const _noSiblingAppState = AppState(sdkAccounts: [_mainAddress]);

/// Builds a [ChildOperation] with the fields each write-simulation test
/// varies; [submittedAt] defaults far enough in the past that it never
/// interferes with a real timeout check.
ChildOperation _op(
  ChildOperationKind kind, {
  String target = _childAddress,
  String main = _mainAddress,
  String? newMain,
  BigInt? amountMinions,
  DateTime? submittedAt,
}) => ChildOperation(
  kind: kind,
  fromAccount: main,
  target: target,
  main: main,
  newMain: newMain,
  amountMinions: amountMinions,
  submittedAt: submittedAt ?? DateTime(2026, 1, 1),
);

/// Delegates every write and the reads it needs back to
/// [DevMockChildWallets] -- stands in for [ChildOperationsCubit]'s own
/// gated seam, which is compiled out under `flutter test`.
class _MockWriteApi implements GeniusApi {
  _MockWriteApi({required this.mainAddress, required this.now});

  final String mainAddress;
  final DateTime Function() now;

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) =>
      DevMockChildWallets.balanceFor(childAddress);

  @override
  String getMinionsBalance([String? tokenId]) =>
      DevMockChildWallets.mainBalanceMinions.toString();

  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) =>
      DevMockChildWallets.instance.submitWrite(
        ChildOperation(
          kind: ChildOperationKind.fund,
          fromAccount: mainAddress,
          target: childAddress,
          main: mainAddress,
          amountMinions: toBaseUnits(amountGnus, 6),
          submittedAt: now(),
        ),
      );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  setUp(() {
    DevMockChildWallets.instance.clear();
    DevMockChildWallets.instance.setWriteMode(DevChildWalletsWriteMode.confirm);
  });
  tearDown(() {
    DevMockChildWallets.instance.clear();
    DevMockChildWallets.instance.setWriteMode(DevChildWalletsWriteMode.confirm);
  });

  group('preset lifecycle', () {
    test('preset is null until armed', () {
      expect(DevMockChildWallets.instance.preset.value, isNull);
    });

    test('clear() nulls the preset again', () {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      DevMockChildWallets.instance.clear();
      expect(DevMockChildWallets.instance.preset.value, isNull);
    });

    test('arming the same preset twice is idempotent', () {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.queryError);
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.queryError);
      expect(
        DevMockChildWallets.instance.preset.value,
        DevChildWalletsPreset.queryError,
      );
    });
  });

  group('notifier semantics', () {
    test('arming from null notifies exactly once', () {
      var callCount = 0;
      void listener() => callCount++;
      DevMockChildWallets.instance.preset.addListener(listener);
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      DevMockChildWallets.instance.preset.removeListener(listener);
      expect(callCount, 1);
    });

    test('arming the SAME preset a second time does NOT notify', () {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      var callCount = 0;
      void listener() => callCount++;
      DevMockChildWallets.instance.preset.addListener(listener);
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      DevMockChildWallets.instance.preset.removeListener(listener);
      expect(callCount, 0);
    });

    test('switching from one preset to a different one notifies', () {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      var callCount = 0;
      void listener() => callCount++;
      DevMockChildWallets.instance.preset.addListener(listener);
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.threeChildren);
      DevMockChildWallets.instance.preset.removeListener(listener);
      expect(callCount, 1);
    });

    test('clear() from an armed preset notifies', () {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
      var callCount = 0;
      void listener() => callCount++;
      DevMockChildWallets.instance.preset.addListener(listener);
      DevMockChildWallets.instance.clear();
      DevMockChildWallets.instance.preset.removeListener(listener);
      expect(callCount, 1);
    });

    test('clear() when already clear does not notify', () {
      var callCount = 0;
      void listener() => callCount++;
      DevMockChildWallets.instance.preset.addListener(listener);
      DevMockChildWallets.instance.clear();
      DevMockChildWallets.instance.preset.removeListener(listener);
      expect(callCount, 0);
    });
  });

  group('registrationsFor', () {
    test('none -> RET_OK with no entries', () {
      final result = DevMockChildWallets.registrationsFor(
        DevChildWalletsPreset.none,
        _sdkAppState,
        _mainAddress,
      );
      expect(result.result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(result.entries, isEmpty);
    });

    test('oneChild -> RET_OK with the single synthetic address', () {
      final result = DevMockChildWallets.registrationsFor(
        DevChildWalletsPreset.oneChild,
        _sdkAppState,
        _mainAddress,
      );
      expect(result.result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(result.entries, hasLength(1));
      expect(
        result.entries.single.childAddress,
        DevMockChildWallets.singleChildAddress,
      );
    });

    test('threeChildren leads with a linked sibling when one exists, in '
        'fixture order', () {
      final result = DevMockChildWallets.registrationsFor(
        DevChildWalletsPreset.threeChildren,
        _sdkAppState,
        _mainAddress,
      );
      expect(result.result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(result.entries, hasLength(3));
      expect(result.entries[0].childAddress, _siblingAddress);
      expect(result.entries[1].childAddress, DevMockChildWallets.pairAddressA);
      expect(result.entries[2].childAddress, DevMockChildWallets.pairAddressB);
    });

    test('threeChildren falls back to a synthetic linked slot with no other '
        'linked account', () {
      final result = DevMockChildWallets.registrationsFor(
        DevChildWalletsPreset.threeChildren,
        _noSiblingAppState,
        _mainAddress,
      );
      expect(
        result.entries[0].childAddress,
        DevMockChildWallets.fallbackLinkedAddress,
      );
    });

    test('queryError -> GENIUS_NODE_ERROR_REGISTRATION with no entries', () {
      final result = DevMockChildWallets.registrationsFor(
        DevChildWalletsPreset.queryError,
        _sdkAppState,
        _mainAddress,
      );
      expect(
        result.result,
        GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
      );
      expect(result.entries, isEmpty);
    });

    test(
      'nodeNotRunning -> GENIUS_NODE_ERROR_NOT_INITIALIZED with no entries',
      () {
        final result = DevMockChildWallets.registrationsFor(
          DevChildWalletsPreset.nodeNotRunning,
          _sdkAppState,
          _mainAddress,
        );
        expect(
          result.result,
          GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
        );
        expect(result.entries, isEmpty);
      },
    );
  });

  group('balanceFor', () {
    test('the single child balances at 1.5 GNUS', () {
      expect(
        DevMockChildWallets.balanceFor(DevMockChildWallets.singleChildAddress),
        BigInt.from(1500000),
      );
    });

    test('the synthetic pair balances at 12.345678 GNUS and zero', () {
      expect(
        DevMockChildWallets.balanceFor(DevMockChildWallets.pairAddressA),
        BigInt.from(12345678),
      );
      expect(
        DevMockChildWallets.balanceFor(DevMockChildWallets.pairAddressB),
        BigInt.zero,
      );
    });

    test('any other address balances at 250 GNUS', () {
      expect(
        DevMockChildWallets.balanceFor(_siblingAddress),
        BigInt.from(250000000),
      );
      expect(
        DevMockChildWallets.balanceFor(
          DevMockChildWallets.fallbackLinkedAddress,
        ),
        BigInt.from(250000000),
      );
    });
  });

  group('synthetic addresses', () {
    test('every synthetic address starts with 0xDEV', () {
      for (final address in [
        DevMockChildWallets.singleChildAddress,
        DevMockChildWallets.pairAddressA,
        DevMockChildWallets.pairAddressB,
        DevMockChildWallets.fallbackLinkedAddress,
      ]) {
        expect(address.startsWith('0xDEV'), isTrue, reason: address);
      }
    });

    test('every synthetic address is distinguishable by its last 4 chars', () {
      final addresses = [
        DevMockChildWallets.singleChildAddress,
        DevMockChildWallets.pairAddressA,
        DevMockChildWallets.pairAddressB,
        DevMockChildWallets.fallbackLinkedAddress,
      ];
      final tails = addresses.map((a) => a.substring(a.length - 4)).toSet();
      expect(tails, hasLength(addresses.length));
    });
  });

  group('write mode', () {
    test('starts confirm', () {
      expect(
        DevMockChildWallets.instance.writeMode.value,
        DevChildWalletsWriteMode.confirm,
      );
    });

    test('setWriteMode assigns', () {
      DevMockChildWallets.instance.setWriteMode(DevChildWalletsWriteMode.fail);
      expect(
        DevMockChildWallets.instance.writeMode.value,
        DevChildWalletsWriteMode.fail,
      );
    });

    test('clear() does not reset the write mode', () {
      DevMockChildWallets.instance.setWriteMode(DevChildWalletsWriteMode.fail);
      DevMockChildWallets.instance.clear();
      expect(
        DevMockChildWallets.instance.writeMode.value,
        DevChildWalletsWriteMode.fail,
      );
    });
  });

  group('submitWrite', () {
    test('fail returns the registration error and changes nothing', () {
      DevMockChildWallets.instance.setWriteMode(DevChildWalletsWriteMode.fail);
      final before = DevMockChildWallets.balanceFor(_childAddress);

      final result = DevMockChildWallets.instance.submitWrite(
        _op(ChildOperationKind.fund, amountMinions: BigInt.from(1)),
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION);
      expect(DevMockChildWallets.balanceFor(_childAddress), before);
    });

    testWidgets('timeout returns OK but never applies', (tester) async {
      DevMockChildWallets.instance.setWriteMode(
        DevChildWalletsWriteMode.timeout,
      );
      final before = DevMockChildWallets.balanceFor(_childAddress);

      final result = DevMockChildWallets.instance.submitWrite(
        _op(ChildOperationKind.fund, amountMinions: BigInt.from(1)),
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      await tester.pump(const Duration(seconds: 10));
      expect(DevMockChildWallets.balanceFor(_childAddress), before);
    });

    group('confirm applies each kind 3 s later, not before', () {
      testWidgets('register adds the target under main', (tester) async {
        DevMockChildWallets.instance.submitWrite(
          _op(ChildOperationKind.register),
        );

        await tester.pump(const Duration(milliseconds: 2900));
        expect(
          DevMockChildWallets.registrationsFor(
            DevChildWalletsPreset.none,
            _sdkAppState,
            _mainAddress,
          ).entries,
          isEmpty,
        );

        await tester.pump(const Duration(milliseconds: 100));
        final entries = DevMockChildWallets.registrationsFor(
          DevChildWalletsPreset.none,
          _sdkAppState,
          _mainAddress,
        ).entries;
        expect(entries, hasLength(1));
        expect(entries.single.childAddress, _childAddress);
      });

      testWidgets('revoke removes the target from main', (tester) async {
        DevMockChildWallets.instance.submitWrite(
          _op(
            ChildOperationKind.revoke,
            target: DevMockChildWallets.singleChildAddress,
          ),
        );

        await tester.pump(const Duration(seconds: 3));
        expect(
          DevMockChildWallets.registrationsFor(
            DevChildWalletsPreset.oneChild,
            _sdkAppState,
            _mainAddress,
          ).entries,
          isEmpty,
        );
      });

      testWidgets('detach removes the target from main', (tester) async {
        DevMockChildWallets.instance.submitWrite(
          _op(
            ChildOperationKind.detach,
            target: DevMockChildWallets.singleChildAddress,
          ),
        );

        await tester.pump(const Duration(seconds: 3));
        expect(
          DevMockChildWallets.registrationsFor(
            DevChildWalletsPreset.oneChild,
            _sdkAppState,
            _mainAddress,
          ).entries,
          isEmpty,
        );
      });

      testWidgets('move drops the target from the old main and adds it '
          'under the new one', (tester) async {
        DevMockChildWallets.instance.submitWrite(
          _op(
            ChildOperationKind.move,
            target: DevMockChildWallets.singleChildAddress,
            newMain: _otherMainAddress,
          ),
        );

        await tester.pump(const Duration(seconds: 3));
        expect(
          DevMockChildWallets.registrationsFor(
            DevChildWalletsPreset.oneChild,
            _sdkAppState,
            _mainAddress,
          ).entries,
          isEmpty,
        );
        final newMainEntries = DevMockChildWallets.registrationsFor(
          DevChildWalletsPreset.oneChild,
          _sdkAppState,
          _otherMainAddress,
        ).entries;
        expect(newMainEntries, hasLength(1));
        expect(
          newMainEntries.single.childAddress,
          DevMockChildWallets.singleChildAddress,
        );
      });

      testWidgets('fund then recover shift the balance by the amount', (
        tester,
      ) async {
        final amount = BigInt.from(500000);
        final before = DevMockChildWallets.balanceFor(_childAddress);

        DevMockChildWallets.instance.submitWrite(
          _op(ChildOperationKind.fund, amountMinions: amount),
        );
        await tester.pump(const Duration(milliseconds: 2900));
        expect(DevMockChildWallets.balanceFor(_childAddress), before);
        await tester.pump(const Duration(milliseconds: 100));
        expect(DevMockChildWallets.balanceFor(_childAddress), before + amount);

        DevMockChildWallets.instance.submitWrite(
          _op(ChildOperationKind.recover, amountMinions: amount),
        );
        await tester.pump(const Duration(seconds: 3));
        expect(DevMockChildWallets.balanceFor(_childAddress), before);
      });
    });

    testWidgets('clear() cancels a scheduled confirm and forgets it', (
      tester,
    ) async {
      DevMockChildWallets.instance.submitWrite(
        _op(ChildOperationKind.register),
      );
      DevMockChildWallets.instance.clear();

      await tester.pump(const Duration(seconds: 5));
      expect(
        DevMockChildWallets.registrationsFor(
          DevChildWalletsPreset.none,
          _sdkAppState,
          _mainAddress,
        ).entries,
        isEmpty,
      );
    });
  });

  group('registrationsFor with a preset armed', () {
    test('other mains start empty even though a preset is armed', () {
      final result = DevMockChildWallets.registrationsFor(
        DevChildWalletsPreset.oneChild,
        _sdkAppState,
        _siblingAddress,
      );
      expect(result.result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);
      expect(result.entries, isEmpty);
    });

    test('queryError and nodeNotRunning stay the error for every main', () {
      for (final main in [_mainAddress, _siblingAddress]) {
        expect(
          DevMockChildWallets.registrationsFor(
            DevChildWalletsPreset.queryError,
            _sdkAppState,
            main,
          ).result,
          GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION,
        );
        expect(
          DevMockChildWallets.registrationsFor(
            DevChildWalletsPreset.nodeNotRunning,
            _sdkAppState,
            main,
          ).result,
          GeniusNodeReturnValue.GENIUS_NODE_ERROR_NOT_INITIALIZED,
        );
      }
    });
  });

  group('through a fake GeniusApi standing in for the write seam', () {
    testWidgets('a confirmed fund resolves to the exact toast copy', (
      tester,
    ) async {
      final now = DateTime(2026, 1, 1);
      final api = _MockWriteApi(mainAddress: _mainAddress, now: () => now);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _sdkAppState,
        now: () => now,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);

      await tester.pump(const Duration(seconds: 3));
      cubit.resolve();

      expect(cubit.state.justResolved, hasLength(1));
      expect(
        resolvedText(cubit.state.justResolved.single, cubit.labelFor),
        'Funded 0.5 GNUS to ${WalletUtils.getAddressForDisplay(_childAddress)}',
      );
      await cubit.close();
    });

    test('a timed-out fund reaches notConfirmed at 2:00', () {
      var now = DateTime(2026, 1, 1);
      DevMockChildWallets.instance.setWriteMode(
        DevChildWalletsWriteMode.timeout,
      );
      final api = _MockWriteApi(mainAddress: _mainAddress, now: () => now);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _sdkAppState,
        now: () => now,
      );
      final submittedAt = now;

      final result = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );
      expect(result, GeniusNodeReturnValue.GENIUS_NODE_RET_OK);

      now = submittedAt.add(childOperationTimeout);
      cubit.resolve();

      expect(cubit.state.operations.single.notConfirmed, isTrue);
      expect(cubit.state.justResolved, isEmpty);
      cubit.close();
    });

    test('a failed fund returns the error, with nothing pending', () {
      final now = DateTime(2026, 1, 1);
      DevMockChildWallets.instance.setWriteMode(DevChildWalletsWriteMode.fail);
      final api = _MockWriteApi(mainAddress: _mainAddress, now: () => now);
      final cubit = ChildOperationsCubit(
        api: api,
        readAppState: () => _sdkAppState,
        now: () => now,
      );

      final result = cubit.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(500000),
      );

      expect(result, GeniusNodeReturnValue.GENIUS_NODE_ERROR_REGISTRATION);
      expect(cubit.state.operations, isEmpty);
      cubit.close();
    });
  });
}
