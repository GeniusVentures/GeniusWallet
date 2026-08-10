import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:genius_wallet/components/cards/gw_card.dart';
import 'package:genius_wallet/components/cards/gw_kicker.dart';
import 'package:genius_wallet/components/cards/gw_row_rhythm.dart';
import 'package:genius_wallet/components/cards/gw_section_title.dart';
import 'package:genius_wallet/components/custom_future_builder.dart';
import 'package:genius_wallet/components/effects/gw_hover_row.dart';
import 'package:genius_wallet/components/feedback/gw_empty_state.dart';
import 'package:genius_wallet/components/feedback/gw_error_state.dart';
import 'package:genius_wallet/components/inputs/gw_text_field.dart';
import 'package:genius_wallet/components/loading.dart';
import 'package:genius_wallet/components/scaffold/gw_page_header.dart';
import 'package:genius_wallet/dashboard/home/view/dashboard_screen.dart';
import 'package:genius_wallet/hive/models/news_article.dart';
import 'package:genius_wallet/services/coin_telegraph/coin_telegraph_api.dart';
import 'package:genius_wallet/theme/genius_wallet_consts.dart';
import 'package:genius_wallet/theme/genius_wallet_typography.dart';
import 'package:genius_wallet/theme/gw_colors.dart';
import 'package:genius_wallet/utils/breakpoints.dart';
import 'package:genius_wallet/web/web_utils.dart';

/// Crypto News. **Two presentations, one breakpoint** (`_bandBreakpoint`, 760).
///
/// **Wide** is **B2 · Hero + Next up** (sketches 100–102): a lead hero beside a
/// "Next up" column, then the rest as an even photo grid. Unchanged.
///
/// **Narrow** is **sketch 189 scheme C · "Lead + digest"** (Jakub, 2026-08-09):
/// the same hero, then ONE `DashboardScrollContainer` panel holding the search
/// field, the story count and every remaining article as a 72px-thumbnail row.
/// It replaces the grid, which at `maxCrossAxisExtent: 360` resolved to two
/// 181px columns on a phone and gave a 16px headline 147px of line - truncated
/// on nearly every article - and it absorbs "Next up", whose three stories are
/// simply the first three rows.
///
/// Hover is the shared `GWCard` lift chip (hero, grid) or `GWHoverRow` (digest),
/// never a black scrim that reprints the title. Search filters the
/// already-fetched list locally (no network).
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
          // ONE breakpoint for the whole page. `_bandBreakpoint` used to be
          // read only inside the magazine, but sketch 189 C gives the search
          // field a width-dependent HOME - page column on desktop, inside the
          // digest panel on a phone - so the decision has to be made where both
          // halves can see it. This builder measures the SAME width the
          // magazine's own one did: the Column below fills this ConstrainedBox
          // (`GWPageHeader` claims `double.infinity`), and the magazine's
          // scroll view adds no horizontal padding.
          child: LayoutBuilder(
            builder: (context, constraints) {
              final wide =
                  constraints.maxWidth >= _NewsMagazine._bandBreakpoint;
              final searchField = GWSearchField(
                controller: _searchController,
                hint: 'Search headlines',
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
              );
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GWPageHeader(
                    title: 'Crypto News',
                    // The freshness stamp (sketch 031 · R3): it says whether
                    // the feed is even stale before you reach for a refresh.
                    // It mounts a refresh button of its own on desktop only -
                    // see `_UpdatedStamp`.
                    trailing: _UpdatedStamp(
                      lastUpdated: _lastUpdated,
                      onRefresh: _retryNews,
                    ),
                  ),
                  // WIDE only. On a phone this exact field is mounted by the
                  // digest panel instead, so the first screen is a photo and a
                  // headline rather than a field the reader rarely uses - which
                  // is the reverse of what shipped before (sketch 189 C).
                  if (wide) ...[
                    searchField,
                    const SizedBox(height: GeniusWalletConsts.space8),
                  ],
                  Expanded(
                    child: FutureStateWidget<List<NewsArticle>>(
                      future: _newsFuture,
                      // The fetch collapses network failures to an empty list
                      // rather than throwing, so this branch is a rare last
                      // resort; the empty-list case below is the real failure
                      // surface.
                      error: GWErrorState(
                        message: 'Failed to load news.',
                        onRetry: _retryNews,
                      ),
                      onData: (articles) {
                        if (articles.isEmpty) {
                          // A genuinely empty feed (failed fetch, no cache) is
                          // the ONLY page-level empty state now. A search MISS
                          // no longer blanks the page - the hero stays put and
                          // the "Results" section (wide) or the digest panel
                          // (narrow) reports the miss inline (Jakub's call).
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
                          // The hero (and "Next up") ALWAYS come from the full
                          // feed; `results` (non-null only while searching)
                          // drives the bottom section, retitled "Results" - so
                          // searching never reshuffles the top band.
                          child: _NewsMagazine(
                            items: articles,
                            query: q,
                            results: q.isEmpty ? null : _filter(articles),
                            wide: wide,
                            searchField: searchField,
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

/// The header freshness control (sketch 031 · R3): "Updated 3m ago", beside a
/// refresh icon **on desktop only** (sketch 194 scheme A). Owns its OWN 30s
/// ticker so only the stamp re-renders as the label ages - never the whole
/// magazine (that per-minute relayout is exactly what the search debounce
/// exists to avoid).
class _UpdatedStamp extends StatefulWidget {
  const _UpdatedStamp({required this.lastUpdated, required this.onRefresh});

  final DateTime? lastUpdated;
  final VoidCallback onRefresh;

  @override
  State<_UpdatedStamp> createState() => _UpdatedStampState();
}

/// Optical, not structural: the gap between where the title's letters sit and
/// where a geometrically centred smaller line puts its own. Derived at the use
/// site below, and only correct for THIS pairing (bodySm beside headlineLg).
const double _opticalNudge = 1;

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
        // when the first fetch settles - "Updating…" until then.
        //
        // Nudged down 1px. `GWPageHeader` centres its trailing with
        // `CrossAxisAlignment.center`, which centres the two LINE BOXES, and a
        // line box is not where the letters are: Inter's proportional leading
        // split (typo asc 1984 / desc -494 of 2048 upem) puts the baseline at
        // 80.06% of the box, so the 24/32 title's ink lands at 7.93..30.61
        // (mid 19.27) while this 14/20 stamp's lands at 11.49..25.03
        // (mid 18.26). Measuring the x-height band alone agrees: 0.88px.
        // Baseline alignment is the wrong fix here - it moves the stamp 3.61px
        // and overshoots 2.6px the other way. `Transform`, not `Padding`, so
        // the correction cannot change the header's measured height.
        Transform.translate(
          offset: const Offset(0, _opticalNudge),
          child: Text(
            updated == null ? 'Updating…' : 'Updated ${shortTimeAgo(updated)}',
            style: GeniusWalletTypography.bodySm.copyWith(
              color: gw.textSecondary,
            ),
          ),
        ),
        // DESKTOP ONLY (sketch 194 scheme A). The button exists because
        // pull-to-refresh is unreachable with a mouse - a reason that only
        // holds where there IS a mouse. On a phone `RefreshIndicator` is
        // already mounted over this same feed, so the glyph was a second door
        // into a room that has one, and its 40px tap target (not the 32px
        // title line) was what set the header row's height.
        //
        // `useDesktopLayout`, not this page's own 760px `wide` test: it also
        // rules out a mobile app at tablet width, which is exactly the case
        // the "no mouse" reason cares about. No new breakpoint - the page
        // frame around this header already sizes itself with it.
        //
        // A bare icon button, no fill/border box: `GWPageHeader.trailing` has
        // only two other callers, a `GWButton` on Buy GNUS and a centred
        // `Icons.tune` on Swap, and neither is a peer of a left-aligned
        // content tab. Markets, Transactions, Assets and Submit job mount no
        // trailing at all - which is what this page now matches on a phone.
        if (GeniusBreakpoints.useDesktopLayout(context)) ...[
          const SizedBox(width: GeniusWalletConsts.space4),
          IconButton(
            tooltip: 'Refresh',
            onPressed: widget.onRefresh,
            icon: Icon(Icons.refresh, size: 18, color: gw.textSecondary),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ],
    );
  }
}

/// The body, in both presentations. Wide: a hero + "Next up" band, then the
/// remaining stories as an even photo grid (B2). Narrow: the hero, then one
/// digest panel (sketch 189 C). Everything scrolls as one surface either way.
class _NewsMagazine extends StatelessWidget {
  const _NewsMagazine({
    required this.items,
    required this.wide,
    required this.searchField,
    this.query = '',
    this.results,
  });

  /// The full, unfiltered feed — hero + "Next up" always come from here, so the
  /// top band never reshuffles on a search.
  final List<NewsArticle> items;

  /// The active query (trimmed); empty while browsing. Used only to label the
  /// "no matches" line.
  final String query;

  /// Search matches — non-null ONLY while searching. Drives the "Results"
  /// section in place of "More news".
  final List<NewsArticle>? results;

  /// Which presentation to render. Decided ONCE, by the page, against
  /// [_bandBreakpoint] - this widget no longer measures for itself, because the
  /// search field's home is decided by the same number one level up.
  final bool wide;

  /// The page's search field. Mounted here only on the NARROW path, inside the
  /// digest panel; on the wide path the page column mounts it above this
  /// widget and this reference goes unused.
  final Widget searchField;

  // Below this the "Next up" column used to drop beneath the hero (sketch 101
  // B2). Since sketch 189 C it does not drop - below this the whole page
  // switches to the lead + digest presentation, and "Next up" is not rendered
  // at all. Read by `_CryptoNewsScreenState.build`, which owns the decision.
  static const double _bandBreakpoint = 760;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    final hero = items.first;
    final nextUp = items.skip(1).take(3).toList();
    final rest = items.skip(1 + nextUp.length).toList();

    // NARROW: every story except the lead becomes a digest row - including the
    // three that are "Next up" on a wide window. While searching the rows are
    // the MATCHES, minus the hero if it is one of them: the hero is frozen on
    // the full feed directly above, and printing the same story twice on one
    // phone screen would read as a duplicate rather than as a match.
    final digest = (results ?? items).where((a) => a != hero).toList();

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
        // above" report. The padding gives the lift room inside the clip, and
        // the hero is still the first child in BOTH presentations, so it is
        // still the card that needs it.
        // Horizontal 0 so the hero, the grid and the digest panel align with
        // the 'Crypto News' title above (all at the ConstrainedBox left edge,
        // not 8px further in). The search field is only above them on a wide
        // window now - on a phone it lives inside the digest panel.
        padding: const EdgeInsets.fromLTRB(0, GeniusWalletConsts.space6, 0, 0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!wide) ...[
              // NARROW - sketch 189 C. The hero is today's narrow `_HeroCard`
              // unchanged (photo 16:9 on top, then text); everything behind it
              // is one panel. "Next up" is NOT mounted here: on a phone it was
              // a numbered list of three headlines sitting between two other
              // lists, and its three articles are the digest's first three
              // rows instead. `_NextUp`/`_NextUpRow` stay - the wide path
              // below still mounts them as the band's right-hand column.
              _HeroCard(article: hero, wide: false),
              // `space3` - the gap `OneColumnDashBoardView` puts between two
              // dashboard panels, so the hero card and the digest sit on the
              // homepage's rhythm rather than a rhythm of their own.
              const SizedBox(height: GeniusWalletConsts.space3),
              _NewsDigestPanel(
                articles: digest,
                query: query,
                searching: results != null,
                searchField: searchField,
              ),
            ] else ...[
              // WIDE: the hero ALWAYS sits at flex 3, so a single filtered
              // result looks identical to the hero in the full magazine
              // instead of sprawling edge-to-edge (Jakub: "one huge article
              // should look the same as finding a few"). When there is no
              // "Next up", the right 2/5 is an empty spacer that reserves the
              // band width - it does NOT stretch the hero. IntrinsicHeight
              // also keeps the stretch-Row self-bounding in the page's
              // vertical scroll (the earlier infinite-height freeze).
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _HeroCard(article: hero, wide: true),
                    ),
                    const SizedBox(width: GeniusWalletConsts.space8),
                    Expanded(
                      flex: 2,
                      child: nextUp.isEmpty
                          ? const SizedBox.shrink()
                          : _NextUp(articles: nextUp),
                    ),
                  ],
                ),
              ),
              // Bottom section. Searching → "Results": every match, shown here
              // so the hero band above stays frozen on the latest stories
              // instead of the whole feed reshuffling on each search. Browsing
              // → "More news": the stories past the hero band.
              if (results != null) ...[
                const SizedBox(height: GeniusWalletConsts.space12),
                // No `contentTopInset` in either branch: `_grid`'s first tile
                // is a `GWCard` whose photo fills its top edge, and the
                // empty-state Text paints from its own line box. Both are
                // C = 0, so the title pays the full `space8` and this section
                // renders the shared 26px gap
                // (`gw_section_title_rhythm_test.dart`).
                const GWSectionTitle(title: 'Results'),
                if (results!.isEmpty)
                  // The `top: space4` this used to carry was a second gap
                  // stacked under the title's own, which pushed this branch to
                  // 34 while the grid branch beside it sat at 26. Removed
                  // 2026-08-06 so the empty message sits on exactly the same
                  // rhythm as the grid it replaces.
                  Text(
                    'No headlines match “$query”.',
                    style: GeniusWalletTypography.bodyMd.copyWith(
                      color: gw.textSecondary,
                    ),
                  )
                else
                  _grid(results!),
              ] else if (rest.isNotEmpty) ...[
                const SizedBox(height: GeniusWalletConsts.space12),
                // C = 0 - `_grid`'s first tile paints its photo at its own top
                // edge - so this section reaches the rule exactly, like
                // Results.
                const GWSectionTitle(title: 'More news'),
                _grid(rest),
              ],
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

/// The phone's digest (sketch 189 C): ONE `DashboardScrollContainer` holding
/// the search field, the story count and every story past the hero as a row.
///
/// The order and the spacing are `/assets`' second panel
/// (`assets_screen.dart:406-455`): field at full card width, `space6`, the
/// dense kicker at the `space4` wall, `space4`, then rows separated by a
/// `borderSubtle` `Divider`. Copied rather than re-decided so the two boxed
/// pages read as one list language instead of two.
class _NewsDigestPanel extends StatelessWidget {
  const _NewsDigestPanel({
    required this.articles,
    required this.query,
    required this.searching,
    required this.searchField,
  });

  /// The rows, hero already removed.
  final List<NewsArticle> articles;

  /// The active query (trimmed). Used only to label the miss line.
  final String query;

  /// True while a query is active. Switches the count from "N stories" to
  /// "N results", and turns an empty [articles] into the inline miss line
  /// rather than a silently short panel - a search MISS must never blank the
  /// page (the same rule the wide "Results" section follows).
  final bool searching;

  final Widget searchField;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return DashboardScrollContainer(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Full card width, NO `space4` wall - the field's own border is the
          // edge the eye reads, which is exactly why `/assets` mounts its field
          // this way (`assets_screen.dart:417`).
          searchField,
          const SizedBox(height: GeniusWalletConsts.space6),
          Padding(
            // `space4`, the wall `GWSectionTitle` charges inside a panel and
            // the one `kGWRowWall` gives every row below, so the count and the
            // headlines share one left edge.
            padding: const EdgeInsets.symmetric(
              horizontal: GeniusWalletConsts.space4,
            ),
            // Lower-case: GWKicker upper-cases it itself and its doc forbids
            // callers pre-calling toUpperCase().
            child: GWKicker(
              searching
                  ? '${articles.length} results'
                  : '${articles.length} stories',
              dense: true,
              // NOT a control - the feed has exactly one order and this states
              // it, which is why it is a plain `Text` in the kicker's own type
              // rather than `/assets`' tappable sort toggle. Drawn by sketch
              // 189 C; it is also the one piece of chrome on this panel that
              // could go without changing what the page does.
              trailing: Text(
                'NEWEST FIRST',
                style: GWKicker.style(gw, dense: true),
              ),
            ),
          ),
          const SizedBox(height: GeniusWalletConsts.space4),
          if (searching && articles.isEmpty)
            Padding(
              // At the same wall as the kicker above it, so the miss line
              // starts where the headlines it replaces would have.
              padding: const EdgeInsets.symmetric(
                horizontal: GeniusWalletConsts.space4,
              ),
              child: Text(
                'No headlines match “$query”.',
                style: GeniusWalletTypography.bodyMd.copyWith(
                  color: gw.textSecondary,
                ),
              ),
            ),
          // A `for` loop, not a list widget: the page's SingleChildScrollView is
          // the one scroll, exactly as `/assets` builds its rows.
          //
          // ponytail: every row is built eagerly, so the whole 30-item feed
          // builds at once. Upgrade path is a sliver list, once the feed is
          // long enough for that to be measurable.
          for (int i = 0; i < articles.length; i++) ...[
            _NewsListRow(article: articles[i]),
            if (i < articles.length - 1)
              Divider(height: 1, thickness: 1, color: gw.borderSubtle),
          ],
        ],
      ),
    );
  }
}

/// One story in the digest: a square thumbnail, two lines of headline, one line
/// of dek, then the age.
///
/// This is the phone's ONLY story component past the hero - it replaces both
/// the "Next up" row and the grid tile, whose 16px headline got 147px of line
/// at two 181px columns and truncated on nearly every article.
class _NewsListRow extends StatelessWidget {
  const _NewsListRow({required this.article});

  final NewsArticle article;

  /// The thumbnail's side. Untokened for the same reason [kGWRowIconSize] is:
  /// it measures a SIZE, not a gap. Derived from that 38 rather than invented -
  /// doubled, then back to the nearest 4-pt step (76 → 72) - so the digest's
  /// leading slot is the app's row glyph at photo scale.
  static const double _thumb = 72;

  @override
  Widget build(BuildContext context) {
    final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();
    return GWHoverRow(
      onTap: () => launchWebSite(context, article.link),
      child: Padding(
        // The shared row box: `kGWRowWall` each side, `kGWRowSeparatorGap`
        // above and below, so a story row and a `CoinCardRow` sit on one
        // rhythm and the `Divider` between two of them lands where every other
        // list's does.
        padding: kGWRowPadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(GeniusWalletConsts.radiusSm),
              child: SizedBox(
                width: _thumb,
                height: _thumb,
                child: _NewsPhoto(url: article.imageUrl),
              ),
            ),
            const SizedBox(width: kGWRowIconToText),
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
                  if (article.dek.isNotEmpty) ...[
                    const SizedBox(height: GeniusWalletConsts.space2),
                    Text(
                      article.dek,
                      style: GeniusWalletTypography.bodySm.copyWith(
                        color: gw.textSecondary,
                      ),
                      // ONE line. The headline is the story here; the dek is
                      // the hint that decides whether to open it, and a second
                      // line of it costs 20px on every row of a 29-row page.
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  const SizedBox(height: GeniusWalletConsts.space2),
                  _MetaLine(article: article),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// The "Next up" column: a section title over headline-only rows (no photo).
///
/// **Wide only** since sketch 189 C. It fills the right 2/5 of the hero band, a
/// column that would otherwise be empty; on a phone that band does not exist
/// and its stories are digest rows instead.
class _NextUp extends StatelessWidget {
  const _NextUp({required this.articles});

  final List<NewsArticle> articles;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // `_NextUpRow` pads itself `vertical: space4`, so the first row's ink
        // starts 8px below its layout box. Declared rather than removed: that
        // padding is the ROW's own rhythm, shared by every row in the column,
        // and stripping it from the first one alone would make row 1 sit
        // tighter than rows 2..n. The title spends its pad against it instead
        // - `26 - 10 - 8` leaves `space4` - so this section renders the same
        // 26px gap as every other one
        // (`gw_section_title_rhythm_test.dart`).
        const GWSectionTitle(
          title: 'Next up',
          contentTopInset: GeniusWalletConsts.space4,
        ),
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
