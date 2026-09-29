// Proves the fund flow end to end through the real screen: row menu -> the
// Fund dialog -> the registry -> a fake SDK write -> the pending badge ->
// resolve() observing a real balance rise -> the one-shot success toast.
// Also proves the per-child lock, "Not confirmed yet" plus "Check again",
// and that the registry keeps working once its screen is gone.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/genius_api_ffi.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/child_wallets/child_operation_status.dart';
import 'package:genius_wallet/child_wallets/child_operations_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_cubit.dart';
import 'package:genius_wallet/child_wallets/child_wallets_screen.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _childAddress = '0x2222222222222222222222222222222222bbbb';
const _secondChildAddress = '0x4444444444444444444444444444444444dddd';

const _mainWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Main Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _mainAddress,
);

const _childWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Game Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _childAddress,
);

const _secondChildWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Second Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _secondChildAddress,
);

const _appState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress],
  wallets: [_mainWallet, _childWallet],
  sdkAccountLinks: {
    _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
    _childAddress: (walletAddress: _childAddress, walletName: 'Game Wallet'),
  },
);

const _twoChildAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress],
  wallets: [_mainWallet, _childWallet, _secondChildWallet],
  sdkAccountLinks: {
    _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
    _childAddress: (walletAddress: _childAddress, walletName: 'Game Wallet'),
    _secondChildAddress: (
      walletAddress: _secondChildAddress,
      walletName: 'Second Wallet',
    ),
  },
);

const _registrations = (
  result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  entries: [
    ChildRegistration(
      childAddress: _childAddress,
      mainAddress: _mainAddress,
      sequence: 0,
    ),
  ],
);

const _twoChildRegistrations = (
  result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  entries: [
    ChildRegistration(
      childAddress: _childAddress,
      mainAddress: _mainAddress,
      sequence: 0,
    ),
    ChildRegistration(
      childAddress: _secondChildAddress,
      mainAddress: _mainAddress,
      sequence: 1,
    ),
  ],
);

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _FakeApi implements GeniusApi {
  _FakeApi({
    this.registrations = _registrations,
    this.fundResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.recoverResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.revokeResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
  });

  // Mutable so a revoke test can prove its resolve reads a later list, not
  // the one captured at submission.
  ChildRegistrations registrations;
  final GeniusNodeReturnValue fundResult;
  final GeniusNodeReturnValue recoverResult;
  final GeniusNodeReturnValue revokeResult;
  final Map<String, BigInt> balances = {};
  String? lastFundedAmount;
  String? lastFundedChild;
  String? lastRecoveredAmount;
  String? lastRecoveredChild;
  String? lastRevokedChild;
  int fundCallCount = 0;
  int recoverCallCount = 0;
  int revokeCallCount = 0;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) => registrations;

  @override
  BigInt getChildBalanceAll(String childAddress) =>
      balances[childAddress] ?? BigInt.zero;

  // Comfortably above every amount these tests type in.
  @override
  String getMinionsBalance([String? tokenId]) => '10000000';

  @override
  GeniusNodeReturnValue fundChildGnus(String amountGnus, String childAddress) {
    fundCallCount++;
    lastFundedAmount = amountGnus;
    lastFundedChild = childAddress;
    return fundResult;
  }

  @override
  GeniusNodeReturnValue recoverFromChildGnus(
    String amountGnus,
    String childAddress,
  ) {
    recoverCallCount++;
    lastRecoveredAmount = amountGnus;
    lastRecoveredChild = childAddress;
    return recoverResult;
  }

  @override
  GeniusNodeReturnValue revokeChild(String childAddress) {
    revokeCallCount++;
    lastRevokedChild = childAddress;
    return revokeResult;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the real screen wrapped in [ChildOperationToasts], so a resolved
/// toast is reachable the same way it is in production. Both cubits are
/// returned so a test can close them before it ends.
Future<(ChildWalletsCubit, ChildOperationsCubit)> _pumpScreen(
  WidgetTester tester, {
  required GeniusApi api,
  required GlobalKey<NavigatorState> navigatorKey,
  AppState appState = _appState,
  DateTime Function() now = DateTime.now,
}) async {
  final childWallets = ChildWalletsCubit(
    api: api,
    readAppState: () => appState,
    mainAddress: _mainAddress,
  );
  final operations = ChildOperationsCubit(
    api: api,
    readAppState: () => appState,
    now: now,
  );

  await tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: MultiBlocProvider(
        providers: [
          BlocProvider<ChildWalletsCubit>.value(value: childWallets),
          BlocProvider<ChildOperationsCubit>.value(value: operations),
        ],
        child: ChildOperationToasts(
          navigatorKey: navigatorKey,
          child: const ChildWalletsScreen(),
        ),
      ),
    ),
  );
  await tester.pump();
  return (childWallets, operations);
}

Future<void> _openFundDialog(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Child actions'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(MenuItemButton, 'Fund'));
  await tester.pumpAndSettle();
}

Future<void> _openRecoverDialog(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Child actions'));
  await tester.pumpAndSettle();
  await tester.tap(find.widgetWithText(MenuItemButton, 'Recover'));
  await tester.pumpAndSettle();
}

Future<void> _openMenu(WidgetTester tester) async {
  await tester.tap(find.byTooltip('Child actions'));
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('fund resolves once the balance really rises, then toasts once', (
    tester,
  ) async {
    final api = _FakeApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
    );

    await _openFundDialog(tester);
    await tester.enterText(find.byType(TextField), '1.5');
    await tester.tap(find.widgetWithText(GWButton, 'Fund'));
    await tester.pumpAndSettle();

    expect(api.fundCallCount, 1);
    expect(api.lastFundedAmount, '1.500000');
    expect(api.lastFundedChild, _childAddress);
    expect(find.text('Funding 1.5 GNUS…'), findsOneWidget);

    // The real signal: the child's balance actually rose by the amount.
    api.balances[_childAddress] = BigInt.from(1500000);
    await tester.tap(find.byTooltip('Refresh'));
    await tester.pumpAndSettle();

    expect(find.text('Funding 1.5 GNUS…'), findsNothing);
    expect(find.text('Funded 1.5 GNUS to Game Wallet'), findsOneWidget);

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a refused fund shows the reason and never shows a badge', (
    tester,
  ) async {
    final api = _FakeApi(
      fundResult: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
    );

    await _openFundDialog(tester);
    await tester.enterText(find.byType(TextField), '1.5');
    await tester.tap(find.widgetWithText(GWButton, 'Fund'));
    await tester.pumpAndSettle();

    expect(api.fundCallCount, 1);
    expect(
      find.text(
        'The SDK refused to fund this child: GENIUS_NODE_INVALID_ARGUMENT',
      ),
      findsOneWidget,
    );
    expect(find.text('Funding 1.5 GNUS…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'the Fund item locks while pending, tooltipped, and releases once not '
    'confirmed',
    (tester) async {
      var now = DateTime(2024);
      final api = _FakeApi();
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
        now: () => now,
      );
      final submittedAt = now;

      operations.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      await tester.pump();
      await tester.tap(find.byTooltip('Child actions'));
      await tester.pumpAndSettle();

      final locked = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Fund'),
      );
      expect(locked.onPressed, isNull);
      expect(find.byTooltip('Already funding this child'), findsOneWidget);

      await tester.tap(find.byTooltip('Child actions'));
      await tester.pumpAndSettle();

      // Timed out: the lock releases even though the balance never moved.
      now = submittedAt.add(const Duration(minutes: 2));
      operations.resolve();
      await tester.pump();
      await tester.tap(find.byTooltip('Child actions'));
      await tester.pumpAndSettle();

      final released = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Fund'),
      );
      expect(released.onPressed, isNotNull);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('Check again resolves once the balance has actually risen', (
    tester,
  ) async {
    var now = DateTime(2024);
    final api = _FakeApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      now: () => now,
    );
    final submittedAt = now;

    operations.submit(
      kind: ChildOperationKind.fund,
      target: _childAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(1000000),
    );
    now = submittedAt.add(const Duration(minutes: 2));
    operations.resolve();
    await tester.pumpAndSettle();

    expect(find.text('Not confirmed yet'), findsOneWidget);

    api.balances[_childAddress] = BigInt.from(1000000);
    await tester.tap(find.widgetWithText(GWButton, 'Check again'));
    await tester.pumpAndSettle();

    expect(find.text('Not confirmed yet'), findsNothing);
    expect(find.text('Funded 1 GNUS to Game Wallet'), findsOneWidget);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'the registry keeps resolving and toasts once its screen is disposed',
    (tester) async {
      final api = _FakeApi();
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
      );

      await _openFundDialog(tester);
      await tester.enterText(find.byType(TextField), '1.5');
      await tester.tap(find.widgetWithText(GWButton, 'Fund'));
      await tester.pumpAndSettle();

      // The screen closing in production: the route holding ChildWalletsScreen
      // is gone, but the registry lives above the router and survives.
      await tester.pumpWidget(
        MaterialApp(
          navigatorKey: navigatorKey,
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: BlocProvider<ChildOperationsCubit>.value(
            value: operations,
            child: ChildOperationToasts(
              navigatorKey: navigatorKey,
              child: const SizedBox(),
            ),
          ),
        ),
      );
      await tester.pump();

      api.balances[_childAddress] = BigInt.from(1500000);
      await tester.pump(const Duration(seconds: 10));
      await tester.pumpAndSettle();

      expect(find.text('Funded 1.5 GNUS to Game Wallet'), findsOneWidget);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('two children pending each show their own badge, independent of '
      'submission order', (tester) async {
    final api = _FakeApi(registrations: _twoChildRegistrations);
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _twoChildAppState,
    );

    // Submitted in reverse of the row order the SDK returns.
    operations.submit(
      kind: ChildOperationKind.fund,
      target: _secondChildAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(2500000),
    );
    operations.submit(
      kind: ChildOperationKind.fund,
      target: _childAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(1000000),
    );
    await tester.pumpAndSettle();

    expect(find.text('Funding 1 GNUS…'), findsOneWidget);
    expect(find.text('Funding 2.5 GNUS…'), findsOneWidget);

    final firstRowTop = tester.getTopLeft(find.text('Game Wallet')).dy;
    final secondRowTop = tester.getTopLeft(find.text('Second Wallet')).dy;
    expect(firstRowTop, lessThan(secondRowTop));

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a pending row lays out without overflow at 320px wide', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    final api = _FakeApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
    );

    operations.submit(
      kind: ChildOperationKind.fund,
      target: _childAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(1500000),
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'recover resolves once the child balance really falls, then toasts once',
    (tester) async {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(2000000);
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
      );

      await _openRecoverDialog(tester);
      expect(find.text('Recover from Game Wallet'), findsOneWidget);
      expect(find.text('From Game Wallet to Main Wallet.'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '1.5');
      await tester.tap(find.widgetWithText(GWButton, 'Recover'));
      await tester.pumpAndSettle();

      expect(api.recoverCallCount, 1);
      expect(api.lastRecoveredAmount, '1.500000');
      expect(api.lastRecoveredChild, _childAddress);
      expect(find.text('Recovering 1.5 GNUS…'), findsOneWidget);

      // The real signal: the child's balance actually fell by the amount.
      api.balances[_childAddress] = BigInt.from(500000);
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Recovering 1.5 GNUS…'), findsNothing);
      expect(find.text('Recovered 1.5 GNUS from Game Wallet'), findsOneWidget);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('a refused recover shows the reason and never shows a badge', (
    tester,
  ) async {
    final api = _FakeApi(
      recoverResult: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
    );
    api.balances[_childAddress] = BigInt.from(2000000);
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
    );

    await _openRecoverDialog(tester);
    await tester.enterText(find.byType(TextField), '1.5');
    await tester.tap(find.widgetWithText(GWButton, 'Recover'));
    await tester.pumpAndSettle();

    expect(api.recoverCallCount, 1);
    expect(
      find.text(
        'The SDK refused to recover from this child: '
        'GENIUS_NODE_INVALID_ARGUMENT',
      ),
      findsOneWidget,
    );
    expect(find.text('Recovering 1.5 GNUS…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'revoke confirms the exact copy and resolves once the child leaves the '
    'list, then toasts once',
    (tester) async {
      final api = _FakeApi();
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
      );

      await _openMenu(tester);
      await tester.tap(find.widgetWithText(MenuItemButton, 'Revoke'));
      await tester.pumpAndSettle();

      expect(find.text('Revoke child?'), findsOneWidget);
      expect(
        find.text(
          'Revoke Game Wallet? It will no longer be a child of '
          'Main Wallet.',
        ),
        findsOneWidget,
      );
      await tester.tap(find.widgetWithText(GWButton, 'Revoke'));
      await tester.pumpAndSettle();

      expect(api.revokeCallCount, 1);
      expect(api.lastRevokedChild, _childAddress);
      expect(find.text('Revoking…'), findsOneWidget);

      // The real signal: an OK read of the main no longer lists the child.
      api.registrations = (
        result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
        entries: const [],
      );
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Revoked Game Wallet'), findsOneWidget);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('a refused revoke shows the reason and never shows a badge', (
    tester,
  ) async {
    final api = _FakeApi(
      revokeResult: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
    );

    await _openMenu(tester);
    await tester.tap(find.widgetWithText(MenuItemButton, 'Revoke'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GWButton, 'Revoke'));
    await tester.pumpAndSettle();

    expect(api.revokeCallCount, 1);
    expect(
      find.text(
        'The SDK refused to revoke this child: GENIUS_NODE_INVALID_ARGUMENT',
      ),
      findsOneWidget,
    );
    expect(find.text('Revoking…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'a pending Revoke locks only Revoke on that child -- Fund and Recover '
    'stay enabled',
    (tester) async {
      final api = _FakeApi();
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
      );

      operations.submit(
        kind: ChildOperationKind.revoke,
        target: _childAddress,
        main: _mainAddress,
      );
      await tester.pump();
      await _openMenu(tester);

      final revokeItem = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Revoke'),
      );
      expect(revokeItem.onPressed, isNull);
      expect(find.byTooltip('Already revoking this child'), findsOneWidget);

      final fundItem = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Fund'),
      );
      final recoverItem = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Recover'),
      );
      expect(fundItem.onPressed, isNotNull);
      expect(recoverItem.onPressed, isNotNull);

      await childWallets.close();
      await operations.close();
    },
  );
}
