// A recovery phrase can repeat a word, so the quiz's chip pool can hold two
// identical chips. These tests drive the real screen with a phrase whose
// every slot is empty -- the only case where duplicates interact with the
// quiz -- to prove a repeated word can neither pass wrongly nor trap the
// user.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_api/tw/hd_wallet.dart';
import 'package:genius_wallet/bloc/app_bloc.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/new_wallet/bloc/new_wallet_bloc.dart';
import 'package:genius_wallet/onboarding/new_wallet/routes/new_wallet_flow.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

// Two 'delta's: one wrong arrangement, one right, both reachable from the
// shuffled chip pool.
final _words = ['delta', 'alpha', 'charlie', 'delta'];

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

class _IdleAppBloc implements AppBloc {
  @override
  Stream<AppState> get stream => const Stream<AppState>.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) {
    if (invocation.memberName == #add) {
      return null;
    }
    return super.noSuchMethod(invocation);
  }
}

Future<NewWalletBloc> _mountQuiz(WidgetTester tester) async {
  debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  tester.view.physicalSize = const Size(1200, 1600);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  final bloc = NewWalletBloc(
    api: _Api(),
    wallet: _Wallet(),
    initialState: NewWalletState(
      recoveryWords: _words,
      currentStep: NewWalletStep.verifyRecoveryPhrase,
    ),
  );
  final router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        builder: (_, _) => const Scaffold(body: Text('landing')),
      ),
      GoRoute(
        path: '/dashboard',
        builder: (_, _) => const Scaffold(body: Text('dashboard')),
      ),
      GoRoute(
        path: '/create',
        builder: (_, _) => MultiBlocProvider(
          providers: [
            BlocProvider<NewWalletBloc>.value(value: bloc),
            BlocProvider<AppBloc>.value(value: _IdleAppBloc()),
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
  return bloc;
}

Future<void> _tapChip(WidgetTester tester, String word) async {
  await tester.tap(find.widgetWithText(ActionChip, word).first);
  await tester.pump();
}

Future<void> _continue(WidgetTester tester) async {
  await tester.tap(find.byType(GWButton));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 500));
}

void main() {
  testWidgets('a repeated word cannot produce a wrong pass', (tester) async {
    final bloc = await _mountQuiz(tester);
    expect(find.byType(ActionChip), findsNWidgets(4));

    // Fill in a wrong order; the identical 'delta' chips are interchangeable
    // but the arrangement still isn't the phrase.
    await _tapChip(tester, 'alpha');
    await _tapChip(tester, 'charlie');
    await _tapChip(tester, 'delta');
    // Clicking one of the two identical chips leaves the other clickable.
    expect(find.widgetWithText(ActionChip, 'delta'), findsOneWidget);
    await _tapChip(tester, 'delta');
    expect(find.byType(ActionChip), findsNothing);

    await _continue(tester);
    expect(
      bloc.state.verificationStatus,
      VerificationStatus.failed,
      reason: 'a wrong arrangement must fail even with repeated words',
    );
    expect(find.text('Verification failed'), findsOneWidget);

    // The failure cleared the slots; all four chips are back, so the user is
    // not stuck.
    expect(find.byType(ActionChip), findsNWidgets(4));

    await _tapChip(tester, 'delta');
    await _tapChip(tester, 'alpha');
    await _tapChip(tester, 'charlie');
    await _tapChip(tester, 'delta');
    await _continue(tester);
    expect(bloc.state.verificationStatus, VerificationStatus.passed);
    debugDefaultTargetPlatformOverride = null;
  });

  testWidgets('a mis-click with repeated words can be taken back', (
    tester,
  ) async {
    await _mountQuiz(tester);

    await _tapChip(tester, 'alpha');
    expect(find.text('01. alpha'), findsOneWidget);
    // Tap the filled slot to return the word to the pool.
    await tester.tap(find.text('01. alpha'));
    await tester.pump();
    expect(find.text('01.'), findsAtLeastNWidgets(1));
    expect(find.byType(ActionChip), findsNWidgets(4));

    await _tapChip(tester, 'delta');
    await _tapChip(tester, 'alpha');
    await _tapChip(tester, 'charlie');
    await _tapChip(tester, 'delta');
    await _continue(tester);
    expect(find.text('Verification failed'), findsNothing);
    debugDefaultTargetPlatformOverride = null;
  });
}
