import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

/// Whether pages open inside the app on Linux. WebKitGTK is a system library
/// the user may not have, so it is probed once at startup; false keeps the
/// system browser.
bool linuxInAppWeb = false;

Future<void> probeLinuxInAppWeb() async {
  if (!Platform.isLinux) {
    return;
  }
  try {
    linuxInAppWeb = await LinuxWebViewPlatform.isAvailable();
  } catch (_) {
    linuxInAppWeb = false;
  }
}

void launchWebSite(BuildContext context, String url) async {
  if (Platform.isLinux) {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    return;
  }
  unawaited(
    context.push(
      '/web',
      extra: WebViewExtras(url: url, includeBackButton: true),
    ),
  );
}
