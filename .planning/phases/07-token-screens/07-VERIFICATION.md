---
phase: 07-token-screens
status: gaps_found
verified: 2026-07-24
method: human-walk
requirements: [SCR-03]
next_action: "Plan gap closure: /gsd-plan-phase 7 --gaps (5 fix items + re-walk). Design locked in sketch 152; drawer fixes are drift from won sketches 034-A2 / 030-B1."
---

# Phase 7 Verification — Token Screens (SCR-03)

Verified by human walk (07-03) on the running Windows debug build, dark + light. **Result: gaps_found.**

## SCR-03 criteria
- **Criterion 1 — token-detail/action-row/Info/Convert/drawers match redesign in dark+light:** PARTIAL — surfaces read as redesign; header/title/QR/X sizing off in the Receive drawer; page layout to adopt sketch 152. → GAP 1, 3, 4.
- **Criterion 2 — receive QR scans (dark) / send completes:** receive half **PASS** (decoded on a real phone in dark); send half = **D-02 out-of-scope deferral** (no send flow). QR oversized → GAP 3 (polish, not functional).
- **Criterion 3 — Finding 37 (non-GNUS More disabled, never empty drawer):** not confirmed regressed (empty drawer was a GNUS token, where More opens); the GNUS Bridge drawer body is empty → GAP 5. Non-GNUS disabled state to re-confirm on re-walk.
- **Criterion 4 — Finding 24 (no setState-after-dispose):** **PASS** — zero occurrences (live console monitor during the walk).

## Passes (earned)
- Send/Swap render clearly disabled yet legible in both modes.
- Receive QR decodes with a real phone camera in dark mode.
- No `setState() called after dispose` during chart navigation / refresh ticks.

## Gaps to close (feed /gsd-plan-phase 7 --gaps)
1. **Token-detail layout** → implement sketch **152** (A @ ≥768, D @ <768, Convert below graph on mobile).
2. **Convert Token Price → read-only** (only Amount editable).
3. **Receive QR** oversized → bring `CryptoAddressQR` to sketch **034-A2** (contained QR ~60%).
4. **Receive drawer close (X) too big + header too tall** → bring `ResponsiveDrawer` to sketch **030-B1** (compact quiet band, small top-right X).
5. **More → Bridge Tokens drawer** body empty → fill with real content.
6. **Re-walk** to flip 1–5 to PASS and confirm non-GNUS More-disabled.

Once the gap-closure plans execute and the re-walk passes, this becomes `status: passed`.
