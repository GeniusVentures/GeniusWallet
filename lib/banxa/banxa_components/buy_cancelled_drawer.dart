import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_cancelled_drawer_content.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';

/// **Finding, recorded not acted on (21-03-SUMMARY.md):** this drawer has no
/// production caller -- the only reference outside its own files is
/// `lib/dev/dev_tools_bubble.dart`. No "Try again" affordance is added: no
/// retry callback exists on this API and inventing one is mechanics, not a
/// re-skin.
class BuyCancelledDrawer {
  static void show(BuildContext context) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Purchase cancelled',
      child: ListView(children: const [BuyCancelledDrawerContent()]),
      // Defect fix (21-03): this handler used to be an empty block that did
      // nothing at all. It now actually closes the drawer.
      footer: GWButton(
        onPressed: () => Navigator.of(context).pop(),
        label: 'Close',
        variant: GWButtonVariant.gradientOutline,
        size: GWButtonSize.lg,
        expand: true,
      ),
    );
  }
}
