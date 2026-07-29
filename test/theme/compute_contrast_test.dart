import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/data/gw_status_dot.dart';
import 'package:genius_wallet/dashboard/compute/compute_panel.dart';
import 'package:genius_wallet/dashboard/compute/compute_state.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/genius_wallet_decorations.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper rather than adding a third
// implementation (`theme_contrast_test.dart`'s own doc comment: "do not add
// a second implementation" - `transaction_filter_rail_test.dart` follows the
// same import shape).
import 'theme_contrast_test.dart' show contrastRatio, themeFor;

/// Proves `ComputePanel`'s contrast in both appearance modes, without
/// golden/pixel tooling: every colour it draws is either read straight off
/// [GWColors]/[GeniusWalletColors] (the text/link foregrounds - identical to
/// what `14-UI-SPEC.md §5.1` already measured, re-verified here rather than
/// quoted) or pulled off the REAL rendered widgets (`GWStatusDot.color`, the
/// bar's fill gradient) so a drift in `compute_panel.dart`'s own dot/bar
/// mapping is what actually fails this file, not a hand-copied second
/// mapping that could silently disagree with it.
ComputeStatusView _viewFor(ComputeState state) {
  return viewForComputeState(
    state,
    initStatusMessage: state == ComputeState.startingUp
        ? 'Preparing the compute node'
        : null,
    initPercentage: state == ComputeState.startingUp ? 0.6 : null,
    processingPercentage: state == ComputeState.processing ? 52.5 : null,
  );
}

Future<void> _pumpPanel(
  WidgetTester tester,
  GWAppearanceMode mode,
  ComputeState state,
) {
  final theme = themeFor(mode);
  return tester.pumpWidget(
    MaterialApp(
      theme: theme,
      home: Scaffold(
        body: SizedBox(
          width: 320,
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
  );
}

void main() {
  group('Text foregrounds clear 4.5:1 against both card surfaces', () {
    for (final mode in GWAppearanceMode.values) {
      test('textPrimary, textSecondary, brandPrimaryOnSurface -- $mode', () {
        final theme = themeFor(mode);
        final gw = theme.extension<GWColors>()!;

        // The dark card is flat (both gradient stops identical); the light
        // card is a gradient whose BOTTOM stop is the worst case for a dark
        // foreground (`14-UI-SPEC.md §5`). `.colors.last` reads that stop
        // straight off `GWDecorations.surfaceSheen` rather than
        // hand-duplicating the hex values `genius_wallet_decorations.dart`
        // already owns.
        final cardSurface = GWDecorations.surfaceSheen.colors.last;

        final foregrounds = <String, Color>{
          'gw.textPrimary (status labels, trailing values, the balance '
                  'number, the no-wallet placeholder)':
              gw.textPrimary,
          'gw.textSecondary (every sub-line)': gw.textSecondary,
          'brandPrimaryOnSurface (inline links)':
              GeniusWalletColors.brandPrimaryOnSurface,
        };

        for (final entry in foregrounds.entries) {
          expect(
            contrastRatio(entry.value, cardSurface),
            greaterThanOrEqualTo(4.5),
            reason:
                '${entry.key} = ${entry.value} vs card surface '
                '$cardSurface in $mode mode',
          );
        }
      });
    }
  });

  group('Every status dot clears 3:1 against the tile fill', () {
    for (final mode in GWAppearanceMode.values) {
      for (final state in ComputeState.values) {
        testWidgets('${state.name} dot -- $mode', (tester) async {
          await _pumpPanel(tester, mode, state);
          await tester.pump();

          final gw = themeFor(mode).extension<GWColors>()!;
          final dot = tester.widget<GWStatusDot>(find.byType(GWStatusDot));

          expect(
            contrastRatio(dot.color, gw.surfaceSunken),
            greaterThanOrEqualTo(3.0),
            reason:
                '${state.name} dot colour ${dot.color} vs tile fill '
                '${gw.surfaceSunken} in $mode mode',
          );
        });
      }
    }
  });

  group('The bar fill clears 3:1 against its track', () {
    // showBar is only true for startingUp and processing
    // (`compute_state.dart`'s viewForComputeState) - the other six states
    // have no bar to assert against.
    const barStates = [ComputeState.startingUp, ComputeState.processing];

    for (final mode in GWAppearanceMode.values) {
      for (final state in barStates) {
        testWidgets('${state.name} bar fill -- $mode', (tester) async {
          await _pumpPanel(tester, mode, state);
          await tester.pump();

          final gw = themeFor(mode).extension<GWColors>()!;

          final fillBox = tester.widget<DecoratedBox>(
            find.byKey(const ValueKey('computeBarFill')),
          );
          final decoration = fillBox.decoration as BoxDecoration;
          final gradient = decoration.gradient!;

          for (final stop in gradient.colors) {
            expect(
              contrastRatio(stop, gw.surfaceSunken),
              greaterThanOrEqualTo(3.0),
              reason:
                  '${state.name} bar fill stop $stop vs track '
                  '${gw.surfaceSunken} in $mode mode - the light-mode '
                  'degrade in genius_wallet_gradient.dart:44-51 is what '
                  'this assertion actually gates.',
            );
          }
        });
      }
    }
  });

  group(
    'No status label is drawn in a status hue - a rule, not a measurement',
    () {
      for (final mode in GWAppearanceMode.values) {
        for (final state in ComputeState.values) {
          testWidgets(
            '${state.name} label uses textPrimary, not the dot hue -- $mode',
            (tester) async {
              await _pumpPanel(tester, mode, state);
              await tester.pump();

              final dot = tester.widget<GWStatusDot>(find.byType(GWStatusDot));

              // GWStatusDot renders `labelColor ?? gw.textPrimary` and this
              // panel passes no `labelColor` at all
              // (`lib/dashboard/compute/compute_panel.dart`'s `_ComputeTile`) -
              // asserting the parameter itself is null is the API-level proof
              // that no per-state label ever adopts the dot's hue, which is
              // what makes per-state label contrast math unnecessary
              // (`14-UI-SPEC.md §2.2`). One sketch's markup disagrees with its
              // own written finding and colours labels per status - a
              // treatment measuring ~1.6:1 in light mode. The written finding
              // wins; this assertion is what stops that markup's version from
              // creeping back in.
              expect(
                dot.labelColor,
                isNull,
                reason:
                    '${state.name} passed a labelColor to GWStatusDot in '
                    '$mode mode - only the dot itself may carry hue.',
              );
            },
          );
        }
      }
    },
  );
}
