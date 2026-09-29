// End-to-end proof that registered children reach the switcher as nested
// rows: SDK (or dev-mock) registrations -> ChildOperationsCubit ->
// buildAccountTree -> real drawer rows, through the same `AccountDrawer.show`
// entry `sdk_account_rows_test.dart` already pumps.
import 'dart:typed_data';

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
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart'
    show ChildWalletRow;
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/cards/gw_select_row.dart';
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/dev/dev_mock_child_wallets.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/wallet_utils.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:hive_ce_flutter/hive_flutter.dart';
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
  // Tall enough by default that every row, however deep, builds inside the
  // viewport rather than needing a scroll per assertion. A caller proving a
  // phone-width layout passes its own, narrower size.
  Size size = const Size(1200, 2000),
}) async {
  tester.view.physicalSize = size;
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
    'threeChildren nests the other own account, merged onto its wallet, '
    'under the running main exactly once',
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

      expect(find.text('Main B'), findsOneWidget);
      final mainBRow = find.ancestor(
        of: find.text('Main B'),
        matching: find.byType(GWSelectRow),
      );
      expect(_leftIndentOf(tester, mainBRow), 24.0);

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

  group('collapsible mains', () {
    testWidgets(
      'a main starts expanded with a Hide children chevron; tapping hides '
      'its subtree and flips to Show children; tapping again restores it, '
      'without changing the active wallet',
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

        expect(find.byTooltip('Hide children'), findsOneWidget);
        expect(find.byType(ChildWalletRow), findsOneWidget);

        await tester.tap(find.byTooltip('Hide children'));
        await tester.pumpAndSettle();

        expect(find.byType(ChildWalletRow), findsNothing);
        expect(find.byTooltip('Show children'), findsOneWidget);
        expect(bloc.state.selectedSDKAccount, _mainA);

        await tester.tap(find.byTooltip('Show children'));
        await tester.pumpAndSettle();

        expect(find.byType(ChildWalletRow), findsOneWidget);
        expect(find.byTooltip('Hide children'), findsOneWidget);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets('a leaf row carries no chevron', (tester) async {
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

      // mainB has no children under this preset, so it never gets a chevron.
      final mainBRow = _rowFor(title: 'Unlinked', subtitle: '0xaaaa...2222');
      expect(
        find.descendant(
          of: mainBRow,
          matching: find.byIcon(Icons.chevron_right),
        ),
        findsNothing,
      );
      expect(
        find.descendant(of: mainBRow, matching: find.byIcon(Icons.expand_more)),
        findsNothing,
      );

      await tester.runAsync(() => bloc.close());
      await details.close();
      await operations.close();
    });

    testWidgets('closing and reopening the drawer forgets a collapsed main', (
      tester,
    ) async {
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
      await tester.tap(find.byTooltip('Hide children'));
      await tester.pumpAndSettle();
      expect(find.byType(ChildWalletRow), findsNothing);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pumpAndSettle();
      await tester.tap(find.text('open drawer'));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Hide children'), findsOneWidget);
      expect(find.byType(ChildWalletRow), findsOneWidget);

      await tester.runAsync(() => bloc.close());
      await details.close();
      await operations.close();
    });
  });

  group('nested own row child actions', () {
    const nestMainA = '0xAAAA111111111111111111111111111111AAA1';
    const nestMainB = '0xBBBB222222222222222222222222222222BBB2';

    ChildRegistrations okList(List<String> children, String main) => (
      result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
      entries: [
        for (var i = 0; i < children.length; i++)
          ChildRegistration(
            childAddress: children[i],
            mainAddress: main,
            sequence: i,
          ),
      ],
    );

    Finder accountRow(String address) => _rowFor(
      title: 'Unlinked',
      subtitle: WalletUtils.getAddressForDisplay(address),
    );

    Future<void> openMenu(WidgetTester tester, Finder row) async {
      await tester.tap(
        find.descendant(of: row, matching: find.byTooltip('Account options')),
      );
      await tester.pumpAndSettle();
    }

    Future<(_SeededAppBloc, WalletDetailsCubit, ChildOperationsCubit)>
    pumpNested(
      WidgetTester tester,
      _PerMainApi api, {
      String? selectedSDKAccount = nestMainA,
    }) async {
      final details = WalletDetailsCubit(
        geniusApi: api,
        networkTokensProvider: NetworkTokensProvider(),
      );
      final bloc = _SeededAppBloc(
        api: api,
        transactionsCubit: TransactionsCubit(),
        walletDetailsCubit: details,
        networkProvider: NetworkProvider(),
        sdkAccounts: const [nestMainA, nestMainB],
        wallets: const [],
        sdkAccountLinks: const {},
        selectedSDKAccount: selectedSDKAccount,
      );
      final operations = ChildOperationsCubit(
        api: api,
        readAppState: () => bloc.state,
        devTools: true,
      );
      await _pumpDrawer(tester, bloc, details, operations: operations);
      return (bloc, details, operations);
    }

    testWidgets(
      'B nested under running A gets Fund/Recover/Revoke after a divider',
      (tester) async {
        final api = _PerMainApi(
          registrationsByMain: {
            nestMainA.toLowerCase(): okList([nestMainB], nestMainA),
          },
        );
        final (bloc, details, operations) = await pumpNested(tester, api);

        await openMenu(tester, accountRow(nestMainB));
        expect(find.widgetWithText(MenuItemButton, 'Fund'), findsOneWidget);
        expect(find.widgetWithText(MenuItemButton, 'Recover'), findsOneWidget);
        expect(find.widgetWithText(MenuItemButton, 'Revoke'), findsOneWidget);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets("A's own top-level menu never carries them", (tester) async {
      final api = _PerMainApi(
        registrationsByMain: {
          nestMainA.toLowerCase(): okList([nestMainB], nestMainA),
        },
      );
      final (bloc, details, operations) = await pumpNested(tester, api);

      await openMenu(tester, accountRow(nestMainA));
      expect(find.widgetWithText(MenuItemButton, 'Fund'), findsNothing);
      expect(find.widgetWithText(MenuItemButton, 'Recover'), findsNothing);
      expect(find.widgetWithText(MenuItemButton, 'Revoke'), findsNothing);

      await tester.runAsync(() => bloc.close());
      await details.close();
      await operations.close();
    });

    testWidgets(
      'Fund on B submits through the registry with main A; the pending badge '
      "shows under B's row, locking Fund and Recover with the same reason",
      (tester) async {
        final api = _PerMainApi(
          registrationsByMain: {
            nestMainA.toLowerCase(): okList([nestMainB], nestMainA),
          },
        );
        final (bloc, details, operations) = await pumpNested(tester, api);

        await openMenu(tester, accountRow(nestMainB));
        await tester.tap(find.widgetWithText(MenuItemButton, 'Fund'));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField), '1.5');
        await tester.tap(find.widgetWithText(GWButton, 'Fund'));
        await tester.pumpAndSettle();

        expect(api.fundCalls, [nestMainB]);
        expect(find.text('Funding 1.5 GNUS…'), findsOneWidget);

        await openMenu(tester, accountRow(nestMainB));
        final fundItem = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, 'Fund'),
        );
        final recoverItem = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, 'Recover'),
        );
        expect(fundItem.onPressed, isNull);
        expect(recoverItem.onPressed, isNull);
        expect(find.byTooltip('Already funding this child'), findsWidgets);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      "Revoke locks independently, with its own reason, while a revoke on "
      'B is pending',
      (tester) async {
        final api = _PerMainApi(
          registrationsByMain: {
            nestMainA.toLowerCase(): okList([nestMainB], nestMainA),
          },
        );
        final (bloc, details, operations) = await pumpNested(tester, api);

        operations.submit(
          kind: ChildOperationKind.revoke,
          target: nestMainB,
          main: nestMainA,
        );
        await tester.pumpAndSettle();

        await openMenu(tester, accountRow(nestMainB));
        final revokeItem = tester.widget<MenuItemButton>(
          find.widgetWithText(MenuItemButton, 'Revoke'),
        );
        expect(revokeItem.onPressed, isNull);
        expect(find.byTooltip('Already revoking this child'), findsOneWidget);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'running as B, Fund on B opens the switch dialog naming A, not B',
      (tester) async {
        final api = _PerMainApi(
          registrationsByMain: {
            nestMainA.toLowerCase(): okList([nestMainB], nestMainA),
          },
        );
        final (bloc, details, operations) = await pumpNested(
          tester,
          api,
          selectedSDKAccount: nestMainB,
        );

        await openMenu(tester, accountRow(nestMainB));
        await tester.tap(find.widgetWithText(MenuItemButton, 'Fund'));
        await tester.pumpAndSettle();

        final mainLabel = WalletUtils.getAddressForDisplay(nestMainA);
        expect(find.text('Switch to $mainLabel?'), findsOneWidget);
        expect(api.selectCalls, isEmpty);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );
  });

  group('live refresh and phone width', () {
    testWidgets(
      'a revoke that resolves after the simulated write lands removes its '
      'row from the still-open drawer, with no reopen',
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
        expect(find.byType(ChildWalletRow), findsOneWidget);

        await tester.tap(find.byTooltip('Child actions'));
        await tester.pumpAndSettle();
        await tester.tap(find.widgetWithText(MenuItemButton, 'Revoke'));
        await tester.pumpAndSettle();
        await tester.tap(
          find.descendant(
            of: find.byType(GWDialog),
            matching: find.widgetWithText(GWButton, 'Revoke'),
          ),
        );
        await tester.pumpAndSettle();

        // Not yet -- the simulated write hasn't landed.
        expect(find.byType(ChildWalletRow), findsOneWidget);

        // The registry's own 3 s write lands, then resolve() reads the now
        // real removal -- the drawer never closed for any of this.
        await tester.pump(const Duration(seconds: 3));
        operations.resolve();
        await tester.pumpAndSettle();

        expect(find.byType(ChildWalletRow), findsNothing);

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );

    testWidgets(
      'a four-deep own-account chain fits 360px wide with no overflow; the '
      "deepest main's indent matches its own child's",
      (tester) async {
        const mainA = '0xAAAA111111111111111111111111111111AAA1';
        const mainB = '0xBBBB222222222222222222222222222222BBB2';
        const mainC = '0xCCCC333333333333333333333333333333CCC3';
        const mainD = '0xDDDD444444444444444444444444444444DDD4';

        Wallet wallet(String name, String address) => Wallet(
          coinType: TWCoinType.TWCoinTypeEthereum,
          walletName: name,
          currencySymbol: 'ETH',
          walletType: WalletType.privateKey,
          balance: 0,
          address: address,
        );
        final walletA = wallet('Main A', mainA);
        final walletB = wallet('Main B', mainB);
        final walletC = wallet('Main C', mainC);
        final walletD = wallet('Main D', mainD);
        // Keys and `walletAddress` values are matched lowercased by
        // `AppBloc.linkedWallet` -- this fixture's addresses are mixed case
        // (so an address alone tells the four rows apart), so both sides are
        // lowercased explicitly here.
        final links = <String, SDKAccountLink>{
          mainA.toLowerCase(): (
            walletAddress: mainA.toLowerCase(),
            walletName: 'Main A',
          ),
          mainB.toLowerCase(): (
            walletAddress: mainB.toLowerCase(),
            walletName: 'Main B',
          ),
          mainC.toLowerCase(): (
            walletAddress: mainC.toLowerCase(),
            walletName: 'Main C',
          ),
          mainD.toLowerCase(): (
            walletAddress: mainD.toLowerCase(),
            walletName: 'Main D',
          ),
        };
        ChildRegistrations regs(String child, String main) => (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: [
            ChildRegistration(
              childAddress: child,
              mainAddress: main,
              sequence: 0,
            ),
          ],
        );
        final api = _PerMainApi(
          registrationsByMain: {
            mainA.toLowerCase(): regs(mainB, mainA),
            mainB.toLowerCase(): regs(mainC, mainB),
            mainC.toLowerCase(): regs(mainD, mainC),
          },
        );
        final details = WalletDetailsCubit(
          geniusApi: api,
          networkTokensProvider: NetworkTokensProvider(),
        );
        // In-memory box: `selectWallet` persists the pick with one Hive
        // write, same setup account_drawer_show_test.dart's harness uses.
        final box = await Hive.openBox(walletBoxName, bytes: Uint8List(0));
        addTearDown(() => box.close());
        await details.selectWallet(walletC);
        final bloc = _SeededAppBloc(
          api: api,
          transactionsCubit: TransactionsCubit(),
          walletDetailsCubit: details,
          networkProvider: NetworkProvider(),
          sdkAccounts: const [mainA, mainB, mainC, mainD],
          wallets: [walletA, walletB, walletC, walletD],
          sdkAccountLinks: links,
          selectedSDKAccount: mainC,
        );
        final operations = ChildOperationsCubit(
          api: api,
          readAppState: () => bloc.state,
          devTools: true,
        );

        await _pumpDrawer(
          tester,
          bloc,
          details,
          operations: operations,
          size: const Size(360, 800),
        );

        expect(tester.takeException(), isNull);

        Finder rowFor(String name) => find.ancestor(
          of: find.text(name),
          matching: find.byType(GWSelectRow),
        );
        final rowA = rowFor('Main A');
        final rowB = rowFor('Main B');
        final rowC = rowFor('Main C');
        final rowD = rowFor('Main D');
        for (final row in [rowA, rowB, rowC, rowD]) {
          expect(row, findsOneWidget);
          expect(tester.getRect(row).right, lessThanOrEqualTo(360.0));
        }
        expect(_leftIndentOf(tester, rowD), _leftIndentOf(tester, rowC));

        expect(
          find.descendant(of: rowC, matching: find.text('Selected')),
          findsOneWidget,
        );
        expect(
          find.descendant(of: rowC, matching: find.text('On node')),
          findsOneWidget,
        );

        await tester.runAsync(() => bloc.close());
        await details.close();
        await operations.close();
      },
    );
  });
}

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
/// Registrations differ PER MAIN, unlike [DevMockChildWallets] (which only
/// ever nests under the running account) -- needed to prove a nested own
/// row's menu with the node running as either side of the registered pair.
class _PerMainApi implements GeniusApi {
  _PerMainApi({this.registrationsByMain = const {}});

  final Map<String, ChildRegistrations> registrationsByMain;

  String? _selected;
  final fundCalls = <String>[];
  final revokeCalls = <String>[];
  final selectCalls = <String>[];

  static const _emptyRegistrations = (
    result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    entries: <ChildRegistration>[],
  );

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) =>
      registrationsByMain[mainAddress.toLowerCase()] ?? _emptyRegistrations;

  @override
  BigInt getChildBalanceAll(String childAddress) => BigInt.zero;

  // Comfortably above every amount the Fund dialog test submits.
  @override
  String getMinionsBalance([String? tokenId]) => '1000000000';

  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) {
    fundCalls.add(childAddress);
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  GeniusNodeReturnValue revokeChild(String childAddress) {
    revokeCalls.add(childAddress);
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  String? getSelectedAccountAddress() => _selected;

  @override
  Future<GeniusNodeReturnValue> selectGeniusAccountAsync(
    String publicAddress,
  ) async {
    selectCalls.add(publicAddress);
    _selected = publicAddress;
    return GeniusNodeReturnValue.GENIUS_NODE_RET_OK;
  }

  @override
  String? getSelectedAccountMnemonic() => null;

  @override
  List<String> getAvailableAccounts() => const [];

  @override
  Future<Map<String, SDKAccountLink>> getSDKAccountLinks() async => const {};

  @override
  Stream<SGNUSConnection> getSGNUSConnectionStream() =>
      Stream.value(SGNUSConnection.empty());

  @override
  String? getStartAccountAddress() => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
