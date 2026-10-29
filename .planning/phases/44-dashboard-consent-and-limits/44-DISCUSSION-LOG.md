# Phase 44: Dashboard consent and limits - Discussion Log

> **Audit trail only.** Do not use as input to planning, research, or execution agents.
> Decisions are captured in CONTEXT.md; this log keeps the alternatives considered.

**Date:** 2026-10-27
**Phase:** 44-dashboard-consent-and-limits
**Areas discussed:** Connect prompt, Spend confirm, Prompt limits, Connected sites list

Braian asked for recommendations with pros and cons and took the recommended option every time.

| Question | Options | Chosen |
|---|---|---|
| Decline code | 4001 / 4100 | 4001 |
| Connection lifetime | Until revoked / until app restart | Until revoked |
| Connection scope | Origin only / origin + wallet | Origin only |
| Confirm UI | Reuse approve drawer / new job sheet | Reuse approve drawer |
| PIN on approve | No PIN / require PIN | No PIN |
| Rate limit | 3 per minute / 10 per minute / one open at a time only | 3 per minute |
| Call during open prompt | Reject now (-32005) / queue | Reject now |
| Settings placement | Own section / merge with WalletConnect | Own section |

## Claude's Discretion

Revoke forgets the origin (next call prompts); every method needs the connection; connect prompt
reuses the same drawer; no revoke-all; storage, rate-limit mechanics, dev bubble entries, copy.

## Deferred Ideas

PIN/biometric on spends (wallet-wide phase), per-origin spend cap, merged connections list.
