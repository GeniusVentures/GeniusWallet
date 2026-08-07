// Regression coverage for the dev-tools MOCK holdings buttons losing their
// injected fixtures on their own (debug session
// `.planning/debug/260807-mock-data-vanishes.md`, Jakub 2026-08-07).
//
// Both cases below are CHECK-THEN-ACT defects in `WalletDetailsCubit`, and
// both are dev-only: the guards that close them are led by the
// `kDebugMode && kShowDevTools` const pair, exactly like the pre-existing
// guard at the top of `getCoins()`, so a release build constant-folds them
// away and its executed behaviour is byte-for-byte unchanged.
//
// **This file needs the define.** `kShowDevTools` is a `bool.fromEnvironment`
// const that is FALSE under a plain `flutter test` (the runner passes no
// `--dart-define`), so the guards under test are unreachable here by
// construction - the same constraint `test/dev/dev_mock_sgnus_test.dart` and
// `test/dev/dev_mock_job_test.dart` document for the fixture classes. The
// tests therefore skip themselves unless run as:
//
//   flutter test test/dev/dev_mock_holdings_race_test.dart \
//     --dart-define=GW_DEV_TOOLS=true
//
// They are kept in the tree rather than deleted because they are the only
// executable statement of what the two guards are for; without them the next
// person to "simplify" either guard has nothing to run.
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

/// Hand-written fake - `implements` + `noSuchMethod`, the pattern
/// `test/dashboard/compute_panel_wiring_test.dart` established, because the
/// real `GeniusApi`'s constructor dlopens the native SuperGenius framework
/// and crashes `flutter test`'s host environment.
///
/// Only the two balance reads `readSuperGeniusTokenAssets` makes are given
/// real behaviour. That function performs no I/O at all once the token list
/// is empty (`NetworkTokensProvider` with nothing loaded returns `[]`), which
/// is what keeps this test hermetic - and it is still an `async` function, so
/// `getCoins()`'s `await` on it still yields to the microtask queue. That
/// yield IS the race window; it does not need a slow network to exist, the
/// network only widens it (28517ms, measured on device - see the debug file).
class _FakeGeniusApi implements GeniusApi {
  String gnusBalance = '7';

  @override
  String getSGNUSBalance() => gnusBalance;

  @override
  String getMinionsBalance([String? tokenId]) => '0';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

const _sgnusWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletType: WalletType.sgnus,
  address: '0xRaceWallet',
  balance: 0,
  currencySymbol: 'minions',
  walletName: 'Race Wallet',
);

const _network = Network(
  name: 'Super Genius',
  symbol: 'GNUS',
  chainId: 1,
  rpcUrl: 'https://example.invalid',
);

/// The fixture the dev bubble's `Populated` button injects, reduced to the one
/// property these tests assert on.
const _mockCoins = [
  Coin(name: 'Mock Ether', symbol: 'ETH', balance: 12.5),
  Coin(name: 'Mock Tether', symbol: 'USDT', balance: 900),
];

WalletDetailsCubit _cubit(_FakeGeniusApi api) => WalletDetailsCubit(
  geniusApi: api,
  networkTokensProvider: NetworkTokensProvider(),
  initialState: const WalletDetailsState(
    selectedWallet: _sgnusWallet,
    selectedNetwork: _network,
  ),
);

void main() {
  // One reason string, so a skipped run says WHY rather than just skipping.
  const skipReason = kShowDevTools
      ? null
      : 'needs --dart-define=GW_DEV_TOOLS=true; kShowDevTools is a '
            'compile-time const and the guards under test fold away without it';

  group('injected mock holdings survive the live read', () {
    test('a getCoins() already in flight when Populated is pressed does not '
        'overwrite the injected coins', () async {
      final api = _FakeGeniusApi();
      final cubit = _cubit(api);
      addTearDown(cubit.close);

      // 1. The live read starts and passes the entry guard while mockMode is
      //    still false - this is the state the app is in for as long as
      //    getCoins() is awaiting, which on device was measured at 28.5s.
      final inFlight = cubit.getCoins();

      // 2. The user presses `Populated` DURING that window. Synchronous, so
      //    it lands before the awaited future completes.
      cubit.injectMockCoins(_mockCoins, balance: '999');
      expect(
        cubit.state.coins,
        _mockCoins,
        reason: 'injection itself must take effect immediately',
      );

      // 3. The live read now settles.
      await inFlight;

      // 4. It must NOT have replaced the fixtures. Before the fix it did:
      //    the success emit re-checked only `isClosed`, never `mockMode`,
      //    so the rows Jakub had just injected vanished on their own the
      //    moment the network came back.
      expect(
        cubit.state.coins,
        _mockCoins,
        reason: 'a late live read must not clobber injected mock holdings',
      );
      expect(cubit.state.selectedWalletBalance, '999');
    }, skip: skipReason);

    test(
      'loadInitial does not wipe injected coins (pull-to-refresh)',
      () async {
        final api = _FakeGeniusApi();
        final cubit = _cubit(api);
        addTearDown(cubit.close);

        cubit.injectMockCoins(_mockCoins, balance: '999');

        // `LoadWallets` -> `AppBloc._onLoadWallets` -> this call. Reachable
        // from the dashboard's pull-to-refresh, which is one accidental
        // overscroll away on a phone.
        await cubit.loadInitial(
          selectedWallet: _sgnusWallet,
          selectedNetwork: _network,
        );

        // Before the fix this emitted a FRESH `WalletDetailsState(...)` via the
        // constructor rather than `copyWith`, so `coins` reset to `const []`.
        // Worse than the race above: `mockMode` stayed true, so the entry guard
        // then blocked the refetch too and the panel stayed EMPTY rather than
        // reverting to real holdings.
        expect(
          cubit.state.coins,
          _mockCoins,
          reason: 'a wallet reload must not wipe injected mock holdings',
        );
        // The reload still has to do its real job.
        expect(cubit.state.selectedWallet, _sgnusWallet);
        expect(cubit.state.selectedNetwork, _network);
        expect(cubit.state.initStatus, WalletStatus.successful);
      },
      skip: skipReason,
    );

    test('with mock mode OFF the live read still wins, unchanged', () async {
      final api = _FakeGeniusApi();
      final cubit = _cubit(api);
      addTearDown(cubit.close);

      await cubit.getCoins();

      // The real path is untouched: one native GNUS coin built from the fake's
      // balance. This is the assertion that would catch a "fix" that gated the
      // live read too broadly and starved real wallets of their holdings.
      expect(cubit.state.coinsStatus, WalletStatus.successful);
      expect(cubit.state.coins, hasLength(1));
      expect(cubit.state.coins.single.balance, 7);
    }, skip: skipReason);
  });
}
