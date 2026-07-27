---
phase: 08-swap-bridge
verified: 2026-07-27T00:00:00Z
status: human_needed
score: "9 of 9 items PASS in dark; light mode deliberately not walked (Braian 2026-07-27); criterion 4 partial (dry-run depth, no bridgeOut)"
behavior_unverified: 0  # in dark. Light mode + criterion 4 full depth remain unverified by choice — see below.
requirements: [SCR-04]
walk_authorisation:
  descoped_by: "D-22 (Braian, 2026-07-25) — 'lets just switch the design we dont need to test it fully'"
  reinstated_by: "Braian, 2026-07-27, during this session: chose 'Reinstate the walk now' over recording the descope"
  bridge_depth: "dry-run — chosen by Braian 2026-07-27 at 08-07 Task 1. NO bridgeOut call is authorised (D-23). Criterion 4 will therefore be recorded as PARTIALLY verified: the receipt is exercised via the dev bubble, not a real response."
  host: "Windows 11, flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true, Flutter 3.41.9"
automated_gates:
  analyze: "59 issues (baseline 61) — no new issues in touched files"
  tests: "376 pass / 1 known pre-existing failure (test/local_wallet_storage_test.dart — 'Missing definition of main method', unrelated to this phase). Up from 326 at the start of the walk: the walk added 50 tests across the balance math, the holdings filter, the picker empty state, the magnitude fixtures, the FAB push/pop paths and the swap preselection."
---

# Phase 08 — Swap & Bridge: Verification

> **STATUS: dark-mode walk COMPLETE, light-mode walk DECLINED.** All nine items pass in dark.
> Light mode was deliberately not run (Braian, 2026-07-27) and is recorded as declined, never as
> performed. Criterion 4 is partial by authorisation, not by omission: dry-run depth meant no
> `bridgeOut`, so the real bridge result path was never observed.
>
> This file must NOT be flipped to `passed` without an explicit override citing both of those
> decisions — the same rule D-22 set for the walk it originally cancelled.

## Criteria

| # | Criterion | Verdict |
|---|-----------|---------|
| 1 | Swap renders in the redesign skin (105 A1); quote figures match develop | 🟨 dark PASS, light outstanding |
| 2 | Route-fetch failure → em dash, no route card, red notice, enabled Retry | 🟨 dark PASS, light outstanding |
| 3 | Submit → develop's outcome (toast + receipt + persisted tx), NO real swap (D-01) | 🟨 dark PASS as the documented deviation, light outstanding |
| 4 | Bridge result shows toast ALONGSIDE the receipt | 🟨 PARTIAL — screen verified dark at dry-run depth; NO bridgeOut, so the real result path is unobserved |
| 5 | Cold start with no `!_dirty`; FAB present/absent on the right surfaces | 🟨 dark PASS (after `10be9c3`), light outstanding |
| D-15 | WCAG AA on every CTA rung, notice, impact green, MAX chip, sheen — both modes | 🟨 dark PASS; **light HALF NEVER TESTED** — the rule explicitly requires both |

## Walk items

### 1. Cold start + FAB placement — ✅ PASS (dark), light outstanding

**Crash half — PASS (dark).** Four separate cold starts in this session produced **no red error
screen and no `!_dirty` / `assert(!_dirty)` line** as the initial route resolved. The `_ready` gate
ported in 08-02 holds under `runApp`'s real mount timing, which is the thing `pumpWidget` cannot
prove. Boot was slow (`getCoins` settled in 20.4s on the first run, 318ms on later ones) but that
is network, not the bug.

**FAB half — FAILED on first walk, fixed, then re-walked green.** Braian: *"the swap button should
disappear when in the swap page."* It did not.

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

### 4. Route error (D-09, finding 22) — ✅ PASS (dark)

Walked by Braian 2026-07-27 with a forced route-fetch failure. All four required behaviours
observed together: "You Receive" shows an **em dash** rather than the stale number it last held,
the route-details card **disappears** (D-09: no figures derived from a route that just failed), the
red "quote is not current" notice appears, and the CTA becomes an **enabled Retry** that re-fetches
on tap.

This is criterion 2, and it has no automatable proof — the quote service is a compile-time
constant (D-18b), so the failure path cannot be provoked from a test.

**Outstanding:** light mode, including the notice's legibility.

### 5. CTA ladder + D-15 disabled contrast — ✅ PASS (dark)

Walked by Braian 2026-07-27. Every rung of the 08-03 state ladder rendered and read correctly:
`Enter an amount` (disabled, still legible), `Insufficient {SYMBOL} balance` on the red-tinted
fill, `Finding best route…` during fetch, and the brand-gradient `Swap` on a valid quote. D-15's
specific question — disabled rungs clearly distinguishable from the enabled one AND readable,
not a grey smear — passes in dark.

⚠ **This rung was untestable before today.** The `pow(10, decimals) as double` cast threw inside
`fromBalanceAmount` before the ladder could evaluate, so `Insufficient {SYMBOL} balance` could
never render. `1445549` is what made this item walkable at all — worth remembering if this
verdict is ever revisited.

**Outstanding:** light mode, which is the half D-15 most needs (the disabled fills and the
red tint are the states most likely to collapse against a light surface).

### 6. Swap submit — ✅ PASS (dark), recorded as the D-01 DOCUMENTED DEVIATION

Walked by Braian 2026-07-27. Submitting produced develop's outcome: the "Swap Submitted" toast
**and** the shipped 031-B receipt — both, not one instead of the other (D-04) — with no Network
Fee row (nothing executed, so no fee is claimed — this is 08-05's blank-fee guard doing its job),
no explorer button (the hash is empty), no wording implying on-chain settlement (D-02), and the
transaction appearing in the Transactions surface.

**Recorded explicitly:** criterion 3 is satisfied by the DOCUMENTED-DEVIATION branch. No real
Squid swap was executed and none was attempted — `swap_screen.dart` still carries both
`// TODO:` markers, grep-guarded by 08-05. Recording this as "a swap executed" would be false.

**Outstanding:** light mode.
### 7. Bridge (120 B1), dry-run depth — ✅ PASS (dark), at DRY-RUN depth only

Walked by Braian 2026-07-27. The bridge screen reads as the Swap tab's twin per sketch 120 B1:
compact back-arrow header, ~560px column, source→destination route bar whose destination chip
opens a picker **sheet** (not a dropdown menu), "You Pay" / "You Receive on {network}" cards, a gas
card with exactly two rows showing an **em dash rather than a 0** before an estimate arrives, no
rate row, no slippage row, no flip control and no swap/bridge toggle. Entry still requires GNUS
with a non-zero balance. A real gas estimate arrives on typing an amount — that call genuinely
hits chain — and the receive amount mirrors the pay amount 1:1.

**CRITERION 4 IS PARTIALLY VERIFIED, AND MUST NOT BE RECORDED OTHERWISE.** The walk stopped at
CTA-ready. No `bridgeOut` was called, per the dry-run depth Braian authorised at Task 1 and per
D-23. So the toast-alongside-receipt path was NOT observed against a real bridge response — the
shared receipt was exercised through the dev bubble instead, against a synthesized record.

Consequently these two remain **UNANSWERED**, both flagged by 08-06 as needing human judgement:

1. Whether the receipt's **"Minted"** badge and title read acceptably for a bridge. D-19's
   sanctioned fallback is the transfer type if they do not.
2. Whether **staying on the bridge screen** after dismissing the receipt — instead of popping back
   to the token screen as before — is acceptable (RESEARCH Assumptions Log A4). This is a
   documented behaviour change, and it has not been put to a human against a real bridge.
### 8. No orphans / no Phase-10 damage — ✅ PASS (dark), one cosmetic defect routed elsewhere

Verified by direct inspection 2026-07-27 (this is the half that does not need eyes):

- **Dev bubble split is exactly what 08-05 claimed.** Two buttons call `showTransactionDetails`
  (`dev_tools_bubble.dart:588,623` — the shared 031-B receipt, completed and failed), and two
  still call `SwapResultDrawer.show` (`:537,550` — the reown drawer).
- **The Phase-10 path is intact (D-05).** `lib/reown/swap_result_drawer.dart` still exists and is
  still called from **two production sites** — `handle_dapp_requests.dart:177` and `:205` — plus
  the two dev sites above. Nothing in 08-05/08-06 touched it.
- **The three superseded drawers are gone, not orphaned.** `SwapSuccessDrawer`, `SwapFailDrawer`
  and `SwapDrawerContent` survive only inside explanatory comments
  (`dev_tools_bubble.dart:583,619`, `swap_screen.dart:269`). Zero live references, and `analyze`
  is clean, so nothing imports a deleted file.

**Visual half walked 2026-07-27 — the item's own criterion PASSES, with a cosmetic defect found
that belongs to other phases.**

The no-orphans / no-Phase-10-damage question is answered: "Swap OK" and "Swap fail" **do** still
open the reown drawer, and the repointed buttons **do** open the shared receipt. Nothing is
orphaned and nothing in Phase 10 was broken by 08-05.

**But** Braian: *"swap ok and swap fail is basically empty right now … it does not have paddings in
this content."* Both drawers render their body flush against the panel edges —
`swap_result_drawer.dart:25` has no body padding at all, and `_buildDetailsCard`
(`transaction_displays.dart:421`) has `vertical: space2` with **zero horizontal**.

Not a Phase 8 regression. `ResponsiveDrawer` documents that body padding is each caller's
responsibility (`responsive_drawer.dart:113`); the 07-06 re-skin pinned the *title* to a 20px inset
and these two callers never padded their bodies to match. `swap_result_drawer.dart` has not been
touched since `4d1bb36`, before the redesign.

**Deliberately NOT fixed.** Both files are fenced off from this phase — D-05 makes the reown
drawer Phase 10's, and 08-05 forbids redesigning `showTransactionDetails`. Braian was asked at the
walk and chose to respect both prohibitions rather than cross them. Recorded in
`.planning/todos/pending/2026-07-27-drawer-bodies-have-no-horizontal-padding.md`, routed to
sketch 154 (which already recorded the identical finding) and Phase 10.

**Outstanding:** light mode.

### 9. Console watch — ✅ PASS with one recorded exception (dark)

One reproducible exception, present on **every** launch, fires on the dashboard before anything is
touched:

```
A RenderFlex overflowed by 33 pixels on the bottom
lib/chart/crypto_live_chart.dart:372
```

Outside Phase 08's surfaces (dashboard chart, Phase 05/13 territory) so it does not gate this
phase, but it is real and recorded.

**On Phase 08's own surfaces the console is clean.** A live filter ran over the Flutter console for
the whole session, watching for exceptions, overflows, `setState() called after dispose`, `_dirty`
asserts and unlaid-out RenderBoxes. Across the walk of items 1–6 the only thing it caught on swap
or bridge was the two entries below. Notably **zero** `type 'int' is not a subtype of type 'double'`
in this run, against a steady stream of them before `1445549`.

**One unresolved observation, recorded rather than closed:** earlier in the session two horizontal
overflows fired — **7.1px and 8.1px on the right**, twice each — while the app was being driven.
They have NOT recurred since. The widget could not be identified: Flutter prints the full widget
path only for the first exception of a run and collapses repeats to "Another exception was
thrown", and that one full block belonged to the dashboard chart. Most likely candidates, both
unconfirmed: the picker row carrying the 13-digit `1000000000000`, or the 38px hero holding the
17-character dust amount after MAX — i.e. the very problem sketch 066 was raised to solve. If it
resurfaces, rebuild with the repeat-collapsing defeated so the widget path prints.

## Light mode — DELIBERATELY NOT WALKED (Braian, 2026-07-27)

*"everything pass and light mode we are not running for now."*

Every verdict above is **dark mode only**. Light mode was not walked, and nothing here may be read
as implying it. This is a deliberate descope by the developer, recorded as such — the same
treatment D-22 prescribed for the walk it originally cancelled: *"never as performed, never as
passed."*

**What that leaves genuinely unverified**, rather than merely unrecorded:

- **D-15 is the biggest hole.** Its whole point is *"WCAG AA in BOTH light and dark, across every
  CTA rung including the disabled ones."* Half the rule was tested. The states most likely to fail
  are precisely the untested ones: disabled CTA fills and the red route-error tint, both of which
  collapse most easily against a light surface.
- The brand sheen behind the swap column — item 2 explicitly called out light mode as the mode
  where it might wash out card contrast.
- The route-error notice's legibility (item 4).
- The `<0.000001` dust figure and the 13-digit balance in the picker (item 3), which sketch 066 was
  raised to address and which have only ever been seen dark.

This is the known cost, accepted knowingly. Phase 06's walk found eleven defects that appeared in
no plan; this walk found nine in dark alone. A light-mode pass would be the cheapest remaining
place to find more.

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
- `.planning/todos/pending/2026-07-27-drawer-bodies-have-no-horizontal-padding.md` — the reown
  swap-result drawer and `_buildDetailsCard` both render flush to the panel edge. Fenced off from
  this phase by D-05 and 08-05; routed to Phase 10 and sketch 154 respectively.
- `crypto_live_chart.dart:372` overflow (item 9).
