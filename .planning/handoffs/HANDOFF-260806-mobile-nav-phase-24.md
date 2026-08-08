# HANDOFF 2026-08-06 — Mobile nav shell (phase 24)

## Branch

`redesign/navigation-260806`, cut from an up-to-date local `develop`.
**Base branch is now `develop`** (Jakub, 2026-08-06). `origin/ui-redesign-port` was deleted upstream
during this session's first fetch, so the old base no longer exists. Nothing committed - the whole
phase sits in the working tree.

## Decisions locked by Jakub today

- **Mobile only.** iOS is Jakub's review surface (physical iPhone "Sidney"); Brian owns Android.
- **Sketch 171 variant B** — bottom bar is 4 destinations + a centre dock, not 5 flat tabs.
- **Sketch 172 variant A** — the dock is **Swap**, reusing `Icons.swap_vert_rounded`.
- **Sketch 174** — accounts sheet has two labelled sections, SDK vs private.
- **Dock overlaps the bar** and is large (64px) — per Jakub's reference image, 2026-08-06.
- All user-facing copy in **English**.
- Always route work through GSD. Reuse existing `GW*` base components.

## Sketches produced

| # | Name | State |
|---|---|---|
| 171 | mobile-home-and-nav | 4 whole schemes + baseline; B picked |
| 172 | dock-icon-and-top-bar | 4 dock candidates; A picked |
| 173 | variant-a-interactive | clickable prototype |
| 174 | accounts-sdk-vs-private | two-section accounts sheet |

Served at `http://localhost:8899/` (`python3 -m http.server 8899 --directory .planning/sketches`).

## Code changed (uncommitted)

| File | Change |
|---|---|
| `lib/screens/splash.dart` | `SafeArea(top:false, minimum: space6)` — bottom rail was under the home indicator |
| `lib/components/coins/view/coin_card_row.dart` | zero balances `textPrimary38` → `textPrimary80` (3.54:1 → 12.4:1) |
| `lib/account/account_drawer.dart` | two sections (SDK / Your Accounts), `ACTIVE ON NODE` badge, disconnected state, title → "Accounts" |
| `lib/components/overlay/responsive_overlay.dart` | mobile `AppBar` header with wallet identity; 4 tabs + overlapping Swap dock; `_currentIndex` returns -1 instead of a silent 0 |
| `lib/components/overlay/global_swap_fab_host.dart` | FAB hidden on the mobile shell (the dock replaces it) |
| `test/components/global_swap_fab_host_test.dart` | desktop-width viewport + new mobile-shell test |
| `test/account/account_drawer_show_test.dart` | assertions follow the two-section split |

`flutter analyze` — **No issues found**. `flutter test` — **1018 passed** (before the last dock geometry change; re-run needed).

## The bug worth remembering

The first dock implementation made `_MobileSwapDock` a `SizedBox` with **only a width**. `Scaffold`
offers `bottomNavigationBar` `maxHeight` equal to the whole screen, so the unbound height propagated,
the bar became full-screen, and the dock landed dead centre of the phone. **No exception, no
overflow, analyzer clean, 1018 tests green — and the app was unusable.** Only looking at the device
caught it. Recorded in `.planning/debug/260806-mobile-shell-dock.md`.

Second, separate fault in the same report: a hand-rolled `Container` in `Scaffold.appBar` renders
under the notch, because Scaffold reserves the top inset but does not apply it — `AppBar` does that
itself. Fixed by using a real `AppBar`.

## Open / owed

- **Visual verification of the final dock geometry has NOT happened.** Do not call phase 24 done until it is.
- No regression test pinning "the mobile bar is never taller than a fraction of the viewport" — needs
  a shell harness (GoRouter + AppBloc + WalletDetailsCubit) that no test builds today.
- `ANR detected` at boot and `getCoins` taking ~25s — pre-existing, unrelated to this phase.
- Two stale `Runner` installs were seen on the device from different bundle UUIDs.

## Tooling state (this cost most of the session)

- **iPhone Mirroring is permanently unavailable** — blocked in the EU under the DMA. Confirmed by
  `[com.apple.screensharing:eligibility] Device is ineligible ... answer: 2` and the app's own dialog.
  Use **QuickTime → New Movie Recording → source: Sidney** over USB instead.
- `screencapture` needs Screen Recording permission for **Cursor** (the host app). Already granted.
- The QuickTime capture session dies when the app is reinstalled and then returns an all-black frame
  (0 non-zero pixels). Re-create the recording window; it is not an app symptom.
- **The USB cable kept dropping** — `flutter devices` fell back to `Sidney (wireless)` three times,
  and every "Lost connection to device" traces to that. Wireless launch then fails because the VPN
  blocks local-network discovery of the Dart VM Service.
- Launch also failed with `Timed out waiting for CONFIGURATION_BUILD_DIR to update` (Xcode open on
  the same project) and `Sidney may need to be unlocked to recover from previously reported
  preparation errors`.
- Launch pattern that works: detached `flutter run` with a FIFO on stdin (see
  [[geniuswallet-macos-ios-setup]]). Never as a harness-managed background task.

## Next actions

1. Re-plug USB (different port), unlock the phone, quit Xcode.
2. Relaunch, verify the dock overlaps the bar and the header clears the notch.
3. Re-run `flutter test` after the dock geometry change.
4. Then decide on committing — nothing is committed and commits are gated on Jakub's say-so.
