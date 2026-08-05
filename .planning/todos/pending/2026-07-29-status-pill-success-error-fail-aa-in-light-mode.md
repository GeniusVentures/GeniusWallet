# Status-pill success + error labels fail WCAG AA in light mode

**Found:** 2026-07-29, during the 23-03 follow-up that promoted `statusWarningText`.
**Status:** open. Pre-existing — NOT introduced by Phase 23.
**Severity:** accessibility. AGENTS.md lists accessibility as something this repo is explicitly not lazy about.

## What

The two status-pill palettes paint their label in the same token they use for the
translucent wash behind it:

- `lib/banxa/banxa_components/order_status_style.dart` — `orderStatusPaint()`
- `lib/dashboard/home/widgets/transaction_displays.dart` — `txStatusColors()`

(They are deliberate copies of each other; `order_status_style.dart` says it was
"copied verbatim from the shipped `_statusPill`".)

The **warning** tone was fixed on 2026-07-29 — it now reads `gw.statusWarningText`
and clears AA. **Success and error were not**, and they fail.

## Measured 2026-07-29

Label vs its own wash, `Color.alphaBlend`-composited over each surface. Threshold is
**4.5:1**: the label is `labelMd` (13px) at `w600`, and WCAG large text starts at
18.66px bold, so 13px bold does not qualify for the 3:1 allowance.

| Tone | Mode | surfaceElevated | surfaceMenu | surfaceBase |
|---|---|---|---|---|
| success | light | **3.77** | **3.39** | **2.91** |
| error | light | **3.89** | **3.49** | **2.99** |
| warning | light | 6.56 | 5.93 | 5.15 | ← fixed |
| all three | dark | 8.20 / 8.79 / 5.12 | 7.16 / 7.62 / 4.54 | 8.29 / 8.89 / 5.17 | ← all pass |

All six light-mode figures are below the 4.5:1 body-text floor, and **the two
`surfaceBase` figures are below even the 3:1 non-text floor.**

Dark mode is fine everywhere (minimum 4.54:1, error on `surfaceMenu`).

## Why it is not already fixed

The light-mode `statusSuccess` / `statusError` values are *already* AA-divergent
(they diverge from the legacy palette specifically for light-mode contrast — see
`gw_colors.dart`'s `statusSuccess`/`statusError` field docs). They still miss,
because the wash is a translucent tint **of the same hue**, so darkening the label
and lightening its backdrop move together.

## Upgrade path

Mirror what `statusWarningText` did: add `statusSuccessText` and `statusErrorText`
to `GWColors`, seeded per-mode, and repoint the two `fg:` slots. The wash stays on
`statusSuccess`/`statusError` — those are genuine fills, which is what the tokens
are tuned for.

Then extend `test/theme/theme_contrast_test.dart`'s **Part 8** group to assert all
three tones in **both** modes, and delete the `ponytail:` note that currently
explains why light-mode success/error are excluded.

## Guard in place meanwhile

Part 8 asserts dark mode for all three tones and light mode for warning only. The
exclusion is documented in-test with the measured numbers, so it is visible rather
than silently missing. Neither function had **any** test before 2026-07-29.
