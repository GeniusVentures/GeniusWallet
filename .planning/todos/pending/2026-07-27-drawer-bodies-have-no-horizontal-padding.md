---
created: 2026-07-27T00:00:00Z
title: Drawer bodies have no horizontal padding — content touches the panel edges
area: ui
files:
  - lib/reown/swap_result_drawer.dart:25
  - lib/dashboard/home/widgets/transaction_displays.dart:421
  - lib/components/bottom_drawer/responsive_drawer.dart:113
---

## Problem

Found at the running app during the Phase 8 / 08-07 walk (2026-07-27), by Braian, via the dev
bubble's **Swap OK / Swap fail** buttons: *"swap ok and swap fail is basically empty right now …
it does not have paddings in this content."*

Two drawers render their body content flush against the panel edges:

| File | Body padding today |
|------|--------------------|
| `lib/reown/swap_result_drawer.dart:25` | **none at all** — a bare `ListView` straight into the shell |
| `_buildDetailsCard`, `transaction_displays.dart:421` | `EdgeInsets.symmetric(vertical: space2)` — **zero horizontal** |

## Why it looks like a regression but is not one

`ResponsiveDrawer` states the contract in its own comments
(`responsive_drawer.dart:113`): *"Header chrome ONLY — no blanket body padding is added here;
that stays each caller's responsibility (see 07-06-PLAN.md prohibitions — some of the ~19 callers
already pad their own bodies)."*

The 07-06 re-skin (`1d43a13`) pinned the **title** to a 20px inset (`_titleInset = space10`) so the
header would sit on the same axis as the bodies that already pad themselves. These two callers
never did. The header moved in, the bodies did not, and the mismatch is what now reads as broken.

Neither file was touched by Phase 8. `swap_result_drawer.dart` was last modified in `4d1bb36`,
before the redesign began.

## Why it was NOT fixed at the walk

Both files are fenced off from Phase 8 by explicit prohibitions, and Braian chose to respect them
rather than cross them (2026-07-27, asked and answered at the walk):

- **D-05** — `lib/reown/swap_result_drawer.dart` is Phase 10's territory. 08-05 was forbidden from
  importing, referencing or consolidating it.
- **08-05 prohibitions** — *"Do NOT redesign `showTransactionDetails`. The ONLY authorised change
  is guarding the Network Fee row."*

## Where each fix belongs

- **`_buildDetailsCard`** → **sketch 154 · transaction-details-drawer**, which is `_pending pick`
  and already recorded this exact finding: *"`_buildDetailsCard` has padding EXCLUSIVELY vertical —
  labels touch the left edge of the panel, values hit the right. Exactly the flaw sketch 031's
  design question named a year of sketches ago."* Fixing it here would pre-empt that design
  session; fold it into 154's outcome instead.
- **`swap_result_drawer.dart`** → **Phase 10 (dapp connectivity)**, which owns the reown surfaces.
  Worth noting this drawer is entirely pre-redesign: hardcoded `Colors.greenAccent`/`redAccent`,
  a hand-rolled `ElevatedButton` footer and `GeniusWalletColors.deepBlueMenu` rather than the
  appearance-aware tokens. Padding is the symptom; the whole file wants the redesign language.

## The minimal fix, when the time comes

Horizontal `space10` (20px) on each body, matching `_titleInset` so body and title share one axis —
the same relationship every already-padded caller has. Not a redesign, and it does not conflict
with 154's larger reshaping of rows/pills/sections.

## Related

- The Phase-10 path itself is confirmed INTACT — see 08-VERIFICATION.md item 8: the drawer still
  exists and is still called from `handle_dapp_requests.dart:177` and `:205`. This is a cosmetic
  defect on a working path, not an orphan.
