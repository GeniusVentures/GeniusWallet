---
created: 2026-09-24T15:00:00.000Z
title: The disabled-state 3:1 floor is enforced by one test and written down nowhere
area: accessibility
severity: minor
---

## Problem

WCAG 1.4.11 exempts disabled controls, so AGENTS.md's "AA in both modes" line does not cover them. This project holds them to 3:1 anyway, but the only guard is `test/theme/disabled_control_contrast_test.dart`, which covers GWCheckbox and GWSwitch alone.

## Fix direction

State in the UI-SPEC template and `.planning/codebase/CONVENTIONS.md` that two pairings must clear 3:1 in both appearances before a component ships: disabled vs its surface, and disabled vs the enabled-off state. Optional in the same pass: GWSwitch paints disabled-on and disabled-off identically except for thumb position (`gw_switch.dart:42-53`).
