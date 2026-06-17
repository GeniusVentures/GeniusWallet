import 'dart:convert';

/// Schema for an array of child tokens of the GNUS.ai SuperGenius network.
class SuperGeniusTokenInfo {
  /// URL to the token's image/icon.
  String iconUrl;

  /// Unique 256-bit identifier represented as a hexadecimal string.
  String id;

  /// Name of the token.
  String name;

  SuperGeniusTokenInfo({
    required this.iconUrl,
    required this.id,
    required this.name,
  });

  factory SuperGeniusTokenInfo.fromRawJson(String str) =>
      SuperGeniusTokenInfo.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  factory SuperGeniusTokenInfo.fromJson(Map<String, dynamic> json) =>
      SuperGeniusTokenInfo(
        iconUrl: json["iconUrl"],
        id: json["id"],
        name: json["name"],
      );

  Map<String, dynamic> toJson() => {"iconUrl": iconUrl, "id": id, "name": name};
}
