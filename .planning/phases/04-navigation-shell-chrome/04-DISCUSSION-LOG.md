# Phase 4: Navigation shell & chrome - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-07-17
**Phase:** 4-navigation-shell-chrome
**Areas discussed:** theme.dart sequencing, Default appearance, Phase 3 loose ends, Wallet drawer UX

---

## theme.dart sequencing

| Option | Description | Selected |
|--------|-------------|----------|
| Theme-only first plan | 04-01 wires theme.dart only, then re-walk gallery + derive count, before any shell/screen re-skin | ✓ |
| Fold theme into shell re-skin | One plan does theme + shell together | |

**User's choice:** Theme-only first plan (the analyst's recommended option).
**Notes:** Matches the STATE.md concern ("wire theme.dart early, before re-skinning any screen"). Unblocks the light-mode question and de-risks the other 5 criteria. → D-01, D-02.

---

## Default appearance

| Option | Description | Selected |
|--------|-------------|----------|
| Dark (recommended by analyst) | Matches develop + Alex's design default; dark-first tuning | |
| Follow the OS setting | Respect system light/dark on first launch, toggle overrides after | ✓ |
| Light | Open light by default | |

**User's choice:** Follow the OS setting.
**Notes:** Overrides the analyst's dark recommendation — recorded as an explicit, informed call. Analyst flagged the consequence and the user proceeded: light mode becomes a shipping surface from first launch, so light-mode BUGS must be fixed (not deferred) before Phase 4 closes. This reinforces the theme-first sequencing. → D-03.

---

## Phase 3 loose ends

| Option | Description | Selected |
|--------|-------------|----------|
| Split by type at 04-01 re-walk | Bugs fixed in Phase 4; deliberate design choices decided by user with gallery in hand | ✓ |
| Fix bugs now, defer design calls to milestone end | Bugs fixed at 04-01; all design decisions held for a later polish pass | |
| Defer everything to a later polish phase | Batch bugs + design into a later pass | |

**User's choice:** Split by type at 04-01 re-walk.
**Notes:** Bugs (theme-confound residue, screen-wrappers-blank-in-dark, disabled-checkbox-invisible) get fixed in Phase 4 — reinforced by the OS-follow appearance decision. The four deliberate dark-only design choices get decided by the user with the walkable gallery in front of them. → D-04, D-05.

---

## Wallet drawer UX

| Option | Description | Selected |
|--------|-------------|----------|
| Match whatever develop does today | Preserve develop's existing delete-confirmation, re-skinned only | |
| Confirmation dialog (destructive) | Modal "Delete wallet?" confirm before removal | ✓ |
| Undo toast (soft delete) | Delete immediately, show Undo toast | |

**User's choice:** Confirmation dialog (destructive).
**Notes:** Analyst flagged the rule interaction: a confirmation dialog is a pure re-skin ONLY if develop already confirms deletes. Recorded conditionally (D-06) — the researcher must first determine develop's current behavior. If develop confirms → re-skin it. If not → this is a deliberate, user-authorized safety guard, the ONE sanctioned exception to "re-skin, never restructure" for this phase, and must be called out explicitly in the plan/SUMMARY. → D-06. Other criterion-4 behaviors are preserve-and-re-skin (D-07).

---

## Claude's Discretion

- HOW theme.dart is reconciled (line-by-line vs adopt Alex's wholesale), bounded by "take Alex's visual."
- Desktop-rail vs mobile-bottom-nav breakpoint follows develop's existing `GeniusBreakpoints` logic — no new breakpoint.

## Deferred Ideas

- Wiring `tool/verify_additive_boundary.sh` into CI (noted in 03-VERIFICATION.md; not enforced today) — later infrastructure decision.
- The two missing gallery sections (dropdowns, `wallet_type_icon`) from Phase 3 criterion 6 Part B — fold into a Phase 4 plan touching the gallery, or a Phase 3 follow-up.
</content>
