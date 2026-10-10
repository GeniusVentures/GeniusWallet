// The phone shell's page runs to the bar's painted top edge, under the Swap
// dock's overhang, and the strip beside the dock stays tappable.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/overlay/responsive_overlay.dart';
import 'package:genius_wallet/dashboard/transactions/cubit/transactions_cubit.dart';
import 'package:genius_wallet/providers/network_provider.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/theme.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

class _FakeGeniusApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('the phone page ends at the bar, not above the dock', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    tester.view.padding = const FakeViewPadding(bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    addTearDown(tester.view.resetViewInsets);

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

    const probe = Key('page');
    var pageTaps = 0;
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/dashboard',
          builder: (_, _) => MobileOverlay(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => pageTaps++,
              child: const SizedBox.expand(key: probe),
            ),
          ),
        ),
        GoRoute(
          path: '/swap',
          builder: (_, _) => const MobileOverlay(child: SizedBox.shrink()),
        ),
      ],
    );

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          RepositoryProvider<GeniusApi>.value(value: api),
          BlocProvider<WalletDetailsCubit>.value(value: walletDetailsCubit),
          BlocProvider<TransactionsCubit>.value(value: transactionsCubit),
          BlocProvider<AppBloc>.value(value: appBloc),
          ChangeNotifierProvider<NetworkProvider>.value(value: networkProvider),
        ],
        child: MaterialApp.router(theme: getThemeData(), routerConfig: router),
      ),
    );
    await tester.pump();

    const barTop = 844 - kMobileBarHeight - kMaxBottomSafeInset;
    expect(tester.getRect(find.byKey(probe)).bottom, barTop);

    await tester.tapAt(const Offset(20, barTop - 10));
    await tester.pump();
    expect(pageTaps, 1);

    tester.view.viewInsets = const FakeViewPadding(bottom: 300);
    await tester.pump();
    expect(tester.getRect(find.byKey(probe)).bottom, 544);

    tester.view.resetViewInsets();
    await tester.pump();
    await tester.tapAt(const Offset(195, barTop - 13));
    await tester.pump(const Duration(milliseconds: 500));
    expect(router.routerDelegate.currentConfiguration.uri.path, '/swap');

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.runAsync(() => appBloc.close());
    await walletDetailsCubit.close();
    await transactionsCubit.close();
  });
}
