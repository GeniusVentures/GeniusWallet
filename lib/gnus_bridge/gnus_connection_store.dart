import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:hive_ce/hive.dart';

/// One origin the user let use the bridge, and when.
class GnusConnection {
  const GnusConnection({required this.origin, required this.connectedAt});

  final String origin;
  final DateTime connectedAt;
}

/// The origins the user connected, one JSON string per origin. A connection
/// lasts until [revoke]. Reads and writes records only.
class GnusConnectionStore {
  GnusConnectionStore(this._box);

  final Box<String> _box;

  // Hashed: an origin can pass Hive's 255-byte key cap.
  static String _key(String origin) =>
      sha256.convert(utf8.encode(origin)).toString();

  /// Exact match on the whole origin, so a look-alike never inherits one.
  bool isConnected(String origin) {
    final raw = _box.get(_key(origin));
    return raw != null && _decode(raw)?.origin == origin;
  }

  Future<void> connect(String origin, DateTime at) => _box.put(
    _key(origin),
    jsonEncode({
      'v': 1,
      'origin': origin,
      'connectedAt': at.toUtc().toIso8601String(),
    }),
  );

  Future<void> revoke(String origin) => _box.delete(_key(origin));

  /// Newest first. A value that cannot be read is skipped.
  List<GnusConnection> all() {
    return [for (final raw in _box.values) ?_decode(raw)]
      ..sort((a, b) => b.connectedAt.compareTo(a.connectedAt));
  }

  /// Fires after every connect or revoke.
  Stream<void> get changes => _box.watch().map<void>((_) {});

  static GnusConnection? _decode(String raw) {
    try {
      final map = jsonDecode(raw);
      if (map is! Map) {
        return null;
      }
      final origin = map['origin'];
      final connectedAt = map['connectedAt'];
      if (origin is! String || connectedAt is! String) {
        return null;
      }
      final at = DateTime.tryParse(connectedAt);
      if (at == null) {
        return null;
      }
      return GnusConnection(origin: origin, connectedAt: at.toUtc());
    } catch (_) {
      return null;
    }
  }
}
