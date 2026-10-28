import 'package:genius_wallet/gnus_bridge/gnus_rpc_contract.dart';

/// How a page reached the bridge. [label] is what the user sees.
enum GnusTransport {
  webview('In-app browser'),
  walletconnect('WalletConnect');

  const GnusTransport(this.label);

  final String label;
}

// Lowercase letters, digits, dots, hyphens, and colons for IPv6. Uri.parse
// percent-encodes anything else in a host, so a '%' never gets through.
final RegExp _canonicalHost = RegExp(r'^[a-z0-9.:\-]+$');
const int _maxRawOriginLength = 2048;
const int _maxHostLength = 253;

/// A page's identity at the bridge: its transport plus its canonical origin.
/// Built only by [tryParse], so every value is canonical. Two transports that
/// claim the same origin are two different callers.
final class GnusOrigin {
  const GnusOrigin._(this.transport, this.value);

  final GnusTransport transport;

  /// `scheme://host[:port]`, lowercased, with no default port.
  final String value;

  /// The canonical origin of [raw], dropping any path, query or fragment.
  /// Null for anything that is not http or https, carries userinfo, or has
  /// no plain host.
  static GnusOrigin? tryParse(GnusTransport transport, String raw) {
    if (raw.length > _maxRawOriginLength) {
      return null;
    }
    final Uri uri;
    try {
      uri = Uri.parse(raw);
    } on FormatException {
      return null;
    }
    final scheme = uri.scheme.toLowerCase();
    final host = uri.host.toLowerCase();
    if ((scheme != 'http' && scheme != 'https') ||
        !uri.hasAuthority ||
        uri.userInfo.isNotEmpty ||
        host.length > _maxHostLength ||
        !_canonicalHost.hasMatch(host) ||
        (uri.hasPort && (uri.port < 1 || uri.port > 65535))) {
      return null;
    }
    // Uri already drops a port that is the scheme's default.
    final value = Uri(
      scheme: scheme,
      host: host,
      port: uri.hasPort ? uri.port : null,
    ).toString();
    return GnusOrigin._(transport, value);
  }

  /// [tryParse], or the contract's 4100 for an origin it cannot identify.
  static GnusOrigin parse(GnusTransport transport, String raw) =>
      tryParse(transport, raw) ??
      (throw const GnusRpcError(GnusRpcCode.unauthorized, 'Unauthorized'));

  @override
  bool operator ==(Object other) =>
      other is GnusOrigin &&
      other.transport == transport &&
      other.value == value;

  @override
  int get hashCode => Object.hash(transport, value);

  @override
  String toString() => '${transport.name} $value';
}
