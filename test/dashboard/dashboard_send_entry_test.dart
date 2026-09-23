// The dashboard entry point: a Send button on the Assets panel that opens
// the coin picker (`/send` with no extra), gated on holding SOMETHING on a
// network the wallet can actually sign on.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/network.dart';
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

/// `canSignOn` refuses this one: no `rpcUrl`.
const _noRpc = Network(name: 'No RPC', symbol: 'eth', chainId: 1);

Coin _coin(String symbol, {required double balance}) =>
    Coin(name: symbol, symbol: symbol, iconPath: '', balance: balance);

WalletDetailsCubit _cubit({required List<Coin> coins, Network? network}) =>
    WalletDetailsCubit(
      initialState: WalletDetailsState(
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
  testWidgets('a funded, signable wallet shows Send and reaches /send bare', (
    tester,
  ) async {
    final cubit = _cubit(coins: [_coin('USDC', balance: 10)], network: _amoy);
    final pushed = <Object?>[];

    await tester.pumpWidget(_routedHost(cubit, pushed));
    await tester.pump();

    expect(find.widgetWithText(GWButton, 'Send'), findsOneWidget);

    await tester.tap(find.widgetWithText(GWButton, 'Send'));
    await tester.pumpAndSettle();

    expect(pushed, [null]);
  });

  testWidgets('a network with no rpcUrl shows no Send', (tester) async {
    final cubit = _cubit(coins: [_coin('USDC', balance: 10)], network: _noRpc);

    await tester.pumpWidget(_routedHost(cubit, []));
    await tester.pump();

    expect(find.widgetWithText(GWButton, 'Send'), findsNothing);
  });

  testWidgets('all-zero balances show no Send', (tester) async {
    final cubit = _cubit(coins: [_coin('USDC', balance: 0)], network: _amoy);

    await tester.pumpWidget(_routedHost(cubit, []));
    await tester.pump();

    expect(find.widgetWithText(GWButton, 'Send'), findsNothing);
  });

  testWidgets('the picker reuse (onCoinSelected set) never shows Send', (
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

    expect(find.widgetWithText(GWButton, 'Send'), findsNothing);
  });
}
