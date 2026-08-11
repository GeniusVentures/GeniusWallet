// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/buttons/gw_button.dart';
import 'package:genius_wallet/components/toast/toast_manager.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

// Task 2 (D-07) — the ONE file in Phase 9 with no per-file visual contract in
// 09-UI-SPEC.md (its Boundary Note fenced this file OUT; 09-CONTEXT.md's
// later D-07 brought it back IN). Its treatment below is DERIVED from the
// app-wide token rules and the shell archetype's visual language (see
// 09-05-SUMMARY.md), not specified by an approved per-file contract.
//
// The presentation mechanism is deliberately unchanged, not switched to the
// shared drawer helper's dialog-capable shell — that helper switches to a
// centred dialog at/above `GeniusBreakpoints.medium`
// (`lib/components/bottom_drawer/responsive_drawer.dart:21,40,72`), so
// adopting it would move this sheet to a centred dialog on every desktop
// window. That is a presentation change, not a paint change — restructuring
// under PROJECT.md §65, and Phase 21's call (see the drawer-language rollout,
// plan 21-04). See filed todo:
// .planning/todos/pending/2026-07-27-checkout-options-sheet-visual-contract-was-derived-not-specified.md
Future<void> showCheckoutOptionsSheet(
  BuildContext context, {
  required String checkoutUrl,
  required String orderId,
  required String redirectUrl,
}) async {
  final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    // Material's default modal-sheet surface derives from `ColorScheme.
    // surface` via a computed tonal container, not literally `gw.
    // surfaceElevated` — checked, not assumed, before adding this override.
    backgroundColor: gw.surfaceElevated,
    builder: (_) => CheckoutOptionsSheet(
      parentContext: context,
      checkoutUrl: checkoutUrl,
      orderId: orderId,
      redirectUrl: redirectUrl,
    ),
  );
}

class CheckoutOptionsSheet extends StatelessWidget {
  final BuildContext parentContext;
  final String checkoutUrl;
  final String orderId;
  final String redirectUrl;

  const CheckoutOptionsSheet({
    super.key,
    required this.parentContext,
    required this.checkoutUrl,
    required this.orderId,
    required this.redirectUrl,
  });

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GeniusWalletConsts.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continue to checkout',
              style: GeniusWalletTypography.titleLg.copyWith(
                color: gw.textPrimary,
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space6),

            // Neither this nor the two buttons below is the singular
            // money-moving action the way "Create Order" is — all three are
            // routes to the SAME checkout — so none takes the brand
            // gradient (09-UI-SPEC's "Accent reserved for" rule).
            GWButton(
              variant: GWButtonVariant.secondary,
              expand: true,
              label: 'Open in Browser',
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await launchUrl(
                    Uri.parse(checkoutUrl),
                    mode: LaunchMode.externalApplication,
                  );
                } catch (_) {
                  showToast(
                    context,
                    'Cannot open browser. Try QR or copy link.',
                    type: ToastType.error,
                  );
                }
              },
            ),
            const SizedBox(height: GeniusWalletConsts.space4),

            GWButton(
              variant: GWButtonVariant.secondary,
              expand: true,
              label: 'Show QR (use another device)',
              onPressed: () {
                Navigator.of(context).pop();
                GoRouter.of(parentContext).push(
                  '/checkoutQR',
                  extra: {'checkoutUrl': checkoutUrl, 'orderId': orderId},
                );
              },
            ),
            const SizedBox(height: GeniusWalletConsts.space4),

            // Copy link
            GWButton(
              variant: GWButtonVariant.tertiary,
              expand: true,
              leading: const Icon(Icons.content_copy),
              label: 'Copy checkout link',
              onPressed: () async {
                await Clipboard.setData(ClipboardData(text: checkoutUrl));
                if (parentContext.mounted) {
                  Navigator.of(context).pop();
                  showToast(context, 'Checkout link copied');
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
