import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

/// Loads Banxa checkout in WebKitGTK inside the app, with the same navigation
/// rules as the mobile view. Only built after WebKitGTK loaded.
class CheckoutWebViewLinux extends StatefulWidget {
  const CheckoutWebViewLinux({
    super.key,
    required this.uri,
    required this.onReturn,
    required this.onLoadError,
  });

  final Uri uri;
  final VoidCallback onReturn;
  final VoidCallback onLoadError;

  @override
  State<CheckoutWebViewLinux> createState() => _CheckoutWebViewLinuxState();
}

class _CheckoutWebViewLinuxState extends State<CheckoutWebViewLinux> {
  late final WebViewController _controller;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (isBanxaReturn(uri, isMainFrame: request.isMainFrame)) {
              widget.onReturn();
              return NavigationDecision.prevent;
            }
            if (!allowsCheckoutNavigation(uri)) {
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            if (error.isForMainFrame ?? false) {
              widget.onLoadError();
            }
          },
        ),
      )
      ..loadRequest(widget.uri);
  }

  @override
  void dispose() {
    final platform = _controller.platform;
    if (platform is LinuxWebViewController) {
      unawaited(platform.dispose());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // The native view paints over the spinner, so it stays hidden until
        // the first page is done.
        WebOverlayGate(
          hidden: _loading,
          child: WebViewWidget(controller: _controller),
        ),
        if (_loading) const Center(child: Loading()),
      ],
    );
  }
}
