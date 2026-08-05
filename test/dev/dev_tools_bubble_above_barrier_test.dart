// Quick task 260731-gow: two-sided regression test proving the dev-tools
// bubble no longer sits below the drawer's showDialog barrier.
//
// Root cause (see lib/dev/dev_tools_host.dart's class doc): desktop
// ResponsiveDrawer.show opens with showDialog(useRootNavigator: true), whose
// ModalBarrier is a full-screen layer in the ROOT navigator's overlay -
// above the whole page. The old mount point put the bubble inside the page
// itself, below that barrier, so a tap on the bubble landed on the barrier
// and dismissed the drawer instead of reaching the panel. The fix re-homes
// the bubble above the root Navigator via DevToolsBubbleHost.
//
// BOTH halves below are required, and the second is not optional decoration
// - a test asserting only the first would also pass if the drawer had
// stopped being dismissible at all, which is the opposite of what was
// asked.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/dev/dev_tools_bubble.dart';
import 'package:genius_wallet/dev/dev_tools_host.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';

/// A `/` route rendering a button that opens a titleless ResponsiveDrawer.
///
/// No title is passed to `ResponsiveDrawer.show`: with a title,
/// `_ResponsiveDrawerScaffold` renders its OWN `Icons.close` X button, which
/// would make `find.byIcon(Icons.close)` ambiguous between the drawer's own
/// close button and the dev panel's. Omitting the title keeps `Icons.close`
/// meaning exactly one thing in this file: the panel's own X.
GoRouter _harnessRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => Scaffold(
          body: Center(
            child: Builder(
              builder: (innerContext) => ElevatedButton(
                onPressed: () => ResponsiveDrawer.show(
                  context: innerContext,
                  child: const Text('DRAWER BODY'),
                ),
                child: const Text('Open drawer'),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

/// Renders the harness under `MaterialApp.router` with `DevToolsBubbleHost`
/// mounted at the builder level - the real mount point, not a bare
/// `MaterialApp` with the bubble dropped straight into a `Stack`. That
/// distinction is the entire point of this test: it is the builder-level
/// mount that puts the bubble above the root Navigator's `showDialog`
/// barrier.
Widget _harness(GoRouter router) {
  return MaterialApp.router(
    routerConfig: router,
    theme: ThemeData.dark().copyWith(extensions: [GWColors.dark()]),
    builder: (context, child) => DevToolsBubbleHost(
      enabled: true,
      router: router,
      child: child ?? const SizedBox.shrink(),
    ),
  );
}

void main() {
  void resetPanelState() {
    // The singleton is process-wide - reset before and after each test so
    // no test leaks its state into the next one (same pattern as
    // dev_tools_bubble_persistence_test.dart).
    DevToolsBubblePanelState.instance.position = null;
    DevToolsBubblePanelState.instance.expanded = false;
  }

  setUp(resetPanelState);
  tearDown(resetPanelState);

  // Desktop width/height forces ResponsiveDrawer.show's DESKTOP showDialog
  // branch (width >= GeniusBreakpoints.medium, 768) - that barrier is the
  // reported bug, not the mobile showModalBottomSheet branch.
  void setDesktopSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
  }

  testWidgets(
    'Test 1 (the bug): a tap on the dev bubble expands the panel and leaves '
    'an open drawer open, and the exception does not leak into the '
    "barrier's own dismissal behaviour",
    (tester) async {
      setDesktopSize(tester);

      final router = _harnessRouter();
      await tester.pumpWidget(_harness(router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open drawer'));
      await tester.pumpAndSettle();

      expect(find.text('DRAWER BODY'), findsOneWidget);
      // Collapsed bubble: no close icon on screen yet (see the harness doc
      // for why Icons.close is unambiguous here).
      expect(find.byIcon(Icons.close), findsNothing);

      // THE BUG, reproduced: tap the dev bubble while the drawer is open.
      await tester.tap(find.byIcon(Icons.bug_report));
      await tester.pumpAndSettle();

      // Both assertions are required. The second is what proves the tap
      // reached the bubble rather than being silently swallowed by the
      // barrier underneath it - tester.tap only WARNS on a missed target,
      // it does not fail the test on its own.
      expect(find.text('DRAWER BODY'), findsOneWidget);
      expect(find.byIcon(Icons.close), findsOneWidget);

      // THE GUARD, in the same test: with the panel now EXPANDED, a tap on
      // the barrier away from both the drawer and the panel still closes
      // the drawer - proving the panel's tap-exception is scoped to the
      // panel and did not leak into the barrier's behaviour generally.
      //
      // Derivation of the point: window is 1200x900. The drawer is 420
      // wide, right-aligned (Align(alignment: centerRight)), so it occupies
      // x in [780, 1200]. The expanded panel is anchored top-right at
      // (right: edgeInset=GeniusWalletConsts.space4=8, top:
      // headerHeight(68)+edgeInset(8)=76) with width up to 260, so it
      // occupies x in [932, 1192] at most. Offset(100, 700) has x=100, left
      // of both the drawer (>=780) and the panel (>=932), so it lands only
      // on the barrier regardless of either widget's exact height.
      await tester.tapAt(const Offset(100, 700));
      await tester.pumpAndSettle();

      expect(find.text('DRAWER BODY'), findsNothing);
    },
  );

  testWidgets(
    'Test 2 (the guard): a tap on the barrier away from the drawer and the '
    'collapsed bubble closes the drawer, exactly as before this change',
    (tester) async {
      setDesktopSize(tester);

      final router = _harnessRouter();
      await tester.pumpWidget(_harness(router));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open drawer'));
      await tester.pumpAndSettle();
      expect(find.text('DRAWER BODY'), findsOneWidget);

      // Same derivation as Test 1's guard step, with the bubble still
      // collapsed (48x48 at right: 8, top: 76, so x in [1144, 1192]):
      // Offset(100, 700) is clear of the drawer (x >= 780), the collapsed
      // bubble (x >= 1144), and lands only on the barrier.
      await tester.tapAt(const Offset(100, 700));
      await tester.pumpAndSettle();

      expect(find.text('DRAWER BODY'), findsNothing);
    },
  );
}
