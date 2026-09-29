// End-to-end proof that registered children reach the switcher as nested
// rows: SDK (or dev-mock) registrations -> ChildOperationsCubit ->
// buildAccountTree -> real drawer rows, through the same `AccountDrawer.show`
// entry `sdk_account_rows_test.dart` already pumps.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/models/sgnus_connection.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/account/account_drawer.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart'
    show ChildWalletRow;
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:local_secure_storage/local_secure_storage.dart';

const _mainA = '0xaaaa1111';
const _mainB = '0xaaaa2222';

const _walletMainA = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main A',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainA,
);

const _walletMainB = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main B',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainB,
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _Api implements GeniusApi {
  _Api({this.accounts = const []});

  final List<String> accounts;

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  List<String> getAvailableAccounts() => accounts;

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => const {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  String? getSelectedAccountAddress() => null;

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
  }) {
    emit(
      state.copyWith(
        sdkAccounts: sdkAccounts,
        wallets: wallets,
        sdkAccountLinks: sdkAccountLinks,
        selectedSDKAccount: selectedSDKAccount,
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
  // Tall enough that every row, however deep, builds inside the viewport
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

/// The indent this file's Padding wrapper applies at [depth] -- must match
/// `account_drawer.dart`'s own `min(depth, 2) * GeniusWalletConsts.space12`.
double _leftIndentOf(WidgetTester tester, Finder rowFinder) {
  final padding = tester.widget<Padding>(
    find.ancestor(of: rowFinder, matching: find.byType(Padding)).first,
  );
  return (padding.padding as EdgeInsets).left;
}

/// The one row whose title AND subtitle match both -- `SDKAccountRow` is
/// gone (Rule of Three merged it into a private tile no other file can name),
/// so a row is now found the way a human would: by what it says.
Finder _rowFor({required String title, required String subtitle}) =>
    find.byWidgetPredicate(
      (w) => w is GWSelectRow && w.title == title && w.subtitle == subtitle,
    );

void main() {
  tearDown(() => DevMockChildWallets.instance.clear());

  testWidgets(
    'a foreign child under the running account sits between it and the '
    'next account, indented once, with Fund/Recover/Revoke only',
    (tester) async {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.oneChild);
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
        wallets: const [_walletMainA, _walletMainB],
        sdkAccountLinks: const {},
        selectedSDKAccount: _mainA,
      );
      final operations = ChildOperationsCubit(
        api: api,
        readAppState: () => bloc.state,
        devTools: true,
      );

      await _pumpDrawer(tester, bloc, details, operations: operations);

      // Neither account is linked to its same-address wallet here (no
      // links configured), so both stay their own "Unlinked" account rows.
      final mainARow = _rowFor(title: 'Unlinked', subtitle: '0xaaaa...1111');
      final mainBRow = _rowFor(title: 'Unlinked', subtitle: '0xaaaa...2222');

      expect(find.byType(ChildWalletRow), findsOneWidget);
      expect(_leftIndentOf(tester, find.byType(ChildWalletRow)), 24.0);

      final mainARowY = tester.getTopLeft(mainARow).dy;
      final childRowY = tester.getTopLeft(find.byType(ChildWalletRow)).dy;
      final mainBRowY = tester.getTopLeft(mainBRow).dy;
      expect(mainARowY, lessThan(childRowY));
      expect(childRowY, lessThan(mainBRowY));

      await tester.tap(find.byTooltip('Child actions'));
      await tester.pumpAndSettle();
      expect(find.widgetWithText(MenuItemButton, 'Fund'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'Recover'), findsOneWidget);
      expect(find.widgetWithText(MenuItemButton, 'Revoke'), findsOneWidget);
      expect(find.byType(MenuItemButton), findsNWidgets(3));

      await tester.runAsync(() => bloc.close());
      await details.close();
      await operations.close();
    },
  );

  testWidgets(
    'threeChildren registers the other own account under the running main, '
    'but its own wallet link surfaces it at a top-level merged row instead '
    'of nesting it a second time',
    (tester) async {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.threeChildren);
      final api = _Api(accounts: const [_mainA, _mainB]);
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      const links = {_mainB: (walletAddress: _mainB, walletName: 'Main B')};
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [_mainA, _mainB],
        wallets: const [_walletMainA, _walletMainB],
        sdkAccountLinks: links,
        selectedSDKAccount: _mainA,
      );
      final operations = ChildOperationsCubit(
        api: api,
        readAppState: () => bloc.state,
        devTools: true,
      );

      await _pumpDrawer(tester, bloc, details, operations: operations);

      // Main B merges onto its own wallet's row and renders once, at depth
      // 0 -- never duplicated as a nested leaf under Main A.
      expect(find.text('Main B'), findsOneWidget);
      final mainBRow = find.ancestor(
        of: find.text('Main B'),
        matching: find.byType(GWSelectRow),
      );
      expect(_leftIndentOf(tester, mainBRow), 0.0);

      // The preset's two synthetic (not-owned) children still nest under
      // Main A, the running account.
      expect(find.byType(ChildWalletRow), findsNWidgets(2));
      expect(_leftIndentOf(tester, find.byType(ChildWalletRow).at(0)), 24.0);

      await tester.runAsync(() => bloc.close());
      await details.close();
      await operations.close();
    },
  );

  Future<void> expectFlat(
    WidgetTester tester,
    ChildOperationsCubit? Function(_Api api, _SeededAppBloc bloc) makeRegistry,
  ) async {
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
      wallets: const [_walletMainA, _walletMainB],
      sdkAccountLinks: const {},
      selectedSDKAccount: _mainA,
    );
    final operations = makeRegistry(api, bloc);

    await _pumpDrawer(tester, bloc, details, operations: operations);

    final mainARow = _rowFor(title: 'Unlinked', subtitle: '0xaaaa...1111');
    final mainBRow = _rowFor(title: 'Unlinked', subtitle: '0xaaaa...2222');
    expect(mainARow, findsOneWidget);
    expect(mainBRow, findsOneWidget);
    expect(find.byType(ChildWalletRow), findsNothing);
    expect(_leftIndentOf(tester, mainARow), 0.0);
    expect(_leftIndentOf(tester, mainBRow), 0.0);

    await tester.runAsync(() => bloc.close());
    await details.close();
    await operations?.close();
  }

  testWidgets('no registry above the drawer renders every account row flat', (
    tester,
  ) async {
    await expectFlat(tester, (_, _) => null);
  });

  testWidgets('nodeNotRunning armed renders every account row flat', (
    tester,
  ) async {
    await expectFlat(tester, (api, bloc) {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.nodeNotRunning);
      return ChildOperationsCubit(
        api: api,
        readAppState: () => bloc.state,
        devTools: true,
      );
    });
  });

  testWidgets('queryError armed renders every account row flat', (
    tester,
  ) async {
    await expectFlat(tester, (api, bloc) {
      DevMockChildWallets.instance.arm(DevChildWalletsPreset.queryError);
      return ChildOperationsCubit(
        api: api,
        readAppState: () => bloc.state,
        devTools: true,
      );
    });
  });
}
