// ponytail: shared pure helpers so the host / https-lock logic that
// BOTH omniboxes need is written and tested ONCE. The mobile path uses an async
// WebViewController and the Windows path a synchronous WebviewController, so the
// two omnibox *widgets* stay separate on purpose (a shared widget would need
// generic callbacks — more code than it saves). Reuse is limited to these pure
// string/int predicates, which have no controller dependency and are the only
// non-trivial edge-case logic worth a test.

/// The Web tab's home page — what `/web` opens with, what the `+` button adds,
/// and what closing the last tab resets to.
///
/// One constant because the previous literal (`https://www.duckduckgo.com`) was
/// written out at FOUR call sites across two files, so "change the home page"
/// was never a single edit. Jakub set it to gnus.ai on 2026-07-26.
const String kWebHomeUrl = 'https://gnus.ai/';

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
  if (uri == null || uri.host.isEmpty) {
    return trimmed;
  }
  return uri.host;
}

/// True only when the scheme is `https` — drives whether the omnibox paints the
/// secure lock glyph. `http`, `about:blank`, and unparseable input are false.
bool webIsSecure(String url) => Uri.tryParse(url.trim())?.scheme == 'https';

/// Whether a link may be opened: an absolute https URL with a host. Article,
/// explorer and deep-link URLs come from outside the app, so anything else
/// (file:, javascript:, http:) is refused rather than handed to a browser.
bool isOpenableWebUrl(String? url) {
  final uri = Uri.tryParse(url ?? '');
  return uri != null && uri.scheme == 'https' && uri.host.isNotEmpty;
}

/// The active tab after tab [closed] is removed from a strip that now holds
/// [newLength] tabs. A tab closed before the active one shifts it left; closing
/// the active tab hands focus to the tab that slid into its place, or to the
/// last tab when it was the last.
int tabIndexAfterClose({
  required int active,
  required int closed,
  required int newLength,
}) {
  if (closed < active) {
    return active - 1;
  }
  return active.clamp(0, newLength - 1);
}

/// Where the omnibox sends [raw]: a URL-looking entry as https unless it names
/// a scheme, anything else as a Google search. Null when the entry is empty or
/// not a parseable URL (`https://[x.com`), so the page stays as it is.
Uri? omniboxTarget(String raw) {
  var input = raw.trim();
  if (input.isEmpty) {
    return null;
  }
  final isLikelyUrl = input.contains('.') && !input.contains(' ');
  if (!isLikelyUrl) {
    return Uri.tryParse(
      'https://www.google.com/search?q=${Uri.encodeComponent(input)}',
    );
  }
  if (!input.startsWith('http://') && !input.startsWith('https://')) {
    input = 'https://$input';
  }
  return Uri.tryParse(input);
}
