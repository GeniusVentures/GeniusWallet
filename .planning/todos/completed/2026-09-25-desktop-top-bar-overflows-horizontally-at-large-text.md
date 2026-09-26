# The desktop top bar overflows horizontally at large Windows text sizes

**Filed:** 2026-09-25, during the phase 32 walk (Windows debug, Accessibility → Text size 150%+).
**Status:** fixed (the bar); the ~35 unattributed overflows below were not re-attributed.
**Severity:** accessibility.

## What

With the window just wide enough for the desktop layout (the bar got `w=1001`) and text at 150%+,
the outer `Row` of `_DesktopTopBar` (`lib/components/overlay/responsive_overlay.dart:423`)
overflowed by 12px on the right. Roughly 35 more horizontal overflows (0.79 to 106px) fired in the
same session. Flutter prints the source only for the first one, so the rest are unattributed.

The phone bar is fine: it now clamps text scale at 221/180. The desktop bar has no clamp and
no `Expanded`/`Flexible`. Its logo, nav row and actions keep their natural widths.

## Next step

Re-run at 150% with `debugPrintStack` / DevTools to attribute the other overflows. Then decide
per widget: clamp (as AppBar and the phone bar do) or flex/ellipsize. The desktop bar already
hides labels below `GeniusBreakpoints.xxl`, and that threshold may also need to move with the
text scale.

## Resolution

A clamp alone could not fix it: at the narrowest desktop window (1025) the bar already overflowed
by 12px at 1x text once the SDK-account chip showed. So the bar now flexes. The control track is
`Flexible`, and the SDK-account and wallet chips' address labels ellipsize (they already asked
to, but never had a bounded width). Nav labels return at `xxl * textScale`, not `xxl`.
`test/components/desktop_top_bar_text_scale_test.dart` pumps the whole bar in real Inter at 1025
and 1536 wide, at 1x, 1.5x and 2x text, and fails on any overflow. The other overflows from the
walk were never attributed and may lie outside the bar; re-walk at 150% to see whether any remain.
