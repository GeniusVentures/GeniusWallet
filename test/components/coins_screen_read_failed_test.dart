import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

void main() {
  testWidgets('a failed holdings read is not reported as "No coins yet"', (
    tester,
  ) async {
    await tester.pumpWidget(
      BlocProvider<WalletDetailsCubit>(
        create: (_) => WalletDetailsCubit(
          initialState: const WalletDetailsState(
            coinsStatus: WalletStatus.error,
          ),
          geniusApi: _UnusedApi(),
          networkTokensProvider: NetworkTokensProvider(),
        ),
        child: MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: const Scaffold(body: CoinsScreen()),
        ),
      ),
    );

    expect(find.text('No coins yet'), findsNothing);
    expect(find.text('Failed to load your assets.'), findsOneWidget);
  });
}
