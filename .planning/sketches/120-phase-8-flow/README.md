---
sketch: 120
name: phase-8-flow
question: "What are the missing designs that complete the whole Phase 8 (Swap & bridge) flow — beyond the swap tab (105 A1) — so the phase is design-complete?"
winner: "B1"
tags: [phase-8, swap, bridge, squid, gnus, states, error, result, receipt, drawer, flow]
---

# Sketch 120: Phase 8 flow (the missing pieces)

## Design Question

Sketch **105 A1** covered the Swap *tab*. But Phase 8 is **"Swap & bridge"** with four success
criteria that span more surfaces than the tab. This sketch designs everything else the flow needs so
Phase 8 can be planned as design-complete. What's missing, mapped to the code + findings:

| Missing surface | Code today | Criterion |
|---|---|---|
| Swap non-happy states (submitting, **route error**) | `swap_screen.dart` — receive can go stale silently | SC2 / finding 22 |
| Swap + bridge **result** drawer | `swap_success_drawer` / `swap_fail_drawer` / `swap_drawer_content` **vs** `reown/swap_result_drawer` — two competing impls | SC1/SC3 · findings 21 |
| **Bridge screen** | `dashboard/bridge/bridge_screen.dart` — Material AppBar + dropdowns + `TextButton`, no redesign | SC1 |
| **Bridge result** | `bridge_screen.dart` `AlertDialog` (from→to, hash, error) + toast | SC4 / finding 28 |

## Key finding — the result drawer is already designed

The swap/bridge **result** does not need a new design. Sketches **030-B (drawer shell)** and **031-B
(status-led receipt)** already shipped the pattern — 031's own question is *"where a user lands after
a transaction, swap, or buy resolves."* So the move is: **route both swap-result and bridge-result
through 031-B**, which also resolves the two competing implementations (`swap_*_drawer` vs
`reown/swap_result_drawer`). This sketch's Result tab just proves 031-B fills cleanly from either
flow across Success / Pending / Failed.

## How to View

Serve `sketches/` and open `/120-phase-8-flow/index.html`. Four flow stages as tabs:

- **Bridge · B1 · Swap-twin** ⭐ — the GNUS bridge redesigned to mirror the Swap tab exactly: network
  route bar, two cards + connector, gas/route rows, gradient CTA with states. Kills the Material
  AppBar + dropdowns. Instant recognition from Swap. Type an amount / MAX / change destination network.
- **Bridge · B2 · Network-forward** — leads with the source→destination network selector as the hero
  (bridge is fundamentally cross-chain movement of GNUS), amount below. More distinct from Swap; heavier.
- **Swap · states** — the missing states on 105 A1. Cycle: **Submitting** (in-flight spinner),
  **Route error (f22)** — receive amount → `—` + a red "not current" notice + Retry (never a stale
  quote), **Insufficient**.
- **Result · receipt** — swap AND bridge results in the shipped **031-B** receipt. Cycle
  Swap/Bridge × Success/Pending/Failed to see one receipt serve both flows.

## Variants / recommendation

- **Bridge: B1 · Swap-twin recommended** — consistency with the just-decided Swap A1 is worth more
  than novelty; a bridge that looks like the swap is instantly learnable, and it's the lowest-churn
  reskin of `bridge_screen.dart`.
- **Result: reuse 031-B** (not a new design) — one receipt, filled from either flow.

## What to Look For

- **Bridge B1 vs B2:** does mirroring Swap (B1) feel right, or does bridge deserve its own
  network-hero identity (B2)?
- **Route error (f22):** is the "—" + notice unmistakable that the quote is dead, not just slow?
- **One receipt for both flows:** does 031-B carry a bridge result (GNUS→GNUS across chains) as well
  as a swap? Watch the Pending state — a cross-chain bridge is often still confirming when the drawer opens.
- **Both themes** — toggle Dark/Light.

## Notes for build

- Bridge screen is a full rewrite of `bridge_screen.dart` off the Material `AppBar`/`DropdownButton`/
  `TextButton` onto the swap tab's field/CTA/route components.
- Result: delete/redirect `swap_success_drawer` + `swap_fail_drawer` + `reown/swap_result_drawer`
  into a single 031-B receipt call; bridge's inline `AlertDialog` (`bridge_screen.dart:233-514`) → the
  same receipt (finding 28: toast already fires; keep it alongside).
- Swap: add the route-fetch error branch (finding 22) — today `_fetchRoute`'s catch only shows a
  snackbar and leaves `toAmount` stale.
