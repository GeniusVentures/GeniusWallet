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

Transaction _tx({TransactionStatus status = TransactionStatus.completed}) =>
    Transaction(
      hash: _hash,
      fromAddress: '0x1111222233334444555566667777888899990000',
      recipients: [TransferRecipients(toAddr: _toAddress, amount: '1.25')],
      timeStamp: DateTime(2026, 7, 20, 18, 42),
      transactionDirection: TransactionDirection.sent,
      fees: '0.00042',
      coinSymbol: 'ETH',
      transactionStatus: status,
      type: TransactionType.transfer,
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
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () => showTransactionDetails(context, _tx()),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );
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

  // Jakub, 2026-07-28: "status completed brakuje im kolorów - powinien być
  // przez komponent połączony". The pill and the Status row print the SAME
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
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(extensions: [GWColors.dark()]),
          home: Scaffold(
            body: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () =>
                    showTransactionDetails(context, _tx(status: status)),
                child: const Text('open'),
              ),
            ),
          ),
        ),
      );
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
