import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
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
/// DERIVING 314, NOT 316 - the number this file actually asserts against.
/// ---------------------------------------------------------------------
///
/// **Re-derived 2026-07-31**, when the slot went 300 -> 340 so the Compute
/// panel could adopt `GWSectionTitle` and put Balance on the same baseline as
/// the first Assets coin. The arithmetic below is unchanged; only the slot it
/// starts from moved. The old numbers were `300 - 26 = 274`.
///
/// The slot is `kDashboardPanelSlotHeight` (`dashboard_screen.dart`), imported
/// here rather than copied, so this file cannot silently disagree with the
/// layout again. `DashboardScrollContainer` (`dashboard_screen.dart`) is a
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
/// `340 - 26 = 314` - the number this file asserts, and **not the 316px a
/// padding-only reading gives**, which counts only the `EdgeInsets.all(space6)`
/// padding and misses the border's own fold-in. Losing those 2px matters: the
/// inherited design had 3px of
/// slack and this phase's own tile-padding lever (`compute_panel.dart`'s
/// `_ComputeCardTile`, `vertical: space4` instead of `space6`) is what buys
/// the headroom the worst state actually has against the budget.
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
/// doc comment above for the full derivation: slot - 2*(space6 + 1px border).
///
/// Derived from the production constant, never re-typed: if someone changes
/// the slot again, this file follows instead of asserting against a number
/// the layout no longer uses.
const double _kContainerBudget = kDashboardPanelSlotHeight;
const double _kPanelContentBudget =
    _kContainerBudget - 2 * (GeniusWalletConsts.space6 + 1);

/// Builds the view model for [state] with plain, fixed inputs. Every
/// state's label/sub-line/trailing is fully determined by
/// `viewForComputeState`'s own switch, so there is nothing for a test
/// fixture to vary beyond the two native-scale percentages.
///
/// `startingUp` no longer takes a free-form `initStatusMessage` -
/// `14-09-PLAN.md` Task 1b replaced its sub-line with the fixed `Feed live`
/// copy and deleted the parameter entirely, so the ellipsis path this
/// fixture used to exercise (a long message forced to truncate) no longer
/// exists for this state: `Feed live` is short and fixed, never long
/// enough to wrap or truncate.
ComputeStatusView _viewFor(ComputeState state) {
  return viewForComputeState(
    state,
    initPercentage: state == ComputeState.startingUp ? 0.6 : null,
    processingPercentage: state == ComputeState.processing ? 52.5 : null,
  );
}

Future<void> _pump(
  WidgetTester tester,
  ComputeState state,
  double width, {
  bool useMinions = false,
}) {
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
                useMinions: useMinions,
                onUnitChanged: (_) {},
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
  // `useMinions: true` is included below (`14-08-PLAN.md` Task 3's
  // extension) because the "MINIONS" label is longer than "GNUS" and the
  // unit toggle now costs real height (>=24px hit area, not the free
  // inline suffix originally proposed) - both are stress conditions the
  // pre-Task-3 fixture never exercised. A state over the content budget in
  // either unit is a failure, not a rounding error.
  for (final width in [_kRealisticPanelWidth, _kNarrowPanelWidth]) {
    for (final state in ComputeState.values) {
      for (final useMinions in [false, true]) {
        final unitLabel = useMinions ? 'minions' : 'GNUS';
        testWidgets(
          '${state.name} fits the height budget at ${width}px ($unitLabel)',
          (tester) async {
            await _pump(tester, state, width, useMinions: useMinions);
            await tester.pump();

            expect(tester.takeException(), isNull);

            final container = tester.getSize(
              find.byType(DashboardScrollContainer),
            );
            final panel = tester.getSize(find.byType(ComputePanel));

            // The outer assertion is the REAL constraint the dashboard
            // enforces and cannot be got wrong by arithmetic; the inner one
            // is the diagnostic that says which side of the container's
            // inset a regression came from.
            expect(
              container.height,
              lessThanOrEqualTo(_kContainerBudget),
              reason:
                  'DashboardScrollContainer measured ${container.height} for '
                  '${state.name} ($unitLabel) at ${width}px - over the '
                  'dashboard\'s own $_kContainerBudget cap '
                  '(dashboard_screen.dart:210/212).',
            );
            expect(
              panel.height,
              lessThanOrEqualTo(_kPanelContentBudget),
              reason:
                  'ComputePanel measured ${panel.height} for ${state.name} '
                  '($unitLabel) at ${width}px - over the '
                  '$_kPanelContentBudget budget derived in this file\'s doc '
                  'comment (slot - 2*(space6 + border), not the '
                  'inherited 276).',
            );
          },
        );
      }
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
