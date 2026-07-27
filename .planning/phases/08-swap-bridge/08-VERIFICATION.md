---
phase: 08-swap-bridge
verified: 2026-07-27T00:00:00Z
status: human_needed
score: "walk IN PROGRESS — 3 of 9 items settled in dark; 0 of 9 in light"
behavior_unverified: 6
requirements: [SCR-04]
walk_authorisation:
  descoped_by: "D-22 (Braian, 2026-07-25) — 'lets just switch the design we dont need to test it fully'"
  reinstated_by: "Braian, 2026-07-27, during this session: chose 'Reinstate the walk now' over recording the descope"
  bridge_depth: "dry-run — chosen by Braian 2026-07-27 at 08-07 Task 1. NO bridgeOut call is authorised (D-23). Criterion 4 will therefore be recorded as PARTIALLY verified: the receipt is exercised via the dev bubble, not a real response."
  host: "Windows 11, flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true, Flutter 3.41.9"
automated_gates:
  analyze: "59 issues (baseline 61) — no new issues in touched files"
  tests: "363 pass / 1 known pre-existing failure (test/local_wallet_storage_test.dart — 'Missing definition of main method', unrelated to this phase)"
---

# Phase 08 — Swap & Bridge: Verification

> **STATUS: WALK IN PROGRESS.** This file is written as the walk proceeds so nothing is lost.
> It must NOT be flipped to `passed` until every numbered item has a verdict in BOTH appearance
> modes. Items with no verdict below are **not** implied passes.

## Criteria

| # | Criterion | Verdict |
|---|-----------|---------|
| 1 | Swap renders in the redesign skin (105 A1); quote figures match develop | 🟨 dark PASS, light outstanding |
| 2 | Route-fetch failure → em dash, no route card, red notice, enabled Retry | ⬜ not walked |
| 3 | Submit → develop's outcome (toast + receipt + persisted tx), NO real swap (D-01) | ⬜ not walked |
| 4 | Bridge result shows toast ALONGSIDE the receipt | ⬜ not walked (dry-run depth only) |
| 5 | Cold start with no `!_dirty`; FAB present/absent on the right surfaces | 🟨 dark PASS (after `10be9c3`), light outstanding |
| D-15 | WCAG AA on every CTA rung, notice, impact green, MAX chip, sheen — both modes | ⬜ not walked |

## Walk items

### 1. Cold start + FAB placement — 🟨 PARTIAL (dark only)

**Crash half — PASS (dark).** Four separate cold starts in this session produced **no red error
screen and no `!_dirty` / `assert(!_dirty)` line** as the initial route resolved. The `_ready` gate
ported in 08-02 holds under `runApp`'s real mount timing, which is the thing `pumpWidget` cannot
prove. Boot was slow (`getCoins` settled in 20.4s on the first run, 318ms on later ones) but that
is network, not the bug.

**FAB half — FAILED, fixed, NOT yet re-walked.** Braian: *"the swap button should disappear when in
the swap page."* It did not.

`/swap` was in `_hiddenPaths` all along; the defect was which path the host read.
`currentConfiguration.uri` tracks declarative navigation only — an imperative `push` appends an
`ImperativeRouteMatch` without moving it. Probed directly:

```
router.push('/swap') → uri.path = /dashboard → FAB visible   ← the bug
router.go('/swap')   → uri.path = /swap      → FAB hidden
```

The FAB's own `onPressed` calls `push('/swap')`, so tapping it opened the swap screen and kept
floating on top of it. The nav bar uses `context.go`, which hid it correctly — and every existing
test used `go`, the one path that was never broken. Fixed in `10be9c3` by reading
`last.matchedLocation`; two regression tests added (hidden after push, restored on pop).

**FAB half re-walked after the fix — PASS (dark).** Braian, 2026-07-27, on the build carrying
`10be9c3`: FAB present on the dashboard and on a pushed token detail, **absent on `/swap` including
when reached by tapping the FAB itself** (the exact path that was broken), returning on back-out,
exactly one FAB, not covering another screen's CTA.

**Outstanding for this item:** light mode.

### 2. Swap skin + quote figures (105 A1) — ✅ PASS (dark)

Walked by Braian 2026-07-27 against sketch 105 A1: centred ~560px column, brand sheen not washing
out card contrast, one-line subtitle under "Swap", 38px amounts, flip control sitting IN THE SEAM
between the cards (the `-170` pixel-offset hack is gone), route-details card showing Pricing /
Slippage / Price Impact / Fees. Quote figures match develop — noting D-18b: the quote is a
compile-time constant, so the criterion is "the same figures develop showed", never "a live route".

Walked on the build carrying `faaa74b`, which halved the fees-table→CTA gap from 32px to 16px at
Braian's request during this item.

**Outstanding:** light mode.

### 3. MAX + the fiat line — ✅ PASS (dark)

Walked by Braian 2026-07-27. MAX fills the amount from the token's balance. Note the conditions
that made this a real test rather than a formality: CoinGecko was returning HTTP 429 and the
USDC/GNUS/USDT price fetches failed with handshake errors throughout the session, so no price was
known for most tokens — the fiat line had to be ABSENT rather than `$0.00`, and was.

This item also covers the first sight of the 08-07 magnitude fixtures in the picker
(`<0.000001` through `1000000000000`) on the build carrying the `pow`/`toDouble` fix, i.e. the
first run in which held balances rendered their real figures at all rather than `0`.

**Outstanding:** light mode.
### 4. Route error (D-09) — ⬜ not walked
### 5. CTA ladder + D-15 disabled contrast — ⬜ not walked
### 6. Swap submit (D-01 documented deviation) — ⬜ not walked
### 7. Bridge (120 B1), dry-run depth — ⬜ not walked
### 8. No orphans / no Phase-10 damage — ⬜ not walked
### 9. Console watch — 🟨 PARTIAL

One reproducible exception, present on **every** launch, fires on the dashboard before anything is
touched:

```
A RenderFlex overflowed by 33 pixels on the bottom
lib/chart/crypto_live_chart.dart:372
```

Outside Phase 08's surfaces (dashboard chart, Phase 05/13 territory) so it does not gate this
phase, but it is real and recorded. No other exceptions during boot after the fixes below.

## Defects found by this walk and fixed during it

08-07 forbids source edits; Braian explicitly authorised these after each was diagnosed and the
trade-off was put to him.

| Commit | Defect |
|--------|--------|
| `1445549` | `pow(10, decimals) as double` threw for EVERY token with a balance (`pow` returns int). `displayBalance` caught it and rendered `0`; `swap_screen`'s `fromBalanceAmount` did not and threw during build. Dormant since `7c40615` (2025-05-12); 08-03's CTA ladder added the first unguarded caller. Left walk item 5's "Insufficient balance" rung unable to evaluate. |
| `e64bdf9` | Apply in Swap Settings popped the swap route instead of the drawer, dropping the user on the dashboard — `Navigator.of(callerContext)` resolved to the shell's nested navigator while the drawer was pushed on the root. |
| `10be9c3` | The swap FAB stayed visible on `/swap` (item 1 above). |
| `70f4282` | The "You Pay" picker offered tokens the wallet does not hold. Braian: *"a user can't simply swap a BNB he does not have."* Pay side now filtered to holdings with a designed empty state; receive side deliberately unfiltered. |

Also `651f371` — magnitude stress fixtures (1e-15 → 1e12), which is what surfaced the rendering
question below.

## Design decisions taken during the walk (not implemented)

| Sketch | Decision |
|--------|----------|
| 065 · token-row-chain | **C · Grouped by chain** — the picker never named which chain a token was on, so the same symbol appeared as identical rows. Needs a `SliverPersistentHeader`/`CustomScrollView` swap in the drawer. |
| 066 · big-number-rendering | **B · Grouped + exact second line** — never hide a digit in a balance you are about to spend. Second line only when the grouped form differs. |

⚠ The two compound: 065-C adds a header per chain and 066-B adds a line per row, in the same list.
Recorded in both sketch READMEs.

## Recorded, not fixed

- `.planning/todos/pending/2026-07-27-swap-pay-token-picker-should-list-only-held-tokens.md` — the
  flip control can still seat a zero-balance token on the filtered pay side.
- `crypto_live_chart.dart:372` overflow (item 9).
