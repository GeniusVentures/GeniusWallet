# Phase 40: Always-available GNUS bridge - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md - this log preserves the alternatives considered.

**Date:** 2026-10-07
**Phase:** 40-always-available-gnus-bridge
**Areas discussed:** Who can bridge, Where Bridge sits, Disabled reasons, Entry without a coin

---

## Who can bridge

| Option | Selected |
|--------|----------|
| Disabled with a reason when not the earning account | yes |
| Offer to switch earning, then bridge | |
| Burn-only for other wallets | |

Gate source: live earning account via `selectedSDKAccount` + `sdkAccountLinks` (chosen) over fixing
the connection stream in genius_api.
Child wallets: disabled with a reason (chosen) over the same rule as any wallet.

## Where Bridge sits

Placement (multi): Assets GNUS row, Dashboard wallet overview, Keep the coin page button. Not chosen:
Swap page link.
Nav tab: No.

## Disabled reasons

Overview shape: single Bridge button (chosen) over an icon action.
Distinct reasons: all four chosen (not earning wallet, switch pending, earning not started, no
GNUS / view-only).
Reason UI: one line under the button (chosen) over a tooltip.

## Entry without a coin

Start on GNUS on the selected network (chosen) over a source-chain picker.
GNUS on another network only: disabled, name the network (chosen) over auto-picking that network.

## Claude's Discretion

Exact copy, state precedence, coin resolution.

## Deferred Ideas

Connection-stream re-emit on switch; switch-then-bridge flow; chain picker.
