---
date: 2026-08-07
branch: redesign/navigation-260806
base: develop
committed: NOTHING - everything below is working tree only, HEAD is 47e0565c
---

# Handoff: mobile redesign, 2026-08-07

**Read `.planning/WALK-260807-mobile.md` first** - it holds every verdict Jakub gave on device today,
what is closed, what is accepted-by-omission, and what is still open. This file is the working
context around it.

## Hard rules in force

- **Route ALL work through GSD.** The MODE is mine to pick and he does not want to be asked which.
- **No commits, no PRs** without explicit authorisation. Base branch is `develop`.
- **Mobile only, iOS.** Dark mode first.
- **Use existing `GW*` components**; extend additively, never hand-roll. A hand-rolled `WalletPill`
  cost us a whole review round.
- **Design only what the code already supports.** Jakub, 2026-08-07: the menu is to hold only what we
  have today (...) and everything is to be built on the basis of the code. Every proposed row needs a
  file and line proving it exists.
- **Open every sketch in the browser the moment it is built.** A URL in a terminal is not a delivered
  design.
- No em dashes. 4-pt grid, `space3` = 6 the one documented exception.

## Tooling that cost time today - do not relearn

- **`pkill -f "flutter run"` matches nothing.** The real line is `flutter_tools.snapshot run -d <udid>`.
  **And `grep -c` with the `[f]` trick is unreliable here** - `grep` is ugrep on this machine and gave
  a false count of 2 when nothing was running. Use `pgrep -f 'flutter_tools.snapshot run' | wc -l`.
- **Kill the FIFO reader too.** The `while :; do cat fifo; done` wrapper survives a flutter kill and a
  stale one contributed to two sessions fighting over the device. `pgrep -f 'gw.fifo'`.
- **Hot reload is rejected when a `const` class loses or gains a field.** It happened twice today with
  `GWSectionTitle`, and the rejection is ATOMIC - the whole batch fails, including unrelated changes,
  so "I reloaded it" can silently mean "nothing arrived". Always check the log for `Reloaded N` versus
  `Hot reload was rejected`.
- **A file written after the build started is not in the build.** Two rounds of "it is not there" were
  exactly this. Compare `stat` mtimes against the log's start.
- iPhone Mirroring is blocked in the EU. Screen capture is QuickTime Movie Recording.

## What landed today, all uncommitted

Phase 25 (one page scroll, top-5 caps, the `/assets` page) plus nine quick tasks. Every one has a row
in `STATE.md` with its findings. The ones whose findings outlive the task:

- **`CoinsScreen` has no `isDashboard` parameter** - it is a local bool derived at line 247. Two
  planning documents claimed otherwise.
- **`GWColors.light()` does not return light values under a dark global** - its surface fields read an
  appearance-aware getter, so a naive light-mode test silently asserts the dark branch.
- **`AppBar` charges `titleSpacing` on BOTH sides** - the title Row gets 342 of 390 at 390pt, not 358.
  This invalidated a whole budget table and is the reason no brand size keeps the wallet pill at its
  full 236 cap.
- **`AccountAvatar` paints a currency icon, not a wallet identity** - two ETH wallets are pixel
  identical. Hence the monogram in sketch 181.
- **The More sheet is DERIVED** - `_allDestinations` minus Swap minus what the bar shows. Removing a
  tab files it in the sheet automatically. But `/assets` was never added to `_allDestinations`, so it
  can only ever be reached from a tab or a link.
- **`walletCubit.selectNetwork()` has exactly one call site.** Unmounting that widget without a
  replacement removes mobile's only way to change network.
- **The amount column already clips ordinary amounts** on a phone. Todo filed; do not take width from
  it, that was measured as strictly worse.

## In flight right now

| | State |
| --- | --- |
| S7 bottom bar - Home, Assets, Swap, Activity, News | planning |
| Sketch 183 - how the F control is drawn (border, none, gradient) | building |
| Sketch 184 - the Menu page | building |

**S7 has a trap the plan is built around:** removing `More` before an alternative entrance exists
strands Markets, Web, Feedback and **Settings**. So the hamburger ships in the same task, wired to
today's existing sheet. The redesigned menu is separate.

## Decided, not yet built

- **Sketch 181 scheme F** - wallet icon plus hamburger, top right, 224px to 100px. Awaiting 183 for
  its visual treatment.
- **Sketch 182 S7** - the tab set above. Planning.
- **The Menu is a full page**, not a sheet: it has children (`Settings` is already a screen), a sheet
  has a height ceiling, and a menu is a place you look around in rather than a pick-one-and-return.
- **No wallet section in the Menu** - scheme F's wallet icon already owns accounts and networks.
- **News is not in the Menu** - S7 gives it a tab, and a tab plus a menu row is two sources of truth.

## Baselines at handoff

`flutter analyze` 0 issues repo-wide. `flutter test` 1158 passing, 3 skipped (dev-gated, by
convention), 0 failing. One clean flutter session on the phone with `GW_DEV_TOOLS=true`.
