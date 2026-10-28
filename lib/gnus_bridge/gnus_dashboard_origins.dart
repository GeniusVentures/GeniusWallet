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

bool _isBlankPage(Uri url) =>
    url.scheme == 'about' && (url.path == 'blank' || url.path == 'srcdoc');
