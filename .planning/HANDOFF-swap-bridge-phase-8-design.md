# HANDOFF — Swap & Bridge (Phase 8) design

**Session:** design (gsd-sketch), 2026-07-24. **Role:** DESIGN — did NOT touch git / MANIFEST / STATE /
ROADMAP / `lib/` (executor-only; MANIFEST was already dirty from a parallel markets session).

## What this session produced

| Sketch | What | Status |
|---|---|---|
| **105 · swap-tab** | The Swap tab redesign. R1 chose **A · Faithful**; R2 chose **A1 · Focused (bigger)** — 560px column, 38px amounts, brand sheen, subtitle, flip in the seam (kills the `-170` hack). | **WINNER: A1** (`winner:"A1"` in README + ★) |
| **120 · phase-8-flow** | The rest of Phase 8: bridge screen (B1 Swap-twin / B2 Network-forward), swap states (submitting / **route-error f22** / insufficient), and the result drawer. | **Bridge pick OPEN** (rec B1). Result = **reuse 031-B**. |
| **121 · phase-8-storyboard** | Page-by-page user walkthrough of both journeys (Swap flow / Bridge flow). Not a decision sketch — a map. | done (walkthrough) |

Numbering: 105 in lane A; 120/121 chosen at Jakub's request (106-108 taken by a parallel markets
session; 109-119 left free).

## Decisions LOCKED
- **Swap tab = 105 A1** (Focused-bigger).
- **Result/receipt = reuse the already-shipped 031-B status-led receipt** (030-B shell) for BOTH swap
  and bridge results — this resolves the two competing impls (`swap_success_drawer`/`swap_fail_drawer`
  /`swap_drawer_content` vs `reown/swap_result_drawer`) and covers findings 21 + 28.
- **Swap route-fetch error (finding 22)** designed: receive → `—` + red "not current" notice + Retry
  (never a silently stale quote).

## Decisions CLOSED 2026-07-25 (was "OPEN — resume here tonight")
Both open picks were resolved by Braian on 2026-07-25. Nothing in this document is open any more.

4. **Bridge = B1 · Swap-twin** — recommendation accepted. Mirrors the swap tab exactly; instant
   recognition; lowest-churn reskin of `bridge_screen.dart`; bridge is 1:1 burn→mint with no
   rate/slippage, so the swap layout carries over. B2 (source→destination network hero) rejected.
   Recorded as `winner: "B1"` in `.planning/sketches/120-phase-8-flow/README.md`.
5. **Bridge entry stays buried** — it remains GNUS token → **More** → "Bridge Tokens". Surfacing it
   is an IA restructure, not a re-skin, and ROADMAP's four Phase 8 criteria do not cover
   discoverability. Deferred to a product/IA decision, tracked at
   `.planning/todos/pending/2026-07-25-surface-the-bridge-entry-as-a-first-class-action.md`, to be
   taken together with the deferred mobile-nav-IA item. **Explicitly OUT OF SCOPE for Phase 8.**

## Navigation facts (verified in code — for whoever plans/builds)
- **Swap** = `/swap` → `SwapScreen` (`router.dart:223`); a top-nav tab, any token; also global `GWSwapFab`.
- **Bridge** = `/bridge` → `BridgeScreen(fromToken: selectedCoin)` (`router.dart:270,275`), pushed from
  `token_info_screen.dart:181` "More" → "Bridge Tokens". **GNUS-only** (`isGnusBridgeEnabled`),
  disabled at balance 0. It is a back-arrow sub-screen, NOT a tab, NOT a swap/bridge toggle.
- Bridge logic = burn on source chain → mint on destination, **1:1** (no rate/slippage; cost = gas).
  `getBrigeOutGasCost(...)` on amount change (300ms debounce); `bridgeOut(...shouldMintTokens:true)` on submit.

## Phase 8 status
- **Phase 8 (Swap & bridge) EXISTS in ROADMAP** (goal + 4 success criteria + findings 21/22/28) but is
  **NOT planned** — no `.planning/phases/08-*` dir, `Plans: TBD`. Depends on Phase 7 (mid-walk: 07-03).
- After the two open picks above, Phase 8 design is **complete**: 105 A1 (swap) + 120 B1 (bridge) +
  swap states + 031-B (result).

## Next step
~~Confirm Bridge B1/B2 (+ surface decision), then~~ **both picks are now closed (see above).**
Next is **`/gsd-plan-phase 8`** — executor work (writes `.planning/phases/08-*`, touches `lib/`).

⚠ **Do NOT feed this file to `/gsd-plan-phase 8 --ingest`.** Tried 2026-07-25 and the ADR parser
mis-reads it: it hoisted the (then-)OPEN section into `decisions[]` as if locked, fragmented
multi-line bullets into half-sentences, and dropped the Navigation-facts section as an unmapped
header. Phase 8 needs a real `/gsd-discuss-phase 8` pass to build CONTEXT.md, using this document
as the source of the locked decisions.

## Executor to-do (MANIFEST rows waiting)
Pending todos hold the rows to add to `.planning/sketches/MANIFEST.md` + suggested commits:
- `.planning/todos/pending/2026-07-24-sketch-105-swap-tab.md` (A1 decided)
- `.planning/todos/pending/2026-07-24-sketch-120-phase-8-flow.md` (bridge pick pending; result=031-B)
- **121 row (add):** `| 121 | phase-8-storyboard | Page-by-page user walkthrough of the whole swap + bridge flow | _walkthrough, no winner_ | phase-8, swap, bridge, storyboard, user-journey |`

## Preview server
`cd .planning/sketches && python3 -m http.server 8751` — then
`/105-swap-tab/`, `/120-phase-8-flow/`, `/121-phase-8-storyboard/` (file:// is blocked for the Chrome
extension). The server from this session will likely be dead by evening; just re-run the command.
