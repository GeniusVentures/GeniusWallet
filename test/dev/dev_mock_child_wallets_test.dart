import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

// Pure-Dart coverage of the DevMockChildWallets fixture class only - it
// cannot go through ChildWalletsCubit here: `kShowDevTools` is a
// `bool.fromEnvironment` const that is `false` under `flutter test` (no
// `--dart-define` is passed by the test runner), so the cubit's gated
// branch is unreachable in this environment. That is also why the preset's
// effect on the real cubit and screen is proven in
// test/child_wallets/child_wallets_screen_test.dart instead, through a
// delegating fake `GeniusApi`.
const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _siblingAddress = '0x2222222222222222222222222222222222bbbb';

const _sdkAppState = AppState(
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

void main() {
  setUp(DevMockChildWallets.instance.clear);
  tearDown(DevMockChildWallets.instance.clear);

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
}
