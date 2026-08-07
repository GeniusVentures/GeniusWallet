import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/dashboard/home/widgets/transactions_slim_view.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the existing WCAG helper rather than adding a third implementation
// (see its doc comment in test/theme/theme_contrast_test.dart).
import '../theme/theme_contrast_test.dart' show contrastRatio;

/// The PAGE filter rail: `TransactionsSlimView(page: true)` at >= 768.
///
/// Three things this file exists to pin, in order of value:
///
///  1. **The active mark is sketch 022's B2** — w700 `textPrimary` label that
///     is NEVER recoloured, a 2px gradient rule beneath it, and a glyph that
///     does not change at all. Two marks for one boolean, because a permanent
///     rail read from peripheral vision needs more than a weight change.
///  2. **That rule clears WCAG 1.4.11's 3:1 in BOTH appearances.** It is a
///     non-text mark, and `brandCta`'s blue stop fails 3:1 on white, so the
///     rule must be painted through `_activeLabelShader`'s degradation. That is
///     the single most valuable test here (test 6).
///  3. **The counts come from the UNFILTERED scope**, so they do not move when
///     you filter.
///
/// ---------------------------------------------------------------------------
/// TWO HARNESS TRAPS. Both silently make assertions read the wrong thing.
/// ---------------------------------------------------------------------------
///
/// **(a) The surface.** `flutter_test`'s default is 800x600 LOGICAL. A
/// `SizedBox(width: 1200)` inside it collapses to 800 — the `wide` boolean
/// would still be true, but only because `800 >= 768` by 32px, entirely by
/// accident, and every "narrow" case would collapse to the same 800. Every
/// pump here goes through [_surface], which widens the window and tears it back
/// down. Teardown is not optional: a leaked surface changes every file that
/// runs after this one.
///
/// **(b) Label collisions.** Four `Filters` labels are also row action chips —
/// a transaction row prints `Sent`, `Received`, `Swapped` and `Purchased`. This
/// harness renders the LIST beside the rail, so a bare `find.text('Sent')`
/// matches two widgets. `transaction_filters_test.dart` dodges this by pumping
/// a fixture that prints none of those words; the rail cannot dodge it, because
/// rendering all ten labels is the entire point of a rail. **Every filter-label
/// finder in this file goes through [railText], which scopes to the rail
/// subtree.** Do not reintroduce a bare `find.text` on a filter label.

Transaction _tx({
  TransactionType? type,
  TransactionStatus status = TransactionStatus.completed,
  TransactionDirection direction = TransactionDirection.sent,
  DateTime? at,
}) {
  return Transaction(
    hash: '0xabc',
    fromAddress: '0x1111',
    recipients: [TransferRecipients(toAddr: '0x2222', amount: '1.0')],
    timeStamp: at ?? DateTime(2026, 7, 22),
    transactionDirection: direction,
    fees: '0.001',
    coinSymbol: 'ETH',
    transactionStatus: status,
    type: type,
  );
}

/// Eight transactions covering seven type filters. Counts, for reference:
/// sent 2 · received 1 · mint 1 · jobs 1 · escrow 1 · swap 1 · purchase 1 ·
/// pending 0 · failed 0, total **8**.
List<Transaction> _mixed() => [
  _tx(type: TransactionType.transfer, direction: TransactionDirection.sent),
  _tx(type: TransactionType.transfer, direction: TransactionDirection.sent),
  _tx(type: TransactionType.transfer, direction: TransactionDirection.received),
  _tx(type: TransactionType.mint),
  _tx(type: TransactionType.process),
  _tx(type: TransactionType.escrow),
  _tx(type: TransactionType.swap),
  _tx(type: TransactionType.purchase),
];

/// Sets the GLOBAL appearance to [mode] and returns the matching [GWColors],
/// restoring dark on teardown.
///
/// Both halves are required. `GWColors.light()` copies `surfaceMenu` (and the
/// rest) from `GeniusWalletColors.surfaceMenu`, a GLOBAL getter keyed off
/// [GWAppearance] — so constructing a "light" instance while the global is dark
/// hands back the DARK `#171A21`, and `_activeLabelShader`'s luminance branch
/// then takes the DARK arm inside a nominally-light test. Test 6 would pass for
/// the wrong reason in both iterations. Same mechanism as `themeFor` in
/// `test/theme/theme_contrast_test.dart:23-29` and `gwFor` in
/// `transaction_filters_test.dart`.
GWColors gwFor(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return mode == GWAppearanceMode.light ? GWColors.light() : GWColors.dark();
}

/// Widens the test window to 1400x1000 logical and restores it afterwards.
void _surface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1400 * 3, 1000 * 3); // logical x dpr
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

/// `GWDecorations`' two sheen endpoints per appearance, taken as literals.
///
/// The card the rule sits on is painted with `GWDecorations.surfaceSheen`,
/// which keys off the GLOBAL `GWAppearance.isLight` rather than off the
/// [GWColors] in the widget tree — which is why this file compares COLOUR PAIRS
/// against these constants and never reads rendered pixels. The rule is 2px
/// tall and may sit anywhere down the card, so BOTH endpoints have to pass;
/// asserting only the favourable one is how a 1.4.11 failure ships.
const Color _sheenDarkTop = Color(0xFF181B24);
const Color _sheenDarkBottom = Color(0xFF0C0E14);
const Color _sheenLightTop = Color(0xFFFFFFFF);
const Color _sheenLightBottom = Color(0xFFF5F7FA);

final Finder railFinder = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == '_FilterRail',
);
final Finder rowFinder = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == '_RailRow',
);
final Finder barFinder = find.byWidgetPredicate(
  (w) => w.runtimeType.toString() == '_TransactionFilterBar',
);

/// A `Text` finder scoped to the rail — see trap (b) in the header comment.
Finder railText(String s) =>
    find.descendant(of: railFinder, matching: find.text(s));

/// The `_RailRow` carrying [label].
Finder rowFor(String label) =>
    find.ancestor(of: railText(label), matching: rowFinder);

/// The row's hover fill: `AnimatedContainer`'s EVALUATED inner `Container`, not
/// the `AnimatedContainer` widget itself — the widget holds the animation's
/// TARGET, which is already the destination colour on the frame the hover
/// starts, so reading it would pass without any animation running at all.
/// Selected by its 40px tight constraint, which is `space20`.
Container _fillOf(WidgetTester tester, Finder row) => tester.widget<Container>(
  find.descendant(
    of: row,
    matching: find.byWidgetPredicate(
      (w) => w is Container && w.constraints?.maxHeight == 40,
    ),
  ),
);

/// The 2px rule beneath the row's label, selected by its tight 2px constraint.
Container _ruleOf(WidgetTester tester, Finder row) => tester.widget<Container>(
  find.descendant(
    of: row,
    matching: find.byWidgetPredicate(
      (w) => w is Container && w.constraints?.maxHeight == 2,
    ),
  ),
);

/// The row's count — the LAST `Text` in the row (`Row` order is glyph, gap,
/// label block, `Spacer`, count).
String _countOf(WidgetTester tester, Finder row) => tester
    .widget<Text>(find.descendant(of: row, matching: find.byType(Text)).last)
    .data!;

Widget _host({
  required double width,
  required GWColors gw,
  List<Transaction>? txs,
  double height = 900,
  bool page = true,
}) => MaterialApp(
  theme: ThemeData(extensions: [gw]),
  home: Scaffold(
    body: Center(
      child: SizedBox(
        width: width,
        height: height,
        // Keyed on `page` so re-pumping the same test from page to panel
        // REMOUNTS rather than reusing the State — otherwise `selectedFilter`
        // survives the switch and the panel opens on whatever the rail last
        // selected. In the app `page` is fixed per call site, so remounting is
        // the faithful behaviour, not a workaround.
        child: TransactionsSlimView(
          key: ValueKey(page),
          transactions: txs ?? _mixed(),
          page: page,
        ),
      ),
    ),
  ),
);

void main() {
  // 1 -------------------------------------------------------------------
  testWidgets('the rail unrolls the whole menu', (tester) async {
    _surface(tester);
    await tester.pumpWidget(
      _host(width: 1200, gw: gwFor(GWAppearanceMode.dark)),
    );
    expect(tester.takeException(), isNull);

    // NINE rows: seven types + two statuses. There is NO All element at all
    // (sketch 023, walk 2) — no row, no summary. RED if a group is dropped, if
    // the rail is built from `Filters.primary` alone, or if any All affordance
    // is reinstated.
    expect(rowFinder, findsNWidgets(9));

    expect(railText('Type'), findsOneWidget);
    expect(railText('Status'), findsOneWidget);

    for (final f in Filters.values) {
      if (f == Filters.all) {
        continue;
      }
      expect(railText(f.label), findsOneWidget, reason: '${f.label} missing');
    }

    // No total anywhere in the rail — the summary was removed on the walk.
    expect(find.text('transactions'), findsNothing);
    expect(find.textContaining(RegExp(r'\d+ transactions')), findsNothing);
  });

  // 2 -------------------------------------------------------------------
  testWidgets('neither the page nor the panel shows a running total', (
    tester,
  ) async {
    // Both totals were removed on the 023 walk: the rail summary AND the panel
    // footer. This guards both presentations at once — a "N transactions" line
    // reappearing in either is the regression.
    _surface(tester);

    // PAGE.
    await tester.pumpWidget(
      _host(width: 1200, gw: gwFor(GWAppearanceMode.dark)),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining(RegExp(r'\d+ transactions?')), findsNothing);

    // PANEL, same fixture shape.
    await tester.pumpWidget(
      _host(
        width: 900,
        gw: gwFor(GWAppearanceMode.dark),
        txs: [_tx(type: TransactionType.escrow)],
        page: false,
      ),
    );
    expect(tester.takeException(), isNull);
    expect(find.textContaining(RegExp(r'\d+ transactions?')), findsNothing);
  });

  // 3 -------------------------------------------------------------------
  testWidgets('counts are computed over the unfiltered list', (tester) async {
    _surface(tester);
    await tester.pumpWidget(
      _host(width: 1200, gw: gwFor(GWAppearanceMode.dark)),
    );

    final before = _countOf(tester, rowFor('Sent'));
    expect(before, isNot('0'));

    // Tap the ROW, not its label: the row is 40px of mostly empty space and the
    // whole of it must be the target, which is what `HitTestBehavior.opaque`
    // buys. `warnIfMissed` fails this line if the tap lands on nothing.
    await tester.tap(rowFor('Received'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // RED if `filterCounts` is called on `txs` instead of `scoped`: every
    // inactive count would drop to 0.
    expect(_countOf(tester, rowFor('Sent')), before);
    expect(_countOf(tester, rowFor('Received')), isNot('0'));
  });

  // 4 -------------------------------------------------------------------
  testWidgets('active is w700 textPrimary and is NEVER recoloured', (
    tester,
  ) async {
    _surface(tester);
    final gw = gwFor(GWAppearanceMode.dark);
    await tester.pumpWidget(_host(width: 1200, gw: gw));

    expect(
      tester.widget<Text>(railText('Mint')).style!.fontWeight,
      FontWeight.w500,
    );

    await tester.tap(rowFor('Mint'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final active = tester.widget<Text>(railText('Mint')).style!;
    expect(active.fontWeight, FontWeight.w700);
    // RED if the label is tinted brand — sketch 022 variant B, rejected.
    expect(active.color, gw.textPrimary);

    // And RED if it is wrapped in a ShaderMask. This needs its own assertion
    // rather than riding on the colour one: the `srcIn` convention `_menuItem`
    // uses sets the masked child to `Colors.white`, and in DARK
    // `gw.textPrimary` IS `Colors.white` (the theme primitive layer's dark
    // branch) — so
    // the line above cannot tell the two apart. The rail paints its gradient
    // into the 2px rule and nowhere else.
    expect(
      find.descendant(of: railFinder, matching: find.byType(ShaderMask)),
      findsNothing,
    );

    // Another row is untouched, so w700 is a SELECTION mark and not the rail's
    // resting weight.
    expect(
      tester.widget<Text>(railText('Sent')).style!.fontWeight,
      FontWeight.w500,
    );
  });

  // 4b ------------------------------------------------------------------
  testWidgets('tapping the active row clears back to All', (tester) async {
    // The rail has no All element (sketch 023, walk 2), so tapping the active
    // row again IS the way back to unfiltered. Before this it was a no-op —
    // `onChanged(f)` re-selected the same filter — which stranded the user on
    // a filter with no visible route out. RED if the toggle regresses to a
    // plain re-select: the row would stay w700 on the second tap.
    _surface(tester);
    await tester.pumpWidget(
      _host(width: 1200, gw: gwFor(GWAppearanceMode.dark)),
    );

    await tester.tap(rowFor('Mint'));
    await tester.pumpAndSettle();
    expect(
      tester.widget<Text>(railText('Mint')).style!.fontWeight,
      FontWeight.w700,
      reason: 'first tap activates',
    );

    await tester.tap(rowFor('Mint'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    // Back to resting weight — nothing is selected, which is the All state.
    expect(
      tester.widget<Text>(railText('Mint')).style!.fontWeight,
      FontWeight.w500,
      reason: 'second tap on the active row must clear to All',
    );
    // And no row anywhere wears the active weight now.
    for (final f in Filters.values) {
      if (f == Filters.all) {
        continue;
      }
      expect(
        tester.widget<Text>(railText(f.label)).style!.fontWeight,
        FontWeight.w500,
        reason: '${f.label} should be unselected in the All state',
      );
    }
  });

  // 5 -------------------------------------------------------------------
  testWidgets('the glyph does not change with selection', (tester) async {
    _surface(tester);
    final gw = gwFor(GWAppearanceMode.dark);
    await tester.pumpWidget(_host(width: 1200, gw: gw));

    // The row is picked deliberately. `badgeGlyph` returns an `Icon` OR an
    // `SvgPicture`, and `TransactionBadgeKind.mint` is the hand-drawn pickaxe
    // SVG — so reading `Icon.color` on the Mint row (the row test 4 selects,
    // which makes it the easy wrong choice) would find nothing. `sent` carries
    // an `IconData` (`Icons.north_east`).
    Icon glyph() => tester.widget<Icon>(
      find.descendant(of: rowFor('Sent'), matching: find.byType(Icon)),
    );

    final before = glyph();
    expect(before.color, gw.textSecondary);

    await tester.tap(rowFor('Sent'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);

    final after = glyph();
    // RED if the glyph is tinted or swapped on selection — the rule locked at
    // `_menuItem` and restated by all five variants in sketch 022.
    expect(after.icon, before.icon);
    expect(after.color, before.color);
    expect(after.color, gw.textSecondary);
  });

  // 6 -------------------------------------------------------------------
  // THE test in this file. Parameterised over GWAppearanceMode.values — NOT
  // over two hand-built GWColors instances; see gwFor's doc comment.
  for (final mode in GWAppearanceMode.values) {
    testWidgets('the active rule clears WCAG 1.4.11 in ${mode.name}', (
      tester,
    ) async {
      _surface(tester);
      // Flag first, GWColors second. The order is the whole point.
      final gw = gwFor(mode);
      await tester.pumpWidget(_host(width: 1200, gw: gw));

      await tester.tap(rowFor('Sent'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);

      final gradient =
          (_ruleOf(tester, rowFor('Sent')).decoration as BoxDecoration).gradient
              as LinearGradient;

      // An inactive row renders the same 2px box with a NULL gradient, so the
      // rail never twitches when selection moves.
      expect(
        (_ruleOf(tester, rowFor('Mint')).decoration as BoxDecoration).gradient,
        isNull,
      );

      final surfaces = mode == GWAppearanceMode.light
          ? const [_sheenLightTop, _sheenLightBottom]
          : const [_sheenDarkTop, _sheenDarkBottom];

      for (final stop in gradient.colors) {
        for (final surface in surfaces) {
          expect(
            contrastRatio(stop, surface),
            greaterThanOrEqualTo(3.0),
            // RED if the rule is painted with `GeniusWalletGradient.brandCta`
            // unconditionally: its blue stop `#0AAEE6` (the theme primitive
            // layer's gradientBlue) measures 2.56:1 on white.
            reason:
                'rule stop $stop on $surface in ${mode.name} — WCAG 1.4.11 '
                'wants 3:1 for a non-text UI mark',
          );
        }
      }
    });
  }

  // 7 -------------------------------------------------------------------
  testWidgets('rest geometry matches the menu item', (tester) async {
    _surface(tester);
    await tester.pumpWidget(
      _host(width: 1200, gw: gwFor(GWAppearanceMode.dark)),
    );
    expect(tester.takeException(), isNull);

    // 40 = `space20`, the height `_menuItem` uses and the height the navbar
    // normalizes every interactive control to.
    // Nine, not ten: the All summary is not a `_RailRow` and does not carry
    // the 40px control height — it is a heading-weight total.
    for (var i = 0; i < 9; i++) {
      expect(tester.getSize(rowFinder.at(i)).height, 40);
    }

    // The rail CARD is 220 and its content box is 194 — `DashboardScrollContainer`
    // spends `space6` each side AND a 1px hairline border, because
    // `GWDecorations.surface` carries one. 194, not the 196 a padding-only
    // reading gives. If either drifts, the width arithmetic in `_railWidth`'s
    // comment stops describing the widget.
    expect(
      tester.getSize(find.byType(DashboardScrollContainer).first).width,
      220,
    );
    expect(tester.getSize(railFinder).width, 194);

    // The measured half of `_railWidth`'s budget: 194 - 24 row padding - 14
    // glyph - 8 gap leaves 148 for label + count. `Purchased` is the widest
    // label and draws 119.25 in the harness's one-em-per-character fallback
    // font, so the numeral has 28.75 — two digits. This is the pessimistic
    // font, not the shipped one; it is pinned so the comment's ceiling stays
    // true rather than becoming folklore.
    expect(tester.getSize(railText('Purchased')).width, closeTo(119.25, 0.01));
  });

  // 8 -------------------------------------------------------------------
  testWidgets('hover lifts, and the active row does not', (tester) async {
    _surface(tester);
    final gw = gwFor(GWAppearanceMode.dark);
    await tester.pumpWidget(_host(width: 1200, gw: gw));

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // An INACTIVE row lifts onto surfaceElevated — the sketch-008 "lift chip",
    // 120ms, the same gesture `_FilterChip` and `_TimeframeTab` use.
    await gesture.moveTo(tester.getCenter(rowFor('Escrow')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      (_fillOf(tester, rowFor('Escrow')).decoration as BoxDecoration).color,
      gw.surfaceElevated,
    );

    // Now make it active and hover it again. RED if hover and active collapse
    // into one fill — the collision that killed sketch 022 variant E.
    await tester.tap(rowFor('Escrow'));
    await tester.pumpAndSettle();
    await gesture.moveTo(tester.getCenter(rowFor('Escrow')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));
    expect(
      (_fillOf(tester, rowFor('Escrow')).decoration as BoxDecoration).color,
      Colors.transparent,
    );
    expect(tester.takeException(), isNull);
  });

  // 9 -------------------------------------------------------------------
  testWidgets('an empty wallet shows no rail', (tester) async {
    _surface(tester);
    await tester.pumpWidget(
      _host(width: 1200, gw: gwFor(GWAppearanceMode.dark), txs: const []),
    );
    expect(tester.takeException(), isNull);

    // RED if the `scoped.isNotEmpty` guard is dropped — 15-03's rule, applied
    // to the page presentation.
    expect(railFinder, findsNothing);
    expect(find.text(emptyTransactionsTitle), findsOneWidget);
  });

  // 10 ------------------------------------------------------------------
  testWidgets('a narrow page falls back to the panel', (tester) async {
    _surface(tester);
    // ONE escrow row, not `_mixed()`: at 600-768px the harness's one-em-per-
    // character fallback font makes a busy transaction row overflow for a
    // reason that does not exist on screen. `escrow`'s subtitle reads "Locked"
    // then "in escrow" since 179-C deleted the action chip and moved the verb
    // down to lead that line, colliding with no rail label (15-03's finding).
    final txs = [_tx(type: TransactionType.escrow)];

    // The surface stays 1400 throughout: the SizedBox shrinks, not the window,
    // so the branch is chosen by the widget under test rather than by the
    // harness. Without that, all three widths below would collapse to 800 and
    // this test would assert nothing at all.
    for (final width in <double>[600, 767]) {
      await tester.pumpWidget(
        _host(width: width, gw: gwFor(GWAppearanceMode.dark), txs: txs),
      );
      expect(tester.takeException(), isNull, reason: '$width');
      // RED if the `wide` boolean is removed and a 220px rail is forced beside
      // a list at phone width.
      expect(railFinder, findsNothing, reason: '$width');
      expect(barFinder, findsOneWidget, reason: '$width');
    }

    // The boundary PAIR. `wide` is the one layout-derived value in the whole
    // page path, and an off-by-one in `>=` vs `>` is invisible at 600 and 1200.
    await tester.pumpWidget(
      _host(width: 768, gw: gwFor(GWAppearanceMode.dark), txs: txs),
    );
    expect(tester.takeException(), isNull);
    expect(railFinder, findsOneWidget);
    expect(barFinder, findsNothing);
  });
}
