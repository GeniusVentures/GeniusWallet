import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/bloc/pin_cubit.dart';
import 'package:genius_wallet/onboarding/bloc/new_pin_cubit.dart';
import 'package:genius_wallet/onboarding/view/confirm_and_save_pin_screen.dart';
import 'package:genius_wallet/screens/pin_screen.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _saveFailed = "Your PIN couldn't be saved. Enter it again to retry.";

/// A PIN save that fails once without blocking storage.
class _FlakyApi implements GeniusApi {
  @override
  ValueListenable<bool> get secureStorageFailed => ValueNotifier(false);

  @override
  Future<void> storeUserPin(String pin) =>
      Future.error(PlatformException(code: 'busy'));

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  testWidgets('a mismatch after a failed save shows only the mismatch', (
    tester,
  ) async {
    final api = _FlakyApi();
    final newPinCubit = NewPinCubit(api: api)..pinEntered('1234');
    await tester.pumpWidget(
      RepositoryProvider<GeniusApi>.value(
        value: api,
        child: MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: Scaffold(
            body: BlocProvider.value(
              value: newPinCubit,
              child: ConfirmAndSavePinScreen(onPassed: () {}),
            ),
          ),
        ),
      ),
    );

    Future<void> submit(String pin) async {
      final pinCubit = tester.element(find.byType(PinScreen)).read<PinCubit>()
        ..clearAll();
      for (final digit in pin.split('')) {
        pinCubit.add(digit);
      }
      await tester.pump();
      await tester.tap(find.text('Continue'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));
    }

    await submit('1234');
    expect(find.text(_saveFailed), findsOneWidget);
    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
    expect(find.text(_saveFailed), findsNothing);

    await submit('9999');

    expect(
      find.text("PINs don't match. Enter the PIN you just created."),
      findsOneWidget,
    );
    expect(find.text(_saveFailed), findsNothing);
    await tester.pump(const Duration(seconds: 10));
  });
}
