# Phase 8: Swap & bridge - Context

**Gathered:** 2026-07-25
**Status:** Ready for planning

<domain>
## Phase Boundary

Swap and bridge wear the redesign and keep develop's route/fee/slippage logic.

This is a **re-skin phase**. The visual layer changes; the mechanics do not. "Re-skin never
restructure" applies throughout — the same doctrine that kept develop's 8 nav destinations in 04-03.

In scope: `swap_screen.dart`, `bridge_screen.dart`, `swap_field.dart`, `swap_settings_drawer.dart`,
`gw_swap_fab.dart`, and a shared 031-B result receipt for the swap-tab and bridge flows.

Out of scope: executing real swaps (see D-01), the dApp request result path (see D-05), and
surfacing the bridge entry (see Deferred Ideas).

</domain>

<decisions>
## Implementation Decisions

### Swap execution — finding 21
- **D-01:** **Keep the unwired swap path, and write the deviation down.** `swap_screen.dart:340`
  is `// TODO: invoke Squid API` and `:352` is `// TODO: record transaction`, yet `:387` shows
  `SwapSuccessDrawer` and `:400`/`:406` call `transactionsCubit.addTransaction(...)`. So today the
  screen renders success and records a transaction **without executing a swap**. Wiring real Squid
  execution is a functional change — real funds, its own testing story — and does not belong in a
  re-skin phase. ROADMAP criterion 3 is therefore satisfied by its **second** branch: "the
  deliberate deviation is re-confirmed and written down as a decision." This decision IS that
  record. The planner must NOT wire the Squid call, and must NOT silently leave criterion 3
  unaddressed.
- **D-02:** The receipt must not gain any new language implying an on-chain swap occurred. Re-skin
  the existing copy; do not upgrade its claims.

### Result receipt — findings 21 + 28
- **D-03:** **Reuse the already-shipped 031-B status-led receipt** (030-B shell) for BOTH the swap
  result and the bridge result. Do not design a new receipt.
- **D-04:** 031-B replaces the three `squid_router` drawers for these two flows:
  `swap_success_drawer.dart`, `swap_fail_drawer.dart`, `swap_drawer_content.dart`.
- **D-05:** **`lib/reown/swap_result_drawer.dart` is OUT OF SCOPE — do not touch it.** It is
  consumed by `lib/reown/handle_dapp_requests.dart`, i.e. the dApp request path, which belongs to
  **Phase 10 (dApp connectivity)**. The design handoff described "two competing impls"; there are
  in fact four files across two packages serving two different entry points. Consolidating the dApp
  path onto 031-B is a Phase 10 decision, not a Phase 8 one.
- **D-06:** Superseded drawer files must not be left orphaned. Once 031-B serves the swap-tab and
  bridge flows, remove the drawer files that no longer have a production caller, and update
  `lib/dev/dev_tools_bubble.dart`, which currently references `swap_success_drawer`,
  `swap_fail_drawer` and `reown/swap_result_drawer`. Note `swap_fail_drawer` has **no production
  caller at all today** — only the dev bubble. Phase 18 shipped exactly this trap (an orphaned
  helper whose passing tests implied a rule the app no longer enforced); do not repeat it.

### Swap tab layout
- **D-07:** **Sketch 105 A1 · Focused (bigger)** — 560px column, 38px amounts, brand sheen,
  subtitle, and the flip control in the seam (which kills the existing `-170` offset hack).
  Locked by the design session; not open for re-litigation.
- **D-08:** Preserve develop's route, fee and slippage figures exactly. The quote pipeline is
  mechanics, not skin.

### Swap route-fetch error — finding 22
- **D-09:** On a failed route fetch the "You Receive" field shows `—` plus a red "not current"
  notice and a Retry affordance. It must **never** display a silently stale quote. Designed in
  sketch 120.

### Bridge screen
- **D-10:** **Sketch 120 B1 · Swap-twin** — the GNUS bridge mirrors the Swap tab exactly. Chosen
  for instant recognition and because it is the lowest-churn reskin of `bridge_screen.dart` (726
  lines, the largest file in this phase). B2 (source→destination network hero) was rejected.
- **D-11:** Bridge mechanics are untouched: burn on source chain → mint on destination, **1:1**, no
  rate and no slippage (cost is gas only). `getBrigeOutGasCost(...)` stays on the 300ms debounced
  amount change; `bridgeOut(... shouldMintTokens: true)` stays on submit.
- **D-12:** Bridge remains GNUS-only (`isGnusBridgeEnabled`) and disabled at zero balance. It stays
  a back-arrow sub-screen — **not** a tab, **not** a swap/bridge toggle.

### Attached swap surfaces
- **D-13:** **`swap_settings_drawer.dart` (slippage) is IN scope** — it opens directly from the
  swap tab and would visibly clash against the redesigned tab if skipped.
- **D-14:** **`gw_swap_fab.dart` (global swap FAB) is IN scope** — it is a swap entry point and
  should not read as pre-redesign chrome.

### GlobalSwapFabHost — the Phase 4 carry (added 2026-07-25, post-discussion)
- **D-17:** **Phase 8 owns `7a63b4f` and mounts `GlobalSwapFabHost`.** ROADMAP's Phase 4 entry
  deferred this commit "to the swap-FAB phase per D-08 (its target `GlobalSwapFabHost` is not built
  this phase; carry-move, not a drop)". Phase 8 is that phase. It was NOT in the original four
  success criteria, so it would have drifted a second time with nobody owning it — a **crash fix**
  (NAV-02, the `!_dirty` red screen on startup). ROADMAP criterion 5 was added to make it explicit.
  Surfaced by the UI researcher, which found `gw_swap_fab.dart:9` documenting a host that does not
  exist.
- **D-18:** **This is a PORT, not a from-scratch build.**
  `lib/components/overlay/global_swap_fab_host.dart` — 143 lines, with the `7a63b4f` fix already
  applied — exists on branch `ui-redesign-3.514-develop` (the superseded forward-port branch that
  survives only as a source of fix commits) and is **absent** on `ui-redesign-port`. Port it rather
  than reimplementing.
  **Preserve the `if (!_ready) return;` guard and its comment verbatim.** That comment records a
  genuinely subtle finding: mounting the router's Navigator resolves the initial route and notifies
  the delegate from inside `performRebuild`, *after* `super.performRebuild()` has cleared the dirty
  flag, so `setState()` there re-dirties the element and trips `assert(!_dirty)` — and the obvious
  `schedulerPhase` check does **not** catch it, because the initial mount runs under
  `attachRootWidget` where the phase is `idle`, not `persistentCallbacks`. Re-deriving that from a
  blank file would be expensive. A live trace of the same condition sits at
  `lib/components/splash.dart:57`.
  Note the FAB *button* itself (`gw_swap_fab.dart`) is already visually compliant — D-14's re-skin
  scope for it is close to a no-op. The real work here is the host and the crash guard.
- **D-18a — CORRECTION to D-18, 2026-07-25 (post-research).** D-18's "port it verbatim" is **wrong as
  written and would not compile.** The `7a63b4f` file imports
  `package:genius_wallet/components/buttons/gw_ai_fab.dart` (line 3) and renders `GWAiFab` (line 136);
  `gw_ai_fab.dart` does **not exist** on `ui-redesign-port` — it was deliberately excluded from Phase
  3's component-library port because WIRE-02 puts the AI FAB out of scope for this milestone
  (ROADMAP's own Phase 3 accounting: "60 additive − 9 nav-shell − 1 `gw_ai_fab.dart` (WIRE-02) = 50
  files"). Verified: `find lib -iname "*ai_fab*"` returns nothing.
  **Corrected instruction:** port the file with the `GWAiFab` import and its `Positioned` block
  REMOVED (~15 lines). Everything else — and in particular the `if (!_ready) return;` guard and its
  comment — is preserved verbatim. Do NOT add `gw_ai_fab.dart`; that would import WIRE-02 scope into
  this phase.
- **D-18b — Criterion 1 means less than it looks.** `SquidTokenService.getRoute()` returns a
  hardcoded `mockSquidRoute` constant (`lib/squid_router/squid_token_service.dart:60`, mock defined at
  `:92`, called from `swap_screen.dart:155`). This is **pre-existing on `develop`**, not introduced by
  the redesign. D-08 ("preserve the figures exactly") is therefore trivially satisfied by a compile-time
  constant. The planner must NOT design a verification step that assumes the quote varies by input
  token or amount — it does not. Criterion 1 verifies that a re-skin didn't disturb a constant, not
  that a live route was fetched.

### Bridge receipt plumbing (added 2026-07-25, post-research)
- **D-19:** D-04 routes bridge results through `showTransactionDetails()`, which takes a
  `Transaction` — but `bridge_screen.dart:235` raises a raw `AlertDialog` and never builds one, and
  `TransactionType` has no `bridge` value (its seven are `transfer, mint, escrow, process,
  escrowRelease, purchase, swap`).
  **Decision: synthesize a `Transaction` for display and REUSE an existing `TransactionType`.**
  **Do NOT add `TransactionType.bridge`, and do NOT touch anything under `packages/`.** That enum is
  Hive-persisted with explicit `@HiveField` indices, so a new value is a persisted-schema change —
  out of bounds for a re-skin phase, and this wallet has already lost a day to persistence-layer
  surprises.
  Preference for the reused value: **`mint`** — the destination-chain half of a bridge is literally a
  mint, and the API call is `bridgeOut(... shouldMintTokens: true)`. Fall back to `transfer` if the
  rendered badge copy reads wrong in situ; the planner may choose based on how
  `transaction_utils.dart` maps type → badge. Either way the choice must not require editing the enum.
  Accept the cost knowingly: the receipt's type badge will not read "bridge". That was weighed
  against a schema change and the schema change lost.

### Receipt fee row (added 2026-07-25, post-planning)
- **D-20:** **AUTHORIZED — one guarded condition in `lib/dashboard/home/widgets/transaction_displays.dart`.**
  UI-SPEC says "no copy changes authorized" for the 031-B receipt; this is an explicit, scoped
  exception Braian approved on 2026-07-25, because routing swap/bridge through the shared receipt
  would otherwise print a **false** fee.
  **The fix:** set `fees: ''` on both the swap and bridge paths, and guard the fee row on
  `tx.fees.trim().isNotEmpty`. This honours the function's OWN existing skip-empty contract — the
  neighbouring `add('Rate', tx.exchangeRate ?? '')` (`:464`) already depends on it. Add a test
  asserting existing non-blank-fee behaviour is unchanged. Suppressing a row is correct here;
  printing a wrong number is not.
  **Root causes, recorded here rather than as separate todos (Braian declined extra backlog items) —
  the guard HIDES these, it does not fix them:**
  1. **Swap stores the pay amount as the fee.** `lib/squid_router/swap_screen.dart:366` sets
     `fees: fromAmount`. The retired `SwapSuccessDrawer` never rendered a fee, so this was invisible;
     031-B would newly print "Network Fee: 1 ETH" where 1 ETH is what the user pays. Changing that one
     persisted `String` is not a schema change, and `txRowContent` does not read `fees` for the swap
     type, so the Transactions list is unaffected.
  2. **Bridge's gas figure is a price, mislabelled as a cost.** `genius_api.getBrigeOutGasCost`
     returns `"<N> Gwei"` (from `getGasPriceInGwei`) with no gas-limit multiplication, in the SOURCE
     chain's native token, displayed on develop under "Estimated Gas Cost". A real cost is mechanics
     → out of scope for a re-skin (D-11). Plans preserve the value and record the inaccuracy. One
     deliberate deviation: develop prints a literal `0` when unknown; plans show an em dash, because
     "0" reads as a free bridge.
  If either root cause is ever fixed properly, revisit this guard — it may become unnecessary.

### Standing authorizations for execution (added 2026-07-25)
- **D-21: Braian pre-authorizes routine execution judgment. Do not stop to ask about:** task
  ordering within a plan, which existing `TransactionType` the bridge badge reuses (D-19 prefers
  `mint`, `transfer` is an acceptable fallback), exact gate wording, whether an analyze warning is
  pre-existing (compare against the 61 baseline), test naming, or any reversible in-plan choice.
  Decide, proceed, and report the call afterwards. Stated 2026-07-25: *"do everything until the end,
  approve it as if you was me."*
- **D-22: The `08-07` human walk is DESCOPED by Braian, 2026-07-25.** Stated directly: *"lets just
  switch the design we dont need to test it fully."* Phase 8 ships the re-skin (waves 1–4); the full
  human walk is not required.
  **How this must be recorded — this part is not optional.** `08-VERIFICATION.md` records the walk as
  **deliberately skipped at the user's instruction**, NOT as performed or passed. Phase 8 therefore
  closes at `human_needed`, or `passed` with an explicit override citing this decision — never with
  fabricated walk evidence. Skipping verification is the user's call; inventing it is not, and this
  milestone has already paid for false records (a `HANDOFF.json` that sent sessions to redo finished
  work). Automated gates (`flutter analyze` vs the 61 baseline, `flutter test` vs 248/1, and the
  widget/unit tests the plans add) still run — they are cheap and unaffected by this decision.
  **Known cost, accepted:** phase 06's walk found ELEVEN defects that appeared in no plan. Descoping
  the walk means comparable issues in swap/bridge will ship unfound. Recorded so the tradeoff is
  visible rather than silent.
- **D-23: `bridgeOut` is never executed by an agent.** `bridgeOut(... shouldMintTokens: true)` is a
  real burn-and-mint on-chain call. With the walk descoped there is no reason to fire it at all:
  **dry-run only.** No agent may select live-testnet or live-mainnet; that needs Braian's explicit
  word at the time, and "don't test it fully" is the opposite of that instruction.

### Cross-cutting project rules
- **D-15:** WCAG AA contrast in **both** light and dark modes and in **all** states, including
  disabled — disabled states must stay visibly distinct. This is a hard project rule, not a
  preference.
- **D-16:** Windows is the walk host. Both screens are ordinary Flutter widgets (no platform
  views), so there is no Windows/macOS parity split here — unlike Phase 18's webview work.

### Claude's Discretion
- Task decomposition and plan ordering.
- Which shared `gw_*` primitives to reuse when realising 105 A1 / 120 B1.
- Whether the 031-B receipt is reached by extracting a shared widget or by parameterising the
  existing one — provided D-04/D-05/D-06 hold.

</decisions>

<canonical_refs>
## Canonical References

### Design sources (read before planning)
- `.planning/sketches/105-swap-tab/` — swap tab, `winner: "A1"`
- `.planning/sketches/120-phase-8-flow/` — bridge B1/B2, swap states, result; `winner: "B1"`
- `.planning/sketches/121-phase-8-storyboard/` — page-by-page walkthrough of both journeys
- `.planning/sketches/MANIFEST.md` — rows 105 / 120 / 121
- `.planning/HANDOFF-swap-bridge-phase-8-design.md` — the design session's own record. **Do not feed
  this file to `--ingest`**: the ADR parser hoists its (now-closed) OPEN section into `decisions[]`
  as if locked, fragments multi-line bullets, and drops the Navigation-facts section.

### Requirements / roadmap
- `.planning/ROADMAP.md` § "Phase 8: Swap & bridge" — goal, 4 success criteria, findings 21/22/28
- `.planning/REQUIREMENTS.md` — `SCR-04`

### Code the phase touches
- `lib/squid_router/swap_screen.dart` (430) — swap tab
- `lib/dashboard/bridge/bridge_screen.dart` (726) — bridge
- `lib/squid_router/swap_field.dart` (153) — the amount fields
- `lib/squid_router/swap_settings_drawer.dart` (88) — slippage (D-13)
- `lib/components/buttons/gw_swap_fab.dart` (82) — global FAB (D-14)
- `lib/squid_router/{swap_success_drawer,swap_fail_drawer,swap_drawer_content}.dart` — superseded by
  031-B (D-04, D-06)
- `lib/reown/swap_result_drawer.dart` + `lib/reown/handle_dapp_requests.dart` — **do not touch** (D-05)
- `lib/dev/dev_tools_bubble.dart` — references three drawers; update alongside D-06

</canonical_refs>

<specifics>
## Specific Ideas

- The flip control moving into the seam is specifically what removes the `-170` offset hack in the
  current swap layout — treat that hack's removal as a signal the layout landed correctly.
- Sketch 121 is a map, not a decision sketch. Use it to sanity-check that the planned task order
  produces a coherent journey; do not treat it as a spec.
- No packaged sketch-findings skill exists for these sketches
  (`./.claude/skills/sketch-findings-*` is absent), so the researcher must read the sketch READMEs
  directly rather than expecting distilled findings.

</specifics>

<deferred>
## Deferred Ideas

- **Surface the bridge entry as a first-class action.** Bridge is reachable only via GNUS token →
  More → "Bridge Tokens". Promoting it is an IA restructure, not a re-skin, and ROADMAP's four
  Phase 8 criteria do not cover discoverability. Tracked at
  `.planning/todos/pending/2026-07-25-surface-the-bridge-entry-as-a-first-class-action.md`, to be
  decided together with the deferred mobile-nav-IA item.
- **Wiring real Squid swap execution** (the D-01 TODOs). A functional capability, not a skin —
  belongs in its own phase with its own testing and safety story.
- **Consolidating the dApp result path onto 031-B** (`reown/swap_result_drawer`). Phase 10
  territory (D-05).

</deferred>
