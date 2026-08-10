# Separator rhythm - MEASURED, 2026-08-07

What actually renders today around every horizontal rule between two list rows,
at phone width (390 x 844 logical, devicePixelRatio 3).

**Method.** Throwaway widget probes under `test/`, pumping the real widgets in
their real hosts and reading `RenderBox` geometry through the painted-ink filter
from `test/components/gw_section_title_rhythm_test.dart` (`_paintsInk` +
`firstPaintedTopBelow`, extended here with a `lastPaintedBottomAbove` twin).
No number below is a sum of source padding values. The probes were deleted; the
working tree is unchanged (`git status --porcelain` at the end of this file).

**Measured against the uncommitted type-scale restoration** in
`transaction_displays.dart` / `transactions_slim_view.dart`. That is today's
truth and it moves the Transactions numbers.

**Why the numbers are exact and not font-dependent.** Every style in
`genius_wallet_typography.dart` declares an explicit `height` multiplier, so a
`RichText`'s render box IS the line box: `titleMd` = 22, `bodySm` = 20,
`labelMd` = 18, the 16px amount override = 23. Those are the same on device as
in the harness. The one harness artefact is text WIDTH - the fallback font is
wider than Inter, so one probe row wrapped its title; that row is excluded and
flagged below.

---

## 1. The table

Distances are painted ink to painted ink. "Gap above" = last painted pixel of
the row above -> top of the drawn rule. "Gap below" = bottom of the drawn rule
-> first painted pixel of the row below. Walls are measured from the card's
INNER content edge (x = 13 at 390pt: 6 ListView gutter + 6 card pad + 1 border).

| Panel | gap above rule | rule height (drawn / layout) | gap below rule | symmetric? | row height | wall padding (icon / text) | icon size | icon placement |
|---|---|---|---|---|---|---|---|---|
| **Transactions** (dashboard panel) | **4.00** | 1 / 1 | **4.00** | **YES** (0.00 delta) | 54 | **6** / 52 | **40** | centred in the 46px content band; badge overhangs 2px |
| **Transactions** (`/transactions` page, narrow) | **4.00** | 1 / 1 | **4.00** | **YES** | 54 | 6 / 52 | 40 | identical to the panel |
| **Assets** (dashboard panel) | **15.63** | 1 / 1 | **20.00** | **NO** (+4.37 below) | 80 | **8** / 62 | **38** | centred in the full 80px row |
| **Assets** (`/assets` page) | **15.63** | 1 / 1 | **20.00** | **NO** (+4.37) | 80 | 8 / 62 (from the SCREEN edge - no gutter) | 38 | centred in the full 80px row |
| **Markets** (dashboard panel) | **13.25** | 1 / 1 | **16.75** | **NO** (+3.50 below) | 72 | **16** / 66 | **34** | centred in the full 72px row |
| Tx filter rail (desktop `/transactions` only) | 18.50 | 1 / 1 | 16.00 | NO (-2.50) | 40 | 12 | 14 (glyph) | centred |

Row-to-row **total** ink distance across the rule (gap above + 1 + gap below):

| Panel | total |
|---|---|
| Transactions | **9.00** |
| Markets | **31.00** |
| Assets | **36.63** |

Every rule in all three panels is drawn flush to its container: the panel rules
span x = 13..377 (the full 364px content box), the Assets-page rule spans
0..390 full bleed. So the rule OVERHANGS the row content by the wall value -
6px on Transactions, 8px on Assets, 16px on Markets, on each side.

Row internal vertical padding, and how much of the gap is actually controllable:

| Panel | row box | ink block | total slack | from an explicit padding | from `ListTile`'s tile snap |
|---|---|---|---|---|---|
| Transactions | 54 | 46 | 8 | **8** (4 top + 4 bottom) | 0 - no ListTile |
| Assets | 80 | 44.38 | 35.62 | 8 (4 + 4) | **27.62** |
| Markets | 72 | 42.00 | 30.00 | 0 | **30.00** |

---

## 2. Exactly how Transactions differs, item by item

Jakub's three complaints, quantified, with the line responsible.

### 2a. "The gaps between a row and the separator are completely different"

| | Transactions | Assets | Markets |
|---|---|---|---|
| gap above | 4.00 | 15.63 | 13.25 |
| gap below | 4.00 | 20.00 | 16.75 |

Transactions is **3.9x tighter above** and **5.0x tighter below** than Assets.

- Transactions: `lib/dashboard/home/widgets/transaction_displays.dart:372-374`
  - `vertical: compact ? space2 : space4` -> **4** on a phone. That 4 is the
    whole gap; there is no ListTile under it.
- Assets: `lib/components/coins/view/coin_card_row.dart:78`
  - `contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 4)`,
    but the row is a `ListTile` whose two-line default tile height is 72,
    against a 44.38 ink block. 27.62 of the 35.62 slack is Material's snap,
    not this line.
- Markets: `lib/chart/crypto_simple_chart.dart:77`
  - a bare `ListTile` with **no `contentPadding` at all**. 100% of its 30px
    slack is the tile snap. There is nothing in this repo to change.

The rules themselves are identical in all three (1px drawn, 1px layout):
`transactions_slim_view.dart:703`, `coins_screen.dart:471`,
`assets_screen.dart:572` are `Divider(height: 1, thickness: 1)`;
`dashboard_markets.dart:167` is a `Container(height: 1)` - same 1px, but it is
NOT a `Divider`, so it will not pick up a `Divider`-based or theme-based change.

### 2b. "The wall size is different"

Inset from the card's inner content edge to the row's first painted pixel:

| | icon left wall | text column x | right wall |
|---|---|---|---|
| Transactions | **6** | 52 | 6 |
| Assets | **8** | 62 | 8 |
| Markets | **16** | 66 | 16 |

- Transactions: `transaction_displays.dart:368-371`, `horizontal: compact ? space3 : space6` -> **6**.
- Assets: `coin_card_row.dart:78`, `horizontal: 8`.
- Markets: `crypto_simple_chart.dart:77`, no override -> `ListTile`'s default
  `EdgeInsets.symmetric(horizontal: 16)`.

### 2c. "The logo is displayed in a different place"

| | icon size | left wall | icon -> text gap | text column x | vertical placement |
|---|---|---|---|---|---|
| Transactions | **40** | 6 | **6** | 52 | centred in the 46px content band (row top + 7) |
| Assets | **38** | 8 | **16** | 62 | centred in the full 80px row (row top + 21) |
| Markets | **34** | 16 | **16** | 66 | centred in the full 72px row (row top + 19) |

- icon size: `transaction_displays.dart:409` (`size: 40`) vs
  `coin_card_row.dart:79` (`size: 38`) vs `crypto_simple_chart.dart:32,78`
  (`iconSize = 34`).
- icon -> text gap: `transaction_displays.dart:410-414`
  (`SizedBox(width: compact ? space3 : space6)` -> **6**) vs `ListTile`'s
  default `horizontalTitleGap` of 16, which Assets and Markets both inherit.
- Transactions additionally hangs a `TransactionBadge` 2px OUTSIDE the 40px
  icon slot (`transaction_displays.dart:246-254`, `right: -2, bottom: -2`),
  which neither of the other two has.

All three centre the icon vertically. Nothing is top- or baseline-aligned. The
"different place" is horizontal (6 vs 8 vs 16) and dimensional (40 vs 38 vs 34),
not vertical alignment.

### 2d. The `/transactions` page

**The page is byte-identical to the dashboard panel** on every number in this
document: 4 / 1 / 4, row 54, wall 6, icon 40 at +7, text at 52. Both hosts land
the card content box at x = 13, width 364 (page gutter is
`GeniusBreakpoints.pageGutter` = 6 at phone, `transactions_screen.dart:78-83`;
the dashboard gutter is `space3` = 6, `dashboard_screen.dart:355`). The page
differs only in what sits ABOVE the list - a `GWPageHeader` plus the filter bar
instead of a `GWSectionTitle` - and in being uncapped. Fixing the panel fixes
the page for free.

---

## 3. App-wide separator survey

Every place in `lib/` that draws a horizontal rule. "M" = measured with a widget
probe, "D" = derived from explicit padding with no `ListTile` in the path.

### Between LIST ROWS - in scope for a shared value

| file:line | separates | rule | gap above / below | method |
|---|---|---|---|---|
| `lib/dashboard/home/widgets/transactions_slim_view.dart:703` | `TransactionRow` <-> `TransactionRow` (dashboard panel AND `/transactions` page) | `Divider(1,1)` | **4.00 / 4.00** (phone) - 8 / 8 on desktop | M |
| `lib/components/coins/view/coins_screen.dart:471` | `CoinCardRow` <-> `CoinCardRow` (dashboard Assets panel) | `Divider(1,1)` | **15.63 / 20.00** | M |
| `lib/dashboard/assets/assets_screen.dart:572` | `CoinCardRow` <-> `CoinCardRow` (`/assets` page, full bleed) | `Divider(1,1)` | **15.63 / 20.00** | M |
| `lib/dashboard/chart/dashboard_markets.dart:167` | `CryptoSparkLineChart` <-> same (Markets panel). **A `Container(height:1)`, not a `Divider`** - identical 1px result, but invisible to any `Divider`/theme-level change | `Container(1)` | **13.25 / 16.75** | M |
| `lib/screens/banxa_buy_screen.dart:1373` | `TransactionRow` <-> `TransactionRow` (Buy GNUS "Your orders" rail) - the SAME row widget as Transactions | `Divider(1,1)` | **4.00 / 4.00** (phone) | D (same widget as the measured Transactions case) |
| `lib/squid_router/route_details_card.dart:104` | label/value rows in the swap route card | `Divider(1,1)` | **12 / 12**, symmetric (`EdgeInsets.symmetric(horizontal: space10, vertical: space6)` at `:81-84`) | D |
| `lib/components/cards/gw_detail_grid.dart:70` | detail rows inside the receipt / order drawers (SHARED component, 5 call sites) | `Container(1)` | **8 / 8**, symmetric (`kGWDetailRowPadding` vertical `space4`, `gw_detail_grid.dart:12-15`) | D |
| `lib/dashboard/chart/markets_table.dart:181` and `:228` | Markets PAGE table header row and data rows. **`Border(bottom:)` on the row's own `Container`**, not a `Divider` | 1px border | **12 / 12**, symmetric (`vertical: space6` on both) | D |
| `lib/dashboard/home/widgets/transactions_slim_view.dart:1190` | the filter rail's Type/Status group boundary (DESKTOP page only) | `Divider(1,1)` in a `Padding(vertical: space4)` | **18.50 / 16.00** | M |
| `lib/network/network_page.dart:130`, `:155`, `:181` | bare `ListTile`s on the debug Network page | bare `Divider()` - **layout height 16**, line centred | ~7.5 / ~7.5 layout, plus each `ListTile`'s own snap on top | D (partial - ListTile in the path, not measured; debug screen) |
| `lib/account/sdk_account_manager.dart:256` | menu items in the SDK account menu | `Divider(height: 9, indent: 12, endIndent: 12)` | 4 / 4 layout, indented 12 | D |

### SECTION separators - not list-row rules, listed so the sweep does not hit them by accident

| file:line | separates | gap above / below | method |
|---|---|---|---|
| `lib/settings/settings_screen.dart:338` | a settings card's title from its body | bare `Divider()` = **16 layout**, line centred -> ~7.5 / ~7.5 | D |
| `lib/logs/submit_logs_screen.dart:603` | the feedback form from its status/CTA block | **24 / 24** (`space12` `SizedBox` on each side) | D |
| `lib/dashboard/chart/markets_hero_card.dart:154` | the hero price block from the 2x2 stat grid | **24 / 24** (`space12` each side) | D |
| `lib/tokens/token_info_screen.dart:1492` | the plot from the 24h low/high footer | **12 / 12** (`space6` each side) | D |
| `lib/reown/approve_transaction_drawer.dart:64`, `lib/reown/approve_dapp_connection_drawer.dart:72` | drawer header from body | derive at the call site if included | D |
| `lib/components/bottom_drawer/responsive_drawer.dart:310` | drawer header hairline | header chrome, not a list rule | D |
| `lib/banxa/banxa_components/order_card.dart:79` | order info rows, mid-card | `Divider(height: 20)` -> 9.5 / 9.5 layout | D |
| `lib/web/web_view_windows.dart:460` | debug/dev web view chrome | bare `Divider()` = 16 layout | D |
| `lib/dashboard/home/widgets/transactions_slim_view.dart:926` | `PopupMenuDivider` in the filter overflow menu | menu chrome, Material-owned | D |

### NOT horizontal separators - excluded

- `lib/components/overlay/responsive_overlay.dart:87` `_trackDivider` is
  `Container(width: 1, height: 22)` - a VERTICAL rule inside the navbar control
  track. Out of scope.
- `lib/theme/theme.dart:382` sets `dividerTheme.color` only, never a height, so
  every bare `Divider()` in this repo still takes Material's default 16px
  layout height. A theme-level change can reach colour but NOT the gap.

---

## 4. The range the sweet spot must sit in

Measured extremes, phone, list-row rules only:

- **Minimum rendered gap: 4.00** - Transactions, both sides.
- **Maximum rendered gap: 20.00** - Assets, below the rule.
- Second-highest: 16.75 (Markets, below), then 15.63 (Assets, above),
  then 13.25 (Markets, above).

So any single shared value has to be proposed inside **[4, 20]**.

Useful reference points inside that band:

- midpoint of the two panels Jakub named, Transactions 4 vs Assets 17.8 (its
  own above/below average): **~10.9**
- midpoint of the raw extremes 4 and 20: **12**
- the value already used symmetrically by three other row lists in the app -
  `route_details_card.dart`, `markets_table.dart` header and data rows: **12**
- the value used by the shared `GWDetailGrid`: **8**
- tokens available on the grid inside the band: `space4` 8, `space3` 6,
  `space6` 12, `space8` 16, `space10` 20.

`space6` = **12** is the only value in the band that is simultaneously on the
4-pt grid, the midpoint of the measured extremes, and already the shipped
symmetric value at three other row-list sites. That is a measurement, not a
recommendation - the pick is Jakub's.

---

## 5. What surprised me / what contradicts the request

**1. The premise is backwards on the one point that decides how hard this is.**
The request says "Transactions is the one drifting" and asks to adopt the
Assets/Markets structure. Transactions is the only one of the three whose
separator gap is an actual decision anybody made: 4px, from one explicit
`EdgeInsets.symmetric(vertical: ...)`. Assets and Markets get 27.62 and 30.00 of
their slack from Material's default `ListTile` tile height (72 for a two-line
tile), which no line in this repo chose and no token controls. Adopting "the
Assets structure" for the gap means adopting an unowned Material default.

**2. Neither Assets nor Markets is symmetric around its own rule, and
Transactions is.** Assets renders 15.63 above / 20.00 below (+4.37); Markets
13.25 / 16.75 (+3.50); Transactions 4.00 / 4.00 exactly. The two "correct"
panels each sit visibly lower in their own gap than the "drifting" one. Any
app-wide value that is a single number implicitly fixes an asymmetry that has
been shipping in both of them.

**3. Assets and Markets do not agree with each other**, so "use the structure
from Assets and Markets" is under-specified at three of the four items:
wall 8 vs 16, icon 38 vs 34, gap 15.63/20.00 vs 13.25/16.75. They agree only on
the icon-to-text gap (16, both inherited from `ListTile`) and on centring the
icon. A pick between them is needed before Transactions can be aligned to
anything.

**4. `GWSectionTitle`'s `contentTopInset` values are load-bearing on this.**
`dashboard_markets.dart:127` declares `contentTopInset: 16.75` and my probe
measures the Markets row's own top inset at exactly 16.75; `coins_screen.dart`
deliberately declares 0 because its total band now sits first. Changing the
row's vertical padding to hit a separator target will silently break the
title -> first-row rhythm that `gw_section_title_rhythm_test.dart` pins. The two
numbers are coupled and must move together.

**5. The Markets rule is not a `Divider`.** `dashboard_markets.dart:167` draws a
`Container(height: 1, color: gw.borderSubtle)`. Same pixel today, but a rollout
implemented as "change the Divider" or "change `dividerTheme`" will miss it -
along with `markets_table.dart:181,228`, which draw theirs as a `Border(bottom:)`
on the row container, and `gw_detail_grid.dart:70` and `token_info_screen.dart:1492`,
which are also `Container`s. Four of the ten in-scope sites are not `Divider`s.

**6. The `/transactions` page needs no separate work.** It renders the identical
`TransactionRow` in an identically-sized card box; every number matches the
dashboard panel to two decimal places.

**7. Assets-page rules are full bleed and panel rules are not.** On `/assets`
the rule spans the whole 390pt screen and the icon sits 8px from the bezel
(`assets_screen.dart:340-390` puts a `horizontal: 12` `Padding` on the header,
search and kicker but NOT on the rows). If the rollout touches walls as well as
gaps, that page needs a decision of its own.

**8. One probe row wrapped its title** (the harness's fallback font is wider
than Inter), producing a 90px row and a 12.00 gap-above instead of 15.63. It is
excluded from every number above. Called out so nobody re-runs a probe, sees 12,
and thinks the measurement is unstable - it is a text-width artefact of the
harness, and it never happens on device.

---

## Working tree after measuring

```
$ git status --porcelain
 M lib/dashboard/home/widgets/transaction_displays.dart
 M lib/dashboard/home/widgets/transactions_slim_view.dart
 M test/dashboard/dashboard_section_caps_test.dart
 M test/dashboard/transaction_row_test.dart
?? .planning/quick/260807-ubg-restore-transaction-row-type-scale-every/
?? .planning/quick/260807-v6m-dashboard-panel-bottom-inset-mirrors-the/
```

Identical to the state at the start of this task - the four modifications are
the pre-existing type-scale restoration, and the two untracked directories are
planning folders. Every probe file was deleted. Nothing in `lib/` was touched.
