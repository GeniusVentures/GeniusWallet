import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/dev/dev_flags.dart';
import 'package:genius_wallet/dev/dev_tools_bubble.dart';
import 'package:go_router/go_router.dart';

/// Floats [DevToolsBubble] above the app's root Navigator, mounted once at
/// the `MaterialApp.router` builder level in `main.dart` - the same level
/// `GlobalSwapFabHost` mounts at, and for the same structural reason.
///
/// **Why this exists.** Desktop `ResponsiveDrawer.show` opens its drawer
/// with `showDialog(useRootNavigator: true, barrierDismissible: ...)`, whose
/// `ModalBarrier` is a full-screen layer inside the ROOT navigator's
/// overlay - above the whole page. The old mount point put the bubble
/// inside the page itself (`responsive_overlay.dart`'s `MobileOverlay` /
/// `DesktopOverlay`, in a `Stack` owned by the ShellRoute's page), which
/// sits BELOW that dialog route. A tap on the bubble therefore landed on
/// the barrier and dismissed the drawer instead of reaching the panel, and
/// the panel rendered dimmed under the barrier's `black54` scrim for the
/// same layering reason. Moving the mount above the Navigator - this host -
/// puts the bubble above the barrier too, so its own taps reach it while a
/// tap anywhere else on the barrier still closes the drawer exactly as
/// before.
///
/// **Why a sibling of `GlobalSwapFabHost`, not an extension of it.** That
/// class is stateful only to carry route-listening machinery (`_ready`, the
/// delegate listener) whose sole job is hiding the FAB on its own
/// `_hiddenPaths`. The dev bubble needs none of that (see the no-hidden-
/// paths reasoning below), so extending `GlobalSwapFabHost` would put
/// dev-only code and a `lib/dev/` import inside a shared production
/// component, and would leave a class named `GlobalSwapFabHost` mounting
/// something that is not a swap FAB. This lives in `lib/dev/`, where the
/// rest of the dev-only code already does, and is stateless.
///
/// **Why the gate is a defaulted field, not an inline `kDebugMode &&
/// kShowDevTools` check.** `kShowDevTools` is
/// `const bool.fromEnvironment('GW_DEV_TOOLS')`, so it reads `false` under
/// `flutter test` and cannot be flipped at runtime. A hard-coded check would
/// make a regression test exercise a copy of this host's body rather than
/// the host itself - a test of the wrong thing. [enabled] defaults to the
/// const expression `kDebugMode && kShowDevTools` (so the default itself
/// stays const and the mount still tree-shakes out of release builds);
/// `main.dart` passes nothing, and a test passes `enabled: true`.
///
/// **No hidden-path set here, and none is wanted.** `GlobalSwapFabHost`
/// hides on named paths because its FAB is fixed at `bottom: 80 + inset,
/// right: space10` and can permanently cover an onboarding or checkout CTA
/// the user cannot move. The dev bubble is draggable and collapses to a
/// 48px circle, so it can never trap a control, and it is behind a
/// dart-define that is off in every build nobody has explicitly asked for
/// it in. It is also most useful exactly on the surfaces it could not reach
/// before - appearance toggling during an onboarding walk, mock injection
/// before a wallet exists. The accepted cost (floating over recovery-phrase
/// and wallet-creation screens in `GW_DEV_TOOLS=true` debug builds) is
/// recorded in this plan's threat model.
class DevToolsBubbleHost extends StatelessWidget {
  const DevToolsBubbleHost({
    super.key,
    required this.router,
    required this.child,
    this.enabled = kDebugMode && kShowDevTools,
  });

  final GoRouter router;
  final Widget child;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    if (!enabled) {
      return child;
    }
    return Stack(
      children: [
        child,
        // Discovered running Task 3's regression test (2026-07-31): several
        // panel buttons pass a `tooltip` to GWButton, which wraps itself in
        // a `Tooltip`, and `Tooltip` calls `Overlay.of(context)` on ITS OWN
        // ancestor chain in the real widget tree - independent of whatever
        // context DevToolsBubble's actions are rebound onto. At this mount
        // point (above the root Navigator) there is no Overlay ancestor
        // there at all, since Navigator builds its Overlay as a CHILD of
        // itself, not above it. `Overlay.wrap` is the sanctioned Flutter
        // API for exactly this: it gives DevToolsBubble its own local
        // Overlay so every Tooltip inside the panel has one to find, with
        // no effect on where the panel itself renders (DevToolsBubble's
        // `Positioned` still positions against this Overlay's own internal
        // Stack, which fills the same space the bare Positioned did).
        Overlay.wrap(child: DevToolsBubble(router: router)),
      ],
    );
  }
}
