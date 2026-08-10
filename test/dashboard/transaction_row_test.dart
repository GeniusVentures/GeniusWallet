import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_badge.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_utils.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
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
          child: SizedBox(
            width: width,
            child: TransactionRow(tx: tx),
          ),
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

  for (final appearance in {
    'dark': GWColors.dark(),
    'light': GWColors.light(),
  }.entries) {
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

  // WHY THIS TEST EXISTS (260807-ubg): 260806-hfe's merge gated every font
  // size in this row on `compact`, and `compact` reads the WINDOW
  // (`GeniusBreakpoints.useDesktopLayout`), not this row's own constraints -
  // so it is true on every phone surface, the Home dashboard panel included.
  // Every host above and every host in `transaction_row_subtitle_test.dart`
  // pumps into the default 800x600 test window, so `compact` has always been
  // false there and none of them could have caught a phone-only shrink. This
  // is the one test in either file that sets a real phone window, and it is
  // the guard for that specific blind spot.
  group('phone-width type scale (260807-ubg)', () {
    testWidgets(
      'phone window: title/subtitle/amount paint at the token sizes, not a '
      'compact override',
      (tester) async {
        // A real 390pt iPhone width at 3x density - makes `compact` true.
        tester.view.physicalSize = const Size(390 * 3, 844 * 3);
        tester.view.devicePixelRatio = 3.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final gw = GWColors.dark();
        final tx = _tx(type: TransactionType.transfer);
        final content = txRowContent(tx, prices: const <String, double>{});
        // 366: the phone content box the plan derives (PLAN Finding 2).
        await tester.pumpWidget(_host(tx, width: 366, gw: gw));
        expect(tester.takeException(), isNull);

        // This harness runs the fallback one-em-per-character font - that is
        // fine here, because every assertion below reads a resolved STYLE
        // property, never a measured width.
        double? styleFontSize(Finder finder) =>
            tester.renderObject<RenderParagraph>(finder).text.style?.fontSize;

        // Content-addressed, like `transaction_row_subtitle_test.dart`'s
        // `_paragraphWith`: resolves the same paragraph before and after the
        // anatomy change instead of relying on tree position.
        RenderParagraph paragraphWith(String needle) =>
            tester.renderObject<RenderParagraph>(
              find.byWidgetPredicate(
                (w) =>
                    w is Text &&
                    (w.data ?? w.textSpan?.toPlainText() ?? '').contains(
                      needle,
                    ),
                description: 'the Text containing "$needle"',
              ),
            );

        // Read from the TOKEN, never a literal: a deliberate future token
        // change moves this test with it, and only a re-introduced local
        // `fontSize` override reddens it.
        expect(
          styleFontSize(find.text(content.title)),
          GeniusWalletTypography.titleMd.fontSize,
          reason: 'the title should paint at titleMd, not a compact override',
        );

        final subtitleRp = paragraphWith(content.subtitleLead!);
        expect(
          (subtitleRp.text as TextSpan).style?.fontSize,
          GeniusWalletTypography.bodySm.fontSize,
          reason:
              'the subtitle paragraph should paint at bodySm, not a compact '
              'override',
        );

        expect(
          styleFontSize(find.text(content.amount)),
          16,
          reason: 'the amount should always paint at 16',
        );
      },
    );
  });

  // The Status pill is a WIDE-only affordance (sketch 030-A2). On the wide page
  // the status is a pill; on the narrow panel it is the subtitle line's pinned
  // right-hand tail (sketch 179-C, which moved it out of the subtitle string and
  // dropped its leading middle dot). This pins that the status is stated exactly
  // ONCE in each presentation, never twice and never zero times - the whole
  // point of `subtitleBase`/`status`/`statusTail` on TxRowContent.
  //
  // Each case pins WHICH element states it. Before sketch 186 scheme A that was
  // colour: `gw.statusError` for the pill, `gw.textSecondary` for the tail.
  // 186-A retires that distinction on purpose - the tail's ink is now
  // `txStatusColors(content.status, gw).fg`, the SAME function `_statusPill`
  // already uses, so a failed row's tail reads `gw.statusError` too (colour
  // freed from the amount column, spent on the one thing a sign glyph cannot
  // say). What still tells pill and tail apart is SIZE: the pill's label is
  // `labelMd` (13), the tail is `bodySm` (14) - the same size the subtitle
  // paragraph beside it takes, because the tail is subtitle text with a status
  // ink, not a miniature pill. A pill that leaked onto the panel would still
  // read at 13, not 14.
  group('wide-page Status pill (030-A2) and narrow tail (179-C)', () {
    final failed = _tx(status: TransactionStatus.failed);

    testWidgets('wide (900): the status is the pill, and only the pill', (
      tester,
    ) async {
      final gw = GWColors.dark();
      await tester.pumpWidget(_host(failed, width: 900, gw: gw));
      expect(tester.takeException(), isNull);
      // Stated exactly once…
      expect(find.text('Failed'), findsOneWidget);
      // …by the PILL, whose label takes the status colour at the pill's size.
      final pillText = tester.widget<Text>(find.text('Failed'));
      expect(pillText.style?.color, gw.statusError);
      expect(pillText.style?.fontSize, GeniusWalletTypography.labelMd.fontSize);
      // …and the subtitle does not also carry it, in either shape.
      expect(find.textContaining('· Failed'), findsNothing);
    });

    testWidgets('narrow (320): the status is the subtitle tail, and only that', (
      tester,
    ) async {
      final gw = GWColors.dark();
      await tester.pumpWidget(_host(failed, width: 320, gw: gw));
      expect(tester.takeException(), isNull);
      // Stated exactly once…
      expect(find.text('Failed'), findsOneWidget);
      // …by the TAIL: sketch 186 scheme A gives it the SAME status ink the
      // pill uses (`txStatusColors`, so a failed row's tail is
      // `gw.statusError` here too - see the group doc above) but at the
      // subtitle's `bodySm` size, not the pill's `labelMd`. Size, not colour,
      // is what fails if the pill ever leaks onto the panel now.
      final tailText = tester.widget<Text>(find.text('Failed'));
      expect(tailText.style?.color, gw.statusError);
      expect(tailText.style?.fontSize, GeniusWalletTypography.bodySm.fontSize);
      expect(
        tailText.style?.fontSize,
        isNot(GeniusWalletTypography.labelMd.fontSize),
      );
      // The tail carries no leading middle dot: it is a separate, right-pinned
      // element, and the 8px a dot costs is width the verb needs.
      expect(find.textContaining('· Failed'), findsNothing);
    });

    testWidgets(
      'narrow (320): a cancelled row keeps its tail neutral, unlike failed',
      (tester) async {
        // 186-A routes the tail through `txStatusColors`, which is already
        // correct for all four statuses (`_statusPill`'s own doc) - cancelled
        // stays `textSecondary`, the one status this change does NOT redden.
        final gw = GWColors.dark();
        final cancelled = _tx(status: TransactionStatus.cancelled);
        await tester.pumpWidget(_host(cancelled, width: 320, gw: gw));
        expect(tester.takeException(), isNull);
        expect(find.text('Cancelled'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('Cancelled')).style?.color,
          gw.textSecondary,
        );
      },
    );
  });

  // Sketch 186 scheme A + lead L2, Jakub approved on device 2026-08-08
  // (quick task 260808-k2l). Pinned against TOKENS, never literal colour
  // values, so a future palette edit moves these tests with it.
  group('sketch 186 scheme A (amount tone, always-on value line) + lead L2', () {
    testWidgets(
      'the amount is textPrimary for BOTH an incoming and an outgoing row - '
      'the asymmetry cannot return silently',
      (tester) async {
        final gw = GWColors.dark();
        final outgoing = _tx(
          type: TransactionType.transfer,
          direction: TransactionDirection.sent,
        );
        final incoming = _tx(
          type: TransactionType.transfer,
          direction: TransactionDirection.received,
        );

        await tester.pumpWidget(_host(outgoing, width: 320, gw: gw));
        final outgoingAmount = txRowContent(
          outgoing,
          prices: const <String, double>{},
        ).amount;
        expect(
          tester.widget<Text>(find.text(outgoingAmount)).style?.color,
          gw.textPrimary,
        );

        await tester.pumpWidget(_host(incoming, width: 320, gw: gw));
        final incomingAmount = txRowContent(
          incoming,
          prices: const <String, double>{},
        ).amount;
        final incomingStyle = tester
            .widget<Text>(find.text(incomingAmount))
            .style;
        expect(incomingStyle?.color, gw.textPrimary);
        // The regression this guards: a credit quietly getting its green back.
        expect(incomingStyle?.color, isNot(gw.statusSuccess));
      },
    );

    testWidgets(
      'a row whose price is unknown still renders a second line, reading '
      '"No price"',
      (tester) async {
        final gw = GWColors.dark();
        // The default fixture's ETH carries no price in this file - no Hive
        // box is opened here and `DevMockHoldings` is never touched, so
        // `livePricesBySymbol()` resolves to `const {}` for every case above
        // too (see the closed-box group's own test of that fact, declared
        // last in this file).
        final unpriced = _tx(type: TransactionType.transfer);
        await tester.pumpWidget(_host(unpriced, width: 320, gw: gw));
        expect(tester.takeException(), isNull);
        expect(find.text('No price'), findsOneWidget);
        expect(
          tester.widget<Text>(find.text('No price')).style?.color,
          gw.textSecondary,
        );
      },
    );

    testWidgets('a failed row still reads "Not charged", and its value line is '
        'statusError', (tester) async {
      final gw = GWColors.dark();
      final failed = _tx(status: TransactionStatus.failed);
      await tester.pumpWidget(_host(failed, width: 320, gw: gw));
      expect(tester.takeException(), isNull);
      expect(find.text('Not charged'), findsOneWidget);
      expect(
        tester.widget<Text>(find.text('Not charged')).style?.color,
        gw.statusError,
      );
    });

    testWidgets('the subtitle lead is textPrimary70 (lead L2)', (tester) async {
      final gw = GWColors.dark();
      final tx = _tx(type: TransactionType.transfer);
      final content = txRowContent(tx, prices: const <String, double>{});
      await tester.pumpWidget(_host(tx, width: 320, gw: gw));
      expect(tester.takeException(), isNull);

      // Read from the WIDGET's own `TextSpan` tree, not a resolved/merged
      // paragraph style: the lead's colour is a literal set directly on its
      // span, and this is the one `Text.rich` in the row.
      final richText = tester.widget<Text>(
        find.byWidgetPredicate((w) => w is Text && w.textSpan != null),
      );
      final rootSpan = richText.textSpan! as TextSpan;
      final leadSpan = rootSpan.children!.first as TextSpan;
      expect(leadSpan.text, content.subtitleLead);
      expect(leadSpan.style?.color, gw.textPrimary70);
      // The regression this guards: the lead quietly collapsing back onto the
      // ticker's ink, which is complaint 1 this lead treatment exists to fix.
      expect(leadSpan.style?.color, isNot(gw.textPrimary));
    });
  });

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
