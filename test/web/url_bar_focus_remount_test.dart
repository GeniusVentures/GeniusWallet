// Regression guard for the Web-tab omnibox bug of 2026-07-25: clicking the URL
// bar focused it but no key could be typed (every keystroke came back unhandled
// and macOS beeped) until the bar was blurred and re-focused.
//
// The cause was tree SHAPE, not text input. `Container` only inserts a
// `DecoratedBox` when its `decoration` is non-null, so a decoration toggled by
// focus changes the shape of the tree on focus. Flutter cannot match the old
// child against the new `DecoratedBox`, so it unmounts and rebuilds the whole
// subtree — disposing the freshly-focused `EditableText` one frame after it had
// consumed the focus node's single keyboard token. The replacement had focus
// but no text-input connection, and on macOS ALL text editing (arrow keys
// included) is routed through that connection.
//
// Scope: this pins the framework behaviour the fix relies on. It cannot pump
// `WebViewMobile` itself — that builds a `WebViewController` in `initState`,
// which needs a platform implementation no widget test has.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

class _Omnibox extends StatefulWidget {
  const _Omnibox({required this.toggleShape});

  /// true reproduces the bug (decoration flips null <-> non-null),
  /// false mirrors the shipped fix (decoration always present).
  final bool toggleShape;

  @override
  State<_Omnibox> createState() => _OmniboxState();
}

class _OmniboxState extends State<_Omnibox> {
  final FocusNode node = FocusNode();

  @override
  void initState() {
    super.initState();
    node.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    node.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool editing = node.hasFocus;
    return Container(
      decoration: widget.toggleShape
          ? (editing ? BoxDecoration(border: Border.all(width: 1.5)) : null)
          : BoxDecoration(
              border: Border.all(
                width: 1.5,
                color: editing ? const Color(0xFF00A6E7) : Colors.transparent,
              ),
            ),
      child: TextField(focusNode: node),
    );
  }
}

Future<bool> _fieldSurvivesFocus(
  WidgetTester tester, {
  required bool toggleShape,
}) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(body: _Omnibox(toggleShape: toggleShape)),
    ),
  );
  final EditableTextState before = tester.state<EditableTextState>(
    find.byType(EditableText),
  );
  tester.state<_OmniboxState>(find.byType(_Omnibox)).node.requestFocus();
  await tester.pump();
  await tester.pump();
  final EditableTextState after = tester.state<EditableTextState>(
    find.byType(EditableText),
  );
  return identical(before, after);
}

void main() {
  testWidgets('constant decoration keeps the field alive across focus', (
    WidgetTester tester,
  ) async {
    expect(
      await _fieldSurvivesFocus(tester, toggleShape: false),
      isTrue,
      reason:
          'Focusing must not replace the EditableText. If this fails, the '
          'omnibox decoration went back to being conditional and typing in the '
          'URL bar is dead again on the first click.',
    );
  });

  testWidgets('toggling decoration null <-> non-null remounts the field', (
    WidgetTester tester,
  ) async {
    expect(
      await _fieldSurvivesFocus(tester, toggleShape: true),
      isFalse,
      reason:
          'Pins the trap itself: a null decoration drops the DecoratedBox, '
          'so the subtree is rebuilt on focus. Kept as executable evidence '
          'because three earlier fix attempts blamed text input instead.',
    );
  });
}
