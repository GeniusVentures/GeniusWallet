# 260728-v6c · Coin page actions, sketch 074-C2

**Date:** 2026-07-28 · **Lane:** execution · **Commits:** none (CLAUDE.md: *"Do not create commits"*)

Jakub, after the component audit: *"ok to compact a potem wdrazamy C2"*. Ran directly rather than
through the full quick workflow - the sketch, the audit and the three resolutions were already on
disk, so a planner would have re-derived a plan that existed.

## What shipped

The four-tile `TokenActionBar` is gone. The wallet actions now ride the **section line above the
chart card**, opposite `GWKicker('Price')`, as `GWButton.icon` at `GWButtonSize.sm` (44px targets,
20px glyphs, `variant: GWButtonVariant.icon`).

| Action | State | Why |
|---|---|---|
| **Receive** | live everywhere | the QR drawer; needs no market price |
| **Swap** | live everywhere | `context.push('/swap')`, **no preselection** - `SwapScreen` takes no params |
| **Bridge** | present only when GNUS + connected; `onPressed: null` at zero balance | replaced the one-row "More Options" drawer |
| **Send** | **absent** | no screen, no route, `GeniusApi.transferTokens` has zero callers |

## Decisions taken, and their cost

**Bridge is ABSENT rather than disabled when the coin is not GNUS.** A permanently-grey button on
Bitcoin says *"unavailable"* when the truth is *"does not apply"* - 072 finding 3 was that one grey
box collapsed three different truths. Zero balance IS a disabled state, because it is a state the
user can change, so that one lands on `onPressed: null`. **Cost:** from Markets the row is two icons,
not three.

**The "More Options" drawer is deleted, and its description line with it** (*"Move your GNUS across
chains with the bridge."*). Flagged in the 074 audit before the decision; a drawer to reach one row
was a click that bought nothing.

**Glyphs are Material icons, not the sketch-152 SVGs the old bar used.** `GWButton` drives icon
colour and size through an `IconTheme`, which `SketchIcon` cannot read - it takes a required
`color` - so an SVG would be the one glyph in the row that does not dim when Bridge is disabled.

**Icons are all equal - no tinted "primary" Receive.** The sketch drew an 18% brand tint and there is
no such variant: `gradient` is a full bright fill. In this app the gradient means commitment, and
this is an action row, not a CTA.

**Icon buttons are circles**, per `gw_button.dart:270`. The sketch drew `radiusMd`; the component
won rather than being changed for one call site.

## Three defects found and fixed on the way

1. **`_pushBridgeScreen` opened with `Navigator.of(context).pop()`** to close the drawer it used to
   live in. With Bridge a direct icon, that pop would have popped **the page** and pushed `/bridge`
   onto whatever was underneath.
2. **The no-data state moved into the chart card's slot.** It used to render above the actions, so a
   covered coin and an uncovered one put the action row at two different heights. Now the section
   line does not move at all - the card beneath it changes. This is the reason C2 beat the other
   three placements.
3. **`_kChromeAboveChart` was 38px stale** - 380 measured a layout with a 74px action bar plus its
   16px gap, replaced by a 44px line. Now 342.

## Deleted

`lib/tokens/widgets/token_action_bar.dart` - `TokenActionBar` plus its private `_ActButton` and
`_ActVariant`. It had exactly one consumer. `SlidingDrawerButton` survives on its other consumers.

## Checks

`test/tokens/coin_page_stat_rail_test.dart` gained one: **Send must not appear at all**, including as
a disabled box, and Bridge must be absent - not greyed - on a coin that cannot bridge. That is the
check that fails if someone "restores" the missing tiles. The no-data test now asks for the Receive
**action** by tooltip rather than the widget, which is also the only assertion that fails if the
tooltip is dropped - on an icon-only button the tooltip is the whole label.

## Gates

- `flutter analyze lib` - **59**, baseline held
- `flutter test` - **371 pass / 1 fail**, up one from 370/1; the failure is the inherited
  fully-commented-out `local_wallet_storage_test.dart`
- Hot reload applied (6 of 3653 libraries), no commits

## Not done

**The human walk.** Nobody has seen this on screen. Specifically: the two-icon row from Markets, the
three-icon row from Assets on GNUS, the disabled Bridge at zero balance, the no-data page with the
line above an empty state, and the row at <768 where 'PRICE' + three 44px circles share one line.

**Still unanswered, and it changes the icon count:** `isGnusWalletConnected` is hardcoded `false` at
`markets_screen.dart:58` and `dashboard_markets.dart:83` and never passed at
`markets_search_bar.dart:93`. If Bridge should be live from Markets, the main route gets three icons
instead of two - and that is a bug in the callers, not in this page.
