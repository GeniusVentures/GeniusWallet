---
created: 2026-07-25T12:35:51.827Z
title: Surface the bridge entry as a first-class action (deferred product/IA decision)
area: ux
files:
  - lib/dashboard/token/token_info_screen.dart
  - lib/navigation/router.dart
---

## Problem

Bridge is effectively undiscoverable. Reaching it today takes: **GNUS token → "More" → "Bridge
Tokens"** (`token_info_screen.dart:181`), which pushes `/bridge` → `BridgeScreen(fromToken:
selectedCoin)` (`router.dart:270,275`). It is a back-arrow sub-screen — **not** a tab, and **not**
a swap/bridge toggle. It is also GNUS-only (`isGnusBridgeEnabled`) and disabled at zero balance.

Raised as an optional finding by the 2026-07-24 Phase 8 design session (sketch 120). **Deliberately
deferred out of Phase 8 on 2026-07-25 by Braian**, because promoting it is an **IA restructure, not
a re-skin** — and "re-skin never restructure" is doctrine on this branch (it is why 04-03 kept
develop's 8 nav destinations rather than curating them). ROADMAP's four Phase 8 success criteria do
not cover discoverability, so doing it inside Phase 8 would need a fifth criterion and would widen
a re-skin phase into a product change.

## Solution

Treat this as a **product/IA decision**, in the same bucket as the deferred mobile-nav-IA item
(`2026-07-18-mobile-nav-ia-curate-bottom-nav.md`) — ideally decided together, since both are
"where does this belong in the navigation" questions and answering them piecemeal risks a
half-curated nav.

Open questions a decision needs to answer:

- Does Bridge deserve top-level placement while it remains **GNUS-only**? A first-class action that
  is inert for every other token may read as broken rather than discoverable.
- If it is surfaced, what happens at **zero balance** — hidden, or visible-but-disabled? (Today's
  disabled-at-zero behavior is inside the More menu, where it is far less conspicuous.)
- Is the natural home a nav destination, an action on the GNUS token page, or a swap/bridge toggle
  on `/swap` (which sketch 120 B1 makes visually plausible, since the bridge screen now mirrors the
  swap tab)?

**Do not action this without a product decision** — it is not a bug and the current behavior is
intentional.
