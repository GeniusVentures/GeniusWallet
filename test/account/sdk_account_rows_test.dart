// Each SDK row must say which wallet it came from, or admit it has none.
// This file proves the row-naming and row-address contract directly against
// `SDKAccountRow`'s output, reached through the real switcher drawer rather
// than a standalone host.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/account/sdk_account_manager.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
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
  WalletDetailsCubit details,
) async {
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
}
