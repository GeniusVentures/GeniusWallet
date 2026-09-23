import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// A token transfer: gas paid in ETH, the token that actually moved is USDC.
Transaction _tokenTx({int? chainId = 8453, String? assetSymbol = 'USDC'}) =>
    Transaction(
      hash: '0xabcdef0123456789abcdef0123456789abcdef0123456789',
      fromAddress: '0x1111222233334444555566667777888899990000',
      recipients: [
        TransferRecipients(
          toAddr: '0x5555666677778888999900001111222233334444',
          amount: '1.25',
        ),
      ],
      timeStamp: DateTime(2026, 9, 23, 18, 42),
      transactionDirection: TransactionDirection.sent,
      fees: '0.0042',
      coinSymbol: 'ETH',
      transactionStatus: TransactionStatus.completed,
      assetSymbol: assetSymbol,
      chainId: chainId,
    );

void main() {
  group('a token row reads its asset, not the gas coin', () {
    test('title names the asset', () {
      final content = txRowContent(_tokenTx(), prices: {});
      expect(content.title, 'USDC');
    });

    test('amount names the asset', () {
      final content = txRowContent(_tokenTx(), prices: {});
      expect(content.amount, contains('USDC'));
      expect(content.amount, isNot(contains('ETH')));
    });

    test('a row with neither field behaves exactly as today', () {
      final tx = _tokenTx(chainId: null, assetSymbol: null);
      final content = txRowContent(tx, prices: {});
      expect(content.title, 'ETH');
      expect(content.amount, contains('ETH'));
    });
  });

  group('the explorer link is keyed off the chain', () {
    test('8453 links to basescan', () {
      expect(
        explorerUrlFor(_tokenTx(chainId: 8453)),
        'https://basescan.org/tx/${_tokenTx().hash}',
      );
    });

    test('80002 links to Amoy', () {
      expect(
        explorerUrlFor(_tokenTx(chainId: 80002)),
        'https://amoy.polygonscan.com/tx/${_tokenTx().hash}',
      );
    });

    test('84531 (retired Base Goerli) shows no link', () {
      expect(explorerUrlFor(_tokenTx(chainId: 84531)), '');
    });

    test('no chainId falls back to the symbol lookup', () {
      final tx = _tokenTx(chainId: null, assetSymbol: null);
      expect(explorerUrlFor(tx), getExplorerUrl(tx.coinSymbol, tx.hash));
    });
  });

  group('the receipt drawer', () {
    Widget host(Transaction tx) => MaterialApp(
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

    testWidgets('Network Fee names the gas coin; no fee line names the asset', (
      tester,
    ) async {
      await tester.pumpWidget(host(_tokenTx()));
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();

      expect(find.text('0.0042 ETH'), findsOneWidget);
      expect(find.text('0.0042 USDC'), findsNothing);
    });
  });
}
