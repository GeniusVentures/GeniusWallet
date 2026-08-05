---
created: 2026-07-18T12:35:27.843Z
title: AppScreenView ("Screen wrappers") renders blank in dark mode
area: ui
files:
  - lib/components/app_screen_view.dart
  - lib/dev/design_gallery_screen.dart
---

## Problem

Confirmed live in the 04-02 D-02 gallery re-walk (2026-07-18): the gallery's
"Screen wrappers" section — which demos `AppScreenView` (SafeArea +
CustomScrollView body/footer wrapper) inside a constrained box — renders
**blank/empty in dark mode**. It should show the demo body ("AppScreenView —
SafeArea + CustomScrollView body/footer wrapper…") and the "Footer slot".

One of the two long-unexplained Phase-3 findings (the other, disabled-control
visibility, is [[dark-mode-disabled-state-visibility-checkbox-switch]]). Third of
the 3 dark-only findings from the re-walk. Not addressed by the 04-02 migration
(that plan was scoped to the const-rebuild + Inter fixes).

## Solution

TBD — gap closure. Investigate why `AppScreenView`'s body/footer render blank in
dark specifically (likely a color/background resolving to the dark surface color
so content is invisible, or a layout collapse only triggered in the dark branch).
Reproduce in the gallery "Screen wrappers" section by toggling to dark. Fix so the
wrapper renders its content in both modes; verify against the WCAG contrast rule
([[wcag-contrast-rule]]).
