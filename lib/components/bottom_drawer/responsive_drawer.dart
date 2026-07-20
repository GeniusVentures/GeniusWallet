import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';

class ResponsiveDrawer {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    String? title,
    List<Widget>? actions,
    Widget? footer,
    double desktopWidth = 420,
    bool useRootNavigator = true,
    bool isDismissible = true,
    bool enableDrag = true,
  }) {
    final isDesktop =
        MediaQuery.sizeOf(context).width >= GeniusBreakpoints.medium;

    // Fail-soft read: resolved once at open-time (this is a static factory,
    // not a widget build()), used for the two Route/API-level color params
    // below (desktop panel decoration, mobile bottom-sheet backgroundColor).
    // These are captured once when show() is invoked -- the same structural
    // limitation as GWDialog.show()'s barrierColor -- while the LIVE flip
    // while the drawer stays open is carried by
    // _ResponsiveDrawerScaffold.build()'s own Theme dependency below.
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();

    final content = _ResponsiveDrawerScaffold(
      title: title,
      actions: actions,
      footer: footer,
      child: child,
    );

    if (isDesktop) {
      return showDialog<T>(
        context: context,
        barrierDismissible: isDismissible,
        barrierColor: Colors.black54,
        useRootNavigator: useRootNavigator,
        builder: (_) {
          return Align(
            alignment: Alignment.centerRight,
            child: Material(
              color: Colors.transparent,
              child: Container(
                width: desktopWidth,
                height: double.infinity,
                // Remapped from the legacy non-appearance-aware
                // deepBlueTertiary constant to the closest appearance-aware
                // sheet/menu surface token (documented value remap, see
                // 04-04-SUMMARY.md). No longer const -- takes a runtime Color.
                decoration: BoxDecoration(
                  color: gw.surfaceMenu,
                  borderRadius: const BorderRadius.horizontal(
                    left: Radius.circular(GeniusWalletConsts.radius3xl),
                  ),
                ),
                clipBehavior: Clip.antiAlias,
                child: content,
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      useRootNavigator: useRootNavigator,
      isDismissible: isDismissible,
      enableDrag: enableDrag,
      useSafeArea: true,
      isScrollControlled: true,
      // Remapped from the legacy non-appearance-aware deepBlueTertiary
      // constant to the closest appearance-aware sheet/menu surface token
      // (documented value remap, see 04-04-SUMMARY.md).
      backgroundColor: gw.surfaceMenu,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(GeniusWalletConsts.radius3xl),
        ),
      ),
      builder: (_) => content,
    );
  }
}

class _ResponsiveDrawerScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? footer;

  const _ResponsiveDrawerScaffold({
    required this.child,
    this.title,
    this.actions,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    // Fail-soft read: registers the InheritedWidget dependency that forces
    // this widget to rebuild on a live appearance toggle -- this is the
    // read that makes the LIVE drawer's own background genuinely flip while
    // the drawer stays open (this widget stays mounted for the drawer's
    // lifetime in both the desktop and mobile branches of
    // ResponsiveDrawer.show()).
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Scaffold(
      // Remapped from the legacy non-appearance-aware deepBlueTertiary
      // constant to the closest appearance-aware sheet/menu surface token
      // (documented value remap, see 04-04-SUMMARY.md).
      backgroundColor: gw.surfaceMenu,

      // Native Material app bar
      appBar: title != null
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(title!),
              leadingWidth: 56,
              leading: Padding(
                padding: const EdgeInsets.only(
                  left: GeniusWalletConsts.space2,
                  top: GeniusWalletConsts.space2,
                ),
                child: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: Navigator.of(context).pop,
                ),
              ),
              actions: actions,
            )
          : null,

      // Content decides its own scrolling
      body: child,

      // Native Material footer area
      bottomNavigationBar: footer != null
          ? SafeArea(top: false, child: footer!)
          : null,
    );
  }
}
