import 'dart:io';
import 'package:flutter/material.dart';
import 'web_view_mobile.dart';
import 'web_view_windows.dart';
import 'web_view_linux.dart';

class WebViewScreen extends StatelessWidget {
  final String url;

  const WebViewScreen({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (Platform.isWindows) {
      return WebViewWindows(url: url);
    } else if (Platform.isLinux) {
      return WebViewLinux(url: url);
    } else {
      return WebViewMobile(url: url);
    }
  }
}
