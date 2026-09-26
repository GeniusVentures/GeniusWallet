# Phase 10: dApp connectivity - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md — this log preserves the alternatives considered.

**Date:** 2026-09-26
**Phase:** 10-dapp-connectivity
**Areas discussed:** Pairing dialog skin, Failed-init recovery, Windows pairing proof, Browser clipboard pairing

---

## Pairing dialog skin

| Option | Description | Selected |
|--------|-------------|----------|
| ResponsiveDrawer | Same container as the approve-connection drawer | ✓ |
| GWDialog in place | Keep a centred modal, swap in GW components | |
| You decide | Planner picks | |

Follow-up, first view: **Keep today's split** (desktop = paste field, phone = QR) ✓; alternatives were
"both at once on desktop" and "paste first everywhere".

## Failed-init recovery

| Option | Description | Selected |
|--------|-------------|----------|
| Retry once, then restart msg | Real retry per press; restart toast if it fails again | ✓ |
| Retry every press, no restart msg | Connection-check message instead | |
| Auto-retry in background | Backoff retry when network returns | |

## Windows pairing proof

| Option | Description | Selected |
|--------|-------------|----------|
| Live walk + unit test | Init-logic test plus a real pairing + personal_sign on this machine | ✓ |
| Unit test only | | |
| Live walk only | | |

## Browser clipboard pairing

| Option | Description | Selected |
|--------|-------------|----------|
| Show an error toast | Shared toast, never includes the URI | ✓ |
| Keep it silent | | |
| Out of scope | | |

## Claude's Discretion

- Drawer layout and copy; how `initOnce()` is made testable.

## Deferred Ideas

None.
