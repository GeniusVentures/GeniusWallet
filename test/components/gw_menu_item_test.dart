// The one disabled/locked/destructive shape every row menu in the app
// shares - proven directly against GWMenuItem rather than through whichever
// screen happens to render it.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/overlays/gw_menu_item.dart';
import 'package:genius_wallet/theme/gw_colors.dart';

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

  testWidgets('disabled: icon and label dim to textSecondary at 50%, even a '
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
    final dimmed = gw.textSecondary.withValues(alpha: 0.5);
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
          label: 'Run node as this',
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
}
