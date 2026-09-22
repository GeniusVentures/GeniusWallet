---
phase: quick-260922-chs
plan: 01
subsystem: ui
provides:
  - GWAppearancePreference (system/light/dark), split from the resolved GWAppearanceMode
  - Settings Appearance card calling GWAppearance.instance.setPreference
  - Mid-session OS brightness tracking while the preference is system
key-files:
  created: [test/theme/gw_appearance_preference_test.dart]
  modified: [lib/theme/gw_appearance.dart, lib/settings/settings_screen.dart]
tasks: 3
commits: 4
status: complete
---

# Appearance control on Settings

A user on a normal build can now pick Light, Dark or Follow system. Before this the
only toggles were behind the dev-tools define.

## Decisions

- **Preference and resolved mode are different things.** `GWAppearanceMode` stays
  two-valued and keeps meaning what is painted, so `isLight`, `getThemeData()` and the
  ~20 theme readers need no edit. A third case there would ask them an unanswerable
  question.
- **The OS listener is a `WidgetsBindingObserver`.** `onPlatformBrightnessChanged` is a
  single slot the framework owns; taking it breaks `MediaQuery.platformBrightnessOf`.
- **Reuses `GWSelect`**: no sixth segmented control, no new contrast test owed. Legacy
  `'light'`/`'dark'` round-trip unchanged; anything else loads as `system`.

## Verification

`flutter test` 1555 pass / 5 skip / 0 fail (5 new, 1550 baseline) · `flutter analyze`
No issues found! · all six shell gates pass · walked on a Windows debug build.

## Follow-ups

Status pills and disabled controls still fail AA in light mode — separate branch.
