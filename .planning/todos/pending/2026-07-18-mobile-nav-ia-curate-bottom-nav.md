---
created: 2026-07-18T13:28:11.589Z
title: Mobile nav IA — curate bottom nav to most-used, overflow the rest
area: ui
files:
  - lib/components/overlay/responsive_overlay.dart
---

## Problem

Raised by the user during the 04-03 nav-shell walk (2026-07-18). 04-03 fully
re-branded the navigation shell BUT deliberately kept develop's **full
8-destination set** in both the desktop top bar and the mobile bottom nav — per
the port's hard scope rule "re-skin never restructure" (moving items / changing
IA = a product decision, recorded not decided; see [[ui-redesign-port]]).

**8 items in a mobile bottom nav is poor UX.** The desktop top bar is fine, but on
mobile the bottom nav should show only the **most-used** destinations (the way
Alex Faber's redesign did — his `gw_bottom_nav.dart` / "Gen-B" used a curated
short list, which 04-03 explicitly did NOT adopt), and present the remaining
destinations **another way** (e.g. a "More" overflow, a menu, or a drawer).

This is a **product / IA decision**, intentionally deferred from the re-skin. It
is NOT a re-skin — it changes information architecture.

## Solution

TBD — product decision, likely its own plan (or a Phase 4 follow-up / later
milestone). Scope when picked up:
- Decide which destinations are "most used" for the mobile bottom nav (candidates
  from Alex's Gen-B curated set) vs. which move to the overflow.
- Choose the overflow presentation (More menu / sheet / drawer).
- HARD CONSTRAINT: keep ALL 8 destinations reachable (Phase 4 criterion 2 — every
  route reachable before the port stays reachable) and do NOT change the
  destinations' own behavior; this is purely IA/presentation.
- Desktop top bar can keep the full set (space allows) — this is a mobile-specific
  restructure.
- Apply the standing WCAG contrast rule and the GWColors appearance pattern.
