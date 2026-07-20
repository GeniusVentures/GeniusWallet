---
created: 2026-07-20T10:15:42.522Z
title: CTA hover state is over-rounded
area: ui
files:
  - lib/theme/theme.dart:197-204
  - lib/theme/theme.dart:250-253
  - lib/theme/genius_wallet_consts.dart:34-42
---

## Problem

Surfaced during the 05-01 human walk on macOS (2026-07-20). Hovering a dashboard CTA
produces a highlight whose corner radius reads as too round for the intended shape.

This is a **wrong-token-applied** question, not a wrong-token-value question. The radius
scale in `genius_wallet_consts.dart:34-42` matches the Figma export
(`.planning/design/gnus-tokens.json` on branch `ui-redesign-3.514`) exactly:

| token | app | Figma |
|-------|-----|-------|
| radiusXs / radiusSm / radiusBase | 4 / 8 / 10 | 4 / 8 / 10 |
| radiusMd / radiusLg / radius2xl | 12 / 15 / 16 | 12 / 15 / 16 |
| radiusXl / radiusPill | 24 / 48 | 24 / 48 |

So the values are right; the open question is which token each control should use.
Buttons currently resolve to `radiusLg` (15) via `elevatedButtonTheme` (:197-204) and
`textButtonTheme` (:250-253). For contrast, `dropdownMenuTheme` uses `radiusPill` (48)
and `searchBarTheme` uses `radiusXs` (4).

**The design reference does not settle this.** `gnus-mockups.html` defines **zero**
`:hover` rules — it is a static mockup built for mobile screens, and hover is a
desktop-only state. Its radius distribution leans heavily on full-pill (`999px` × 17
occurrences, vs 16px × 4, 15px × 3, 12px × 3), which is evidence that heavy rounding is
intentional somewhere in the system, but not evidence about *this* control's hover.

Out of scope for 05-01, which touched only `DashboardScrollContainer`, `loading.dart`
and `custom_future_builder.dart` — no button or hover code.

## Solution

TBD — needs a design answer before a code change.

1. Identify exactly which control the reporter hovered. The header row (Tokens / Gallery /
   Connect / Buy GNUS / wallet address) is Phase 4 nav chrome, already walked; the
   dashboard-content cards are Phase 5 (05-04 markets, 05-06 transactions). Owner differs
   by answer.
2. Ask Alex whether the design system specifies hover states at all, and what radius the
   hover surface should take. Without that, any change here is a guess.
3. Only then adjust the token at the theme level — not per call site.
