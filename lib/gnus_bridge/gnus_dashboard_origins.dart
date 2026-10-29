import 'package:genius_api/genius_api.dart' show SgnsNet;
import 'package:genius_wallet/gnus_bridge/gnus_origin.dart';

/// The dashboard origin that may use `window.gnus` on [net] in a release build.
String gnusDashboardOrigin(SgnsNet net) => switch (net) {
  // ponytail: the Cloudflare Pages URL does not exist yet. `.invalid` never
  // resolves, so nobody can claim it; swap in the real origin when it ships.
  SgnsNet.staging => 'https://gnus-dashboard-staging.invalid',
};

/// The dev dashboard origin when no define overrides it.
const String kGnusDashboardDevOrigin = String.fromEnvironment(
  'GNUS_DASHBOARD_DEV_ORIGIN',
  defaultValue: 'http://localhost:3000',
);

/// The origins allowed to call the bridge. [dev] adds one `http://localhost`
/// origin from [devOrigin]; anything else in that slot is ignored.
Set<GnusOrigin> gnusAllowedOrigins(
  SgnsNet net, {
  required bool dev,
  String devOrigin = kGnusDashboardDevOrigin,
}) {
  final pinned = GnusOrigin.tryParse(
    GnusTransport.webview,
    gnusDashboardOrigin(net),
  );
  final local = dev ? _localhostOrigin(devOrigin) : null;
  return {?pinned, ?local};
}

/// Where the in-wallet dashboard starts: the origin root. A dev build opens
/// the dev origin unless [hosted] asks for the pinned one.
Uri gnusDashboardStart(
  SgnsNet net, {
  required bool dev,
  bool hosted = false,
  String devOrigin = kGnusDashboardDevOrigin,
}) {
  final local = dev && !hosted ? _localhostOrigin(devOrigin) : null;
  return Uri.parse(local?.value ?? gnusDashboardOrigin(net)).replace(path: '/');
}

/// Whether the wallet offers the dashboard entry. A release build waits for a
/// real pinned origin.
// ponytail: one network today, so one placeholder hides the entry everywhere;
// list per network once a second SgnsNet exists.
bool gnusDashboardListed({required bool dev}) =>
    dev ||
    SgnsNet.values.every(
      (net) => !Uri.parse(gnusDashboardOrigin(net)).host.endsWith('.invalid'),
    );

GnusOrigin? _localhostOrigin(String raw) {
  final origin = GnusOrigin.tryParse(GnusTransport.webview, raw);
  if (origin == null) {
    return null;
  }
  final uri = Uri.parse(origin.value);
  return uri.scheme == 'http' && uri.host == 'localhost' ? origin : null;
}

/// Where a navigation happens. Linux names no frame, so it is [unknown].
enum GnusFrame { main, sub, unknown, newWindow }

enum GnusNavigation { allow, block, external }

/// What a bridge view does with a navigation to [url]: load it, drop it, or
/// hand it to the system browser. Only http(s) ever leaves the app.
GnusNavigation gnusNavigation({
  required Uri? url,
  required GnusFrame frame,
  required Set<GnusOrigin> allowed,
}) {
  if (url == null) {
    return GnusNavigation.block;
  }
  final web =
      (url.scheme == 'http' || url.scheme == 'https') && url.host.isNotEmpty;
  final onList =
      web &&
      allowed.contains(GnusOrigin.tryParse(GnusTransport.webview, '$url'));
  final outside = web ? GnusNavigation.external : GnusNavigation.block;
  return switch (frame) {
    // The frame cannot reach the bridge, so it needs no lock.
    GnusFrame.sub => GnusNavigation.allow,
    GnusFrame.main => onList ? GnusNavigation.allow : outside,
    GnusFrame.newWindow => outside,
    // A frame-blind platform: an off-list load is blocked wherever it is, and
    // nothing opens externally because it may be a subframe.
    GnusFrame.unknown =>
      onList || _isBlankPage(url) ? GnusNavigation.allow : GnusNavigation.block,
  };
}

/// Whether a main-frame load error is only the web view reporting a load we
/// stopped ourselves, such as a blocked redirect. [domain] is null where the
/// platform names none, which is never a stopped load.
bool gnusLoadWasBlocked({required String? domain, required int code}) =>
    switch (domain) {
      // NSURLErrorCancelled, and WebKit's "frame load interrupted by policy
      // change" (102), the two ways WKWebView reports a refused navigation.
      'NSURLErrorDomain' => code == -999,
      'WebKitErrorDomain' => code == 102,
      _ => false,
    };

bool _isBlankPage(Uri url) =>
    url.scheme == 'about' && (url.path == 'blank' || url.path == 'srcdoc');
