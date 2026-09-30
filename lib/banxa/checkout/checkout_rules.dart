import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:webview_flutter/webview_flutter.dart';

const _banxaHosts = ['banxa.com', 'banxa-sandbox.com'];

/// The API response decides what loads in the app, so only https on a Banxa
/// domain passes. The dot keeps look-alikes such as evilbanxa.com out.
bool isTrustedCheckoutUrl(Uri uri) {
  if (uri.scheme != 'https') {
    return false;
  }
  final host = uri.host;
  return _banxaHosts.any((h) => host == h || host.endsWith('.$h'));
}

/// Compares scheme, host and path, never a substring, so the return link
/// cannot be smuggled inside another URL or shown by an embedded frame.
bool isBanxaReturn(Uri? uri, {required bool isMainFrame}) {
  if (uri == null || !isMainFrame) {
    return false;
  }
  final expected = BanxaApiService.returnUri;
  return uri.scheme == expected.scheme &&
      uri.host == expected.host &&
      uri.path == expected.path;
}

/// The checkout page only ever needs the web; app links and script URLs are
/// refused.
bool allowsCheckoutNavigation(Uri? uri) {
  if (uri == null) {
    return false;
  }
  return const {'http', 'https', 'about'}.contains(uri.scheme);
}

/// [windows] is reserved for its own in-app host; until it exists Windows
/// falls back to the system browser like Linux.
enum CheckoutHostKind { webview, windows, external }

CheckoutHostKind checkoutHostKind(String operatingSystem) {
  return switch (operatingSystem) {
    'windows' || 'linux' => CheckoutHostKind.external,
    _ => CheckoutHostKind.webview,
  };
}

/// Card and ID checks use the camera and microphone; nothing else is granted.
bool checkoutPermissionAllowed(Set<WebViewPermissionResourceType> types) {
  return types.isNotEmpty &&
      types.every(
        (t) =>
            t == WebViewPermissionResourceType.camera ||
            t == WebViewPermissionResourceType.microphone,
      );
}
