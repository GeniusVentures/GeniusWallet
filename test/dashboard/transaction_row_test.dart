import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:hive_ce/hive.dart';

/// The ONE check 12-03's row owes.
///
/// 12-02's 40 unit tests already pin every string the row prints; what they
/// cannot see is whether those strings FIT. This file is the smallest thing
/// that fails if the anatomy breaks: it renders the real widget at the
/// narrowest width the transactions panel ever gets, for all seven
/// `TransactionType` values plus the two non-happy-path statuses, and fails on
/// any RenderFlex overflow.
///
/// It is also the first execution of `livePricesBySymbol()` — with no Hive
/// binding, its `Hive.isBoxOpen` guard must return `const {}` rather than
/// throw. A regression there would make every row in this file throw.

Transaction _tx({
  TransactionType? type,
  TransactionStatus status = TransactionStatus.completed,
  TransactionDirection direction = TransactionDirection.sent,
  String amount = '1.25',
  String coinSymbol = 'ETH',
}) => Transaction(
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
  coinSymbol: coinSymbol,
  transactionStatus: status,
  type: type,
  fromAmount: '1.5',
  toAmount: '2400.75',
  fromSymbol: 'ETH',
  toSymbol: 'GNUS',
  exchangeRate: '1600.5',
);

Widget _host(Transaction tx, {required double width, required GWColors gw}) =>
    MaterialApp(
      theme: ThemeData(extensions: [gw]),
      home: Scaffold(
        body: Center(
          child: SizedBox(width: width, child: TransactionRow(tx: tx)),
        ),
      ),
    );

void main() {
  // 320 is narrower than the dashboard's right-hand transactions column ever
  // gets; 900 is the full-page /transactions route. Both mount the same row.
  const widths = <double>[320, 900];

  final cases = <String, Transaction>{
    'transfer sent': _tx(type: TransactionType.transfer),
    'transfer received': _tx(
      type: TransactionType.transfer,
      direction: TransactionDirection.received,
    ),
    'null type': _tx(),
    'mint': _tx(type: TransactionType.mint),
    'escrow': _tx(type: TransactionType.escrow),
    'escrowRelease': _tx(type: TransactionType.escrowRelease),
    'process': _tx(type: TransactionType.process),
    'purchase': _tx(type: TransactionType.purchase),
    'swap': _tx(type: TransactionType.swap),
    'pending': _tx(
      type: TransactionType.transfer,
      status: TransactionStatus.pending,
    ),
    'failed': _tx(
      type: TransactionType.transfer,
      status: TransactionStatus.failed,
    ),
    // The whale sketch 010 measured setting the panel's width, and a symbol
    // long enough to blow the identity slot's asset name.
    'whale amount + long symbol': _tx(
      amount: '123456789.123456789123456789',
      coinSymbol: 'WRAPPEDSTAKEDETHEREUM',
    ),
  };

  for (final appearance in {'dark': GWColors.dark(), 'light': GWColors.light()}
      .entries) {
    for (final width in widths) {
      for (final entry in cases.entries) {
        testWidgets(
          'row fits: ${entry.key} @ ${width.toInt()}px (${appearance.key})',
          (tester) async {
            await tester.pumpWidget(
              _host(entry.value, width: width, gw: appearance.value),
            );
            // A RenderFlex overflow is reported as a FlutterError, which
            // takeException() surfaces. Null means the row laid out clean.
            expect(tester.takeException(), isNull);

            // The anatomy: every type carries a badge. `escrowRelease` and
            // `process` used to render as a bare `ListTile` string with no
            // icon at all — that is the regression this line guards.
            expect(find.byType(TransactionBadge), findsOneWidget);
          },
        );
      }
    }
  }

  // Declared LAST on purpose: it opens a real Hive box, and every row test
  // above must run against the closed-box path (`const {}`) it also asserts.
  group('livePricesBySymbol against a real box', () {
    late Directory dir;

    setUp(() async {
      dir = await Directory.systemTemp.createTemp('gw_market_box');
      Hive.init(dir.path);
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(CoinGeckoMarketDataAdapter());
      }
    });

    tearDown(() async {
      await Hive.deleteBoxFromDisk(marketDataBox);
      await Hive.close();
      await dir.delete(recursive: true);
    });

    test('closed box yields an empty map instead of throwing', () {
      expect(Hive.isBoxOpen(marketDataBox), isFalse);
      expect(livePricesBySymbol(), isEmpty);
    });

    test('open box is read with the app\'s own value typing', () async {
      // `Hive.box<CoinGeckoMarketData>` THROWS if the box was opened with a
      // different value type, so this also pins the typing against init.dart.
      final box = await Hive.openBox<CoinGeckoMarketData>(marketDataBox);
      await box.put(
        'ethereum',
        CoinGeckoMarketData(
          id: 'ethereum',
          symbol: 'ETH',
          name: 'Ethereum',
          imageUrl: '',
          currentPrice: 2400.0,
          marketCap: 0,
          marketCapRank: 0,
          fullyDilutedValuation: 0,
          totalVolume: 0,
          high24h: 0,
          low24h: 0,
          priceChange24h: 0,
          priceChangePercentage24h: 0,
          marketCapChange24h: 0,
          marketCapChangePercentage24h: 0,
          circulatingSupply: 0,
          totalSupply: 0,
          maxSupply: 0,
          ath: 0,
          athChangePercentage: 0,
          athDate: DateTime(2026),
          atl: 0,
          atlChangePercentage: 0,
          atlDate: DateTime(2026),
          lastUpdated: DateTime(2026),
          sparkline: const [],
        ),
      );

      // Keyed by LOWERCASE symbol — `fiatValue` looks up with `toLowerCase()`,
      // so an upper-cased key here would silently drop every fiat line.
      expect(livePricesBySymbol(), {'eth': 2400.0});
    });
  });
}
