import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/buttons/gw_swap_fab.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:go_router/go_router.dart';

/// `GlobalSwapFabHost` carries the NAV-02 crash fix (`assert(!_dirty)` on
/// startup, 7a63b4f): reading the router mid-`MaterialApp.router`'s very
/// first build re-dirties the element. The `_ready` gate defers that read
/// past the first frame — this file pins the automatable half of that fix.
///
/// The `!_dirty` crash itself is NOT reproducible under `pumpWidget` (it
/// needs `runApp`'s real mount timing); that repro is the 08-07 cold-start
/// walk's job, not this file's. What IS provable here: the host renders
/// ONLY its child on the very first frame (no router read at all), then
/// shows the FAB once the post-frame callback lands, and correctly hides/
/// reshows it across a hidden-path visit.

Widget _app(GoRouter router) => MaterialApp.router(
  routerConfig: router,
  builder: (context, child) => GlobalSwapFabHost(
    router: router,
    child: child ?? const SizedBox.shrink(),
  ),
);

GoRouter _router() => GoRouter(
  initialLocation: '/dashboard',
  routes: [
    GoRoute(
      path: '/dashboard',
      builder: (context, state) =>
          const Scaffold(body: Text('dashboard placeholder')),
    ),
    // '/swap' is one of GlobalSwapFabHost's verbatim-ported _hiddenPaths.
    GoRoute(
      path: '/swap',
      builder: (context, state) =>
          const Scaffold(body: Text('swap placeholder')),
    ),
  ],
);

void main() {
  testWidgets('first frame renders only the child; FAB appears after', (
    tester,
  ) async {
    final router = _router();
    await tester.pumpWidget(_app(router));

    // Before any further pump: the post-frame callback that flips `_ready`
    // has not run yet, so build() must have taken the `!_ready` short-circuit
    // and returned `widget.child` alone. Goes red if the host reads the
    // router (and therefore renders the FAB) on its very first build.
    expect(
      find.byType(GWSwapFab),
      findsNothing,
      reason: 'the _ready gate must suppress the FAB on the first frame',
    );
    expect(find.text('dashboard placeholder'), findsOneWidget);

    // Let the post-frame callback's setState land.
    await tester.pump();

    expect(
      find.byType(GWSwapFab),
      findsOneWidget,
      reason: 'once _ready flips, the visible-path FAB must appear',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the FAB is hidden on a _hiddenPaths route', (tester) async {
    final router = _router();
    await tester.pumpWidget(_app(router));
    await tester.pump(); // let _ready flip

    expect(find.byType(GWSwapFab), findsOneWidget);

    router.go('/swap');
    await tester.pumpAndSettle();

    expect(
      find.byType(GWSwapFab),
      findsNothing,
      reason: '/swap is in the ported _hiddenPaths set',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('the FAB reappears after returning from a hidden path', (
    tester,
  ) async {
    final router = _router();
    await tester.pumpWidget(_app(router));
    await tester.pump(); // let _ready flip

    router.go('/swap');
    await tester.pumpAndSettle();
    expect(find.byType(GWSwapFab), findsNothing);

    router.go('/dashboard');
    await tester.pumpAndSettle();

    // This is what listening to the routerDelegate (a ChangeNotifier) buys
    // over routeInformationProvider: the delegate reliably notifies on this
    // transition, so the FAB must reliably come back.
    expect(
      find.byType(GWSwapFab),
      findsOneWidget,
      reason: 'returning to a visible path must reshow the FAB',
    );
    expect(tester.takeException(), isNull);
  });
}
