import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

/// Loads Banxa checkout in WebKitGTK inside the app, with the same navigation
/// and permission rules as the mobile view. Only built after WebKitGTK loaded.
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
  // The request names no origin, so the last main-frame page stands in for it:
  // a bank or 3-D Secure page never gets the camera.
  late bool _onBanxaPage = isTrustedCheckoutUrl(widget.uri);

  @override
  void initState() {
    super.initState();
    _controller = WebViewController(onPermissionRequest: _onPermissionRequest)
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          // A navigation request names no frame on WebKitGTK, so it is not
          // where the permission origin or the return link is decided. The
          // return link is let through because WebKit fails it, for the main
          // frame only, and onWebResourceError picks that up.
          onNavigationRequest: (request) {
            final uri = Uri.tryParse(request.url);
            if (isBanxaReturn(uri, isMainFrame: true) ||
                allowsCheckoutNavigation(uri)) {
              return NavigationDecision.navigate;
            }
            return NavigationDecision.prevent;
          },
          onPageStarted: _onMainFrameUrl,
          onUrlChange: (change) {
            final url = change.url;
            if (url != null) {
              _onMainFrameUrl(url);
            }
          },
          onPageFinished: (_) {
            if (mounted) {
              setState(() => _loading = false);
            }
          },
          onWebResourceError: (error) {
            switch (classifyLinuxLoadFailure(
              isForMainFrame: error.isForMainFrame,
              url: error.url,
            )) {
              case LinuxLoadFailure.returned:
                widget.onReturn();
              case LinuxLoadFailure.loadError:
                widget.onLoadError();
              case LinuxLoadFailure.ignore:
                break;
            }
          },
        ),
      );
    // The native view is created on first use and can fail to open.
    unawaited(
      _controller
          .loadRequest(widget.uri)
          .catchError((_) => widget.onLoadError()),
    );
  }

  // Load events are main-frame only, so an embedded frame cannot change it.
  void _onMainFrameUrl(String url) {
    final uri = Uri.tryParse(url);
    _onBanxaPage = uri != null && isTrustedCheckoutUrl(uri);
  }

  Future<void> _onPermissionRequest(WebViewPermissionRequest request) async {
    final allowed = checkoutPermissionAllowed(
      onBanxaPage: _onBanxaPage,
      types: request.types.map((t) => t.name),
    );
    if (!allowed) {
      await request.deny();
      return;
    }
    await request.grant();
  }

  @override
  void dispose() {
    final platform = _controller.platform;
    if (platform is LinuxWebViewController) {
      // Throws when the native view never opened; nothing is left to tell, and
      // lib/banxa prints nothing.
      unawaited(platform.dispose().catchError((Object _) {}));
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
