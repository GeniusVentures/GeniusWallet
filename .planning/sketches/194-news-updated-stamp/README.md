---
sketch: 194
name: The "Updated" stamp and its icon on Crypto News
question: >
  On a phone, where does the Crypto News freshness control belong - the
  "Updated 2m ago" stamp, its refresh glyph, and the pair together?
winner: null
tags: [news, header, refresh, freshness, icons, mobile, gw-page-header, placeholder]
---

# 194 - the "Updated" stamp and its icon

Open at **http://localhost:8899/194-news-updated-stamp/**

## The request, and how it was read

Jakub, 2026-08-09, looking at the freshly shipped Crypto News scheme C on his iPhone:

> "one last thing about Crypto News. Please think about how we can present this in the
> updated form, including that icon. I have the impression it looks weird, so prepare three
> or four designs for how to improve it there."

**This is an interpretation, not a fact.** "The updated form" is read as the **"Updated …"
stamp**, and "that icon" as the refresh glyph beside it - together `_UpdatedStamp`
(`crypto_news_screen.dart:241-297`), which the page mounts as `GWPageHeader.trailing`
(`crypto_news_screen.dart:164-174`). So the subject taken here is **the header's freshness
control: the stamp, its icon, and where the pair belongs on a phone.**

The only other icon a reader meets on this page is the broken-photo placeholder
(`_NewsPhoto.errorWidget`, `crypto_news_screen.dart:945-949`). **Scheme D covers that**, in
case the reading above is wrong.

## What the code actually does (checked before designing)

1. **The page changed today.** Below `_bandBreakpoint` (760, `crypto_news_screen.dart:337`)
   the phone renders hero + `_NewsDigestPanel`; the wide window still renders the magazine
   (`crypto_news_screen.dart:377-458`). The header is above both.
2. **`trailing` sits beside the whole identity block**, not inside the title line
   (`gw_page_header.dart:212-239`), and its own doc says why: inside the title `Row` a tall
   trailing set the row height and parked ~15px of dead row above the subtitle
   (`gw_page_header.dart:188-211`). Consequence here: **the 40px `IconButton`, not the 32px
   title line, sets the header row's height.**
3. **The ticker.** `_UpdatedStampState` owns `Timer.periodic(30s)` whose only job is to
   re-render its own label (`crypto_news_screen.dart:251-268`). The label can change at most
   once a minute, so at least half the ticks are no-ops, and after the first hour it is 119
   in 120. It is correctly scoped (the stamp, not the magazine) and cheap. **A, B and D keep
   it; C keeps it too, in the kicker.** Nothing in this sketch is motivated by removing it.
4. **The tension the request lands on.** The `IconButton` exists because "pull-to-refresh
   alone is unreachable with a mouse" (`crypto_news_screen.dart:166-169`). On a phone there
   is no mouse, and `RefreshIndicator` **is** mounted on this page
   (`crypto_news_screen.dart:210-211`). On this platform the glyph is a second door into a
   room that already has one.
5. **Its consistency argument is stale.** The code says the bare icon matches "the Markets
   header's trailing action, the magnifying glass" (`crypto_news_screen.dart:286-287`).
   Markets today is `const GWPageHeader(title: "Markets")` with no trailing
   (`markets_screen.dart:114`); Transactions (`:114`), Assets (`:395`) and the job screen
   (`:60`) have none either. The only other `trailing` callers are Buy GNUS (a `GWButton`,
   `banxa_buy_screen.dart:247`) and Swap (centred, `swap_screen.dart:655`). **News is the
   only left-aligned content tab with anything in its header trailing.**
6. **The label can be wrong.** `shortTimeAgo` (`news_article.dart:10-25`) formats
   `_lastUpdated`, which `_load` sets in `whenComplete` - success or cache hit alike
   (`crypto_news_screen.dart:74-82`). The feed returns the cache untouched for 2 minutes
   (`coin_telegraph_api.dart:12`, `:27-33`). **So a press inside that window resets the
   label to "Updated now" having fetched nothing.** T and D render that lie; A, B and C read
   the cache's own timestamp (`coin_telegraph_api.dart:97`) instead.
7. **A press blanks the page.** `_retryNews` is `setState(_load)`, which assigns a NEW future
   (`crypto_news_screen.dart:74-86`), and `FutureStateWidget` returns
   `Center(child: Loading())` for `ConnectionState.waiting`
   (`custom_future_builder.dart:28-29`). The hero and all 29 rows are replaced by a spinner -
   including on the warm-cache path that returns the same articles. The shipped icon is not
   animated, so **the page turning into a spinner is the only feedback a press gives.**
8. **The header is the only region that exists in every state.** `Expanded(FutureStateWidget)`
   replaces the whole body on cold start, on error and on an empty feed
   (`crypto_news_screen.dart:183-226`); the header sits outside it. That is why the stamp was
   made unconditional ("so the header never looks empty / jumps",
   `crypto_news_screen.dart:277-280`) - and it is what decides the ranking below.

## The variants

Every scheme renders all four states from the control strip under its phone: **Cold start**
(pre-first-fetch, `Updating…`), **Fresh** (`now`), **3h old** (`3h ago`), and **Warm cache**
plus a press, which fetches nothing because the 2-minute cache is still warm.

| | Scheme | Header trailing | Refresh on a phone | Warm press says |
|---|---|---|---|---|
| **T** | as shipped | `Updated 2m ago` + 40px `IconButton` | icon **and** pull | "Updated now" - a lie, and the body blanks |
| **A ★** | the stamp without the button | `Updated 3h ago`, plain text | pull only | "Updated 1m ago" - unchanged, correctly |
| **B** | one object, not two | a 36px pill: `⟳ 3h ago` | the pill **and** pull | "Up to date", then back to 1m ago |
| **C** | freshness belongs to the list | nothing | pull only | "ALREADY UP TO DATE" in the kicker |
| **D** | the other icon | as shipped | as shipped | as shipped (the lie is drawn) |

**A ★ - recommended.** Mount the `IconButton` only under
`GeniusBreakpoints.useDesktopLayout(context)` - the same test that already decides where the
search field lives (`crypto_news_screen.dart:151-182`). Desktop keeps a mouse-reachable
refresh, which is the only place its comment was ever true; the phone keeps the sentence.
Zero new components, zero new widgets, header row 40 -> 32px, and the freshness fact stays in
the one region of the page that survives every state. It is also the change that makes the
News header identical to Transactions, Markets and Assets.

**B - runner-up.** If the header should keep a tap target, it should be **one** object rather
than a sentence plus a button that repeats what the sentence is about. A 36px pill, hairline
border, `surfaceSunken`, `radiusPill`, glyph 16 then the age at 13/600; the whole pill is the
target and the glyph is its leading mark, not a button. It is the only scheme where a press
can answer "nothing came back" in words. Two costs, both stated on the page: 36px needs a
transparent inset to reach a 44px target, and in light mode the label must be `textPrimary`
(`textSecondary` #5A606E on light `surfaceSunken` #CFD4DB is **4.23:1**, under AA).

**C - rejected.** It produces the cleanest header in the set by moving the stamp into the
digest kicker, taking the `NEWEST FIRST` slot that the code itself nominates as droppable
(`crypto_news_screen.dart:626-628`). Then the states break it: the panel does not exist on
cold start, on error or on an empty feed, so in the three states where "how fresh is this?"
is the real question the page says nothing. In the fourth state it prints "UPDATED 3H AGO"
one line above 29 green story ages from the same formatter (`_MetaLine`,
`crypto_news_screen.dart:904-926`) - the same words for a different fact.

**D - second reading, orthogonal.** `Icons.broken_image_outlined` is drawn at Flutter's
default 24px at every photo size, because `errorWidget` does not know how big it is: 11% of a
72px thumbnail, 0.7% of the 378x213 hero. And a torn photograph is the wrong word - nothing
is broken, the feed simply shipped no image, and the row still has a headline, a dek and an
age. D is size-aware and quiet: **no glyph at all under about 96px**, and
`Icons.image_not_supported_outlined` at 20px in `textSecondary` (6.20:1 on dark
`surfaceSunken`) at hero and tile size. Cheap either way, and it conflicts with nothing.

## What to look for

- Put **T** in **Warm cache** and press the refresh glyph: the hero and all 29 rows vanish
  into a spinner, and the label comes back saying **now** although nothing was fetched.
  Then do the same on **A** and **B**.
- Put **C** in **Cold start**: the freshness disappears from the page entirely. Compare with
  **A** in the same state, where the page's only words are the title and `Updating…`.
- Turn **ruler** on (dashed tab, top right): the header box, the trailing, the 40px icon
  button, the kicker and the pull zone are all outlined.
- **D**: switch photos to **All fail** and compare the 72px rows against the `today 72` plate
  in the control strip, which draws the shipped 24px glyph at 1:1.

## Icon fidelity

No SVG path in this sketch is hand-drawn. Every glyph is the real Material outline extracted
from the Flutter SDK font (`MaterialIcons-Regular.otf`, codepoints read from
`packages/flutter/lib/src/material/icons.dart`), flipped with `Transform(1, 0, 0, -1, 0, 512)`
into a top-down `viewBox="0 0 512 512"` and rendered **filled**. Newly extracted for this
sketch, with their measured bounding boxes in the 24 grid:

| glyph | codepoint | bbox in the 24 grid |
|---|---|---|
| `refresh` | 0xe514 | (4.0, 4.0) - (20.0, 20.0) |
| `broken_image_outlined` | 0xeeff | (3.0, 3.0) - (21.0, 21.0) |
| `image_not_supported_outlined` | 0xf11f | (0.7, 2.1) - (21.9, 23.3) |
| `hide_image_outlined` | 0xf0fa | (1.4, 2.8) - (21.2, 22.6) |
| `search` | 0xe567 | (3.0, 3.0) - (20.5, 20.5) |
| `done` | 0xe1f6 | (3.4, 5.6) - (21.0, 19.0) |
| `arrow_downward` | 0xe097 | (4.0, 4.0) - (20.0, 20.0) |
| `article_outlined` | 0xee93 | (3.0, 3.0) - (21.0, 21.0) |
| `dashboard_outlined` | 0xefa1 | (3.0, 3.0) - (21.0, 21.0) |
| `account_balance_wallet_outlined` | 0xee33 | (3.0, 3.0) - (22.0, 21.0) |
| `swap_vert_rounded` | 0xf01fc | (5.7, 3.2) - (18.3, 20.8) |
| `menu` | 0xe3dc | (3.0, 6.0) - (21.0, 18.0) |
| `schedule` | (pre-extracted) | - |

Sanity check on the flip: `done` measures x 3.41..21.0, y 5.59..19.0, which is exactly the
published Material path `M9 16.17L4.83 12l-1.42 1.41L9 19 21 7l-1.41-1.41z`. `refresh` at
4..20 in both axes is the expected inset for a circular arrow. Both look right.

One substitution is declared: the Activity tab in the bottom bar is
`FontAwesomeIcons.clock.data` (`nav_destinations.dart:157-160`), which lives in a different
font; the bar here draws Material `schedule` in its place. The bottom bar is scaffolding, not
the subject.

## Provenance

Every value on the page came from one of these:

- `lib/dashboard/news/view/crypto_news_screen.dart` - `:74-86` `_load` / `_retryNews` and the
  `whenComplete` stamp; `:151-182` the `wide` decision and where the search field is mounted;
  `:164-174` `GWPageHeader(title: 'Crypto News', trailing: _UpdatedStamp(...))`; `:166-169`
  the "unreachable with a mouse" comment; `:183-226` `Expanded(FutureStateWidget(...))` and
  the empty state; `:210-211` `RefreshIndicator`; `:241-297` `_UpdatedStamp`; `:251-268` the
  30s `Timer.periodic`; `:277-280` "always shown … so the header never looks empty";
  `:285-293` `space4` + the compact `IconButton` with an 18px `Icons.refresh`; `:286-287` the
  stale "matches Markets" comment; `:337` `_bandBreakpoint = 760`; `:377-395` the narrow
  hero + `space3` + digest panel; `:575-665` `_NewsDigestPanel`; `:608-635` search field,
  `space6`, the dense `GWKicker` at the `space4` wall, `space4`; `:626-628` "NEWEST FIRST …
  could go without changing what the page does"; `:656-660` the rows and the `borderSubtle`
  `Divider`; `:682` `_thumb = 72`; `:904-926` `_MetaLine` (compact age, `statusSuccess`,
  w600); `:945-949` `_NewsPhoto.errorWidget` (`surfaceSunken`, `Icons.broken_image_outlined`,
  `textSecondary`).
- `lib/components/scaffold/gw_page_header.dart` - `:44-49` `gwPageHeaderContentInset` =
  `1 + space3 + space4` = **15** at phone width; `:137` title is `headlineLg`; `:188-211` why
  `trailing` sits beside the identity block; `:212-239` the `Expanded` identity + trailing
  row; `:269` the `space8` the header owns below itself.
- `lib/hive/models/news_article.dart` - `:10-25` `shortTimeAgo` (`now`, `12m ago`, `3h ago`,
  `2d ago`, `4w ago`), ported verbatim into the sketch; `:69` `dek` strips the RSS HTML;
  `:75-78` `relativeTimeShort`.
- `lib/services/coin_telegraph/coin_telegraph_api.dart` - `:12` `cacheDuration = 2 minutes`;
  `:27-33` the warm-cache early return; `:97` `timestampBox.put('timestamp', now)` - the
  fetch instant A, B and C read.
- `lib/components/custom_future_builder.dart` - `:28-29` `waiting` returns
  `Center(child: Loading())`, which is what blanks the body on every refresh.
- `lib/dashboard/chart/markets_screen.dart:114`, `lib/dashboard/transactions/transactions_screen.dart:114`,
  `lib/dashboard/assets/assets_screen.dart:395`, `lib/submit_job/view/submit_job_screen.dart:60` -
  the four left-aligned page headers with **no** trailing.
- `lib/screens/banxa_buy_screen.dart:247` and `lib/squid_router/swap_screen.dart:655` - the
  only other `GWPageHeader.trailing` callers (a `GWButton`, and an `IconButton` on the
  centred form).
- `lib/utils/breakpoints.dart` - `:32-34` `pageTitleGap` = `space12` = 24 on a phone;
  `:40-41` `pageGutter` = 6 on a phone.
- `lib/theme/genius_wallet_consts.dart` - `:19-34` the spacing tokens; `:41-48` the radii.
- `lib/theme/genius_wallet_colors.dart` - `:119-146` `surfaceBase` #0B0D12,
  `surfaceElevated` #0C0E14, `surfaceMenu` #171A21, `surfaceSunken` #06080C (dark) /
  #CFD4DB (light); `:181-183` `textSecondary` #8A8F9D; `:193-199` `borderSubtle` white 12%.
  `lib/theme/gw_colors.dart:303-305` light `textSecondary` #5A606E, `:473` dark
  `statusSuccess` #0AD89C.
- `lib/theme/genius_wallet_typography.dart` - `:84-89` `headlineLg` 24/32 w600;
  `:91-92` `headlineMd` 20/28; `:98-99` `titleMd` 16/22 w500; `:108-120` `bodyMd` 16/24 and
  `bodySm` 14/20.
- `lib/components/inputs/gw_text_field.dart:389-424` - `GWSearchField`: `radiusLg`, a
  hairline that becomes a 2px gradient ring on focus, `Icons.search` at 20.
- `lib/dashboard/home/view/dashboard_screen.dart:395-425` - `DashboardScrollContainer`:
  `radiusLg`, `borderSubtle`, `space3` of padding at phone width.
- `lib/components/overlay/nav_destinations.dart:137-167` - the four mobile bar destinations
  and their glyphs.
- Flutter SDK - `packages/flutter/lib/src/material/button_style_button.dart:580-584`
  (`MaterialTapTargetSize.padded` -> `kMinInteractiveDimension + densityAdjustment`) and
  `theme_data.dart:3307-3314` (`baseSizeAdjustment` = density x 4). Together:
  48 + (-2 x 4) = **40x40** for the compact `IconButton`.

Contrast, computed for this sketch: `textSecondary` #8A8F9D is 6.01:1 on `surfaceBase`,
5.97:1 on `surfaceElevated`, 6.20:1 on `surfaceSunken` (dark). Light `textSecondary` #5A606E
is 6.30:1 on white and **4.23:1 on light `surfaceSunken`** - the one pairing a proposal must
avoid, hence B's `textPrimary` label (12.47:1 on light sunken, 20.04:1 on dark).

Content: the 30 items CoinTelegraph's RSS returned on 2026-08-09 (real headlines, deks,
timestamps and photo URLs). Ages are computed against a fixed `NOW` so the sketch is
deterministic.

## Verification

- `node --check` on the extracted inline script: **OK**
- `<div>` balance: 116 open, 116 close
- em-dash grep over `index.html`: **0** matches
- jsdom, 48 clicks across all five schemes, all four states each, plus the in-phone controls,
  the pull zone, a row tap and the ruler toggle: **ZERO script errors, all assertions passed**
