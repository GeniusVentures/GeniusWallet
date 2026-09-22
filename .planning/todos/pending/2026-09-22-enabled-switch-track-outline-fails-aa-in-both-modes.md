# Enabled GWSwitch track outline fails WCAG 1.4.11 in both modes

**Filed:** 2026-09-22, while measuring the disabled-checkbox/switch fix (quick 260922-deo).
**Status:** open.
**Severity:** accessibility.

## What

`GWSwitch`'s enabled (on/off) `trackOutlineColor` reads `borderSubtle`, which
measures **1.28–1.43:1** against the track it outlines — and the track itself
is only **1.15–1.33:1** from its surrounding canvas. Nothing identifies the
component as a switch at rest; WCAG 1.4.11 asks for 3:1 from a control
boundary.

This is distinct from the disabled state fixed this session: this session's
fix only added a `WidgetState.disabled` branch to the existing
`trackOutlineColor` resolver (now `borderControl` when disabled). The
enabled/unselected branch is untouched and still reads `borderSubtle`.

## Upgrade path

Likely the same `borderControl` token the disabled branch now uses, but
verify the contrast against both the ON (brand-tinted) and OFF track colours
before committing to one value — the two tracks are visually different fills.
