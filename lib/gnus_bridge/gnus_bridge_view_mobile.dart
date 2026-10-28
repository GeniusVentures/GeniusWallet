import 'dart:async';

import 'package:file_picker/file_picker.dart';
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

/// The file extensions an input's `accept` list names (`.json`), lowercased and
/// without the dot. Null when it names none, which means any file.
List<String>? gnusPickerExtensions(List<String> accept) {
  final extensions = {
    for (final entry in accept)
      if (entry.trim().startsWith('.') && entry.trim().length > 1)
        entry.trim().substring(1).toLowerCase(),
  };
  return extensions.isEmpty ? null : extensions.toList();
}

/// Whether the page at [topUrl] may open the file picker: only an allowlisted
/// origin, never a blank or unknown page.
bool gnusPickerAllowed(String? topUrl, Set<GnusOrigin> allowed) {
  final origin = topUrl == null
      ? null
      : GnusOrigin.tryParse(GnusTransport.webview, topUrl);
  return origin != null && allowed.contains(origin);
}

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
  bool _canGoBack = false;
  String? _topUrl;

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
        // ponytail: Android raises this when the navigation commits, but
        // WKWebView at its provisional start, so there a navigation that never
        // commits (a download) still drops replies. Upgrade: a didCommit
        // signal from the native installer.
        onPageStarted: (url) {
          _topUrl = url;
          _bridge.pageCommitted(url);
        },
        // In-page links are same-document navigations, so the history is
        // read again on every URL change, not only on page loads.
        onUrlChange: (change) {
          _topUrl = change.url;
          unawaited(_syncCanGoBack());
        },
        onPageFinished: (_) {
          unawaited(_syncCanGoBack());
          widget.onLoaded?.call();
        },
        onWebResourceError: (error) {
          final blocked = gnusLoadWasBlocked(
            domain: error is WebKitWebResourceError ? error.domain : null,
            code: error.errorCode,
          );
          if ((error.isForMainFrame ?? false) && !blocked) {
            widget.onFailed?.call();
          }
        },
      ),
    );
    final agent = await _controller.getUserAgent();
    if (agent != null) {
      await _controller.setUserAgent('$agent$gnusUserAgentSuffix');
    }
    final platform = _controller.platform;
    if (platform is AndroidWebViewController) {
      await platform.setOnShowFileSelector(_pickFiles);
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

  // A job definition is not sensitive, so the picked files are not cleaned up.
  Future<List<String>> _pickFiles(FileSelectorParams params) async {
    if (!gnusPickerAllowed(_topUrl, _allowed)) {
      return const [];
    }
    final extensions = gnusPickerExtensions(params.acceptTypes);
    final result = await FilePicker.pickFiles(
      type: extensions == null ? FileType.any : FileType.custom,
      allowedExtensions: extensions,
      allowMultiple: params.mode == FileSelectorMode.openMultiple,
    );
    if (result == null) {
      return const [];
    }
    return [
      for (final file in result.files)
        if (file.path != null) Uri.file(file.path!).toString(),
    ];
  }

  Future<void> _syncCanGoBack() async {
    final can = await _controller.canGoBack();
    if (mounted && can != _canGoBack) {
      setState(() => _canGoBack = can);
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
    // System back steps through the page's own history first, and leaves the
    // screen only when there is none.
    return PopScope(
      canPop: !_canGoBack,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) {
          unawaited(_controller.goBack());
        }
      },
      child: WebViewWidget(controller: _controller),
    );
  }
}
