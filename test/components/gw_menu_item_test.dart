// The one disabled/locked/destructive shape every row menu in the app
// shares - proven directly against GWMenuItem rather than through whichever
// screen happens to render it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/overlays/gw_menu_item.dart';
import 'package:genius_wallet/theme/gw_appearance.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

// Reuse the single existing WCAG ratio helper -- do not add a second
// implementation.
import '../theme/theme_contrast_test.dart' show contrastRatio, themeFor;

Widget _host(Widget item) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.light()]),
  home: Scaffold(body: Material(child: item)),
);

void main() {
  testWidgets('enabled: icon and label share textPrimary', (tester) async {
    final gw = GWColors.light();
    await tester.pumpWidget(
      _host(
        GWMenuItem(icon: Icons.copy, label: 'Copy address', onPressed: () {}),
      ),
    );

    final button = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
    expect(button.style?.foregroundColor?.resolve({}), gw.textPrimary);
    expect(find.byTooltip('Copy address'), findsNothing);
  });

  testWidgets('color overrides both icon and label, for a destructive item', (
    tester,
  ) async {
    final gw = GWColors.light();
    await tester.pumpWidget(
      _host(
        GWMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          onPressed: () {},
          color: gw.statusErrorText,
        ),
      ),
    );

    final button = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
    expect(button.style?.foregroundColor?.resolve({}), gw.statusErrorText);
  });

  testWidgets('disabled: icon and label dim to textSecondary at 70%, even a '
      'destructive one, and no tooltip appears', (tester) async {
    final gw = GWColors.light();
    await tester.pumpWidget(
      _host(
        GWMenuItem(
          icon: Icons.delete_outline,
          label: 'Delete',
          onPressed: null,
          color: gw.statusErrorText,
        ),
      ),
    );

    final button = tester.widget<MenuItemButton>(find.byType(MenuItemButton));
    final dimmed = gw.textSecondary.withValues(alpha: 0.7);
    expect(button.style?.foregroundColor?.resolve({}), dimmed);
    expect(
      button.style?.foregroundColor?.resolve({WidgetState.disabled}),
      dimmed,
    );
    expect(find.byType(Tooltip), findsNothing);
  });

  testWidgets('disabled with a lockedReason: the same dimming, inside a '
      'Tooltip carrying it', (tester) async {
    await tester.pumpWidget(
      _host(
        const GWMenuItem(
          icon: Icons.dns_outlined,
          label: 'Earn with this account',
          onPressed: null,
          lockedReason: 'Waiting for a child operation from Main to confirm',
        ),
      ),
    );

    expect(
      find.byTooltip('Waiting for a child operation from Main to confirm'),
      findsOneWidget,
    );
  });

  group('disabled foreground contrast', () {
    for (final mode in GWAppearanceMode.values) {
      test(
        'clears 3:1 on surfaceMenu and differs from textPrimary -- $mode',
        () {
          final gw = themeFor(mode).extension<GWColors>()!;
          // The exact composited colour GWMenuItem paints for a disabled item
          // -- textSecondary at 70%, alpha-blended over the surface it sits on.
          final disabledFg = gw.textSecondary.withValues(alpha: 0.7);
          final effective = Color.alphaBlend(disabledFg, gw.surfaceMenu);

          expect(
            contrastRatio(effective, gw.surfaceMenu),
            greaterThanOrEqualTo(3.0),
            reason:
                'GWMenuItem disabled foreground $effective on surfaceMenu '
                '${gw.surfaceMenu} in $mode mode',
          );
          expect(
            effective,
            isNot(gw.textPrimary),
            reason:
                'disabled must read visibly different from an enabled '
                'item, not merely "still technically legible"',
          );
        },
      );
    }
  });
}
