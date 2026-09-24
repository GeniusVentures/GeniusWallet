---
created: 2026-09-24T12:00:00.000Z
title: Swap history rows are saved without a chain id, so Base swaps link to etherscan
area: correctness
severity: minor
files:
  - lib/squid_router/swap_screen.dart
---

## Problem

`_swapRow` (`swap_screen.dart:~1137`) builds the history row without the chain id that Send's rows
carry since phase 31. The history screen then falls back to picking the explorer by coin symbol, so a
swap on Base opens etherscan.io instead of basescan. Found by the v2.0 milestone audit.

## Fix direction

Pass the source chain id at the two call sites (`~:527`, `~:578`) and add one test that a Base swap
row resolves to the Base explorer.
