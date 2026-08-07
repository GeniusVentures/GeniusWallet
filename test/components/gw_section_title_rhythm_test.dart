/// MEASURES the vertical rhythm around [GWSectionTitle] instead of believing
/// the comments that describe it, then ASSERTS the result.
///
/// ---------------------------------------------------------------------
/// THE TWO NUMBERS
/// ---------------------------------------------------------------------
///
/// For a section S that mounts a [GWSectionTitle]:
///
///   R1(S) = titleLineBox.top   - boxContentTop(S)      // box -> title
///   R2(S) = firstPaintedTop(S) - titleLineBox.bottom   // title -> content
///
/// **R1 is FROZEN at 12** - Jakub's original constraint on 2026-08-06,
/// "zachowaj padding ktory jest uzyty box vs title". It is an input to this
/// work, never an output, and every assertion below re-checks it.
///
/// **R2 is held CONSTANT at 26 across every section**, independent of what
/// sits below the title. That is the rule this file enforces.
///
/// ---------------------------------------------------------------------
/// WHY firstPaintedTop AND NOT getRect(firstRow).top
/// ---------------------------------------------------------------------
///
/// Every dashboard list row (`CoinCardRow` in Assets, `CryptoSparkLineChart`
/// in Markets) is a `ListTile`, and a `ListTile` does NOT size to its content.
/// It snaps to a default tile height and CENTRES the content inside it. That
/// centring slack is real, unpadded whitespace sitting directly under the
/// title, it is invisible in source at both the row and the title, and it is
/// what the eye actually reads as the gap. Measuring `getRect(row).top` counts
/// the row's layout box and misses the slack entirely - which is exactly the
/// error the doc comments this file corrects both made.
///
/// If a future edit "simplifies" [firstPaintedTopBelow] back to a layout-box
/// read, it reintroduces that error silently: every number below stays green
/// while the rendered gap changes.
///
/// ---------------------------------------------------------------------
/// R1 IS 12 EVERYWHERE - and that was the surprise
/// ---------------------------------------------------------------------
///
/// The hosts differ (a `DashboardScrollContainer` folds a 1px border into its
/// `space6` padding for a 13px content inset; the news sections sit under a
/// `space12` spacer; All Markets sits under a hero card) - but every one of
/// those insets ends exactly where [GWSectionTitle]'s own padding box begins,
/// which is the definition of `boxContentTop`. So the host term cancels and
///
///   R1 = edgePad(2) + slack(10) = 12
///
/// in all eight sections. `slack` is the whitespace the 44px header
/// reservation itself contributes: the title line box is 24px tall (`titleLg`
/// is 18/24), so `(44 - 24) / 2 = 10` is paid on EACH side of it before any
/// padding is charged at all. That 10 is the term nobody had counted, and it
/// is why
///
///   R2 = slack(10) + bottomPad + contentTopInset
///
/// made a FIXED bottom pad produce a different rendered gap in every panel.
///
/// ---------------------------------------------------------------------
/// MEASURED - 2026-08-06/07, from this file's own output
/// ---------------------------------------------------------------------
///
/// `C` is the content's OWN top inset: its first painted pixel minus its
/// layout box top. `B` is [GWSectionTitle]'s bottom pad, now derived as
/// `max(0, 26 - slack - C)` rather than fixed.
///
/// | Section              | C     | B before | R2 before | B after | R2 after |
/// | -------------------- | ----- | -------- | --------- | ------- | -------- |
/// | component baseline   |  0    | 16       | 26        | 16      | 26       |
/// | Compute              |  0    | 16       | 26        | 16      | 26       |
/// | More news / Results  |  0    | 16       | 26        | 16      | 26       |
/// | Results (empty)      |  8->0 | 16       | 34        | 16      | 26       |
/// | Transactions (panel) |  8->0 | 16       | 34        | 16      | 26       |
/// | Next up              |  8    | 16       | 34        |  8      | 26       |
/// | All Markets          | 12    | 16       | 38        |  4      | 26       |
/// | Markets (panel)      | 16.75 | 16       | 42.75     |  0      | 26.75    |
/// | Assets               | 20    | 16       | 46        |  0      | 30       |
///
/// Every resulting pad is an existing token - `space8` 16, `space4` 8,
/// `space2` 4, and 0 - so nothing off-grid was introduced. The `C` values are
/// not spacing choices and are not required to be on the grid: they describe
/// what the content already does.
///
/// Where each C comes from:
///   - Compute        `_BalanceTile` is a `GWCard`; it paints at its own top.
///   - News grid      `_NewsGridCard`'s photo fills the tile's top edge.
///   - Results empty  a `Padding(top: space4)` - REMOVED, it double-counted.
///   - Transactions   the first day label's `Padding(top: space4)` - REMOVED
///                    for the panel only; the PAGE has no section title above
///                    it and keeps its space4.
///   - Next up        `_NextUpRow`'s own `vertical: space4`.
///   - All Markets    `MarketsTable`'s header `Container(vertical: space6)`.
///   - Markets panel  `CryptoSparkLineChart`'s ListTile snap - measured here.
///   - Assets         `CoinCardRow`'s ListTile snap - measured here.
///
/// **The two overshoots are deliberate.** The pad floors at zero, so C above
/// 16 renders `slack + C` instead of 26: Assets at 30 and the Markets panel at
/// 26.75. Assets is the section Jakub measured on device as ALREADY correct -
/// 28.9pt above the title against 31.3pt below, painted ink to painted ink -
/// and named as the target the others should match. Normalising those
/// `ListTile`s to close the last 4px would change row-to-row rhythm, divider
/// spacing and touch-target heights across three panels; it was considered and
/// withdrawn.
///
/// ---------------------------------------------------------------------
/// WHY 12 ABOVE AND 26 BELOW IS SYMMETRIC ON GLASS
/// ---------------------------------------------------------------------
///
/// The layout numbers omit two terms the eye does not:
///
///   visual above = hostCardPad(12) + edgePad(2) + slack(10) + cap(~4) ~= 28
///   visual below = slack(10) + bottomPad + C + descent(~5)            ~= 31
///
/// The host card's `space6` padding sits directly above the title and reads as
/// part of the border->title gap; below the title nothing corresponds to it.
/// Device capture 2026-08-06 confirms both halves: Assets 28.9 / 31.3 (judged
/// balanced), Compute 27.9 / 17.7 (judged bottom-tight, and the reason this
/// pass exists).
///
/// ---------------------------------------------------------------------
/// THE VERDICT ON `gw_section_title.dart:15-19` (the old doc comment)
/// ---------------------------------------------------------------------
///
/// It claimed the component made all four panels read at ONE geometry: "an
/// identical title->panel-top padding AND title->first-row gap".
///
/// **Half true, and the false half was the one it was written to guarantee.**
///
///  - `title->panel-top padding`: TRUE, and still true. R1 = 12 at every site.
///  - `title->first-row gap`: FALSE, and never once true. It measured 26, 34,
///    38, 43 and 46 across the eight sites the day it was written.
///
/// The term that breaks it is the CONTENT inset, not the host inset - the host
/// inset cancels (see above). A fixed bottom pad could not have delivered the
/// property the comment asserted, which is why the pad is now derived.
///
/// A second, smaller falsehood in the same comment: "OWNS its own `space8`
/// bottom gap" was true as a DECLARATION and wrong as a description of what
/// rendered. The rendered gap below the line box was 26, because the 44px
/// reservation had already paid 10 of it.
library;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/chart/crypto_simple_chart.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/coins/view/coin_card_row.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/hive/models/coin_gecko_market_data.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/theme.dart';

const double _kPanelWidth = 320;

/// Standalone row measurements run WIDE on purpose.
///
/// The number being read is the row's own VERTICAL top inset, which is
/// width-independent as long as nothing wraps - and the test harness's
/// fallback font draws roughly one em per character, so the production width
/// (294 inside a 320px card) forces wraps that Inter never produces on device.
/// Measuring wide isolates the ListTile snap, which is the term that matters.
const double _kRowProbeWidth = 560;

/// `DashboardScrollContainer` is a `Container` carrying BOTH a `decoration`
/// (whose `Border.all(width: 1)` contributes a 1px `decoration.padding`) and a
/// child `Padding` of `space6`. `Container.build` folds the border into the
/// content inset via `_paddingIncludingDecoration`, so the content box starts
/// `12 + 1 = 13` in, not 12. `compute_panel_height_test.dart` derives the same
/// fold at length and `transaction_filter_rail_test.dart` confirms it
/// independently at a different card size.
const double _kScrollContainerTopInset = GeniusWalletConsts.space6 + 1;

/// R1: the box->title gap, frozen. `edgePad(2) + slack(10)`.
const double kFrozenBoxToTitle = kGWSectionTitleEdgePad + kGWSectionTitleSlack;

/// The largest content inset the component can still absorb. Above this the
/// bottom pad floors at 0 and the rendered gap overshoots to `slack + C`.
const double kMaxAbsorbableInset =
    kGWSectionTitleRenderedGap - kGWSectionTitleSlack;

/// The inner top edge of a `DashboardScrollContainer`-hosted panel.
double boxContentTop(WidgetTester tester) =>
    tester.getRect(find.byType(DashboardScrollContainer)).top +
    _kScrollContainerTopInset;

/// The rendered paragraph box of the section title.
///
/// The LINE BOX, not glyph extents, on both sides of the comparison: for Inter
/// at 18/24 the cap-top inset and the baseline inset inside the line box
/// differ by well under a pixel, so line-box symmetry tracks optical symmetry
/// - and unlike glyph extents it does not move when a title happens to carry a
/// descender ("Compute", "Next up") and it is expressible on the spacing grid.
Rect titleLineBox(WidgetTester tester, String title) =>
    tester.getRect(find.text(title));

/// Whether [w]'s render object actually puts ink on the screen.
///
/// Deliberately narrow. A `ListTile`, an `InkWell`, a transparent `Material`
/// and a bare `Padding` all occupy space and paint nothing; counting any of
/// them is how the layout box sneaks back into the measurement.
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

/// The topmost PAINTED pixel inside [subtree] that starts at or below [y].
///
/// Reads the render object directly rather than round-tripping through
/// `find.byWidget`, which is not identity-stable when rows repeat.
double firstPaintedTopBelow(WidgetTester tester, Finder subtree, double y) {
  double? best;
  final Iterable<Element> painted = find
      .descendant(
        of: subtree,
        matching: find.byWidgetPredicate(_paintsInk, description: 'paints ink'),
        matchRoot: true,
      )
      .evaluate();
  for (final Element e in painted) {
    final RenderObject? ro = e.renderObject;
    if (ro is! RenderBox || !ro.hasSize || ro.size.isEmpty) {
      continue;
    }
    final double top = ro.localToGlobal(Offset.zero).dy;
    if (top < y - 0.01) {
      continue;
    }
    if (best == null || top < best) {
      best = top;
    }
  }
  expect(
    best,
    isNotNull,
    reason:
        'no painted render object found below y=$y - the subtree finder is '
        'wrong, not the layout',
  );
  return best!;
}

/// Asserts BOTH halves of the rule for one mounted section: R1 frozen at 12,
/// and the rendered title->first-ink gap equal to the shared 26.
void expectSectionRhythm(
  WidgetTester tester, {
  required String label,
  required String title,
  required Finder content,
}) {
  final Rect box = titleLineBox(tester, title);
  final double r1 = box.top - boxContentTop(tester);
  final double r2 =
      firstPaintedTopBelow(tester, content, box.bottom) - box.bottom;
  debugPrint(
    'RHYTHM | ${label.padRight(30)} R1=${r1.toStringAsFixed(2).padLeft(6)}  '
    'R2=${r2.toStringAsFixed(2).padLeft(6)}',
  );
  expect(
    r1,
    closeTo(kFrozenBoxToTitle, 1),
    reason:
        '$label: R1 is FROZEN at $kFrozenBoxToTitle - the box->title gap is an '
        'input to this rule, never an output. Measured $r1.',
  );
  expect(
    r2,
    closeTo(kGWSectionTitleRenderedGap, 1),
    reason:
        '$label: the RENDERED title->first-painted-pixel gap measured $r2 '
        'against the shared $kGWSectionTitleRenderedGap. A fixed bottom pad '
        'makes this number depend on what sits below the title - if this went '
        'red, check whether the pad was "simplified" back to a constant.',
  );
}

/// A content probe with a declared top inset of its own, standing in for a
/// `ListTile`'s centring slack or a padded row without dragging a real row
/// into the test. [inset] of 0 is the zero-inset case.
///
/// A StatelessWidget, not a `_buildProbe()` helper - AGENTS.md.
class InsetProbe extends StatelessWidget {
  const InsetProbe({super.key, this.inset = 0});

  final double inset;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(top: inset),
      child: const SizedBox(
        height: 40,
        width: double.infinity,
        child: ColoredBox(color: Color(0xFF00FF00)),
      ),
    );
  }
}

Widget _hostedInScrollContainer(Widget child, {double width = _kPanelWidth}) {
  return MaterialApp(
    theme: getThemeData(),
    home: Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          width: width,
          child: DashboardScrollContainer(child: child),
        ),
      ),
    ),
  );
}

ComputeStatusView _viewFor(ComputeState state) => viewForComputeState(
  state,
  initPercentage: state == ComputeState.startingUp ? 0.6 : null,
  processingPercentage: state == ComputeState.processing ? 52.5 : null,
);

Widget _computePanel(ComputeState state) => _hostedInScrollContainer(
  ComputePanel(
    view: _viewFor(state),
    balance: 1234.56,
    fiatSubline: '≈ \$312.40',
    useMinions: false,
    onUnitChanged: (_) {},
    onLinkTap: (_) {},
    onNewJob: () {},
  ),
);

Transaction _tx({DateTime? at}) => Transaction(
  hash: '0xabc',
  fromAddress: '0x1111',
  recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
  timeStamp: at ?? DateTime(2026, 7, 22),
  transactionDirection: TransactionDirection.sent,
  fees: '0.001',
  coinSymbol: 'ETH',
  transactionStatus: TransactionStatus.completed,
  type: TransactionType.escrow,
);

CoinGeckoMarketData _market() =>
    CoinGeckoMarketData.fromJson(const <String, dynamic>{
      'id': 'genius',
      'symbol': 'gnus',
      'name': 'Genius Tokens',
      'current_price': 1.23,
      'high_24h': 1.5,
      'low_24h': 1.0,
      'price_change_percentage_24h': 2.5,
    });

void main() {
  // THE CONTRACT, and the case that pins it for the five sections no test in
  // this repo can mount (Assets needs a bloc, Markets and All Markets need a
  // network future, the three news sections need both).
  //
  // The loop IS the assertion: the same rendered gap for four different
  // content insets is the whole property. A fixed bottom pad passes the first
  // iteration and fails the other three, which is exactly how the drift got in
  // and stayed in.
  for (final double inset in <double>[
    0, // Compute, the news grid, Transactions after the day-label fix
    GeniusWalletConsts.space4, // Next up
    GeniusWalletConsts.space6, // All Markets
    16, // the largest inset the pad can still fully absorb
  ]) {
    testWidgets('CONTRACT - rendered gap is 26 at contentTopInset $inset', (
      tester,
    ) async {
      await tester.pumpWidget(
        _hostedInScrollContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              GWSectionTitle(title: 'Contract', contentTopInset: inset),
              InsetProbe(inset: inset),
            ],
          ),
        ),
      );
      await tester.pump();

      // The two terms the whole table's arithmetic rests on, asserted rather
      // than quoted: a 24px line box centred in a 44px reservation is what
      // makes the slack 10, and the slack is why a fixed pad could never
      // render one gap.
      expect(
        titleLineBox(tester, 'Contract').height,
        kGWSectionTitleLineHeight,
      );
      expect(kGWSectionTitleSlack, 10);

      expectSectionRhythm(
        tester,
        label: 'contract (C=$inset)',
        title: 'Contract',
        content: find.byType(InsetProbe),
      );
    });
  }

  // The two sites whose content brings more inset than the pad can absorb.
  // Documented as behaviour so nobody "fixes" the overshoot by normalising a
  // ListTile: Assets is the section Jakub measured on device as ALREADY
  // correct and named as the target.
  for (final double inset in <double>[16.75, 20]) {
    testWidgets('OVERSHOOT - contentTopInset $inset renders slack + C', (
      tester,
    ) async {
      await tester.pumpWidget(
        _hostedInScrollContainer(
          Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              GWSectionTitle(title: 'Overshoot', contentTopInset: inset),
              InsetProbe(inset: inset),
            ],
          ),
        ),
      );
      await tester.pump();

      final Rect box = titleLineBox(tester, 'Overshoot');
      final double r1 = box.top - boxContentTop(tester);
      final double r2 =
          firstPaintedTopBelow(tester, find.byType(InsetProbe), box.bottom) -
          box.bottom;
      debugPrint('RHYTHM | overshoot C=$inset R1=$r1 R2=$r2');

      // R1 never moves, whatever the content declares.
      expect(r1, kFrozenBoxToTitle);
      expect(inset, greaterThan(kMaxAbsorbableInset));
      expect(
        r2,
        closeTo(kGWSectionTitleSlack + inset, 0.01),
        reason:
            'above $kMaxAbsorbableInset the pad floors at 0 and the gap is the '
            "content's own inset plus the reservation slack. If this ever "
            'reads $kGWSectionTitleRenderedGap the floor has been defeated and '
            "the table in this file's doc comment is stale.",
      );
    });
  }

  // Every state, not a sample: `_BalanceTile` changes form between them
  // (no-wallet drops the unit track, processing carries a percentage), and a
  // form change is exactly what could give the first content an inset.
  for (final state in ComputeState.values) {
    testWidgets('COMPUTE - ${state.name}', (tester) async {
      await tester.pumpWidget(_computePanel(state));
      await tester.pump();
      expect(tester.takeException(), isNull);

      expectSectionRhythm(
        tester,
        label: 'Compute (${state.name})',
        title: 'Compute',
        content: find.byType(ComputePanel),
      );

      // Compute is the panel with a height budget, and option B gave it back
      // the 14px the intermediate build had taken away - so this is the
      // assertion that matters most here. Asserted in the file that would
      // cause a regression as well as in `compute_panel_height_test.dart`,
      // because the panel lives in a `SingleChildScrollView`: blowing the
      // budget throws nothing, it just drops the CTA below the fold.
      expect(
        tester.getSize(find.byType(ComputePanel)).height,
        lessThanOrEqualTo(
          kDashboardPanelSlotHeight - 2 * _kScrollContainerTopInset,
        ),
      );
    });
  }

  testWidgets('TRANSACTIONS - dashboard panel, first content is a day label', (
    tester,
  ) async {
    final DateTime now = DateTime.now();
    await tester.pumpWidget(
      _hostedInScrollContainer(
        SizedBox(
          height: 400,
          child: TransactionsSlimView(
            transactions: [
              _tx(at: DateTime(now.year, now.month, now.day, 10)),
              _tx(at: DateTime(now.year, now.month, now.day - 1, 10)),
            ],
          ),
        ),
        // Wide enough that the title's trailing slot does not overflow under
        // the harness's wide fallback font, where "Transactions" alone draws
        // ~214px. Width does not enter the vertical measurement.
        //
        // That trailing is a `GWViewAllLink` since phase 25, not the filter
        // bar - Jakub moved the bar to the full screen on 2026-08-07 because
        // the two do not both fit a 336px content box. Neither the swap nor
        // the panel's new five-row cap touches this measurement: the fixture is
        // two transactions in a 400px box, so the cap never bites, the box is
        // BOUNDED so the panel takes its scroll branch exactly as before, and
        // the first widget below the title is still the same day label at the
        // same zero top pad.
        width: 900,
      ),
    );
    await tester.pump();

    expectSectionRhythm(
      tester,
      label: 'Transactions (panel)',
      title: 'Transactions',
      content: find.byType(TransactionsSlimView),
    );
  });

  // The two ListTile rows, measured standalone. Their numbers are the `C`
  // column for Assets and the Markets panel in the table above - neither panel
  // can be mounted here (bloc / network future), so the row is measured on its
  // own and the section's rendered gap derived as `slack + C`.
  //
  // Both assert `C > kMaxAbsorbableInset`, which is what makes those two the
  // overshoot cases rather than ordinary ones.
  testWidgets('ROW INSET - CoinCardRow (Assets)', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: getThemeData(),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: _kRowProbeWidth,
              child: CoinCardRow(
                iconPath: '',
                name: 'GNUS',
                symbol: 'GNUS',
                balance: 12.5,
                marketData: _market(),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    final Rect row = tester.getRect(find.byType(CoinCardRow));
    final double c =
        firstPaintedTopBelow(tester, find.byType(CoinCardRow), row.top) -
        row.top;
    debugPrint(
      'RHYTHM | CoinCardRow          height=${row.height} C=$c '
      '-> Assets gap = ${kGWSectionTitleSlack + c}',
    );
    expect(
      c,
      greaterThan(kMaxAbsorbableInset),
      reason:
          'Assets overshoots the shared gap because its ListTile brings more '
          'top inset than the section title has pad to spend. If this row ever '
          'drops below $kMaxAbsorbableInset, Assets joins the shared 26 and '
          "the table in this file's doc comment is stale.",
    );
  });

  testWidgets('ROW INSET - CryptoSparkLineChart (Markets panel)', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(extensions: [GWColors.dark()]),
        home: const Scaffold(
          body: Center(
            child: SizedBox(
              width: _kRowProbeWidth,
              child: CryptoSparkLineChart(
                title: 'Bitcoin',
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
      ),
    );
    await tester.pump();

    final Rect row = tester.getRect(find.byType(CryptoSparkLineChart));
    final double c =
        firstPaintedTopBelow(
          tester,
          find.byType(CryptoSparkLineChart),
          row.top,
        ) -
        row.top;
    debugPrint(
      'RHYTHM | CryptoSparkLineChart height=${row.height} C=$c '
      '-> Markets gap = ${kGWSectionTitleSlack + c}',
    );
    expect(c, greaterThan(kMaxAbsorbableInset));
  });
}
