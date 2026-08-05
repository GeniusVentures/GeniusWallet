---
created: 2026-07-22T09:05:00.000Z
title: Splash/boot screen does not cover the full window — dashboard bleeds through on the right edge
area: ui
severity: visible-on-every-cold-start
files:
  - lib/screens/boot_sequence.dart
  - lib/screens/loading_screen.dart
  - lib/dashboard/home/view/dashboard_screen.dart
---

## What was observed

macOS build, cold start, window ~2000x1440. The GNUS.AI splash (logo + the two brand dots) paints
the navy background across **most** of the window — but a strip roughly **90–100px wide down the
right edge is not covered**, and the dashboard underneath is plainly visible through it: the brain
logo top-right, a card edge, the "Bitc…" markets row, panel borders.

There is also a thin uncovered band along the **bottom** edge in the same screenshot.

So the splash is not a full-bleed overlay. It is being laid out inside something narrower than the
window, or it is painted into a box whose size was measured before the window reached its final
size, while the dashboard behind it is already built and painting.

## Why it matters

It is on the **cold-start path**, so it is the first thing a user sees, every time. It also leaks
the dashboard before the app claims to be ready — which defeats the entire point of the boot gate
(the reason Phase 13 exists: one gate instead of per-section loaders).

## Analysis notes for whoever picks this up

Do NOT fix by eye. Two candidate causes, and they take different fixes:

1. **Sizing** — the splash is inside a `Center`/`ConstrainedBox`/`SafeArea` that bounds it, rather
   than `Positioned.fill` / `SizedBox.expand` in a `Stack`. Then the navy is just a big box, not the
   screen.
2. **Stacking/timing** — the splash is a sibling of the dashboard in a `Stack` whose extents are
   driven by the dashboard child, or it is swapped in a frame late, so the first painted frame shows
   both. `dashboard_screen.dart:62` is already a `Stack(fit: StackFit.expand)` — check whether the
   boot screen participates in that stack or sits outside it.

Evidence to gather before proposing anything: paint the splash background a debug colour and screen-
record one cold start. The width of the uncovered strip against the window width tells you which of
the two it is — a constant strip means (1), a strip that only exists on the first frames means (2).

## Ownership warning

`lib/screens/boot_sequence.dart` is **session B's file** (Phase 13, boot-loading sequence, sketch
015 "Signal Edge"). This todo is a report, not a claim. Coordinate before editing it — or hand this
file to session B and let them fold it into Phase 13, which is where it most likely belongs.

## Route

User asked for this to become a **GSD quick fix** after the transactions design work lands — not now.
Analyse first (`superpowers:systematic-debugging`, root cause before fix), then `/gsd-quick`.
