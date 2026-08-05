---
phase: 06-onboarding
plan: 06
subsystem: ui
tags: [flutter, onboarding, closeout, security-gate, fresh-install-walk, walked-both-modes]

# Dependency graph
requires:
  - phase: 06-onboarding
    plan: 05
    provides: "The finished onboarding tree (landing, both flow shells, Legal, wallet-type chooser, both seed screens, hardened import, shared PIN) this plan gates and walks"
  - phase: 03-gw-component-library
    provides: "GWButton, GWColors extension, the guard-script house style"
provides:
  - "tool/check_onboarding_seed_safety.sh — UI-SPEC §3's six-item security gate as one re-runnable command over the FINISHED tree"
  - "Five filed todos, one per deliberately-unfixed gap, each against its OWNING file"
  - "The fresh-install end-to-end walk evidence for ROADMAP criterion 1 (both flows, both modes)"
affects: []

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "A cross-file security property confirmed in each per-plan diff can still be false in the union; gate the SET over the finished tree in one command, with comment-stripped matching and an adjacency (not presence) test for the finding-19 mounted guard."
    - "Runtime token assembly from string parts (per check_no_new_key_logging.sh) so the gate's own source cannot trip the console-logging tripwire it implements."

key-files:
  created:
    - tool/check_onboarding_seed_safety.sh
  modified:
    - .planning/phases/06-onboarding/deferred-items.md
    - .planning/STATE.md   # Pending Todos ledger only (five new one-line entries)

key-decisions:
  - "The §3 security gate PASSES all six checks over the finished tree (bec9c03): recovery phrase read-only (no SelectableText/TextField/TextFormField on a non-comment line in either seed screen), _isVisible defaults true, no print/debugPrint-family call under lib/onboarding/** or pin_screen.dart and no BlocObserver in lib/, the finding-19 mounted guard adjacent (<=2 lines) to the awaited clipboard copy, autocorrect+enableSuggestions both false on the import field, and the PIN masked with the appearance-aware gw.statusError (not the flat const)."
  - "Todo #1 was filed HONESTLY, not to the plan's literal wording. The plan told me to record GWButtonVariant.secondary as still failing AA at 1.93:1; the walked evidence (06-01-SUMMARY + gw_button.dart:136,138 at HEAD) shows quick task 260721-fa7 already repointed it to brandPrimaryOnSurface (~4.76:1). The todo records the corrected state — code fixed, only the live light-mode walk remains — cross-linked to the light-mode backlog, rather than re-asserting a refuted number. No-unearned-claim discipline."
  - "verify_additive_boundary.sh Check 2 fails on FOUR duplicate private class names (_Section, _SplashState, _TimeframeSegment[State]) — none in onboarding. They entered from OTHER phases merged onto this branch after the 2e82ec2 phase-06 baseline (Phase 16 markets _TimeframeSegment via aa78eec; the Signal Edge boot _SplashState via 29b183b; _Section pre-existing). Task 1 adds only a tool/ script and no lib/ code, so it cannot have changed the census. Logged to deferred-items.md; the shadow-name baseline needs a redesign-track update, out of phase-06 scope."

requirements-completed: [SCR-02, GAP-04]
---

# 06-06 SUMMARY — Phase 6 closeout: security gate, gap todos, and the fresh-install walk

## What this plan delivered

1. **`tool/check_onboarding_seed_safety.sh`** — UI-SPEC §3's six security properties re-asserted over the
   FINISHED tree in one runnable, re-runnable command. All six PASS (verified twice — by the executor and
   by an independent orchestrator re-run). Committed `bec9c03`.
2. **Five gap todos** in `.planning/todos/pending/`, each naming its OWNING file and citing walked
   evidence: `gw_button.dart` secondary-variant light-mode text, seed-screen screenshot/recording
   exposure, the dead `/backup_phrase` route + `BackupPhraseScreen`, the inert `PasteField.height`, and
   the import screen's per-build never-disposed `TextEditingController`s. Added to the STATE ledger.
   Committed `3d7aa07`.
3. **The fresh-install end-to-end walk** — the one thing no single-screen plan can establish.

## Fresh-install walk (Task 3) — evidence

Setup was performed via `.planning/reference/FRESH-INSTALL-RECIPE.md` (the orchestrator cleared RUN A's
profile to a verified pristine state: node dirs 0, hive boxes 0; the user managed re-clears between the
subsequent runs). Debug build launched with `GW_DEV_TOOLS=true` (appearance toggle only; no Mock
injectors used). The post-walk profile shows `node dirs: 9` — multiple genuine SDK inits, consistent
with several real onboarding completions (not a fixture).

**Walked and reported by the user (human-verify gate):**

| Leg | Result |
|-----|--------|
| RUN A — create wallet, DARK, landing → dashboard, uninterrupted | ✅ pass |
| RUN A — stress: narrow/short + resize at recovery-phrase & import; full back-nav; copy-then-back interruption | ✅ pass (no throw on copy-then-back) |
| RUN A — create wallet, LIGHT (fresh profile) | ✅ pass |
| RUN B — import wallet (throwaway mnemonic), to dashboard | ✅ pass |
| Any ONBOARDING screen overflow/clip/throw | ✅ none (only the dashboard chart — see below) |

**Console scan (orchestrator-verified over the captured run log):** no recovery word, no PIN, and no
`NewWalletState(` / `PinState(` dump. Clean for criterion 2's console clause.

## Criterion-by-criterion verdict (ROADMAP Phase 6)

1. **Create/import/recovery/verify/legal render in the redesign and complete end to end on a fresh
   install** — **PASS.** RUN A (create, dark + light) and RUN B (import) each walked from a fresh profile
   to `/dashboard`; no onboarding-screen overflow at default or reduced window sizes.
2. **Recovery phrase read-only, hide-toggle works, no seed in console** — **PASS.** Gate checks 1/2/3 hold
   over the finished tree; live console scan across the walk found no seed word.
3. **Copy confirmation does not throw after mid-copy dismissal (finding 19)** — **PASS.** Gate check 4
   proves the `mounted` guard is adjacent to the awaited copy; the walk's copy-then-back interruption
   threw nothing.
4. **select-wallet-type wears the extended design and routes correctly (GAP-04)** — **PASS.** Walked via
   RUN B (select Ethereum → import); GAP-04 closed by 06-02 (`ba8e412`).

## Out-of-scope observation recorded, not attributed to Phase 6

During the walk, once onboarding completed and the dashboard loaded, the console showed a
`RenderFlex OVERFLOWING` on `CryptoLiveChart` (a `h=7.5` chart slot). This is the **known dashboard
Bitcoin-chart height overflow** — an accepted Phase 05 override
(`.planning/todos/pending/2026-07-21-bitcoin-chart-card-height-dashboard-vertical-budget.md`), not an
onboarding defect. Recorded here so it is not silently absorbed; it does not block Phase 6.

## Scope fence (UI-SPEC §5) — held

Zero diff across the 8 logic-only bloc files and the dead `backup_phrase_screen.dart` over the phase's
commits. The §5.3 reconciliation (8 logic-only + 1 dead + 13 table-carrying = 22) holds.

## Known caveats (honest record)

- **`flutter analyze` on the phase scope exits 1 on two pre-existing info-level issues**
  (`recovery_phrase_screen.dart:193` `use_build_context_synchronously`; `verify_recovery_phrase_screen.dart:161`
  `SELECT_WORD_COUNT` naming). Both pre-date this plan, which adds no `lib/` code.
- **`verify_additive_boundary.sh` Check 2 fails** on four duplicate private class names from the redesign
  track / boot work, not onboarding (see key-decisions). Logged to `deferred-items.md`; needs a
  shadow-name baseline update outside this phase.
- **The fresh-per-run guarantee for RUN A-light and RUN B rests on the user's report** — the orchestrator
  cleared only RUN A's initial profile; the user managed subsequent re-clears. The `node dirs: 9` count
  is consistent with multiple genuine completions.

## Phase 6 verdict

**COMPLETE.** All four ROADMAP criteria PASS; the §3 security gate is re-runnable by any later phase in
one command; the §5 scope fence held; and every deliberately-unfixed gap is filed against its owning file
rather than absorbed into an implied pass.
