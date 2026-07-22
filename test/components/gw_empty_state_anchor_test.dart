import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

/// `GWEmptyState` is a SHARED component with five call sites, and this plan
/// (15-02) changes its outermost layout. Nothing in phase 15 walks Assets, the
/// dashboard Markets error card or the design gallery, so this file is the
/// substitute for walking them: it pins the THREE constraint shapes those call
/// sites hand the widget, plus the compact tier quick task 260721-e3r shipped.
///
///   1. tall bounded   -> transactions_slim_view.dart, both `_body` empty
///                        branches, under the panel's `Expanded`
///   2. short bounded  -> dashboard_screen.dart, the Markets `coins.isEmpty`
///                        branch (~114px card)
///   3. unbounded      -> design_gallery_screen.dart, the
///                        `Column(crossAxisAlignment: stretch)` states section
///
/// Call sites are named by BRANCH, not by line number: the transactions file is
/// under active edit and those two lines moved 247/258 -> 264/282 during this
/// plan alone.
///
/// Every test names, in a comment or its `reason:`, the mutation that reddens
/// it. None of them is a "the widget exists" assertion.

/// `flutter_test`'s default surface is 800x600 logical at dpr 3.0, and no other
/// test in this repo changes it. A `SizedBox(height: 1400)` inside a 600px
/// surface silently collapses to 600, which would make every number below a
/// lie. Widen the surface, and ALWAYS restore it — a leaked surface size
/// changes every test file that runs after this one in the same shard.
void _useTallSurface(WidgetTester tester) {
  tester.view.physicalSize = const Size(1200 * 3, 1600 * 3); // logical x dpr
  tester.view.devicePixelRatio = 3.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

const _slotKey = ValueKey('slot');

/// The real transactions copy (`emptyTransactionsTitle`/`Message`), so the
/// measured geometry is the geometry a user actually gets. Note the test font
/// is Ahem — one square glyph per character — so at the 600px harness width
/// this message wraps to TWO lines, exactly as the plan's numbers assume.
const _title = 'No transactions yet';
const _message = 'Your sends, receives and swaps will appear here.';

/// Shapes 1 and 2: a fixed-height slot, i.e. what an `Expanded` or a sized
/// dashboard card hands the widget. `Align(topLeft)` rather than `Center` so
/// the slot's own top is a stable origin regardless of surface height.
Widget _boundedHost(double height, {bool withAction = false}) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: Align(
      alignment: Alignment.topLeft,
      child: SizedBox(
        key: _slotKey,
        width: 600,
        height: height,
        child: GWEmptyState(
          title: _title,
          message: _message,
          actionLabel: withAction ? 'Show all' : null,
          onAction: withAction ? () {} : null,
        ),
      ),
    ),
  ),
);

/// Shape 3: the design gallery's own shape — a non-flexible child of a
/// stretched `Column` inside a scroll view, so `constraints.maxHeight` reaching
/// the widget's `LayoutBuilder` is `double.infinity`.
Widget _unboundedHost() => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(
    body: SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: const [GWEmptyState(title: _title, message: _message)],
      ),
    ),
  ),
);

/// Vertical centre of the icon circle, measured from the TOP OF THE SLOT — not
/// from the harness window, so the assertions survive a surface change.
double _iconCentreFromSlotTop(WidgetTester tester) =>
    tester.getRect(find.byType(Icon)).center.dy -
    tester.getRect(find.byKey(_slotKey)).top;

void main() {
  testWidgets('a tall slot anchors the block near the top', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_boundedHost(1400));

    // Goes red if: the Align/ConstrainedBox is reverted to a bare `Center`.
    expect(
      _iconCentreFromSlotTop(tester),
      closeTo(192.0, 8),
      reason:
          'sketch 020 measured the block at the midpoint of the ~1400px '
          '/transactions slot — below the fold on a laptop. Measured here '
          'against the pre-fix widget the icon centre sat at dy 652.0; the '
          'anchored tree puts it at 192.0. A bare `Center` cannot produce a '
          'number in this band at this slot height.',
    );
    // The lower bound matters as much as the upper one: an anchor that pinned
    // the block flush to dy 0 would also pass `< 480`.
    expect(_iconCentreFromSlotTop(tester), greaterThan(0));
    // 480 is `_anchorSearchHeight`, inlined because the constant is private.
    expect(_iconCentreFromSlotTop(tester), lessThan(480));
    expect(tester.takeException(), isNull);
  });

  testWidgets('a short slot is byte-identical to today', (tester) async {
    _useTallSurface(tester);
    // 300px: above the 192 compact threshold, below the 480 anchor cap, so the
    // cap does not bind and the tree must behave exactly like today's `Center`.
    await tester.pumpWidget(_boundedHost(300));

    final slot = tester.getRect(find.byKey(_slotKey));
    final block = tester.getRect(find.byType(Column).last);
    final gapAbove = block.top - slot.top;
    final gapBelow = slot.bottom - block.bottom;

    // Centring is asserted as a RELATION (equal gaps), not a hardcoded pixel,
    // so it stays true if the content's own height ever changes.
    // Goes red if: the implementation uses sketch 021's rejected variant `a`
    // (topCenter + space16) or `b` (topCenter + space32) — a fixed offset from
    // the top makes gapAbove a constant while gapBelow tracks the slot.
    expect(
      gapAbove,
      closeTo(gapBelow, 1),
      reason:
          'below the 480 cap the anchored tree must be indistinguishable '
          'from the plain `Center` this widget shipped with — the fix is a '
          'RULE, not an offset, so nothing regresses where the current layout '
          'is already fine. Measured pre-fix: icon centre dy 102.0 in a 300px '
          'slot, block gaps 66/66.',
    );
    expect(_iconCentreFromSlotTop(tester), closeTo(102.0, 1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('an unbounded slot still sizes to its content', (tester) async {
    _useTallSurface(tester);
    await tester.pumpWidget(_unboundedHost());

    // Goes red if: the `isHeightBounded` guard is dropped and the cap is
    // applied unconditionally. `ConstrainedBox(maxHeight: 480)` under an
    // infinite height hands its `Center` a bounded 0..480, `Center` takes the
    // largest allowed size, and the widget inflates from 192 to exactly 480 —
    // the design gallery grows a 288px void.
    expect(
      tester.getSize(find.byType(GWEmptyState)).height,
      lessThan(480),
      reason:
          'design_gallery_screen.dart:757 sits in a stretched Column, so '
          'maxHeight is infinity. Pre-fix and required post-fix: 192.0 — the '
          "widget's own content height. 480 means the cap was applied to an "
          'unbounded slot.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the compact tier still fires under its threshold', (
    tester,
  ) async {
    _useTallSurface(tester);
    // 170, NOT 150. `_compactLayoutHeight` is 156 — the worst-case height of
    // the COMPACT layout — so a 150px slot overflows the compact layout itself
    // by exactly 6.0px (measured) and this test would fail on arrival for a
    // reason that has nothing to do with the anchor. 170 sits in the real
    // target band: under the 192 threshold, over the 156 the layout needs.
    await tester.pumpWidget(_boundedHost(170));

    // Goes red if: the compact decision is ever fed the capped height instead
    // of the real slot height (verified: substituting `_anchorSearchHeight`
    // for `constraints.maxHeight` in the `isCompact` line yields icon 32.0).
    //
    // It does NOT go red if the `ConstrainedBox` is hoisted outside the
    // `LayoutBuilder` — verified too. At 170px the cap never binds, so the
    // builder still sees 170 either way; that mutation reddens tests 2, 3 and
    // 5 instead. Recorded so the next reader does not trust a mutation this
    // test cannot actually catch.
    expect(
      (tester.widget(find.byType(Icon)) as Icon).size,
      24.0, // _iconGlyphCompact; the full tier is 32
      reason:
          'the adaptive compact tier quick task 260721-e3r shipped must '
          'keep selecting from the REAL slot height. The anchor cap lives '
          'inside the LayoutBuilder, so constraints.maxHeight is untouched.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('an action-bearing state keeps its button in a tall slot', (
    tester,
  ) async {
    _useTallSurface(tester);
    // transactions_slim_view.dart:258 — the filtered-empty branch. Its
    // effective threshold is 256, not 192, and it is the shape most likely to
    // be forgotten when the subtree is hoisted into a local.
    await tester.pumpWidget(_boundedHost(1400, withAction: true));

    // Goes red if: the action block is dropped from the hoisted `content`, or
    // the cap is set below the action-bearing layout height.
    expect(find.text('Show all'), findsOneWidget);
    expect(_iconCentreFromSlotTop(tester), lessThan(480));
    expect(tester.takeException(), isNull);
  });
}
