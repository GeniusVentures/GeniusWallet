---
slug: splash-bottom-safe-area
created: 2026-08-06
type: quick
area: ui
files:
  - lib/screens/splash.dart
---

# Splash: the bottom STATUS bar runs under the home indicator

## The report

Jakub, 2026-08-06, from a screenshot off the iPhone Sidney: on iPhone the status bar is slightly cut
off, so raise it a bit and give it some padding at the bottom.

## Cause

`lib/screens/splash.dart` contains **no** `SafeArea` and never reads `MediaQuery.viewPadding`.
The bottom content is an `Align(alignment: Alignment.bottomCenter)` around a `Column` whose last
child is a 2-pixel progress bar (`SizedBox(height: 2)`, `:249`). `Align` glues it to the physical
edge of the screen.

On an iPhone with a home indicator the bottom ~34 px are taken by the system handle and the corners
are rounded - so the progress bar is partly hidden and clipped, and the `STATUS` row has only
`space6` (12 px) of its own spacing above it.

This is not a cosmetic problem on one screen: it is missing safe-area handling on the screen that is
the first thing a user ever sees.

## Solution

Wrap the bottom `Column` in `SafeArea(top: false)` with a `minimum` floor:

```dart
child: SafeArea(
  top: false,
  minimum: const EdgeInsets.only(bottom: GeniusWalletConsts.space6),
  child: Column(...),
),
```

**Why `SafeArea` rather than adding a number by hand:** it is rung 4 from `AGENTS.md` - a native
platform feature covers the problem. A hand-written `EdgeInsets.only(bottom: 34)` would be a literal
guessed for one phone model and would break on every other one.

**Why `minimum` on top of that, rather than `SafeArea` alone:** on devices without a gesture handle
(older iPhones, some Androids) `viewPadding.bottom` is 0 and `SafeArea` on its own would leave the
bar glued to the edge again. `minimum` acts as a floor - the resulting inset is the larger of the two
values, so the iPhone gets its ~34 px and a device without a handle gets 12 px off the 4-pt grid.

`top: false`, because the top edge stays as it is - the logo is centred in a `Stack` and nothing clips it.

## Verification

1. `dart format` + `flutter analyze` - baseline from project memory: 409 issues, 0 errors.
2. Hot reload on Sidney and a screenshot of the splash - the progress bar and the STATUS row must
   stand off the bottom edge and must not be covered by the home indicator.

## Out of scope

- The look of the progress bar itself and the status copy (walk 13-03 already settled that).
- The safe area on the remaining screens - if the problem is wider, that is a separate task.
