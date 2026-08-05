# Handoff · 2026-07-28 · Coin page rebuilt, drawer foundation, five base components

**Session:** executor, branch `redesign/jakub-260726b`, PR into **`ui-redesign-port`** (never `main`).
**Handing to:** Braian.

---

## Where to start

**Nothing here has been walked except the coin page, and that only partly.** Everything below passes
`flutter analyze lib` at the 59-issue baseline and its own tests, but a large part of it has never
been on a screen in front of a person. The walk list is at the bottom and it is the real next task.

---

## What shipped, in one paragraph each

### The coin page, rebuilt three times in one day

**070-A** put it on base components: `GWDetailGrid` for the Info rows, `GWTextField` for the Convert
fields, and every info glyph moved to ONE accent after measuring that five of the six colours collapse
on the light well (`statusSuccess` 10.80 dark → **1.25** light).

**071-B** rebuilt the whole screen. The page **moved inside the `ShellRoute`** - it was the only
screen in the app without a navbar - the 48px `AppBar` and its hand-built breadcrumb became a
`GWPageHeader`, the frame became Markets' exact frame (xxl/1536 + 12px gutter), `SizedBox(height: 480)`
became `coinChartHeight(viewportHeight, isDesktop)`, a six-tile stat rail arrived on a promoted
`GWStatTile`, and the null-`marketData` route finally SAYS so instead of silently dropping three
blocks.

**074-C2 then 075-E2** settled the actions. The four-tile `TokenActionBar` is **deleted**. Receive and
Swap (and Bridge on GNUS) are now bare glyphs on the title's own line, behind a hairline. **Send is
gone entirely** - it does not exist at any layer a user can reach, and per Jakub's rule
(*"Jeśli czegoś nie ma w kodzie, to nie uwzględniamy designu"*) it left the design rather than
shipping as a fourth grey box.

### Four defects nobody would have found from a screenshot

1. **`pow(10, decimals) as double` crashed the swap screen on every token pick.** `pow(int, int)`
   returns a `num` that is an `int` at runtime whenever the result fits int64 - which is every
   `decimals <= 18`, i.e. every real token. It read as data-dependent only because two of three
   callers swallow it and print `0`.
2. **The token you had just picked vanished from its own picker.** Both sides filtered out *this*
   side's token as well as the other's, so `selectedToken` could never match a row.
3. **The chart was not flat - the ruler was.** `minY/maxY` reduced over the ENTIRE series while
   `minX/maxX` showed only the last 50 points, so on GNUS (-98.53% from ATH) the visible range
   occupied a sliver at the bottom of the card.
4. **`AssetImage("")`** in `CryptoAddressQR` threw *"Unable to load asset"* on every build for every
   coin without artwork.

### Base components promoted

`GWKicker` (5 hand-written copies), `GWSelectRow` (4 pickers), `GWWarningNote` (3), `GWDetailGrid`,
`GWStatTile`. The 3+ consumer bar was applied every time and **refused twice** - `_CopyRow` at one
consumer stayed local, `GWStatTile` was refused at two until Jakub overrode on instance count (ten
uses of one two-line widget).

### Two slots on `GWPageHeader` that exist for one page

`leading` (the token logo) and `titleTrailing` (the actions on the title's line). **Both are under the
3+ bar and that is recorded in their doc comments.** The alternative was not a local widget - it was
the coin page hand-rolling its own title row again, which is what `GWPageHeader` exists to stop.

---

## Decisions a reviewer might want to reopen

| Decision | Why | Where to argue |
|---|---|---|
| **Send removed, not disabled** | no screen, no route, `transferTokens` has zero callers | sketch 072 |
| **Bridge absent, not greyed, on non-GNUS** | "does not apply" ≠ "unavailable" | sketch 074 |
| **Bare glyphs, no chip** | a 44px chip stands 12px taller than the 24/32 title; shrinking to 32 would drop below WCAG 2.5.5 AAA, so the PAINT went and the 48px TARGET stayed | `_buildActionRow` |
| **Rank left the subtitle** | the stat rail's first tile is Rank; it was printed twice | `_header` |
| **`GWStatTile` promoted at 2 consumers** | Jakub overrode the 3+ bar on instance count | `gw_stat_tile.dart` |
| **Drawer panel hairline `borderSubtle`, not `borderStrong`** | Jakub overruled the contrast arithmetic on a live look; 1.30:1 accepted, not 2.01:1 | `responsive_drawer.dart` |

---

## Open, and each one is somebody's decision

**1 · The three hardcoded `isGnusWalletConnected: false` call sites.**
`markets_screen.dart:58`, `dashboard_markets.dart:83`, and `markets_search_bar.dart:93` (never passes
it). So **arriving from Markets, the main route, the coin page shows two actions instead of three**.
This is a bug in the CALLERS, and nobody has said whether Bridge *should* be live from Markets. If it
should, the action count changes on every sketch from 072 onward.

**2 · Sketch 075 is decided but its losers are not cancelled.** 072-A and 073-A both stay
`winner: null`. E2 shipped; A (beside the price) remains the runner-up and is one `Row` away.

**3 · `local_wallet_storage_test.dart`** is fully commented out and has been the single failing test
all week. Restore it or retire it explicitly.

**4 · `TokenDetailHero` now has zero consumers.** Todo filed with the delete-or-re-consume decision;
it is the only stacked-identity implementation and the <360 layout used to use it.

**5 · The two `cmake/` changes are in this PR and are not UI work.** `find_package(Snappy)` relaxed to
`QUIET` (not shipped in the TestNet-Phase-3.1 bundle, rocksdb builds without it) and the dependency
download timeout raised 300s → 3600s (a 300MB archive times out on slower links). They predate this
session's UI work. **Drop the `build:` commit if they belong elsewhere.**

---

## The walk list, which is the actual next task

**Coin page** - the most changed thing here and the least seen:
- the navbar on the page at all (it never had one before the route move)
- **back from all FOUR entry points** - the route move changed which Navigator `pop` talks to
- the no-data page from the Assets list (a coin CoinGecko does not cover)
- widths **900 / 768 / <768** - the title row now carries logo + name + hairline + glyphs + price, and
  the title is `Flexible`, so it should ellipsize rather than overflow. Unverified.
- the chart filling its card, and whether 8% headroom is the right amount on a real series
- the stat rail's numbers against the Markets table for the same coin

**Drawers** - seventeen of them inherited the shell's new body/footer insets and the
`surfaceElevated` panel. Two were walked. Fifteen were not.

**Light mode** - deferred all week by decision (dark first). The backlog file has seven items,
including `GWDetailGrid`'s key text at 4.23:1 on the light well.

---

## Environment notes that cost time today

- **Hot reload stopped completing twice** (requests logged, completions not). Both times the fix was
  quit + relaunch, ~3 minutes, most of it `dsymutil` linking SuperGenius/RocksDB symbols.
- **Never `R`.** Hot restart kills the app on the native node's RocksDB lock. `r` or a full relaunch.
- **A route change never survives hot reload** - `geniusWalletRouter` is a top-level `final`.
- The dev-tools bubble needs `--dart-define=GW_DEV_TOOLS=true` on every `flutter run`.

---

## State of the tree at handoff

`flutter analyze lib` **59** = baseline. Scoped suite (tokens, chart, components, squid_router, theme,
account, dashboard) **318 pass**. The one known failure repo-wide is the inherited
`local_wallet_storage_test.dart`, which is commented out.
