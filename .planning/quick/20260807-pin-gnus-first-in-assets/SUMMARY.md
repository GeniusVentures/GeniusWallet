---
quick_id: 260807-gns
slug: pin-gnus-first-in-assets
date: 2026-08-07
branch: redesign/navigation-260806
status: incomplete
blocked_on: four hard-coded test literals encoding the superseded rule - awaiting Jakub
commits: none (CLAUDE.md rule)
---

# Pin GNUS first in Assets - Summary

GNUS is a pin again, on both surfaces, changed in one place. `compareAssetsByValue`
(`lib/dashboard/assets/assets_sort.dart`) now ranks GNUS first outright as **step 1**,
ahead of the unpriced-vs-priced tiering, instead of as the step-4 tie-break phase 25
demoted it to. The dashboard panel and the `/assets` page both sort through this
function, so the single edit moved both together - `coins_screen.dart` and
`assets_screen.dart` were not touched, and their hashes are unchanged.

## Files changed

| File | Change |
|---|---|
| `lib/dashboard/assets/assets_sort.dart` | GNUS check hoisted above the tier check; `_kNativeSymbol` and the comparator doc comment rewritten |
| `test/dashboard/assets_sort_test.dart` | 8 new cases in a new `GNUS is PINNED first` group. Additive only |

Both files are **untracked** in this tree (phase 25's work is not committed on this
branch), so `git diff` shows nothing for them. No commits were created.

## The decision: ascending keeps GNUS first

Recommended and implemented. A pinned row is pinned in both directions; the arrow then
visibly reorders everything *around* a fixed head, which reads as intentional.

**The rejected alternative - mirroring GNUS to LAST when ascending - is named in the doc
comment with its reason**, per the brief. It was rejected on two grounds:

1. A token that teleports between first and last on a direction toggle reads as a bug.
   The unpriced tier mirrors because it is a *ranking* (by attention needed); the pin
   does not, because it is not a ranking at all.
2. **The tests already decided it.** Two existing ascending expectations put GNUS first:
   `assets_screen_test.dart:252` (`['GNUS','USDC','ETH','UNLST']`) and the all-zero
   wallet case at `:372`. The mirror would have meant *weakening* both, which the brief
   forbade. Keeping GNUS first was the only option that is purely additive here.

## Also documented in the comment, as asked

- **No GNUS in the wallet:** the pin never fabricates a row. It is a comparator; it
  orders rows that already exist. Verified: a wallet with no coins short-circuits to
  `GWEmptyState` at `assets_screen.dart:476` (S3) *before* any sort runs, and a
  GNUS-free funded wallet is ordered byte-identically to before (test:
  `a wallet holding no GNUS is ordered exactly as it was`).
- **GNUS held at zero balance:** still pinned, deliberately. It renders as an ordinary
  `$0.00` row at the top, which is exactly where it already sits on the all-zero wallet
  today, beside the page's `Buy GNUS` CTA - so held-none reads as an offer, not a defect.
  Making the pin conditional on `balance > 0` was considered and rejected in the comment:
  the row would leap down the list the moment a balance hit zero, a worse surprise than a
  quiet $0.00 at the top.
- **The accepted cost, named so it is a decision and not a rediscovery:** an unpriced
  holding is the one row that needs attention, and it now sits *below* GNUS. The pin is a
  brand rule and it outranks the attention rule by exactly one row.

## Gates

| Gate | Result |
|---|---|
| `flutter analyze` | **0 issues** |
| `flutter test` baseline (before) | **1090 pass, 0 fail** (brief said 1081; it had moved) |
| `flutter test` (after) | **1094 pass, 4 fail** of 1098 |

1090 + 8 new = 1098. All 8 new cases pass, every pre-existing case in
`assets_sort_test.dart` passes unweakened, and exactly 4 fail. Zero collateral.

## BLOCKED: four hard-coded literals encode the old rule

The brief said *"Do not edit that test to make it pass - report instead."* I have not
edited any of them. All four failures are a single expected-list literal.

**The contract itself is intact - the surfaces have NOT diverged.** The real divergence
detector is `assets_screen_test.dart:415-419`, which compares the rendered rows against a
*live-computed* `sortAssets(...).take(5)`. Both sides moved together to
`['GNUS','WBTC','ETH','SOL','MATIC']`; they still agree. What fails is the constant *both
sides are compared against*, which that test's own comment describes as "written out
rather than derived, so this fails loudly if the shared rule changes". It is a
change-detector doing its job, not a divergence.

| # | Location | Expected (old rule) | Actual (pin) |
|---|---|---|---|
| 1 | `assets_screen_test.dart:228` | `['UNLST','ETH','USDC','GNUS']` | `['GNUS','UNLST','ETH','USDC']` |
| 2 | `assets_screen_test.dart:244` | `['UNLST','ETH','USDC','GNUS']` | `['GNUS','UNLST','ETH','USDC']` |
| 3 | `assets_screen_test.dart:396` | `['WBTC','ETH','SOL','MATIC','USDC']` | `['GNUS','WBTC','ETH','SOL','MATIC']` |
| 4 | `dashboard_section_caps_test.dart:367` | `['BBB','DDD','GNUS','FFF','AAA']` | `['GNUS','BBB','DDD','FFF','AAA']` |

Each is a one-line reorder, and each keeps its discriminating power (a hand-rolled
"GNUS first, then fetch order" sort still fails #4: it would give
`['GNUS','AAA','BBB','CCC','DDD']`). Two stale comments also need a line each:
`dashboard_section_caps_test.dart:363-366` ("GNUS at 5 sits THIRD ... phase 25 traded the
absolute GNUS pin") and `assets_screen_test.dart:394` - both narrate the rule just
reversed. Note #2's *ascending* assertion at `:252` needs no change; it already expects
GNUS first and will pass once `:244` is updated.

**Awaiting Jakub's go-ahead to apply those four literals plus the two comments.** Until
then the suite is red by exactly those four.

## What Jakub should check on the phone

Run with `--dart-define=GW_DEV_TOOLS=true`, then use the dev-tools bubble MOCK section.
The real wallet is all zeros and **cannot** show this change - GNUS is already first
there by tie-break, which is precisely how the regression survived the last walk.

1. **`Unpriced` - the scenario that proves the pin.** Strongest case: GNUS 1020, ETH
   4320, UNLST unpriced. Before this change GNUS was **last**; now it is **first**, above
   the unpriced UNLST row. Check the dashboard Assets panel, then `View all` and confirm
   `/assets` reads the same order.
2. **`Populated` - the everyday funded case.** GNUS 1020, ETH 4320, USDT 500, USDC 250.
   GNUS moves from **second to first**. Same check on both surfaces.
3. **The ascending decision, on `/assets` only** (the dashboard has no toggle). On
   `Populated`, tap the sort arrow: the order goes `GNUS, ETH, USDT, USDC` to
   `GNUS, USDC, USDT, ETH`. GNUS stays put, everything below it reverses. That fixed head
   with a reordering tail is the thing to eyeball - if it reads as broken rather than
   deliberate, the rejected mirror alternative is still on the table.
4. **`Long-extreme` - a wallet with no GNUS at all.** Two rows, WHL then MEGALONGSYM, no
   GNUS row invented and the order unchanged. `Missing-icon` is a second no-GNUS case.
5. **`Clear` - back to the real all-zero wallet.** GNUS first, identical to today. This is
   the one that should look like nothing happened.

## Fences

Held. Hashes verified unchanged after the edit:

- `lib/components/coins/view/coins_screen.dart` `215e496b...`
- `lib/components/cards/gw_section_title.dart` `88d53451...`
- `lib/components/cards/gw_view_all_link.dart` `f8d46965...`
- `lib/dashboard/assets/assets_screen.dart` `ea6b0d0d...`

No commits created. No em dashes in either file (checked). Nothing under `/banxa` or
`/squidrouter`. The running flutter session was not killed, restarted or hot-reloaded -
picking up this change needs a relaunch or a hot reload `r`, and the dev-tools mock
scenarios must be re-armed after any restart.

## Self-Check: PASSED

- `lib/dashboard/assets/assets_sort.dart` - present, step 1 is the GNUS pin
- `test/dashboard/assets_sort_test.dart` - present, 8 new cases, 24/24 pass
- `flutter analyze` - 0 issues, re-run after all edits
- Fenced file hashes - all 4 match pre-edit values
- Commits - none, as required
