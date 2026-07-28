---
quick_id: 260728-0vd
status: complete
date: 2026-07-28
commit: none - CLAUDE.md forbids commits
files_created:
  - test/components/responsive_drawer_body_padding_test.dart
files_modified:
  - lib/components/bottom_drawer/responsive_drawer.dart
  - lib/squid_router/swap_settings_drawer.dart
  - lib/squid_router/token_selector_drawer.dart
  - lib/network/network_dropdown_selector.dart
  - lib/dashboard/bridge/bridge_screen.dart
  - lib/account/account_dropdown_selector.dart
  - lib/account/sdk_account_manager.dart
  - lib/reown/approve_transaction_drawer.dart
  - lib/tokens/token_info_screen.dart
  - lib/dashboard/home/widgets/transaction_displays.dart
  - AGENTS.md
  - .planning/codebase/CONVENTIONS.md
gates:
  analyze_lib: 59
  analyze_baseline: 59
  tests_pass: 332
  tests_fail: 1
  tests_baseline: "328 pass / 1 fail (before this task)"
---

# Quick 260728-0vd - SUMMARY

Four changes to one shell, all from the same diagnosis: **the frame supplied nothing, so every one
of the ~19 drawers had to remember for itself - and some forgot.**

## 1. Body inset moved to the shell

`kDrawerBodyPadding` = `fromLTRB(20, 24, 20, 20)`. The value is not new: it is exactly what
`_SlippageForm` carried, the one drawer that got this right. 24 on top because the header hairline
sits directly above and at a flat 20 the first label read as glued to it.

**This reverses 07-06's prohibition, but only half of it - the other half was correct.** A drawer
with a **scrolling list** must keep its inset on the list itself, or the rows stop reaching the
panel edge and the top inset no longer scrolls with the content. Hence `EdgeInsets.zero` as the
opt-out, taken by five drawers: network picker, bridge destination, Your Accounts, SDK Accounts,
token picker.

Three drawers had their own removed so it would not double: Swap Settings (carried the identical
value), reown transaction request (16, would have rendered 36), token-page More Options (24 on the
sides, would have rendered 44).

**The transaction receipt fixed itself without the file being touched** - it added no padding, so
it inherited the shell's. That was the defect the whole change started from.

## 2. Footer inset + top rule moved to the shell

`kDrawerFooterPadding` = `EdgeInsets.all(20)`, plus the `borderSubtle` top rule that 030-B1
specified and that **one** drawer out of nineteen actually drew. No opt-out: a footer holds one or
two actions and is never a scrolling viewport, so the case that forced the body's escape hatch
cannot arise.

Own insets removed: Swap Settings (20 + rule), Your Accounts (16), SDK Accounts (12).

## 3. Close button - reported by Jakub from a live walk

`IconButton` had `padding: EdgeInsets.zero` and 36x36 constraints flush against the panel edge, so
its 36px hover circle bled outside the drawer while the title sat 20 inside.

Rule applied: **glyph to glyph** - title 20 from the left, `✕` 20 from the right.

**The value is measured, not calculated.** Arithmetic said 12 (20 minus the glyph's 8-per-side
inset in a 36 box); the test measured the glyph at 26 instead of 20, because `AppBar` contributes
its **own 6** to the actions slot. Final value `space3` (6). That fact is in the comment, because
the next reader will do the same arithmetic and make the same mistake.

## 4. `View on Explorer` to `gradientOutline`, then the rule deleted

Jakub asked for the gradient on this button. That contradicted the standing CTA-weight rule, which
named `View on Explorer` **explicitly** as the canonical `secondary`. Raised before changing
anything, rather than drifting silently.

`gradientOutline` chosen. The rule was first extended - separating two questions the old
single-axis table had fused (is this the surface's hero, and does it commit) - and then, on an
explicit request, **deleted entirely** from `AGENTS.md` and `CONVENTIONS.md`. `CLAUDE.md` is a
symlink to `AGENTS.md`, so it went in the same move. One line survives in `CONVENTIONS.md`'s footer
recording that the section existed and when it was removed; without it, comments referring to it
would point at nothing.

The code change stays: it is an appearance decision, independent of whether the rule is written
down.

## The check

`test/components/responsive_drawer_body_padding_test.dart`, 4 tests, all green.

The assertions are the **delta** between a padded run and a zero run, not absolute coordinates - so
they survive a change to the toolbar height, the panel radius or the hairline, and fail exactly
when the padding genuinely disappears. A separate test pins the "caller passed nothing" case, which
is the one that failed on the receipt. A fourth pins the `✕` axis and that its box never reaches
the edge.

The test caught **two of my own errors** along the way: measuring against the screen instead of the
panel (the desktop drawer is right-aligned, offset by 380px), and `AppBar`'s undocumented 6px.

## Gates

- `flutter analyze lib` = **59**, baseline 59. Zero new all day.
- `flutter test` = **332 / 1**. 328/1 before this task, so +4 is exactly its own tests. The single
  failure is the inherited `test/local_wallet_storage_test.dart` - a file with no `main()`,
  untouched.

## Deviations from the gsd-quick workflow

- **No commit** - `CLAUDE.md` forbids it, and the tree carries three sources' work.
- **No worktree executor** - a worktree executor commits, which would walk straight into the
  prohibition above. Run inline with the GSD structure preserved.

## What this unblocks, and what stays open

The shell is now ready for the archetypes in **066** and for receipt **154-A** - both assumed
correct padding as their starting point.

Open: **067-A** (section grammar) and **156-A** (drawer canvas colour) are **decided but not
built**. Still unanswered: whether the receipt takes tap-to-copy rows (154-D).
