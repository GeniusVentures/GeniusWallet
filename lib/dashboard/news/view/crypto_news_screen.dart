import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:genius_wallet/services/coin_telegraph/coin_telegraph_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';

/// Crypto News, redesigned as **B2 · Hero + Next up** (sketches 100–102). The
/// old staggered grid of scrim-covered photo tiles is replaced by a photo-led
/// magazine: a lead hero + a "Next up" column, then the rest as an even photo
/// grid. Hover is the shared `GWCard` lift chip, not a black scrim that reprints
/// the title. Search filters the already-fetched list locally (no network).
class CryptoNewsScreen extends StatefulWidget {
  const CryptoNewsScreen({super.key});

  @override
  State<CryptoNewsScreen> createState() => _CryptoNewsScreenState();
}

class _CryptoNewsScreenState extends State<CryptoNewsScreen> {
  late Future<List<NewsArticle>> _newsFuture;
  final TextEditingController _searchController = TextEditingController();
  String _query = '';
  Timer? _searchDebounce;

  /// When the current feed finished loading — drives the header's "Updated …"
  /// stamp (sketch 031 · R3). Null until the first fetch settles.
  DateTime? _lastUpdated;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  /// Kicks off a fetch and stamps [_lastUpdated] when it settles (success OR
  /// error — the feed collapses failures to a cached/empty list, so either way
  /// "this is as fresh as it gets right now" is the honest thing to show).
  void _load() {
    final future = fetchCoinTelegraphNews();
    _newsFuture = future;
    future.whenComplete(() {
      if (mounted) {
        setState(() => _lastUpdated = DateTime.now());
      }
    });
  }

  void _retryNews() {
    setState(_load);
  }

  /// Debounced so typing never re-lays-out the whole magazine (photo grid +
  /// shrink-wrapped GridView) on every keystroke — that per-key rebuild is what
  /// dropped characters ("can't type") and left a half-typed query that matched
  /// nothing ("doesn't find by title"). The filter runs once the user pauses.
  void _onSearchChanged(String value) {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 220), () {
      if (mounted) {
        setState(() => _query = value);
      }
    });
  }

  void _clearSearch() {
    _searchDebounce?.cancel();
    setState(() {
      _searchController.clear();
      _query = '';
    });
  }

  /// Local, network-free filter over the already-fetched list — a `where()`
  /// across the headline and the dek.
  List<NewsArticle> _filter(List<NewsArticle> articles) {
    final q = _query.trim().toLowerCase();
    if (q.isEmpty) {
      return articles;
    }
    return articles
        .where(
          (a) =>
              a.title.toLowerCase().contains(q) ||
              a.dek.toLowerCase().contains(q),
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    // topCenter: centred horizontally (symmetric margins) and top-pinned for the
    // 64px navbar→title gap; the shared xxl cap aligns this title with the other
    // content tabs while keeping left padding on a wide window.
    return Align(
      alignment: Alignment.topCenter,
      child: Padding(
        // Shared gap and gutter (`GeniusBreakpoints`), so 'Crypto News' sits
        // at the SAME X as Transactions and Markets.
        padding: EdgeInsets.fromLTRB(
          GeniusBreakpoints.pageGutter(context),
          GeniusBreakpoints.pageTitleGap(context),
          GeniusBreakpoints.pageGutter(context),
          GeniusWalletConsts.space4,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: GeniusBreakpoints.xxl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GWPageHeader(
                title: 'Crypto News',
                // Desktop-reachable refresh (pull-to-refresh alone is
                // unreachable with a mouse), now paired with a freshness stamp
                // (sketch 031 · R3): the stamp says whether the feed is even
                // stale before you press.
                trailing: _UpdatedStamp(
                  lastUpdated: _lastUpdated,
                  onRefresh: _retryNews,
                ),
              ),
              GWSearchField(
                controller: _searchController,
                hint: 'Search headlines',
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              ),
              const SizedBox(height: GeniusWalletConsts.space8),
              Expanded(
                child: FutureStateWidget<List<NewsArticle>>(
                  future: _newsFuture,
                  // The fetch collapses network failures to an empty list
                  // rather than throwing, so this branch is a rare last resort;
                  // the empty-list case below is the real failure surface.
                  error: GWErrorState(
                    message: 'Failed to load news.',
                    onRetry: _retryNews,
                  ),
                  onData: (articles) {
                    if (articles.isEmpty) {
                      // A genuinely empty feed (failed fetch, no cache) is the
                      // ONLY page-level empty state now. A search MISS no longer
                      // blanks the page — the hero band stays put and the
                      // "Results" section reports the miss inline (Jakub's call).
                      return GWEmptyState(
                        icon: Icons.article_outlined,
                        title: 'No news right now',
                        message: 'Try again in a moment.',
                        actionLabel: 'Refresh',
                        onAction: _retryNews,
                      );
                    }
                    final q = _query.trim();
                    return RefreshIndicator(
                      onRefresh: () async => _retryNews(),
                      // Hero + "Next up" ALWAYS come from the full feed; `results`
                      // (non-null only while searching) drives the bottom section,
                      // retitled "Results" — so searching never reshuffles the
                      // top band.
                      child: _NewsMagazine(
                        items: articles,
                        query: q,
                        results: q.isEmpty ? null : _filter(articles),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// The header freshness control (sketch 031 · R3): "Updated 3m ago" beside a
/// refresh icon. Owns its OWN 30s ticker so only the stamp re-renders as the
/// label ages — never the whole magazine (that per-minute relayout is exactly
/// what the search debounce exists to avoid).
class _UpdatedStamp extends StatefulWidget {
  const _UpdatedStamp({required this.lastUpdated, required this.onRefresh});

  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  @override
  State<_UpdatedStamp> createState() => _UpdatedStampState();
}

class _UpdatedStampState extends State<_UpdatedStamp> {
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(seconds: 30), (_) {
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final updated = widget.lastUpdated;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Always shown (Jakub's call) so the header never looks empty / jumps
        // when the first fetch settles — "Updating…" until then.
        Text(
          updated == null ? 'Updating…' : 'Updated ${shortTimeAgo(updated)}',
          style: GeniusWalletTypography.bodySm.copyWith(
            color: gw.textSecondary,
          ),
        ),
        const SizedBox(width: GeniusWalletConsts.space4),
        // A bare icon button — no fill/border box — to match the Markets
        // header's trailing action (markets_screen.dart, the magnifying glass).
        IconButton(
          tooltip: 'Refresh',
          onPressed: widget.onRefresh,
          icon: Icon(Icons.refresh, size: 18, color: gw.textSecondary),
          visualDensity: VisualDensity.compact,
        ),
      ],
    );
  }
}

/// The B2 body: a hero + "Next up" band, then the remaining stories as an even
/// photo grid. Everything scrolls as one surface.
class _NewsMagazine extends StatelessWidget {
  const _NewsMagazine({required this.items, this.query = '', this.results});

  /// The full, unfiltered feed — hero + "Next up" always come from here, so the
  /// top band never reshuffles on a search.
  final List<NewsArticle> items;

  /// The active query (trimmed); empty while browsing. Used only to label the
  /// "no matches" line.
  final String query;

  /// Search matches — non-null ONLY while searching. Drives the "Results"
  /// section in place of "More news".
  final List<NewsArticle>? results;

  // Below this the "Next up" column drops beneath the hero (sketch 101 B2).
  static const double _bandBreakpoint = 760;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final hero = items.first;
    final nextUp = items.skip(1).take(3).toList();
    final rest = items.skip(1 + nextUp.length).toList();

    return ScrollConfiguration(
      // No scrollbar on the News surface (Jakub's call) — the desktop default
      // ScrollBehavior draws one on the right edge; scrollbars:false removes it
      // for this scroll view only.
      behavior: ScrollConfiguration.of(context).copyWith(scrollbars: false),
      child: SingleChildScrollView(
        // Always scrollable so RefreshIndicator has something to pull even when
        // a filtered result is short.
        physics: const AlwaysScrollableScrollPhysics(),
        // Top space6 is load-bearing: the hero is a hoverLift GWCard, and this
        // scroll view clips at its viewport edge (Clip.hardEdge). With the hero
        // flush at the top, its 2px hover lift + deepened shadow paint ABOVE the
        // viewport and get clipped — the "border escapes / overlaps the section
        // above" report. The padding gives the lift room inside the clip.
        // Horizontal 0 so the hero + grid align with the 'Crypto News' title
        // and search field above (all at the ConstrainedBox left edge, not 8px
        // further in). Top space6 stays — the hoverLift hero needs room above
        // it inside this clipping scroll or its lift/shadow gets cut.
        padding: const EdgeInsets.fromLTRB(0, GeniusWalletConsts.space6, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= _bandBreakpoint;
                final heroCard = _HeroCard(article: hero, wide: wide);
                if (!wide) {
                  // Narrow: single column. One result is just the hero; more
                  // results stack "Next up" beneath it.
                  if (nextUp.isEmpty) {
                    return heroCard;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      heroCard,
                      const SizedBox(height: GeniusWalletConsts.space8),
                      _NextUp(articles: nextUp),
                    ],
                  );
                }
                // Wide: the hero ALWAYS sits at flex 3, so a single filtered
                // result looks identical to the hero in the full magazine
                // instead of sprawling edge-to-edge (Jakub: "one huge article
                // should look the same as finding a few"). When there is no
                // "Next up", the right 2/5 is an empty spacer that reserves the
                // band width — it does NOT stretch the hero. IntrinsicHeight
                // also keeps the stretch-Row self-bounding in the page's
                // vertical scroll (the earlier infinite-height freeze).
                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 3, child: heroCard),
                      const SizedBox(width: GeniusWalletConsts.space8),
                      Expanded(
                        flex: 2,
                        child: nextUp.isEmpty
                            ? const SizedBox.shrink()
                            : _NextUp(articles: nextUp),
                      ),
                    ],
                  ),
                );
              },
            ),
            // Bottom section. Searching → "Results": every match, shown here so
            // the hero band above stays frozen on the latest stories instead of
            // the whole feed reshuffling on each search. Browsing → "More news":
            // the stories past the hero band.
            if (results != null) ...[
              const SizedBox(height: GeniusWalletConsts.space12),
              const GWSectionTitle(title: 'Results'),
              if (results!.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(
                    top: GeniusWalletConsts.space4,
                  ),
                  child: Text(
                    'No headlines match “$query”.',
                    style: GeniusWalletTypography.bodyMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  ),
                )
              else
                _grid(results!),
            ] else if (rest.isNotEmpty) ...[
              const SizedBox(height: GeniusWalletConsts.space12),
              const GWSectionTitle(title: 'More news'),
              _grid(rest),
            ],
            const SizedBox(height: GeniusWalletConsts.space8),
          ],
        ),
      ),
    );
  }

  /// The even photo grid shared by "More news" (browse) and "Results" (search).
  Widget _grid(List<NewsArticle> articles) => GridView.builder(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
      maxCrossAxisExtent: 360,
      mainAxisSpacing: GeniusWalletConsts.space8,
      crossAxisSpacing: GeniusWalletConsts.space8,
      // Fixed tile height (not an aspect ratio) so the layout is stable across
      // column widths and cannot overflow as the photo scales: photo 168 + the
      // text region below it.
      mainAxisExtent: 312,
    ),
    itemCount: articles.length,
    itemBuilder: (context, i) => _NewsGridCard(article: articles[i]),
  );
}

/// The lead story. Wide: big photo left, text right. Narrow: photo on top.
class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.article, required this.wide});

  final NewsArticle article;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final text = Padding(
      padding: const EdgeInsets.all(GeniusWalletConsts.space8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            article.title.trim(),
            style: GeniusWalletTypography.headlineMd.copyWith(
              color: gw.textPrimary,
            ),
            maxLines: wide ? 3 : 2,
            overflow: TextOverflow.ellipsis,
          ),
          if (article.dek.isNotEmpty) ...[
            const SizedBox(height: GeniusWalletConsts.space4),
            Text(
              article.dek,
              style: GeniusWalletTypography.bodyMd.copyWith(
                color: gw.textSecondary,
              ),
              maxLines: wide ? 3 : 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
          const SizedBox(height: GeniusWalletConsts.space6),
          _MetaLine(article: article),
        ],
      ),
    );

    return GWCard(
      hoverLift: true,
      onTap: () => launchWebSite(context, article.link),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        child: wide
            // IntrinsicHeight is load-bearing: this Row uses
            // CrossAxisAlignment.stretch, so it needs a BOUNDED height. When the
            // magazine renders the hero+"Next up" band it wraps the pair in an
            // IntrinsicHeight, but when a filtered result leaves nextUp empty it
            // returns THIS card bare, directly into the page's vertical scroll —
            // unbounded height → stretch demanded h=Infinity → the whole News
            // page threw on every layout and froze (only ever on a search that
            // narrowed to ≤1 result). Self-bounding here fixes it everywhere;
            // the outer IntrinsicHeight in the band case is then just redundant.
            ? IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _NewsPhoto(url: article.imageUrl)),
                    Expanded(child: text),
                  ],
                ),
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AspectRatio(
                    aspectRatio: 16 / 9,
                    child: _NewsPhoto(url: article.imageUrl),
                  ),
                  text,
                ],
              ),
      ),
    );
  }
}

/// The "Next up" column: a section title over headline-only rows (no photo).
class _NextUp extends StatelessWidget {
  const _NextUp({required this.articles});

  final List<NewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        const GWSectionTitle(title: 'Next up'),
        for (var i = 0; i < articles.length; i++)
          _NextUpRow(index: i + 1, article: articles[i]),
      ],
    );
  }
}

class _NextUpRow extends StatelessWidget {
  const _NextUpRow({required this.index, required this.article});

  final int index;
  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
        onTap: () => launchWebSite(context, article.link),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: GeniusWalletConsts.space4,
            vertical: GeniusWalletConsts.space4,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 24,
                child: Text(
                  '$index',
                  style: GeniusWalletTypography.numericBody.copyWith(
                    color: gw.textSecondary,
                  ),
                ),
              ),
              const SizedBox(width: GeniusWalletConsts.space4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.title.trim(),
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    _MetaLine(article: article),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A full photo card for the grid: photo on top, then title, dek and meta.
class _NewsGridCard extends StatelessWidget {
  const _NewsGridCard({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWCard(
      hoverLift: true,
      onTap: () => launchWebSite(context, article.link),
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 168,
              width: double.infinity,
              child: _NewsPhoto(url: article.imageUrl),
            ),
            // Expanded absorbs any slack in the fixed-height tile so the text
            // region can never overflow it.
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(GeniusWalletConsts.space8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      article.title.trim(),
                      style: GeniusWalletTypography.titleMd.copyWith(
                        color: gw.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (article.dek.isNotEmpty) ...[
                      const SizedBox(height: GeniusWalletConsts.space2),
                      Text(
                        article.dek,
                        style: GeniusWalletTypography.bodySm.copyWith(
                          color: gw.textSecondary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    _MetaLine(article: article),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A timestamp with a clock glyph — the story's age, formatted live.
class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.article});

  final NewsArticle article;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    // Timestamp in green (sketch 031 · T2, colour C1): the COMPACT age
    // ("3h ago"), no clock glyph (Jakub's call — the green already reads as a
    // timestamp). Green is `gw.statusSuccess` — AA on the card surface in both
    // themes (#0AD89C dark / #07875F light).
    return Text(
      article.relativeTimeShort,
      style: GeniusWalletTypography.bodySm.copyWith(
        color: gw.statusSuccess,
        fontWeight: FontWeight.w600,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }
}

/// Shared photo: a covered network image with the app's sunken placeholder and
/// a soft error fallback. Sized by its parent (Expanded / AspectRatio / SizedBox).
class _NewsPhoto extends StatelessWidget {
  const _NewsPhoto({required this.url});

  final String? url;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return CachedNetworkImage(
      imageUrl: url ?? '',
      fit: BoxFit.cover,
      placeholder: (context, url) => ColoredBox(
        color: gw.surfaceSunken,
        child: const Center(child: Loading()),
      ),
      errorWidget: (context, url, error) => Container(
        color: gw.surfaceSunken,
        alignment: Alignment.center,
        child: Icon(Icons.broken_image_outlined, color: gw.textSecondary),
      ),
    );
  }
}
