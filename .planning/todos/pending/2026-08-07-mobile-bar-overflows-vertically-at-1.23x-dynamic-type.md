---
created: 2026-08-07T13:55:00.000Z
title: The phone bottom bar overflows VERTICALLY at about 1.23x Dynamic Type
area: ui
files:
  - lib/components/overlay/responsive_overlay.dart
  - test/components/mobile_nav_destinations_test.dart
---

## Problem

The phone bottom bar's slot has **3.15px of vertical slack**, and the only term in it that
scales is the label line. So the bar overflows vertically long before any label truncates
horizontally, and nothing had recorded this.

Measured from the real constants on 2026-08-07 (printed by
`mobile_nav_destinations_test.dart`, group "the bar fits, measured at real Inter"):

```
2 x space4 padding      16.00
kMobileNavIconSize      23.00
space2                   4.00
labelMd line box        13.85   (fontSize 10 x height 18/13)
-----------------------------
total                   56.85   against kMobileBarHeight = 60.00
slack                    3.15
```

The column overflows once `13.846 * s > 17.00`, which is **textScaler above roughly 1.23x**.

Every label's HORIZONTAL ceiling is far above that, measured at real Inter SemiBold 10 against
the `(390 - kMobileDockSlotWidth) / 4 = 76.50px` slot:

| Label | w600 width | Horizontal ceiling |
| --- | ---: | ---: |
| Home | 28.46 | 2.69x |
| Assets | 33.04 | 2.32x |
| Activity | 37.21 | **2.06x** (binding) |
| News | 27.24 | 2.81x |

So the honest answer to "what is the Dynamic Type ceiling per label" is: **no label ever
truncates, because the bar runs out of height first, at about half the scale.**

**This is PRE-EXISTING.** The bar had identical geometry before sketch 182 scheme S7, and S7
neither causes it nor worsens it - S7 actually RAISED the horizontal ceiling from 1.93x
(Markets, the binding label before) to 2.06x (Activity). It was left alone deliberately: fixing
it is a design decision, not a navigation change, and it was found during one.

`mobile_nav_destinations_test.dart` now asserts the 56.85 against the 60.00 with the slack
printed, so this cannot quietly get worse while nobody is looking.

## Solution

TBD - two candidate remedies, neither chosen, because both are design calls:

1. **Clamp `textScaler` on the bar.** There is precedent one widget away: `AppBar` clamps its
   own title at 1.34x (`app_bar.dart:44`, `_kMaxTitleTextScaleFactor`) for exactly this reason -
   to keep a toolbar's visual hierarchy under large type. Cheap, one `MediaQuery` wrapper, and
   it caps the accessibility benefit rather than delivering it.
2. **Drop the label above a threshold**, leaving icon-only tabs at large scales. The desktop bar
   already does something adjacent (`hideLabels` below `GeniusBreakpoints.xxl`, with a `Tooltip`
   carrying the label), so the pattern exists in this file. Costs the label at the scales where
   a user most needs it.

A third option - growing `kMobileBarHeight` - is not free: the bar's height feeds the dock
overhang and the safe-area cap, and 24-07 was caused by exactly one box in this area leaving an
axis unstated.
