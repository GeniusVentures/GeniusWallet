import 'dart:convert';
import 'package:http/http.dart' as http;
import 'token_model.g.dart';

/// Loads SuperGeniusTokenInfo data from GitHub
class TokenInfoLoader {
  static const String _defaultTokensUrl =
      'https://raw.githubusercontent.com/GeniusVentures/tokeninfo/main/tokens.json';

  final String tokensUrl;
  final http.Client _httpClient;

  TokenInfoLoader({
    this.tokensUrl = _defaultTokensUrl,
    http.Client? httpClient,
  }) : _httpClient = httpClient ?? http.Client();

  /// Load the first token from the GitHub URL (for backward compatibility)
  /// Returns null if loading fails or array is empty
  Future<SuperGeniusTokenInfo?> loadToken() async {
    try {
      final tokens = await loadTokens();
      return tokens.isNotEmpty ? tokens.first : null;
    } catch (e) {
      // Return null on any error to allow graceful fallback
      print('Error loading token from $tokensUrl: $e');
      return null;
    }
  }

  /// Load all tokens from the JSON array
  /// Returns empty list if loading fails
  Future<List<SuperGeniusTokenInfo>> loadTokens() async {
    try {
      final response = await _httpClient.get(Uri.parse(tokensUrl));

      if (response.statusCode != 200) {
        throw Exception('Failed to load tokens: HTTP ${response.statusCode}');
      }

      final dynamic json = jsonDecode(response.body);

      // Handle both single object and array of objects
      if (json is List) {
        return json
            .map((item) =>
                SuperGeniusTokenInfo.fromJson(item as Map<String, dynamic>))
            .toList();
      } else if (json is Map<String, dynamic>) {
        return [SuperGeniusTokenInfo.fromJson(json)];
      }

      return [];
    } catch (e) {
      print('Error loading tokens from $tokensUrl: $e');
      return [];
    }
  }

  /// Load tokens with caching support
  /// Uses the provided cache duration to avoid repeated network calls
  Future<List<SuperGeniusTokenInfo>> loadTokensWithCache({
    Duration cacheDuration = const Duration(hours: 1),
    List<SuperGeniusTokenInfo>? cachedTokens,
    DateTime? lastFetch,
  }) async {
    // Check if cache is still valid
    if (cachedTokens != null &&
        lastFetch != null &&
        DateTime.now().difference(lastFetch) < cacheDuration) {
      return cachedTokens;
    }

    // Otherwise fetch fresh data
    return loadTokens();
  }

  /// Dispose of resources
  void dispose() {
    // Only dispose if we created the client
    if (_httpClient is http.Client && tokensUrl == _defaultTokensUrl) {
      _httpClient.close();
    }
  }
}

/// Extension to make it easier to use in the app
extension TokenInfoLoaderExtension on TokenInfoLoader {
  /// Load token by ID from a list
  Future<SuperGeniusTokenInfo?> loadTokenById(String id) async {
    final tokens = await loadTokens();
    try {
      return tokens.firstWhere((token) => token.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Load GNUS token specifically
  Future<SuperGeniusTokenInfo?> loadGNUSToken() async {
    return loadTokenById(
        '0000000000000000000000000000000000000000000000000000000000000000');
  }
}
