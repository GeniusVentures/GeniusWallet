import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/theme/theme.dart';

/// WCAG relative-luminance contrast ratio. Uses [Color.computeLuminance],
/// Flutter's built-in WCAG-relative-luminance implementation, so this is
/// just the standard (L1+0.05)/(L2+0.05) formula, no reimplementation of the
/// luminance math itself. Mirrors test/theme/nav_chip_style_test.dart's
/// helper -- do not add a second implementation.
double contrastRatio(Color a, Color b) {
  final la = a.computeLuminance();
  final lb = b.computeLuminance();
  final lighter = la > lb ? la : lb;
  final darker = la > lb ? lb : la;
  return (lighter + 0.05) / (darker + 0.05);
}

/// Builds [getThemeData]'s output for [mode], restoring dark (the
/// module-level default) afterward so no other test file inherits a flipped
/// appearance.
ThemeData themeFor(GWAppearanceMode mode) {
  GWAppearance.instance.value = mode;
  addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);
  return getThemeData();
}

void main() {
  group('Part 2: foreground-on-brand-fill pairings clear 4.5:1 (both modes)', () {
    for (final mode in GWAppearanceMode.values) {
      test('checkbox checkColor(selected) vs fillColor(selected) -- $mode', () {
        final theme = themeFor(mode);
        final fg = theme.checkboxTheme.checkColor?.resolve({
          WidgetState.selected,
        });
        final bg = theme.checkboxTheme.fillColor?.resolve({
          WidgetState.selected,
        });
        expect(fg, isNotNull);
        expect(bg, isNotNull);
        expect(
          contrastRatio(fg!, bg!),
          greaterThanOrEqualTo(4.5),
          reason:
              'checkbox checkColor(selected)=$fg vs '
              'fillColor(selected)=$bg in $mode mode',
        );
      });

      test(
        'datePicker headerForegroundColor vs headerBackgroundColor -- $mode',
        () {
          final theme = themeFor(mode);
          final fg = theme.datePickerTheme.headerForegroundColor;
          final bg = theme.datePickerTheme.headerBackgroundColor;
          expect(fg, isNotNull);
          expect(bg, isNotNull);
          expect(
            contrastRatio(fg!, bg!),
            greaterThanOrEqualTo(4.5),
            reason:
                'datePicker headerForegroundColor=$fg vs '
                'headerBackgroundColor=$bg in $mode mode',
          );
        },
      );

      test(
        'datePicker dayForegroundColor(selected) vs dayBackgroundColor(selected) -- $mode',
        () {
          final theme = themeFor(mode);
          final fg = theme.datePickerTheme.dayForegroundColor?.resolve({
            WidgetState.selected,
          });
          final bg = theme.datePickerTheme.dayBackgroundColor?.resolve({
            WidgetState.selected,
          });
          expect(fg, isNotNull);
          expect(bg, isNotNull);
          expect(
            contrastRatio(fg!, bg!),
            greaterThanOrEqualTo(4.5),
            reason:
                'datePicker dayForegroundColor(selected)=$fg vs '
                'dayBackgroundColor(selected)=$bg in $mode mode',
          );
        },
      );
    }
  });

  group(
    'Part 3: focus/selection states clear 4.5:1 on every light surface (both modes)',
    () {
      for (final mode in GWAppearanceMode.values) {
        test(
          'identity: five properties equal brandPrimaryOnSurface -- $mode',
          () {
            final theme = themeFor(mode);
            final token = GeniusWalletColors.brandPrimaryOnSurface;

            final inputFocus =
                (theme.inputDecorationTheme.focusedBorder!
                        as OutlineInputBorder)
                    .borderSide
                    .color;
            final dropdownFocus =
                (theme.dropdownMenuTheme.inputDecorationTheme!.focusedBorder!
                        as OutlineInputBorder)
                    .borderSide
                    .color;
            final tabIndicator = theme.tabBarTheme.indicatorColor;
            final checkboxSide = theme.checkboxTheme.side?.color;
            final progressColor = theme.progressIndicatorTheme.color;

            expect(
              inputFocus,
              token,
              reason: 'inputDecorationTheme focusedBorder ($mode)',
            );
            expect(
              dropdownFocus,
              token,
              reason: 'dropdownMenu focusedBorder ($mode)',
            );
            expect(
              tabIndicator,
              token,
              reason: 'tabBarTheme.indicatorColor ($mode)',
            );
            expect(checkboxSide, token, reason: 'checkboxTheme.side ($mode)');
            expect(
              progressColor,
              token,
              reason: 'progressIndicatorTheme.color ($mode)',
            );
          },
        );

        test(
          'five properties clear 4.5:1 on surfaceElevated/surfaceMenu/surfaceBase -- $mode',
          () {
            final theme = themeFor(mode);
            final surfaceElevated = GeniusWalletColors.surfaceElevated;
            final surfaceMenu = GeniusWalletColors.surfaceMenu;
            final surfaceBase = GeniusWalletColors.surfaceBase;

            final inputFocus =
                (theme.inputDecorationTheme.focusedBorder!
                        as OutlineInputBorder)
                    .borderSide
                    .color;
            final dropdownFocus =
                (theme.dropdownMenuTheme.inputDecorationTheme!.focusedBorder!
                        as OutlineInputBorder)
                    .borderSide
                    .color;
            final tabIndicator = theme.tabBarTheme.indicatorColor!;
            final checkboxSide = theme.checkboxTheme.side!.color;
            final progressColor = theme.progressIndicatorTheme.color!;

            final props = <String, Color>{
              'inputDecorationTheme focusedBorder': inputFocus,
              'dropdownMenu focusedBorder': dropdownFocus,
              'tabBarTheme.indicatorColor': tabIndicator,
              'checkboxTheme.side': checkboxSide,
              'progressIndicatorTheme.color': progressColor,
            };
            final surfaces = <String, Color>{
              'surfaceElevated': surfaceElevated,
              'surfaceMenu': surfaceMenu,
              'surfaceBase': surfaceBase,
            };

            for (final propEntry in props.entries) {
              for (final surfaceEntry in surfaces.entries) {
                expect(
                  contrastRatio(propEntry.value, surfaceEntry.value),
                  greaterThanOrEqualTo(4.5),
                  reason:
                      '${propEntry.key}=${propEntry.value} vs '
                      '${surfaceEntry.key}=${surfaceEntry.value} in $mode mode',
                );
              }
            }
          },
        );
      }
    },
  );

  group('Part 3: GWButton secondary foreground + border equal the token', () {
    for (final mode in GWAppearanceMode.values) {
      testWidgets('secondary variant -- $mode', (tester) async {
        GWAppearance.instance.value = mode;
        addTearDown(() => GWAppearance.instance.value = GWAppearanceMode.dark);

        await tester.pumpWidget(
          MaterialApp(
            theme: getThemeData(),
            home: Scaffold(
              body: GWButton(
                label: 'Secondary',
                variant: GWButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ),
        );

        final token = GeniusWalletColors.brandPrimaryOnSurface;

        final textWidget = tester.widget<Text>(find.text('Secondary'));
        expect(
          textWidget.style?.color,
          token,
          reason: 'GWButton secondary label color ($mode)',
        );

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.border?.top.color,
          token,
          reason: 'GWButton secondary border color ($mode)',
        );
      });
    }
  });

  // Sketch 156-A "Card canvas". The drawer panel moved to `surfaceElevated`,
  // which puts it 1.11:1 from an input's own fill -- so the field's EDGE is the
  // only thing left saying "this is a control", and WCAG 1.4.11 asks it for 3:1
  // by itself.
  //
  // This measures the panel the drawer ACTUALLY paints rather than the token we
  // believe it uses, so it fails in BOTH directions the reasoning can rot: the
  // alpha on `borderControl` drifting, or the shell being repainted back to
  // `surfaceMenu` (which would silently return the field to a 1.36:1 hairline
  // on a canvas 1.00:1 from its own fill).
  group('Part 4: the drawer input edge carries 1.4.11 alone (156-A)', () {
    for (final mode in GWAppearanceMode.values) {
      testWidgets('borderControl vs the painted drawer panel -- $mode', (
        tester,
      ) async {
        final theme = themeFor(mode);
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: Builder(
                builder: (context) => ElevatedButton(
                  onPressed: () => ResponsiveDrawer.show<void>(
                    context: context,
                    title: 'Swap Settings',
                    child: const SizedBox.expand(),
                  ),
                  child: const Text('open'),
                ),
              ),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();

        // Only the drawer has an AppBar, so this picks its Scaffold and not the
        // host page's.
        final panel = tester
            .widget<Scaffold>(
              find.ancestor(
                of: find.byType(AppBar),
                matching: find.byType(Scaffold),
              ),
            )
            .backgroundColor;
        expect(panel, isNotNull);

        // IDENTITY, not just contrast. The contrast assertion below does NOT
        // catch a panel repainted back to `surfaceMenu`: white 36% measures
        // 3.30:1 on #0C0E14 and 3.33:1 on #171A21, so it passes on both. That
        // was claimed as a safety net in quick 260728-q7c's summary and it was
        // wrong. This line is the net.
        expect(
          panel,
          theme.extension<GWColors>()!.surfaceElevated,
          reason: '156-A: the drawer panel is the card colour',
        );

        // borderControl is translucent, so it has to be composited before it
        // has a luminance -- computeLuminance() ignores alpha.
        final edge = Color.alphaBlend(GeniusWalletColors.borderControl, panel!);
        expect(
          contrastRatio(edge, panel),
          greaterThanOrEqualTo(3.0),
          reason:
              'field edge $edge on drawer panel $panel in $mode mode -- an '
              'input whose fill is 1.11:1 from its panel is identified by its '
              'border alone',
        );
      });
    }
  });
}
