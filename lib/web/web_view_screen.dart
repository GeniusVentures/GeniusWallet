import 'dart:io';
import 'package:flutter/material.dart';
import 'web_view_mobile.dart';
import 'web_view_windows.dart';

class WebViewScreen extends StatelessWidget {
  final String? url;
  final bool? includeBackButton;

  const WebViewScreen({Key? key, this.url, this.includeBackButton})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WebViewWindows(
          url: url ?? "https://www.duckduckgo.com",
          includeBackButton: includeBackButton);
    }
    else {
      return WebViewMobile(
          url: url ?? "https://www.duckduckgo.com",
          includeBackButton: includeBackButton);
    }
  }
}
