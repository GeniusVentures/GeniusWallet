// The amount on the desktop dashboard's Transactions panel, measured in real
// Inter: the number is drawn whole and the label beside it gives way instead.
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// The dashboard panel's row width on a desktop window.
const double _kPanelWidth = 376;

Future<void> _loadInter() async {
  final loader = FontLoader('Inter');
  for (final asset in const [
    'Inter-Regular.ttf',
    'Inter-Medium.ttf',
    'Inter-SemiBold.ttf',
  ]) {
    loader.addFont(rootBundle.load('assets/fonts/$asset'));
  }
  await loader.load();
}

Transaction _tx(String amount, String symbol, TransactionDirection direction) =>
    Transaction(
      hash: '0xabcdef0123456789abcdef0123456789abcdef0123456789',
      fromAddress: '0x1111222233334444555566667777888899990000',
      recipients: [
        TransferRecipients(
          toAddr: '0x5555666677778888999900001111222233334444',
          amount: amount,
        ),
      ],
      timeStamp: DateTime(2026, 7, 20, 18, 42),
      transactionDirection: direction,
      fees: '0.00042',
      coinSymbol: symbol,
      transactionStatus: TransactionStatus.pending,
      type: TransactionType.transfer,
    );

Widget _host(Transaction tx) => MaterialApp(
  theme: ThemeData(
    extensions: <ThemeExtension<dynamic>>[GWColors.dark()],
    textTheme: GeniusWalletTypography.toMaterialTextTheme(),
  ),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: _kPanelWidth,
        child: TransactionRow(tx: tx),
      ),
    ),
  ),
);

RenderParagraph _paragraphWith(WidgetTester tester, String needle) =>
    tester.renderObject<RenderParagraph>(
      find.byWidgetPredicate(
        (w) => w is Text && (w.data ?? '').contains(needle),
        description: 'the Text containing "$needle"',
      ),
    );

void main() {
  setUpAll(_loadInter);

  // The window must be desktop-sized so the row keeps its time column.
  for (final (amount, symbol, direction, shown) in const [
    ('476.18', 'USDC', TransactionDirection.received, '+ 476.18 USDC'),
    ('1.25', 'WSTETH', TransactionDirection.sent, '1.25 WSTETH'),
    ('1476.18', 'USDC', TransactionDirection.received, '+ 1,476.18 USDC'),
    ('12345.67', 'USDC', TransactionDirection.received, '+ 12,345.67 USDC'),
  ]) {
    testWidgets('"$shown" is drawn whole on the dashboard panel', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(1400, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(_host(_tx(amount, symbol, direction)));

      expect(_paragraphWith(tester, shown).didExceedMaxLines, isFalse);
      expect(tester.takeException(), isNull);
    });
  }
}
