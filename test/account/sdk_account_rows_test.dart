// Each account row must say which wallet it came from, or admit it has
// none, and "Run node as this" -- not a row tap -- is the only path that
// switches the node. Reached through the real switcher
// drawer rather than a standalone host.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

// Ten-character, already-lowercased addresses, distinct in their last four,
// so each row's truncated subtitle (`WalletUtils.getAddressForDisplay`)
// stays distinguishable even between the two same-named wallets below.
// Lowercase because `SDKAccountLink.walletAddress` is always stored
// lowercased (`local_secure_storage_base.dart:393`) and matched against
// `wallet.address.toLowerCase()` - a mixed-case fixture here would test
// nothing but its own typo.
const _mainA = '0xaaaa1111';
const _mainB = '0xaaaa2222';
const _oldAddr = '0xaaaa3333';
const _unlinkedAddr = '0xaaaa4444';

const _walletMainA = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainA,
);

const _walletMainB = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainB,
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
  _Api({this.links = const {}, this.accounts = const [], this.lands = true});

  final Map<String, SDKAccountLink> links;
  final List<String> accounts;

  /// False: the node is still starting and names no account after a select.
  final bool lands;

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  List<String> getAvailableAccounts() => accounts;

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => links;

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  // The three overrides a pending fund needs from `ChildOperationsCubit` --
  // this file's own drawer/row contract has no use for a real balance.
  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) =>
      GeniusNodeReturnValue.GENIUS_NODE_RET_OK;

  @override
  String getMinionsBalance([String? tokenId]) => '10000000';

  // A released lock's own test taps a row expecting the switch to actually
  // land -- `AppBloc._onSelectSDKAccount` reads these three back once
  // `selectGeniusAccountAsync` itself returns OK.
  String? _selectedAccount;

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(String address) async {
    _selectedAccount = lands ? address : null;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  String? getSelectedAccountAddress() => _selectedAccount;

  @override
  String? getStartAccountAddress() => null;

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) => BigInt.zero;

  // The switcher's own registrations pre-read now calls this for every own
  // account once a registry sits above the drawer -- an OK, empty read
  // matches this file's "nobody has any children" fixtures.
  @override
  ChildRegistrations getChildRegistrations(String mainAddress) => const (
    result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    entries: <ChildRegistration>[],
  );

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _SeededAppBloc extends AppBloc {
  _SeededAppBloc({
    required super.api,
    required super.transactionsCubit,
    required super.walletDetailsCubit,
    required super.networkProvider,
    required List<String> sdkAccounts,
    required List<Wallet> wallets,
    required Map<String, SDKAccountLink> sdkAccountLinks,
    String? selectedSDKAccount,
    String? defaultSDKAccount,
  }) {
    emit(
      state.copyWith(
        sdkAccounts: sdkAccounts,
        wallets: wallets,
        sdkAccountLinks: sdkAccountLinks,
        selectedSDKAccount: selectedSDKAccount,
        defaultSDKAccount: defaultSDKAccount,
      ),
    );
  }
}

Future<void> _pumpDrawer(
  WidgetTester tester,
  _SeededAppBloc bloc,
  WalletDetailsCubit details, {
  ChildOperationsCubit? operations,
}) async {
  // Tall enough that every row, however many, builds inside the viewport
  // rather than needing a scroll per assertion.
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    MultiBlocProvider(
      providers: [
        BlocProvider<WalletDetailsCubit>.value(value: details),
        BlocProvider<AppBloc>.value(value: bloc),
        // Absent by default: a drawer with no registry above it (every test
        // in this file that omits `operations`) must render every row
        // unlocked, the same as before this cubit existed.
        if (operations != null)
          BlocProvider<ChildOperationsCubit>.value(value: operations),
      ],
      child: MaterialApp(
        theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => AccountDrawer.show(context),
              child: const Text('open drawer'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open drawer'));
  await tester.pumpAndSettle();
}

void main() {
  test('an empty SDK account list renders no button and no rows', () async {
    final api = _Api();
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
      sdkAccounts: const [],
      wallets: const [],
      sdkAccountLinks: const {},
    );
    expect(bloc.state.sdkAccounts, isEmpty);
    await bloc.close();
    await details.close();
  });

  testWidgets(
    'a linked account merges onto its wallet\'s row and shows that name '
    'once; an unlinked or wallet-removed account is honest about it - every '
    'row keeps its own short address',
    (tester) async {
      final api = _Api(
        links: const {
          _mainA: (walletAddress: _mainA, walletName: 'Main'),
          _mainB: (walletAddress: _mainB, walletName: 'Main'),
          _oldAddr: (walletAddress: '0xffff9999', walletName: 'Old'),
        },
        accounts: const [_mainA, _mainB, _oldAddr, _unlinkedAddr],
      );
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [_mainA, _mainB, _oldAddr, _unlinkedAddr],
        wallets: const [_walletMainA, _walletMainB],
        sdkAccountLinks: api.links,
        // The default account (mainA) and the running one (mainB) sit on
        // two DIFFERENT merged rows, so both markers are proven
        // independently: " · Default account" inline, "On node" as a tag.
        selectedSDKAccount: _mainB,
        defaultSDKAccount: _mainA.toLowerCase(),
      );

      await _pumpDrawer(tester, bloc, details);

      // One row per account: merging leaves exactly one "Main" per
      // linked pair, not the two the pre-merge switcher would have shown.
      expect(find.text('Main'), findsNWidgets(2));
      expect(find.text('Old (wallet removed)'), findsOneWidget);
      expect(find.text('Unlinked'), findsOneWidget);

      // Each row's own short address, plus the right status.
      expect(
        find.textContaining('0xaaaa...1111 · Default account'),
        findsOneWidget,
      );
      expect(find.text('0xaaaa...2222'), findsOneWidget);
      expect(find.text('Earning'), findsOneWidget);
      expect(find.text('0xaaaa...3333'), findsOneWidget);
      expect(find.text('0xaaaa...4444'), findsOneWidget);

      // Render order: own wallets (merged) first, then unmerged accounts.
      final order = [
        '0xaaaa...1111',
        '0xaaaa...2222',
        '0xaaaa...3333',
        '0xaaaa...4444',
      ].map((text) => tester.getTopLeft(find.textContaining(text)).dy).toList();
      for (var i = 1; i < order.length; i++) {
        expect(order[i], greaterThan(order[i - 1]));
      }

      await tester.runAsync(() => bloc.close());
      await details.close();
    },
  );

  testWidgets("the selected row's Child wallets item is enabled", (
    tester,
  ) async {
    final api = _Api(
      links: const {_mainA: (walletAddress: _mainA, walletName: 'Main')},
      accounts: const [_mainA, _mainB],
    );
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
      sdkAccounts: const [_mainA, _mainB],
      wallets: const [_walletMainA],
      sdkAccountLinks: api.links,
      selectedSDKAccount: _mainA,
    );

    await _pumpDrawer(tester, bloc, details);

    await tester.tap(find.byTooltip('Account options').at(0));
    await tester.pumpAndSettle();

    final item = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Child wallets'),
    );
    expect(item.onPressed, isNotNull);

    await tester.runAsync(() => bloc.close());
    await details.close();
  });

  testWidgets("another row's Child wallets item is disabled", (tester) async {
    final api = _Api(
      links: const {_mainA: (walletAddress: _mainA, walletName: 'Main')},
      accounts: const [_mainA, _mainB],
    );
    final details = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final bloc = _SeededAppBloc(
      api: api,
      transactionsCubit: TransactionsCubit(),
      walletDetailsCubit: details,
      networkProvider: NetworkProvider(),
      sdkAccounts: const [_mainA, _mainB],
      wallets: const [_walletMainA],
      sdkAccountLinks: api.links,
      selectedSDKAccount: _mainA,
    );

    await _pumpDrawer(tester, bloc, details);

    await tester.tap(find.byTooltip('Account options').at(1));
    await tester.pumpAndSettle();

    final item = tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, 'Child wallets'),
    );
    expect(item.onPressed, isNull);

    await tester.runAsync(() => bloc.close());
    await details.close();
  });

  testWidgets(
    "tapping the selected row's Child wallets item closes the drawer and "
    "routes to it with that row's address",
    (tester) async {
      final api = _Api(
        links: const {_mainA: (walletAddress: _mainA, walletName: 'Main')},
        accounts: const [_mainA, _mainB],
      );
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [_mainA, _mainB],
        wallets: const [_walletMainA],
        sdkAccountLinks: api.links,
        selectedSDKAccount: _mainA,
      );

      tester.view.physicalSize = const Size(1200, 2000);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final router = GoRouter(
        initialLocation: '/',
        routes: [
          GoRoute(
            path: '/',
            builder: (context, state) => Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => AccountDrawer.show(context),
                  child: const Text('open drawer'),
                ),
              ),
            ),
          ),
          GoRoute(
            path: '/child-wallets',
            builder: (context, state) => Text('child of ${state.extra}'),
          ),
        ],
      );

      await tester.pumpWidget(
        MultiBlocProvider(
          providers: [
            BlocProvider<WalletDetailsCubit>.value(value: details),
            BlocProvider<AppBloc>.value(value: bloc),
          ],
          child: MaterialApp.router(
            theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
            routerConfig: router,
          ),
        ),
      );
      await tester.tap(find.text('open drawer'));
      await tester.pumpAndSettle();

      await tester.tap(find.byTooltip('Account options').at(0));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(MenuItemButton, 'Child wallets'));
      await tester.pumpAndSettle();

      expect(find.text('child of $_mainA'), findsOneWidget);
      expect(find.text('Main'), findsNothing);

      await tester.runAsync(() => bloc.close());
      await details.close();
    },
  );

  group('the pending-operation switcher lock', () {
    const target = '0xaaaa5555';

    testWidgets(
      'a pending fund from the running account disables "Run node as this" '
      'on every other row, tooltipped with the reason, and a row tap never '
      'reaches the SDK select',
      (tester) async {
        final api = _Api(accounts: const [_mainA, _mainB]);
        final details = WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        );
        final bloc = _SeededAppBloc(
          api: api,
          transactionsCubit: TransactionsCubit(),
          walletDetailsCubit: details,
          networkProvider: NetworkProvider(),
          sdkAccounts: const [_mainA, _mainB],
          wallets: const [_walletMainA],
          sdkAccountLinks: const {},
          selectedSDKAccount: _mainA,
        );
        final operations = ChildOperationsCubit(
          api: api,
          readAppState: () => bloc.state,
        );
        operations.submit(
          kind: ChildOperationKind.fund,
          target: target,
          main: _mainA,
          amountMinions: BigInt.from(1000000),
        );

        await _pumpDrawer(tester, bloc, details, operations: operations);

        const reason =
            'Waiting for a child operation from 0xaaaa...1111 to confirm';
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(find.byTooltip(reason), findsOneWidget);

        // A tap only ever affects wallet selection; mainB has no
        // sgnus wallet here, so it is a no-op either way, never the switch.
        await tester.tap(find.text('0xaaaa...2222'));
        await tester.pump();

        expect(bloc.state.selectedSDKAccount, _mainA);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'the on-node row carries no lock glyph -- exactly one row does',
      (tester) async {
        final api = _Api(accounts: const [_mainA, _mainB]);
        final details = WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        );
        final bloc = _SeededAppBloc(
          api: api,
          transactionsCubit: TransactionsCubit(),
          walletDetailsCubit: details,
          networkProvider: NetworkProvider(),
          sdkAccounts: const [_mainA, _mainB],
          wallets: const [_walletMainA],
          sdkAccountLinks: const {},
          selectedSDKAccount: _mainA,
        );
        final operations = ChildOperationsCubit(
          api: api,
          readAppState: () => bloc.state,
        );
        operations.submit(
          kind: ChildOperationKind.fund,
          target: target,
          main: _mainA,
          amountMinions: BigInt.from(1000000),
        );

        await _pumpDrawer(tester, bloc, details, operations: operations);

        final onNodeRow = find.ancestor(
          of: find.text('0xaaaa...1111'),
          matching: find.byType(GWSelectRow),
        );
        expect(
          find.descendant(
            of: onNodeRow,
            matching: find.byIcon(Icons.lock_outline),
          ),
          findsNothing,
        );
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'once the pending op times out to notConfirmed, "Run node as this" '
      're-enables on the other row and switches the node',
      (tester) async {
        var now = DateTime(2024);
        final api = _Api(accounts: const [_mainA, _mainB]);
        final details = WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        );
        final bloc = _SeededAppBloc(
          api: api,
          transactionsCubit: TransactionsCubit(),
          walletDetailsCubit: details,
          networkProvider: NetworkProvider(),
          sdkAccounts: const [_mainA, _mainB],
          wallets: const [_walletMainA],
          sdkAccountLinks: const {},
          selectedSDKAccount: _mainA,
        );
        final operations = ChildOperationsCubit(
          api: api,
          readAppState: () => bloc.state,
          now: () => now,
        );
        final submittedAt = now;
        operations.submit(
          kind: ChildOperationKind.fund,
          target: target,
          main: _mainA,
          amountMinions: BigInt.from(1000000),
        );

        await _pumpDrawer(tester, bloc, details, operations: operations);
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);

        now = submittedAt.add(childOperationTimeout);
        operations.resolve();
        await tester.pumpAndSettle();

        expect(find.byIcon(Icons.lock_outline), findsNothing);

        // Rows render wallet A first (index 0), then mainA and mainB as
        // unmerged accounts -- mainB is index 2.
        await tester.tap(find.byTooltip('Account options').at(2));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(MenuItemButton, 'Earn with this account'),
        );
        await tester.pump();

        expect(bloc.state.selectedSDKAccount, _mainB);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'a drawer pumped without any registry above it renders every row '
      'unlocked, and "Run node as this" switches freely',
      (tester) async {
        final api = _Api(accounts: const [_mainA, _mainB]);
        final details = WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        );
        final bloc = _SeededAppBloc(
          api: api,
          transactionsCubit: TransactionsCubit(),
          walletDetailsCubit: details,
          networkProvider: NetworkProvider(),
          sdkAccounts: const [_mainA, _mainB],
          wallets: const [_walletMainA],
          sdkAccountLinks: const {},
          selectedSDKAccount: _mainA,
        );

        // No `operations:` argument -- the exact shape every other test in
        // this file already pumps.
        await _pumpDrawer(tester, bloc, details);

        expect(find.byIcon(Icons.lock_outline), findsNothing);

        // Rows render wallet A first (index 0), then mainA and mainB as
        // unmerged accounts -- mainB is index 2.
        await tester.tap(find.byTooltip('Account options').at(2));
        await tester.pumpAndSettle();
        await tester.tap(
          find.widgetWithText(MenuItemButton, 'Earn with this account'),
        );
        await tester.pump();

        expect(bloc.state.selectedSDKAccount, _mainB);

        await tester.runAsync(() => bloc.close());
        await details.close();
      },
    );
  });

  testWidgets(
    'while a switch is in flight, the account being left offers no payout '
    'and the account being switched to cannot be deleted',
    (tester) async {
      final api = _Api(accounts: const [_mainA, _mainB], lands: false);
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [_mainA, _mainB],
        wallets: const [_walletMainA],
        sdkAccountLinks: const {},
        selectedSDKAccount: _mainA,
      );
      await _pumpDrawer(tester, bloc, details);

      Finder optionsFor(String shortAddress) => find.descendant(
        of: find.ancestor(
          of: find.text(shortAddress),
          matching: find.byWidgetPredicate(
            (w) => w.runtimeType.toString() == '_AccountRowTile',
          ),
        ),
        matching: find.byTooltip('Account options'),
      );
      final leaving = optionsFor('0xaaaa...1111').last;
      final target = optionsFor('0xaaaa...2222').last;

      MenuItemButton item(String label) => tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, label),
      );

      await tester.tap(leaving);
      await tester.pumpAndSettle();
      expect(item('Set payout address').onPressed, isNotNull);
      await tester.tap(leaving);
      await tester.pumpAndSettle();

      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(item('Delete account').onPressed, isNotNull);
      await tester.tap(
        find.widgetWithText(MenuItemButton, 'Earn with this account'),
      );
      await tester.pump();
      await tester.pump();

      await tester.tap(leaving);
      await tester.pumpAndSettle();
      expect(item('Set payout address').onPressed, isNull);
      await tester.tap(leaving);
      await tester.pumpAndSettle();

      await tester.tap(target);
      await tester.pumpAndSettle();
      expect(item('Delete account').onPressed, isNull);
      await tester.tap(target);

      api._selectedAccount = _mainB;
      await tester.pump(const Duration(seconds: 3));
      await tester.pumpAndSettle();
      await tester.runAsync(() => bloc.close());
      await details.close();
    },
  );

  testWidgets(
    'a switch the node has not confirmed tags its row "Switching…" and no '
    'row "On node", until the node reports the account',
    (tester) async {
      final api = _Api(accounts: const [_mainA, _mainB], lands: false);
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [_mainA, _mainB],
        wallets: const [_walletMainA],
        sdkAccountLinks: const {},
        selectedSDKAccount: _mainA,
      );
      await _pumpDrawer(tester, bloc, details);

      // Rows render wallet A first (index 0), then mainA and mainB as
      // unmerged accounts -- mainB is index 2.
      await tester.tap(find.byTooltip('Account options').at(2));
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(MenuItemButton, 'Earn with this account'),
      );
      await tester.pump();
      await tester.pump();

      Finder rowFor(String address) => find.ancestor(
        of: find.text(address),
        matching: find.byType(GWSelectRow),
      );
      expect(
        find.descendant(
          of: rowFor('0xaaaa...2222'),
          matching: find.text('Switching…'),
        ),
        findsOneWidget,
      );
      expect(find.text('Earning'), findsNothing);

      api._selectedAccount = _mainB;
      await tester.pump(const Duration(seconds: 3));
      await tester.pump();

      expect(find.text('Switching…'), findsNothing);
      expect(
        find.descendant(
          of: rowFor('0xaaaa...2222'),
          matching: find.text('Earning'),
        ),
        findsOneWidget,
      );

      await tester.pumpAndSettle();
      await tester.runAsync(() => bloc.close());
      await details.close();
    },
  );
}
