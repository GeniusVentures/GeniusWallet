import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

const String _channel = 'gnusBridge';

/// The bridge on WebKitGTK. It names no sender for a message, so the caller's
/// origin is the URL of the last committed top-level document.
class GnusBridgeViewLinux extends StatefulWidget {
  const GnusBridgeViewLinux({
    super.key,
    required this.url,
    required this.handler,
    required this.readNet,
    required this.dev,
    this.onPageFinished,
    this.onLoadFailed,
  });

  final String url;
  final GnusRpcHandler handler;
  final Future<SgnsNet> Function() readNet;
  final bool dev;

  /// A main-frame page finished loading.
  final VoidCallback? onPageFinished;

  /// A main-frame load failed. WebKitGTK reports main-frame failures only.
  final VoidCallback? onLoadFailed;

  @override
  State<GnusBridgeViewLinux> createState() => _GnusBridgeViewLinuxState();
}

class _GnusBridgeViewLinuxState extends State<GnusBridgeViewLinux> {
  final WebViewController _controller = WebViewController();
  late final GnusWebBridge _bridge;
  Set<GnusOrigin> _allowed = const {};
  String? _committedUrl;
  bool _leaving = false;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _bridge = GnusWebBridge(
      handler: widget.handler,
      readNet: widget.readNet,
      deliver: _controller.runJavaScript,
      dev: widget.dev,
    );
    unawaited(_init());
  }

  Future<void> _init() async {
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    await _controller.addJavaScriptChannel(
      _channel,
      // Read synchronously: the page events arrive on the same ordered
      // channel as this message. Between a navigation's start and its commit
      // the old page may be leaving, so it speaks for nobody.
      onMessageReceived: (message) => _bridge.onMessage(
        message.message,
        source: _leaving ? null : _committedUrl,
      ),
    );
    await _controller.addUserScript(
      WebViewUserScript(source: _bridge.shimSource),
    );
    try {
      _allowed = await _bridge.allowedOrigins();
    } catch (e) {
      // With no allowlist every load is refused, which is the safe failure.
      debugPrint('Bridge allowlist unavailable: ${e.runtimeType}');
    }
    final delegate = NavigationDelegate(
      onNavigationRequest: _onNavigationRequest,
      onPageStarted: (_) => _leaving = true,
      // Also ends a navigation that never commits (a download, a 204, a
      // blocked redirect): the page that started it is still the one shown.
      onPageFinished: (_) {
        _leaving = false;
        widget.onPageFinished?.call();
      },
      onWebResourceError: (error) {
        if (error.isForMainFrame == true) {
          widget.onLoadFailed?.call();
        }
      },
    );
    final platform = delegate.platform;
    if (platform is LinuxNavigationDelegate) {
      await platform.setOnPageCommitted((url) {
        _committedUrl = url;
        _leaving = false;
        _bridge.pageCommitted(url);
      });
    }
    await _controller.setNavigationDelegate(delegate);
    final agent = await _controller.getUserAgent();
    if (agent != null) {
      await _controller.setUserAgent('$agent$gnusUserAgentSuffix');
    }
    await _controller.loadRequest(Uri.parse(widget.url));
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  // WebKitGTK names no frame for a decision, so a subframe load is held to the
  // same list as the page; only a new-window request opens the system browser.
  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    final frame = request.isNewWindow ? GnusFrame.newWindow : GnusFrame.unknown;
    switch (gnusNavigation(url: uri, frame: frame, allowed: _allowed)) {
      case GnusNavigation.allow:
        return NavigationDecision.navigate;
      case GnusNavigation.external:
        unawaited(launchUrl(uri!, mode: LaunchMode.externalApplication));
        return NavigationDecision.prevent;
      case GnusNavigation.block:
        return NavigationDecision.prevent;
    }
  }

  @override
  void didUpdateWidget(covariant GnusBridgeViewLinux oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready && oldWidget.url != widget.url) {
      unawaited(_controller.loadRequest(Uri.parse(widget.url)));
    }
  }

  @override
  void dispose() {
    unawaited(_bridge.dispose());
    final platform = _controller.platform;
    if (platform is LinuxWebViewController) {
      unawaited(
        platform.dispose().catchError(
          (Object e) => debugPrint('Bridge web view dispose failed: $e'),
        ),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    // WebKitGTK paints above Flutter, so a prompt would sit under the page.
    return WebOverlayGate(child: WebViewWidget(controller: _controller));
  }
}
