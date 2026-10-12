// ponytail: shared pure helpers so the host / https-lock logic that
// BOTH omniboxes need is written and tested ONCE. The mobile path uses an async
// WebViewController and the Windows path a synchronous WebviewController, so the
// two omnibox *widgets* stay separate on purpose (a shared widget would need
// generic callbacks — more code than it saves). Reuse is limited to these pure
// string/int predicates, which have no controller dependency and are the only
// non-trivial edge-case logic worth a test.

/// The Web tab's home page: what `/web` opens, what `+` adds, and what closing
/// the last tab resets to. One constant so changing it is a single edit.
const String kWebHomeUrl = 'https://gnus.ai/';

/// The host shown in the omnibox at rest, e.g. `app.uniswap.org`. Falls back to
/// the trimmed input when there is no host, and retries on the pre-query slice
/// because `Uri.tryParse` rejects an un-encoded space in a search query.
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

/// The active tab after tab [closed] is removed, leaving [newLength] tabs: an
/// earlier close shifts it left, and closing the active tab picks the tab that
/// slid into its place, clamped to the last.
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
