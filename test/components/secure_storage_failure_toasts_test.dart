import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/toast/secure_storage_failure_toasts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

void main() {
  testWidgets('storage blocked before mount still shows the notice', (
    tester,
  ) async {
    final navigatorKey = GlobalKey<NavigatorState>();
    final failed = ValueNotifier(true);

    await tester.pumpWidget(
      MaterialApp(
        navigatorKey: navigatorKey,
        theme: ThemeData(extensions: [GWColors.dark()]),
        builder: (context, child) => SecureStorageFailureToasts(
          failed: failed,
          navigatorKey: navigatorKey,
          child: child!,
        ),
        home: const Scaffold(),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text(secureStorageFailedTitle), findsOneWidget);

    await tester.pump(const Duration(seconds: 10));
  });
}
