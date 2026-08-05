# Phase 7: Token screens — Discussion Log

**Date:** 2026-07-23 (human reference only; not consumed by downstream agents)

## Gray areas presented
1. Address book scope — no code exists; build vs defer
2. Send/Receive/More: drawers vs pages
3. Send behavior (WIRE-2)
4. Token-detail top slot / header

**User selected to discuss:** Send behavior (WIRE-2), Send/Receive/More surfaces.

## Key discovery (from reading the code)
- The token-page **Send** button is a dead `const ActionButton` with **no `onPressed`**
  (`token_info_screen.dart:174`); Receive and More are wired, Send and Swap are inert.
- **No `/send` route or `Send*Screen`** exists anywhere in `lib/`.
- Consequence: ROADMAP criterion 2's "a send completes end to end" has no send flow to re-skin.

## Decisions
- **Send:** re-skin only; do NOT wire a send flow. It stays inert. A real send flow → its own future
  phase. (User picked "Re-skin only; fence Send OUT".) → criterion 2's send half is a deferral.
- **Surfaces:** keep the `ResponsiveDrawer` pattern, re-skin in place; no promotion to full screens.
- **Address book** (not discussed): applied the same logic as Send — no code exists, build-new → fenced
  out / deferred.
- **Top slot** (not discussed): keep reusing the A2 `CoinCardRow`.
- **Receive QR:** light background in both modes (finding 16/6).

## Deferred
Real Send flow; address book; markets tab (Phase 16); chart re-skin (Phase 5); timeframe ranges.

## Claude's discretion
Per-widget re-skin token choices; finding-37 disabled-More affordance details.
