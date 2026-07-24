---
phase: 07-token-screens
plan: 03
subsystem: token-screens-human-walk
tags: [human-verify, walk, fidelity, qr, finding-37, finding-24, gaps]
requires: [07-01, 07-02]
provides:
  - "Human-walk evidence for the Phase 7 token-detail re-skin (dark+light)"
  - "Gap list feeding 07-VERIFICATION.md (status: gaps_found)"
affects: []
tech-stack:
  added: []
  patterns: []
key-files:
  created: []
  modified: []
decisions:
  - "Walk performed on the running Windows debug build (Flutter 3.41.9). Recorded honestly per no-unearned-PASS: 2 checks PASS, 1 functional PASS, remaining OUTSTANDING."
  - "The 'header/title/X/QR too big' findings are the RECEIVE DRAWER, not the page (the page uses a bare 56px AppBar with no title) — confirmed with the user."
  - "Design direction for the layout gaps resolved in sketch 152 (A@>=768 + D@<768, Convert below graph on mobile); QR/X/header are drift from won sketches 034-A2/030-B1."
metrics:
  duration: ~walk
  completed: 2026-07-24
  tasks: 1
  requirements: [SCR-03]
status: complete
---

# Phase 7 Plan 03: Human Verification Walk — Summary

Blocking human-verify walk of the token-detail re-skin on the running Windows debug build, in dark + light.

## Results vs the six checks
1. **Visual fidelity** — PARTIAL. Surfaces read as the redesign; layout/sizing issues below.
2. **Send/Swap disabled legibility** — **PASS** (both read clearly disabled, legible, not tappable).
3. **Finding 37 (non-GNUS More disabled)** — NOT confirmed as regressed. The empty drawer seen was on a **GNUS** token, where More is *meant* to open. Real issue = empty Bridge body (gap 4). Non-GNUS "More does nothing" still to be explicitly re-confirmed on re-walk.
4. **Receive QR** — **FUNCTIONAL PASS** (decoded with a real phone camera in dark mode). Oversized (gap 3).
5. **Convert** — behavior updates, but the **Token Price field is editable** (gap 2).
6. **Finding 24 (setState-after-dispose)** — **PASS** — zero occurrences during the walk (live console monitor).

ROADMAP criterion 2 send-half = acknowledged out-of-scope deferral (D-02): no send flow exists. Not a pass, not a gap.

## Gaps (→ 07-VERIFICATION.md: gaps_found → /gsd-plan-phase 7 --gaps)
1. Token-detail layout → resolved to **sketch 152** (A tablet/full, D mobile w/ Convert below graph).
2. Convert **Token Price** must be **read-only** (only Amount editable).
3. Receive drawer QR too big → bring shipped `CryptoAddressQR` to **sketch 034-A2** (contained QR).
4. Receive drawer close (X) too big + header too tall → bring `ResponsiveDrawer` to **sketch 030-B1** (compact quiet band).
5. More → **Bridge Tokens** drawer body is empty (one lone button) → fill with real content.
6. Re-walk after fixes to flip 1–5 to PASS and confirm non-GNUS More-disabled.

Design captured/committed: sketch 152 (`bddedaf`). Walk gaps also mirrored in `.planning/todos/pending/2026-07-24-phase-07-token-detail-walk-gaps.md`.
