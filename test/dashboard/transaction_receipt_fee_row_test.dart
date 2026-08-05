import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// 08-05 Task 1: `showTransactionDetails`'s Network Fee row must skip-empty
/// exactly like the neighbouring Rate row already does (`add('Rate', tx.exchangeRate ?? '')`).
/// Today the row's value composes `'${formatTxAmount(tx.fees)} ${tx.coinSymbol}'`,
/// so it is NEVER blank even when `fees` is — a blank fee renders a lone coin
/// symbol instead of no row at all. This is the defect the guard closes.
Transaction _tx({
  required String fees,
  TransactionType? type,
  String fromAmount = '1.5',
  String toAmount = '2400.75',
  String hash = '0xabcdef0123456789abcdef0123456789abcdef0123456789',
}) => Transaction(
  hash: hash,
  fromAddress: '0x1111222233334444555566667777888899990000',
  recipients: const [],
  timeStamp: DateTime(2026, 7, 20, 18, 42),
  transactionDirection: TransactionDirection.sent,
  fees: fees,
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: type,
  fromAmount: fromAmount,
  toAmount: toAmount,
  fromSymbol: 'ETH',
  toSymbol: 'USDC',
);

Widget _host(Transaction tx) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Builder(
    builder: (context) => Scaffold(
      body: Center(
        child: ElevatedButton(
          onPressed: () => showTransactionDetails(context, tx),
          child: const Text('open'),
        ),
      ),
    ),
  ),
);

void main() {
  testWidgets('non-blank fee still renders the Network Fee row (unchanged)', (
    tester,
  ) async {
    await tester.pumpWidget(_host(_tx(fees: '0.0042')));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Network Fee'), findsOneWidget);
  });

  testWidgets('blank fee omits the Network Fee row entirely', (tester) async {
    await tester.pumpWidget(_host(_tx(fees: '')));
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Network Fee'), findsNothing);
  });

  testWidgets(
    'swap-shaped transaction (blank fees, empty hash) renders From/To and '
    'omits Network Fee',
    (tester) async {
      await tester.pumpWidget(
        _host(_tx(fees: '', type: TransactionType.swap, hash: '')),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('From'), findsOneWidget);
      expect(find.text('To'), findsOneWidget);
      expect(find.text('Network Fee'), findsNothing);
    },
  );
}
