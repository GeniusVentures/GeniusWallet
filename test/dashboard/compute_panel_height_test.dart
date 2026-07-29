import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/theme/theme.dart';

/// Measures `ComputePanel`, not estimates it. Every member of
/// `ComputeState.values` (eight - state 04 Stalled is parked, see
/// `compute_state.dart`'s own `ponytail:` comment) is pumped inside the REAL
/// `DashboardScrollContainer` at two widths and its rendered size is read
/// back with `tester.getSize`. `14-CONTEXT.md`'s standing rule is to
/// re-derive every inherited number rather than quote it - this file derives
/// its own budget below instead of trusting the 276px the roadmap, the
/// sketches and the context document all carry.
///
/// ---------------------------------------------------------------------
/// DERIVING 274, NOT 276 - the number this file actually asserts against.
/// ---------------------------------------------------------------------
///
/// `dashboard_screen.dart:210/212` caps the panel's slot at
/// `ConstrainedBox(maxHeight: 300)` (also `:293`/`:298` in the one-column
/// layout). `DashboardScrollContainer` (`dashboard_screen.dart:320-345`) is a
/// `Container` whose `decoration` is `GWDecorations.surface(...)`, which sets
/// `border: Border.all(width: 1)` (`genius_wallet_decorations.dart:99-102`),
/// and separately applies `padding: EdgeInsets.all(GeniusWalletConsts.space6)`
/// (12px each side, 24px total).
///
/// A Flutter `Container` that carries BOTH an explicit `padding` and a
/// `decoration` does not apply them independently - `Container.build()`
/// combines them via `_paddingIncludingDecoration`, which is
/// `padding.add(decoration.padding)`, and `BoxDecoration.padding` returns the
/// border's own `EdgeInsets` (`border.dimensions`, 1px per side for
/// `Border.all(width: 1)`). So the CONTENT region inside
/// `DashboardScrollContainer` is inset by `padding + border width` per side,
/// not `padding` alone: `(12 + 1) * 2 = 26`, not `12 * 2 = 24`.
///
/// `300 - 26 = 274` - the number this file asserts, and **not the 276px
/// carried by the roadmap, the sketches and `14-CONTEXT.md`**, all of which
/// only counted the `EdgeInsets.all(space6)` padding and missed the border's
/// own fold-in. Losing those 2px matters: the inherited design had 3px of
/// slack and this phase's own tile-padding lever (`compute_panel.dart`'s
/// `_ComputeCardTile`, `vertical: space4` instead of `space6`) is what buys
/// the ~6px of headroom the worst state actually has against 274.
///
/// `test/dashboard/transaction_filter_rail_test.dart`'s own comment ("the
/// rail CARD is 220 and its content box is 194... 194, not the 196 a
/// padding-only reading gives") independently confirms the identical
/// border-fold arithmetic for a DIFFERENT `DashboardScrollContainer`
/// consumer at a different card size, so this is not a one-off reading.
///
/// ---------------------------------------------------------------------
/// TWO WIDTHS PER STATE
/// ---------------------------------------------------------------------
///
/// `_kRealisticPanelWidth` approximates `OverviewDashboardView`'s width at
/// the two-column layout's own onset: `dashboard_screen.dart:66` switches to
/// desktop layout above `GeniusBreakpoints.medium` (768px), and
/// `_OverviewContributionsRow` (`dashboard_screen.dart:236-256`) gives the
/// panel `flex: 2` of a 5-wide split next to `ContributionsDashboardView`'s
/// `flex: 3`, inside a row that has already lost `space3` (6px) to the
/// two-column body's own outer padding on each side and `space3` again as
/// the row's inter-child spacing. At the narrowest reachable two-column
/// width that arithmetic lands the panel around 300px; 320 is used here with
/// a small margin rather than the exact boundary value.
///
/// `_kNarrowPanelWidth` is deliberately narrower than the true reachable
/// minimum computed above (roughly 300px, at the two-column layout's own
/// 768px onset) - it exists purely as the stress case `14-07-PLAN.md` Task 2
/// calls for: proving no sub-line wraps into a second line box under width
/// pressure beyond what production ever applies. It is bounded below by a
/// different, genuine constraint rather than chosen arbitrarily: a sub-line
/// carrying the longest inline link (`Choose a wallet ›` / `See node status
/// ›`) is a `Row` whose link segment is deliberately NEVER allowed to
/// truncate (`14-UI-SPEC.md §1.5.2` - "the affordance never truncates").
/// Going narrower than this necessarily forces that Row to overflow
/// (measured: both 240px and 280px throw `A RenderFlex overflowed`), which
/// is a symptom of the SAME width no production layout ever reaches, not a
/// bug this panel needs to defend against.
const double _kRealisticPanelWidth = 320;
const double _kNarrowPanelWidth = 290;

/// The panel's own budget, independent of the container's - see the file
/// doc comment above for the full derivation. `300 - 2*(12 + 1) = 274`.
const double _kPanelContentBudget = 274;
const double _kContainerBudget = 300;

/// Builds the view model for [state] with plain, fixed inputs. Only
/// [ComputeState.startingUp] takes free-form caller input
/// (`initStatusMessage`); every other state's label/sub-line/trailing is
/// fully determined by `viewForComputeState`'s own switch, so there is
/// nothing else for a test fixture to vary. The starting-up message is
/// deliberately longer than the SDK's own fallback string
/// (`startingUpFallbackMessage`) to exercise the ellipsis path rather than
/// merely the short default.
ComputeStatusView _viewFor(ComputeState state) {
  return viewForComputeState(
    state,
    initStatusMessage: state == ComputeState.startingUp
        ? 'Connecting to the SuperGenius network and preparing the local '
              'compute node for the next job'
        : null,
    initPercentage: state == ComputeState.startingUp ? 0.6 : null,
    processingPercentage: state == ComputeState.processing ? 52.5 : null,
  );
}

Future<void> _pump(WidgetTester tester, ComputeState state, double width) {
  return tester.pumpWidget(
    MaterialApp(
      theme: getThemeData(),
      home: Scaffold(
        body: SingleChildScrollView(
          // Unbounded height, exactly like the test file this mirrors
          // (`transactions_page_frame_test.dart`'s own harness note): the
          // panel's true intrinsic height is what this file measures, not
          // whatever the 800x600 default test surface would otherwise clip
          // it to.
          child: SizedBox(
            width: width,
            child: DashboardScrollContainer(
              child: ComputePanel(
                view: _viewFor(state),
                balance: 1234.56,
                fiatSubline: '≈ \$312.40',
                onLinkTap: (_) {},
                onNewJob: () {},
              ),
            ),
          ),
        ),
      ),
    ),
  );
}

void main() {
  for (final width in [_kRealisticPanelWidth, _kNarrowPanelWidth]) {
    for (final state in ComputeState.values) {
      testWidgets('${state.name} fits the height budget at ${width}px', (
        tester,
      ) async {
        await _pump(tester, state, width);
        await tester.pump();

        expect(tester.takeException(), isNull);

        final container = tester.getSize(find.byType(DashboardScrollContainer));
        final panel = tester.getSize(find.byType(ComputePanel));

        // The outer assertion is the REAL constraint the dashboard enforces
        // and cannot be got wrong by arithmetic; the inner one is the
        // diagnostic that says which side of the container's inset a
        // regression came from.
        expect(
          container.height,
          lessThanOrEqualTo(_kContainerBudget),
          reason:
              'DashboardScrollContainer measured ${container.height} for '
              '${state.name} at ${width}px - over the dashboard\'s own '
              '$_kContainerBudget cap (dashboard_screen.dart:210/212).',
        );
        expect(
          panel.height,
          lessThanOrEqualTo(_kPanelContentBudget),
          reason:
              'ComputePanel measured ${panel.height} for ${state.name} at '
              '${width}px - over the $_kPanelContentBudget budget derived '
              'in this file\'s doc comment (300 - 2*(space6 + border) = '
              '274, not the inherited 276).',
        );
      });
    }
  }

  testWidgets('no sub-line wraps into a second line box at the narrow width', (
    tester,
  ) async {
    // A second line box is exactly what the maxLines:1/ellipsis rule
    // (`14-UI-SPEC.md §1.5.1`) exists to prevent. Every rendered `Text`
    // inside the panel that is allowed to carry free-form/longer content
    // must stay at a single 18px-or-shorter line box even under the
    // deliberately narrow width - if one silently grew to two lines, the
    // corresponding state's total height assertion above would already
    // have failed, but this test names the mechanism directly rather than
    // only its symptom.
    for (final state in ComputeState.values) {
      await _pump(tester, state, _kNarrowPanelWidth);
      await tester.pump();

      for (final textWidget in tester.widgetList<Text>(
        find.descendant(
          of: find.byType(ComputePanel),
          matching: find.byType(Text),
        ),
      )) {
        final maxLines = textWidget.maxLines;
        expect(
          maxLines,
          anyOf(isNull, 1),
          reason:
              'A Text with maxLines > 1 inside ComputePanel for '
              '${state.name} would silently blow the height budget under '
              'width pressure.',
        );
        if (maxLines == 1) {
          expect(
            textWidget.overflow,
            TextOverflow.ellipsis,
            reason:
                'A single-line Text without ellipsis overflow inside '
                'ComputePanel for ${state.name} would clip instead of '
                'truncating, which is a readability bug even though it '
                'does not blow the height budget.',
          );
        }
      }
    }
  });
}
