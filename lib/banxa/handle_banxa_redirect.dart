import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/buy_cancelled_drawer.dart';
import 'package:genius_wallet/banxa/buy_success_drawer.dart';

/// TODO: Replace these URLs with the actual success and cancel URLs from Banxa
const String buySuccessUrl = 'https://www.google.com';
const String buyCancelUrl = 'https://www.msn.com';

void handleBanxaRedirect({
  required BuildContext context,
  required String uri,
}) {
  if (uri.contains(buySuccessUrl)) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      BuySuccessDrawer.show(context, onClose: () {
        Navigator.of(context).pop(); // Close WebView
      });
    });
  }

  if (uri.contains(buyCancelUrl)) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!context.mounted) return;
      BuyCancelledDrawer.show(context, onClose: () {
        Navigator.of(context).pop(); // Close WebView
      });
    });
  }
}
