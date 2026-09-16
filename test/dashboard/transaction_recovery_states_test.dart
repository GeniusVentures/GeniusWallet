// Three states where the money moved but not where it was asked to go.
//
// The load-bearing case is the button. A paused transfer is resumed on the
// aggregator's own page, and that URL is CAPTURED from the status response and
// persisted — never composed from the hash. So the cases below alter the
// stored link and assert the button follows it: a composed link would ignore
// the change and open the same place either way.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

const _hash = '0xfeedfacefeedfacefeedfacefeedfacefeedface';
const _axelar = 'https://axelarscan.io/gmp/$_hash';

Transaction _tx({required TransactionStatus status, String? recoveryUrl}) =>
    Transaction(
      hash: _hash,
      fromAddress: '0x1111111111111111111111111111111111111111',
      recipients: const [],
      timeStamp: DateTime(2026, 9, 16),
      transactionDirection: TransactionDirection.received,
      fees: '0.42',
      coinSymbol: 'ETH',
      transactionStatus: status,
      type: TransactionType.swap,
      fromSymbol: 'GNUS',
      toSymbol: 'USDC',
      recoveryUrl: recoveryUrl,
    );

/// Captures the URL the app actually navigates to. `launchWebSite` pushes
/// `/web` carrying it, so a route here is the only way to prove the button
/// opens the STORED string rather than one built from the hash.
String? launchedUrl;

Widget _app(Transaction tx) {
  launchedUrl = null;
  return MaterialApp.router(
    theme: ThemeData(extensions: [GWColors.dark()]),
    routerConfig: GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (_, _) => Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => showTransactionDetails(context, tx),
                child: const Text('open'),
              ),
            ),
          ),
        ),
        GoRoute(
          path: '/web',
          builder: (_, state) {
            launchedUrl = (state.extra as WebViewExtras?)?.url;
            return const Scaffold(body: SizedBox.shrink());
          },
        ),
      ],
    ),
  );
}

Future<void> _openReceipt(WidgetTester tester, Transaction tx) async {
  tester.view.physicalSize = const Size(1200, 2000);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(_app(tx));
  await tester.tap(find.text('open'));
  await tester.pumpAndSettle();
}

Finder get _recoveryButton =>
    find.widgetWithText(GWButton, 'Open recovery page');

void main() {
  group('the stored link survives the round trip', () {
    test('a row keeps the link it was written with', () {
      final tx = _tx(status: TransactionStatus.needsGas, recoveryUrl: _axelar);
      expect(tx.recoveryUrl, _axelar);
    });

    test('a row written by an earlier build reads back with none', () {
      // Field 17 is appended, so an older row simply has nothing there —
      // which is the same as "no action offered", not a crash.
      expect(_tx(status: TransactionStatus.needsGas).recoveryUrl, isNull);
    });
  });

  group('what each state says', () {
    test('every status is either explained or deliberately silent', () {
      // Iterating the enum, not a written-out list: the next value added
      // cannot quietly skip this and print its own name at a user.
      for (final status in TransactionStatus.values) {
        final note = recoveryNoteFor(status, requestedSymbol: 'USDC');
        if (note != null) {
          expect(note, isNotEmpty, reason: '$status');
          expect(note, isNot(contains(status.name)), reason: '$status');
        }
        // Every status must have a word for the row, whatever it says.
        expect(statusWordFor(status), isNotEmpty, reason: '$status');
      }
    });

    test('the three moved-money states explain themselves', () {
      for (final status in [
        TransactionStatus.needsGas,
        TransactionStatus.partialSuccess,
        TransactionStatus.refunded,
      ]) {
        final note = recoveryNoteFor(status);
        expect(note, isNotNull, reason: '$status said nothing');
        expect(note, isNotEmpty);
        // Never the enum's own name.
        expect(note, isNot(contains(status.name)));
      }
    });

    test('a settled or never-sent state has nothing to explain', () {
      for (final status in [
        TransactionStatus.completed,
        TransactionStatus.pending,
        TransactionStatus.failed,
        TransactionStatus.cancelled,
      ]) {
        expect(recoveryNoteFor(status), isNull, reason: '$status over-spoke');
      }
    });

    test('a paused swap says the funds are held, not lost', () {
      final note = recoveryNoteFor(TransactionStatus.needsGas)!;
      expect(note.toLowerCase(), contains('held'));
      expect(note.toLowerCase(), contains('not lost'));
    });
  });

  group('which links this app will open', () {
    test('an https link is openable', () {
      expect(openableRecoveryUrl(_axelar), _axelar);
    });

    test('absent, empty, unparseable or non-https is not', () {
      for (final bad in [
        null,
        '',
        'not a url at all',
        'http://axelarscan.io/gmp/x',
        'javascript:alert(1)',
        'file:///etc/passwd',
      ]) {
        expect(openableRecoveryUrl(bad), isNull, reason: '$bad was accepted');
      }
    });
  });

  group('the receipt', () {
    testWidgets('a paused swap shows the sentence and the button', (
      tester,
    ) async {
      await _openReceipt(
        tester,
        _tx(status: TransactionStatus.needsGas, recoveryUrl: _axelar),
      );

      expect(find.byType(GWWarningNote), findsOneWidget);
      expect(_recoveryButton, findsOneWidget);
    });

    testWidgets('a paused swap with NO link shows the sentence and no button', (
      tester,
    ) async {
      // The state is still worth explaining; the control is not worth faking.
      await _openReceipt(tester, _tx(status: TransactionStatus.needsGas));

      expect(find.byType(GWWarningNote), findsOneWidget);
      expect(_recoveryButton, findsNothing);
    });

    testWidgets('a paused swap with a non-https link offers no button', (
      tester,
    ) async {
      await _openReceipt(
        tester,
        _tx(
          status: TransactionStatus.needsGas,
          recoveryUrl: 'http://axelarscan.io/gmp/x',
        ),
      );

      expect(find.byType(GWWarningNote), findsOneWidget);
      expect(_recoveryButton, findsNothing);
    });

    testWidgets('the button opens the STORED link, not a composed one', (
      tester,
    ) async {
      // An altered stored link must open the altered one. Anything built from
      // the hash would ignore this and open the same page either way.
      const altered = 'https://example.invalid/somewhere-else';
      await _openReceipt(
        tester,
        _tx(status: TransactionStatus.needsGas, recoveryUrl: altered),
      );

      await tester.tap(_recoveryButton);
      await tester.pumpAndSettle();

      expect(launchedUrl, altered);
      // And it shares nothing with the hash, so it cannot have been built
      // from it.
      expect(altered, isNot(contains(_hash)));
    });

    testWidgets('a completed swap shows neither', (tester) async {
      await _openReceipt(
        tester,
        _tx(status: TransactionStatus.completed, recoveryUrl: _axelar),
      );

      expect(find.byType(GWWarningNote), findsNothing);
      expect(_recoveryButton, findsNothing);
    });

    testWidgets('a refunded swap explains itself in plain text, not amber', (
      tester,
    ) async {
      // An amber warning box that says "nothing is required" argues with
      // itself, so the refund gets secondary text and no button — there is
      // nothing to resume, the money is already on its way back.
      await _openReceipt(
        tester,
        _tx(status: TransactionStatus.refunded, recoveryUrl: _axelar),
      );

      expect(find.byType(GWWarningNote), findsNothing);
      expect(
        find.text(recoveryNoteFor(TransactionStatus.refunded)!),
        findsOneWidget,
      );
      expect(_recoveryButton, findsNothing);
    });

    testWidgets('a partial swap names the token asked for and no other', (
      tester,
    ) async {
      await _openReceipt(tester, _tx(status: TransactionStatus.partialSuccess));

      final note = recoveryNoteFor(
        TransactionStatus.partialSuccess,
        requestedSymbol: 'USDC',
      )!;
      expect(note, contains('USDC'));
      // The status response carries no symbol for what actually ARRIVED, so
      // naming one would be an invention.
      expect(note, isNot(contains('GNUS')));
      expect(find.byType(GWWarningNote), findsOneWidget);
      expect(_recoveryButton, findsNothing);
    });
  });
}
