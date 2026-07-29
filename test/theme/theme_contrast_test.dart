import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_widget.dart';
import 'package:genius_wallet/squid_router/swap_settings_drawer.dart';
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

  // 23-03: the toast widget used to hardcode a fully inverted light-mode
  // palette (Colors.green.shade50-style literals, always painted regardless
  // of appearance). Re-derived from context.gw; this group is the
  // replacement evidence -- see 23-03-CONTRAST.md for the by-hand ratios.
  group('Part 5: ToastWidget clears AA in both appearances (23-03)', () {
    IconData iconFor(ToastType type) => switch (type) {
      ToastType.success => Icons.check_circle_outline_outlined,
      ToastType.error => Icons.error_outline_outlined,
      ToastType.warning => Icons.warning_amber_outlined,
    };

    // Mirrors ToastWidget's own private `_warningAccent` -- the fourth
    // occurrence of the documented light-mode amber workaround (see the
    // widget's own ponytail note).
    Color warningAccentFor(GWAppearanceMode mode, GWColors gw) =>
        mode == GWAppearanceMode.light
        ? const Color(0xFF92400E)
        : gw.statusWarning;

    for (final mode in GWAppearanceMode.values) {
      for (final type in ToastType.values) {
        testWidgets('${type.name} toast -- $mode', (tester) async {
          final theme = themeFor(mode);
          final gw = theme.extension<GWColors>()!;
          final accent = switch (type) {
            ToastType.success => gw.statusSuccess,
            ToastType.error => gw.statusError,
            ToastType.warning => warningAccentFor(mode, gw),
          };

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: ToastWidget(
                  title: 'Title',
                  message: 'Message',
                  type: type,
                  onDismiss: () {},
                ),
              ),
            ),
          );

          final card = tester
              .widgetList<Container>(find.byType(Container))
              .firstWhere((c) => c.decoration != null);
          final decoration = card.decoration as BoxDecoration;
          final surface = decoration.color;
          expect(
            surface,
            gw.surfaceElevated,
            reason: 'toast card surface ($mode)',
          );

          final icon = tester.widget<Icon>(find.byIcon(iconFor(type)));
          expect(icon.color, accent, reason: '${type.name} accent ($mode)');
          expect(
            contrastRatio(icon.color!, surface!),
            greaterThanOrEqualTo(3.0),
            reason:
                '${type.name} icon $accent on toast surface $surface '
                'in $mode mode (non-text UI, 3:1 floor)',
          );

          final title = tester.widget<Text>(find.text('Title'));
          expect(
            title.style?.color,
            gw.textPrimary,
            reason: 'toast title colour ($mode)',
          );
          expect(
            contrastRatio(title.style!.color!, surface),
            greaterThanOrEqualTo(4.5),
            reason: 'toast title on surface $surface in $mode mode',
          );

          final message = tester.widget<SelectableText>(
            find.byType(SelectableText),
          );
          expect(
            message.style?.color,
            gw.textSecondary,
            reason: 'toast message colour ($mode)',
          );
          expect(
            contrastRatio(message.style!.color!, surface),
            greaterThanOrEqualTo(4.5),
            reason: 'toast message on surface $surface in $mode mode',
          );
        });
      }
    }
  });

  // 23-03: gw_button.dart's design-system offenders -- primary/gradient's
  // on-brand text and the destructive fill/foreground pairing this plan
  // replaced (was 3.27:1 / 3.86:1, both below 4.5:1 -- see
  // 23-03-CONTRAST.md).
  group('Part 6: GWButton primary + destructive clear AA (23-03)', () {
    for (final mode in GWAppearanceMode.values) {
      testWidgets('primary variant label vs brand CTA gradient -- $mode', (
        tester,
      ) async {
        final theme = themeFor(mode);
        final gw = theme.extension<GWColors>()!;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: GWButton(
                label: 'Primary',
                variant: GWButtonVariant.primary,
                onPressed: () {},
              ),
            ),
          ),
        );

        final textWidget = tester.widget<Text>(find.text('Primary'));
        expect(
          textWidget.style?.color,
          gw.textOnBrand,
          reason: 'GWButton primary label color ($mode)',
        );

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        final gradient = decoration.gradient! as LinearGradient;
        for (final stop in gradient.colors) {
          expect(
            contrastRatio(textWidget.style!.color!, stop),
            greaterThanOrEqualTo(4.5),
            reason:
                'GWButton primary label ${textWidget.style!.color} on '
                'gradient stop $stop ($mode) -- fixed in both modes',
          );
        }
      });

      testWidgets('destructive variant fill + label clear AA -- $mode', (
        tester,
      ) async {
        final theme = themeFor(mode);
        final gw = theme.extension<GWColors>()!;

        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: GWButton(
                label: 'Delete',
                variant: GWButtonVariant.destructive,
                onPressed: () {},
              ),
            ),
          ),
        );

        final container = tester.widget<AnimatedContainer>(
          find.byType(AnimatedContainer),
        );
        final decoration = container.decoration as BoxDecoration;
        expect(
          decoration.color,
          gw.foundationError,
          reason: 'GWButton destructive fill ($mode)',
        );

        final textWidget = tester.widget<Text>(find.text('Delete'));
        expect(
          textWidget.style?.color,
          Colors.white,
          reason:
              'GWButton destructive label is a documented fixed exception '
              '($mode) -- gw.foundationError does not flip, so the label '
              'must not follow gw.textPrimary either',
        );
        expect(
          contrastRatio(textWidget.style!.color!, decoration.color!),
          greaterThanOrEqualTo(4.5),
          reason:
              'GWButton destructive label on ${decoration.color} in $mode '
              'mode -- was 3.27:1 (dark) / 3.86:1 (light) against '
              'gw.statusError before this plan',
        );
      });
    }
  });

  // 23-03: swap_settings_drawer.dart's private `_Message` fork re-derived the
  // warning tone from raw `statusWarning` (~1.59:1 on light's white
  // surfaceElevated -- effectively invisible) instead of reusing
  // GWWarningNote's documented light-mode amber fix. This end-to-end test
  // drives the real drawer and asserts the warning path now renders a
  // GWWarningNote with the fixed amber icon.
  group(
    'Part 7: swap_settings_drawer warning uses GWWarningNote\'s amber fix (23-03)',
    () {
      for (final mode in GWAppearanceMode.values) {
        testWidgets('high slippage warning -- $mode', (tester) async {
          final theme = themeFor(mode);

          await tester.pumpWidget(
            MaterialApp(
              theme: theme,
              home: Scaffold(
                body: Builder(
                  builder: (context) => ElevatedButton(
                    onPressed: () => SwapSettingsDrawer.show(
                      context,
                      // Above kSlippageWarnAbove (5.0) -- triggers the "High"
                      // warning message on open, no typing needed.
                      initialSlippage: 10.0,
                      onSlippageChanged: (_) {},
                    ),
                    child: const Text('open'),
                  ),
                ),
              ),
            ),
          );
          await tester.tap(find.text('open'));
          await tester.pumpAndSettle();

          expect(
            find.byType(GWWarningNote),
            findsOneWidget,
            reason:
                'the private _Message fork is gone; the warning tone must '
                'render the shared GWWarningNote ($mode)',
          );

          final expectedAmber = mode == GWAppearanceMode.light
              ? const Color(0xFF92400E)
              : theme.extension<GWColors>()!.statusWarning;
          final icon = tester.widget<Icon>(
            find.descendant(
              of: find.byType(GWWarningNote),
              matching: find.byIcon(Icons.warning_amber_rounded),
            ),
          );
          expect(
            icon.color,
            expectedAmber,
            reason: 'GWWarningNote icon colour ($mode)',
          );

          final panel = tester
              .widget<Scaffold>(
                find.ancestor(
                  of: find.byType(AppBar),
                  matching: find.byType(Scaffold),
                ),
              )
              .backgroundColor!;
          expect(
            contrastRatio(icon.color!, panel),
            greaterThanOrEqualTo(3.0),
            reason:
                'GWWarningNote icon $expectedAmber on drawer panel $panel '
                'in $mode mode -- was 1.59:1 before this fix in light mode',
          );
        });
      }
    },
  );
}
