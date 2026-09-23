// A mistyped confirmation PIN keeps the user on the confirm step: the first
// PIN survives, only the confirmation entry is cleared, "Incorrect PIN" shows
// where the mistake happened, and every further mismatch is heard again.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/view/confirm_and_save_pin_screen.dart';
import 'package:genius_wallet/screens/pin_screen.dart';

/// `implements`, not `extends`: the real constructor loads the native library.
class _FakeGeniusApi implements GeniusApi {
  final stored = <String>[];

  @override
  Future<void> storeUserPin(String pin) async => stored.add(pin);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  late _FakeGeniusApi api;
  late NewPinCubit newPinCubit;
  late int passed;

  Future<void> pumpConfirm(WidgetTester tester) async {
    api = _FakeGeniusApi();
    newPinCubit = NewPinCubit(api: api)..pinEntered('1234');
    passed = 0;
    await tester.pumpWidget(
      RepositoryProvider<GeniusApi>.value(
        value: api,
        child: MaterialApp(
          home: Scaffold(
            body: BlocProvider.value(
              value: newPinCubit,
              child: ConfirmAndSavePinScreen(onPassed: () => passed++),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> submit(WidgetTester tester, String pin) async {
    final pinCubit = tester.element(find.byType(PinScreen)).read<PinCubit>();
    for (final digit in pin.split('')) {
      pinCubit.add(digit);
    }
    await tester.pump();
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();
  }

  String confirmEntry(WidgetTester tester) => tester
      .element(find.byType(PinScreen))
      .read<PinCubit>()
      .state
      .pinController
      .text;

  testWidgets('a mismatch stays on Confirm PIN, clears only that entry', (
    tester,
  ) async {
    await pumpConfirm(tester);

    await submit(tester, '9999');

    expect(find.text('Confirm PIN'), findsOneWidget);
    expect(find.text('Incorrect PIN'), findsOneWidget);
    expect(confirmEntry(tester), isEmpty);
    expect(newPinCubit.state.pinToConfirm, '1234');
    expect(passed, 0);
    expect(api.stored, isEmpty);
  });

  testWidgets('a second mismatch is caught too, then the right PIN saves', (
    tester,
  ) async {
    await pumpConfirm(tester);

    await submit(tester, '9999');
    await submit(tester, '8888');

    expect(confirmEntry(tester), isEmpty);
    expect(api.stored, isEmpty);

    await submit(tester, '1234');

    expect(api.stored, ['1234']);
    expect(passed, 1);
  });
}
