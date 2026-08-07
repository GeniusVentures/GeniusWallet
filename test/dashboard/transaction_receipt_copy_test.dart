// The ONE check sketch 154-D's receipt owes.
//
// D exists for a single reason - people open this drawer "to get the hash or
// the address out" - and its own design creates the way that silently fails:
// the row deliberately PRINTS an abbreviated, chunked form. If the copy ever
// takes what is drawn rather than what was passed, the user gets a truncated
// address in their clipboard, pastes it, and nothing on screen ever said so.
//
// So this asserts the gap: the full value is not on screen, and the full value
// is what lands in the clipboard.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

const _toAddress = '0x5555666677778888999900001111222233334444';
const _hash =
    '0xabcdef0123456789abcdef0123456789abcdef0123456789abcdef0123456789';

Transaction _tx({
  TransactionStatus status = TransactionStatus.completed,
  TransactionType type = TransactionType.transfer,
}) => Transaction(
  hash: _hash,
  fromAddress: '0x1111222233334444555566667777888899990000',
  recipients: [TransferRecipients(toAddr: _toAddress, amount: '1.25')],
  timeStamp: DateTime(2026, 7, 20, 18, 42),
  transactionDirection: TransactionDirection.sent,
  fees: '0.00042',
  coinSymbol: 'ETH',
  transactionStatus: status,
  type: type,
);

Widget _app(Transaction tx) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: Builder(
      builder: (context) => ElevatedButton(
        onPressed: () => showTransactionDetails(context, tx),
        child: const Text('open'),
      ),
    ),
  ),
);

void main() {
  late List<String> copied;

  setUp(() {
    copied = <String>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
          if (call.method == 'Clipboard.setData') {
            copied.add((call.arguments as Map)['text'] as String);
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('a copy row puts the FULL value in the clipboard, never the '
      'short form it draws', (tester) async {
    await tester.pumpWidget(_app(_tx()));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // Half the assertion, and the half that makes the other half mean
    // something: the whole value is NOT rendered. If this ever starts finding
    // the address, the row stopped abbreviating and the copy test below would
    // pass for the wrong reason.
    expect(find.text(_toAddress), findsNothing);
    expect(find.text(_hash), findsNothing);

    // ensureVisible before every tap: the receipt is a ListView and at the
    // test window's 600px the Network section sits below the fold, where a tap
    // silently misses.
    await tester.ensureVisible(find.text('To'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('To'));
    await tester.pumpAndSettle();
    expect(copied, [_toAddress]);

    // The copy confirmation is a SnackBar, which parks over the bottom of the
    // panel -- exactly where the Hash row sits. Without waiting it out, the
    // next tap lands on the SnackBar and this test passes while asserting
    // nothing. (It did, once.)
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Hash'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hash'));
    await tester.pumpAndSettle();
    expect(copied.last, _hash);
  });

  // THE GO/NO-GO GATE for the 2026-08-07 row change, and the reason it is
  // written here rather than beside that change.
  //
  // Jakub, on device: the job row's second line printed the transaction's own
  // hash (`Job 0x9f3a…4b21`) and he named it senseless there. The row is about
  // to stop printing it. That is only DECLUTTERING if the hash stays reachable;
  // if the drawer did not carry it, a job would become unverifiable against a
  // block explorer and the change would be DATA LOSS.
  //
  // The drawer labels this row `Job` for a process transaction and `Hash` for
  // every other type, because for a job the hash IS the job reference. Nothing
  // covered the `Job` branch until now - the test above only ever opened a
  // transfer. So this runs BEFORE the row loses the string, and if it cannot be
  // made to pass the row change must not ship.
  testWidgets('a processing job keeps its hash in the drawer, labelled Job '
      'and copyable in full', (tester) async {
    await tester.pumpWidget(_app(_tx(type: TransactionType.process)));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();

    // The label is `Job`, and `Hash` is NOT also emitted: one row, not the same
    // value printed twice under two labels.
    expect(find.text('Job'), findsOneWidget);
    expect(find.text('Hash'), findsNothing);
    // The drawer's own header is the long form, and it is a different string
    // from the row label - so the finder above cannot be matching the title.
    expect(find.text('Processing job'), findsOneWidget);

    // Same half-assertion as above: the full hash is not on screen, so the
    // clipboard check below cannot pass by accident.
    expect(find.text(_hash), findsNothing);

    await tester.ensureVisible(find.text('Job'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Job'));
    await tester.pumpAndSettle();
    expect(copied, [_hash]);
  });

  // Jakub, 2026-07-28: the completed status is missing its colours, and the
  // two places that print it should be connected through one component.
  // The pill and the Status row print the SAME
  // word, so a drift between them is a drift between two colours on one
  // string. This asserts they cannot: both Texts are found by the same finder
  // and must agree, for every state.
  //
  // The bug it pins is the one that shipped: the pill switched on all four
  // statuses while the row only coloured failed/cancelled, so Completed was a
  // green pill above a white "Completed".
  for (final status in TransactionStatus.values) {
    testWidgets('the pill and the Status row take one colour -- $status', (
      tester,
    ) async {
      await tester.pumpWidget(_app(_tx(status: status)));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      final label = status.name[0].toUpperCase() + status.name.substring(1);
      final texts = tester.widgetList<Text>(find.text(label)).toList();
      // Exactly two: the pill under the amount and the Status row's value. If
      // this ever finds one, a consumer was dropped rather than recoloured.
      expect(
        texts,
        hasLength(2),
        reason: 'pill + Status row both print $label',
      );
      expect(texts[0].style?.color, isNotNull);
      expect(texts[0].style?.color, texts[1].style?.color);
    });
  }
}
