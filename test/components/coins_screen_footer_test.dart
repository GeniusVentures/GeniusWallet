import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('a short panel keeps Receive and Buy GNUS on screen', (
    tester,
  ) async {
    // Unpriced holdings: the panel's total is 0, so it offers both actions.
    final coins = [
      for (final symbol in ['AAA', 'BBB', 'CCC', 'DDD', 'EEE', 'FFF'])
        Coin(name: symbol, symbol: symbol, iconPath: '', balance: 1),
    ];

    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: BlocProvider<WalletDetailsCubit>(
            create: (_) => WalletDetailsCubit(
              initialState: WalletDetailsState(
                coins: coins,
                coinsStatus: WalletStatus.successful,
              ),
              geniusApi: _UnusedApi(),
              networkTokensProvider: NetworkTokensProvider(),
            ),
            // The desktop dashboard slot: a bounded height shorter than the
            // header, five rows and the footer together.
            child: const Align(
              alignment: Alignment.topLeft,
              child: SizedBox(width: 600, height: 320, child: CoinsScreen()),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Receive').hitTestable(), findsOneWidget);
    expect(find.text('Buy GNUS').hitTestable(), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
