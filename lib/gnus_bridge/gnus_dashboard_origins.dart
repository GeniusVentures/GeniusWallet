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
