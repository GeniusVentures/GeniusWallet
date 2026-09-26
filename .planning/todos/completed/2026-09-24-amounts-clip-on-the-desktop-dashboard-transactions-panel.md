---
created: 2026-09-24T15:00:00.000Z
title: Amounts clip on the desktop dashboard Transactions panel
area: layout
severity: minor
---

## Problem

On desktop the dashboard panel (about 376px) keeps the 44px time column, leaving the amount column about 114px (`transaction_displays.dart:551-557`). At Inter 16/w600, `+ 476.18 USDC` (120.5px) and `- 1.25 WSTETH` (123.6px) ellipsise, and four-figure amounts lose digits. Phones are fine since d5993c58 dropped the time column there.

## Fix direction

Drop the time column when the row (not the window) is narrow, put the fiat value on one line, or abbreviate large magnitudes. Ship with a real-font width test shaped like `transaction_row_subtitle_test.dart`. Reserving a fixed 96px for the amount stays rejected.

## Resolution

The narrow row split the name block and the amount 1:1, so the amount got a fixed half whatever it
needed. The amount now keeps its natural width and the name block takes the rest, down to a floor
of the status-tail cap plus its gutter, so the subtitle gives way first. The time column stays.
`test/dashboard/transaction_row_amount_width_test.dart` checks that `+ 476.18 USDC`,
`- 1.25 WSTETH`, `+ 1,476.18 USDC` and `+ 12,345.67 USDC` draw whole at 376px in real Inter. The
subtitle ledger's lead-cut allowlist shrank (mint, escrow and most transfer cells no longer cut).
Swaps still cut `Swapped` on every status with a tail, now more deeply, because their amount is wide.
