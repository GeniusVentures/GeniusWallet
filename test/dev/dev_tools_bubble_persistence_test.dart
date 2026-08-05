// Task 3 (2026-07-31): proves the dev panel's open state survives the exact
// lifecycle a route change (or the Mobile/Desktop overlay flip) puts it
// through - the element is disposed and a fresh one mounted later. Before
// this fix, `_expanded` etc. were plain `State` fields, so that disposal
// silently reset the panel to collapsed, which read to a walker as "it
// closes when I click next to it" even though there is no outside-tap
// dismissal anywhere in this file or `responsive_overlay.dart` (checked;
// see `dev_tools_bubble.dart`'s `DevToolsBubblePanelState` doc comment for
// the grep result, stated either way per the plan).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/dev/dev_tools_bubble.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

// Quick task 260731-gow: DevToolsBubble now requires a router (it derives an
// app-navigator context from it - see dev_tools_bubble.dart's
// _appNavigatorContext). A trivial standalone GoRouter is enough here: this
// harness never builds the router's own Navigator, so
// `navigatorKey.currentContext` stays null, which is exactly the case the
// `?? context` fallback exists for. The bubble only stores the router; this
// file's tests never exercise a NAVIGATE push or a drawer/toast action.
GoRouter _standaloneRouter() => GoRouter(
  routes: [
    GoRoute(path: '/', builder: (context, state) => const SizedBox.shrink()),
  ],
);

Widget _harness() {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    home: Scaffold(
      body: Stack(children: [DevToolsBubble(router: _standaloneRouter())]),
    ),
  );
}

Widget _harnessWithoutBubble() {
  return MaterialApp(
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    home: const Scaffold(body: SizedBox.shrink()),
  );
}

void main() {
  void resetPanelState() {
    // The singleton is process-wide, not per-widget - reset it before (and
    // after) each test so no test leaks its state into the next one.
    DevToolsBubblePanelState.instance.position = null;
    DevToolsBubblePanelState.instance.expanded = false;
  }

  setUp(resetPanelState);
  tearDown(resetPanelState);

  testWidgets(
    'expanding the panel, disposing the element, and remounting it keeps '
    'the panel expanded',
    (tester) async {
      await tester.pumpWidget(_harness());

      // Collapsed: the bug-report icon is the whole tappable bubble.
      expect(find.byIcon(Icons.bug_report), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);

      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      // Expanded: the panel's own X (close) button is now on screen.
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(DevToolsBubblePanelState.instance.expanded, isTrue);

      // Dispose the element - the exact thing a route change or the
      // Mobile/Desktop overlay flip does.
      await tester.pumpWidget(_harnessWithoutBubble());
      await tester.pumpAndSettle();
      expect(find.byIcon(Icons.close), findsNothing);
      expect(find.byIcon(Icons.bug_report), findsNothing);

      // Remount - a fresh State/element, same singleton.
      await tester.pumpWidget(_harness());
      await tester.pumpAndSettle();

      // Still expanded: the singleton, not the disposed State, is what
      // this widget reads from.
      expect(find.byIcon(Icons.close), findsOneWidget);
      expect(DevToolsBubblePanelState.instance.expanded, isTrue);
    },
  );

  testWidgets('the X button is still the only way to collapse the panel', (
    tester,
  ) async {
    await tester.pumpWidget(_harness());
    await tester.tap(find.byIcon(Icons.bug_report));
    await tester.pumpAndSettle();
    expect(DevToolsBubblePanelState.instance.expanded, isTrue);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();

    expect(DevToolsBubblePanelState.instance.expanded, isFalse);
    expect(find.byIcon(Icons.bug_report), findsOneWidget);
  });
}
