/// MEASURES the app-wide row rhythm Jakub named on 2026-08-07 - painted ink,
/// never source padding - against the four constants in
/// `lib/components/cards/gw_row_rhythm.dart`:
/// [kGWRowWall] (8), [kGWRowIconSize] (38), [kGWRowIconToText] (8) and
/// [kGWRowSeparatorGap] (12), plus the derived [kGWRowTextColumnX] (54).
///
/// ---------------------------------------------------------------------
/// WHY PAINTED INK, NOT SOURCE PADDING
/// ---------------------------------------------------------------------
///
/// `SEPARATOR-RHYTHM-MEASURED.md`'s whole finding is that Assets and Markets
/// render 15.63/20.00 and 13.25/16.75 around their rule while NO line in this
/// repo declares either number - both come from a bare `ListTile` snapping to
/// Material's default two-line tile height and centring its content inside
/// it. Reading `contentPadding` or a `SizedBox` width would have missed that
/// slack entirely, which is the exact error `gw_section_title_rhythm_test
/// .dart`'s own doc comment describes at length for the section-title case.
/// This file measures the same way that one does: [firstPaintedTopBelow] and
/// its three twins below ([lastPaintedBottomAbove], [firstPaintedLeftIn],
/// [lastPaintedRightIn]) walk the render tree for the topmost/bottommost/
/// leftmost/rightmost thing that actually PAINTS, never a layout box.
///
/// ---------------------------------------------------------------------
/// REUSE, NOT RE-DERIVATION
/// ---------------------------------------------------------------------
///
/// [firstPaintedTopBelow] is imported directly from
/// `gw_section_title_rhythm_test.dart`, which declares `library;` and is
/// therefore a legal import target. `_paintsInk` and `_decorationPaints`,
/// which it closes over, are PRIVATE to that file (Dart privacy is
/// per-library/per-file) and cannot be imported - they are duplicated below
/// byte-for-byte, deliberately, because the source file is pinned: Task 5 of
/// the 260807-wbu plan is the only task allowed to touch it, and this task is
/// Task 1.
///
/// ---------------------------------------------------------------------
/// WHY STANDALONE ROWS PUMP AT 364, NOT WIDE
/// ---------------------------------------------------------------------
///
/// `gw_section_title_rhythm_test.dart` pumps its two `ListTile` row probes at
/// a WIDE 560 on purpose, because its probe title is a real coin name under
/// the widget-test harness's fallback font (roughly one em per character),
/// which can wrap a name that Inter never wraps on device. This file's probe
/// title is the fixed literal [_kProbeTitle] - five characters, chosen to be
/// short enough that no plausible per-row text budget in this file's cases
/// wraps it - so it can safely pump at 364, the phone card content box
/// `SEPARATOR-RHYTHM-MEASURED.md` measured (x = 13..377 at 390pt). Measuring
/// at the real width, not an artificially wide one, is what makes the walls
/// and the icon-to-text gap the numbers this file's cases actually assert.
///
/// ---------------------------------------------------------------------
/// WHY THE MARKETS PANEL HAS NO IN-HOST SEPARATOR CASE
/// ---------------------------------------------------------------------
///
/// `DashboardMarkets` fetches its coin list in `initState`, which this
/// harness cannot satisfy - the same limitation
/// `dashboard_section_caps_test.dart`'s own doc names for the same widget.
/// Its separator is a bare `Container(height: 1)` appended straight into a
/// `Column` with no padding of its own around it
/// (`dashboard_markets.dart:167`), so the rendered rule gap IS the two
/// neighbouring rows' own top/bottom insets - exactly what the
/// `CryptoSparkLineChart` STANDALONE case below already pins. No probe is
/// faked to cover it a second time.
///
/// ---------------------------------------------------------------------
/// BEFORE - measured 2026-08-07, this task's own run, phone window
/// (390x844 logical, dpr 3), from this file's own `debugPrint` output
/// ---------------------------------------------------------------------
///
/// | Case                                       | top   | bottom | left  | titleX | rule gap above/height/below | result |
/// | ------------------------------------------- | ----- | ------ | ----- | ------ | ---------------------------- | ------ |
/// | STANDALONE TransactionRow (the reference)    | 12.00 | 12.00  | 8.00  | 54.00  | n/a                          | GREEN  |
/// | STANDALONE CoinCardRow (Assets)              | 20.00 | 15.63  | 8.00  | 62.00  | n/a                          | RED    |
/// | STANDALONE CryptoSparkLineChart (Markets)    | 16.75 | 13.25  | 16.00 | 66.00  | n/a                          | RED    |
/// | IN-HOST SEPARATOR Transactions panel         | n/a   | n/a    | n/a   | n/a    | 12.00 / 1.00 / 12.00         | GREEN  |
/// | IN-HOST SEPARATOR Assets panel               | n/a   | n/a    | n/a   | n/a    | 15.63 / 1.00 / 20.00         | RED    |
///
/// `top`/`bottom` are the standalone row's OWN inset (content-box edge to its
/// first/last painted pixel); the separator cases' `above`/`below` are the
/// SAME quantity read on two neighbouring rows across a shared rule, which is
/// why Assets' standalone `bottom` (15.63) equals its separator `above`
/// (15.63) and its standalone `top` (20.00) equals its separator `below`
/// (20.00) - one row's bottom inset is what sits above the rule that follows
/// it, and the next row's top inset is what sits below it.
///
/// 2 passed, 3 failed - `flutter test test/components/gw_row_rhythm_test.dart`
/// reports exactly this split. Every RED number above is a real `ListTile`
/// snap or default, not a bug in this file; Wave 2 (Tasks 2-4) is what turns
/// each one GREEN.
///
/// ---------------------------------------------------------------------
/// AFTER - measured 2026-08-08, Task 5's own run, same phone window, once
/// Wave 2 (Tasks 2-4) landed
/// ---------------------------------------------------------------------
///
/// | Case                                       | top   | bottom | left  | titleX | rule gap above/height/below | result |
/// | ------------------------------------------- | ----- | ------ | ----- | ------ | ---------------------------- | ------ |
/// | STANDALONE TransactionRow (the reference)    | 12.00 | 12.00  | 8.00  | 54.00  | n/a                          | GREEN  |
/// | STANDALONE CoinCardRow (Assets)              | 12.00 | 12.00  | 8.00  | 54.00  | n/a                          | GREEN  |
/// | STANDALONE CryptoSparkLineChart (Markets)    | 12.00 | 12.00  | 8.00  | 54.00  | n/a                          | GREEN  |
/// | IN-HOST SEPARATOR Transactions panel         | n/a   | n/a    | n/a   | n/a    | 12.00 / 1.00 / 12.00         | GREEN  |
/// | IN-HOST SEPARATOR Assets panel               | n/a   | n/a    | n/a   | n/a    | 12.00 / 1.00 / 12.00         | GREEN  |
///
/// 5 passed, 0 failed. Every row that was RED in the BEFORE table above now
/// reads the identical five numbers the reference `TransactionRow` always
/// shipped: 12 top, 12 bottom, 8 left, a text column at 54, and a symmetric
/// 12 / 1 / 12 rule. The Markets panel has no in-host separator case (see
/// "WHY THE MARKETS PANEL HAS NO IN-HOST SEPARATOR CASE" above) - its
/// STANDALONE case above is what the panel's real rule gap now derives from.
library;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/genius_api.dart' show GeniusApi;
import 'package:genius_api/models/coin.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/cards/gw_row_rhythm.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/components/coins/view/coins_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/providers/network_tokens_provider.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/wallets/cubit/wallet_details_cubit.dart';

// See the "REUSE, NOT RE-DERIVATION" doc section above.
import 'gw_section_title_rhythm_test.dart' show firstPaintedTopBelow;

/// The probe title every row case below renders, instead of a real coin name
/// or token symbol - see "WHY STANDALONE ROWS PUMP AT 364" above.
const String _kProbeTitle = 'ROWX';

// ---------------------------------------------------------------------------
// Ink-measurement primitives - duplicated from `gw_section_title_rhythm_test
// .dart` (private there; see the doc comment above), plus the three twins
// that file's own doc says it deleted after use: `lastPaintedBottomAbove`,
// `firstPaintedLeftIn` and `lastPaintedRightIn`.
// ---------------------------------------------------------------------------

/// Whether [w]'s render object actually puts ink on the screen. Byte-for-byte
/// the same predicate `gw_section_title_rhythm_test.dart` uses, duplicated
/// because it is private there.
bool _paintsInk(Widget w) {
  // Text, Icon and every label.
  if (w is RichText) {
    return true;
  }
  // Image.
  if (w is RawImage) {
    return true;
  }
  if (w is ColoredBox) {
    return w.color.a > 0;
  }
  if (w is DecoratedBox) {
    return _decorationPaints(w.decoration);
  }
  if (w is CustomPaint) {
    return w.painter != null || w.foregroundPainter != null;
  }
  // EXTENSION beyond `gw_section_title_rhythm_test.dart`'s version, needed
  // because this file measures `CryptoSparkLineChart`, which that file never
  // had to: fl_chart's `LineChart` paints through `LineChartLeaf`, a
  // `LeafRenderObjectWidget` with its own `RenderBox` subclass - not the
  // built-in `CustomPaint`/`CustomPainter` pair the checks above cover. A
  // leaf render object widget has no widget CHILD by construction, so - like
  // `RichText`, `RawImage` and a filled `DecoratedBox` above - if it is in
  // the tree at all it is there to paint something, never to just take up
  // space (that is what `SizedBox`, `Padding` and `ConstrainedBox` are for,
  // and none of those is a `LeafRenderObjectWidget`). Without this the
  // sparkline's own ink is invisible to every measurement in this file and
  // the rightmost thing found is whatever paints just to its left.
  if (w is LeafRenderObjectWidget) {
    return true;
  }
  return false;
}

bool _decorationPaints(Decoration d) {
  if (d is BoxDecoration) {
    return (d.color?.a ?? 0) > 0 ||
        d.gradient != null ||
        d.image != null ||
        d.border != null ||
        (d.boxShadow?.isNotEmpty ?? false);
  }
  if (d is ShapeDecoration) {
    return (d.color?.a ?? 0) > 0 || d.gradient != null || d.image != null;
  }
  return true;
}

/// Every painted `Element` inside [subtree], read directly off the render
/// tree rather than round-tripping through `find.byWidget` (not
/// identity-stable when a row repeats).
Iterable<Element> _paintedElements(Finder subtree) => find
    .descendant(
      of: subtree,
      matching: find.byWidgetPredicate(_paintsInk, description: 'paints ink'),
      matchRoot: true,
    )
    .evaluate();

/// Twin of [firstPaintedTopBelow]: the bottommost painted pixel inside
/// [subtree] that ENDS at or above [y].
double lastPaintedBottomAbove(WidgetTester tester, Finder subtree, double y) {
  double? best;
  for (final Element e in _paintedElements(subtree)) {
    final RenderObject? ro = e.renderObject;
    if (ro is! RenderBox || !ro.hasSize || ro.size.isEmpty) {
      continue;
    }
    final double bottom = ro.localToGlobal(Offset.zero).dy + ro.size.height;
    if (bottom > y + 0.01) {
      continue;
    }
    if (best == null || bottom > best) {
      best = bottom;
    }
  }
  expect(
    best,
    isNotNull,
    reason:
        'no painted render object found above y=$y - the subtree finder is '
        'wrong, not the layout',
  );
  return best!;
}

/// Twin: the leftmost painted pixel inside [subtree] - no `y` bound, because
/// this reads a row's own left wall rather than a position relative to a
/// rule.
double firstPaintedLeftIn(WidgetTester tester, Finder subtree) {
  double? best;
  for (final Element e in _paintedElements(subtree)) {
    final RenderObject? ro = e.renderObject;
    if (ro is! RenderBox || !ro.hasSize || ro.size.isEmpty) {
      continue;
    }
    final double left = ro.localToGlobal(Offset.zero).dx;
    if (best == null || left < best) {
      best = left;
    }
  }
  expect(
    best,
    isNotNull,
    reason: 'no painted render object found in the subtree',
  );
  return best!;
}

/// Twin: the rightmost painted pixel inside [subtree].
double lastPaintedRightIn(WidgetTester tester, Finder subtree) {
  double? best;
  for (final Element e in _paintedElements(subtree)) {
    final RenderObject? ro = e.renderObject;
    if (ro is! RenderBox || !ro.hasSize || ro.size.isEmpty) {
      continue;
    }
    final double right = ro.localToGlobal(Offset.zero).dx + ro.size.width;
    if (best == null || right > best) {
      best = right;
    }
  }
  expect(
    best,
    isNotNull,
    reason: 'no painted render object found in the subtree',
  );
  return best!;
}

// ---------------------------------------------------------------------------
// Fixtures
// ---------------------------------------------------------------------------

/// A real 390pt iPhone width at 3x density, matching the window
/// `SEPARATOR-RHYTHM-MEASURED.md`'s probes ran under. Every case in this file
/// sets this before pumping - `compact` in `transaction_displays.dart` reads
/// the WINDOW, not a row's own constraints, and mobile is this task's whole
/// target.
void _setPhoneWindow(WidgetTester tester) {
  tester.view.physicalSize = const Size(390 * 3, 844 * 3);
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Transaction _tx({required DateTime at, String hash = '0xabc'}) => Transaction(
  hash: hash,
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: at,
  transactionDirection: TransactionDirection.sent,
  fees: '0.001',
  coinSymbol: _kProbeTitle,
  transactionStatus: TransactionStatus.completed,
  type: TransactionType.transfer,
);

/// [WalletDetailsCubit] takes a [GeniusApi] `CoinsScreen` only touches
/// through `getCoins()`, which nothing here triggers - same four-line
/// apparatus `dashboard_section_caps_test.dart` and `assets_screen_test.dart`
/// use, and it throws loudly rather than returning a silent null if that ever
/// stops being true.
class _UnusedApi implements GeniusApi {
  @override
  dynamic noSuchMethod(Invocation i) => super.noSuchMethod(i);
}

Coin _coin(String symbol, {required double balance}) =>
    Coin(name: symbol, symbol: symbol, iconPath: '', balance: balance);

// ---------------------------------------------------------------------------
// Standalone row hosts - each pumped in a 364-wide box, the phone card
// content box `SEPARATOR-RHYTHM-MEASURED.md` measured (x = 13..377 at
// 390pt).
// ---------------------------------------------------------------------------

const double _kRowContentWidth = 364;

Widget _txHost(Transaction tx) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: _kRowContentWidth,
        child: TransactionRow(tx: tx),
      ),
    ),
  ),
);

Widget _coinRowHost() => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: const Scaffold(
    body: Center(
      child: SizedBox(
        width: _kRowContentWidth,
        child: CoinCardRow(
          iconPath: '',
          name: _kProbeTitle,
          symbol: _kProbeTitle,
          balance: 1,
        ),
      ),
    ),
  ),
);

Widget _marketsRowHost() => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: const Scaffold(
    body: Center(
      child: SizedBox(
        width: _kRowContentWidth,
        child: CryptoSparkLineChart(
          title: _kProbeTitle,
          symbol: 'BTC',
          currentPrice: 1.23,
          high24h: 1.5,
          low24h: 1.0,
          priceChangePercent: 2.5,
          sparkline: [1.0, 1.1, 1.2, 1.3],
        ),
      ),
    ),
  ),
);

/// Measures and asserts the five numbers a standalone row must render:
/// [kGWRowSeparatorGap] top, [kGWRowSeparatorGap] bottom, [kGWRowWall] left,
/// [kGWRowWall] right, and [kGWRowTextColumnX] for the title's left edge -
/// which pins the glyph size and the glyph-to-text gap JOINTLY, without
/// having to find three different glyph widgets across three different row
/// anatomies (a coin image, a `LineChart` sparkline, a badge-overlaid
/// identity stack).
void _expectStandaloneRowRhythm(WidgetTester tester, {required String label}) {
  final Finder row = find.byWidgetPredicate(
    (w) => w is TransactionRow || w is CoinCardRow || w is CryptoSparkLineChart,
    description: 'the row under test',
  );
  final Rect box = tester.getRect(row);

  final double topInset = firstPaintedTopBelow(tester, row, box.top) - box.top;
  final double bottomInset =
      box.bottom - lastPaintedBottomAbove(tester, row, box.bottom);
  final double leftInset = firstPaintedLeftIn(tester, row) - box.left;
  final double rightInset = box.right - lastPaintedRightIn(tester, row);
  final double titleX = tester.getRect(find.text(_kProbeTitle)).left - box.left;

  debugPrint(
    'RHYTHM-ROW | ${label.padRight(34)} '
    'top=${topInset.toStringAsFixed(2).padLeft(6)} '
    'bottom=${bottomInset.toStringAsFixed(2).padLeft(6)} '
    'left=${leftInset.toStringAsFixed(2).padLeft(6)} '
    'right=${rightInset.toStringAsFixed(2).padLeft(6)} '
    'titleX=${titleX.toStringAsFixed(2).padLeft(6)}',
  );

  expect(
    topInset,
    closeTo(kGWRowSeparatorGap, 0.5),
    reason: '$label: top inset (measured $topInset)',
  );
  expect(
    bottomInset,
    closeTo(kGWRowSeparatorGap, 0.5),
    reason: '$label: bottom inset (measured $bottomInset)',
  );
  expect(
    leftInset,
    closeTo(kGWRowWall, 0.5),
    reason: '$label: left wall / first ink x (measured $leftInset)',
  );
  expect(
    rightInset,
    closeTo(kGWRowWall, 0.5),
    reason: '$label: right wall (measured $rightInset)',
  );
  expect(
    titleX,
    closeTo(kGWRowTextColumnX, 0.5),
    reason:
        '$label: text column x - pins glyph size + glyph-to-text gap jointly '
        '(measured $titleX)',
  );
}

// ---------------------------------------------------------------------------
// In-host separator hosts.
// ---------------------------------------------------------------------------

Widget _transactionsPanelHost(List<Transaction> txs) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SizedBox(
      width: _kRowContentWidth,
      height: 400,
      child: TransactionsSlimView(transactions: txs),
    ),
  ),
);

Widget _assetsPanelHost(List<Coin> coins) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: BlocProvider<WalletDetailsCubit>(
      create: (_) => WalletDetailsCubit(
        initialState: WalletDetailsState(
          coins: coins,
          coinsStatus: WalletStatus.successful,
        ),
        geniusApi: _UnusedApi(),
        networkTokensProvider: NetworkTokensProvider(),
      ),
      child: const SingleChildScrollView(
        child: SizedBox(width: 900, child: CoinsScreen(onCoinSelected: null)),
      ),
    ),
  ),
);

/// Measures and asserts the rule gap for the first `Divider` found inside
/// [host]: [kGWRowSeparatorGap] above, 1 for the rule's own height,
/// [kGWRowSeparatorGap] below.
void _expectSeparatorRhythm(
  WidgetTester tester, {
  required String label,
  required Finder host,
}) {
  final Rect rule = tester.getRect(find.byType(Divider).first);
  final double gapAbove =
      rule.top - lastPaintedBottomAbove(tester, host, rule.top);
  final double gapBelow =
      firstPaintedTopBelow(tester, host, rule.bottom) - rule.bottom;

  debugPrint(
    'RHYTHM-SEP | ${label.padRight(34)} '
    'above=${gapAbove.toStringAsFixed(2).padLeft(6)} '
    'ruleHeight=${rule.height.toStringAsFixed(2).padLeft(6)} '
    'below=${gapBelow.toStringAsFixed(2).padLeft(6)}',
  );

  expect(
    gapAbove,
    closeTo(kGWRowSeparatorGap, 0.5),
    reason: '$label: gap above the rule (measured $gapAbove)',
  );
  expect(
    rule.height,
    closeTo(1, 0.5),
    reason: '$label: the rule itself is 1px (measured ${rule.height})',
  );
  expect(
    gapBelow,
    closeTo(kGWRowSeparatorGap, 0.5),
    reason: '$label: gap below the rule (measured $gapBelow)',
  );
}

// ---------------------------------------------------------------------------

void main() {
  group('STANDALONE - one row, no host chrome', () {
    testWidgets('TransactionRow (the reference - ships the spec already)', (
      tester,
    ) async {
      _setPhoneWindow(tester);
      await tester.pumpWidget(_txHost(_tx(at: DateTime(2026, 8, 7, 10))));
      await tester.pump();
      expect(tester.takeException(), isNull);

      _expectStandaloneRowRhythm(tester, label: 'TransactionRow');
    });

    testWidgets('CoinCardRow (Assets) - RED until Task 2 lands', (
      tester,
    ) async {
      _setPhoneWindow(tester);
      await tester.pumpWidget(_coinRowHost());
      await tester.pump();
      expect(tester.takeException(), isNull);

      _expectStandaloneRowRhythm(tester, label: 'CoinCardRow');
    });

    testWidgets('CryptoSparkLineChart (Markets) - RED until Task 3 lands', (
      tester,
    ) async {
      _setPhoneWindow(tester);
      await tester.pumpWidget(_marketsRowHost());
      await tester.pump();
      expect(tester.takeException(), isNull);

      _expectStandaloneRowRhythm(tester, label: 'CryptoSparkLineChart');
    });
  });

  group('IN-HOST SEPARATOR - the rule between two real rows', () {
    testWidgets('Transactions panel - GREEN already', (tester) async {
      _setPhoneWindow(tester);
      final DateTime day = DateTime(2026, 8, 7);
      final txs = [
        _tx(at: day.add(const Duration(hours: 11)), hash: '0xaaa'),
        _tx(at: day.add(const Duration(hours: 9)), hash: '0xbbb'),
      ];
      await tester.pumpWidget(_transactionsPanelHost(txs));
      await tester.pump();
      expect(tester.takeException(), isNull);

      _expectSeparatorRhythm(
        tester,
        label: 'Transactions panel',
        host: find.byType(TransactionsSlimView),
      );
    });

    testWidgets('Assets panel - RED until Task 2 lands', (tester) async {
      _setPhoneWindow(tester);
      final coins = [_coin('AAA', balance: 3), _coin('BBB', balance: 5)];
      await tester.pumpWidget(_assetsPanelHost(coins));
      await tester.pump();
      expect(tester.takeException(), isNull);

      _expectSeparatorRhythm(
        tester,
        label: 'Assets panel',
        host: find.byType(CoinsScreen),
      );
    });

    // No Markets panel case here - see "WHY THE MARKETS PANEL HAS NO IN-HOST
    // SEPARATOR CASE" in this file's library doc.
  });
}
