// The one check `lib/reown/` owed before this plan (21-04) touched a single
// pixel in it: at HEAD `08f6df5`, `test/reown/` did not exist, and nothing in
// the app's suite exercised these two drawers at all. They are the wallet's
// LAST human checkpoint before a signature -- `ApproveTransactionDrawer.show`
// and `ApproveDappConnectionDrawer.show` return the `Future<bool?>` that
// `handle_dapp_requests.dart` branches on to decide whether the wallet signs.
// A re-skin that turned a dismissal into an approval, or swapped which
// button pops `true`, would look perfect in a screenshot and would be a
// signing bug. So the check that matters here is not what these drawers look
// like -- it is that all six outcomes (approve / reject / dismiss, on both
// drawers) still mean what they meant, proven through a real `show()` call
// and a real gesture, not by calling `Navigator.pop` directly (that would
// test the Navigator, not the button).
//
// `Image.network`'s `errorBuilder` path (T-21-12) needs no HTTP mocking here:
// `TestWidgetsFlutterBinding` installs a global `HttpOverrides` for every
// widget test that makes ANY `HttpClient` request fail fast with a synthetic
// 400 response and no real network I/O (see
// `package:flutter_test/src/_binding_io.dart#_MockHttpOverrides`) -- exactly
// the "no HTTP" failing image this file needs, for free.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/reown/approve_dapp_connection_drawer.dart';
import 'package:genius_wallet/reown/approve_transaction_drawer.dart';
import 'package:genius_wallet/reown/send_transaction_details.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Deliberately <= 12 characters each so `GWCopyRow`'s truncation never kicks
// in (`shorten` defaults true, only active above 12 chars) -- case 5 below
// needs these to reach the screen byte-for-byte, not as a truncated display
// form.
const _txFixture = SendTransactionDetails(
  fromAddress: '0xFrom0001',
  toAddress: '0xTo000002',
  amount: '1.2345',
  totalGasFee: '0.0010',
  maxFeePerGas: '0.0020',
  priorityFee: '0.0007',
  receiveTokenSymbol: 'USDC',
);

const _dappName = 'Uniswap';
const _dappUrl = 'https://app.uniswap.org';
const _brokenIconUrl = 'https://icons.example.invalid/broken.png';

/// Records the outcome of a real `show()` call driven through a real gesture.
/// `value` is intentionally nullable AND `settled` is a separate flag: a
/// dismissal legitimately resolves the future with `null`, which must be
/// distinguishable from "the future has not resolved yet".
class _Outcome {
  bool settled = false;
  bool? value;
}

/// Pumps a host app with one button that opens the drawer under test via
/// [show], taps it open, and returns the [_Outcome] the caller then drives
/// with further gestures (tapping a button, tapping the barrier, or popping
/// the root navigator).
Future<_Outcome> _openDrawer(
  WidgetTester tester,
  Future<bool?> Function(BuildContext context) show,
) async {
  final outcome = _Outcome();
  await tester.pumpWidget(
    MaterialApp(
      theme: ThemeData(extensions: [GWColors.dark()]),
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () async {
              outcome.value = await show(context);
              outcome.settled = true;
            },
            child: const Text('open'),
          ),
        ),
      ),
    ),
  );
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
  return outcome;
}

/// Dismisses the DESKTOP `showDialog` panel by tapping its barrier. The panel
/// is a known 420px-wide right-aligned column (`ResponsiveDrawer.show`'s
/// `desktopWidth`), so a tap in the top-left corner reliably lands outside it
/// on the default 800x600 test surface.
Future<void> _dismissViaDesktopBarrier(WidgetTester tester) async {
  await tester.tapAt(const Offset(10, 10));
  await tester.pumpAndSettle();
}

/// Dismisses the MOBILE `showModalBottomSheet` route the way the shell's own
/// ✕ button does (`Navigator.of(context).pop()` with `useRootNavigator:
/// true`) rather than a blind barrier tap -- the sheet's height depends on
/// its (scroll-free) content, so there is no dependable barrier-only strip to
/// tap blind, the same reasoning
/// `test/components/drawer_body_padding_test.dart` already recorded for this
/// exact route shape.
Future<void> _dismissMobileSheet(WidgetTester tester) async {
  final rootContext = tester.element(find.text('open'));
  Navigator.of(rootContext, rootNavigator: true).pop();
  await tester.pumpAndSettle();
}

/// Below `GeniusBreakpoints.medium` (768) so `ResponsiveDrawer.show()` takes
/// the `showModalBottomSheet` branch instead of `showDialog` -- matching
/// `drawer_body_padding_test.dart`'s own mobile surface.
Future<void> _useMobileSurface(WidgetTester tester) async {
  await tester.binding.setSurfaceSize(const Size(400, 800));
  addTearDown(() => tester.binding.setSurfaceSize(null));
}

void main() {
  group('ApproveTransactionDrawer -- desktop panel', () {
    testWidgets(
      'Case 1: tapping Approve completes the future with true, and the '
      'broken dApp icon still leaves the url readable (T-21-12)',
      (tester) async {
        final outcome = await _openDrawer(
          tester,
          (context) => ApproveTransactionDrawer.show(
            context: context,
            content: _txFixture,
            dappName: _dappName,
            dappUrl: _dappUrl,
            iconUrl: _brokenIconUrl,
          ),
        );

        // T-21-12: nothing renders in the icon's place, but the url the
        // identity exists to show is still there.
        expect(find.text(_dappUrl), findsOneWidget);

        await tester.tap(find.text('Approve'));
        await tester.pumpAndSettle();

        expect(outcome.settled, isTrue);
        expect(outcome.value, isTrue);
      },
    );

    testWidgets('Case 2: tapping Reject completes the future with false', (
      tester,
    ) async {
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveTransactionDrawer.show(
          context: context,
          content: _txFixture,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(outcome.settled, isTrue);
      expect(outcome.value, isFalse);
    });

    testWidgets(
      'Case 3: dismissing via the barrier completes the future with null, '
      'not false',
      (tester) async {
        final outcome = await _openDrawer(
          tester,
          (context) => ApproveTransactionDrawer.show(
            context: context,
            content: _txFixture,
            dappName: _dappName,
            dappUrl: _dappUrl,
          ),
        );

        await _dismissViaDesktopBarrier(tester);

        expect(outcome.settled, isTrue);
        expect(outcome.value, isNull);
      },
    );
  });

  group('ApproveTransactionDrawer -- mobile sheet', () {
    testWidgets('approve completes the future with true', (tester) async {
      await _useMobileSurface(tester);
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveTransactionDrawer.show(
          context: context,
          content: _txFixture,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await tester.tap(find.text('Approve'));
      await tester.pumpAndSettle();

      expect(outcome.settled, isTrue);
      expect(outcome.value, isTrue);
    });

    testWidgets('reject completes the future with false', (tester) async {
      await _useMobileSurface(tester);
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveTransactionDrawer.show(
          context: context,
          content: _txFixture,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await tester.tap(find.text('Reject'));
      await tester.pumpAndSettle();

      expect(outcome.settled, isTrue);
      expect(outcome.value, isFalse);
    });

    testWidgets('dismissing the sheet completes the future with null', (
      tester,
    ) async {
      await _useMobileSurface(tester);
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveTransactionDrawer.show(
          context: context,
          content: _txFixture,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await _dismissMobileSheet(tester);

      expect(outcome.settled, isTrue);
      expect(outcome.value, isNull);
    });
  });

  group('ApproveDappConnectionDrawer -- desktop panel', () {
    testWidgets(
      'Case 4a: tapping Allow completes the future with true, and the '
      'broken dApp icon still leaves the name and url readable (T-21-12)',
      (tester) async {
        final outcome = await _openDrawer(
          tester,
          (context) => ApproveDappConnectionDrawer.show(
            context: context,
            dappName: _dappName,
            dappUrl: _dappUrl,
            iconUrl: _brokenIconUrl,
          ),
        );

        expect(find.text(_dappName), findsOneWidget);
        expect(find.text(_dappUrl), findsOneWidget);

        await tester.tap(find.text('Allow'));
        await tester.pumpAndSettle();

        expect(outcome.settled, isTrue);
        expect(outcome.value, isTrue);
      },
    );

    testWidgets('Case 4b: tapping Deny completes the future with false', (
      tester,
    ) async {
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveDappConnectionDrawer.show(
          context: context,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await tester.tap(find.text('Deny'));
      await tester.pumpAndSettle();

      expect(outcome.settled, isTrue);
      expect(outcome.value, isFalse);
    });

    testWidgets(
      'Case 4c: dismissing via the barrier completes the future with null, '
      'not false',
      (tester) async {
        final outcome = await _openDrawer(
          tester,
          (context) => ApproveDappConnectionDrawer.show(
            context: context,
            dappName: _dappName,
            dappUrl: _dappUrl,
          ),
        );

        await _dismissViaDesktopBarrier(tester);

        expect(outcome.settled, isTrue);
        expect(outcome.value, isNull);
      },
    );
  });

  group('ApproveDappConnectionDrawer -- mobile sheet', () {
    testWidgets('allow completes the future with true', (tester) async {
      await _useMobileSurface(tester);
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveDappConnectionDrawer.show(
          context: context,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await tester.tap(find.text('Allow'));
      await tester.pumpAndSettle();

      expect(outcome.settled, isTrue);
      expect(outcome.value, isTrue);
    });

    testWidgets('deny completes the future with false', (tester) async {
      await _useMobileSurface(tester);
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveDappConnectionDrawer.show(
          context: context,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await tester.tap(find.text('Deny'));
      await tester.pumpAndSettle();

      expect(outcome.settled, isTrue);
      expect(outcome.value, isFalse);
    });

    testWidgets('dismissing the sheet completes the future with null', (
      tester,
    ) async {
      await _useMobileSurface(tester);
      final outcome = await _openDrawer(
        tester,
        (context) => ApproveDappConnectionDrawer.show(
          context: context,
          dappName: _dappName,
          dappUrl: _dappUrl,
        ),
      );

      await _dismissMobileSheet(tester);

      expect(outcome.settled, isTrue);
      expect(outcome.value, isNull);
    });
  });

  group('SendTransactionDetails inside the transaction drawer', () {
    testWidgets(
      'Case 5: every one of the seven SendTransactionDetails strings is '
      'findable on screen, unmodified',
      (tester) async {
        await _openDrawer(
          tester,
          (context) => ApproveTransactionDrawer.show(
            context: context,
            content: _txFixture,
            dappName: _dappName,
            dappUrl: _dappUrl,
          ),
        );

        bool findable(String value) => tester
            .widgetList<Text>(find.byType(Text))
            .any((t) => (t.data ?? '').contains(value));

        expect(
          findable(_txFixture.fromAddress),
          isTrue,
          reason: 'fromAddress must reach the screen unmodified',
        );
        expect(
          findable(_txFixture.toAddress),
          isTrue,
          reason: 'toAddress must reach the screen unmodified',
        );
        expect(
          findable(_txFixture.amount),
          isTrue,
          reason: 'amount must reach the screen unmodified',
        );
        expect(
          findable(_txFixture.totalGasFee),
          isTrue,
          reason: 'totalGasFee must reach the screen unmodified',
        );
        expect(
          findable(_txFixture.maxFeePerGas),
          isTrue,
          reason: 'maxFeePerGas must reach the screen unmodified',
        );
        expect(
          findable(_txFixture.priorityFee),
          isTrue,
          reason: 'priorityFee must reach the screen unmodified',
        );
        expect(
          findable(_txFixture.receiveTokenSymbol!),
          isTrue,
          reason: 'receiveTokenSymbol must reach the screen unmodified',
        );

        // Leave the route clean for the next test.
        await _dismissViaDesktopBarrier(tester);
      },
    );

    testWidgets(
      'Case 6: no fiat figure and no computed total appears -- only the '
      'four numeric fields actually passed in',
      (tester) async {
        await _openDrawer(
          tester,
          (context) => ApproveTransactionDrawer.show(
            context: context,
            content: _txFixture,
            dappName: _dappName,
            dappUrl: _dappUrl,
          ),
        );

        final allText = tester
            .widgetList<Text>(find.byType(Text))
            .map((t) => t.data ?? '')
            .toList();

        // No fiat figure anywhere -- the D-03 / unwired-fiat guard. 033's `*`
        // marker was deliberately dropped rather than quietly rendering a
        // number (see the plan's constraints); this is the check that a
        // later change does not quietly wire one in quietly.
        for (final text in allText) {
          expect(
            text.contains(r'$'),
            isFalse,
            reason: 'Unexpected fiat figure in "$text"',
          );
        }

        // Every decimal number on screen is one of the four values this
        // drawer was actually given -- nothing computed (a sum, a fiat
        // conversion) sneaks in as an unexplained fifth number.
        final knownNumbers = <String>{
          _txFixture.amount,
          _txFixture.totalGasFee,
          _txFixture.maxFeePerGas,
          _txFixture.priorityFee,
        };
        final numberPattern = RegExp(r'\d+\.\d+');
        for (final text in allText) {
          for (final match in numberPattern.allMatches(text)) {
            expect(
              knownNumbers.contains(match.group(0)),
              isTrue,
              reason:
                  'Unexpected numeric value "${match.group(0)}" in "$text" '
                  '-- not one of the four fields this drawer was given '
                  '($knownNumbers)',
            );
          }
        }

        await _dismissViaDesktopBarrier(tester);
      },
    );
  });
}
