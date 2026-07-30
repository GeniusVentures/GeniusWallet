import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/effects/gw_hoverable.dart';

/// `GWHoverable` is the shared hover-plumbing widget thirteen call sites
/// hand-rolled independently before 23-05 (see `23-05-EXTRACTION-AUDIT.md`).
/// Its whole value is the CONTRACT a visual baseline could not check anyway:
/// the builder receives the right flag at the right time, the pointer region
/// covers exactly the child it wraps (not more, not less), the cursor it
/// reports is the one the caller asked for, and a redundant enter event does
/// not cost an extra build. This file goes red if any of those four silently
/// regresses -- a picture would show none of them.
const _childKey = Key('gw_hoverable_child');

/// `MaterialApp`/`Scaffold` add their own `MouseRegion`s (cursor tracking for
/// the app's own scaffolding), so a bare `find.byType(MouseRegion)` is
/// ambiguous. Scoped to the one `GWHoverable` actually builds.
final _hoverableRegion = find.descendant(
  of: find.byType(GWHoverable),
  matching: find.byType(MouseRegion),
);

Widget _host({
  required ValueChanged<bool> onBuild,
  MouseCursor cursor = SystemMouseCursors.click,
}) => MaterialApp(
  home: Scaffold(
    body: Center(
      child: GWHoverable(
        cursor: cursor,
        builder: (hovered) {
          onBuild(hovered);
          return const SizedBox(key: _childKey, width: 120, height: 40);
        },
      ),
    ),
  ),
);

void main() {
  testWidgets('rest, enter and exit pass the right flag to the builder', (
    tester,
  ) async {
    var lastHovered = false;
    await tester.pumpWidget(_host(onBuild: (h) => lastHovered = h));

    // Rest: false before any pointer has touched it.
    expect(lastHovered, isFalse, reason: 'builder receives false at rest');

    final gesture = await tester.createGesture(kind: PointerDeviceKind.mouse);
    await gesture.addPointer(location: Offset.zero);
    addTearDown(gesture.removePointer);

    // Enter: a real synthetic mouse moving onto the child.
    await gesture.moveTo(tester.getCenter(find.byKey(_childKey)));
    await tester.pump();
    expect(
      lastHovered,
      isTrue,
      reason: 'builder receives true once the pointer is over the child',
    );

    // Exit: the mouse moves away again.
    await gesture.moveTo(const Offset(-100, -100));
    await tester.pump();
    expect(
      lastHovered,
      isFalse,
      reason: 'builder receives false again once the pointer leaves',
    );

    expect(tester.takeException(), isNull);
  });

  testWidgets('cursor reaches the pointer region, defaulting to click', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onBuild: (_) {}));
    final region = tester.widget<MouseRegion>(_hoverableRegion);
    expect(
      region.cursor,
      SystemMouseCursors.click,
      reason:
          'most existing call sites set the click cursor explicitly; this is '
          'the default this migration must not silently change',
    );

    await tester.pumpWidget(
      _host(onBuild: (_) {}, cursor: SystemMouseCursors.text),
    );
    final customRegion = tester.widget<MouseRegion>(_hoverableRegion);
    expect(
      customRegion.cursor,
      SystemMouseCursors.text,
      reason: 'a caller-supplied cursor must reach the region unchanged',
    );
  });

  testWidgets('the hit area matches the child\'s own rect exactly', (
    tester,
  ) async {
    await tester.pumpWidget(_host(onBuild: (_) {}));

    final regionRect = tester.getRect(_hoverableRegion);
    final childRect = tester.getRect(find.byKey(_childKey));

    expect(
      regionRect,
      childRect,
      reason:
          'the pointer region must cover exactly the area the child paints -- '
          'a future wrapper that shrinks or inflates the hover target should '
          'fail here, not in a live walk',
    );
  });

  testWidgets('a redundant enter does not cost an extra build', (tester) async {
    var buildCount = 0;
    await tester.pumpWidget(_host(onBuild: (_) => buildCount++));
    expect(buildCount, 1, reason: 'the initial build');

    final region = tester.widget<MouseRegion>(_hoverableRegion);

    // A genuine transition: false -> true costs one build.
    region.onEnter!(const PointerEnterEvent());
    await tester.pump();
    expect(buildCount, 2, reason: 'the real hover transition rebuilds once');

    // A REDUNDANT enter while already hovered: the no-op guard means this
    // must cost nothing.
    region.onEnter!(const PointerEnterEvent());
    await tester.pump();
    expect(
      buildCount,
      2,
      reason:
          'a second enter with no state change must not trigger another build',
    );

    // Symmetrical check on the exit side.
    region.onExit!(const PointerExitEvent());
    await tester.pump();
    expect(buildCount, 3, reason: 'the real exit transition rebuilds once');

    region.onExit!(const PointerExitEvent());
    await tester.pump();
    expect(buildCount, 3, reason: 'a redundant exit must not rebuild again');

    expect(tester.takeException(), isNull);
  });
}
