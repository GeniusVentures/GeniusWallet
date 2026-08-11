import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_api/models/transaction.dart';
import 'package:genius_wallet/banxa/banxa_components/order_status_style.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/feedback/gw_warning_note.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/components/toast/toast_widget.dart';
import 'package:genius_wallet/dashboard/home/widgets/transaction_displays.dart';
import 'package:genius_wallet/squid_router/swap_settings_drawer.dart';
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

/// `orderStatusPaint` names its fill `bg`; `txStatusColors` names it `wash`.
/// Normalised here so both can go through the same assertion loop.
({Color fg, Color wash}) _asPair(({Color fg, Color bg}) p) =>
    (fg: p.fg, wash: p.bg);

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
            final token = theme.extension<GWColors>()!.brandPrimaryOnSurface;

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
            final gw = theme.extension<GWColors>()!;
            final surfaceElevated = gw.surfaceElevated;
            final surfaceMenu = gw.surfaceMenu;
            final surfaceBase = gw.surfaceBase;

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

        final theme = getThemeData();
        await tester.pumpWidget(
          MaterialApp(
            theme: theme,
            home: Scaffold(
              body: GWButton(
                label: 'Secondary',
                variant: GWButtonVariant.secondary,
                onPressed: () {},
              ),
            ),
          ),
        );

        final token = theme.extension<GWColors>()!.brandPrimaryOnSurface;

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
        final edge = Color.alphaBlend(
          theme.extension<GWColors>()!.borderControl,
          panel!,
        );
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

    // Mirrors ToastWidget's own `_accent` for the warning case.
    Color warningAccentFor(GWAppearanceMode mode, GWColors gw) =>
        gw.statusWarningText;

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

          // Was a SelectableText. Text selection inside a transient that is
          // gone in five seconds, and that is dismissed by dragging it, was
          // fighting the swipe — so the message is a plain Text now. The
          // contrast claim below is unchanged and is the point of this test.
          final message = tester.widget<Text>(find.text('Message'));
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

          final expectedAmber = theme.extension<GWColors>()!.statusWarningText;
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

  group('Part 7b: GWTextField hint and inline prefix on the field fill', () {
    // 260731-vty gave `GWTextField` a real inline `prefix` slot and styled it
    // from the component (`prefixStyle`), in the same `textSecondary` the
    // hint already used, on the same `surfaceElevated` default fill. The plan
    // for that task assumed this pairing was already inside Part 3's
    // "five properties clear 4.5:1 on surfaceElevated/..." sweep. IT IS NOT:
    // that sweep covers focus borders, tab indicators, checkbox sides and the
    // progress colour, all of which are CHROME, not text. This is the
    // assertion that closes the gap rather than a claim of coverage that was
    // not there.
    //
    // Threshold is 4.5:1, the BODY-text floor, even though the Buy GNUS hero
    // renders its `$` at 24px w600 and would qualify for the 3:1 large-text
    // floor. The slot's DEFAULT type step is `bodyLg` (16px), which is not
    // large text, so the general caller sets the requirement, not the one
    // caller that happens to be bigger.
    for (final mode in GWAppearanceMode.values) {
      test('textSecondary on surfaceElevated -- $mode', () {
        final gw = themeFor(mode).extension<GWColors>()!;
        expect(
          contrastRatio(gw.textSecondary, gw.surfaceElevated),
          greaterThanOrEqualTo(4.5),
          reason:
              'GWTextField hint/prefix ink ${gw.textSecondary} on its default '
              'fill ${gw.surfaceElevated} in $mode mode',
        );
      });
    }
  });

  group('Part 8: status-pill foregrounds on their own wash (23-03 follow-up)', () {
    // The two pill palettes are separate functions that must not drift --
    // order_status_style.dart says outright it was "copied verbatim from the
    // shipped _statusPill". Both go through one loop so a fix to one that
    // misses the other fails here.
    //
    // The wash is TRANSLUCENT and must be composited over the surface it sits
    // on before it has a luminance; computeLuminance() ignores alpha (same
    // reason as the borderControl handling above).
    //
    // Threshold is 4.5:1, not 3:1: the pill label is labelMd (13px) at w600,
    // and WCAG large text starts at 18.66px bold -- 13px bold does not
    // qualify, so the body-text ratio applies.
    const tones = ['success', 'warning', 'error'];

    ({Color fg, Color wash}) orderPair(String tone, GWColors gw) =>
        switch (tone) {
          'success' => _asPair(orderStatusPaint(OrderStatusTone.success, gw)),
          'warning' => _asPair(orderStatusPaint(OrderStatusTone.warning, gw)),
          _ => _asPair(orderStatusPaint(OrderStatusTone.error, gw)),
        };
    ({Color fg, Color wash}) txPair(String tone, GWColors gw) => switch (tone) {
      'success' => txStatusColors(TransactionStatus.completed, gw),
      'warning' => txStatusColors(TransactionStatus.pending, gw),
      _ => txStatusColors(TransactionStatus.failed, gw),
    };

    Map<String, Color> surfacesOf(GWColors gw) => {
      'surfaceElevated': gw.surfaceElevated,
      'surfaceMenu': gw.surfaceMenu,
      'surfaceBase': gw.surfaceBase,
    };

    // Dark mode: every tone already clears AA (measured min 4.54:1 on
    // surfaceMenu/error). Asserted so a token change cannot silently break it.
    test('every tone clears 4.5:1 in dark mode', () {
      final gw = themeFor(GWAppearanceMode.dark).extension<GWColors>()!;
      for (final tone in tones) {
        for (final pair in [orderPair(tone, gw), txPair(tone, gw)]) {
          for (final surface in surfacesOf(gw).entries) {
            expect(
              contrastRatio(
                pair.fg,
                Color.alphaBlend(pair.wash, surface.value),
              ),
              greaterThanOrEqualTo(4.5),
              reason: '$tone pill on ${surface.key} in dark mode',
            );
          }
        }
      }
    });

    // Light mode: ONLY the warning tone is asserted, because only the warning
    // tone has been fixed. It reads statusWarningText (#92400E) and measures
    // 6.56 / 5.93 / 5.15 on elevated / menu / base -- it was 1.47:1 (order)
    // and 1.59:1 (tx) when both painted the fill-tuned statusWarning.
    //
    // ponytail: success and error are NOT asserted in light mode because they
    // DO NOT PASS, and an assertion tuned down to let them through would be
    // the unearned PASS this project forbids. Measured 2026-07-29:
    //   success  3.77 / 3.39 / 2.91   (elevated / menu / base)
    //   error    3.89 / 3.49 / 2.99
    // All six are below the 4.5:1 body-text floor and the two surfaceBase
    // figures are below even the 3:1 non-text floor. This is PRE-EXISTING and
    // was not introduced by 23-03. Ceiling: the light-mode statusSuccess /
    // statusError values are already AA-divergent and still miss on a
    // translucent wash of their own colour. Upgrade path: statusSuccessText /
    // statusErrorText tokens mirroring statusWarningText, then extend this
    // group to all three tones in both modes and delete this note. See
    // .planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md
    test('warning tone clears 4.5:1 in light mode (was 1.47:1 / 1.59:1)', () {
      final gw = themeFor(GWAppearanceMode.light).extension<GWColors>()!;
      for (final pair in [orderPair('warning', gw), txPair('warning', gw)]) {
        for (final surface in surfacesOf(gw).entries) {
          expect(
            contrastRatio(pair.fg, Color.alphaBlend(pair.wash, surface.value)),
            greaterThanOrEqualTo(4.5),
            reason:
                'warning pill label ${pair.fg} on its wash composited over '
                '${surface.key} ${surface.value} in light mode',
          );
        }
      }
    });
  });
}
