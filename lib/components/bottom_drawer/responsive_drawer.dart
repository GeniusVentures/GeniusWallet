import 'package:flutter/material.dart';
import 'package:genius_wallet/theme/genius_wallet_colors.dart';
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

    final content = _ReponsiveDrawerScaffold(
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
                decoration: const BoxDecoration(
                  color: GeniusWalletColors.deepBlueTertiary,
                  borderRadius: BorderRadius.horizontal(
                    left: Radius.circular(28),
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
      backgroundColor: GeniusWalletColors.deepBlueTertiary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (_) => content,
    );
  }
}

class _ReponsiveDrawerScaffold extends StatelessWidget {
  final Widget child;
  final String? title;
  final List<Widget>? actions;
  final Widget? footer;

  const _ReponsiveDrawerScaffold({
    required this.child,
    this.title,
    this.actions,
    this.footer,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: GeniusWalletColors.deepBlueTertiary,

      // Native Material app bar
      appBar: title != null
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              title: Text(title!),
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: Navigator.of(context).pop,
              ),
              actions: actions,
            )
          : null,

      // Content decides its own scrolling
      body: child,

      // Native Material footer area
      bottomNavigationBar: footer != null
          ? SafeArea(
              top: false,
              child: footer!,
            )
          : null,
    );
  }
}
