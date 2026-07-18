---
phase: 04-navigation-shell-chrome
plan: 06
subsystem: ui
tags: [flutter, sdk-accounts, gw-card, gw-dialog, gw-textfield, gw-button, bottom-drawer, theme-extension, appearance-toggle, security]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome
    provides: "04-02's GWColors ThemeExtension attached to ThemeData in both light/dark branches — this plan is one of 04-02's DEFERRED migration_surface readers, migrated in place here"
  - phase: 03-gw-component-library
    provides: "BottomDrawer (03-05, content chrome for ResponsiveDrawer.show(), previously demoed only in the gallery) and GWDialog (03-05, landed unconsumed) — this plan is the first real production consumer of both"
provides:
  - "lib/account/sdk_account_manager.dart re-skinned to Phase 3 gw_* primitives: BottomDrawer chrome (first real consumer), GWCard account rows, GWButton footer/dialog actions, GWTextField-in-GWDialog key-entry dialogs"
  - "SDK account manager's own appearance-aware reads (row surface, title/subtitle text, instruction line, empty-state text) resolved fail-soft from Theme.of(context).extension<GWColors>(), never the GeniusWalletColors static getters"
  - "tool/check_no_new_key_logging.sh — reusable gate script diffing a file for newly-added print/debugPrint calls, for any future plan touching key-material entry flows"
affects: [04-07]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "BottomDrawer adopted as real drawer content chrome (not just a gallery demo): ResponsiveDrawer.show(context:, child: BottomDrawer(title:, children:)) with title/actions omitted on .show() itself; footer stays a separate ResponsiveDrawer.show(footer:) param, unmoved"
    - "Selected-row accent collapses to a border/icon-only brandPrimary treatment, never a brandPrimary fill or brandPrimary body text — brandPrimary text on a light-mode surfaceElevated background measures ~1.96:1 contrast, failing WCAG AA outright (same numeric fact GWButton's own textOnBrand comment documents for the inverse case)"
    - "GWDialog's actions close over the OUTER (pre-dialog) BuildContext, not a builder-supplied ctx — because GWDialog.show() builds its actions list before invoking showDialog, every action's onPressed must pop via Navigator.of(context, rootNavigator: true), matching account_dropdown_selector.dart's (04-04) established convention"
    - "Runtime-assembled grep tokens for gate scripts (tool/check_no_new_key_logging.sh splits 'print'/'debugPrint' into parts) so a new gate script's own source never embeds the literal string it's designed to catch"

key-files:
  created:
    - tool/check_no_new_key_logging.sh
  modified:
    - lib/account/sdk_account_manager.dart

key-decisions:
  - "Row surface stays gw.surfaceElevated in BOTH selected and unselected states (per the plan's explicit routing table); the selected-state accent (formerly deepBlueTertiary text + greenAccent tile fill) collapses into a single mode-invariant GeniusWalletColors.brandPrimary treatment applied ONLY to the row border (2px) and the leading/menu icons — never as a fill or as body text, since brandPrimary text/fill directly against a light-mode surfaceElevated background fails WCAG AA (~1.96:1, computed contrast)."
  - "Footer stays attached to ResponsiveDrawer.show(footer:), not relocated into BottomDrawer's own footer slot — the plan's binding rule only requires omitting title/actions on .show(), and BottomDrawer.children forces its own internal ListView.builder (no room for the original Expanded-based body layout), so the account-row list was flattened into BottomDrawer.children directly (instruction line + rows, gaps as SizedBox items) rather than kept as a separately-scrolling Expanded(ListView.separated(...)) nested inside a single BottomDrawer child."
  - "Row/separator/subtitle spacing snapped to the nearest GeniusWalletConsts token per the plan's 'zero raw hex/px' requirement: the original 6px row gap became space2 (4px, closest token below), the 12px subtitle became labelMd (13px, closest existing type-scale token) rather than a new custom size — both are minor, acceptable value-snaps documented here per the project's established value-remap convention (see 04-04-SUMMARY.md precedent)."
  - "Mnemonic QR display (the AlertDialog wrapping QrImageView, incl. its white backdrop) left completely untouched, per the plan's explicit carve-out — not converted to GWDialog, exempted from the zero-raw-px rule."
  - "Explicit MenuAnchor MenuStyle added to the account row's selected-state menu (surfaceElevated background, radiusLg shape) even though 04-RESEARCH's file-level audit note said MenuAnchor was 'absent' in this file — direct inspection during this plan found a MenuAnchor already present in the live file (only the top 120 lines had been confirmed in prior research per 04-UI-SPEC §3.2's own caveat); applied the same Pitfall 5 fix account_dropdown_selector.dart (04-04) already carries, since an unstyled MenuAnchor reverts to stock Material 3 now that menuTheme is dropped."

requirements-completed: [GAP-03]

coverage:
  - id: D1
    description: "Drawer content chrome wrapped in BottomDrawer (first real production consumer) passed as child: to ResponsiveDrawer.show(), title/actions omitted on .show() so no competing AppBar renders; account rows re-skinned Card/ListTile -> GWCard with GWIcon icons; every appearance-aware read (row surface, unselected title/subtitle, instruction line, empty-state) resolves via Theme.of(context).extension<GWColors>() ?? GWColors.dark() in both the drawer's BlocBuilder and _buildAccountRow(); selected-state accent collapsed to a mode-invariant brandPrimary border/icon treatment, never fill or body text; delete-confirm dialog re-skinned to GWDialog/GWDialogAction with a destructive-variant Delete action"
    requirement: "GAP-03"
    verification:
      - kind: other
        ref: "flutter analyze lib/account/sdk_account_manager.dart -- No issues found! (Task 2, commit 774b67a)"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 2 commit 774b67a"
        status: pass
      - kind: manual_procedural
        ref: "Task 4 SDK account manager walk (checkpoint:human-verify, gate=blocking, autonomous:false) -- confirms the drawer chrome/rows actually render correctly, the LIVE appearance-flip (04-02 D-02) works with the drawer open, and WCAG AA contrast holds in both modes"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze proves the code reads the right token but cannot prove the drawer visually re-skins live, that the brandPrimary border/icon accent reads clearly against surfaceElevated, or that contrast holds in both modes — that requires the Task 4 human walk, which is outstanding (autonomous: false)."
  - id: D2
    description: "Footer 'Add with mnemonic'/'Add with private key' explicitly restyled as GWButton secondary (were fully dependent on the now-dropped outlinedButtonTheme); mnemonic/private-key/payout-address entry dialogs re-skinned to GWTextField inside GWDialog with the SAME TextEditingController threaded through unchanged -- controller.text.trim() still flows straight into the existing FFI dispatch (AddSDKAccountWithMnemonic / AddSDKAccountWithPrivateKey / SetSDKPayoutAddress), chrome only, no behavior change; no new console-logging call introduced in the key-entry flow"
    requirement: "GAP-03"
    verification:
      - kind: other
        ref: "flutter analyze lib/account/sdk_account_manager.dart -- No issues found! (Task 3, commit f6525be)"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 3 commit f6525be"
        status: pass
      - kind: other
        ref: "bash tool/check_no_new_key_logging.sh lib/account/sdk_account_manager.dart -- OK: no new key logging (Task 3, commit f6525be; script itself sanity-checked against a synthetic added print() call before use)"
        status: pass
      - kind: manual_procedural
        ref: "Task 4 SDK account manager walk -- confirms add-with-mnemonic / add-with-private-key / set-payout-address dialogs actually open, style correctly, and complete the add/select/delete flows in both modes"
        status: unknown
    human_judgment: true
    rationale: "Analyze and the key-logging gate prove the code compiles, reads the right tokens, and introduces no new logging call, but cannot exercise the add/select/delete flows in a running app, confirm WCAG AA contrast, or confirm the live-toggle re-skin — all of that is the Task 4 human walk, which is outstanding (autonomous: false, gate=blocking)."

duration: ~7min (Tasks 1-3 only; Task 4 is a blocking-human checkpoint, not yet performed)
completed: 2026-07-18
status: blocked
---

# Phase 04 Plan 06: SDK account manager re-skin Summary

**SDK account manager (GAP-03) re-skinned to Phase 3's `gw_*` primitives — `BottomDrawer` chrome (first real production consumer), `GWCard` rows, `GWButton` footer/dialog actions, `GWTextField`-in-`GWDialog` key-entry dialogs — with develop's add/select/delete FFI dispatch, `TextEditingController` threading, and copy completely unchanged; the V6 no-new-key-logging gate passes.**

Tasks 1-3 complete and committed. **Task 4 — the SDK account manager walk in both appearance modes — is a blocking-human checkpoint (`autonomous: false`) and has NOT been performed in this run.**

## Performance

- **Started:** 2026-07-18T15:11:19Z
- **Completed (Tasks 1-3):** 2026-07-18T15:17:52Z
- **Duration:** ~7 min
- **Tasks:** 3 of 4 (Task 4 pending human verification)
- **Files modified:** 2 (`tool/check_no_new_key_logging.sh` created, `lib/account/sdk_account_manager.dart` modified)

## Accomplishments

- **Task 1 (Wave-0 gate scaffold):** `tool/check_no_new_key_logging.sh` created — diffs a given file and fails if any added line contains a `print`/`debugPrint` call, with the token assembled at runtime so the script's own source never embeds the literal. Sanity-checked against both an empty diff (exit 0) and a synthetic added `print()` call (exit 1) before relying on it.
- **Task 2 (drawer chrome + rows):**
  - `_showSDKAccountDrawer` now wraps its content in `BottomDrawer(title: 'SDK Accounts', children: [...])` passed as `child:` to `ResponsiveDrawer.show()`; `title` moved off the `.show()` call itself so `_ResponsiveDrawerScaffold` renders no competing `AppBar` (04-UI-SPEC §5.1's binding rule). `footer:` stayed on `.show()`, unmoved.
  - The account-row list (previously an `Expanded(ListView.separated(...))`) was flattened into `BottomDrawer.children` — instruction line + rows with `SizedBox` gaps — since `BottomDrawer` owns its own internal `ListView.builder` and has no slot for a nested `Expanded`.
  - `_buildAccountRow`: `Card`+`ListTile` → `GWCard` with `GWIcon` icons. Row surface is `gw.surfaceElevated` in both selected/unselected states; the selected-state accent (formerly `deepBlueTertiary` text + `greenAccent` tile fill) collapsed into a single mode-invariant `GeniusWalletColors.brandPrimary` border (2px) + icon-color treatment — deliberately never used as a fill or body-text color (see Decisions).
  - `_confirmDeleteSDKAccount`: `AlertDialog` → `GWDialog`/`GWDialogAction`, `Delete` action on the `destructive` variant (mode-invariant `statusError` fill).
  - Explicit `MenuAnchor(style: MenuStyle(...))` added to the row's selected-state overflow menu (04-RESEARCH Pitfall 5 — an unstyled `MenuAnchor` reverts to stock Material 3 now that `menuTheme` is dropped).
  - Mnemonic QR display (the `AlertDialog` wrapping `QrImageView`, incl. its white backdrop) left completely untouched, per the plan's explicit carve-out.
- **Task 3 (footer actions + key-entry dialogs):**
  - The two footer `OutlinedButton.icon` actions ("Add with mnemonic" / "Add with private key") — which had no inline `style:` override and were therefore fully dependent on the now-dropped `outlinedButtonTheme` — explicitly restyled as `GWButton` `secondary`, labels preserved verbatim.
  - `_showAddWithMnemonicDialog`, `_showAddWithPrivateKeyDialog`, `_showSetPayoutAddressDialog`: `AlertDialog`+`TextField` → `GWDialog.show()`+`GWTextField`, with the **same** `TextEditingController` threaded through unchanged — `controller.text.trim()` still flows straight into the existing FFI dispatch (`AddSDKAccountWithMnemonic` / `AddSDKAccountWithPrivateKey` / `SetSDKPayoutAddress`), chrome only.
  - Removed the now-unused `auto_size_text` import (`GWButton` owns its own label truncation via `Flexible`+`overflow: ellipsis`).
  - `tool/check_no_new_key_logging.sh lib/account/sdk_account_manager.dart` passes — no new console-logging call introduced anywhere in the key-entry flow.

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Wave-0 gate scaffold — no-new-key-logging check** - `ac425c1` (feat)
2. **Task 2: Re-skin the drawer chrome and account rows** - `774b67a` (feat)
3. **Task 3: Re-skin the footer actions and key-entry dialogs (security-sensitive)** - `f6525be` (feat)

**Task 4: SDK account manager walk — criterion 5 (SDK half), both modes — NOT YET PERFORMED** (`checkpoint:human-verify`, `gate="blocking"`, `autonomous: false`). No plan-metadata commit has been made; STATE.md/ROADMAP.md are owned by the orchestrator and not updated by this run.

## Files Created/Modified

- `tool/check_no_new_key_logging.sh` — new gate script; diffs a target file and fails on any added `print`/`debugPrint` call, token assembled at runtime.
- `lib/account/sdk_account_manager.dart` — drawer chrome (`ResponsiveDrawer.show(title:...)` → `BottomDrawer` as `child:`, title omitted on `.show()`), account rows (`Card`/`ListTile` → `GWCard`+`GWIcon`, delete-confirm `AlertDialog` → `GWDialog`), footer actions (`OutlinedButton.icon` → `GWButton` secondary), key-entry/payout dialogs (`AlertDialog`+`TextField` → `GWDialog`+`GWTextField`). No FFI dispatch, controller threading, onTap/onPressed wiring, or user-facing copy changed. Mnemonic QR display left byte-for-byte unchanged.

## Decisions Made

- **Row surface uniform across selection states; brandPrimary accent confined to border/icon, never fill or body text.** The plan's routing table explicitly maps both "the account-row surface" and "selected-tile tint" to `gw.surfaceElevated` — read literally, this means the row's fill never changes between selected/unselected. Separately, the plan requires the selected-state accent (formerly `deepBlueTertiary`/`greenAccent`) to stay mode-invariant on `GeniusWalletColors.brandPrimary`. Reconciling both: `brandPrimary` computed contrast against a light-mode `surfaceElevated` (white) background is ~1.96:1 — the exact same numeric fact `GWButton`'s own `primary` variant comment documents for the inverse case ("white failed WCAG AA in dark mode ~1.9:1"), which is why `GWButton.primary` uses `textOnBrand` foreground on a `brandPrimary` fill rather than `brandPrimary` text on a neutral surface. Applying `brandPrimary` as body text or a full-tile fill here would therefore fail WCAG AA outright in light mode. The accent was instead applied only to the row's 2px border and the leading/menu icon color — both established, already-used `brandPrimary` accent treatments elsewhere in this design system (e.g. `GWTextField`'s `focusedBorder`, `GWSelect`'s focus-border per 04-UI-SPEC §3.1) — while title/subtitle text stays uniformly `gw.textPrimary`/`gw.textSecondary` regardless of selection.
- **Footer stayed on `ResponsiveDrawer.show(footer:)`, not moved into `BottomDrawer.footer`.** The plan's binding rule (04-UI-SPEC §5.1) only requires omitting `title`/`actions` on `.show()`; `footer:` isn't in that list, and `.show()`'s existing `footer:` param already worked correctly before this plan. Keeping it in place avoids an unnecessary structural move beyond "tokens and components change."
- **Account-row list flattened into `BottomDrawer.children` rather than kept as a nested `Expanded(ListView.separated(...))`.** `BottomDrawer.children` is rendered by `BottomDrawer`'s own internal `ListView.builder`; a nested `Expanded` inside one of its items would throw ("Expanded widgets must be placed inside a Flex widget") since `ListView.builder`'s `itemBuilder` provides no `Flex` ancestor. The instruction line and each account row became separate top-level items in `BottomDrawer.children`, with `SizedBox(height: GeniusWalletConsts.space2)` gaps between rows (mirroring the original `ListView.separated`'s separator). This is a minor, necessary structural adaptation to `BottomDrawer`'s own API shape as its first real (non-gallery) consumer, not a scope-creep restructure of the account-manager's own logic.
- **Empty-state text is no longer full-height-centered.** Previously `Center`'d within the drawer's entire remaining body height (via the outer `Expanded`); now it's the sole item in `BottomDrawer.children`, vertically padded (`space10`) but not centered across the full drawer height, since `BottomDrawer`'s scrollable-list architecture doesn't provide a bounded-height slot for a single centered child. Empty-state copy itself preserved verbatim.
- **Value-scale snaps for token discipline (zero raw hex/px):** the original 6px row-gap became `GeniusWalletConsts.space2` (4px, nearest token below 6); the original 12px subtitle font size became `GeniusWalletTypography.labelMd` (13px, nearest existing type-scale token — no custom size added). Both are minor, deliberate value-remaps to fit the project's token scale, consistent with the value-remap convention already documented in 04-04-SUMMARY.md for `BottomDrawer`'s own background-color migration.
- **`GWDialogAction.onPressed` closures pop via `Navigator.of(context, rootNavigator: true)`, using the OUTER (pre-dialog) context** — `GWDialog.show()` builds its `actions` list before calling `showDialog`, so there is no builder-supplied `ctx` to close over (unlike the original `AlertDialog`'s `builder: (ctx) => ...`). This matches the exact convention `account_dropdown_selector.dart` (04-04) already established for `GWDialog.show()` call sites in this codebase.

## Deviations from Plan

None (Rules 1-4) — plan executed as written. The row-surface/accent reconciliation, footer-placement, list-flattening, empty-state-layout, value-scale-snap, and dialog-navigator-pop choices above are all decisions the plan's own `<action>` text left to the executor's judgment within its explicit constraints (WCAG AA, "structure unchanged," "zero raw hex/px," "mode-invariant brand tokens stay static") — not silent deviations from a specified behavior. Each is documented here per the plan's `<output>` instruction.

## Issues Encountered

- Initial removal of the `auto_size_text` import in Task 2 broke compilation (`AutoSizeText` still used by the then-untouched footer, which is Task 3's scope) — caught immediately by `flutter analyze`, import restored for Task 2's commit, removed for real once the footer was actually converted in Task 3. No behavior impact; caught and fixed before either commit landed.

## Verification Results

- **`flutter analyze lib/account/sdk_account_manager.dart`:** "No issues found!" after both Task 2 (`774b67a`) and Task 3 (`f6525be`).
- **`flutter analyze lib`:** 61 issues (info/warning only, no errors) — consistent with the project's pre-existing ~62-issue baseline; no new errors introduced by this plan.
- **`bash tool/verify_additive_boundary.sh`:** PASSED after Task 2 and after Task 3 — no shadow-import drift, duplicate-class census unchanged (8 names, subset of baseline), no `WIRE-` markers.
- **`bash tool/check_no_new_key_logging.sh lib/account/sdk_account_manager.dart`:** "OK: no new key logging" after Task 3. The script was also sanity-checked against a synthetic added `print()` call (correctly exits 1) before being relied on for the real gate.
- **Task 4 (SDK account manager walk, both appearance modes, LIVE toggle):** NOT YET PERFORMED — `checkpoint:human-verify`, `gate="blocking"`, `autonomous: false`. This is the outstanding piece of Criterion 5 (SDK half): confirm the drawer chrome/rows/footer actually render correctly, add-with-mnemonic/add-with-private-key/select/delete all still work, the mnemonic QR display and empty-state copy are unchanged, the whole surface re-skins LIVE on an appearance toggle with the drawer open (04-02 D-02, no re-navigation), and WCAG AA contrast holds for all text/states (including the brandPrimary border/icon accent against `surfaceElevated`) in both modes.

## Known Stubs

None — no hardcoded empty values, placeholder text, or unwired data sources were introduced. Every add/select/delete/set-payout binding still reads/writes develop's existing `AppBloc` events and dispatches into the same native SDK FFI calls (`AddSDKAccountWithMnemonic`, `AddSDKAccountWithPrivateKey`, `SelectSDKAccount`, `DeleteSDKAccount`, `SetSDKPayoutAddress`, `RefreshSDKAccounts`).

## Threat Flags

None — all changes fall within the plan's declared `<threat_model>` (T-04-06-01 through T-04-06-03), mitigated as specified: T-04-06-01 (Information Disclosure, key-entry dialog re-skin) closed by `tool/check_no_new_key_logging.sh` passing after Task 3, with the appearance-color migration verified to never touch the key-entry `TextEditingController` value; T-04-06-02 (Tampering, native SDK FFI account mutation) — every add/select/delete/set-payout handler still points at the exact same `AppBloc` event/FFI call, to be confirmed live at the Task 4 walk; T-04-06-03 (Information Disclosure, copy-address/clipboard) — accepted, pre-existing develop behavior, not introduced or changed this plan.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

Tasks 1-3 (the mechanical re-skin + security gate) are complete, committed, and pass all automated gates (`flutter analyze`, additive-boundary guard, no-new-key-logging gate). **Task 4 — the blocking-human SDK account manager walk — is outstanding** and must be performed before this plan can be marked fully complete: cold debug run (`flutter run -d windows --debug`), open the SDK account manager drawer from the shell, add an account via each footer button, select and delete an account, confirm the mnemonic QR display and empty-state copy are unchanged, confirm the LIVE-toggle re-skin (04-02 D-02, no re-navigation workaround) with the drawer open, and confirm WCAG AA contrast for all text/states in both modes. Until that walk passes, Criterion 5's SDK half is not verified end-to-end, and 04-07 (which builds on this phase's foundation) should treat GAP-03 as pending, not closed.

---
*Phase: 04-navigation-shell-chrome*
*Completed: 2026-07-18 (Tasks 1-3 only; Task 4 walk outstanding)*

## Self-Check: PASSED

`tool/check_no_new_key_logging.sh`, `lib/account/sdk_account_manager.dart`, and this SUMMARY.md verified present on disk. All three task commit hashes (`ac425c1`, `774b67a`, `f6525be`) verified present in `git log --oneline --all`.
