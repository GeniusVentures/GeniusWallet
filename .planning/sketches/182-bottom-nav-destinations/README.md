# Sketch 182 - which four destinations belong on the bottom bar

http://localhost:8899/182-bottom-nav-destinations/

Jakub, 2026-08-07:

> "zaproponuj jakie batony powinny byc na navigation bottom barze. Poki co mamy: home, markets, mamy
> ikone swap, activity i more. More bym zmienil na menu potencjalnie, i nie wiem czy bym zostawil
> markets i activity. Zasugeruj cos z twojej strony."

And later the same day, which changes the premise:

> "sprobuj w prawym gornym rogu zrobic ikonke walletu, czy cos podobnego w krotszej formie, i obok
> tego hamburger menu. I wtedy, zamiast 'more' na samym dole, moglibysmy dac na przyklad 'news'."

**The bar's shape is not in scope.** Sketch 171 **B** (four tabs plus a centre dock) crossed with 172
**A** (the dock is Swap) were both picked on device on 2026-08-06 and are shipped. Every scheme here
keeps four tabs and the Swap dock. What changes is which four.

## What is live, verified against the working tree this morning

`lib/components/overlay/responsive_overlay.dart` carries a mobile-only list - **Home, Markets,
[Swap dock], Activity, More** - with a 60px bar, a 64px dock overhanging 26px into an 84px reserved
slot, the active tab painted in the brand gradient through one `ShaderMask` + `brandCtaText`, and the
bottom safe-area inset capped at 20pt (`kMaxBottomSafeInset`).

Routes checked in `lib/navigation/router.dart` rather than assumed. Inside the shell:
`/dashboard`, `/transactions`, `/assets`, `/swap`, `/web`, `/markets`, `/news`, `/buy`, `/logs`,
`/settings`, `/token-info`. Outside it: `/buy/orders`, `/bridge`, `/submit_job`, `/network`,
`/checkout`, `/kyc`. **There is no `/compute` and no `/explore`** - anything proposing them is
proposing a build.

Two findings that shaped every scheme:

1. **The overflow is derived, not written.** `_moreDestinations` = all eight desktop destinations,
   minus Swap, minus whatever the mobile bar already shows. Take Markets off the bar and it appears
   in the sheet by itself. No second edit, no chance of losing it.
2. **`/assets` is not a member of `_allDestinations`.** Phase 25 added it straight to the router, so
   it cannot appear in that derived sheet at all. Today its only entrance in the entire app is the
   dashboard panel's `View all`.

## The seven sets

| | Tabs (dock is always Swap) | New routes | Verdict |
| --- | --- | --- | --- |
| Today | Home, Markets, Activity, More | - | baseline |
| S1 | Home, Markets, Activity, **Menu** | none | prerequisite, not a competitor |
| S2 | Home, **Assets**, Activity, Menu | none | **runner-up** |
| S3 | Home, Assets, Activity, **Compute** | `/compute` | right instinct, wrong slot |
| S4 | Home, Assets, Activity, **Explore** | `/explore` | tidiest long-term, superseded by S7 |
| S5 | Home, Assets, **Markets**, Menu | none | rejected - Activity leaves |
| S6 | Home, Markets, Activity, **News** | none | **rejected** - Jakub's literal second message |
| **S7** | Home, **Assets**, Activity, **News** | **none** | **★ recommended** |

S3, S4, S6 and S7 move the menu into a header hamburger, so the fourth slot becomes a destination
rather than a lid.

## Recommendation: S7 - Home, Assets, [Swap], Activity, News

It is the only set that answers both messages at once. The fourth slot stops being the one item in
the bar that is not a place. The holdings page phase 25 built reaches the bar. And a brand-new user
with an empty wallet still has one tab worth opening, which is the objection S2 could not answer.

**It needs no new routes.** `/assets` and `/news` both exist and are both inside the shell, and the
overflow shrinks to five rows on its own because it is derived.

**Runner-up: S2** - the identical set with `Menu` back in the fourth slot. Zero dependencies: one
entry swapped in `_mobileDestinations` plus a rename. Ship S2 if the header is not ready; upgrade the
fourth slot to News the moment the hamburger lands. Nothing built for one is wasted on the other.

**Explicitly rejected: S6**, Jakub's own second message taken literally - while keeping both halves
of it that are right. The hamburger move is right and is adopted. News on the bar is right and is
adopted. What S6 leaves behind is not:

- **Two of four tabs are content that belongs to nobody.** The objection raised against Markets
  applies to News word for word, and they overlap with each other - Markets is what BTC is at, News
  is why. Two doors onto one room.
- **Assets ends up with exactly one entrance in the whole app.** Not on the bar, and not in the
  hamburger either, because that sheet is derived from `_allDestinations` and `/assets` is not a
  member.
- **S6 becomes S7 with one substitution.** Trade the Markets tab for Assets and every objection
  disappears, at the price of Markets going from one tap to two.

### On Jakub's earlier leaning

The brief's own leaning was **Home, Assets, [Swap], Activity, Menu** - that is S2, and it survives
testing, but not for the reason it was offered with. "Assets and Activity are the two things a wallet
owner checks" is a claim about users nobody here has data on. What holds up is structural: the edit
is one list entry, the overflow repairs itself, and S2 is a strict prefix of both S7 and S4. Its real
weakness is on the record - on a fresh wallet three of four tabs are blank - and S7 is what fixes it.

## The hamburger is not free, and the tap count hides the cost

Taps are identical (one from anywhere, because the ShellRoute keeps the header mounted on every
pushed page). Everything around the tap is not:

| | Menu as a tab | Hamburger in the header |
| --- | --- | --- |
| Taps from anywhere | 1 | 1 |
| Target area | 76.5 x 60 = 4590 sq pt | 44 x 44 = 1936 sq pt, about 2.4x smaller |
| Where the thumb is | already there | the far top corner - on a 6.7-inch phone that is a regrip |
| Competing neighbour | three sibling tabs | the wallet control, the most important thing in the header |
| Discoverability | a labelled slot | an unlabelled glyph, though a universal one |

## Dependency, stated so it is not discovered later

**S3, S4, S6 and S7 only exist if the header actually adopts a hamburger, and that is sketch
`181-wallet-control-compact`, in flight right now.** This sketch deliberately does not design the
header - the phones draw it only far enough to show what the hamburger costs the bar. **If 181 lands
on a header that cannot carry a second control beside the wallet, S6 and S7 fall with it** and the
answer reverts to S2.

Related open decision: sketch **175 scheme C** ("delete the overflow") was recommended and never
picked. S7 executes most of it - the sheet drops from five mixed rows to Markets plus three utilities
plus identity - and S4 executes all of it.

## Labels: measured, and the constraint is not where the brief expected

The Row lays out four `Expanded` tabs around one fixed 84px dock slot, and `_MobileBarSlot` adds
vertical padding only, so every label gets **(390 - 84) / 4 = 76.5px** with nothing taken off it.

Widths are advance-width sums read straight out of the shipped `assets/fonts/Inter-Medium.ttf` and
`Inter-SemiBold.ttf` (unitsPerEm 2048) at `fontSize: 10`. `labelMd` carries no letterSpacing, so the
sum is the whole width.

| Label | w500 | w600 | Fits 76.5 | Truncates at text scale |
| --- | --- | --- | --- | --- |
| Home | 28.24 | 28.46 | yes | 2.69x |
| Assets | 32.52 | 33.20 | yes | 2.30x |
| Markets | 38.93 | 39.57 | yes | 1.93x |
| Activity | 36.21 | 37.15 | yes | 2.06x |
| Menu | 27.03 | 27.38 | yes | 2.79x |
| More | 24.91 | 25.20 | yes | 3.04x |
| **News** | **27.11** | **27.39** | **yes** | **2.79x** |
| Explore | 36.08 | 36.57 | yes | 2.09x |
| Compute | 43.73 | 44.27 | yes | 1.73x |
| Transactions | 62.29 | 63.34 | yes | **1.21x** |

**A briefing assumption that does not survive measurement.** "Transactions will not fit where
Activity does" was true of the *eight*-tab bar ripped out on 2026-08-06 - at 48.7pt a slot, 62.3px
truncated. On the shipping four-tab bar it fits with 13px to spare. Every candidate word in this
sketch fits, so **label length must not be used as an argument for or against any scheme.**

Where it does still bite is Dynamic Type. Nothing clamps `textScaler` on this bar, so the last column
is real: "Transactions" breaks one notch above default, which is the actual reason "Activity" is the
right word for that tab. "News" at 2.79x is the safest new label in the set.

## Contrast, computed from the real tokens

The bar's fill on dark is flat - `surfaceSheen` puts `surfaceElevated` at both stops and the file says
so ("same stop - flat, no sheen"), so `#0C0E14` is the whole background.

| Pairing | Ratio | Needs | |
| --- | --- | --- | --- |
| inactive label `#8A8F9D` on bar `#0C0E14` | 5.97:1 | 4.5:1 | pass |
| active gradient stop `#0AD89C` on `#0C0E14` | 10.39:1 | 4.5:1 | pass |
| active gradient stop `#0AAEE6` on `#0C0E14` | 7.54:1 | 4.5:1 | pass |
| dock glyph `#000B18` on the gradient, worst stop | 7.74:1 | 4.5:1 | pass |
| sheet label `#8A8F9D` on `#171A21` | 5.39:1 | 4.5:1 | pass |

Active against inactive is **1.74:1**, below the 3:1 WCAG 1.4.11 asks of a non-text state indicator.
The gradient is not carrying selection alone - the active tab is also w600 against w500 - and this is
shipped behaviour that no scheme here changes. Recorded so it is not later blamed on this sketch.

## Three things the winner must ship with, or it is worse than today

1. **Make the Assets panel link `go` instead of `push`.** `coins_screen.dart:409` pushes `/assets` so
   the dashboard stays mounted with its market-data timer; a nav tab would `go`. Two entrances to one
   route with different back behaviour reads as randomness. The Transactions panel already made this
   exact fix and says why in a comment.
2. **Give the zero states somewhere to go.** Three of four tabs are still blank for a new user; News
   only means they are not all blank. The Assets empty state should carry the Buy GNUS CTA - `/buy`
   exists, is inside the shell, and already defaults to USD to GNUS with the user's own address.
3. **Do not let the hamburger become the second More sheet.** It would hold Markets, Web, Feedback,
   Settings and Accounts - still three unlike kinds of thing, which is sketch 175's original
   complaint moved rather than answered. Accounts is also still duplicated by the wallet control
   sitting next to it; 181 should absorb that row.

## What was deliberately not proposed

- **Five tabs.** 171 settled four plus a dock on device. Reopening it re-litigates a shipped decision.
- **Dropping Home.** Every dashboard section now hands off to a page, so Home does read as a table of
  contents - but it is the only surface carrying Compute, the chart and the wallet summary.
- **Renaming Assets to Wallet or Portfolio.** Both fit (30.6, 41.3). "Assets" is what the section, the
  route and the page header already say, and three names for one thing is how the More sheet got the
  way it is.

## Still open

- No usage data anywhere in this decision. Every claim about what people open is an argument from
  structure, not from telemetry.
- 175's overflow question (A/B/C/D) is still unpicked. S7 resolves most of it as a side effect, which
  is a reason to state the linkage rather than let two decisions drift.
- Light mode not computed (dark-first rule).
- No device verification. This is a browser at 1:1, not Jakub's iPhone.

## Provenance

Tokens verbatim from `gw_colors.dart` / `genius_wallet_consts.dart`; bar geometry verbatim from
`responsive_overlay.dart`. Label widths from the shipped Inter TTFs via fontTools. Contrast by the
WCAG 2.x relative-luminance formula. Phones are 390x844 at 1:1 with the real shipping geometry - 60px
header, 60px bar, 20pt capped inset, 64px dock with 26px overhang in an 84px slot - and every tab
really switches the mocked screen in both the FUNDED and ALL-ZERO wallet states. `node --check`
clean; div balance 205/205; all seven sets and every screen exercised headlessly in both states.
