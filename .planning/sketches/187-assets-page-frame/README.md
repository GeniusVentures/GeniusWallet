---
sketch: 187
name: assets-page-frame
question: "Does /assets need a breadcrumb, and should it be boxed like the Home panels?"
winner: null   # C vs D open, pending 188
tags: [assets, page-frame, navigation, mobile]
---

# Sketch 187 - the Assets page: breadcrumb, boxes, and what the page actually is

http://localhost:8899/187-assets-page-frame/

Sketch 177 decided what `/assets` **is** (variant D: search plus one value sort) and it shipped. This
sketch decides how it is **framed**: does a tab carry a back link, and does a full page use the boxes
Home uses.

## What is on the page today

`lib/dashboard/assets/assets_screen.dart`, 666 lines, all shipped:

| Element | Where |
| --- | --- |
| `GWBackLink` "‹ HOME" | `:342` |
| `GWPageHeader` "Assets" + total in `trailing` (20px w700, then the 24h move) | `:356`, `:404` |
| `GWSearchField` "Search assets", local filter only | `:361` |
| `GWKicker` count + `VALUE ↓` toggle | `:378`, `:610` |
| `CoinCardRow` + `Divider(borderSubtle)` | `:546` |
| Five states: loading / error / no coins / no matches / list | `:439-575` |
| Pull to refresh, no timer of its own (3-min Hive cache shared with `CoinsScreen`) | `:271` |
| Order: GNUS pinned, then unpriced holdings, then value | `assets_sort.dart:26` |

The page is flat: no box anywhere, `maxWidth: xxl`, one scroll view.

## Three findings that decide it

1. **`/assets` is already a bottom-bar tab.** `nav_destinations.dart:143-146` -
   `mobileDestinations` is Home, Assets, Swap, Activity, News (S7, awaiting the device walk). The
   back link was written when the only way in was **View all** from the dashboard.
2. **Assets is the one page-header screen that does not use the shared frame.** It hardcodes
   `space32` (64) on top and `horizontal: 12` at the sides (`:292`, `:351`); every sibling calls
   `GeniusBreakpoints.pageTitleGap` / `pageGutter`, which on a phone are **24 and 6**
   (`breakpoints.dart:32-41`). On a phone the Assets title sits 40px lower and 6px further in than
   the Transactions title.
3. ~~**Boxes are a dashboard device.** No full page uses `DashboardScrollContainer` - not
   Transactions, not Markets, not News.~~ **WRONG, corrected 2026-08-08 while building sketch 188.**
   `transactions_slim_view.dart:483` wraps the transaction list in `DashboardScrollContainer` on the
   phone page; Markets draws a `GWCard` per coin (`markets_cards.dart:57`) and News one per article
   (`crypto_news_screen.dart:452`). **Assets is the only unboxed list in the app.** The container
   recipe and the 14px width cost stand; the conclusion drawn from them does not. See
   `.planning/sketches/188-transactions-page-frame/`.

## Variants

- **A: Flat tab** - recommendation WITHDRAWN 2026-08-08 (see finding 3); no box, no back link, `pageGutter` 6 and `pageTitleGap` 24. The
  total stays in the header trailing. Carries an **AS SHIPPED TODAY** toggle that puts the 64/12
  frame and the back link back, so the before/after is one click apart.
- **B: Value card + flat list** - one box for the summary: total at 32px, the 24h move, and an
  allocation bar computed from `value / total`. Rows below stay flat.
- **C: Boxed panels** ★ recommended after the correction - two boxes, the Home recipe exactly. Cost is
  measurable, not argued: row content width drops from 362 to 348 on a 390pt phone, which is exactly
  what `/transactions` already pays.
- **D: C without boxes** - added 2026-08-08 at Jakub's ask. C's structure, A's flatness: the total
  leaves the header and becomes the dashboard's own band (`_AssetsTotalBand`, `coins_screen.dart:530`)
  flat under the title. Toggles for the number's size (24 dashboard / 32 display) and the kicker.

## What to look for

- Flip every scheme to **ZERO BALANCES** first. That is Jakub's wallet, and a design that only works
  funded is a design that looks broken most of the time.
- On A, toggle **AS SHIPPED TODAY** and watch the title fall 40px and the back link appear over a
  bottom bar whose Assets tab is already lit.
- On C, turn **RULER** on: a card border 6px inside a page gutter, inside the phone bezel.
- Compare B's allocation bar funded and at zero. At zero it is an inert `surfaceSunken` track with no
  legend, on purpose.

## Provenance

Colours verbatim from `gw_colors.dart` dark(); spacing from `genius_wallet_consts.dart` (the token is
half the pixel value: `space3` = 6, `space32` = 64); row rhythm from `gw_row_rhythm.dart` (wall 8,
icon 38, icon-to-text 8, separator 12/1/12). Inter inlined from the shipping TTFs, copied from sketch
186. Phone is 390x844 at 1:1 with the real bar geometry (60 app bar, 80 bar body in a 106 box, 64
dock, 26 overhang, 84 slot). Prices are illustrative; every total, weight and percentage on the page
is computed from them live. `node --check` clean on the script; div balance 0; rendered in jsdom with
zero script errors across all three schemes and all three data states.
