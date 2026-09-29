// Each SDK row must say which wallet it came from, or admit it has none.
// This file proves the row-naming and row-address contract directly against
// `SDKAccountRow`'s output, reached through the real switcher drawer rather
// than a standalone host.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
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
  _Api({this.links = const {}, this.accounts = const []});

  final Map<String, SDKAccountLink> links;
  final List<String> accounts;

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
    _selectedAccount = address;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  String? getSelectedAccountAddress() => _selectedAccount;

  @override
  String? getStartAccountAddress() => null;

  @override
  BigInt getChildBalanceAll(String childAddress) => BigInt.zero;

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
  // Tall enough that both sections, however many accounts each holds,
  // build inside the viewport rather than needing a scroll per assertion.
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
    'row titles name the wallet, or say Unlinked/wallet removed, and the '
    'address stays on every row - each one selectable and deletable',
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
        // Selected (Active processing account) and default (Default
        // account) sit on two DIFFERENT rows here, so both subtitles are
        // proven independently.
        selectedSDKAccount: _mainB,
        defaultSDKAccount: _mainA.toLowerCase(),
      );

      await _pumpDrawer(tester, bloc, details);

      // Titles: same-named wallets stay two rows, the removed-wallet link
      // keeps its old name, and the unmatched account is honest about it.
      // Scoped to SDKAccountRow: both linked accounts' own wallets ALSO
      // render, by the same name, in the "Sending from" section above.
      expect(
        find.descendant(
          of: find.byType(SDKAccountRow),
          matching: find.text('Main'),
        ),
        findsNWidgets(2),
      );
      expect(find.text('Old (wallet removed)'), findsOneWidget);
      expect(find.text('Unlinked'), findsOneWidget);

      // Each row's own short address, plus the right status suffix.
      expect(
        find.textContaining('0xaaaa...1111 · Default account'),
        findsOneWidget,
      );
      expect(
        find.textContaining('0xaaaa...2222 · Active processing account'),
        findsOneWidget,
      );
      expect(find.text('0xaaaa...3333'), findsOneWidget);
      expect(find.text('0xaaaa...4444'), findsOneWidget);

      // Rows keep the SDK's own order.
      final titleOrder = tester
          .widgetList<SDKAccountRow>(find.byType(SDKAccountRow))
          .map((row) => row.name)
          .toList();
      expect(titleOrder, ['Main', 'Main', 'Old (wallet removed)', 'Unlinked']);

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
      expect(find.byType(SDKAccountRow), findsNothing);

      await tester.runAsync(() => bloc.close());
      await details.close();
    },
  );

  group('the pending-operation switcher lock', () {
    const target = '0xaaaa5555';

    testWidgets(
      'a pending fund from the running account locks every other row, '
      'tooltipped, and a tap refuses the switch instead of dispatching it',
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

        await tester.tap(find.byType(SDKAccountRow).at(1));
        await tester.pumpAndSettle();

        expect(find.text(reason), findsWidgets);
        expect(bloc.state.selectedSDKAccount, _mainA);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'the selected row carries no lock glyph, and Sending from switching is '
      'unaffected',
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

        final selectedRowFinder = find.byWidgetPredicate(
          (w) => w is SDKAccountRow && w.address == _mainA,
        );
        expect(
          find.descendant(
            of: selectedRowFinder,
            matching: find.byIcon(Icons.lock_outline),
          ),
          findsNothing,
        );

        // "Sending from" is a separate section built from plain
        // `GWSelectRow`s, not `SDKAccountRow` -- this widget's lock only
        // ever reaches the "Node running as" rows above, so the lone lock
        // glyph on screen stays inside that section (proven exhaustively,
        // with the real Hive-backed switch, in account_drawer_show_test.dart).
        expect(find.byIcon(Icons.lock_outline), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SDKAccountRow),
            matching: find.byIcon(Icons.lock_outline),
          ),
          findsOneWidget,
        );

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'once the pending op times out to notConfirmed, the lock releases and '
      'a tap switches again',
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

        await tester.tap(find.byType(SDKAccountRow).at(1));
        await tester.pumpAndSettle();

        expect(bloc.state.selectedSDKAccount, _mainB);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'a drawer pumped without any registry above it renders every row '
      'unlocked',
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

        await tester.tap(find.byType(SDKAccountRow).at(1));
        await tester.pumpAndSettle();

        expect(bloc.state.selectedSDKAccount, _mainB);

        await tester.runAsync(() => bloc.close());
        await details.close();
      },
    );
  });
}
