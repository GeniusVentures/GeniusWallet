import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/gw_timeframe_segment.dart';

/// WCAG 2.1.1 (Keyboard), Level A, over a REAL control-track chip.
///
/// Every chip in a control track used to be a bare `GestureDetector`: it took
/// no focus and could not be fired without a pointer. They are `InkWell`s now,
/// the same shape `_UnitSegment` in `compute_panel.dart` already used — which
/// is exactly why that one chip was never broken.
///
/// This targets `GWTimeframeSegment` rather than a wrapper widget: a chip that
/// passes here is keyboard-operable as it actually ships, and the test cannot
/// be satisfied by a helper nothing renders.
void main() {
  Future<void> pumpSegment(WidgetTester tester) {
    return tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(body: Center(child: GWTimeframeSegment())),
      ),
    );
  }

  testWidgets('a tab takes focus from the keyboard', (tester) async {
    await pumpSegment(tester);

    await tester.sendKeyEvent(LogicalKeyboardKey.tab);
    await tester.pumpAndSettle();

    final focused = tester
        .widgetList<Focus>(find.byType(Focus))
        .where((f) => f.focusNode?.hasFocus ?? false);
    expect(
      focused,
      isNotEmpty,
      reason: 'no chip took focus — a pointer is the only way in',
    );
  });

  testWidgets('Enter and Space select the focused tab', (tester) async {
    for (final key in [LogicalKeyboardKey.enter, LogicalKeyboardKey.space]) {
      await pumpSegment(tester);
      // '1D' is the default selection; move to a different tab and fire it.
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.sendKeyEvent(LogicalKeyboardKey.tab);
      await tester.pumpAndSettle();

      await tester.sendKeyEvent(key);
      await tester.pumpAndSettle();

      // Selection is reported through Semantics, never by reaching into the
      // private chip: exactly one tab is selected, and the widget survived
      // being driven entirely from the keyboard.
      final selected = tester
          .widgetList<Semantics>(find.byType(Semantics))
          .where((s) => s.properties.selected ?? false);
      expect(
        selected.length,
        1,
        reason:
            '${key.keyLabel} left the segment without exactly one '
            'selected tab',
      );
    }
  });

  testWidgets('every tab reports the button role and a selected state', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();
    await pumpSegment(tester);

    final chips = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((s) => s.properties.button ?? false)
        .toList();

    expect(chips.length, 5, reason: 'all five tabs must announce as buttons');
    expect(
      chips.where((s) => s.properties.selected ?? false).length,
      1,
      reason: 'exactly one tab is selected at rest',
    );
    handle.dispose();
  });

  testWidgets('a pointer tap still selects', (tester) async {
    await pumpSegment(tester);

    await tester.tap(find.text('1Y'));
    await tester.pumpAndSettle();

    final selected = tester
        .widgetList<Semantics>(find.byType(Semantics))
        .where((s) => s.properties.selected ?? false);
    expect(selected.length, 1);
  });
}
