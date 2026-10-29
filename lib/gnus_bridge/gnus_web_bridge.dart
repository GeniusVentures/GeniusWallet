import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/foundation.dart' show debugPrint, visibleForTesting;
import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_dashboard_origins.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';
import 'package:genius_wallet/gnus_bridge/gnus_rpc_handler.dart';

/// Appended to a bridge view's default user agent, so a page knows it is in
/// the wallet before `window.gnus` arrives.
const String gnusUserAgentSuffix =
    ' GeniusWallet/${String.fromEnvironment('FLUTTER_BUILD_NAME')} '
    'gnus/$kGnusRpcVersion';

const int _maxRequestIdLength = 64;

/// One web view's side of the bridge, the same on every platform. The view
/// injects [shimSource], forwards page commits and `(message, source)` pairs,
/// and runs the scripts handed to `deliver`.
class GnusWebBridge {
  GnusWebBridge({
    required GnusRpcHandler handler,
    required Future<SgnsNet> Function() readNet,
    required Future<void> Function(String script) deliver,
    required bool dev,
    Random? random,
  }) : _handler = handler,
       _readNet = readNet,
       _deliver = deliver,
       _dev = dev,
       _secret = _newSecret(random ?? Random.secure()) {
    shimSource = _shimTemplate
        .replaceFirst('__SECRET__', jsonEncode(_secret))
        .replaceFirst('__VERSION__', jsonEncode(kGnusRpcVersion));
  }

  final GnusRpcHandler _handler;
  final Future<SgnsNet> Function() _readNet;
  final Future<void> Function(String script) _deliver;
  final bool _dev;
  final String _secret;

  /// The script to inject at document start in the top frame only.
  late final String shimSource;

  GnusOrigin? _topOrigin;

  // Bumped when a new main-frame document commits, not when a navigation
  // starts: a download or a blocked redirect starts one and leaves the page.
  // A request holds the number it began under; its answer is dropped if the
  // page has moved on.
  int _generation = 0;

  static String _newSecret(Random random) {
    final bytes = [for (var i = 0; i < 16; i++) random.nextInt(256)];
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  StreamSubscription<GnusEvent>? _events;
  bool _disposed = false;

  /// The origins this session accepts a caller from.
  Future<Set<GnusOrigin>> allowedOrigins() async =>
      gnusAllowedOrigins(await _readNet(), dev: _dev);

  /// A new main-frame document committed at [url]. Events for the previous
  /// page stop, and an allowlisted page gets the events of its own origin.
  void pageCommitted(String? url) {
    if (_disposed) {
      return;
    }
    _generation++;
    unawaited(_events?.cancel());
    _events = null;
    final origin = url == null
        ? null
        : GnusOrigin.tryParse(GnusTransport.webview, url);
    _topOrigin = origin;
    if (origin != null) {
      unawaited(_subscribe(origin, _generation));
    }
  }

  Future<void> _subscribe(GnusOrigin origin, int generation) async {
    try {
      final allowed = await allowedOrigins();
      if (generation != _generation || !allowed.contains(origin)) {
        return;
      }
      _events = _handler
          .eventsFor(origin)
          .listen((event) => _forward(origin, generation, event));
    } catch (e) {
      debugPrint('gnus_web events unavailable ${e.runtimeType}');
    }
  }

  void _forward(GnusOrigin origin, int generation, GnusEvent event) {
    if (generation != _generation) {
      debugPrint('gnus_web event dropped ${origin.value}');
      return;
    }
    final call =
        '__gnusBridgeEvent(${jsonEncode(event.name)}, '
        '${jsonEncode(event.payload)})';
    unawaited(_run(call, origin));
  }

  /// Stops all delivery. The view calls this when it goes away.
  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    await _events?.cancel();
    _events = null;
  }

  /// One message from the page. [source] is the origin the platform names as
  /// the sender, or the committed top-level URL on a platform that names none.
  /// A null [source] is a page nobody can vouch for, and is dropped unanswered.
  /// The payload is never trusted for who is calling.
  Future<void> onMessage(String raw, {required String? source}) async {
    // A message queued as the view closed must not open a prompt.
    if (_disposed || source == null) {
      return;
    }
    final generation = _generation;
    final prefix = '$_secret:';
    if (!raw.startsWith(prefix)) {
      return;
    }
    final request = _decode(raw.substring(prefix.length));
    if (request == null) {
      return;
    }
    final origin = GnusOrigin.tryParse(GnusTransport.webview, source);
    final guard = origin ?? _topOrigin;
    if (guard == null) {
      return;
    }
    try {
      final result = await _answer(request, origin, generation);
      await _send(guard, generation, {'id': request.id, 'result': result});
    } on _Stale {
      debugPrint('gnus_web reply dropped ${guard.value}');
    } on GnusRpcError catch (e) {
      await _send(guard, generation, {'id': request.id, 'error': e.toJson()});
    } catch (e) {
      debugPrint('gnus_web request failed ${e.runtimeType}');
      await _send(guard, generation, {
        'id': request.id,
        'error': const GnusRpcError(
          GnusRpcCode.internal,
          'Internal error',
        ).toJson(),
      });
    }
  }

  Future<Object?> _answer(
    _Request request,
    GnusOrigin? origin,
    int generation,
  ) async {
    if (origin == null) {
      throw const GnusRpcError(GnusRpcCode.unauthorized, 'Unauthorized');
    }
    final allowed = gnusAllowedOrigins(await _readNet(), dev: _dev);
    if (!allowed.contains(origin)) {
      throw const GnusRpcError(GnusRpcCode.unauthorized, 'Unauthorized');
    }
    // The page that asked is gone: do not open a prompt for it.
    if (generation != _generation) {
      throw const _Stale();
    }
    return _handler.handle(origin, request.method, request.params);
  }

  Future<void> _send(
    GnusOrigin origin,
    int generation,
    Map<String, Object?> reply,
  ) {
    if (generation != _generation) {
      debugPrint('gnus_web reply dropped ${origin.value}');
      return Future<void>.value();
    }
    return _run('__gnusBridgeReply(${jsonEncode(reply)})', origin);
  }

  /// Runs [call] only if the document that executes it is on [origin].
  Future<void> _run(String call, GnusOrigin origin) async {
    final script =
        'if (location.origin === ${jsonEncode(origin.value)}) window.$call;';
    try {
      await _deliver(script);
    } catch (e) {
      debugPrint('gnus_web deliver failed ${e.runtimeType}');
    }
  }

  static _Request? _decode(String body) {
    final Object? decoded;
    try {
      decoded = jsonDecode(body);
    } on FormatException {
      return null;
    }
    if (decoded is! Map<String, Object?>) {
      return null;
    }
    final id = decoded['id'];
    final method = decoded['method'];
    if (id is! String ||
        id.isEmpty ||
        id.length > _maxRequestIdLength ||
        method is! String) {
      return null;
    }
    return _Request(id, method, decoded['params']);
  }

  @visibleForTesting
  String get secretForTest => _secret;
}

class _Stale implements Exception {
  const _Stale();
}

class _Request {
  const _Request(this.id, this.method, this.params);

  final String id;
  final String method;
  final Object? params;
}

// Binds the native post function and captures JSON.stringify before any page
// script runs, so a later script cannot read the secret or reroute messages.
// The secret lasts for the view. Runs only in the top frame: a frame has no
// window.gnus and cannot use the secret.
const String _shimTemplate = r'''
(function () {
  'use strict';
  if (window.top !== window || window.gnus) {
    return;
  }
  var secret = __SECRET__;
  var stringify = JSON.stringify;
  var host = null;
  if (window.chrome && window.chrome.webview) {
    host = window.chrome.webview;
  } else if (window.webkit && window.webkit.messageHandlers &&
      window.webkit.messageHandlers.gnusBridge) {
    host = window.webkit.messageHandlers.gnusBridge;
  } else if (window.gnusBridge) {
    host = window.gnusBridge;
  }
  // Bound now: a page that later replaces postMessage on the host or its
  // prototype never sees a message.
  var post = host && typeof host.postMessage === 'function'
    ? host.postMessage.bind(host)
    : null;
  var pending = {};
  var listeners = {};
  var nextId = 1;
  var docId = '';
  var bytes = new Uint8Array(8);
  if (window.crypto && window.crypto.getRandomValues) {
    window.crypto.getRandomValues(bytes);
  } else {
    for (var i = 0; i < bytes.length; i++) { bytes[i] = Math.floor(Math.random() * 256); }
  }
  for (var j = 0; j < bytes.length; j++) { docId += (bytes[j] < 16 ? '0' : '') + bytes[j].toString(16); }
  function fail(code, message, data) {
    var e = new Error(message);
    e.code = code;
    if (data !== undefined) {
      e.data = data;
    }
    return e;
  }
  function hide(name, value) {
    Object.defineProperty(window, name, { value: value });
  }
  hide('__gnusBridgeReply', function (r) {
    var p = pending[r.id];
    if (!p) {
      return;
    }
    delete pending[r.id];
    if (r.error) {
      p.reject(fail(r.error.code, r.error.message, r.error.data));
    } else {
      p.resolve(r.result);
    }
  });
  hide('__gnusBridgeEvent', function (name, payload) {
    var list = listeners[name];
    if (!list) {
      return;
    }
    list.slice().forEach(function (fn) {
      try { fn(payload); } catch (err) { /* a listener must not break the others */ }
    });
  });
  var api = Object.freeze({
    isGeniusWallet: true,
    version: __VERSION__,
    request: function (args) {
      return new Promise(function (resolve, reject) {
        if (!args || typeof args.method !== 'string') {
          reject(fail(-32600, 'Invalid request'));
          return;
        }
        if (!post) {
          reject(fail(-32603, 'Internal error'));
          return;
        }
        var id = docId + '-' + (nextId++);
        pending[id] = { resolve: resolve, reject: reject };
        try {
          post(
            secret + ':' + stringify({
              id: id,
              method: args.method,
              params: args.params === undefined ? null : args.params
            }));
        } catch (err) {
          delete pending[id];
          reject(fail(-32603, 'Internal error'));
        }
      });
    },
    on: function (name, fn) {
      if (typeof fn !== 'function') {
        return;
      }
      (listeners[name] = listeners[name] || []).push(fn);
    },
    removeListener: function (name, fn) {
      var list = listeners[name];
      if (!list) {
        return;
      }
      var at = list.indexOf(fn);
      if (at >= 0) {
        list.splice(at, 1);
      }
    }
  });
  Object.defineProperty(window, 'gnus', { value: api, enumerable: true });
  window.dispatchEvent(new Event('gnus#initialized'));
})();
''';
