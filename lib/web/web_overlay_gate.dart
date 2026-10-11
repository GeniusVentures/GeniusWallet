import 'package:flutter/widgets.dart';
import 'package:genius_wallet/components/overlay/global_swap_fab_host.dart';

/// The native page paints above Flutter, so it steps aside while a popup is up.
/// Offstage keeps the page loaded, so closing the popup does not reload it.
class WebOverlayGate extends StatelessWidget {
  const WebOverlayGate({super.key, required this.child, this.hidden = false});

  final Widget child;
  final bool hidden;

  /// Popups opened inside a shell page land on the ShellRoute's navigator, which
  /// the root observers never see. An observer attaches to one navigator only.
  static final PopupRouteObserver shellPopupRoutes = PopupRouteObserver();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([
        GlobalSwapFabHost.popupRoutes,
        shellPopupRoutes,
      ]),
      builder: (context, _) => Offstage(
        offstage:
            hidden ||
            GlobalSwapFabHost.popupRoutes.anyOpen ||
            shellPopupRoutes.anyOpen,
        child: child,
      ),
    );
  }
}
