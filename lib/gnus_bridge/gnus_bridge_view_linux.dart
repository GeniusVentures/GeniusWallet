import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';
import 'package:genius_wallet/web/web_overlay_gate.dart';
import 'package:webview_all/webview_all.dart';
import 'package:webview_all_linux/webview_all_linux.dart';

const String _channel = 'gnusBridge';

/// The bridge on WebKitGTK. It names no sender for a message, so the caller's
/// origin is the top-level URL tracked from page events.
class GnusBridgeViewLinux extends StatefulWidget {
  const GnusBridgeViewLinux({
    super.key,
    required this.url,
    required this.handler,
    required this.readNet,
    required this.dev,
  });

  final String url;
  final GnusRpcHandler handler;
  final Future<SgnsNet> Function() readNet;
  final bool dev;

  @override
  State<GnusBridgeViewLinux> createState() => _GnusBridgeViewLinuxState();
}

class _GnusBridgeViewLinuxState extends State<GnusBridgeViewLinux> {
  final WebViewController _controller = WebViewController();
  late final GnusWebBridge _bridge;
  String? _topUrl;
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
      // Read synchronously: the page events that move the URL arrive on the
      // same ordered channel as this message.
      onMessageReceived: (message) =>
          _bridge.onMessage(message.message, source: _topUrl),
    );
    await _controller.addUserScript(
      WebViewUserScript(source: _bridge.shimSource),
    );
    await _controller.setNavigationDelegate(
      NavigationDelegate(
        onPageStarted: (url) {
          _topUrl = url;
          _bridge.pageStarted(url);
        },
        onUrlChange: (change) => _topUrl = change.url,
      ),
    );
    await _controller.loadRequest(Uri.parse(widget.url));
    if (mounted) {
      setState(() => _ready = true);
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
