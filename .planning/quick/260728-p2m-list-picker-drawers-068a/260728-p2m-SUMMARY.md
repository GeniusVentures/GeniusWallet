---
quick_id: 260728-p2m
status: complete
date: 2026-07-28
commit: none - CLAUDE.md forbids commits
sketches: [068-A]
files_modified:
  - lib/components/cards/gw_select_row.dart
  - lib/squid_router/token_selector_drawer.dart
  - lib/network/network_dropdown_selector.dart
  - lib/account/account_dropdown_selector.dart
  - lib/account/sdk_account_manager.dart
  - test/components/gw_select_row_test.dart
gates:
  analyze_lib: 59
  analyze_baseline: 59
  flutter_test: 342 pass / 1 fail
  flutter_test_baseline: 339 pass / 1 fail
verification: hot-reloaded live (12 libraries); HUMAN WALK PENDING
---

# Quick 260728-p2m - SUMMARY

Sketch **068-A**, taken the same session it was drawn. Three list-picker drawers, three hand-rolled
rows, one component.

## The new component, and the promotion test it passes

`GWSelectRow` (`lib/components/cards/gw_select_row.dart`) is `_TokenRow` promoted out of
`token_selector_drawer.dart`. **Token Selector authored the row and was its only consumer; it is now
one of four.** That is the same test sketch 065 used to promote `GWKicker` (five hand-written copies)
and the same test sketch 154 REFUSED for `_CopyRow` (one consumer, left private).

Two escape hatches, both earned by a real call site rather than anticipated: `titleStyle` (SDK
Accounts, whose title IS an address and wants JetBrainsMono) and `subtitleStyle` (Your Accounts,
whose subtitle is the address). Two trailing slots, `trailing` and `action`, because a balance and an
overflow menu belong on opposite sides of the state glyph - reading a row goes context, then state,
then what you can do about it.

## What each drawer was doing, and what it does now

**Select Network** shipped a bare `ListTile(selected: isSelected)` with nothing else - no
`selectedTileColor`, no check, and the title's colour **literally commented out** (`// color:
color`). With no `ListTileTheme` behind it, `selected: true` paints nothing. **The drawer whose only
job is to show which network you are on did not show which network you are on.** It now has the
tint, the edge and the check.

**Your Accounts** painted selection as `selectedTileColor: brandPrimaryStrong` - a flat brand fill,
the one thing `drawers-final`'s global accent rule forbids and which quick 260721-0ze swept out of
the rest of the app. This row was missed. It also carried two `textOnBrand` overrides that existed
only to stay legible on that fill; both are gone, because ordinary text tokens read fine on the
gradient tint. Its footer was a raw `FilledButton.icon` with an inline `fontSize: 18` and
`iconSize: 28` - now `GWButton(gradient, lg, expand)`.

The address moved from a `SelectableText` in the subtitle to plain text: select-to-copy inside a
tappable row fights the tap, and the overflow menu's "Copy address" is the real path. The row now
follows the token row's shape - identity on the left, value on the right.

**SDK Accounts was not in the shell at all.** It passed no `title` to `ResponsiveDrawer.show` -
deliberately, with a comment - and rendered `BottomDrawer` inside instead: a second header, centred
title, ✕ on the **left**. A stand-off until 156-A, which turned it into a visible defect - the panel
is `surfaceElevated` #0C0E14 and `BottomDrawer` paints itself `surfaceMenu` #171A21, so the header
was a lighter block sitting inside its own drawer. It now uses the shell header like the other
eighteen. Its row was a `GWCard` whose selected state was a **2px** border, so the row's geometry
moved by a pixel each way on selection; `GWSelectRow` keeps the width constant.

## Why selection is drawn three ways

Selection is a STATE, and WCAG 1.4.11 covers states. Measured on the 156-A panel:

| | ratio | carries it? |
|---|---|---|
| gradient tint `0x2E` | 1.39:1 | no |
| brand edge `hoverEdge` 24% | 1.60:1 | no |
| **check glyph `brandPrimaryStrong`** | **6.81:1** | **yes** |

The same finding sketch 156 made about a field's fill, pointed at a row. Tint and edge for the eye,
glyph for the requirement - which is why the check is not optional and why a "cleaner" row that drops
it would fail silently.

## The check

Three tests on the component. The load-bearing one asserts the **check glyph** appears with
selection and not without - the part that carries 1.4.11, and the part a screenshot would not catch
if it went missing while the tint stayed. The third asserts the border width is **identical**
selected and unselected: the always-present transparent border is geometry, not styling, and a row
that gains a border on selection shifts its own contents by a pixel every state change.

## Gates

- `flutter analyze lib` = **59**, baseline 59.
- `flutter test` = **342 / 1**, baseline 339/1. The failure is the inherited
  `local_wallet_storage_test.dart` (no `main()`).
- Hot-reloaded live, 12 libraries.
- **No commit** - `CLAUDE.md`.

## Follow-up

- **Walk all four pickers.** Especially Select Network, which has never shown a selected state at
  all, so this is the first time anyone sees one.
- **`BottomDrawer` now has exactly one consumer left**, and it is `design_gallery_screen.dart` - a
  dev screen that displays it as a component. It is effectively dead code in the app. Not deleted
  here: that is a separate decision and this task had no mandate for it.
- 068's **C · Grouped** stays available if a list ever grows long enough to want an Active / All
  split. 068's **B · Ruled well** is rejected on a mechanic worth not re-deriving: a scrolling list
  inside a bordered box either scrolls its frame away or scrolls under its own bottom edge.
