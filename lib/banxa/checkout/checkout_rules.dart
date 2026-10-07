import 'package:file_picker/file_picker.dart';
import 'package:genius_wallet/banxa/banxa_api_services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:webview_windows/webview_windows.dart'
    show WebviewPermissionDecision, WebviewPermissionKind;

const _banxaHosts = ['banxa.com', 'banxa-sandbox.com'];

// Dart keeps percent escapes and control characters in a host, which a
// webview parses differently, so only plain DNS characters are trusted.
final _plainHost = RegExp(r'^[a-z0-9.-]+$');

/// The API response decides what loads in the app, so only https on a Banxa
/// domain passes. The dot keeps look-alikes such as evilbanxa.com out.
bool isTrustedCheckoutUrl(Uri uri) {
  if (uri.scheme != 'https') {
    return false;
  }
  final host = uri.host;
  if (!_plainHost.hasMatch(host)) {
    return false;
  }
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

/// Card entry and ID capture share this view, so cleartext http, app links and
/// script URLs are refused.
bool allowsCheckoutNavigation(Uri? uri) {
  if (uri == null) {
    return false;
  }
  return const {'https', 'about'}.contains(uri.scheme);
}

/// Linux has no embeddable webview, so it hands checkout to the system browser.
enum CheckoutHostKind { webview, windows, external }

CheckoutHostKind checkoutHostKind(String operatingSystem) {
  return switch (operatingSystem) {
    'windows' => CheckoutHostKind.windows,
    'linux' => CheckoutHostKind.external,
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

/// The web page cannot reach the camera on its own on Android: the app must
/// hold the OS permission for whatever the page asked for, and nothing more.
Set<Permission> androidPermissionsFor(
  Set<WebViewPermissionResourceType> types,
) {
  return {
    if (types.contains(WebViewPermissionResourceType.camera)) Permission.camera,
    if (types.contains(WebViewPermissionResourceType.microphone))
      Permission.microphone,
  };
}

/// WebView2 names the page that asks, so the grant needs a Banxa page as well
/// as camera or microphone.
WebviewPermissionDecision windowsCheckoutPermission(
  WebviewPermissionKind kind, {
  required String url,
}) {
  final uri = Uri.tryParse(url);
  final trusted = uri != null && isTrustedCheckoutUrl(uri);
  final wanted =
      kind == WebviewPermissionKind.camera ||
      kind == WebviewPermissionKind.microphone;
  return trusted && wanted
      ? WebviewPermissionDecision.allow
      : WebviewPermissionDecision.deny;
}

/// Android and iOS copy a picked ID photo into the app cache; this removes it
/// once checkout is done. Desktop pickers hand back the original file, so
/// nothing is cleared there.
Future<void> clearPickedIdFiles(
  String operatingSystem, {
  Future<bool?> Function() clear = FilePicker.clearTemporaryFiles,
}) async {
  if (operatingSystem != 'android' && operatingSystem != 'ios') {
    return;
  }
  try {
    await clear();
  } catch (_) {
    // Cleanup only; the OS empties the cache in time.
  }
}
