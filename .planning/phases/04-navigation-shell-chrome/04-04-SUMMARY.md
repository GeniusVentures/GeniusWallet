---
phase: 04-navigation-shell-chrome
plan: 04
subsystem: ui
tags: [flutter, gwcolors, theme-extension, drawer, dialog, appearance]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome (04-02)
    provides: "GWColors ThemeExtension (lib/theme/gw_colors.dart), the fail-soft Theme.of(context).extension<GWColors>() ?? GWColors.dark() pattern, and the deferred migration_surface list (gw_card.dart, gw_dialog.dart, bottom_drawer.dart) this plan closes"
provides:
  - "GWCard, GWDialog, BottomDrawer, and ResponsiveDrawer/_ResponsiveDrawerScaffold all read appearance-aware colors via GWColors, closing 04-02's deferred migration_surface gap app-wide"
  - "Re-skinned account/wallet drawer row, per-wallet context menu, and rename/delete confirmation dialogs (GWDialog's first real production consumer)"
affects: [any future phase touching shared card/dialog/drawer chrome, or the account/wallet drawer]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "Per-row Theme dependency threading: pass the drawer's own itemBuilder context into row-build methods (not the trigger widget's persistent this.context) so Theme.of(context) registers its rebuild dependency on the element that actually renders inside the open overlay"
    - "GWDialogAction closures pop via the outer context (matches showDialog's/GWDialog.show's useRootNavigator: true default, and the existing design_gallery_screen.dart GWDialog usage) rather than a builder-scoped ctx"

key-files:
  created: []
  modified:
    - lib/components/cards/gw_card.dart
    - lib/components/overlays/gw_dialog.dart
    - lib/components/bottom_drawer/bottom_drawer.dart
    - lib/components/bottom_drawer/responsive_drawer.dart
    - lib/account/account_dropdown_selector.dart

key-decisions:
  - "D-06 condition resolved to 'develop already confirms' -- the delete dialog is a PURE re-skin of the existing AlertDialog; the sanctioned-exception clause did NOT fire."
  - "BottomDrawer's root fill and all three ResponsiveDrawer/_ResponsiveDrawerScaffold fills are a deliberate VALUE remap (legacy deepBlueTertiary -> gw.surfaceMenu), not a byte-identical access-path swap, because deepBlueTertiary never branched by mode."
  - "ResponsiveDrawer.show()'s two Route/API-level reads (desktop panel decoration, mobile bottom-sheet backgroundColor) are captured once at open-time by Flutter API design; _ResponsiveDrawerScaffold.build()'s own Scaffold.backgroundColor is the genuinely live-reactive read that makes the open drawer's background actually flip on a toggle."
  - "BottomDrawer is not wired into the live wallet drawer (account_dropdown_selector.dart uses ResponsiveDrawer.show(), whose _ResponsiveDrawerScaffold renders the actual chrome); BottomDrawer's only call site remains lib/dev/design_gallery_screen.dart, so it is verified via the gallery, not the live drawer."
  - "GWWalletCard did not map cleanly onto the drawer row (fixed API has no slot for selection state, balance/address subtitle, watched icon, or a trailing MenuAnchor) -- the row stays a re-skinned ListTile rather than being restructured onto GWCard/GWWalletCard."

requirements-completed: []  # NAV-02 pends the Task 4 human-verify drawer walk (checkpoint, not yet performed)

# Coverage metadata -- Task 4 (human-verify) is outstanding; deliverables below
# are the auto-task (1-3) surface only. Criterion 3/4 + WCAG behavioral
# verification is NOT yet proven -- see "Outstanding: Task 4" below.
coverage:
  - id: D1
    description: "GWCard, GWDialog, BottomDrawer, and ResponsiveDrawer/_ResponsiveDrawerScaffold read appearance-aware surface/text/border colors via Theme.of(context).extension<GWColors>() ?? GWColors.dark()"
    requirement: "NAV-02"
    verification:
      - kind: other
        ref: "grep -q 'extension<GWColors>()' on all four files (Task 1 verify gate) + flutter analyze 0 errors + tool/verify_additive_boundary.sh PASSED"
        status: pass
    human_judgment: true
    rationale: "Static grep/analyze gates confirm the access-path migration landed, but whether the drawer/dialog/card chrome actually flips LIVE on a toggle-while-open (the behavior this migration exists to fix) can only be confirmed by watching it render -- reserved for the Task 4 human-verify walk (step 5, 6, 7)."
  - id: D2
    description: "Account/wallet drawer row and per-wallet context menu re-skinned with GWColors tokens; rename/delete dialogs re-skinned onto GWDialog with develop's copy, guard, dispatch, and re-selection behavior preserved"
    requirement: "NAV-02"
    verification:
      - kind: other
        ref: "grep -q 'extension<GWColors>()' lib/account/account_dropdown_selector.dart (Task 2 verify gate) + flutter analyze 0 errors + tool/verify_additive_boundary.sh PASSED"
        status: pass
    human_judgment: true
    rationale: "Static gates confirm the code compiles and the access-path is in place; rename/delete/guard/re-selection/live-update behavior and WCAG-AA contrast in both modes require the scripted Task 4 drawer walk (steps 1-4, 8) which has NOT been performed yet."

# Metrics
duration: ~25min
completed: 2026-07-18
status: in-progress
---

# Phase 04 Plan 04: Account Drawer Re-skin + Shared Chrome Migration Summary

**Migrated GWCard/GWDialog/BottomDrawer/ResponsiveDrawer to live `GWColors` ThemeExtension reads and re-skinned the account/wallet drawer row, context menu, and rename/delete dialogs onto GWDialog -- Task 4's human drawer walk is still outstanding.**

## Performance

- **Duration:** ~25 min (Tasks 1-3)
- **Completed:** 2026-07-18 (auto tasks only; Task 4 pending)
- **Tasks:** 3 of 4 (Task 4 is a `checkpoint:human-verify` gate, not performed by this executor run)
- **Files modified:** 5

## Accomplishments
- Closed 04-02's deferred `migration_surface` gap for all four shared chrome components (`gw_card.dart`, `gw_dialog.dart`, `bottom_drawer.dart`, `responsive_drawer.dart`) -- each now resolves `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` instead of reading stale `GeniusWalletColors` static getters, so their card/dialog/sheet/scaffold chrome genuinely flips live on an appearance toggle wherever mounted.
- Fixed the LIVE wallet-drawer's own background: `_ResponsiveDrawerScaffold.build()`'s `Scaffold.backgroundColor` now registers its own Theme dependency -- this is the widget that stays mounted for the drawer's lifetime in both the desktop (right-panel) and mobile (bottom-sheet) branches of `ResponsiveDrawer.show()`.
- Re-skinned the drawer row (`_buildDrawerRow`) and per-wallet `MenuAnchor` context menu with GWColors tokens, threading the drawer's own `itemBuilder` context (not the trigger widget's persistent `this.context`) so the row correctly rebuilds live while the drawer is open.
- Re-skinned the rename and delete confirmation dialogs onto `GWDialog` + `GWTextField` + `GWButton` -- `GWDialog`'s first real (non-gallery) production consumer -- preserving develop's copy, the keep-at-least-one guard, `DeleteWallet` dispatch, and re-selection logic exactly.
- Confirmed D-06's condition resolved to "develop already confirms": the delete dialog is a pure re-skin, not a behavior addition; the sanctioned-exception clause did not fire.

## Task Commits

Each task was committed atomically:

1. **Task 1: Migrate shared chrome components (GWCard, GWDialog, BottomDrawer, ResponsiveDrawer) to live appearance-aware reads** - `5872fd3` (feat)
2. **Task 2: Re-skin the drawer row and the per-wallet context menu** - `b11af5c` (feat)
3. **Task 3: Re-skin the rename and delete confirmation dialogs (D-06 pure re-skin)** - `dea5ddf` (feat)

**Task 4 (checkpoint:human-verify, gate="blocking"):** NOT performed by this executor run -- see "Outstanding: Task 4" below.

_Plan-completion metadata commit deferred until Task 4 passes (orchestrator owns STATE.md/ROADMAP.md for this plan per the sequential, no-worktree execution mode)._

## Files Created/Modified
- `lib/components/cards/gw_card.dart` - default-border fallback now reads `gw.borderSubtle` (byte-identical value); import swapped from `genius_wallet_colors.dart` to `gw_colors.dart`
- `lib/components/overlays/gw_dialog.dart` - border and message text now read `gw.borderSubtle`/`gw.textSecondary` (byte-identical); `brandGreen` icon and `GWDialog.show()`'s `barrierColor` stay on the mode-invariant/captured-once static getters
- `lib/components/bottom_drawer/bottom_drawer.dart` - title/close-icon/divider now read `gw.textPrimary`/`gw.textPrimary12` (byte-identical); root fill remapped `deepBlueTertiary` -> `gw.surfaceMenu` (documented value change); gallery-only, not wired into the live drawer
- `lib/components/bottom_drawer/responsive_drawer.dart` - the LIVE wallet-drawer scaffold; all three `deepBlueTertiary` reads remapped to `gw.surfaceMenu` (documented value change); `_ResponsiveDrawerScaffold.build()`'s `Scaffold.backgroundColor` is the genuinely live-reactive read; the desktop panel `BoxDecoration` lost its `const` (now takes a runtime `Color`); the two `ResponsiveDrawer.show()` reads are Route/API-level, captured once at open-time
- `lib/account/account_dropdown_selector.dart` - drawer row (`_buildDrawerRow`) and `MenuAnchor` re-skinned with GWColors tokens (threaded per-row context); avatar/selected-row colors moved to mode-invariant `brandPrimary`/`textOnBrand`; both "You have no wallets!" call sites read `gw.textPrimary70`; rename/delete dialogs re-skinned onto `GWDialog`/`GWTextField`/`GWButton`

## Decisions Made
- **D-06 resolved:** delete confirmation is a pure re-skin of develop's existing `AlertDialog` -- the sanctioned-exception clause (behavior addition allowed) does NOT fire. Copy, guard-before-dialog ordering, `DeleteWallet` dispatch, and re-selection are all byte-for-byte preserved.
- **Context threading for live-flip correctness:** `_buildDrawerRow` now takes the drawer's own `itemBuilder` `BuildContext` as an explicit parameter instead of implicitly closing over `this.context` (the trigger button's persistent State context). This also means the row's `Navigator.of(context).pop(wallet)`, menu actions, and `_confirmRenameWallet`/`_confirmDeleteWallet(context, wallet)` calls now use the per-row context -- consistent with (and no more surprising than) the existing pattern, since both contexts resolve to the same root navigator (`useRootNavigator: true` on `ResponsiveDrawer.show()`), but the per-row context is the one that actually needs to depend on `Theme` for the live-flip fix to work.
- **GWDialogAction pop pattern:** the rename/delete dialog actions pop via the outer `context` (the same context passed to `GWDialog.show()`), matching `showDialog`'s/`GWDialog.show()`'s `useRootNavigator: true` default and the existing `design_gallery_screen.dart` GWDialog usage -- there is no builder-scoped `ctx` available to `GWDialogAction`s since they're constructed before `.show()` is called.
- **GWWalletCard/GWCard did not map cleanly onto the drawer row:** the row's selection states, balance/address subtitle, watched-eye icon, and trailing `MenuAnchor` don't fit `GWWalletCard`'s fixed icon+name+arrow API. The row stays a re-skinned `ListTile` (re-skin, not restructure) rather than being forced onto `GWCard`/`GWWalletCard`.
- **MenuAnchor needs an explicit `menuStyle`:** because the reconciled theme no longer supplies `menuTheme`, the per-wallet context menu now sets `style: MenuStyle(backgroundColor: gw.surfaceElevated, shape: RoundedRectangleBorder(radiusLg))` explicitly (04-RESEARCH Pitfall 5), and the "Copy address"/"Rename" `MenuItemButton`s read `gw.textPrimary`. The "Delete" item's `Colors.redAccent` icon/text was left untouched -- out of this task's explicit audit scope (Task 3's `statusError` migration applies to the delete CONFIRM button, not this trigger item).

## Deviations from Plan

None - plan executed exactly as written for Tasks 1-3. No Rule 1/2/3 auto-fixes were needed; no architectural (Rule 4) escalation occurred.

## Issues Encountered

One pre-existing, out-of-scope `info`-level lint (`use_build_context_synchronously` at `_confirmRenameWallet`, guarded by an unrelated `mounted` check) shifted line numbers across the edits but was present before this plan touched the file (confirmed via `git stash`/re-analyze on the unmodified file) -- left untouched per the scope-boundary rule (pre-existing warnings in files this plan touches are still out of scope unless directly caused by this plan's changes).

## Verification Results (Tasks 1-3, automated only)

- `flutter analyze lib` (full project): **0 errors**, 62 issues total -- matches the pre-existing ~62-issue baseline exactly; no new issues introduced by this plan's changes.
- `bash tool/verify_additive_boundary.sh`: **PASSED** after every task (shadow-import boundary, duplicate-class census, WIRE- tripwire all clean).
- Task 1 grep gate: `extension<GWColors>()` present in all four shared chrome files -- confirmed.
- Task 2 grep gate: `extension<GWColors>()` present in `account_dropdown_selector.dart` -- confirmed.
- No raw hex/px introduced; no `Colors.white`/`Colors.grey`/`Colors.white70` remain in the drawer row; no `Colors.red`/`Colors.redAccent` in the delete CONFIRM path (the delete dialog's destructive `GWButton` uses `statusError`, mode-invariant).

**None of this constitutes the behavioral/visual verification Task 4 exists to provide** -- see below.

## Outstanding: Task 4 (BLOCKING-HUMAN, not performed)

Task 4 is a `checkpoint:human-verify` gate (`autonomous:false`) requiring a live cold-start `flutter run -d windows --debug` walk. It was intentionally **not** performed or fabricated by this executor run. It remains fully outstanding and covers:

1. Criterion 3: stored wallet balances render on cold start without manual refresh.
2. Criterion 4 scripted walk: rename a wallet, guard fires at 1 wallet, delete a non-selected wallet (live update while drawer stays open), delete the selected wallet (auto re-select).
3. Finding 35: "Network Changed" toast on network switch.
4. Delete confirm reads as destructive (statusError); copy unchanged; SGNUS wallet still hides rename/delete.
5. LIVE appearance flip with the drawer OPEN and with a rename/delete GWDialog OPEN (04-02 D-02 regression guard) -- row, subtitle/address text, "no wallets" text, open MenuAnchor menu, and the dialog's own card-like chrome (border/gradient sheen/message text/title/actions) must all re-skin live, no close/re-open workaround.
6. LIVE drawer scaffold background (widened scope): with the drawer OPEN, the panel/sheet's OWN background (not just row/dialog contents) must flip live -- both the desktop right-panel and mobile bottom-sheet variants should be checked if window size permits.
7. Shared-component gallery regression guard: `GWCard`, `GWDialog`, `BottomDrawer` demo instances in the Dev Gallery (`--dart-define=GW_DEV_TOOLS=true`) must also re-skin live.
8. Full repeat of steps 1-7 in BOTH light and dark mode (D-03), confirming WCAG-AA contrast for selected/unselected/watched/disabled row states, the dialog chrome, the drawer's own scaffold background, and the destructive delete button.

**`requirements-completed` is intentionally left empty** ([NAV-02]) until Task 4 passes -- the automated gates in Tasks 1-3 prove the code compiles and the correct access-path is wired, but not that the intended live-flip/behavioral outcome actually renders correctly.

## User Setup Required

None - no external service configuration required.

## Next Phase Readiness

Tasks 1-3 are committed and verified (analyze + additive-boundary guard). The plan cannot be marked complete, and NAV-02 cannot be marked satisfied, until a human performs the Task 4 drawer walk in both appearance modes and reports pass/fail per sub-behavior. STATE.md/ROADMAP.md updates are deferred to the orchestrator for this same reason.

---
*Phase: 04-navigation-shell-chrome*
*Completed (Tasks 1-3 only): 2026-07-18*

## Self-Check: PASSED

All 5 modified source files and this SUMMARY.md confirmed present on disk; all 3 task commit hashes (`5872fd3`, `b11af5c`, `dea5ddf`) confirmed present in `git log`.
