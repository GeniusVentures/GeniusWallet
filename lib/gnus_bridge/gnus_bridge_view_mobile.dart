import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_native_bridge_channel.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_flutter_android/webview_flutter_android.dart';
import 'package:webview_flutter_wkwebview/webview_flutter_wkwebview.dart';

/// The bridge on Android, iOS and macOS. It skips webview_flutter's JavaScript
/// channel, which any frame can reach, and uses the native installer instead.
/// If the installer is missing or refuses, the page is not loaded.
class GnusBridgeViewMobile extends StatefulWidget {
  const GnusBridgeViewMobile({
    super.key,
    required this.url,
    required this.handler,
    required this.readNet,
    required this.dev,
    this.onLoaded,
    this.onFailed,
    this.onNoBridge,
  });

  final String url;
  final GnusRpcHandler handler;
  final Future<SgnsNet> Function() readNet;
  final bool dev;

  /// A main-frame page finished loading.
  final VoidCallback? onLoaded;

  /// A main-frame load failed.
  final VoidCallback? onFailed;

  /// The native bridge did not install, so no page was loaded. Without this
  /// the view shows its own message.
  final VoidCallback? onNoBridge;

  @override
  State<GnusBridgeViewMobile> createState() => _GnusBridgeViewMobileState();
}

class _GnusBridgeViewMobileState extends State<GnusBridgeViewMobile> {
  final WebViewController _controller = WebViewController();
  late final GnusWebBridge _bridge;
  Set<GnusOrigin> _allowed = const {};
  int? _viewId;
  bool _ready = false;
  bool _installed = false;

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

  int? _identifier() {
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      return platform.webViewIdentifier;
    }
    if (platform is WebKitWebViewController) {
      return platform.webViewIdentifier;
    }
    return null;
  }

  Future<void> _init() async {
    await _controller.setJavaScriptMode(JavaScriptMode.unrestricted);
    try {
      _allowed = await _bridge.allowedOrigins();
    } catch (e) {
      // With no allowlist every load is refused, which is the safe failure.
      debugPrint('Bridge allowlist unavailable: ${e.runtimeType}');
    }
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onNavigationRequest: _onNavigationRequest,
        onPageStarted: _bridge.pageStarted,
        onPageFinished: (_) => widget.onLoaded?.call(),
        onWebResourceError: (error) {
          if (error.isForMainFrame ?? false) {
            widget.onFailed?.call();
          }
        },
      ),
    );
    final agent = await _controller.getUserAgent();
    if (agent != null) {
      await _controller.setUserAgent('$agent$gnusUserAgentSuffix');
    }
    _viewId = _identifier();
    final id = _viewId;
    if (id != null) {
      _installed = await GnusNativeBridgeChannel.instance.install(
        id,
        _bridge,
        _allowed,
      );
    }
    if (_installed) {
      await _controller.loadRequest(Uri.parse(widget.url));
    } else {
      widget.onNoBridge?.call();
    }
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  NavigationDecision _onNavigationRequest(NavigationRequest request) {
    final uri = Uri.tryParse(request.url);
    final frame = request.isMainFrame ? GnusFrame.main : GnusFrame.sub;
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
  void didUpdateWidget(covariant GnusBridgeViewMobile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_installed && oldWidget.url != widget.url) {
      unawaited(_controller.loadRequest(Uri.parse(widget.url)));
    }
  }

  @override
  void dispose() {
    final id = _viewId;
    if (id != null) {
      unawaited(GnusNativeBridgeChannel.instance.uninstall(id));
    }
    unawaited(_bridge.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    if (!_installed) {
      return const Center(
        child: Text('This device cannot run the bridge safely.'),
      );
    }
    return WebViewWidget(controller: _controller);
  }
}
