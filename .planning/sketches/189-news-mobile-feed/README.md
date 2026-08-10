---
sketch: 189
name: news-mobile-feed
question: "What is the Crypto News feed on a phone, once the desktop magazine's grid stops working there?"
winner: "C"
tags: [mobile, ios, news, feed, magazine, grid, density, cards, search, topics, keyword-classifier, rss, code-grounded, follows-100, follows-101, follows-102, follows-031]
---

# Sketch 189 - Crypto News on a phone

http://localhost:8899/189-news-mobile-feed/

Jakub, 2026-08-09: *look at Crypto News, see how it looks and what functions we have in the code, then
design me an adjustment for how the mobile app looks - I think there should be some changes there.
Three or four designs, based on our base components.*

**Decided the same day: scheme C.** Jakub, on seeing the set: *definitely design C. I would just like
the header title to be the same as in Assets - unless you have actually already unified it everywhere.
Keep the components we have, so that we do not introduce anything new unless it is essential.*

## Real content, not placeholder

The 30 items CoinTelegraph's RSS returned on 9 Aug 2026 - real headlines, real deks, real photo URLs,
real timestamps - pulled at build time and inlined. Ages are computed against a fixed `NOW`
(2026-08-09T12:30Z) by `shortTimeAgo`, ported verbatim from `news_article.dart:10-25`, so the sketch is
deterministic across reloads.

## What the phone gets today, measured

`crypto_news_screen.dart` is 695 lines and every line of it is a good desktop page. Three things break
in the translation to 390pt:

| Piece | Phone geometry | Source |
| --- | --- | --- |
| Frame | gutter 6, title gap 24 -> content **378px** | `breakpoints.dart:32-41` |
| Hero | photo 16:9 = 213px, + text ~= **362px** | `:481` `AspectRatio(16/9)` |
| Next up | title + 3 numbered rows ~= **290px** | `:494-522` |
| Grid | `(378/360).ceil()` = **2 cols**, tile **181 x 312** | `:396-404` |
| Tile text width | 181 - 2 borders - 32 padding = **147px** | `:609` `EdgeInsets.all(space8)` |
| Grid block alone | 13 rows x 312 + 12 x 16 = **4,248px** | fixed heights, exactly computable |

1. **The headline does not fit its own tile.** `titleMd` is 16px with 147px of line - roughly 30
   characters in two lines. The median headline in the live feed is **62 characters**, the longest 76.
   Nearly every tile ellipsises, and a truncated headline is the one thing a news card exists to
   deliver.
2. **One object, three card languages.** `_HeroCard`, `_NextUpRow` and `_NewsGridCard` draw one model
   with five fields three ways. Side by side on a desktop that reads as editorial hierarchy; stacked on
   a phone it reads as three different lists.
3. **The page is roughly six viewports long** against a 628px scroll area, and the cost is **164px of
   page per article** (two per 328px grid row) for a headline the tile then truncates.

Smaller, and separate: the header's refresh `IconButton` (`_UpdatedStamp`, `:248`) exists, by its own
comment, because "pull-to-refresh alone is unreachable with a mouse". On a phone there is no mouse and
`RefreshIndicator` is mounted at `:174`. The **stamp** beside it keeps its job either way. Left as a
toggle (`MOBILE HEADER`) rather than decided - it is not part of C.

## The data ceiling, stated once

`NewsArticle` has exactly five fields: `title`, `link`, `description` (-> `dek`), `pubDate`,
`imageUrl`. The RSS carries **no category, no author, no source, no read state**. Any design offering
topics has to derive them locally. Scheme D does, and pays for it in the open.

## Variants

- **Today** - the control, not a candidate: `crypto_news_screen.dart` rendered at phone width.
- **A: Digest** - no photos at all. One panel, 30 headline rows, the app's own row rhythm. Shortest
  page, fewest components, and the tab becomes indistinguishable in language from Assets and Activity.
  Rejected on what it costs: a news product without pictures reads like a log.
- **B: Thumb list** - one card language, photos kept at a 72px square. The headline gets 264px of line
  instead of 147. Rejected as a whole page for one reason only: thirty identical rows have **no first
  item**, and an editorial feed wants one.
- **C: Lead + digest** ★ **CHOSEN** - the hero survives (it is the one piece of today's design that
  works at 390pt), everything behind it becomes B's rows in one panel. Search moves inside the panel,
  below the hero, so the first screen is a story rather than a search field.
- **D: C + topics** - C plus a keyword-derived topic track and a "new since you last looked" divider.
  Not taken now. The divider is cheap and exact (one `lastOpenedAt` string in the Hive box the news
  cache already uses); the topics are a `RegExp` classifier that is wrong sometimes and deserves its
  own decision against a week of real feed, not one day of it.

## Why C won, in one line

It is the only scheme that keeps a first impression **and** fixes all three defects, and it deletes two
of the three card components rather than all three.

## What to look for

- **Today** first, with **RULER** on: read the second column of tiles and count the ellipses.
- The **measured page height** under each phone. It is `scrollHeight`, read from the live DOM after
  render - not a number typed into the notes. Every photo slot has a CSS-fixed height or aspect-ratio,
  so the figure is final before a single image loads and does not move as the network fills them in.
- **NO PHOTOS** on B and C: the live feed does ship articles with a null `imageUrl`, and this is how
  each scheme degrades.
- Search states: **Search hit** keeps the hero frozen and reports in the panel; **No match** shows the
  inline line, never a blanked page. That is today's shipped rule (`:176-184`), preserved.

## Provenance

Colours verbatim from `gw_colors.dart` dark(); spacing from `genius_wallet_consts.dart`; row rhythm
from `gw_row_rhythm.dart` (wall 8, icon 38, icon-to-text 8, separator 12/1/12); page frame from
`GeniusBreakpoints.pageGutter` / `pageTitleGap`; title inset from `gwPageHeaderContentInset`
(1 + `space3` + `space4` = 15 at phone). Inter inlined from the shipping TTFs. `node --check` clean;
div balance 0; rendered in jsdom with **zero script errors** across all five schemes with every control
exercised (46 clicks).
