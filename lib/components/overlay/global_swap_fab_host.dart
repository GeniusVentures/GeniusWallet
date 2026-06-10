import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:genius_wallet/components/buttons/gw_ai_fab.dart';
import 'package:genius_wallet/components/buttons/gw_swap_fab.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

/// Wraps the app navigator and floats the global FABs over every
/// authenticated screen — including pushed detail / settings pages that
/// don't carry the bottom nav: [GWSwapFab] bottom-right (Swap from
/// anywhere) and its mirror [GWAiFab] bottom-left (live AI-processing %,
/// taps through to the submit-job screen).
///
/// Hidden on splash, landing, onboarding and wallet-creation surfaces
/// (and redundantly on their own destination screens). Mounted once at the
/// `MaterialApp.router` builder level in `main.dart`.
///
/// Takes the [router] instance explicitly rather than `GoRouter.of(context)`
/// because the builder's context can sit above the InheritedGoRouter.
class GlobalSwapFabHost extends StatefulWidget {
  const GlobalSwapFabHost({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  /// Auth / onboarding / splash surfaces where the global swap action must
  /// not appear. Exact path match. Also hides on `/swap` (redundant there).
  /// Swap stays reachable everywhere else, including the token detail.
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
      if (mounted) setState(() => _ready = true);
    });
  }

  @override
  void dispose() {
    widget.router.routerDelegate.removeListener(_onRouteChanged);
    super.dispose();
  }

  void _onRouteChanged() {
    if (!mounted) return;
    // The delegate can notify *while a frame is building* (e.g. as the initial
    // route resolves at startup). Calling setState then throws "!_dirty".
    // Defer to the next frame in that case; otherwise rebuild immediately.
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // First frame: don't touch the router yet (see _ready above).
    if (!_ready) return widget.child;

    final path = widget.router.routerDelegate.currentConfiguration.uri.path;
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
            child: GWSwapFab(
              onPressed: () => widget.router.push('/swap'),
            ),
          ),
        // Bottom-left mirror: live AI-processing status. Hidden additionally
        // on its own destination (the submit-job screen).
        if (!hidden && path != '/submit_job')
          Positioned(
            left: GeniusWalletConsts.space10,
            bottom: 80 + bottomInset,
            child: GWAiFab(
              onPressed: () => widget.router.push('/submit_job'),
            ),
          ),
      ],
    );
  }
}
