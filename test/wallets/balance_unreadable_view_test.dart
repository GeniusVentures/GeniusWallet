// Where the node can't read the selected wallet, every balance surface says
// so in words and shows no number.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/assets/assets_screen.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Widget _host(Widget child) => BlocProvider<WalletDetailsCubit>(
  create: (_) => WalletDetailsCubit(
    initialState: const WalletDetailsState(
      coinsStatus: WalletStatus.successful,
      balanceUnreadable: true,
    ),
    geniusApi: _UnusedApi(),
    networkTokensProvider: NetworkTokensProvider(),
  ),
  child: MaterialApp(
    theme: ThemeData(extensions: [GWColors.dark()]),
    home: Scaffold(body: child),
  ),
);

void main() {
  testWidgets('the compute panel says why instead of a balance', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        ComputePanel(
          view: viewForComputeState(ComputeState.notDefaultAccount),
          balance: null,
          fiatSubline: '≈ \$1.00',
          useMinions: false,
          onUnitChanged: (_) {},
          onLinkTap: (_) {},
          onNewJob: () {},
        ),
      ),
    );

    expect(find.text(kBalanceUnreadableMessage), findsOneWidget);
    expect(find.text('MIN'), findsNothing);
    expect(find.text('≈ \$1.00'), findsNothing);
  });

  testWidgets('the dashboard coins panel says why, not "No coins yet"', (
    tester,
  ) async {
    await tester.pumpWidget(_host(const CoinsScreen()));

    expect(find.text(kBalanceUnreadableMessage), findsOneWidget);
    expect(find.text('No coins yet'), findsNothing);
  });

  testWidgets('the assets page shows no total', (tester) async {
    await tester.pumpWidget(_host(const AssetsScreen()));
    await tester.pump();

    expect(find.text(kBalanceUnreadableMessage), findsOneWidget);
    expect(find.textContaining('\$'), findsNothing);
  });
}
