# The swap FAB clears a bottom nav that the desktop shell never mounts

**Found:** 2026-07-27, while measuring the FAB gaps for sketch 158.
**Type:** a mobile constant leaking onto desktop. Visible as an uneven gap.
**Size:** one expression.

## What is wrong

`lib/components/overlay/global_swap_fab_host.dart:124-128`:

```dart
Positioned(
  right: GeniusWalletConsts.space10,   // = 20
  // Clears the 60px bottom nav (+ safe-area) on the main shell;
  // floats thumb-reachable above the edge on pushed screens.
  bottom: 80 + bottomInset,
  child: GWSwapFab(onPressed: () => widget.router.push('/swap')),
)
```

20px on the right, 80px at the bottom - a 4:1 asymmetry, which is what it looks like on screen.

The comment is accurate about *why* the 80 exists, and that reason does not hold on desktop:
`_MobileTabBar` is mounted **only** by `MobileOverlay` (`responsive_overlay.dart:486`). `DesktopOverlay` has
no bottom bar at all - navigation is the top navbar. **On the desktop app 60 of those 80 pixels are avoiding
something that is not there**, and `viewPadding.bottom` is 0 there, so nothing absorbs the difference.

## The fix

Derive the number rather than hardcoding it, using the same breakpoint `ResponsiveDrawer.show()` already
uses (`responsive_drawer.dart:20-21`):

```dart
final isDesktop = MediaQuery.sizeOf(context).width >= GeniusBreakpoints.medium;
// ...
bottom: GeniusWalletConsts.space10 + (isDesktop ? 0 : 60) + bottomInset,
```

Mobile keeps exactly the 80 it has today; desktop gets an equal 20/20 gutter. No new concept is introduced.

## Watch when fixing

- `GWSwapFab` carries two glows offset `(-2, 6)` and `(2, 6)` with a 24px blur
  (`gw_swap_fab.dart:56-69`), so the visible mass hangs ~30px below the box. At a 20px bottom gap the glow
  will be clipped by the window edge on **both** axes rather than just the right one. If that reads badly on
  the real screen, `space12` (24) on both axes is the fallback - decided by looking, not by arithmetic.
- Do **not** compensate for the shadow offset by making the two gaps deliberately unequal (e.g. 20/26). It
  looks right and silently un-centres the button the moment the glow is retuned.

## Separate, found alongside

`_hiddenPaths` (`:36-54`) hides the FAB on `/checkout`, `/checkoutQR`, `/kyc` and `/banxa/callback`, but
**not** on `/buy`, `/createOrder` or `/orderDetails` - so the swap button floats over the fiat purchase flow
and its order list. That is a product question (should a swap action sit over a purchase?), not a bug, and it
is raised in sketch 157.

## Related

- `.planning/sketches/158-global-fab-placement/README.md` - six placement options, four skins, and the
  gradient-outline technique (a `BorderSide` takes one `Color`, so the outline has to be a gradient circle
  with an inset surface circle)
