---
phase: 4
slug: navigation-shell-chrome
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-07-17
---

# Phase 4 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.
>
> **This project has NO working test harness** (`flutter test` does not compile — APP-02, deferred to
> v2). Every prior phase (`02-VERIFICATION.md`, `03-VERIFICATION.md`) treats `flutter analyze` as a
> gate, never evidence. Phase 4's validation spine is therefore the **human walk**, consistent with
> Phases 2–3 — NOT unit/widget tests. The authoritative, per-criterion observation map lives in
> `04-RESEARCH.md` § "Validation Architecture"; this file is the execution-time contract that points to it.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | None (`flutter test` does not compile — APP-02) |
| **Config file** | none — mechanical gates below stand in |
| **Quick run command** | `flutter analyze lib` (0-errors gate; **never** evidence of runtime correctness) |
| **Full suite command** | `bash tool/verify_additive_boundary.sh` (shadow-import boundary + duplicate-class census + WIRE- tripwire) + a debug-build human walk |
| **Estimated runtime** | analyze ~3s; guard ~2s; human walk ~10–20 min |

---

## Sampling Rate

- **After every task commit:** `flutter analyze lib` (0 errors) — mechanical shape check only, not evidence.
- **After plan 04-01 (theme-only):** the **D-02 gallery re-walk**, both appearance modes. **This is the
  gate for every subsequent plan in this phase and is not optional** — it derives the dark-only count
  and confirms the theme flips before any screen re-skin builds on it.
- **After each shell/screen re-skin plan (04-02+):** `bash tool/verify_additive_boundary.sh` (confirm
  the shadow allowlist and duplicate-class census haven't drifted) + a targeted human walk of that
  plan's surface, both appearance modes.
- **Phase gate (before `/gsd-verify-work`):** the full criteria table (RESEARCH §Validation
  Architecture), both appearance modes. **Per D-03, a light-mode failure on ANY of the 6 criteria
  blocks phase close — it cannot be deferred the way Phase 3's theme-confound gaps were.**
- **Max feedback latency:** the human walk — bounded by build time, not seconds.

---

## Per-Criterion Verification Map

The full observation map (Req/Criterion → Behavior → Observation method → Recipe) is authored in
`.planning/phases/04-navigation-shell-chrome/04-RESEARCH.md` § "Validation Architecture → Phase
Requirements → Observation Map". It covers: the D-01/D-02 re-walk gate, criteria 1–6, and BEH-02.
Do not duplicate it here — read it there. Summary of the spine:

| Criterion | Requirement | Observation | Blocks close on light-mode fail? |
|-----------|-------------|-------------|----------------------------------|
| D-01/D-02 re-walk gate | (sequencing) | Human walk, both modes, all 30 gallery sections; derive dark-only count | Yes — gate for all below |
| 1 (boot, every route, no exception) | NAV-01 | Cold `flutter run` (no define), navigate all 8 shell + reachable routes | Yes |
| 2 (shell skin, rail/bottom nav, Web tab) | NAV-01, NAV-02 | Human walk + Release-exe side-by-side; resize across 1024px | Yes |
| 3 (`loadStoredWallets()` at boot) | NAV-02 | Cold start → `/dashboard`, wallets render without manual refresh | Yes |
| 4 (rename/delete/guard/re-select/live/toast) | NAV-02 | Scripted drawer walk (6 sub-behaviors) | Yes |
| 5 (Settings + SDK mgr re-skin, behavior intact) | GAP-02, GAP-03 | Exercise each section's primary action, both modes | Yes |
| 6 (branded exception screen; SDK shutdown) | BEH-02 | Deliberate fault injection, both modes; window-close → `shutdownSDK()` log | Yes |
| BEH-02 `!_dirty`/`GlobalSwapFabHost` | BEH-02 | **DEFERRED to swap-FAB phase (D-08)** — the crashing component isn't built this phase | N/A this phase |

---

## Wave 0 Requirements

*No test-file scaffolding — there is no test infrastructure to extend (APP-02 stands).* The only
Wave-0-shaped prerequisite is the tooling note below.

---

## Manual-Only Verifications

**Every criterion in this phase is manual-only** — that is the project's reality, not a gap. See the
RESEARCH observation map for the exact recipe per criterion. Two standing environment facts the walker
must honor (from prior phases):

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| All 6 criteria + the D-02 gate | NAV-01/02, GAP-02/03, BEH-02 | No test harness (APP-02); render/appearance correctness needs human eyes | RESEARCH §Validation Architecture; run recipe with the pinned Flutter SDK PATH + CMAKE_ARGUMENTS from STATE.md |
| Reference comparison | NAV-01/02 | The Release exe and develop build share a Hive dir and deadlock on lock files | Close one before opening the other, every switch |

---

## Tooling Gap (advisory, not blocking)

Whatever plan (if any) touched `GlobalSwapFabHost` was to add a `grep -rn "gw_ai_fab\|lib/ai/"` import
check — but per **D-08 that component is deferred out of Phase 4 entirely**, so this gap does not apply
this phase. Re-surface it in the swap-FAB phase. `verify_additive_boundary.sh` tripwires literal
`WIRE-` markers only, not import-graph reachability into `lib/ai/`.
</content>
