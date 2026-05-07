// checkout_options_sheet.dart
// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:genius_wallet/components/scaffold/scaffold_helper.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

Future<void> showCheckoutOptionsSheet(
  BuildContext context, {
  required String checkoutUrl,
  required String orderId,
  required String redirectUrl,
}) async {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(GeniusWalletConsts.space8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Continue to checkout',
              style: GeniusWalletTypography.titleMd,
            ),
            const SizedBox(height: GeniusWalletConsts.space6),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  Navigator.of(context).pop();
                  try {
                    await launchUrl(Uri.parse(checkoutUrl),
                        mode: LaunchMode.externalApplication);
                  } catch (_) {
                    showAppSnackBar(
                        context, 'Cannot open browser. Try QR or copy link.');
                  }
                },
                child: const Text('Open in Browser'),
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  GoRouter.of(parentContext).push('/checkoutQR', extra: {
                    'checkoutUrl': checkoutUrl,
                    'orderId': orderId,
                  });
                },
                child: const Text('Show QR (use another device)'),
              ),
            ),
            const SizedBox(height: GeniusWalletConsts.space4),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Clipboard.setData(ClipboardData(text: checkoutUrl));
                  if (parentContext.mounted) {
                    Navigator.of(context).pop();
                    showAppSnackBar(context, 'Checkout link copied');
                  }
                },
                icon: const Icon(Icons.content_copy),
                label: const Text('Copy checkout link'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
