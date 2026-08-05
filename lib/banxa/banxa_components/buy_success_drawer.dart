// buy_success_drawer.dart
import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/banxa_components/buy_success_drawer_content.dart';
import 'package:genius_wallet/components/bottom_drawer/responsive_drawer.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';

/// **Finding, recorded not acted on (21-03-SUMMARY.md):** this drawer has no
/// production caller -- the only reference outside its own files is
/// `lib/dev/dev_tools_bubble.dart`. Sketch 066-B's Purchase section (`Paid`,
/// `Method`, `Order`) needs order data neither this API nor that dev-only
/// caller supplies, so it is not drawn here; wiring that is a future,
/// separate decision.
class BuySuccessDrawer {
  static void show(BuildContext context, {VoidCallback? onClose}) {
    ResponsiveDrawer.show<void>(
      context: context,
      title: 'Purchase complete',
      child: ListView(children: const [BuySuccessDrawerContent()]),
      // Defect fix (21-03): this button used to only invoke onClose when one
      // was supplied and never closed the drawer itself -- the sole caller
      // supplies nothing, so it was dead. It now pops the drawer first, then
      // still invokes onClose if the caller gave one.
      footer: GWButton(
        onPressed: () {
          Navigator.of(context).pop();
          onClose?.call();
        },
        label: 'Done',
        variant: GWButtonVariant.gradient,
        size: GWButtonSize.lg,
        expand: true,
      ),
    );
  }
}
