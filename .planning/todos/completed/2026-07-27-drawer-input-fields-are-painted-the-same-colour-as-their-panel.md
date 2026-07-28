# Drawer input fields are painted the same colour as the panel they sit on

**Found:** 2026-07-27, while measuring drawer surfaces for sketch 156.
**Type:** contrast defect. WCAG 1.4.11 (non-text contrast) at the field boundary.
**Independent of:** the sketch 156 canvas pick - this stands whichever panel colour wins.

## What is wrong

`lib/components/bottom_drawer/responsive_drawer.dart:139` paints the whole panel:

```dart
backgroundColor: gw.surfaceMenu,   // #171A21 in dark
```

`lib/squid_router/swap_settings_drawer.dart:191-193` paints the field on it:

```dart
GWFocusRing(
  radius: GeniusWalletConsts.radiusSm,
  background: gw.surfaceMenu,       // the SAME token
```

**Fill contrast between the field and its own canvas: 1.00:1.** The input is not a box, it is a hairline -
which is exactly how it reads on screen.

## The measured numbers

Computed on the WCAG relative-luminance formula, against the composited value of each translucent overlay:

| Pairing | Ratio | Needs |
|---|---|---|
| field fill vs panel fill | **1.00:1** | - |
| field edge (`borderSubtle`, white 12%) vs panel | **1.43:1** | 3:1 |
| field edge at white **30%** vs `surfaceElevated` panel | **3.0:1** | 3:1 |
| field edge at white 30% vs `surfaceMenu` panel | 2.8:1 | 3:1 |

When a hairline is the **only** thing identifying an input, WCAG 1.4.11 asks for 3:1. Today's is 1.43:1.

**Two dark fills can never carry this on their own** - `#171A21` on `#0C0E14` is 1.11:1 and `#06080C` on
`#0C0E14` is 1.04:1. On a dark canvas the border does the identifying and the fill only sets the mood, so the
fix has to be a pair: a field fill that differs from the panel **and** a stronger edge.

## Scope - read before fixing

`GWFocusRing`'s `background:` is passed `gw.surfaceMenu` at **four** call sites (the swap amount card, this
slippage field, the token search, the feedback message). Only the two inside drawers have this problem; the
other two sit on page canvases where `surfaceMenu` is genuinely a step up from the surface behind them.
**Do not change all four together.**

The edge colour is a separate axis: `borderSubtle` at 12% is correct for **decorative** card hairlines and
should stay. What needs raising is the edge of an **input**, which carries information.

## Related

- `.planning/sketches/156-drawer-canvas-colour/README.md` - six schemes, the measured table, and the
  recommendation (panel to `surfaceElevated`, field up to `surfaceMenu`, field edge to white 30%) plus why it
  should ride the ~19-drawer walk rather than precede it
- The drawer walk queued in `.planning/HANDOFF.json` under `human_actions_pending` - same nineteen panels

---

## RESOLVED 2026-07-28 - quick 260728-q7c (sketch 156-A)

Fixed as the pair this note demanded: the panel dropped to `surfaceElevated`, so `gw.surfaceMenu` on
the field stopped being the panel's own colour and became the lighter object on a darker canvas;
and the edge went to a new `GeniusWalletColors.borderControl`.

**One number in the table above is wrong.** The row *"field edge at white 30% vs `surfaceElevated`
panel - 3.0:1"* measures **2.63:1**. 30% clears 3:1 when composited against the *field*, but
`GWFocusRing` does not use a `Border`: it paints an outer `DecoratedBox` in the edge colour and
covers all but 1.5px of it with the field, so the visible ring composites over the **panel**. The
value that clears it is white **36% = 3.30:1**, which is what sketch 067's own table had said
independently and what shipped.

The scope warning was followed: only the two drawer call sites changed. `swap_field.dart` passes
`Colors.transparent` (its card carries its own hairline) and `submit_logs_screen.dart` sits on a
page canvas - both untouched, and whether every input in the app deserves a 3:1 edge is left as a
separate question in the quick task's SUMMARY.
