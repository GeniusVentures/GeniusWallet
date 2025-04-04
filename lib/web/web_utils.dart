import 'dart:io';

import 'package:flutter/material.dart';
import 'package:genius_wallet/navigation/web_view_extras.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

void launchWebSite(BuildContext context, String url) async {
  if (Platform.isLinux) {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    return;
  }
  context.push('/web', extra: WebViewExtras(url: url, includeBackButton: true));
}
