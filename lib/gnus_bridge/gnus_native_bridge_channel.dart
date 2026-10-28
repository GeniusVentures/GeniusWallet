import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_web_bridge.dart';

/// The Dart end of the native installer that Android, iOS and macOS share:
/// `install` and `uninstall` go out, `message` comes in with the sender's
/// origin as the platform names it.
class GnusNativeBridgeChannel {
  GnusNativeBridgeChannel({
    MethodChannel channel = const MethodChannel(
      'ai.gnus.genius_wallet/gnus_bridge',
    ),
  }) : _channel = channel {
    _channel.setMethodCallHandler(_onCall);
  }

  /// The one channel the app uses.
  static final GnusNativeBridgeChannel instance = GnusNativeBridgeChannel();

  final MethodChannel _channel;
  final Map<int, GnusWebBridge> _sessions = {};

  /// Installs the shim on the web view [webViewId]. False means this platform
  /// cannot do it safely, and the page gets no bridge.
  Future<bool> install(
    int webViewId,
    GnusWebBridge session,
    Set<GnusOrigin> allowed,
  ) async {
    _sessions[webViewId] = session;
    var installed = false;
    try {
      installed =
          await _channel.invokeMethod<bool>('install', {
            'webViewId': webViewId,
            'origins': [for (final origin in allowed) origin.value],
            'shim': session.shimSource,
          }) ??
          false;
    } on PlatformException catch (e) {
      debugPrint('gnus native install failed ${e.code}');
    } on MissingPluginException {
      debugPrint('gnus native installer missing');
    }
    if (!installed) {
      _sessions.remove(webViewId);
    }
    return installed;
  }

  Future<void> uninstall(int webViewId) async {
    _sessions.remove(webViewId);
    try {
      await _channel.invokeMethod<void>('uninstall', {'webViewId': webViewId});
    } on PlatformException {
      // The view is already gone.
    } on MissingPluginException {
      // No installer on this platform.
    }
  }

  Future<Object?> _onCall(MethodCall call) async {
    final args = call.arguments;
    if (call.method != 'message' || args is! Map) {
      return null;
    }
    final id = args['webViewId'];
    final message = args['message'];
    final source = args['source'];
    if (id is! int || message is! String || source is! String) {
      return null;
    }
    unawaited(_sessions[id]?.onMessage(message, source: source));
    return null;
  }
}
