import 'dart:async';

import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:genius_wallet/gnus_bridge/gnus_connection_store.dart';
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';

/// The sites connected to the bridge, newest first, kept in step with the
/// store. Revoking forgets the site, so its next call asks again.
class ConnectedSitesCubit extends Cubit<List<GnusConnection>> {
  ConnectedSitesCubit(this._store) : super(_store.all()) {
    _changes = _store.changes.listen((_) => _reload());
  }

  final GnusConnectionStore _store;
  late final StreamSubscription<void> _changes;

  void _reload() {
    if (!isClosed) {
      emit(_store.all());
    }
  }

  /// Forgets [origin]. False when the store refused: the site is still
  /// connected, and the caller must say so.
  Future<bool> revoke(GnusOrigin origin) async {
    var revoked = true;
    try {
      await _store.revoke(origin);
    } catch (e) {
      debugPrint('connected sites revoke failed ${e.runtimeType}');
      revoked = false;
    }
    _reload();
    return revoked;
  }

  @override
  Future<void> close() async {
    await _changes.cancel();
    return super.close();
  }
}
