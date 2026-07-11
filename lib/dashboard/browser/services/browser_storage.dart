import 'package:flutter/foundation.dart';
import 'package:genius_wallet/hive/constants/cache.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Hive-backed browser persistence: recently visited URLs (capped) and a
/// user-curated favorites list of name+url pairs. A [ChangeNotifier] so the
/// browser screen rebuilds when the data changes.
class BrowserStorage extends ChangeNotifier {
  BrowserStorage() {
    _refresh();
  }

  Box get _box => Hive.box(browserBoxName);

  List<String> _recent = const [];
  List<BrowserFavorite> _favorites = const [];

  List<String> get recent => List.unmodifiable(_recent);
  List<BrowserFavorite> get favorites => List.unmodifiable(_favorites);

  void _refresh() {
    _recent = (_box.get(browserRecentKey) as List?)
            ?.map((e) => e.toString())
            .toList() ??
        const [];
    final raw = (_box.get(browserFavoritesKey) as List?) ?? const [];
    _favorites = raw
        .whereType<Map>()
        .map((m) => BrowserFavorite.fromMap(Map<String, dynamic>.from(m)))
        .toList();
    notifyListeners();
  }

  Future<void> recordVisit(String url) async {
    final next = [url, ..._recent.where((u) => u != url)]
        .take(browserRecentLimit)
        .toList();
    await _box.put(browserRecentKey, next);
    _recent = next;
    notifyListeners();
  }

  Future<void> clearRecent() async {
    await _box.delete(browserRecentKey);
    _recent = const [];
    notifyListeners();
  }

  bool isFavorite(String url) =>
      _favorites.any((f) => _normalize(f.url) == _normalize(url));

  Future<void> toggleFavorite({required String name, required String url}) async {
    final exists = isFavorite(url);
    final next = exists
        ? _favorites
            .where((f) => _normalize(f.url) != _normalize(url))
            .toList()
        : [..._favorites, BrowserFavorite(name: name, url: url)];
    await _box.put(browserFavoritesKey, next.map((f) => f.toMap()).toList());
    _favorites = next;
    notifyListeners();
  }

  Future<void> removeFavorite(String url) async {
    final next = _favorites
        .where((f) => _normalize(f.url) != _normalize(url))
        .toList();
    await _box.put(browserFavoritesKey, next.map((f) => f.toMap()).toList());
    _favorites = next;
    notifyListeners();
  }

  String _normalize(String url) {
    var u = url.trim().toLowerCase();
    if (u.endsWith('/')) u = u.substring(0, u.length - 1);
    return u;
  }
}

class BrowserFavorite {
  const BrowserFavorite({required this.name, required this.url});
  final String name;
  final String url;

  Map<String, dynamic> toMap() => {'name': name, 'url': url};
  static BrowserFavorite fromMap(Map<String, dynamic> m) =>
      BrowserFavorite(name: (m['name'] ?? '') as String, url: (m['url'] ?? '') as String);
}
