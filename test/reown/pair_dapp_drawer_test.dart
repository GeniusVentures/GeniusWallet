// A real `show()` opened from a host button, in both appearance modes, at
// the default 800x600 surface (>= GeniusBreakpoints.medium) so every case
// exercises the desktop side-drawer branch of ResponsiveDrawer.show --
// mirroring test/reown/approve_drawer_contract_test.dart's own approach for
// the drawer this one follows in the connect flow.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/reown/pair_dapp_drawer.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../theme/theme_contrast_test.dart' show themeFor;

const _wcUri = 'wc:abc123@2?relay-protocol=irn&symKey=deadbeef';

/// Pumps a host app with one button that opens the drawer under [show], taps
/// it open, and calls [onSettled] once the returned future completes --
/// there is no bool outcome to capture here, unlike the approve drawer.
Future<void> _openDrawer(
  WidgetTester tester,
  ThemeData theme,
  Future<void> Function(BuildContext context) show, {
  VoidCallback? onSettled,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              await show(context);
              onSettled?.call();
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

void main() {
  for (final mode in GWAppearanceMode.values) {
    group('PairDappDrawer -- $mode', () {
      testWidgets('startWithPaste true shows the field and Connect, no QR', (
        tester,
      ) async {
        await _openDrawer(
          tester,
          themeFor(mode),
          (context) => PairDappDrawer.show(
            context: context,
            wcUri: _wcUri,
            startWithPaste: true,
            onPair: (_) async => true,
          ),
        );

        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);
        expect(find.byType(QrImageView), findsNothing);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });

      testWidgets('startWithPaste false shows a white QR, no Connect', (
        tester,
      ) async {
        await _openDrawer(
          tester,
          themeFor(mode),
          (context) => PairDappDrawer.show(
            context: context,
            wcUri: _wcUri,
            startWithPaste: false,
            onPair: (_) async => true,
          ),
        );

        final qr = tester.widget<QrImageView>(find.byType(QrImageView));
        expect(qr.backgroundColor, Colors.white);
        expect(find.text('Connect'), findsNothing);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });

      testWidgets('the toggle switches between the two views both ways', (
        tester,
      ) async {
        await _openDrawer(
          tester,
          themeFor(mode),
          (context) => PairDappDrawer.show(
            context: context,
            wcUri: _wcUri,
            startWithPaste: true,
            onPair: (_) async => true,
          ),
        );

        await tester.tap(find.text('Show QR Code'));
        await tester.pumpAndSettle();
        expect(find.byType(QrImageView), findsOneWidget);
        expect(find.text('Connect'), findsNothing);

        await tester.tap(find.text('Enter URI Manually'));
        await tester.pumpAndSettle();
        expect(find.byType(TextField), findsOneWidget);
        expect(find.text('Connect'), findsOneWidget);

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });

      testWidgets(
        'a malformed link shows the fixed invalid-link error and never '
        'calls onPair',
        (tester) async {
          var called = false;
          await _openDrawer(
            tester,
            themeFor(mode),
            (context) => PairDappDrawer.show(
              context: context,
              wcUri: _wcUri,
              startWithPaste: true,
              onPair: (_) async {
                called = true;
                return true;
              },
            ),
          );

          await tester.enterText(find.byType(TextField), 'hello');
          await tester.tap(find.text('Connect'));
          await tester.pumpAndSettle();

          expect(
            find.text('That is not a WalletConnect link.'),
            findsOneWidget,
          );
          expect(called, isFalse);

          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
        },
      );

      testWidgets(
        'onPair returning false shows the fixed failure error, stays open, '
        'and the typed link appears only in the field',
        (tester) async {
          await _openDrawer(
            tester,
            themeFor(mode),
            (context) => PairDappDrawer.show(
              context: context,
              wcUri: _wcUri,
              startWithPaste: true,
              onPair: (_) async => false,
            ),
          );

          await tester.enterText(find.byType(TextField), _wcUri);
          await tester.tap(find.text('Connect'));
          await tester.pumpAndSettle();

          expect(
            find.text("Couldn't start the connection. Try again."),
            findsOneWidget,
          );
          final linkTexts = tester
              .widgetList<Text>(find.byType(Text))
              .where((t) => t.data == _wcUri);
          expect(linkTexts, isEmpty);

          await tester.tap(find.text('Cancel'));
          await tester.pumpAndSettle();
        },
      );

      testWidgets('onPair throwing shows the same fixed failure error', (
        tester,
      ) async {
        await _openDrawer(
          tester,
          themeFor(mode),
          (context) => PairDappDrawer.show(
            context: context,
            wcUri: _wcUri,
            startWithPaste: true,
            onPair: (_) async => throw Exception('boom'),
          ),
        );

        await tester.enterText(find.byType(TextField), _wcUri);
        await tester.tap(find.text('Connect'));
        await tester.pumpAndSettle();

        expect(
          find.text("Couldn't start the connection. Try again."),
          findsOneWidget,
        );

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();
      });

      testWidgets(
        'onPair returning true closes the drawer and settles show()',
        (tester) async {
          var settled = false;
          var called = false;
          await _openDrawer(
            tester,
            themeFor(mode),
            (context) => PairDappDrawer.show(
              context: context,
              wcUri: _wcUri,
              startWithPaste: true,
              onPair: (_) async {
                called = true;
                return true;
              },
            ),
            onSettled: () => settled = true,
          );

          await tester.enterText(find.byType(TextField), _wcUri);
          await tester.tap(find.text('Connect'));
          await tester.pumpAndSettle();

          expect(called, isTrue);
          expect(settled, isTrue);
          expect(find.text('WalletConnect'), findsNothing);
        },
      );

      testWidgets('Cancel closes the drawer without calling onPair', (
        tester,
      ) async {
        var settled = false;
        var called = false;
        await _openDrawer(
          tester,
          themeFor(mode),
          (context) => PairDappDrawer.show(
            context: context,
            wcUri: _wcUri,
            startWithPaste: true,
            onPair: (_) async {
              called = true;
              return true;
            },
          ),
          onSettled: () => settled = true,
        );

        await tester.tap(find.text('Cancel'));
        await tester.pumpAndSettle();

        expect(called, isFalse);
        expect(settled, isTrue);
        expect(find.text('WalletConnect'), findsNothing);
      });
    });
  }
}
