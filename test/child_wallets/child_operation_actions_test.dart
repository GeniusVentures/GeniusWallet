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
import 'package:genius_wallet/components/overlays/gw_dialog.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _mainAddress = '0x1111111111111111111111111111111111aaaa';
const _childAddress = '0x2222222222222222222222222222222222bbbb';
const _secondChildAddress = '0x4444444444444444444444444444444444dddd';
const _parentAddress = '0x6666666666666666666666666666666666eeee';
const _newMainAddress = '0x8888888888888888888888888888888888ffff';

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

const _parentWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Parent Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _parentAddress,
);

/// Lists [_parentAddress] as a second own account -- the "This account"
/// card's Detach flow needs a parent for the running account to detach from.
const _withParentAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress, _parentAddress],
  wallets: [_mainWallet, _childWallet, _parentWallet],
  sdkAccountLinks: {
    _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
    _childAddress: (walletAddress: _childAddress, walletName: 'Game Wallet'),
    _parentAddress: (
      walletAddress: _parentAddress,
      walletName: 'Parent Wallet',
    ),
  },
);

const _newMainWallet = Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'New Main Wallet',
  currencySymbol: 'ETH',
  walletType: WalletType.privateKey,
  balance: 0,
  address: _newMainAddress,
);

/// A third own account, alongside [_parentAddress] -- Move's picker needs
/// somewhere else to move to besides the account's current main.
const _withTwoOwnMainsAppState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress, _parentAddress, _newMainAddress],
  wallets: [_mainWallet, _childWallet, _parentWallet, _newMainWallet],
  sdkAccountLinks: {
    _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
    _childAddress: (walletAddress: _childAddress, walletName: 'Game Wallet'),
    _parentAddress: (
      walletAddress: _parentAddress,
      walletName: 'Parent Wallet',
    ),
    _newMainAddress: (
      walletAddress: _newMainAddress,
      walletName: 'New Main Wallet',
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
/// [registrations] answers a read for [_mainAddress] itself (the children
/// list this screen shows); [otherRegistrations] answers a read for any
/// other own account, by lowercased address -- the "This account" card's
/// parent-main lookup and a Detach's own resolve read.
class _FakeApi implements GeniusApi {
  _FakeApi({
    this.registrations = _registrations,
    this.fundResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.recoverResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.revokeResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.detachResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.registerResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.moveResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
    this.otherRegistrations = const {},
  });

  // Mutable so a revoke/detach test can prove its resolve reads a later
  // list, not the one captured at submission.
  ChildRegistrations registrations;
  Map<String, ChildRegistrations> otherRegistrations;
  final GeniusNodeReturnValue fundResult;
  final GeniusNodeReturnValue recoverResult;
  final GeniusNodeReturnValue revokeResult;
  final GeniusNodeReturnValue detachResult;
  final GeniusNodeReturnValue registerResult;
  final GeniusNodeReturnValue moveResult;
  final Map<String, BigInt> balances = {};
  String? lastFundedAmount;
  String? lastFundedChild;
  String? lastRecoveredAmount;
  String? lastRecoveredChild;
  String? lastRevokedChild;
  ChildRegistrationMetadata? lastDetachMetadata;
  String? lastRegisteredMain;
  ChildRegistrationMetadata? lastRegisteredMetadata;
  String? lastMoveNewMain;
  ChildRegistrationMetadata? lastMoveMetadata;
  int fundCallCount = 0;
  int recoverCallCount = 0;
  int revokeCallCount = 0;
  int detachCallCount = 0;
  int registerCallCount = 0;
  int moveCallCount = 0;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) {
    if (mainAddress.toLowerCase() == _mainAddress.toLowerCase()) {
      return registrations;
    }
    return otherRegistrations[mainAddress.toLowerCase()] ??
        const (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: <ChildRegistration>[],
        );
  }

  @override
  BigInt getChildBalance(String childAddress, {String? tokenId}) =>
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
  GeniusNodeReturnValue detachChild(ChildRegistrationMetadata metadata) {
    detachCallCount++;
    lastDetachMetadata = metadata;
    return detachResult;
  }

  @override
  GeniusNodeReturnValue registerChild(
    String mainAddress,
    ChildRegistrationMetadata metadata,
  ) {
    registerCallCount++;
    lastRegisteredMain = mainAddress;
    lastRegisteredMetadata = metadata;
    return registerResult;
  }

  @override
  GeniusNodeReturnValue replaceMain(
    String newMainAddress,
    ChildRegistrationMetadata metadata,
  ) {
    moveCallCount++;
    lastMoveNewMain = newMainAddress;
    lastMoveMetadata = metadata;
    return moveResult;
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
    expect(find.text("Couldn't fund this child."), findsOneWidget);
    expect(find.text('Funding 1.5 GNUS…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'Fund, Recover and Revoke lock while a fund is pending, stay locked with '
    'a plain reason once it is not confirmed, and release once it expires',
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

      MenuItemButton item(String label) => tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, label),
      );

      operations.submit(
        kind: ChildOperationKind.fund,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      await tester.pump();
      await _openMenu(tester);
      expect(item('Fund').onPressed, isNull);
      expect(item('Recover').onPressed, isNull);
      expect(item('Revoke').onPressed, isNull);
      expect(find.byTooltip('Already funding this child'), findsNWidgets(3));
      await _openMenu(tester);

      now = submittedAt.add(const Duration(minutes: 2));
      operations.resolve();
      await tester.pump();
      await _openMenu(tester);
      expect(item('Fund').onPressed, isNull);
      expect(item('Recover').onPressed, isNull);
      expect(
        find.byTooltip(
          "An earlier transfer for this child hasn't confirmed yet. Check "
          'again, or wait a few minutes.',
        ),
        findsNWidgets(3),
      );
      await _openMenu(tester);

      now = submittedAt.add(const Duration(minutes: 6));
      operations.resolve();
      await tester.pump();
      await _openMenu(tester);
      expect(item('Fund').onPressed, isNotNull);
      expect(item('Recover').onPressed, isNotNull);
      expect(item('Revoke').onPressed, isNotNull);
      expect(find.text('Funded 1 GNUS to Game Wallet'), findsNothing);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('the poll alone keeps a timed-out fund locked, unlocks Fund and '
      'Recover once it expires, and then stops', (tester) async {
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

    MenuItemButton item(String label) => tester.widget<MenuItemButton>(
      find.widgetWithText(MenuItemButton, label),
    );

    // Moves the injected clock and the fake timers together, one poll tick
    // at a time, so every tick reads the time it fires at.
    Future<void> pollUntil(Duration elapsed) async {
      while (now.isBefore(submittedAt.add(elapsed))) {
        now = now.add(const Duration(seconds: 10));
        await tester.pump(const Duration(seconds: 10));
      }
    }

    operations.submit(
      kind: ChildOperationKind.fund,
      target: _childAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(1000000),
    );

    await pollUntil(const Duration(minutes: 2));
    expect(operations.state.operations.single.notConfirmed, isTrue);
    await _openMenu(tester);
    expect(item('Fund').onPressed, isNull);
    expect(item('Recover').onPressed, isNull);
    await _openMenu(tester);

    await pollUntil(const Duration(minutes: 6));
    expect(operations.state.operations.single.expired, isTrue);
    await _openMenu(tester);
    expect(item('Fund').onPressed, isNotNull);
    expect(item('Recover').onPressed, isNotNull);
    await _openMenu(tester);

    // The registry is left open on purpose: a poll still running after
    // expiry fails this test as a Timer pending past the widget tree.
    await childWallets.close();
  });

  testWidgets('Check again resolves once the balance has actually risen, '
      'and unlocks Fund', (tester) async {
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

    // Landed, so the child is free for the next fund.
    await _openMenu(tester);
    expect(
      tester
          .widget<MenuItemButton>(find.widgetWithText(MenuItemButton, 'Fund'))
          .onPressed,
      isNotNull,
    );

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'a recover starting while the Fund dialog is open disables Fund and says '
    'why, with no SDK call',
    (tester) async {
      final api = _FakeApi();
      api.balances[_childAddress] = BigInt.from(3000000);
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
      );

      await _openFundDialog(tester);
      operations.submit(
        kind: ChildOperationKind.recover,
        target: _childAddress,
        main: _mainAddress,
        amountMinions: BigInt.from(1000000),
      );
      await tester.pumpAndSettle();

      expect(find.text('Already recovering from this child'), findsOneWidget);
      final fund = tester.widget<GWButton>(
        find.widgetWithText(GWButton, 'Fund'),
      );
      expect(fund.onPressed, isNull);
      expect(api.fundCallCount, 0);

      await childWallets.close();
      await operations.close();
    },
  );

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
    expect(find.text("Couldn't recover from this child."), findsOneWidget);
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
    expect(find.text("Couldn't revoke this child."), findsOneWidget);
    expect(find.text('Revoking…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'a pending Revoke locks Fund and Recover on that child too, with its '
    'reason',
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
      expect(find.byTooltip('Already revoking this child'), findsNWidgets(3));

      final fundItem = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Fund'),
      );
      final recoverItem = tester.widget<MenuItemButton>(
        find.widgetWithText(MenuItemButton, 'Recover'),
      );
      expect(fundItem.onPressed, isNull);
      expect(recoverItem.onPressed, isNull);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets(
    'Detach confirms the exact copy, sends empty metadata, and resolves '
    'once the old main no longer lists the subject, then toasts once',
    (tester) async {
      final api = _FakeApi(
        otherRegistrations: {
          _parentAddress.toLowerCase(): (
            result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
            entries: const [
              ChildRegistration(
                childAddress: _mainAddress,
                mainAddress: _parentAddress,
                sequence: 0,
              ),
            ],
          ),
        },
      );
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
        appState: _withParentAppState,
      );

      expect(find.text('Child of Parent Wallet'), findsOneWidget);
      await tester.tap(find.widgetWithText(GWButton, 'Detach'));
      await tester.pumpAndSettle();

      expect(find.text('Detach from main?'), findsOneWidget);
      expect(
        find.text(
          'Detach from Parent Wallet? Main Wallet will no longer be a '
          'child of Parent Wallet.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(GWDialog),
          matching: find.widgetWithText(GWButton, 'Detach'),
        ),
      );
      await tester.pumpAndSettle();

      expect(api.detachCallCount, 1);
      expect(api.lastDetachMetadata, const ChildRegistrationMetadata());
      expect(find.text('Detaching…'), findsOneWidget);

      // The real signal: an OK read of the old main no longer lists the
      // subject.
      api.otherRegistrations = {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const <ChildRegistration>[],
        ),
      };
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Detaching…'), findsNothing);
      expect(find.text('Detached from Parent Wallet'), findsOneWidget);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('a refused Detach shows the reason and never shows a badge', (
    tester,
  ) async {
    final api = _FakeApi(
      detachResult: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
      otherRegistrations: {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _parentAddress,
              sequence: 0,
            ),
          ],
        ),
      },
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withParentAppState,
    );

    await tester.tap(find.widgetWithText(GWButton, 'Detach'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(GWDialog),
        matching: find.widgetWithText(GWButton, 'Detach'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.detachCallCount, 1);
    expect(find.text("Couldn't detach this account."), findsOneWidget);
    expect(find.text('Detaching…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a pending Detach locks Detach and Move, tooltipped', (
    tester,
  ) async {
    final api = _FakeApi(
      otherRegistrations: {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _parentAddress,
              sequence: 0,
            ),
          ],
        ),
      },
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withParentAppState,
    );

    operations.submit(
      kind: ChildOperationKind.detach,
      target: _mainAddress,
      main: _parentAddress,
    );
    await tester.pumpAndSettle();

    final detachButton = tester.widget<GWButton>(
      find.widgetWithText(GWButton, 'Detach'),
    );
    expect(detachButton.onPressed, isNull);
    expect(find.byTooltip('Already detaching this account'), findsNWidgets(2));

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'Register picks a main from the picker, sends empty metadata, and '
    'resolves once the chosen main lists the subject, then toasts once',
    (tester) async {
      final api = _FakeApi();
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
        appState: _withParentAppState,
      );

      await tester.tap(
        find.widgetWithText(GWButton, 'Register as a child of…'),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Parent Wallet'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GWButton, 'Continue'));
      await tester.pumpAndSettle();
      await tester.tap(
        find.descendant(
          of: find.byType(GWDialog),
          matching: find.widgetWithText(GWButton, 'Register'),
        ),
      );
      await tester.pumpAndSettle();

      expect(api.registerCallCount, 1);
      expect(api.lastRegisteredMain, _parentAddress);
      expect(api.lastRegisteredMetadata, const ChildRegistrationMetadata());
      expect(find.text('Registering…'), findsOneWidget);

      // The real signal: an OK read of the chosen main now lists the
      // subject.
      api.otherRegistrations = {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _parentAddress,
              sequence: 0,
            ),
          ],
        ),
      };
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Registering…'), findsNothing);
      expect(
        find.text('Registered as a child of Parent Wallet'),
        findsOneWidget,
      );

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('a refused Register shows the reason and never shows a badge', (
    tester,
  ) async {
    final api = _FakeApi(
      registerResult: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withParentAppState,
    );

    await tester.tap(find.widgetWithText(GWButton, 'Register as a child of…'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Parent Wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GWButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(GWDialog),
        matching: find.widgetWithText(GWButton, 'Register'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.registerCallCount, 1);
    expect(find.text("Couldn't register this account."), findsOneWidget);
    expect(find.text('Registering…'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a pending Register locks the card button, tooltipped', (
    tester,
  ) async {
    final api = _FakeApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withParentAppState,
    );

    operations.submit(
      kind: ChildOperationKind.register,
      target: _mainAddress,
      main: _parentAddress,
    );
    await tester.pumpAndSettle();

    final registerButton = tester.widget<GWButton>(
      find.widgetWithText(GWButton, 'Register as a child of…'),
    );
    expect(registerButton.onPressed, isNull);
    expect(find.byTooltip('Already registering this account'), findsOneWidget);

    await childWallets.close();
    await operations.close();
  });

  testWidgets(
    'Move picks a new main from the picker, excluding this account and its '
    'current main, confirms with the warning note, and resolves once both '
    'halves land, then toasts once',
    (tester) async {
      final api = _FakeApi(
        otherRegistrations: {
          _parentAddress.toLowerCase(): (
            result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
            entries: const [
              ChildRegistration(
                childAddress: _mainAddress,
                mainAddress: _parentAddress,
                sequence: 0,
              ),
            ],
          ),
          _newMainAddress.toLowerCase(): (
            result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
            entries: const <ChildRegistration>[],
          ),
        },
      );
      final navigatorKey = GlobalKey<NavigatorState>();
      final (childWallets, operations) = await _pumpScreen(
        tester,
        api: api,
        navigatorKey: navigatorKey,
        appState: _withTwoOwnMainsAppState,
      );

      expect(find.text('Child of Parent Wallet'), findsOneWidget);
      await tester.tap(find.widgetWithText(GWButton, 'Move to another main'));
      await tester.pumpAndSettle();

      // The picker excludes this account (never offered) and its current
      // main (already the relationship being moved away from) -- scoped to
      // the dialog, since the card behind it still names both.
      final pickerRows = find.descendant(
        of: find.byType(GWDialog),
        matching: find.text('Main Wallet'),
      );
      final pickerParentRow = find.descendant(
        of: find.byType(GWDialog),
        matching: find.text('Parent Wallet'),
      );
      expect(pickerRows, findsNothing);
      expect(pickerParentRow, findsNothing);
      expect(find.text('New Main Wallet'), findsOneWidget);

      await tester.tap(find.text('New Main Wallet'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(GWButton, 'Continue'));
      await tester.pumpAndSettle();

      expect(find.text('Move to another main?'), findsOneWidget);
      expect(
        find.text(
          'Move to New Main Wallet? Main Wallet will no longer be a child '
          'of Parent Wallet.',
        ),
        findsOneWidget,
      );
      expect(
        find.text(
          'The child keeps its current balance; nothing is transferred by '
          'this action.',
        ),
        findsOneWidget,
      );
      await tester.tap(
        find.descendant(
          of: find.byType(GWDialog),
          matching: find.widgetWithText(GWButton, 'Move'),
        ),
      );
      await tester.pumpAndSettle();

      expect(api.moveCallCount, 1);
      expect(api.lastMoveNewMain, _newMainAddress);
      expect(api.lastMoveMetadata, const ChildRegistrationMetadata());
      expect(find.text('Moving to New Main Wallet…'), findsOneWidget);
      // Still the list-based truth until the real signal lands -- the new
      // main is never claimed early.
      expect(find.text('Child of Parent Wallet'), findsOneWidget);

      // The real signal: the old main no longer lists it, the new main now
      // does.
      api.otherRegistrations = {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const <ChildRegistration>[],
        ),
        _newMainAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _newMainAddress,
              sequence: 0,
            ),
          ],
        ),
      };
      await tester.tap(find.byTooltip('Refresh'));
      await tester.pumpAndSettle();

      expect(find.text('Moving to New Main Wallet…'), findsNothing);
      expect(find.text('Moved to New Main Wallet'), findsOneWidget);

      await childWallets.close();
      await operations.close();
    },
  );

  testWidgets('a refused Move shows the reason and never shows a badge', (
    tester,
  ) async {
    final api = _FakeApi(
      moveResult: GeniusNodeReturnValue.GENIUS_NODE_INVALID_ARGUMENT,
      otherRegistrations: {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _parentAddress,
              sequence: 0,
            ),
          ],
        ),
      },
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withTwoOwnMainsAppState,
    );

    await tester.tap(find.widgetWithText(GWButton, 'Move to another main'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('New Main Wallet'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(GWButton, 'Continue'));
    await tester.pumpAndSettle();
    await tester.tap(
      find.descendant(
        of: find.byType(GWDialog),
        matching: find.widgetWithText(GWButton, 'Move'),
      ),
    );
    await tester.pumpAndSettle();

    expect(api.moveCallCount, 1);
    expect(find.text("Couldn't move this account."), findsOneWidget);
    expect(find.textContaining('Moving to'), findsNothing);

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a pending Move locks Move and Detach, tooltipped', (
    tester,
  ) async {
    final api = _FakeApi(
      otherRegistrations: {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _parentAddress,
              sequence: 0,
            ),
          ],
        ),
      },
    );
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withTwoOwnMainsAppState,
    );

    operations.submit(
      kind: ChildOperationKind.move,
      target: _mainAddress,
      main: _parentAddress,
      newMain: _newMainAddress,
    );
    await tester.pumpAndSettle();

    final moveButton = tester.widget<GWButton>(
      find.widgetWithText(GWButton, 'Move to another main'),
    );
    expect(moveButton.onPressed, isNull);
    expect(find.byTooltip('Already moving this account'), findsNWidgets(2));

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a child with two kinds pending shows both badges, not just the '
      'newest', (tester) async {
    var now = DateTime(2024);
    final api = _FakeApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      now: () => now,
    );

    // A pending revoke locks Fund, so the revoke expires first.
    operations.submit(
      kind: ChildOperationKind.revoke,
      target: _childAddress,
      main: _mainAddress,
    );
    now = now.add(childOperationTimeout * 3);
    operations.resolve();
    operations.submit(
      kind: ChildOperationKind.fund,
      target: _childAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(1000000),
    );
    await tester.pumpAndSettle();

    expect(find.text('Funding 1 GNUS…'), findsOneWidget);
    expect(find.text('Not confirmed yet'), findsOneWidget);

    await childWallets.close();
    await operations.close();
  });

  testWidgets('the card with two kinds pending shows both badges, not just '
      'the newest', (tester) async {
    final api = _FakeApi(
      otherRegistrations: {
        _parentAddress.toLowerCase(): (
          result: GeniusNodeReturnValue.GENIUS_NODE_RET_OK,
          entries: const [
            ChildRegistration(
              childAddress: _mainAddress,
              mainAddress: _parentAddress,
              sequence: 0,
            ),
          ],
        ),
      },
    );
    var now = DateTime(2024);
    final navigatorKey = GlobalKey<NavigatorState>();
    final (childWallets, operations) = await _pumpScreen(
      tester,
      api: api,
      navigatorKey: navigatorKey,
      appState: _withTwoOwnMainsAppState,
      now: () => now,
    );

    // A pending detach locks Move, so the detach times out first.
    operations.submit(
      kind: ChildOperationKind.detach,
      target: _mainAddress,
      main: _parentAddress,
    );
    now = now.add(childOperationTimeout * 3);
    operations.resolve();
    operations.submit(
      kind: ChildOperationKind.move,
      target: _mainAddress,
      main: _parentAddress,
      newMain: _newMainAddress,
    );
    await tester.pumpAndSettle();

    expect(find.text('Not confirmed yet'), findsOneWidget);
    expect(find.text('Moving to New Main Wallet…'), findsOneWidget);

    await childWallets.close();
    await operations.close();
  });

  testWidgets('a resolution before the root navigator attaches still toasts '
      'once it does', (tester) async {
    final api = _FakeApi();
    final navigatorKey = GlobalKey<NavigatorState>();
    final operations = ChildOperationsCubit(
      api: api,
      readAppState: () => _appState,
    );
    final attached = ValueNotifier(false);
    addTearDown(attached.dispose);

    await tester.pumpWidget(
      BlocProvider<ChildOperationsCubit>.value(
        value: operations,
        child: ChildOperationToasts(
          navigatorKey: navigatorKey,
          child: ValueListenableBuilder<bool>(
            valueListenable: attached,
            builder: (_, isAttached, _) => isAttached
                ? MaterialApp(
                    navigatorKey: navigatorKey,
                    theme: ThemeData(extensions: [GWColors.dark()]),
                    home: const SizedBox(),
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );

    operations.submit(
      kind: ChildOperationKind.fund,
      target: _childAddress,
      main: _mainAddress,
      amountMinions: BigInt.from(1000000),
    );
    api.balances[_childAddress] = BigInt.from(1000000);
    operations.resolve();
    await tester.pump();
    expect(operations.state.justResolved, hasLength(1));

    attached.value = true;
    await tester.pumpAndSettle();

    expect(find.text('Funded 1 GNUS to Game Wallet'), findsOneWidget);

    await operations.close();
  });
}
