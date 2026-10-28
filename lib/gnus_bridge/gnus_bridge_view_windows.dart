import 'dart:async';

import 'package:flutter/material.dart';
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';
import 'package:genius_wallet/web/windows_webview_shutdown.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_windows/webview_windows.dart' as win;

/// The bridge on WebView2. The plugin reports the sender WebView2 names for
/// each message, so the caller's origin never comes from the top-level URL.
class GnusBridgeViewWindows extends StatefulWidget {
  const GnusBridgeViewWindows({
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

  /// The top document finished loading.
  final VoidCallback? onLoaded;

  /// A load failed. A redirect that cancels the load it replaces is not one.
  final VoidCallback? onFailed;

  /// WebView2 could not start, or no allowlist could be read. Without this
  /// the error is rethrown.
  final VoidCallback? onNoBridge;

  @override
  State<GnusBridgeViewWindows> createState() => _GnusBridgeViewWindowsState();
}

class _GnusBridgeViewWindowsState extends State<GnusBridgeViewWindows> {
  final win.WebviewController _controller = win.WebviewController();
  final List<StreamSubscription<dynamic>> _subs = [];
  late final GnusWebBridge _bridge;
  Set<GnusOrigin> _allowed = const {};
  String? _topUrl;
  bool _ready = false;
  bool _disposed = false;

  @override
  void initState() {
    super.initState();
    _bridge = GnusWebBridge(
      handler: widget.handler,
      readNet: widget.readNet,
      deliver: _controller.executeScript,
      dev: widget.dev,
    );
    WindowsWebViewShutdown.instance.register(_disposeController);
    unawaited(
      _init().catchError((Object e, StackTrace stack) {
        final report = widget.onNoBridge;
        if (report == null) {
          Error.throwWithStackTrace(e, stack);
        }
        debugPrint('Bridge web view unavailable: ${e.runtimeType}');
        report();
      }),
    );
  }

  Future<void> _init() async {
    await _controller.initialize();
    try {
      _allowed = await _bridge.allowedOrigins();
    } catch (e) {
      debugPrint('Bridge allowlist unavailable: ${e.runtimeType}');
    }
    // The native lock reads an empty list as no limit at all, so with no list
    // there is no page.
    if (_allowed.isEmpty) {
      throw StateError('No bridge allowlist');
    }
    await _controller.setPopupWindowPolicy(win.WebviewPopupWindowPolicy.deny);
    await _controller.addScriptToExecuteOnDocumentCreated(_bridge.shimSource);
    await _controller.setTopLevelAllowlist([
      for (final origin in _allowed) origin.value,
    ]);
    final agent = await _controller.getUserAgent();
    if (agent != null) {
      await _controller.setUserAgent('$agent$gnusUserAgentSuffix');
    }
    _subs
      ..add(_controller.url.listen((url) => _topUrl = url))
      // ContentLoading is raised once the new document has committed; the
      // reply and event scripts also check the origin inside the page, which
      // covers the gap before it.
      ..add(
        _controller.loadingState.listen((state) {
          if (state == win.LoadingState.loading) {
            _bridge.pageCommitted(_topUrl);
          } else if (state == win.LoadingState.navigationCompleted) {
            widget.onLoaded?.call();
          }
        }),
      )
      ..add(
        _controller.onLoadError.listen((status) {
          if (status != win.WebErrorStatus.WebErrorStatusOperationCanceled) {
            widget.onFailed?.call();
          }
        }),
      )
      ..add(_controller.webMessageWithSource.listen(_onMessage))
      ..add(_controller.navigationBlocked.listen(_onBlocked))
      ..add(_controller.newWindowRequested.listen(_onNewWindow));
    await _controller.loadUrl(widget.url);
    if (mounted) {
      setState(() => _ready = true);
    }
  }

  void _onMessage(win.WebMessageFromSource event) {
    final message = event.message;
    if (message is String) {
      unawaited(_bridge.onMessage(message, source: event.source));
    }
  }

  void _onBlocked(String uri) => _open(uri, GnusFrame.main);

  void _onNewWindow(String uri) => _open(uri, GnusFrame.newWindow);

  void _open(String uri, GnusFrame frame) {
    final target = Uri.tryParse(uri);
    final decision = gnusNavigation(
      url: target,
      frame: frame,
      allowed: _allowed,
    );
    if (decision == GnusNavigation.external) {
      unawaited(launchUrl(target!, mode: LaunchMode.externalApplication));
    }
  }

  @override
  void didUpdateWidget(covariant GnusBridgeViewWindows oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready && oldWidget.url != widget.url) {
      unawaited(_controller.loadUrl(widget.url));
    }
  }

  Future<void> _disposeController() async {
    if (_disposed) {
      return;
    }
    _disposed = true;
    WindowsWebViewShutdown.instance.unregister(_disposeController);
    await _bridge.dispose();
    for (final subscription in _subs) {
      await subscription.cancel();
    }
    await _controller.dispose();
  }

  @override
  void dispose() {
    unawaited(_disposeController());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) {
      return const Center(child: CircularProgressIndicator());
    }
    return win.Webview(_controller);
  }
}
