// ponytail: shared pure helpers so the host / https-lock / last-tab logic that
// BOTH omniboxes need is written and tested ONCE. The mobile path uses an async
// WebViewController and the Windows path a synchronous WebviewController, so the
// two omnibox *widgets* stay separate on purpose (a shared widget would need
// generic callbacks — more code than it saves). Reuse is limited to these pure
// string/int predicates, which have no controller dependency and are the only
// non-trivial edge-case logic worth a test.

/// The host shown in the omnibox at rest, e.g. `app.uniswap.org`.
///
/// Returns the trimmed raw input unchanged when the URL has no parseable host
/// (`about:blank`, or a half-typed string), so the field never blanks out and
/// never throws. `Uri.tryParse` rejects a raw space (an un-encoded search query
/// still sitting in the path), so we retry on the pre-query slice before giving
/// up — that recovers the host from `.../search?q=eth price`.
String webDisplayHost(String url) {
  final trimmed = url.trim();
  var uri = Uri.tryParse(trimmed);
  if (uri == null || uri.host.isEmpty) {
    final beforeQuery = trimmed.split(RegExp(r'[?#]')).first;
    uri = Uri.tryParse(beforeQuery);
  }
  if (uri == null || uri.host.isEmpty) return trimmed;
  return uri.host;
}

/// True only when the scheme is `https` — drives whether the omnibox paints the
/// secure lock glyph. `http`, `about:blank`, and unparseable input are false.
bool webIsSecure(String url) => Uri.tryParse(url.trim())?.scheme == 'https';

/// The last-tab-locked rule (mirrors the `_controllers.length == 1` guard in
/// `_closeTab`): the final tab cannot be closed, so its close affordance reads
/// disabled/absent. Extracted so the rule is testable without a live
/// WebViewController.
bool webTabCanClose(int tabCount) => tabCount > 1;
