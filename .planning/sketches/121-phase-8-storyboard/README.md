---
sketch: 121
name: phase-8-storyboard
question: "What does the whole Phase 8 experience look like page-by-page, from the user's perspective — Swap and Bridge as ordered journeys?"
winner: null
tags: [phase-8, swap, bridge, storyboard, flow, walkthrough, navigation, user-journey]
---

# Sketch 121: Phase 8 storyboard (page by page)

## Purpose

Not a design-decision sketch — a **walkthrough**. It lays the whole Phase 8 experience out as two
ordered filmstrips so the flow is legible from the user's point of view, using the decided pieces
(105 A1 swap, 120 B1 bridge, 031-B receipt). Scroll each flow left→right.

## The two journeys

**Swap flow** (ETH → USDC, any token, from the Swap navbar tab):
1. Open Swap (empty) → 2. Pick a token (search sheet) → 3. Type amount → *Finding best route…* →
4. Quote ready (rate/fee/slippage, CTA live) → 5. Submitting (spinner) → 6. Result receipt (031-B) + toast.

**Bridge flow** (250 GNUS, Ethereum → Polygon):
1. **On the GNUS token** (Receive/Send/Swap/**More**) → 2. More → **Bridge Tokens** → 3. Bridge screen
opens (own screen, back arrow) → 4. Choose destination network → 5. Amount → gas estimate, CTA
*Review bridge* → 6. Bridging (spinner) → 7. Result receipt (**same 031-B**) + toast.

## The one navigation truth this surfaces

Swap and Bridge are **not** a toggle. **Swap** is a top-nav tab (any token). **Bridge** has no tab —
it's reached **only from the GNUS token → More → Bridge Tokens** (`token_info_screen.dart:181`,
gated by `isGnusBridgeEnabled`, disabled at balance 0), pushing `/bridge`
(`router.dart:270`) as its own back-arrow screen. Step 1 of the bridge strip shows exactly where it
begins. Whether to *surface* that entry more (vs hiding under "More") is an open, separate call.

## How to View

`open .planning/sketches/121-phase-8-storyboard/index.html` — tabs: Swap flow / Bridge flow;
Dark/Light toggle bottom-right. Companion to 120 (the component-level sketch) and 105 (the swap tab).
