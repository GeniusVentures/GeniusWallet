import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_navigator_observer.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

final _words = List.generate(12, (i) => 'word${i + 1}');

class _Api implements GeniusApi {
  @override
  Future<List<String>> getRecoveryPhrase(HDWallet wallet) async => _words;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _Wallet implements HDWallet {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _fillWrongOrder(WidgetTester tester) async {
  // The chips are shuffled; tapping them in reverse of the required order is
  // wrong whenever the four missing words are distinct, so sort descending.
  final chips = find.byType(ActionChip);
  final labels = tester
      .widgetList<ActionChip>(chips)
      .map((c) => ((c.label) as Text).data!)
      .toList();
  labels.sort(
    (a, b) => int.parse(b.substring(4)).compareTo(int.parse(a.substring(4))),
  );
  for (final label in labels) {
    await tester.tap(find.widgetWithText(ActionChip, label));
    await tester.pump();
  }
}

void main() {
  testWidgets('wrong order shows the failure toast, every attempt', (
    tester,
  ) async {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
    tester.view.physicalSize = const Size(1200, 1600);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    final router = GoRouter(
      observers: [ToastNavigatorObserver(ToastManager.instance)],
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => const Scaffold(body: Text('landing')),
        ),
        GoRoute(
          path: '/create',
          builder: (_, _) => MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (_) => NewWalletBloc(
                  api: _Api(),
                  wallet: _Wallet(),
                  initialState: NewWalletState(
                    recoveryWords: _words,
                    currentStep: NewWalletStep.verifyRecoveryPhrase,
                  ),
                ),
              ),
              BlocProvider(create: (_) => NewPinCubit(api: _Api())),
            ],
            child: const NewWalletFlow(),
          ),
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp.router(
        theme: ThemeData(extensions: [GWColors.dark()]),
        routerConfig: router,
      ),
    );
    unawaited(router.push('/create'));
    await tester.pumpAndSettle();
    await tester.pump();
    await tester.pump();

    for (var attempt = 0; attempt < 2; attempt++) {
      await _fillWrongOrder(tester);
      await tester.tap(find.byType(GWButton));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.text('Verification failed'), findsOneWidget);
      expect(find.byType(ActionChip), findsNWidgets(4));
      const inline = "Those words aren't in the right order. Try again.";
      expect(find.text(inline), findsOneWidget);
      await tester.pump(const Duration(seconds: 10));
    }
    final bloc = tester
        .element(find.byType(NewWalletFlow))
        .read<NewWalletBloc>();
    bloc.add(GoBack());
    await tester.pumpAndSettle();
    bloc.add(RecoveryPhraseContinue());
    await tester.pumpAndSettle();
    expect(
      find.text("Those words aren't in the right order. Try again."),
      findsNothing,
    );
    expect(find.text('Verification failed'), findsNothing);
    await _fillWrongOrder(tester);
    await tester.tap(find.byType(GWButton));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.tap(find.byType(ActionChip).first);
    await tester.pump();
    expect(
      find.text("Those words aren't in the right order. Try again."),
      findsNothing,
    );
    debugDefaultTargetPlatformOverride = null;
  });
}
