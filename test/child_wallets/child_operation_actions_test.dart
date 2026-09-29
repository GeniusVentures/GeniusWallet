// Proves the fund flow end to end through the real screen: row menu -> the
// Fund dialog -> the registry -> a fake SDK write -> the pending badge ->
// resolve() observing a real balance rise -> the one-shot success toast.
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

const _appState = AppState(
  selectedSDKAccount: _mainAddress,
  sdkAccounts: [_mainAddress],
  wallets: [_mainWallet, _childWallet],
  sdkAccountLinks: {
    _mainAddress: (walletAddress: _mainAddress, walletName: 'Main Wallet'),
    _childAddress: (walletAddress: _childAddress, walletName: 'Game Wallet'),
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

/// `implements`, not `extends`: the real constructor dlopens the native SDK.
class _FakeApi implements GeniusApi {
  _FakeApi({this.fundResult = GeniusNodeReturnValue.GENIUS_NODE_RET_OK});

  final GeniusNodeReturnValue fundResult;
  BigInt childBalance = BigInt.zero;
  String? lastFundedAmount;
  String? lastFundedChild;
  int fundCallCount = 0;

  @override
  ChildRegistrations getChildRegistrations(String mainAddress) =>
      _registrations;

  @override
  BigInt getChildBalanceAll(String childAddress) => childBalance;

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
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

/// Pumps the real screen wrapped in [ChildOperationToasts], so a resolved
/// toast is reachable the same way it is in production. Both cubits are
/// returned so a test can close them before it ends.
Future<(ChildWalletsCubit, ChildOperationsCubit)> _pumpScreen(
  WidgetTester tester, {
  required GeniusApi api,
  required GlobalKey<NavigatorState> navigatorKey,
}) async {
  final childWallets = ChildWalletsCubit(
    api: api,
    readAppState: () => _appState,
    mainAddress: _mainAddress,
  );
  final operations = ChildOperationsCubit(
    api: api,
    readAppState: () => _appState,
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
    api.childBalance = BigInt.from(1500000);
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
}
