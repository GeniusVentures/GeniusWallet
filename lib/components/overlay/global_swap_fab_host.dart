import 'package:flutter/material.dart';
import 'package:genius_wallet/components/buttons/gw_swap_fab.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:go_router/go_router.dart';

/// Wraps the app navigator and floats a global [GWSwapFab] over every
/// authenticated screen — including pushed detail / settings pages that
/// don't carry the bottom nav — so Swap is reachable from anywhere.
///
/// Hidden on splash, landing, onboarding and wallet-creation surfaces
/// (and redundantly on the swap screen itself). Mounted once at the
/// `MaterialApp.router` builder level in `main.dart`.
///
/// Takes the [router] instance explicitly rather than `GoRouter.of(context)`
/// because the builder's context can sit above the InheritedGoRouter.
class GlobalSwapFabHost extends StatelessWidget {
  const GlobalSwapFabHost({
    super.key,
    required this.router,
    required this.child,
  });

  final GoRouter router;
  final Widget child;

  /// Auth / onboarding / splash surfaces where the global swap action must
  /// not appear. Exact path match. Also hides on `/swap` (redundant there).
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
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: router.routeInformationProvider,
      builder: (context, _) {
        final path = router.routeInformationProvider.value.uri.path;
        final hidden = _hiddenPaths.contains(path);
        final bottomInset = MediaQuery.of(context).viewPadding.bottom;

        return Stack(
          children: [
            child,
            if (!hidden)
              Positioned(
                right: GeniusWalletConsts.space10,
                // Clears the 60px bottom nav (+ safe-area) on the main shell;
                // floats thumb-reachable above the edge on pushed screens.
                bottom: 80 + bottomInset,
                child: GWSwapFab(
                  onPressed: () => router.push('/swap'),
                ),
              ),
          ],
        );
      },
    );
  }
}
