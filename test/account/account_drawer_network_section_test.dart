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
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
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

// Deliberately NOT the real networks. Three mainnets and a testnet, and
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

// A testnet placed BETWEEN mainnets, so sections that merely kept provider
// order would still show it among them and fail the grouping test below.
const _netTest = Network(
  name: 'Testchain Delta',
  symbol: 'DEL',
  chainId: 90004,
  rpcUrl: 'https://delta.invalid',
  iconPath: 'assets/images/crypto/eth-testnet.png',
  testnet: true,
);

const _networks = [_netEth, _netTest, _netPoly, _netBase];

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
/// the sheet shows in its field and the picker marks as selected.
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
    // in most tests here, and after a pick that does not pop it the
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
          expect(find.byType(NetworkSelectField), findsNothing);
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
          expect(find.byType(NetworkSelectField), findsOneWidget);
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

  testWidgets('the network field clears the 44px touch target floor', (
    tester,
  ) async {
    await _withHarness(
      tester,
      current: _netPoly,
      body: (walletBox, networkBox, harness) async {
        final pending = _Pending();
        await tester.pumpWidget(
          _openerHost(harness: harness, pending: pending, includeNetwork: true),
        );

        await _open(tester);

        expect(
          tester.getSize(find.byType(NetworkSelectField)).height,
          greaterThanOrEqualTo(44.0),
        );
      },
    );
  });

  testWidgets(
    'the picker splits by the testnet flag: every testnet under Testnet, no '
    'mainnet there, and the current network marked',
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
          await _openPicker(tester);

          expect(
            _rowTitles(tester, find.byKey(const ValueKey('testnet-section'))),
            _networks.where((n) => n.testnet).map((n) => n.name).toList(),
          );
          expect(
            _rowTitles(tester, find.byKey(const ValueKey('mainnet-section'))),
            _networks.where((n) => !n.testnet).map((n) => n.name).toList(),
          );
          final selected = tester
              .widgetList<GWSelectRow>(
                find.descendant(
                  of: find.byType(NetworkPicker),
                  matching: find.byType(GWSelectRow),
                ),
              )
              .where((r) => r.selected)
              .map((r) => r.title);
          expect(selected, [_netPoly.name]);
        },
      );
    },
  );

  testWidgets(
    'typing in the picker narrows the list by name, and a query that matches '
    'nothing shows the empty state',
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
          await _openPicker(tester);

          await tester.enterText(
            find.descendant(
              of: find.byType(NetworkPicker),
              matching: find.byType(TextField),
            ),
            'delta',
          );
          await tester.pump();

          expect(_rowTitles(tester, find.byType(NetworkPicker)), [
            _netTest.name,
          ]);
          expect(find.byKey(const ValueKey('mainnet-section')), findsNothing);

          await tester.enterText(
            find.descendant(
              of: find.byType(NetworkPicker),
              matching: find.byType(TextField),
            ),
            'zzz',
          );
          await tester.pump();

          expect(_rowTitles(tester, find.byType(NetworkPicker)), isEmpty);
          expect(find.byType(GWEmptyState), findsOneWidget);
        },
      );
    },
  );

  testWidgets(
    'picking another network reaches BOTH the cubit and BOTH Hive keys. A '
    'cubit write without the Hive write would silently revert the chain on '
    'the next launch and read balances from an RPC the user did not choose',
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
          await _openPicker(tester);

          await tester.tap(_inPicker('Testchain Delta'));
          await tester.pumpAndSettle();

          expect(harness.walletDetailsCubit.state.selectedNetwork, _netTest);
          expect(networkBox.get(selectedNetworkKeyChainId), _netTest.chainId);
          expect(networkBox.get(selectedNetworkKeyRpcUrl), _netTest.rpcUrl);
          // Both the picker and the sheet close on selection.
          expect(find.byType(NetworkPicker), findsNothing);
          expect(find.text('Wallet and network'), findsNothing);
        },
      );
    },
  );

  testWidgets(
    'picking the network you are already on is a no-op: no emit, no Hive '
    'write, no toast announcing a switch that did not happen',
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
          await _openPicker(tester);

          // "Did not re-emit" is asserted by OBJECT IDENTITY on the state,
          // not by counting stream events. Every emit builds a fresh
          // `WalletDetailsState` through `copyWith`, so an unchanged instance
          // is proof no emit happened - and it avoids `await sub.cancel()`,
          // which does not complete inside this file's `FakeAsync` harness and
          // hangs the test to its 10-minute timeout.
          final stateBefore = harness.walletDetailsCubit.state;

          await tester.tap(_inPicker('Testchain Beta'));
          // BOUNDED pumps, never `pumpAndSettle`: the sheet stays open here,
          // and a settle would wait for an event this test asserts never
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

Future<void> _openPicker(WidgetTester tester) async {
  await tester.tap(find.byType(NetworkSelectField));
  await tester.pumpAndSettle();
}

Finder _inPicker(String text) =>
    find.descendant(of: find.byType(NetworkPicker), matching: find.text(text));

List<String?> _rowTitles(WidgetTester tester, Finder scope) => tester
    .widgetList<GWSelectRow>(
      find.descendant(of: scope, matching: find.byType(GWSelectRow)),
    )
    .map((r) => r.title)
    .toList();
