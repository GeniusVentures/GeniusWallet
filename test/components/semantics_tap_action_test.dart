// excludeSemantics drops the child's tap action, so a nav tab must carry its
// own or screen readers announce a button that cannot be activated.
import 'package:flutter/material.dart';
import 'package:flutter/semantics.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/reown/wallet_connect_host.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../reown/fake_wallet_kit.dart' show UnstartedWalletConnectHost;

class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a mobile tab exposes a tap action', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final api = _FakeGeniusApi();
    final walletDetailsCubit = WalletDetailsCubit(
      geniusApi: api,
      networkTokensProvider: NetworkTokensProvider(),
    );
    final networkProvider = NetworkProvider();
    final transactionsCubit = TransactionsCubit();
    final appBloc = AppBloc(
      api: api,
      transactionsCubit: transactionsCubit,
      walletDetailsCubit: walletDetailsCubit,
      networkProvider: networkProvider,
    );
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => const MobileOverlay(child: SizedBox.shrink()),
        ),
      ],
    );

    final handle = tester.ensureSemantics();
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          RepositoryProvider<GeniusApi>.value(value: api),
          RepositoryProvider<WalletConnectHost>.value(
            value: UnstartedWalletConnectHost(),
          ),
          BlocProvider<WalletDetailsCubit>.value(value: walletDetailsCubit),
          BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
          BlocProvider<AppBloc>.value(value: appBloc),
          ChangeNotifierProvider<NetworkProvider>.value(value: networkProvider),
        ],
        child: MaterialApp.router(theme: getThemeData(), routerConfig: router),
      ),
    );
    await tester.pump();

    final data = tester
        .getSemantics(find.bySemanticsLabel('Assets'))
        .getSemanticsData();
    expect(data.hasAction(SemanticsAction.tap), isTrue);

    handle.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() => appBloc.close());
    await walletDetailsCubit.close();
    await transactionsCubit.close();
  });
}
