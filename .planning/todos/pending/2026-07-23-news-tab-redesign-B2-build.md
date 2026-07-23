# News tab redesign → build B2 (queued for the executor)

**Design session decision, 2026-07-23.** Jakub chose **B2 · Hero + Next up** for the `/news` tab.
Run this AFTER the current `/gsd-quick` on terminal 1 finishes. This is a design→executor handoff:
only the executor may edit `lib/`, run flutter, and write `MANIFEST.md`.

Sketches (open to see the target): `100-news-page-layout`, `101-news-magazine-tuning`,
`102-news-hero-band`. The chosen variant is the **B2** tab in 101 and 102 (marked ★).

Target file: `lib/dashboard/news/view/crypto_news_screen.dart` (routed at `router.dart:238`).

## The chosen layout — B2

- **`GWPageHeader(title: 'Crypto News', trailing: <Refresh button>)`** — the trailing slot already
  exists (`gw_page_header.dart:10`) and owns the `space8` gap below; do not add another spacer.
- **Top band:** a full-width **hero** card (one lead story, big photo left ~50%, title/dek/meta right)
  beside a **Next up** column — `GWSectionTitle('Next up')` + items 2-4 as headline-only rows
  (number, title, timestamp, no photo). At narrow widths the Next up column drops below the hero.
- **Below the band:** the remaining ~26 items as an even **3-column grid of full photo cards**
  (photo top, title 2-3 line clamp, dek 2 line, meta). Jakub explicitly wants the full photo grid for
  all items — the shorter-page variants (B2-I front-page list, B2-II featured trio) were rejected.
- Search field in the header (local filter) is **optional** — nice-to-have, not required. If included:
  `GWTextField(hint: 'Search headlines', prefix: Icon(Icons.search))` with `label` null, filtering the
  already-fetched list with `where()`. No network.

## Component map (lean on what ships — Jakub's explicit ask)

| Part | Use | Note |
|------|-----|------|
| Page title + Refresh | `GWPageHeader(trailing:)` | trailing slot + `space8` gap already owned |
| Hero + news cards | `GWCard(onTap:, radius: radiusLg)` | sheen + hairline + `elevation.card` for free; today's card hand-rolls all three in a raw Container (`crypto_news_screen.dart:116-121`) |
| "Next up" title | `GWSectionTitle(title: 'Next up')` | 18px titleLg, reserves shared 44px header height, owns its gap |
| Next up rows | `InkWell` list rows | plain rows — no new widget |
| Search (optional) | `GWTextField(hint:, prefix:, onChanged:)` | leave `label` null |
| Refresh control | `GWButton(variant: ghost, size: sm, leading: Icon(Icons.refresh))` | both already in the enums |
| Photo | `CachedNetworkImage` | already in use; keep `errorWidget` — CDN can still 404 |
| Grid | `GridView` + `SliverGridDelegateWithMaxCrossAxisExtent` | **drops the `flutter_staggered_grid_view` dependency** — nothing else imports it |

## Prerequisite fix — highest leverage — `GWCard` has no hover

`GWCard` has **no hover state**: passing `onTap` wraps it in an `InkWell` (`gw_card.dart:62-71`) that
paints Material's grey highlight, not the sketch-008-D "lift chip" that is the design-system hover
standard. Today's news card works around this with its own `MouseRegion` + a black scrim
(`crypto_news_screen.dart:110-126, 154-185`) — which is finding 3 below.

**Add a `hoverLift` flag to `GWCard`** (translateY(-2px) + border-strong + deeper shadow on hover) and
every card surface in the app inherits the standard hover from one change. Do this first; the News
cards then just pass `hoverLift: true`. Leaves ONE runnable check behind (widget test: card offset/shadow
changes on pointer enter).

## Three behavioural bugs to fix in the same pass (not taste — wrong behaviour)

1. **`pubDate` is a frozen string.** `coin_telegraph_api.dart:63-65` runs `timeago.format()` at fetch
   time and `:94` writes the string into Hive, so a cached article says "2 hours ago" forever. Store the
   `DateTime`/ISO string (additive `@HiveField`; keep `pubDate` for compat), format at build.
2. **`description` is fetched, cached, never rendered** (`news_article.dart:12`; no read in the view).
   B2's dek needs it. **Trap:** the raw field starts with `<img src=…>` (that's how `:75-81` scrapes the
   image) — strip tags before showing, or it prints markup.
3. **Hover subtracts information.** `:154-185` paints `Colors.black87` over the card and reprints the
   same title. Replaced by the `GWCard` lift above.

## Lesser fixes while in the file

- `:55-70` — empty/error states are bare `Text`; use `GWEmptyState` / `GWErrorState` (already used
  elsewhere).
- `:72` — the only refresh is `RefreshIndicator` (pull-to-refresh), unreachable on desktop → the header
  Refresh button covers it.
- `coin_telegraph_api.dart:75-81` — the `<img>` regex fallback is **dead code**: all 30 live items carry
  `<enclosure>`, so `imageUrl` always resolves there. Safe to drop.
- Do NOT add a category/topic filter. Measured 2026-07-23: the live feed has 3 categories with 25/30 in
  "Latest News" — a filter there is decoration. (This is why sketch 100 C was withdrawn.)

## Executor bookkeeping

Add these rows to `.planning/sketches/MANIFEST.md` (design sessions can't write it):

```
| 100 | news-page-layout | What is the Crypto News tab for — scan, magazine, or filterable feed? | **B · Magazine** (C withdrawn: live feed has 3 categories, 25/30 in one) | news, page-layout, feed, cointelegraph |
| 101 | news-magazine-tuning | B won — how does magazine carry 30 items without 8 screens of scroll? | **B2 · Hero + Next up** (chosen 2026-07-23) | news, magazine, density, components, gw-card |
| 102 | news-hero-band | Two improved B2s that also shorten the tail | **B2 (reference)** chosen 2026-07-23 — full photo grid wanted; B2-I/B2-II rejected | news, magazine, next-up, hero |
```

Supersedes the earlier note `2026-07-23-news-tab-three-behavioural-bugs.md` (the bugs are folded in here).
