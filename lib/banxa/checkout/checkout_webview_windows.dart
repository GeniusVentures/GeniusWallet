import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_wallet/banxa/checkout/checkout_rules.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/web/windows_webview_shutdown.dart';
import 'package:webview_windows/webview_windows.dart';
import 'package:window_manager/window_manager.dart';

/// Loads Banxa checkout in WebView2 inside the app. WebView2 has no navigation
/// veto, so the order poller, not the return URL, decides when checkout is done.
class CheckoutWebViewWindows extends StatefulWidget {
  const CheckoutWebViewWindows({
    super.key,
    required this.uri,
    required this.onReturn,
    required this.onLoadError,
  });

  final Uri uri;
  final VoidCallback onReturn;
  final VoidCallback onLoadError;

  @override
  State<CheckoutWebViewWindows> createState() => _CheckoutWebViewWindowsState();
}

class _CheckoutWebViewWindowsState extends State<CheckoutWebViewWindows> {
  final WebviewController _controller = WebviewController();
  final List<StreamSubscription<Object?>> _subscriptions = [];
  bool _ready = false;
  bool _loading = true;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    WindowsWebViewShutdown.instance.register(_disposeResources);
    unawaited(windowManager.setPreventClose(true));
    unawaited(_start());
  }

  Future<void> _start() async {
    try {
      await _controller.initialize();
      if (_disposed) {
        return;
      }
      await _controller.setPopupWindowPolicy(
        WebviewPopupWindowPolicy.sameWindow,
      );
      _subscriptions.addAll([
        _controller.url.listen((url) {
          final uri = Uri.tryParse(url);
          if (isBanxaReturn(uri, isMainFrame: true)) {
            widget.onReturn();
          } else if (!allowsCheckoutNavigation(uri)) {
            // ponytail: webview_windows 0.4.0 exposes no NavigationStarting
            // veto, so the page has already started loading; stop it and drop
            // the view. Upgrade: cancel in NavigationStarting once exposed.
            unawaited(_controller.stop());
            widget.onLoadError();
          }
        }),
        _controller.loadingState.listen((state) {
          if (mounted) {
            setState(() => _loading = state == LoadingState.loading);
          }
        }),
        _controller.onLoadError.listen((status) {
          // A redirect cancels the navigation it replaces; that is not a failure.
          if (status != WebErrorStatus.WebErrorStatusOperationCanceled) {
            widget.onLoadError();
          }
        }),
      ]);
      await _controller.loadUrl(widget.uri.toString());
      if (mounted) {
        setState(() => _ready = true);
      }
    } catch (_) {
      if (!_disposed) {
        widget.onLoadError();
      }
    }
  }

  @override
  void dispose() {
    WindowsWebViewShutdown.instance.unregister(_disposeResources);
    if (!WindowsWebViewShutdown.instance.hasActiveWebViews) {
      unawaited(windowManager.setPreventClose(false));
    }
    unawaited(_disposeResources());
    super.dispose();
  }

  Future<void> _disposeResources() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    _subscriptions.clear();
    await _controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        if (_ready)
          Webview(
            _controller,
            permissionRequested: (url, kind, isUserInitiated) =>
                windowsCheckoutPermission(kind, url: url),
          ),
        if (!_ready || _loading) const Center(child: Loading()),
      ],
    );
  }
}
