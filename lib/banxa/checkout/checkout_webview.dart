import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Loads Banxa checkout inside the app. The return link and every navigation
/// are judged by the pure rules; the page itself is never trusted.
class CheckoutWebView extends StatefulWidget {
  const CheckoutWebView({
    super.key,
    required this.uri,
    required this.onReturn,
    required this.onLoadError,
  });

  final Uri uri;
  final VoidCallback onReturn;
  final VoidCallback onLoadError;

  @override
  State<CheckoutWebView> createState() => _CheckoutWebViewState();
}

class _CheckoutWebViewState extends State<CheckoutWebView> {
  late final WebViewController _controller;
  bool _loading = true;
  // The permission request names no origin, so the last main-frame page
  // stands in for it: a bank or 3-D Secure page never gets the camera.
  late bool _onBanxaPage = isTrustedCheckoutUrl(widget.uri);

  @override
  void initState() {
    super.initState();
    _controller =
        WebViewController(
            onPermissionRequest: (request) {
              if (_onBanxaPage && checkoutPermissionAllowed(request.types)) {
                request.grant();
              } else {
                request.deny();
              }
            },
          )
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
                if (request.isMainFrame && uri != null) {
                  _onBanxaPage = isTrustedCheckoutUrl(uri);
                }
                return NavigationDecision.navigate;
              },
              onPageStarted: (url) {
                final uri = Uri.tryParse(url);
                if (uri != null) {
                  _onBanxaPage = isTrustedCheckoutUrl(uri);
                }
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
  Widget build(BuildContext context) {
    return Stack(
      children: [
        WebViewWidget(controller: _controller),
        if (_loading) const Center(child: Loading()),
      ],
    );
  }
}
