import 'dart:io';
import 'package:flutter/widgets.dart';

import 'web_view_mobile.dart';
import 'web_view_windows.dart';

class WebViewScreen extends StatelessWidget {
  final String? url;
  final bool? includeBackButton;

  const WebViewScreen({super.key, this.url, this.includeBackButton});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WebViewWindows(
        url: url ?? "https://www.duckduckgo.com",
        includeBackButton: includeBackButton,
      );
    }
    return WebViewMobile(
      url: url ?? "https://www.duckduckgo.com",
      includeBackButton: includeBackButton,
    );
  }
}
