import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/banxa/handle_banxa_drawer.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

/// Pins 09-05 Task 2's re-skin of `CheckoutOptionsSheet` (D-07 — see the
/// `.planning/todos/pending/2026-07-27-checkout-options-sheet-visual-
/// contract-was-derived-not-specified.md` note filed alongside this plan).
/// Pumps `CheckoutOptionsSheet` directly rather than driving
/// `showModalBottomSheet`, per the plan's own instruction — the widget takes
/// a `parentContext`, so a router-backed launcher screen supplies one.
///
/// `TestDefaultBinaryMessengerBinding`'s mock handler intercepts the
/// platform-channel clipboard call rather than reading the real system
/// clipboard (there is none in a test harness).
void main() {
  const checkoutUrl = 'https://banxa-sandbox.com/checkout/abc123';

  final List<MethodCall> platformCalls = [];

  setUp(() {
    platformCalls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (
          MethodCall call,
        ) async {
          platformCalls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  /// A two-route `GoRouter` — the sheet's launch point (its `BuildContext`
  /// becomes `parentContext`) and a stub `/checkoutQR` destination — so the
  /// Show QR button's real `GoRouter.of(parentContext).push` call has
  /// somewhere to land instead of throwing on a missing router ancestor.
  Widget routedHost() {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) =>
              _SheetLauncher(parentContext: context, checkoutUrl: checkoutUrl),
        ),
        GoRoute(
          path: '/checkoutQR',
          builder: (context, state) =>
              const Scaffold(body: Text('checkout qr stub')),
        ),
      ],
    );
    return MaterialApp.router(
      theme: ThemeData(extensions: [GWColors.dark()]),
      routerConfig: router,
    );
  }

  testWidgets(
    'renders the title and all three action labels, with no raw Material button in the tree',
    (tester) async {
      await tester.pumpWidget(routedHost());
      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      expect(find.text('Continue to checkout'), findsOneWidget);
      expect(find.text('Open in Browser'), findsOneWidget);
      expect(find.text('Show QR (use another device)'), findsOneWidget);
      expect(find.text('Copy checkout link'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tapping the copy action puts the checkout URL on the clipboard, then closes the sheet',
    (tester) async {
      await tester.pumpWidget(routedHost());
      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Copy checkout link'));
      await tester.pump();

      final clipboardCall = platformCalls.firstWhere(
        (call) => call.method == 'Clipboard.setData',
      );
      final clipboardArgs = clipboardCall.arguments as Map<dynamic, dynamic>;
      expect(clipboardArgs['text'], checkoutUrl);

      await tester.pumpAndSettle();
      expect(find.text('Continue to checkout'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tapping Show QR closes the sheet before it navigates to the QR route',
    (tester) async {
      await tester.pumpWidget(routedHost());
      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show QR (use another device)'));
      await tester.pumpAndSettle();

      expect(find.text('Continue to checkout'), findsNothing);
      expect(find.text('checkout qr stub'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'tapping Open in Browser closes the sheet and its unavailable-launcher catch does not crash',
    (tester) async {
      await tester.pumpWidget(routedHost());
      await tester.tap(find.text('open sheet'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open in Browser'));
      await tester.pumpAndSettle();

      expect(find.text('Continue to checkout'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

class _SheetLauncher extends StatelessWidget {
  const _SheetLauncher({
    required this.parentContext,
    required this.checkoutUrl,
  });

  final BuildContext parentContext;
  final String checkoutUrl;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: TextButton(
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => CheckoutOptionsSheet(
                parentContext: parentContext,
                checkoutUrl: checkoutUrl,
                orderId: 'ord_0001',
                redirectUrl: 'geniuswallet://banxa/callback',
              ),
            ),
          ),
          child: const Text('open sheet'),
        ),
      ),
    );
  }
}
