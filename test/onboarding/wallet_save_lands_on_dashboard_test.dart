// Completing a wallet flow that was pushed over the dashboard shell must
// land on the dashboard with the flow route gone. The save listener is what
// navigates, so the routes below mirror the app's shape: a ShellRoute member
// as home, the flow on a top-level route pushed above it.
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

class _Api implements GeniusApi {
  @override
  Future<void> saveWallet(HDWallet wallet) async {}

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet implements HDWallet {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

// The save listener only reads AppBloc to dispatch LoadWallets; nothing in
// this test depends on what that handler loads, so a stub keeps the native
// SDK and its timers out of the harness.
class _IdleAppBloc implements AppBloc {
  @override
  Stream<AppState> get stream => const Stream<AppState>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    // The save listener dispatches LoadWallets; nothing here depends on the
    // wallets it would load, so the dispatch is a no-op.
    if (invocation.memberName == #add) {
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

void main() {
  testWidgets('saving a wallet pushed over the shell lands on the dashboard', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // The app's shape: the dashboard lives in a ShellRoute, and the flow
    // runs on top-level routes pushed above it.
    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        GoRoute(
          path: '/landing',
          builder: (_, _) => const Scaffold(body: Text('landing')),
        ),
        GoRoute(
          path: '/create',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => NewWalletBloc(api: _Api(), wallet: _Wallet()),
              ),
              BlocProvider(create: (_) => NewPinCubit(api: _Api())),
              BlocProvider<AppBloc>.value(value: _IdleAppBloc()),
            ],
            child: const NewWalletFlow(),
          ),
        ),
        ShellRoute(
          builder: (_, _, child) => Scaffold(body: child),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (_, _) => const Scaffold(body: Text('dashboard')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);

    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    );
    await tester.pumpAndSettle();
    unawaited(router.push('/landing'));
    await tester.pumpAndSettle();
    unawaited(router.push('/create'));
    await tester.pumpAndSettle();

    // The save succeeds: the flow's own listener reacts to walletSaveStatus
    // == loaded.
    tester
        .element(find.byType(NewWalletFlow))
        .read<NewWalletBloc>()
        .add(AddWallet(wallet: _Wallet()));
    await tester.pumpAndSettle();

    expect(find.text('dashboard'), findsOneWidget);
    expect(find.byType(NewWalletFlow), findsNothing);
  });
}
