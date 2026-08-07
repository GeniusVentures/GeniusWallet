---
sketch: 172
name: dock-icon-and-top-bar
question: "Which concrete icon should stand in the centre dock instead of the plus - and what is that dock actually for?"
winner: null
tags: [mobile, ios, bottom-nav, dock, icon, top-bar, total-balance, follows-171]
---

# Sketch 172: Dock icon + top bar

## Design Question

Jakub asked, 2026-08-06: show what the bottom navigation looks like with a specific icon instead of the plus.
The top bar is taken from variant **D** of sketch 171, Total Balance is included, Assets unchanged.

The key reframing: the four variants do not differ in the **drawing**, but in **what the dock is**.
The icon is a consequence of that decision, not its subject.

## How to View

```
open http://localhost:8899/172-dock-icon-and-top-bar/
```

## Variants

- **A: Swap ★** - the dock = one tap into `/swap`. Icon `Icons.swap_vert_rounded`, the same one as today's FAB.
- **B: Move** - the dock opens a Send / Receive / Buy / Swap sheet. Gives Send and Receive their first place in navigation.
- **C: Scan** - the dock opens the QR scanner. The clearest icon, but there is no scanner.
- **D: GNUS** - the dock carries the brand mark and opens Compute. The only one where the dock is a brand, not an action.
- **Side by side** - four docks in one row, a legibility test with no label.
- **Total Balance + inventory** - three cosmetic versions of the balance block, a cost table, a recommendation.

## What to Look For

1. **Whether the icon reads without a caption.** The dock is the only element on the bar with no label.
   Prediction to check: C immediately, A because it is familiar from the FAB, B confused with A, D has to be learned.
2. **The TB-3 to dock-B dependency.** If the dock is "Move", then the Receive/Send CTA pair under the balance duplicates it
   on the same screen. TB-3 only makes sense with dock A, C or D.
3. **Cost.** `New` items beyond the shared dock and bar: A = 0, B = 1, C = 2, D = 1.

## Findings grounded in code

| Fact | Place |
|---|---|
| The existing FAB uses `Icons.swap_vert_rounded` | `gw_swap_fab.dart:73` |
| Send and Receive have no home in navigation - they are buttons inside screens | `wallet_information.dart:176-185`, `coins_screen.dart:179,345` |
| `mobile_scanner: ^5.2.3` in the dependencies, zero uses in `lib/` | `pubspec.yaml:35` |
| The repo only displays QR codes, it never reads them | `components/qr/crypto_address_qr.dart` |
| Zero balance on `textPrimary38` = 3.54:1, below AA | `coin_card_row.dart:126,134` |

## Recommendation

**A · Swap**, but conditionally. A introduces no new concept at all - the same icon, the same route,
the same contract as the FAB, so the risk of misreading it is zero. **If, however, there is a hunch that
users send more often than they swap, B is the better investment** - it closes a documented gap
instead of relocating an existing button. Rejected: C (there is no scanner, and `mobile_scanner` is one of
the two reasons the iOS simulator does not work here) and D (a brand instead of an action in an element with no label).

## Open

- The composition of the four remaining items was carried over from 171-B unchanged; it depends on how 171 is settled.
- The dock breaks the "one filled gradient per surface" rule in every variant - decide that once, not per icon.
- Whether the dock is constant across the whole shell, or only on Home.
