import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/effects/gw_activatable.dart';

/// The check owed by `GWActivatable`: WCAG 2.1.1 (Keyboard), Level A.
///
/// A mouse-only chip passes every visual review and is still unusable without
/// a pointer, so the thing worth pinning is not how it paints but that a
/// keyboard can reach it and fire it.
void main() {
  Future<void> pump(WidgetTester tester, Widget child) {
    return tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: Center(child: child)),
      ),
    );
  }

  testWidgets('focus traversal reaches it, and Enter fires it', (tester) async {
    var taps = 0;
    await pump(
      tester,
      GWActivatable(onPressed: () => taps++, child: const Text('1D')),
    );

    // Tab moves focus onto the chip -- a bare GestureDetector never receives
    // it, which is the defect this widget exists to close.
    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    expect(
      Focus.of(tester.element(find.text('1D')), scopeOk: true).hasFocus,
      isTrue,
      reason: 'the chip never took focus, so a keyboard cannot reach it',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.enter);
    await tester.pumpAndSettle();
    expect(taps, 1, reason: 'Enter did not activate the focused chip');
  });

  testWidgets('Space fires it too', (tester) async {
    var taps = 0;
    await pump(
      tester,
      GWActivatable(onPressed: () => taps++, child: const Text('1W')),
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.space);
    await tester.pumpAndSettle();

    expect(taps, 1, reason: 'Space did not activate the focused chip');
  });

  testWidgets('reports the button role and its selected state', (tester) async {
    final handle = tester.ensureSemantics();
    await pump(
      tester,
      GWActivatable(
        onPressed: () {},
        label: 'Minions',
        selected: true,
        child: const Text('MIN'),
      ),
    );

    expect(
      tester.getSemantics(find.byType(GWActivatable)),
      matchesSemantics(
        isButton: true,
        isSelected: true,
        hasSelectedState: true,
        label: 'Minions',
        isFocusable: true,
        hasEnabledState: false,
        // The two that make it operable rather than merely labelled.
        hasTapAction: true,
        hasFocusAction: true,
      ),
    );
    handle.dispose();
  });

  testWidgets('a pointer tap still works', (tester) async {
    var taps = 0;
    await pump(
      tester,
      GWActivatable(onPressed: () => taps++, child: const Text('1M')),
    );

    await tester.tap(find.text('1M'));
    await tester.pumpAndSettle();
    expect(taps, 1);
  });
}
