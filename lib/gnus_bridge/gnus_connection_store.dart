import 'dart:async';
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_ce/hive.dart';

/// One origin the user let use the bridge, through one transport, and when.
class GnusConnection {
  const GnusConnection({required this.origin, required this.connectedAt});

  final GnusOrigin origin;
  final DateTime connectedAt;
}

/// The origins the user connected, one JSON string per transport and origin.
/// A connection lasts until [revoke]. Reads and writes records only.
class GnusConnectionStore {
  GnusConnectionStore(this._box);

  /// The app's box, opened by `initHive`.
  factory GnusConnectionStore.app() =>
      GnusConnectionStore(Hive.box<String>(gnusConnectionsBoxName));

  final Box<String> _box;

  // Hashed: an origin can pass Hive's 255-byte key cap.
  static String _key(GnusOrigin origin) => sha256
      .convert(utf8.encode('${origin.transport.name}|${origin.value}'))
      .toString();

  /// Exact match on transport and canonical origin, so neither a look-alike
  /// nor the same origin over another transport inherits one.
  bool isConnected(GnusOrigin origin) {
    final raw = _box.get(_key(origin));
    return raw != null && _decode(raw)?.origin == origin;
  }

  Future<void> connect(GnusOrigin origin, DateTime at) => _box.put(
    _key(origin),
    jsonEncode({
      'v': 1,
      'transport': origin.transport.name,
      'origin': origin.value,
      'connectedAt': at.toUtc().toIso8601String(),
    }),
  );

  Future<void> revoke(GnusOrigin origin) => _box.delete(_key(origin));

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
      final transport = GnusTransport.values.asNameMap()[map['transport']];
      final value = map['origin'];
      final connectedAt = map['connectedAt'];
      if (transport == null || value is! String || connectedAt is! String) {
        return null;
      }
      final origin = GnusOrigin.tryParse(transport, value);
      final at = DateTime.tryParse(connectedAt);
      if (origin == null || origin.value != value || at == null) {
        return null;
      }
      return GnusConnection(origin: origin, connectedAt: at.toUtc());
    } catch (_) {
      return null;
    }
  }
}
