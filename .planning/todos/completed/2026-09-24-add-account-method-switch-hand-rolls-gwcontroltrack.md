---
created: 2026-09-24T15:00:00.000Z
title: The add-account method switch hand-rolls GWControlTrack
area: components
severity: cosmetic
---

## Problem

`sdk_account_manager.dart` (the add-account dialog's phrase/key switch) hand-builds the control-track recipe (sunken fill, subtle border, pill radius, 3px padding, 2px gap) that already exists as `lib/components/gw_control_track.dart`.

## Fix direction

Replace the Container with `GWControlTrack`. Turning `_modeChip` from a method into a widget is what AGENTS.md's widgets-not-helper-methods rule asks for. `_PresetChip` (chips with no track) is its own control and stays out.

## Closed 2026-09-26

The method switch is a `GWControlTrack` holding two `_MethodChip` widgets; `_modeChip` and the hand-built Container are gone. Side effects: the well is now `surfaceWell` (was `surfaceSunken`) like every other track, the unselected label uses `textMutedOnSunken` (light `textSecondary` on the old sunken fill measured 4.23:1), and the selected chip stays enabled (focusable, announced "selected") with the no-op guard moved into state. Covered by a new test in `test/account/sdk_add_account_test.dart`.
