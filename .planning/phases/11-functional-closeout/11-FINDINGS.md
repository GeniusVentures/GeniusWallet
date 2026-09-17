---
phase: 11
name: Functional closeout findings
status: open
---

# Findings

One line per broken thing. Found by walking `11-WALK.md`, or by reading code on the way there.

| # | Where | What | Found by | State |
|---|---|---|---|---|
| F-01 | `assets/json/networks/networks.json` | "Base - Sepolia" carries `chainId: 84531`, which is Base **Goerli** (dead). Base Sepolia is **84532**. Name and RPC host both say Sepolia. `signAndSendTransaction` signs with this field, so any transaction built on this network is signed for a chain that no longer exists. | Code read, 2026-09-16 | open |
| F-02 | `lib/dashboard/chart/` (`ChartDashboardView`) | `RenderFlex overflowed by 35 pixels on the bottom` and a second `0.140 pixels on the right` at the default desktop window size. | Runtime log, 2026-09-16 | open |
| F-03 | `packages/genius_api/lib/web3/web3.dart:424` `executeBridgeOutTransaction` | The `catch` builds `ApiResponse.error(e.toString())` and never returns it — no `return` keyword. Every bridge failure falls through to `'Failed to bridge: unknown'`, so the user is never told why. | Code read, 2026-09-16 | open |

## Not findings — decided elsewhere

Swap's fabricated success receipt, the missing Send flow, dApp connect on Windows and the Banxa
webviews are Section 0 of the walk. They are known broken and are not re-logged here. Swap is
Phase 26.
