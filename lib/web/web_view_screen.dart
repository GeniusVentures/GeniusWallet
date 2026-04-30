import 'dart:io';
import 'package:flutter/material.dart';
import 'web_view_mobile.dart';
import 'web_view_windows.dart';
//import 'web_view_linux.dart';

class WebViewScreen extends StatelessWidget {
  final String? url;
  final bool? includeBackButton;

  const WebViewScreen({super.key, this.url, this.includeBackButton});

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WebViewWindows(
          url: url ?? "https://www.duckduckgo.com",
          includeBackButton: includeBackButton);
    }
    //else if (Platform.isLinux) {
    //return WebViewLinux(url: url ?? "https://www.duckduckgo.com");
    //}
    else {
      return WebViewMobile(
          url: url ?? "https://www.duckduckgo.com",
          includeBackButton: includeBackButton);
    }
  }
}
