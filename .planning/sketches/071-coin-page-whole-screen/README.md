---
sketch: 071
name: coin-page-whole-screen
question: "The coin page reads weak. Why, measurably - and what is the whole screen, navbar included, when it is re-composed on components the app already ships?"
winner: "B · Stat rail - chosen by Jakub 2026-07-28 (\"na reszte sie zgadzam, mozemy leciec\"), with the null-marketData state answered the same day: an explicit no-data message, not a silent collapse."
tags: [coin-detail, token-info, page-layout, navbar, shell-route, gw-page-header, page-frame, data-honesty, supersedes-061, follows-070, follows-152]
lane: execution
---

# Sketch 071: The coin page, the whole screen

Jakub, 2026-07-28: *"zrób redesign tego całego screenu, łącznie z navigation barem u góry"* -
*"bo wygląda słabo"*.

The card layer inside this page was rebuilt hours earlier (sketch **070-A**, quick 260728-t3n). This
is the layer around it, and it is where the "weak" actually comes from.

## Relationship to sketch 061

**061 asked the same question and is still `winner: null`.** It framed the chrome problem correctly
(no navbar, wrong frame, `AppBar` instead of `GWPageHeader`) and its ★A is the same move variant A
makes here. What 061 did **not** have is the measurement that explains the complaint:
`SizedBox(height: 480)`. So 071 supersedes it rather than duplicating it - 061's variants B/C/D/E
remain readable as alternatives, and its finding about the model's unused fields is what variant B
here spends.

## How to view

```
open .planning/sketches/071-coin-page-whole-screen/index.html
```

Four variants at three real widths (1536 / 1280 / 900), dark and light, with the app's real navbar
drawn on top. Variant 0 draws the empty page to scale.

## Findings from the code

**1 · `SizedBox(height: 480)` - one literal, and it is most of the problem.**
`_buildMainCard` (`token_info_screen.dart:311`) hard-codes 480px. The Info + Convert column beside it
comes out around 530. So on a 1335px-tall window the content **ends near 620px and the rest of the
page is empty**. Nothing is broken and nothing overflows; the layout simply never asks for the room it
has. This is the reason the screenshot reads as thin.

**2 · It is the only screen in the app with no navbar.** `GoRoute('/token-info')` sits **outside** the
`ShellRoute` (`router.dart:243`; the shell closes at 242). Dashboard, Swap, Markets, News, Settings
are all inside. From a coin you cannot reach News without going back first.

**3 · It uses a different page frame.** `maxWidth: 1200` centred with `space10` padding, where
Markets / Transactions / News use `xxl` (1536) with a **12px gutter**. On a 1500px window the title
lands ~170px further in than "Markets" does - and you cross between the two frames with one click.

**4 · The model carries 24 fields; the page shows 6.** `CoinGeckoMarketData` already holds
`marketCapRank`, `high24h`, `low24h`, `fullyDilutedValuation`, `ath` + `athChangePercentage` +
`athDate`, `atl`, `maxSupply`, `priceChange24h`, `marketCapChangePercentage24h`, `lastUpdated`. All
in Hive, all fetched. **Filling the void costs zero new requests.**

## Variants

| | Variant | Top of the screen | The void | Cost |
|---|---|---|---|---|
| **0** | **Today** | `AppBar` + breadcrumb, no navbar | ~50% of the page | - |
| **A** | **In the frame** | real navbar + `GWPageHeader`, back chip, price in `trailing` | chart takes the height instead of 480 | a router move |
| **B** ★ | **Stat rail** | same as A | a KPI row from fields the model already has, chart full width | one new tile shape |
| **C** | **Your position** | same as A | a holdings panel: balance, value, share | changes what the page is *about* |

**A, B and C share the same three fixes**, because those are defects rather than design: into the
`ShellRoute`, onto the 1536/12 frame, and a chart height from the viewport instead of a literal. They
differ only in what fills the space that frees up.

## What to look at

1. **Switch 0 → A and watch the top of the window.** The biggest change on this page is invisible in
   a screenshot of the content.
2. **Look at the bottom of variant 0.** The red hatch is real empty page, drawn to scale for a 1335px
   window.
3. **Drop to 900.** Below 1024 the layout already stacks; check your favourite survives it, because
   152-D froze the <768 layout and any variant still has to arrive there.
4. **Send and Swap are grey everywhere**, because they are genuinely disabled (D-01/D-02) and More is
   GNUS-gated. A variant that only looks good with a full row of live buttons would be lying.

## Recommendation

**★ B · Stat rail.** A fixes the structure but leaves a taller chart in a page that is still thin; B
fixes the structure **and** the emptiness, out of data already sitting in Hive. The KPI tile is the
only new shape, and it is `GWCard` + `GWKicker` + a value - the Markets hero already reads this way,
and Markets is the page you arrive from.

**Runner-up: A · In the frame.** The honest minimum, and a large improvement on its own: navbar, one
frame, a chart that uses the window. Take it if the page should be repaired rather than re-composed.
It is **strictly a subset of B**, so choosing it is never wasted work.

**Rejected: C · Your position.** It reads well and answers the wrong question. This page is reached
from **Markets**, where you are looking at what something is worth, not at what you hold - the
dashboard already answers that, and Receive/Send/Swap are one row away here anyway. C also degrades
to nothing for a coin you do not own, which on Markets is most of them.

## Data provenance - traced, not assumed

Asked directly by Jakub before planning: *do we have all the data, and does B force a code/logic
change?* Traced end to end.

**The request already asks for everything.** `coin_gecko_api.dart:140`:

```
https://api.coingecko.com/api/v3/coins/markets?vs_currency=usd&ids=...&sparkline=true
```

`/coins/markets` returns `market_cap_rank`, `high_24h`, `low_24h`, `price_change_percentage_24h`,
`ath_change_percentage`, `total_volume`, `fully_diluted_valuation`, `max_supply` and the rest **by
default**. No parameter is missing.

**Every one is already parsed and already cached.** `CoinGeckoMarketData.fromJson` (line 116) maps all
24, and they are written to the `marketDataBox` Hive box with a **3-minute** TTL
(`cacheDuration`, line 13) plus a stale-entry fallback. So a "24h change" tile is at worst 3 minutes
old, which is the same freshness the Markets table already ships.

| B's tile | field | state |
|---|---|---|
| Rank | `marketCapRank` | parsed, cached |
| 24h change | `priceChangePercentage24h` | parsed, cached |
| 24h volume | `totalVolume` | parsed, cached, **already on screen** |
| Market cap | `marketCap` | parsed, cached, **already on screen** |
| From ATH | `athChangePercentage` | parsed, cached |
| 24h range | `high24h` + `low24h` | parsed, cached |

**So: zero API change, zero model change, zero new Hive box.** B spends data the app already pays for.

### Three things B does have to handle in code

**1 · Missing values arrive as `0`, not as `null`.** `fromJson` defaults every numeric to `0.0` and
the rank to `0`. So an absent field would render as `#0`, `$0.00` and `0.00%` - stated confidently and
wrong. The Info card already dodges this: `_formatCompactCurrency` and `_formatCompactDecimal` both
return `"N/A"` when the value is `0` or null. **The KPI tiles need the same rule**, and it exists
twice in this file already, so this is reuse rather than new logic. `maxSupply` is the one honest
exception - it is genuinely `double?`.

**2 · `marketData` can be NULL on this page, and that is a defect today.** Four routes push
`/token-info`; three of them (Markets table, Markets search, dashboard Markets) carry a real
`CoinGeckoMarketData`. The fourth, the wallet's own Assets list, passes
`_marketData[coin.symbol?.toLowerCase()]` (`coins_screen.dart:296`) - **a map lookup that returns null
for any wallet coin CoinGecko does not cover.** The layout then hits
`if (marketData != null)` around the main card, so **the hero, the action bar and the chart all
disappear** and the page is Info + Convert alone. That is not a B problem; it is the current page's
emptiest state and nobody has drawn it. **B must draw it, and so must A.**

**3 · Date fields fall back to epoch 0 on a parse failure.** `_parseDateTime` returns
`DateTime.fromMillisecondsSinceEpoch(0)`, so a bad `ath_date` prints **1 Jan 1970**. B's recommended
tiles use no dates, so it does not hit this - but any tile showing "ATH on ..." would, and that is
worth knowing before someone adds one.

### What B does NOT touch

The chart is a **separate** fetch (`historyApi`, line 47) with its own cache, unchanged by any variant
here. The sparkline in the market response is used by the Markets hero, not by this page.

### Decision - 2026-07-28 (Jakub)

**B, and the null-`marketData` state gets an explicit message** - *"ok, więc wtedy no data czy coś"*.
So the fourth entry point (a wallet coin CoinGecko does not cover) stops silently dropping the hero,
the action bar and the chart, and says so on `GWEmptyState`, which already exists. The action bar
should survive that state where it can - Receive does not need a market price.

**Confirmed before approval: no backend work.** Same endpoint, same model, same Hive box, no new
request. The only logic touched is formatting - routing the KPI numbers through the existing
"0 means unknown" rule that `_formatCompactCurrency` already applies on this very screen.

## The KPI tile - corrected, then decided

**This section originally said the pattern already existed twice** (`markets_hero_card` "and the
dashboard has another"), making B's tile a third instance that cleared the promotion bar
automatically. **That was wrong and was corrected during implementation.** `grep` for
`GWKicker(dense:` returns exactly ONE hit in the whole app: `markets_hero_card.dart:263`, the private
`_Stat` used four times inside the Markets hero card. The dashboard has nothing like it. So the coin
page made it a **second file**, under the 3+ bar.

**Jakub overrode the file count on the instance count** and asked for the component anyway, both
places migrated: *"utworz component zatem by byl i by oba miejsca go uzywaly"*. Ten uses of one
two-line widget, and the widget is small enough that a component costs less than a second copy.
Shipped as `lib/components/cards/gw_stat_tile.dart`, values taken verbatim from `_Stat` so the
Markets hero moved nothing on screen.

## What this does NOT propose

- No change to the chart library, the sparkline data, or the range controls (the zoom/pan row has its
  own filed todo).
- No 1H/1D/1W tabs - there is still no per-range fetch, which sketch 152 already settled.
- No change to `TokenActionBar`, `CoinInfoCard` or `CoinConvertCard` - all three are 070-A, shipped.
- Send/Swap stay disabled and More stays GNUS-gated.

## MANIFEST row

```
| 071 | coin-page-whole-screen | The coin page reads weak. Why, measurably - and what is the whole screen, navbar included, when re-composed on components the app already ships? | **Recommended B · Stat rail** - the A fixes plus a KPI row (rank / 24h change / 24h volume / market cap / from ATH / 24h range) built from fields ALREADY in Hive, chart full width beneath. Runner-up A · In the frame (navbar + one frame + a viewport-driven chart; a strict SUBSET of B so never wasted). Rejected C · Your position (answers "how much do I hold" on a page reached from Markets, where the question is "what is it worth" - and degrades to nothing for coins you do not own, i.e. most of them). **Findings, and the first is the whole complaint: `SizedBox(height: 480)` at token_info_screen.dart:311** - with a ~530px side column, content ENDS near 620px on a 1335px window, so roughly half the page is empty; nothing overflows, the layout just never asks for the room. **It is the only screen in the app outside the ShellRoute** (`router.dart:243`, shell closes at 242) so it is the only one with no navbar - from a coin you cannot reach News without going back. **It uses a different page frame** (1200 centred + space10 vs the 1536 + 12px gutter every tab uses), so its title lands ~170px further in than "Markets" does, one click away. **The model carries 24 fields and the page shows 6** - rank, 24h high/low, FDV, ATH+%, ATL, max supply, price change 24h are all in Hive already, so filling the void costs ZERO new requests. All three variants share the same three fixes because those are defects, not design. **Supersedes 061** (same chrome question, still winner:null, but without the 480 measurement that explains the complaint). To argue when B is planned: its KPI tile would be the THIRD hand-rolled "small labelled number in a box" (markets_hero_card has one, the dashboard another), which is exactly the promotion bar GWKicker/GWSelectRow/GWWarningNote each cleared. | coin-detail, token-info, page-layout, navbar, shell-route, gw-page-header, page-frame, data-honesty, supersedes-061, follows-070, follows-152 |
```
