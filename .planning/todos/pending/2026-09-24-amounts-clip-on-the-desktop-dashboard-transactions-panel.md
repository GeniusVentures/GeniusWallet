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
