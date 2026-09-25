# The desktop top bar overflows horizontally at large Windows text sizes

**Filed:** 2026-09-25, during the phase 32 walk (Windows debug, Accessibility → Text size 150%+).
**Status:** open.
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
