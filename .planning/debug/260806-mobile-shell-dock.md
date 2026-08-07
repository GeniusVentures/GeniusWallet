---
slug: mobile-shell-dock
created: 2026-08-06
status: root-caused
area: ui / navigation shell
suspect_files:
  - lib/components/overlay/responsive_overlay.dart
---

# Debug: mobile shell broken after the centre Swap dock

## Report

Jakub, 2026-08-06: *"apka cala popsula sie przez ten srodkowy CTA"* - the app broke because of the
centre CTA, after phase 24 replaced `BottomNavigationBar` with a custom Row carrying
`_MobileSwapDock`.

## Evidence so far

**What the log does NOT show, which is itself a finding:**
- no `EXCEPTION CAUGHT`, no `RenderFlex ... overflowed`, no failed assertion, no `Null check`
- 150 lines total; the only errors are pre-existing network ones (drpc.org connection resets,
  CoinGecko 429, 3s timeouts) that were present before phase 24

So the shell is **not throwing**. Whatever is wrong renders without an error, which rules out the
first hypothesis worth having (a missing `Material` ancestor for the new `InkWell`s - and on reading,
`Scaffold` does wrap all its slots in `Material`, so that was never it).

**What I could not obtain:** a screenshot. The QuickTime feed of the device went fully black
(0 non-zero pixels across the whole frame) after the app was reinstalled, even with the phone
unlocked. The capture session needs re-selecting; this is a tooling failure, not an app symptom.

## Hypotheses, untested

1. `NetworkDropdownSelector` was built for the desktop control track and does not fit a 60px phone
   header, pushing the header's Row past its constraints without overflowing loudly.
2. The dock's 54px circle plus `Border.all(width: 3)` inside a bar whose height is now driven by
   content could make the bar taller than expected and eat the viewport.
3. `_currentIndex` returning -1 is correct, but some other consumer of it may not expect -1.
4. Not a layout fault at all - taps not landing, so the app *looks* fine but does nothing.

Each predicts a DIFFERENT visible symptom, which is why the next step is a description, not a patch.

## Next step

Get the symptom named: red error screen / yellow-black overflow stripes / blank area / correct
appearance but dead taps / something else. Then test the matching hypothesis.


## ROOT CAUSE (confirmed by the reported symptom, 2026-08-06)

Jakub's description was decisive: *"Nowy CTA jest praktycznie na środku ekranu, a pozostała część
ekranu Genius AI zaczyna się u samej góry mojego ekranu"* - the dock sits mid-screen and the content
starts at the very top edge. That is two separate faults with one report.

### Fault 1 - the bar swallowed the viewport

`_MobileSwapDock` returned `SizedBox(width: 76, child: Center(...))` - **a box bound on one axis
only**. `Scaffold` lays `bottomNavigationBar` out with `maxHeight` equal to the entire screen, so the
unbound height propagated: `Center` expanded to fill everything offered, the `Row` grew to match it,
and the bar became full-screen. The dock, centred inside a full-screen bar, landed dead centre of
the phone.

**Why nothing was logged:** this is not an overflow. Every constraint was satisfied; the widget was
simply offered the whole screen and took it. `flutter analyze` and 1018 tests were all green while
the app was unusable - which is the real lesson here, not the missing height.

**Fix:** `_kMobileBarHeight = 60`, applied to both the bar's `SizedBox` and the dock's.

### Fault 2 - the header rendered under the notch

`_MobileHeader` was a hand-rolled `Container(height: 60)` handed to `Scaffold.appBar`. Scaffold
RESERVES `preferredSize.height + MediaQuery.padding.top` for that slot, but it does not inset the
child - `AppBar` does that itself. Skipping `AppBar` skipped the inset.

**Fix:** return a real `AppBar` with `toolbarHeight: 60`. That also supplies the Material ancestor
the `InkWell` wants and the standard elevation behaviour, none of which the Container had.

## Verification

- `flutter analyze` - No issues found.
- Hot reload onto Sidney succeeded (5 of 3650 libraries).
- **Visual confirmation still outstanding** - the QuickTime capture session died when the app was
  reinstalled and reports a fully black frame (0 non-zero pixels of 629,013), which is a tooling
  failure, not an app symptom. Not claiming this fixed until it has been looked at.

## Follow-up owed

No regression test yet. The invariant worth pinning is "the mobile bar is never taller than a small
fraction of the viewport", and it needs a shell harness (GoRouter + AppBloc + WalletDetailsCubit)
that no test currently builds - `test/account/account_drawer_show_test.dart` has the closest one.
Recorded rather than skipped silently.
