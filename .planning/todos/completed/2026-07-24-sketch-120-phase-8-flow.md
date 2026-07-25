# Sketch 120 · phase-8-flow — the rest of Phase 8's design

Design session (2026-07-24) built `.planning/sketches/120-phase-8-flow/` (index.html + README).
Numbered 120 at Jakub's request (leaves 109-119 free; 106-108 taken by a parallel markets session).
Did NOT touch MANIFEST.md or commit (executor-only; MANIFEST already dirty).

**What it covers (completes Phase 8 design beyond 105 A1 swap tab):**
- **Bridge screen** redesign — rec **B1 · Swap-twin** (mirror the Swap tab; kills Material AppBar) vs B2 Network-forward. Awaiting pick.
- **Swap states** — Submitting + **Route error (finding 22)** + Insufficient.
- **Result receipt** — swap + bridge both reuse the shipped **031-B status-led receipt** (030-B shell); resolves the two competing result-drawer impls (findings 21 + 28). No new design needed.

**Open pick:** Bridge B1 vs B2 (rec B1).

**MANIFEST row for executor:**
```
| 120 | phase-8-flow | The missing Phase 8 designs beyond the swap tab — bridge screen, swap error/submitting states, and the swap+bridge result drawer | _bridge pick pending_ (rec **B1 Swap-twin**); swap states + **result = reuse 031-B receipt** (resolves 2 competing impls, findings 21/22/28) | phase-8, swap, bridge, gnus, states, error, result, receipt, flow |
```

**Build notes** (also in README): rewrite `bridge_screen.dart` onto swap components; redirect
`swap_success_drawer`/`swap_fail_drawer`/`reown/swap_result_drawer` + bridge `AlertDialog` into one
031-B receipt; add the route-fetch error branch in `_fetchRoute` (finding 22).

**Phase 8 design status after this:** swap tab (105 A1) + bridge (120 B1) + states + result (031-B)
= design-complete. Ready to plan Phase 8 once bridge B1/B2 is confirmed.
