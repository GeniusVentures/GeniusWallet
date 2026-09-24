---
created: 2026-09-23T23:30:00.000Z
title: Swap silently truncates an amount finer than the token's precision
area: correctness
severity: minor
files:
  - lib/squid_router/swap_screen.dart
  - lib/squid_router/squid_util.dart
---

## Problem

`toBaseUnits` truncates excess fractional digits by design, so typing `1.0000009` for a 6-decimal
token quotes and swaps exactly `1.000000` with no message. Send now refuses such an amount with
"<TOKEN> supports up to N decimal places."; Swap still truncates silently.

## Fix direction

Apply the same refusal on the Swap amount field (trailing zeros past the precision stay accepted),
without changing `toBaseUnits` itself, which the router path relies on.
