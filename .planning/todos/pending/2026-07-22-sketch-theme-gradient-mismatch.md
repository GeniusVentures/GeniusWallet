---
created: 2026-07-22T11:20:00.000Z
title: Every sketch draws the WRONG brand gradient — the theme tokens do not match brandCta
area: design-system
severity: affects every approved sketch since 001
files:
  - .planning/sketches/themes/default.css
  - lib/theme/genius_wallet_gradient.dart
  - lib/theme/genius_wallet_colors.dart
---

> RESOLVED 2026-07-22: brandCta is canonical; theme css updated (`--brand-cta-a:#0AD89C` / `--brand-cta-b:#0AAEE6` added to `.planning/sketches/themes/default.css`). Remaining scope (re-checking old sketches) is intentionally deferred.

## The mismatch

`.planning/sketches/themes/default.css` defines:

```css
--brand-primary:   #14C8FF;
--brand-secondary: #2BF5B4;
```

Both are real tokens — `GeniusWalletColors.brandPrimary` and `brandSecondary`
(`genius_wallet_colors.dart:48,73`). **But they are not the stops the CTA gradient uses.** Every
sketch draws "the brandCta gradient" as `linear-gradient(..., var(--brand-primary),
var(--brand-secondary))`, and the shipped gradient is:

```dart
// genius_wallet_gradient.dart:16-23
static const LinearGradient brandCta = LinearGradient(
  colors: [GeniusWalletColors.gradientGreen /* #0AD89C */,
           GeniusWalletColors.gradientBlue  /* #0AAEE6 */],
);
```

| | Sketch mockups paint | The app paints |
|---|---|---|
| stop 1 | `#14C8FF` bright cyan | `#0AD89C` green |
| stop 2 | `#2BF5B4` mint | `#0AAEE6` blue |

The direction is even reversed in feel: the mockups run cyan→mint, the app runs green→blue. There
**is** a `#14C8FF`-based gradient in the code — `brandBorder` (`:27-34`) — but its second stop is
`brandSecondaryBright #5BFFD0`, so the CSS pair matches neither gradient exactly.

## Why it matters

Every gradient decision approved off a sketch — the active nav tab, the active filter chip, the
`brandCta` buttons, sketch 022's underline — was approved **against colours the app does not
paint.** The mockups are brighter and cooler than the product.

Found on 2026-07-22 when the Phase 15 plan-checker measured contrast against the real code and the
numbers did not match sketch 022's table. The *conclusions* survived in that case (the underline
still fails WCAG 1.4.11 on white either way, and still needs the `_activeLabelShader` degradation),
but that was luck, not method: the two pairs differ by up to 3 contrast points.

## Fix

Two changes, one decision.

1. **Decide which is right.** Either the app's `brandCta` is correct and the sketch theme is stale,
   or the design intent really is the brighter cyan→mint pair and the *app* is the thing that
   drifted. Check against the website reference — `genius_wallet_gradient.dart:15` claims brandCta
   "mirrors the website's `linear-gradient(270deg, #0c91cc, #06aa78)`", which is neither of the two
   pairs above either, so all three may disagree.
2. **Then make `default.css` derive from whatever wins**, and add a comment naming the Dart constant
   each token mirrors, so the next drift is visible.

Until then: **do not copy hexes out of a mockup into source.** Read them from
`genius_wallet_colors.dart`.

## Scope of the re-check

Sketches carrying an approved gradient decision, worth re-measuring once the source of truth is
settled: 002 (navbar), 005 (right cluster), 006/008 (timeframe + hover), 011-014 (filters, badges),
020-022 (rail). Phase 12's shipped filter chip and the navbar's active tab are the two places the
gradient is already on screen.
