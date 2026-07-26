// Diagnostic for a smell spotted 2026-07-25 in global_swap_fab_host.dart:112-134.
//
// build() returns `widget.child` on the first frame and `Stack([widget.child, fab])`
// on every frame after `_ready` flips. That changes the SHAPE of the tree directly
// above the router's Navigator. The same construct in the Web omnibox
// (Container.decoration toggled null <-> non-null) provably unmounted and rebuilt its
// whole subtree — see test/web/url_bar_focus_remount_test.dart — so the question is
// whether this one remounts the entire app once at startup, taking every FocusNode,
// cubit subscription and initState with it.
//
// Measured by element identity across the _ready flip: a remount produces a new
// Element for the same widget.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';
import 'package:go_router/go_router.dart';

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
  ],
);

void main() {
  testWidgets('flipping _ready must not remount the app below the host', (
    tester,
  ) async {
    await tester.pumpWidget(_app(_router()));
    final Element before = tester.element(find.text('dashboard placeholder'));

    // The post-frame callback flips _ready, so build() swaps `child` for a Stack.
    await tester.pump();
    final Element after = tester.element(find.text('dashboard placeholder'));

    expect(
      identical(before, after),
      isTrue,
      reason:
          'The app below GlobalSwapFabHost was rebuilt from scratch when _ready '
          'flipped. Every State under it — FocusNodes, cubits, initState side '
          'effects — was disposed and recreated once at startup. Fix by keeping '
          'the shape constant: always return the Stack and gate only the FAB.',
    );
  });
}
