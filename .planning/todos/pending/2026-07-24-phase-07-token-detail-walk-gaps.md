# Phase 07 (token-screens) — 07-03 human-walk outcome + gaps

**Date:** 2026-07-24
**Source:** 07-03-PLAN.md blocking human-verify walk (Windows debug run, dark+light)
**Status:** OUTSTANDING — phase 7 does NOT close as PASS; gap-closure + re-walk required.
**Chosen path:** responsive sketches FIRST (token-detail + drawers), then code fixes to match.

## Walk results vs the 6 checks
- Check 1 — Visual fidelity: **PARTIAL** — surfaces read as redesign, but header + title sizing are off (see gaps).
- Check 2 — Send/Swap disabled legibility: **PASS** (no complaint; both read clearly disabled, legible).
- Check 3 — Finding 37 (non-GNUS More disabled): **NOT A REGRESSION** — empty drawer was seen on a **GNUS** token (More is meant to open there). Non-GNUS "More does nothing" still to be explicitly re-confirmed. Real gap = empty Bridge body (below).
- Check 4 — Receive QR: **FUNCTIONAL PASS** — decoded with a real phone camera in dark mode. Oversized (polish gap below).
- Check 5 — Convert: behavior updates, BUT price field editable (bug below).
- Check 6 — Finding 24 (setState-after-dispose console watch): **PASS so far** — zero occurrences during the walk (live monitor).
- ROADMAP criterion 2 send-half: out-of-scope deferral (D-02) — no send flow exists. NOT a pass, NOT a gap.

## Gaps to close (feed /gsd-plan-phase 7 --gaps after sketches)
### Behavior
1. Convert card: token **price** input is user-editable → make it **read-only** (only amount editable).
2. "More" (GNUS token) → Bridge Tokens drawer opens with a description but **empty body** → fill with real Bridge Tokens content.

### Layout / sizing (token-detail + drawers) — sketch first
3. Header occupies too much vertical space → tighten.
4. Title font size too large → reduce.
5. Receive QR too big → downsize to ~60% of current.
6. Drawer close (X) button too big → resize/restyle.
7. Responsive: produce sketches for token-detail + drawers across breakpoints (all responsive screens).

## Notes
- App was left running (Flutter 3.41.9 debug) during the walk; console clean.
- Re-walk required after fixes to convert PARTIAL/gap items to PASS and confirm non-GNUS More-disabled.
