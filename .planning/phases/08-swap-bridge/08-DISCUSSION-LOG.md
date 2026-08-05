# Phase 8: Swap & bridge — Discussion Log

**Date:** 2026-07-25 · **Mode:** discuss (default) · **Participant:** Braian

Human reference only — downstream agents (researcher, planner, executor) read `08-CONTEXT.md`, not
this file.

## Starting position

Unusually, most of Phase 8's design was already settled before this discussion by the 2026-07-24
`gsd-sketch` session: swap = 105 A1, result = reuse 031-B, finding-22 route error designed. Two
picks were left open and were closed earlier the same day (bridge = 120 B1; bridge entry deferred).

So this discussion deliberately did **not** re-litigate design. It focused on the gaps that a
codebase scout surfaced and the sketches could not answer.

## What the codebase scout changed

Two findings reshaped the phase before any question was asked:

1. **The swap does not actually swap.** `swap_screen.dart:340` = `// TODO: invoke Squid API`,
   `:352` = `// TODO: record transaction` — yet `:387` shows the success drawer and `:400`/`:406`
   record a transaction. ROADMAP criterion 3 anticipates exactly this and demands a fix *or* a
   written-down deviation.
2. **"Two competing drawer impls" is actually four files across two packages**, serving two
   different entry points — `squid_router/*` (swap tab) and `reown/swap_result_drawer` (dApp
   requests via `handle_dapp_requests.dart`). The design handoff did not distinguish them.

## Questions asked

### 1. Finding 21 — fix the unwired swap, or document it?
**Options:** document as deliberate (rec) · wire the real Squid call in phase 8 · make it visibly a mock
**Chosen:** **Document as deliberate.**
**Rationale:** wiring real execution is a functional change involving real funds and its own testing
story — out of place in a re-skin phase. Satisfies criterion 3 via its "deviation re-confirmed and
written down" branch. → D-01, D-02

### 2. How far should the 031-B receipt consolidation reach?
**Options:** swap tab + bridge only (rec) · all four incl. the dApp path · leave old drawers in place
**Chosen:** **Swap tab + bridge only.**
**Rationale:** `reown/swap_result_drawer` serves the dApp request path, which is Phase 10's surface.
Keeps phase 8 inside its boundary. Leaving the old drawers untouched was rejected — that is the
orphaned-dead-code trap phase 18 just had to clean up. → D-04, D-05, D-06

### 3. Are the swap settings drawer and global swap FAB in scope?
**Options:** include both · swap settings only · neither
**Chosen:** **Include both.**
**Rationale:** both are swap surfaces attached to the redesigned tab; skipping them leaves a visible
seam. → D-13, D-14

## Scope creep redirected

- Surfacing the bridge entry — raised by the design session, deferred earlier today as an IA
  restructure. Captured as a todo, recorded in Deferred Ideas.
- Real Squid execution — recorded in Deferred Ideas as its own future phase.
- dApp result-path consolidation — recorded in Deferred Ideas as Phase 10 territory.

## Todo cross-reference

`todo.match-phase 8` returned 44 todos all scored 0.9, matching on `area: ui` alone rather than on
swap/bridge relevance (top hits were the account row, AppScreenView, drawer padding, the appearance
toggle, the Bitcoin chart). **None folded** — the matcher was low-precision here. The only genuinely
related todo is the bridge-surfacing one, which is already deferred by decision.

## Note for a future session

No packaged sketch-findings skill exists (`./.claude/skills/sketch-findings-*` absent), so sketches
105/120/121 must be read directly. Running `/gsd-sketch --wrap-up` would make these findings
available as distilled context to future phases.
