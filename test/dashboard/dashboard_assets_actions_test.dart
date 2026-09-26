// The dashboard Assets panel offers Receive and Buy GNUS for every wallet,
// funded or not; sending starts from a token's own page, not from here.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/ffi/trust_wallet_api_ffi.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi, Wallet;
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
import 'package:genius_api/types/wallet_type.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';

/// [WalletDetailsCubit] takes a [GeniusApi] `CoinsScreen` only touches
/// through `getCoins()`, which nothing here triggers -- same stand-in
/// `dashboard_section_caps_test.dart` uses.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

const _amoy = Network(
  name: 'Polygon Amoy',
  symbol: 'matic',
  chainId: 80002,
  rpcUrl: 'https://rpc.invalid',
);

Wallet _walletOf(WalletType type) => Wallet(
  coinType: TWCoinType.TWCoinTypeEthereum,
  walletName: 'Test Wallet',
  currencySymbol: 'MATIC',
  walletType: type,
  balance: 0,
  address: '0x1234567890123456789012345678901234567890',
);

Coin _coin(String symbol, {required double balance}) =>
    Coin(name: symbol, symbol: symbol, iconPath: '', balance: balance);

WalletDetailsCubit _cubit({
  required List<Coin> coins,
  Network? network,
  WalletType walletType = WalletType.mnemonic,
}) => WalletDetailsCubit(
  initialState: WalletDetailsState(
    selectedWallet: _walletOf(walletType),
    coins: coins,
    coinsStatus: WalletStatus.successful,
    selectedNetwork: network,
  ),
  geniusApi: _UnusedApi(),
  networkTokensProvider: NetworkTokensProvider(),
);

/// The dashboard panel, routed: `/send` records whether it was reached and
/// with what extra, so a tap can be proven rather than assumed.
Widget _routedHost(WalletDetailsCubit cubit, List<Object?> pushed) {
  final router = GoRouter(
    initialLocation: '/dashboard',
    routes: [
      GoRoute(
        path: '/dashboard',
        builder: (context, state) => BlocProvider<WalletDetailsCubit>.value(
          value: cubit,
          child: const Scaffold(body: CoinsScreen()),
        ),
      ),
      GoRoute(
        path: '/send',
        builder: (context, state) {
          pushed.add(state.extra);
          return const Scaffold(body: Text('send placeholder'));
        },
      ),
    ],
  );
  return MaterialApp.router(
    theme: ThemeData(extensions: [GWColors.dark()]),
    routerConfig: router,
  );
}

void main() {
  Future<void> pump(WidgetTester tester, WalletDetailsCubit cubit) async {
    await tester.pumpWidget(_routedHost(cubit, []));
    await tester.pump();
  }

  testWidgets('a funded wallet shows Receive and Buy GNUS, and no Send', (
    tester,
  ) async {
    await pump(
      tester,
      _cubit(coins: [_coin('USDC', balance: 10)], network: _amoy),
    );

    expect(find.widgetWithText(GWButton, 'Receive'), findsOneWidget);
    expect(find.widgetWithText(GWButton, 'Buy GNUS'), findsOneWidget);
    expect(find.widgetWithText(GWButton, 'Send'), findsNothing);
  });

  testWidgets('an all-zero wallet shows Receive and Buy GNUS', (tester) async {
    await pump(
      tester,
      _cubit(coins: [_coin('USDC', balance: 0)], network: _amoy),
    );

    expect(find.widgetWithText(GWButton, 'Receive'), findsOneWidget);
    expect(find.widgetWithText(GWButton, 'Buy GNUS'), findsOneWidget);
  });

  testWidgets('the picker reuse (onCoinSelected set) shows no actions', (
    tester,
  ) async {
    final cubit = _cubit(coins: [_coin('USDC', balance: 10)], network: _amoy);

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: BlocProvider<WalletDetailsCubit>.value(
          value: cubit,
          child: Scaffold(body: CoinsScreen(onCoinSelected: (_) {})),
        ),
      ),
    );
    await tester.pump();

    expect(find.widgetWithText(GWButton, 'Receive'), findsNothing);
    expect(find.widgetWithText(GWButton, 'Send'), findsNothing);
  });
}
