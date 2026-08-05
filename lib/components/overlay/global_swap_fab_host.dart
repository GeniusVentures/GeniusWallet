import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genius_wallet/components/buttons/gw_swap_fab.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

/// Wraps the app navigator and floats the global swap FAB over every
/// authenticated screen — including pushed detail / settings pages that
/// don't carry the bottom nav: [GWSwapFab] bottom-right (Swap from
/// anywhere).
///
/// Hidden on splash, landing, onboarding and wallet-creation surfaces
/// (and redundantly on their own destination screens). Mounted once at the
/// `MaterialApp.router` builder level in `main.dart`.
///
/// Takes the [router] instance explicitly rather than `GoRouter.of(context)`
/// because the builder's context can sit above the InheritedGoRouter.
///
/// Note: `7a63b4f`'s source additionally floated a bottom-left AI-FAB mirror
/// (live AI-processing status). That half was intentionally dropped at port
/// time — WIRE-02 keeps the AI FAB out of this milestone, and its button
/// component does not exist on this branch.
class GlobalSwapFabHost extends StatefulWidget {
  const GlobalSwapFabHost({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  /// Auth / onboarding / splash surfaces where the global swap action must
  /// not appear. Exact path match. Also hides on `/swap` (redundant there)
  /// and on `/token-info`, which grew its own live Swap button in Phase 8 —
  /// same redundancy rule, decided by Braian at the 08-07 walk.
  ///
  /// Note `/markets` is deliberately NOT here: it has no Swap affordance of
  /// its own (`TokenActionBar` is used only by the token detail), so hiding
  /// the FAB there would leave the page with no route to swap at all.
  static const Set<String> _hiddenPaths = {
    '/',
    '/landing_screen',
    '/backup_phrase',
    '/recovery_phrase',
    '/verify_recovery_phrase',
    '/legal',
    '/import_wallet',
    '/import_security',
    '/import_existing_wallet',
    '/create_wallet',
    '/swap',
    '/token-info',
    // Payment / KYC flows: floating wallet actions over a checkout or
    // identity form are distracting and can cover their CTAs.
    '/checkout',
    '/checkoutQR',
    '/kyc',
    '/banxa/callback',
  };

  @override
  State<GlobalSwapFabHost> createState() => _GlobalSwapFabHostState();
}

class _GlobalSwapFabHostState extends State<GlobalSwapFabHost> {
  // The FAB host sits inside the `MaterialApp.router` builder. Reading the
  // router's `currentConfiguration` while MaterialApp is doing its very first
  // build forces the delegate to resolve the initial route mid-build, which
  // marks MaterialApp dirty and throws "!_dirty". So we render nothing but the
  // child until after the first frame, by which point the router has settled.
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    // Listen to the router *delegate* (a ChangeNotifier) rather than the
    // routeInformationProvider: the delegate fires on every navigation change
    // including back-pops, so the FAB reliably reappears after returning from
    // a hidden route (the provider doesn't always notify on pop).
    widget.router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() => _ready = true);
      }
    });
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) {
      return;
    }
    // Before the first frame, build() ignores the router entirely (see _ready) and
    // the post-frame callback in initState rebuilds us anyway, so a rebuild here
    // would be pointless -- and actively harmful. `widget.child` is the router's
    // Navigator, so mounting it resolves the initial route and notifies the delegate
    // from inside our own performRebuild, *after* super.performRebuild() cleared the
    // dirty flag. setState() there re-dirties the element and trips assert(!_dirty).
    // The schedulerPhase check below does not catch that case: the initial mount runs
    // under attachRootWidget, where the phase is `idle`, not `persistentCallbacks`.
    if (!_ready) {
      return;
    }
    // The delegate can also notify *while a frame is building* (e.g. a redirect during
    // navigation). Calling setState then throws "!_dirty" too, so defer to the next
    // frame in that case; otherwise rebuild immediately.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {});
        }
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // First frame: don't touch the router yet (see _ready above).
    if (!_ready) {
      return widget.child;
    }

    // Read the TOP match's location, not the match list's `uri`.
    //
    // `currentConfiguration.uri` tracks only declarative navigation. An
    // imperative `push` appends an `ImperativeRouteMatch` WITHOUT moving that
    // uri, so after `push('/swap')` — which is exactly what this FAB does —
    // `uri.path` still reads `/dashboard` and the FAB stayed floating on top
    // of the swap screen it had just opened. `go('/swap')` from the nav bar
    // hid it correctly, which is why the original test missed this: it only
    // ever exercised `go`.
    //
    // `last.matchedLocation` reports `/swap` for BOTH push and go.
    final config = widget.router.routerDelegate.currentConfiguration;
    final path = config.isNotEmpty
        ? config.last.matchedLocation
        : config.uri.path;
    final hidden = GlobalSwapFabHost._hiddenPaths.contains(path);
    final bottomInset = MediaQuery.of(context).viewPadding.bottom;

    return Stack(
      children: [
        widget.child,
        if (!hidden)
          Positioned(
            right: GeniusWalletConsts.space10,
            // Clears the 60px bottom nav (+ safe-area) on the main shell;
            // floats thumb-reachable above the edge on pushed screens.
            bottom: 80 + bottomInset,
            child: GWSwapFab(onPressed: () => widget.router.push('/swap')),
          ),
      ],
    );
  }
}
