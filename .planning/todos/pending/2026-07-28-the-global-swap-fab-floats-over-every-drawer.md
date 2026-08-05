# The global Swap FAB floats OVER every drawer, including its scrim

**Found:** 2026-07-28, in Jakub's screenshot of the Receive drawer opened from the coin page - the
teal swap FAB sits on top of the drawer panel, bottom-right, fully lit.
**Type:** z-order. App-wide, not specific to this drawer.

## Why

`GlobalSwapFabHost` mounts inside the `MaterialApp.router` **builder**
(`lib/components/overlay/global_swap_fab_host.dart`), which puts it ABOVE the Navigator in the widget
tree. Anything the Navigator shows - a route, a dialog, a `ResponsiveDrawer` and its scrim - is
therefore painted underneath it. The scrim dims the page and does not dim the FAB, which is what
makes it read as pinned to the glass.

That placement is deliberate and correct for what it was solving: the FAB has to survive tab changes
without being re-mounted per screen. The bug is that "survives navigation" was taken to mean
"survives modals".

## What it costs

- A live, tappable control over a modal surface. Tapping it from inside the Receive drawer would push
  `/swap` with a drawer still open behind it.
- On the mobile bottom-sheet variant it lands near where a footer CTA would be.

## The fix, most likely

`_hiddenPaths` is an exact-path set, so it cannot see modals - a drawer does not change the route.
The host needs a second condition: hide while a modal route is on top. `ModalRoute.of(context)?.isCurrent`
read at the host is not enough for the same reason (the host is above the Navigator). Candidates, in
increasing cost:

1. A `RouteObserver`/`NavigatorObserver` on the router that flips a `ValueNotifier<bool>` the host
   listens to - the FAB hides while any modal route is pushed.
2. Move the host INSIDE the shell's body so the Navigator paints over it naturally - cheaper to
   reason about, but it re-mounts per shell rebuild and would need checking against whatever the
   builder placement was originally fixing.

Option 1 is the smaller change and does not disturb the placement's original reason.

## Related

- `lib/components/overlay/global_swap_fab_host.dart` - `_hiddenPaths`, and the `_ready` first-frame
  guard that explains why the host is where it is
- `lib/components/bottom_drawer/responsive_drawer.dart`
- Affects **every** drawer in the app (~19 call sites), so it is worth one fix rather than per-caller
