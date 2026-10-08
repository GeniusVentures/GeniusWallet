import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dev/dev_mock_holdings.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

/// Swaps the panel's parent at the desktop breakpoint, the way the dashboard
/// does, so crossing it remounts [CoinsScreen] with a fresh State.
class _BreakpointHost extends StatelessWidget {
  const _BreakpointHost();

  @override
  Widget build(BuildContext context) {
    const panel = Expanded(child: CoinsScreen());
    if (MediaQuery.sizeOf(context).width > GeniusBreakpoints.medium) {
      return const Row(children: [panel]);
    }
    return const Column(children: [panel]);
  }
}

void main() {
  testWidgets('prices survive a layout change that remounts the panel', (
    tester,
  ) async {
    final previous = DevMockHoldings.instance.marketData;
    addTearDown(() => DevMockHoldings.instance.marketData = previous);
    // The dev mock path stands in for the network: it is what the fetch
    // resolves to while the cubit is in mock mode.
    DevMockHoldings.instance.marketData = {
      'gnus': CoinGeckoMarketData.fromJson({
        'id': 'genius-ai',
        'symbol': 'gnus',
        'name': 'Genius AI',
        'current_price': 1.41,
        'price_change_percentage_24h': 2.5,
      }),
    };
    final cubit = WalletDetailsCubit(
      initialState: const WalletDetailsState(coinsStatus: WalletStatus.loading),
      geniusApi: _UnusedApi(),
      networkTokensProvider: NetworkTokensProvider(),
    );
    addTearDown(cubit.close);

    tester.view.devicePixelRatio = 1.0;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: BlocProvider<WalletDetailsCubit>.value(
            value: cubit,
            child: const _BreakpointHost(),
          ),
        ),
      ),
    );

    cubit.injectMockCoins([
      const Coin(name: 'GNUS', symbol: 'GNUS', iconPath: '', balance: 1),
    ], balance: '1.41');
    await tester.pump();
    await tester.pump();
    expect(find.text(r'$1.41'), findsWidgets);

    tester.view.physicalSize = const Size(1000, 800);
    await tester.pump();
    await tester.pump();
    expect(find.text(r'$1.41'), findsWidgets);
    expect(find.text(r'$0.00'), findsNothing);
  });
}
