---
created: 2026-07-21T00:00:00.000Z
title: Side-by-side walk — dashboard vs Release exe, now UNBLOCKED on the Windows box
area: ui
files:
  - .planning/phases/05-dashboard/
---

## Problem

ROADMAP Phase 5 criterion 1's "match the Release exe at `GeniusWallet-3514`" clause was
recorded as NEVER TESTED, attributed to the reference exe being absent from the machine that
wrote `05-VERIFICATION.md`. That attribution was true of the macOS session which produced the
report, and is WRONG for this Windows machine: the built reference is on disk at
`C:\Users\User\Documents\Projects\GNUS-compare\GeniusWallet-3514\build\windows\x64\runner\Release\genius_wallet.exe`.
`05-VERIFICATION.md` already marks this item `status: NOW_POSSIBLE`.

The five dashboard surfaces — balances, holdings, transactions, markets, news — have never
been compared against the reference exe.

## Solution

Run both binaries side by side on the Windows box and compare the five surfaces one at a
time, recording per-surface pass/deviation.

The redesign is intentionally NOT pixel-identical to the reference in places — approved
sketches 001/002/003/005/006/008 changed the dashboard deliberately. The walk should record
*deliberate deviation* vs *unintended regression*, not demand a pixel match.

The light-mode AA pass is still deferred (dark-first), so light-mode differences against the
reference are expected and out of scope for this walk.
