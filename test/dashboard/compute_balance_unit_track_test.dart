// Proves the properties `260731-kc5-PLAN.md` names as "must not regress" for
// the Compute panel's balance unit control - now a two-segment
// `GWControlTrack` (`_UnitTrack`/`_UnitSegment` in
// `lib/dashboard/compute/compute_panel.dart`) rather than the old
// single-label `_UnitToggle`.
//
// Deliberately narrow, mirroring `compute_panel_height_test.dart`'s own
// split: THAT file proves the track costs no height across every state at
// both widths; THIS file proves the seven other properties sketch 170 and
// the plan's `<the_three_properties_that_must_not_regress>` section name -
// visibility, height (by comparison, not a magic number), the 24x24 floor,
// semantics, keyboard operability, the double-tap-does-not-flip guarantee,
// and the honest width/clipping cost at both widths.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/data/gw_animated_number.dart';
import 'package:genius_wallet/components/gw_control_track.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/theme.dart';

/// `flutter test` never loads a project's bundled font assets by default -
/// every unspecified/undeclared `fontFamily` falls back to a single
/// deterministic test typeface with its OWN glyph metrics, not the real
/// font. That is invisible to every other assertion in this suite (they
/// measure height, which this test font approximates closely enough), but
/// it is NOT invisible to test 8 below, which measures the balance number's
/// rendered TEXT WIDTH to judge whether it clips - and the test font's
/// digits measure roughly 1.7x wider than real `Inter-Bold` at this size
/// (manually verified: the same string via `TextPainter` measured 316px
/// under the fallback test font vs 178.7px once this font is loaded). Only
/// `Inter-Bold` (`weight: 700`, `pubspec.yaml`) is loaded - it is the only
/// family/weight `GeniusWalletTypography.numericDisplay` actually requests
/// - so the NUMBER's measured width is now the real, production one; the
/// track/chip labels (`_UnitSegment`'s `Text` sets no `fontFamily` at all,
/// matching `_TimeframeTab` exactly) still render in the deterministic test
/// font, the same as every other measurement in this file and in
/// `compute_panel_height_test.dart` - there is no bundled Roboto/system-font
/// asset in this repo to load for those instead.
Future<void> _loadRealNumberFont() async {
  final data = await rootBundle.load('assets/fonts/Inter-Bold.ttf');
  final loader = FontLoader('Inter')..addFont(Future.value(data));
  await loader.load();
}

/// Same two widths `compute_panel_height_test.dart` derives and documents -
/// re-declared here (both files are private-const, so neither can import the
/// other's) rather than widened to a shared constant nothing else needs.
/// `_kRealisticPanelWidth` is the two-column layout's own onset with a small
/// margin; `_kNarrowPanelWidth` is a deliberate stress case below production
/// reach.
const double _kRealisticPanelWidth = 320;
const double _kNarrowPanelWidth = 290;

/// A plausible large minions balance, not `1234.56` - this is the fixture
/// Task 2 calls for to exercise the real width cost of the wider `MIN`
/// track against a number that actually grows several digits when the unit
/// flips, the way tapping the toggle in production does.
const double _kLargeMinionsBalance = 987654.32;

ComputeStatusView _viewFor(ComputeState state) {
  return viewForComputeState(
    state,
    initPercentage: state == ComputeState.startingUp ? 0.6 : null,
    processingPercentage: state == ComputeState.processing ? 52.5 : null,
  );
}

/// Records every call `onUnitChanged` receives, in order - the no-op and
/// switch tests both read this rather than a single last-value field, so a
/// double-tap's TWO calls (or absence of calls) are both visible.
class _UnitChangeRecorder {
  final List<bool> calls = [];
  void call(bool useMinions) => calls.add(useMinions);
}

Future<void> _pump(
  WidgetTester tester,
  ComputeState state,
  double width, {
  required bool useMinions,
  required ValueChanged<bool> onUnitChanged,
  double balance = 1234.56,
}) {
  return tester.pumpWidget(
    MaterialApp(
      theme: getThemeData(),
      home: Scaffold(
        body: SingleChildScrollView(
          child: SizedBox(
            width: width,
            child: DashboardScrollContainer(
              child: ComputePanel(
                view: _viewFor(state),
                balance: balance,
                fiatSubline: '≈ \$312.40',
                useMinions: useMinions,
                onUnitChanged: onUnitChanged,
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
  setUpAll(_loadRealNumberFont);

  testWidgets('both units are visible without pressing anything', (
    tester,
  ) async {
    final recorder = _UnitChangeRecorder();
    await _pump(
      tester,
      ComputeState.ready,
      _kRealisticPanelWidth,
      useMinions: false,
      onUnitChanged: recorder.call,
    );
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    // Both labels render, in order, inside ONE GWControlTrack - scheme B's
    // entire claim (sketch 170): nothing has to be discovered by pressing.
    expect(find.byType(GWControlTrack), findsOneWidget);
    expect(find.text('GNUS'), findsOneWidget);
    expect(find.text('MIN'), findsOneWidget);

    final track = tester.getTopLeft(find.byType(GWControlTrack));
    final gnus = tester.getTopLeft(find.text('GNUS'));
    final min = tester.getTopLeft(find.text('MIN'));
    expect(
      gnus.dx,
      lessThan(min.dx),
      reason:
          'GNUS must render before MIN in the track, matching the '
          'plan and the sketch.',
    );
    expect(track.dx, lessThanOrEqualTo(gnus.dx));
  });

  testWidgets(
    'the track costs no height - it is no taller than the numeral it sits '
    'beside, proven by comparison not a hard-coded number',
    (tester) async {
      final recorder = _UnitChangeRecorder();
      await _pump(
        tester,
        ComputeState.ready,
        _kRealisticPanelWidth,
        useMinions: false,
        onUnitChanged: recorder.call,
      );
      await tester.pumpAndSettle();

      final trackHeight = tester.getSize(find.byType(GWControlTrack)).height;
      final numeralHeight = tester
          .getSize(find.byType(GWAnimatedNumber))
          .height;

      // The balance value sits in a `Row`, so its height is the MAX of its
      // two children - if the numeral is the taller one, the row's total
      // height is unchanged by construction and no hard-coded 40/32 can go
      // stale under a future type-scale or track-geometry edit.
      expect(
        trackHeight,
        lessThanOrEqualTo(numeralHeight),
        reason:
            'GWControlTrack measured ${trackHeight}px, GWAnimatedNumber '
            'measured ${numeralHeight}px - the track must not be the '
            'taller of the two, or the balance row grows and the panel '
            'height budget moves.',
      );
    },
  );

  testWidgets('every segment clears the 24x24 WCAG 2.5.8 minimum target', (
    tester,
  ) async {
    final recorder = _UnitChangeRecorder();
    await _pump(
      tester,
      ComputeState.ready,
      _kRealisticPanelWidth,
      useMinions: false,
      onUnitChanged: recorder.call,
    );
    await tester.pumpAndSettle();

    // Each segment is an InkWell inside GWControlTrack - reading its
    // rendered box size (rather than the label's own glyph box) is the
    // correction `_UnitToggle`'s own doc comment records once already
    // getting wrong ("+8px, not 0"): this asserts the CONSTRAINED size, not
    // an assumption derived from font metrics.
    final segments = find.descendant(
      of: find.byType(GWControlTrack),
      matching: find.byType(InkWell),
    );
    expect(segments, findsNWidgets(2));

    for (var i = 0; i < 2; i++) {
      final size = tester.getSize(segments.at(i));
      expect(
        size.width,
        greaterThanOrEqualTo(24),
        reason:
            'Segment $i width ${size.width} is under the 24px WCAG '
            '2.5.8 floor.',
      );
      expect(
        size.height,
        greaterThanOrEqualTo(24),
        reason:
            'Segment $i height ${size.height} is under the 24px WCAG '
            '2.5.8 floor.',
      );
    }
  });

  testWidgets(
    'semantics announce both options and which is selected - GNUS active',
    (tester) async {
      final handle = tester.ensureSemantics();
      final recorder = _UnitChangeRecorder();
      await _pump(
        tester,
        ComputeState.ready,
        _kRealisticPanelWidth,
        useMinions: false,
        onUnitChanged: recorder.call,
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('GNUS')),
        matchesSemantics(
          label: 'GNUS',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );
      // The full word, not the visible `MIN` abbreviation - WCAG 2.5.3
      // Label in Name is satisfied by case-insensitive substring match
      // ("min" is contained in "Minions"), and this is the deliberate,
      // stronger choice: an AT user hears the full word regardless of what
      // the abbreviation reads as to a sighted user.
      expect(
        tester.getSemantics(find.bySemanticsLabel('Minions')),
        matchesSemantics(
          label: 'Minions',
          isButton: true,
          hasSelectedState: true,
          isSelected: false,
        ),
      );

      handle.dispose();
    },
  );

  testWidgets(
    'semantics announce both options and which is selected - minions active',
    (tester) async {
      final handle = tester.ensureSemantics();
      final recorder = _UnitChangeRecorder();
      await _pump(
        tester,
        ComputeState.ready,
        _kRealisticPanelWidth,
        useMinions: true,
        onUnitChanged: recorder.call,
      );
      await tester.pumpAndSettle();

      expect(
        tester.getSemantics(find.bySemanticsLabel('GNUS')),
        matchesSemantics(
          label: 'GNUS',
          isButton: true,
          hasSelectedState: true,
          isSelected: false,
        ),
      );
      expect(
        tester.getSemantics(find.bySemanticsLabel('Minions')),
        matchesSemantics(
          label: 'Minions',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );

      handle.dispose();
    },
  );

  testWidgets(
    'keyboard operability is not lost - each segment is an InkWell with a '
    'live onTap, not a GestureDetector',
    (tester) async {
      final recorder = _UnitChangeRecorder();
      await _pump(
        tester,
        ComputeState.ready,
        _kRealisticPanelWidth,
        useMinions: false,
        onUnitChanged: recorder.call,
      );
      await tester.pumpAndSettle();

      // A GestureDetector would pass a plain tap test and fail this one -
      // which is exactly the regression this asserts against. Focus
      // traversal itself is not cheaply assertable in this harness without
      // a FocusScope wired end-to-end; the InkWell assertion plus the walk
      // step (`260731-kc5-PLAN.md` human-check item 8: Tab + Enter) is the
      // gate.
      final inkWells = tester
          .widgetList<InkWell>(
            find.descendant(
              of: find.byType(GWControlTrack),
              matching: find.byType(InkWell),
            ),
          )
          .toList();
      expect(inkWells, hasLength(2));
      for (final inkWell in inkWells) {
        expect(inkWell.onTap, isNotNull);
      }
      // NB: `InkWell` itself is internally BUILT on a `GestureDetector` (its
      // `_InkResponseState` wires one up to drive the splash), so a
      // `GestureDetector` being present under `GWControlTrack` here is
      // expected and is not the regression this test guards against - the
      // regression is a *bare* `GestureDetector` with no `InkWell`/`Material`
      // wrapping it, which the `InkWell` assertion above already rules out.
    },
  );

  testWidgets(
    'tapping the active segment is a no-op - including on an immediate '
    'double tap',
    (tester) async {
      final handle = tester.ensureSemantics();
      final recorder = _UnitChangeRecorder();
      await _pump(
        tester,
        ComputeState.ready,
        _kRealisticPanelWidth,
        useMinions: false,
        onUnitChanged: recorder.call,
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('GNUS'));
      await tester.pump();

      // The component calls onUnitChanged(false) unconditionally
      // (`260731-kc5-PLAN.md`'s state-shape decision) - so tapping the
      // already-active GNUS segment either does not fire, or fires with
      // `false` again. It must NEVER fire with `true`: that would be the
      // flip a toggle-shaped callback could produce.
      expect(recorder.calls, everyElement(isFalse));
      // The panel still shows GNUS selected - ComputePanel is stateless and
      // only reflects what its caller passes in, so this reads back the
      // same `useMinions: false` this pump supplied, proving the tap did
      // not silently desync the rendered selection from the recorded calls.
      expect(
        tester.getSemantics(find.bySemanticsLabel('GNUS')),
        matchesSemantics(
          label: 'GNUS',
          isButton: true,
          hasSelectedState: true,
          isSelected: true,
        ),
      );

      // Two taps in immediate succession, no settle in between - the exact
      // double-tap/stuck-touch/fast-test-pump scenario the plan's
      // state-shape section names as the bug this callback shape makes
      // structurally impossible.
      recorder.calls.clear();
      await tester.tap(find.text('GNUS'));
      await tester.tap(find.text('GNUS'));
      await tester.pump();

      expect(recorder.calls, everyElement(isFalse));
      handle.dispose();
    },
  );

  testWidgets('tapping the other segment switches the unit', (tester) async {
    final recorder = _UnitChangeRecorder();
    await _pump(
      tester,
      ComputeState.ready,
      _kRealisticPanelWidth,
      useMinions: false,
      onUnitChanged: recorder.call,
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('MIN'));
    await tester.pump();

    expect(recorder.calls, isNotEmpty);
    expect(recorder.calls.last, isTrue);
  });

  group('the width cost is measured, not estimated, at both widths', () {
    for (final width in [_kRealisticPanelWidth, _kNarrowPanelWidth]) {
      testWidgets('at ${width}px, with a large minions balance', (
        tester,
      ) async {
        final recorder = _UnitChangeRecorder();
        await _pump(
          tester,
          ComputeState.ready,
          width,
          useMinions: true,
          onUnitChanged: recorder.call,
          balance: _kLargeMinionsBalance,
        );
        await tester.pumpAndSettle();

        expect(tester.takeException(), isNull);

        final trackWidth = tester.getSize(find.byType(GWControlTrack)).width;

        // NumberFormat.decimalPatternDigits (`gw_animated_number.dart:53`)
        // adds thousands separators, so the rendered string is read off the
        // real widget rather than assumed from the raw digit count.
        final renderedText = tester
            .widget<Text>(
              find.descendant(
                of: find.byType(GWAnimatedNumber),
                matching: find.byType(Text),
              ),
            )
            .data!;

        final painter = TextPainter(
          text: TextSpan(
            text: renderedText,
            style: GeniusWalletTypography.numericDisplay,
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        // `.first` because TWO SingleChildScrollViews are ancestors here -
        // this harness's own outer one (mirroring the height test's `_pump`
        // shape, for unbounded height) and the balance tile's inner one
        // (`compute_panel.dart`'s horizontal, never-scrollable guard around
        // `GWAnimatedNumber`). `find.ancestor` walks from nearest to
        // furthest, so `.first` is the inner one - the actual viewport this
        // test needs to measure.
        final viewportWidth = tester
            .getSize(
              find
                  .ancestor(
                    of: find.byType(GWAnimatedNumber),
                    matching: find.byType(SingleChildScrollView),
                  )
                  .first,
            )
            .width;

        // Printed unconditionally (not just on failure) - Task 2 asks for
        // the measured numbers to be recorded, and this plan's own
        // `<the_numbers_re_derived>` estimate (~98px track, using real
        // Inter/system glyph metrics by hand) is superseded by whatever
        // this line prints on the next run; it is the authority, not the
        // estimate. `debugPrint`, not `print` - `avoid_print` is on
        // (`flutter_lints`) and `debugPrint` is its sanctioned escape hatch.
        debugPrint(
          'Measured at ${width}px: track=${trackWidth}px, '
          'rendered number "$renderedText" wants ${painter.width}px, '
          'viewport got ${viewportWidth}px.',
        );

        final clipPx = painter.width - viewportWidth;

        // MEASURED 2026-07-31 (real Inter-Bold metrics, `setUpAll` above):
        // at 320px, track=102.24px, "987,654.32" wants 178.69px, viewport
        // gets 157.76px - a ~20.9px clip (roughly one tabular digit). At
        // 290px, viewport gets 127.76px - a ~50.9px clip (roughly two to
        // three digits).
        //
        // This is a KNOWN, OPEN, RECORDED cost of sketch 170 scheme B, not
        // a bug this task fixes: the wider two-segment track leaves less
        // room for the number than the old single-label toggle did, and a
        // realistic large minions balance clips at the REALISTIC 320px
        // panel width, not just the 290px stress case. Sketch 170 already
        // names scheme A (a ~18px swap glyph) as the fallback if this cost
        // is rejected - see
        // `.planning/todos/pending/2026-07-31-balance-unit-track-clips-a-large-minions-balance-at-320px.md`
        // for the full numbers and the two options. The choice between
        // accepting this clip and falling back to scheme A is Jakub's, not
        // this executor's - so this assertion RECORDS the clip rather than
        // asserting it away: it stays green exactly as long as the clip
        // stays present at roughly its measured size. Do NOT "fix" a
        // failure here by narrowing the track's padding, relabeling `MIN`,
        // or changing the number's style - any of those would resolve the
        // assertion by hiding the finding rather than by a decision. If
        // this assertion ever fails because the clip shrank or vanished,
        // that is worth celebrating - update the numbers above, resolve
        // the todo, and only then loosen or delete this bound.
        final expectedClipRange = width == _kRealisticPanelWidth
            ? const [15.0, 30.0]
            : const [40.0, 60.0];
        expect(
          clipPx,
          allOf(
            greaterThanOrEqualTo(expectedClipRange[0]),
            lessThanOrEqualTo(expectedClipRange[1]),
          ),
          reason:
              'At ${width}px, the rendered minions balance '
              '"$renderedText" wants ${painter.width}px but the viewport '
              'only got ${viewportWidth}px (track measured '
              '${trackWidth}px) - clipPx=$clipPx, expected in '
              '$expectedClipRange based on the 2026-07-31 measurement. A '
              'value outside this range means the real cost changed - '
              'update the recorded numbers and the todo, do not just '
              'widen the range.',
        );
      });
    }
  });
}
