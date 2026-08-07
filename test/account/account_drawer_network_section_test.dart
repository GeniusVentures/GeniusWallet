// The combined "Wallet and network" sheet: one surface answering both
// "whose wallet" and "on which chain".
//
// The harness discipline below is copied VERBATIM from
// `account_drawer_show_test.dart`, which is the file that solved the
// `FakeAsync` + real Hive I/O hang three prior agents stalled on. Read that
// file's header for the full reasoning; the short version:
//
//   * `Hive.openBox(name, bytes: Uint8List(0))` selects hive_ce's
//     `StorageBackendMemory`, whose writes are real `Future`s that actually
//     complete inside `FakeAsync`. A disk-backed box hangs forever.
//   * `_FakeGeniusApi` rather than a real `GeniusApi`, whose constructor
//     dlopens the native SuperGenius framework and kills the test host.
//   * Disposal in `finally`, never `addTearDown` - teardown callbacks run
//     AFTER flutter_test's "no pending Timer" invariant, and `AppBloc` starts
//     a 3s init poll in its constructor.
//   * `tester.runAsync` around `appBloc.close()` only.
//
// Two additions this file needs that the show test did not:
//
//   * a SECOND in-memory box at `networkBoxName`, because the whole point of
//     `NetworkSelection.apply` is that it writes both network keys;
//   * `ToastManager.instance.disposeAll()` in the same `finally`. The success
//     toast arms a 5s `Timer` that no `pumpAndSettle` will drain, and that
//     Timer trips the same invariant `AppBloc`'s poll does.
//
// `loadNetworks()` is never called: it reads the asset bundle, and this test
// has no business depending on what is in networks.json. The provider is
// seeded by subclass instead, the same way `_SeededAppBloc` seeds wallets.
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/network/network_dropdown_selector.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

/// See `account_drawer_show_test.dart`'s copy of this class for why it is
/// `implements` + `noSuchMethod` and not `extends`.
class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
    required List<Wallet> wallets,
  }) {
    emit(state.copyWith(wallets: wallets));
  }
}

/// Seeds the network list directly. `loadNetworks()` would read the asset
/// bundle and make every assertion below a hostage of networks.json.
class _SeededNetworkProvider extends NetworkProvider {
  _SeededNetworkProvider(this._seeded);

  final List<Network> _seeded;

  @override
  List<Network> get networks => _seeded;
}

// Deliberately NOT the real networks. Three is enough to prove ordering, and
// naming them apart from anything in networks.json makes a test that
// accidentally reads the real asset fail loudly rather than pass by luck.
const _netEth = Network(
  name: 'Testchain Alpha',
  symbol: 'ALP',
  chainId: 90001,
  rpcUrl: 'https://alpha.invalid',
  iconPath: 'assets/images/crypto/eth.png',
);

const _netPoly = Network(
  name: 'Testchain Beta',
  symbol: 'BET',
  chainId: 90002,
  rpcUrl: 'https://beta.invalid',
  iconPath: 'assets/images/crypto/matic.png',
);

const _netBase = Network(
  name: 'Testchain Gamma',
  symbol: 'GAM',
  chainId: 90003,
  rpcUrl: 'https://gamma.invalid',
  iconPath: 'assets/images/crypto/base.png',
);

const _networks = [_netEth, _netPoly, _netBase];

const _walletA = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Wallet A',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: '0xAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA',
);

class _Harness {
  _Harness(this.walletDetailsCubit, this.appBloc, this.networkProvider);

  final WalletDetailsCubit walletDetailsCubit;
  final AppBloc appBloc;
  final NetworkProvider networkProvider;

  Future<void> dispose(WidgetTester tester) async {
    await tester.runAsync(() => appBloc.close());
    await walletDetailsCubit.close();
  }
}

/// [current] seeds `WalletDetailsCubit.state.selectedNetwork`, which is what
/// the sheet marks as selected and orders first.
///
/// `selectedWallet` is deliberately left null: `selectNetwork` calls
/// `getCoins()`, and `getCoins` returns at its first guard
/// (`wallet_details_cubit.dart:182`) when no wallet is selected. That is what
/// keeps a network tap from reaching a real RPC read inside a widget test.
_Harness _build({Network? current}) {
  final walletDetailsCubit = WalletDetailsCubit(
    initialState: WalletDetailsState(selectedNetwork: current),
    geniusApi: _FakeGeniusApi(),
    networkTokensProvider: NetworkTokensProvider(),
  );
  final networkProvider = _SeededNetworkProvider(_networks);
  final appBloc = _SeededAppBloc(
    api: _FakeGeniusApi(),
    transactionsCubit: TransactionsCubit(),
    walletDetailsCubit: walletDetailsCubit,
    networkProvider: networkProvider,
    wallets: const [_walletA],
  );
  return _Harness(walletDetailsCubit, appBloc, networkProvider);
}

class _Pending {
  Future<Wallet?>? future;
}

/// Providers wrap `MaterialApp` itself, not just `home` - `ResponsiveDrawer
/// .show` pushes on the ROOT navigator, and the pushed route attaches to the
/// Navigator's Overlay rather than nesting inside `home`. Anything the sheet
/// reads must therefore be an ANCESTOR of the Navigator.
Widget _openerHost({
  required _Harness harness,
  required _Pending pending,
  required bool includeNetwork,
}) => MultiProvider(
  providers: [
    BlocProvider<WalletDetailsCubit>.value(value: harness.walletDetailsCubit),
    BlocProvider<AppBloc>.value(value: harness.appBloc),
    ChangeNotifierProvider<NetworkProvider>.value(
      value: harness.networkProvider,
    ),
  ],
  child: MaterialApp(
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    home: Scaffold(
      body: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            pending.future = AccountDrawer.show(
              context,
              includeNetwork: includeNetwork,
            );
          },
          child: const Text('open drawer'),
        ),
      ),
    ),
  ),
);

/// Opens both in-memory boxes plus a fresh harness, runs [body], tears
/// everything down in `finally`.
Future<void> _withHarness(
  WidgetTester tester, {
  Network? current,
  required Future<void> Function(
    Box walletBox,
    Box networkBox,
    _Harness harness,
  )
  body,
}) async {
  // A PHONE surface, not flutter_test's 800x600 default. This sheet is a
  // mobile surface: at 800 wide `ResponsiveDrawer` takes its desktop side-panel
  // form, which is not the geometry any assertion below is about.
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1.0;

  final walletBox = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
  final networkBox = await Hive.openBox(networkBoxName, bytes: Uint8List(0));

  final harness = _build(current: current);

  try {
    await body(walletBox, networkBox, harness);
  } finally {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
    // Cancels the success toast's 5s Timer, which nothing else drains and
    // which would otherwise trip flutter_test's pending-Timer invariant.
    ToastManager.instance.disposeAll();
    // BOUNDED, never `pumpAndSettle`. This runs with the sheet still mounted
    // in most tests here, and after a chip tap that does not pop it the
    // settle does not terminate - it spins to the 10-minute test timeout.
    // A fixed pump is all this needs: it exists only to let `disposeAll`'s
    // toast-removal run, which is a 300ms reverse at most.
    await tester.pump(const Duration(milliseconds: 400));
    await harness.dispose(tester);
    await walletBox.close();
    await networkBox.close();
  }
}

Future<void> _open(WidgetTester tester) async {
  await tester.tap(find.text('open drawer'));
  await tester.pumpAndSettle();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'the DEFAULT caller gets byte-identical behaviour: title "Accounts", no '
    'network section at all. This is the assertion that proves the parameter '
    'is additive - every existing call site passes nothing',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: false,
            ),
          );

          await _open(tester);

          expect(find.text('Accounts'), findsOneWidget);
          expect(find.text('Wallet and network'), findsNothing);
          expect(find.text('NETWORK'), findsNothing);
          expect(find.byType(NetworkSelectChip), findsNothing);
          // The 174 sections are untouched by the flag.
          expect(find.text('YOUR ACCOUNTS'), findsOneWidget);
          expect(find.text('Wallet A'), findsOneWidget);
        },
      );
    },
  );

  testWidgets(
    'with includeNetwork the sheet is retitled and grows a NETWORK section '
    'above the account sections it does not otherwise touch',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: true,
            ),
          );

          await _open(tester);

          expect(find.text('Wallet and network'), findsOneWidget);
          expect(find.text('Accounts'), findsNothing);
          expect(find.text('NETWORK'), findsOneWidget);
          // At LEAST one, not exactly `_networks.length`: the strip is a lazy
          // horizontal `ListView`, so only the chips inside the viewport are
          // built. On a 390pt phone roughly two and a half fit, which is the
          // documented cost of the horizontal axis - reachability of the rest
          // is asserted by its own test below rather than papered over here.
          expect(find.byType(NetworkSelectChip), findsAtLeastNWidgets(1));
          // Still the sketch-174 drawer underneath.
          expect(find.text('YOUR ACCOUNTS'), findsOneWidget);
          expect(find.text('Wallet A'), findsOneWidget);
          expect(find.text('Add Wallet'), findsOneWidget);
        },
      );
    },
  );

  testWidgets(
    'the current network is named in WORDS on screen - the whole point of the '
    'section, since the pill identifies it only by a 16px picture',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: true,
            ),
          );

          await _open(tester);

          expect(find.text('Testchain Beta'), findsOneWidget);
        },
      );
    },
  );

  testWidgets(
    'the current network sorts FIRST regardless of its index in the provider '
    'list - Beta is second in _networks and must lead the strip, so "which '
    'chain am I on" costs no horizontal scrolling',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: true,
            ),
          );

          await _open(tester);

          final chips = tester
              .widgetList<NetworkSelectChip>(find.byType(NetworkSelectChip))
              .toList();
          expect(chips.first.network, _netPoly);
          expect(chips.first.selected, isTrue);
          // Provider order survives behind the promoted one. Only the chips
          // in the viewport are built, so this reads the second rather than
          // the whole list; the third is covered by the reachability test.
          expect(chips[1].network, _netEth);
          expect(chips[1].selected, isFalse);
        },
      );
    },
  );

  testWidgets(
    'the networks past the fold are reachable by swiping the strip. This is '
    'the accepted cost of the horizontal axis: the answer to "which chain am '
    'I on" is free, but the last network takes a swipe to reach',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: true,
            ),
          );

          await _open(tester);

          expect(find.text('Testchain Gamma'), findsNothing);

          await tester.scrollUntilVisible(
            find.text('Testchain Gamma'),
            120,
            scrollable: find.byWidgetPredicate(
              (w) => w is Scrollable && w.axis == Axis.horizontal,
            ),
          );
          await tester.pumpAndSettle();

          expect(find.text('Testchain Gamma'), findsOneWidget);
        },
      );
    },
  );

  testWidgets('every chip clears the 44px touch target floor', (tester) async {
    await _withHarness(
      tester,
      current: _netPoly,
      body: (walletBox, networkBox, harness) async {
        final pending = _Pending();
        await tester.pumpWidget(
          _openerHost(harness: harness, pending: pending, includeNetwork: true),
        );

        await _open(tester);

        for (final element in find.byType(NetworkSelectChip).evaluate()) {
          expect(
            tester.getSize(find.byElementPredicate((e) => e == element)).height,
            greaterThanOrEqualTo(44.0),
          );
        }
      },
    );
  });

  testWidgets(
    'tapping another chip reaches BOTH the cubit and BOTH Hive keys. A cubit '
    'write without the Hive write would silently revert the chain on the next '
    'launch and read balances from an RPC the user did not choose',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: true,
            ),
          );

          await _open(tester);

          // Alpha, the second chip. Its label's centre sits just past the
          // right edge at 390pt with these deliberately long fixture names,
          // so it is swiped into view first - which is what a user does.
          await tester.scrollUntilVisible(
            find.text('Testchain Alpha'),
            120,
            scrollable: find.byWidgetPredicate(
              (w) => w is Scrollable && w.axis == Axis.horizontal,
            ),
          );
          await tester.pumpAndSettle();

          await tester.tap(find.text('Testchain Alpha'));
          await tester.pumpAndSettle();

          expect(harness.walletDetailsCubit.state.selectedNetwork, _netEth);
          expect(networkBox.get(selectedNetworkKeyChainId), _netEth.chainId);
          expect(networkBox.get(selectedNetworkKeyRpcUrl), _netEth.rpcUrl);
          // The sheet closes on selection, the way the row list already does.
          expect(find.text('Wallet and network'), findsNothing);
        },
      );
    },
  );

  testWidgets(
    'tapping the chip you are already on is a no-op: no emit, no Hive write, '
    'no toast announcing a switch that did not happen',
    (tester) async {
      await _withHarness(
        tester,
        current: _netPoly,
        body: (walletBox, networkBox, harness) async {
          final pending = _Pending();
          await tester.pumpWidget(
            _openerHost(
              harness: harness,
              pending: pending,
              includeNetwork: true,
            ),
          );

          await _open(tester);

          // "Did not re-emit" is asserted by OBJECT IDENTITY on the state,
          // not by counting stream events. Every emit builds a fresh
          // `WalletDetailsState` through `copyWith`, so an unchanged instance
          // is proof no emit happened - and it avoids `await sub.cancel()`,
          // which does not complete inside this file's `FakeAsync` harness and
          // hangs the test to its 10-minute timeout.
          final stateBefore = harness.walletDetailsCubit.state;

          await tester.tap(find.text('Testchain Beta'));
          // BOUNDED pumps, never `pumpAndSettle`. This is the one tap in the
          // file that leaves the sheet OPEN, and `pumpAndSettle` does not
          // terminate here: the sheet stays mounted, so whatever keeps
          // scheduling frames behind it keeps scheduling them, and the call
          // spins until the 10-minute test timeout. Two bounded pumps are
          // also the honest tool for asserting that NOTHING happened - a
          // settle would be waiting for an event this test asserts never
          // occurs.
          await tester.pump();
          await tester.pump(const Duration(milliseconds: 400));

          expect(
            identical(harness.walletDetailsCubit.state, stateBefore),
            isTrue,
          );
          expect(harness.walletDetailsCubit.state.selectedNetwork, _netPoly);
          expect(networkBox.get(selectedNetworkKeyChainId), isNull);
          expect(networkBox.get(selectedNetworkKeyRpcUrl), isNull);
          expect(find.text('Network Changed'), findsNothing);
        },
      );
    },
  );
}
