import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/image_utils.dart';

Widget _host(Widget child) => MaterialApp(
  theme: ThemeData(extensions: [GWColors.dark()]),
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('missing path shows the label letters', (tester) async {
    await tester.pumpWidget(
      _host(const TokenIcon(iconPath: null, size: 32, label: 'crv')),
    );
    expect(find.text('CR'), findsOneWidget);
  });

  testWidgets('a path that fails to load falls back to the letters', (
    tester,
  ) async {
    await tester.pumpWidget(
      _host(
        const TokenIcon(
          iconPath: 'assets/does_not_exist.png',
          size: 32,
          label: 'usdfi',
        ),
      ),
    );
    await tester.pump();
    await tester.pump();
    expect(find.text('US'), findsOneWidget);
  });
}
