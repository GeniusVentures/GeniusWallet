---
phase: 04-navigation-shell-chrome
plan: 05
subsystem: ui
tags: [flutter, settings, gw-card, gw-select, gw-switch, gw-textfield, gw-button, theme-extension, appearance-toggle]

# Dependency graph
requires:
  - phase: 04-navigation-shell-chrome
    provides: "04-02's GWColors ThemeExtension attached to ThemeData in both light/dark branches — this plan is one of 04-02's DEFERRED migration_surface readers, migrated in place here"
provides:
  - "lib/settings/settings_screen.dart re-skinned to Phase 3 gw_* primitives: GWScreen wrapper, GWCard sections, GWIcon.material + titleMd titles, GWSelect/GWTextField/GWSwitch rows, GWButton actions"
  - "Settings screen's own appearance-aware chrome/text reads (divider, title, neutral status text) resolved fail-soft from Theme.of(context).extension<GWColors>(), never the GeniusWalletColors static getters"
affects: [04-06, 04-07]

# Tech tracking
tech-stack:
  added: []
  patterns:
    - "GWScreen picked over AppScreenView as the screen-wrapper primitive for routes that own their own AppBar/title (matches the sibling /logs SubmitLogsScreen pattern) — AppScreenView has no appBar slot and is reserved for routes relying on the shell overlay's chrome"
    - "GWSwitch's built-in label param replaces SwitchListTile+ListTile wrapper directly — no separate Text+Row hand-rolling needed"

key-files:
  created: []
  modified:
    - lib/settings/settings_screen.dart

key-decisions:
  - "Screen wrapper: GWScreen, not AppScreenView. Settings today (like /logs' SubmitLogsScreen) owns a nested Scaffold+AppBar(title) inside the ShellRoute's MobileOverlay/DesktopOverlay chrome — GWScreen's Scaffold+appBar param is a direct token-ified replacement of that exact shape. AppScreenView provides no Scaffold/appBar at all (matches DashboardScreen-style routes that rely entirely on the shell's own chrome); switching to it would silently drop the 'Settings' title bar, which is a structural change, not a re-skin."
  - "Divider: set explicit gw.borderSubtle rather than leaving Material 3's dropped-dividerTheme default (colorScheme.outlineVariant). Cannot be visually confirmed without the Task 3 walk (Task 1/2 verify is automated-only) — recorded here as the initial choice per 04-RESEARCH §4.1's guidance; swap to gw.borderStrong if the walk finds borderSubtle reads too faint against GWCard's surfaceElevated fill."
  - "Padding/spacing tokens matched to the pre-existing literal values exactly where a GeniusWalletConsts constant coincided (space2=4, space4=8, space8=16, space12=24) so the outer screen padding and section spacing are visually unchanged; GWCard's own default padding (space8=16) and default radius (radiusLg=15, vs. the old hardcoded 12) are accepted per §3.1's mapping table."
  - "Button icons use plain Icon(...) for GWButton's leading param (not GWIcon.material) — matches the existing convention in lib/dev/design_gallery_screen.dart's GWButton.icon demos; GWButton's IconTheme.merge wrapper already supplies the correct color regardless of which Icon primitive is used."

requirements-completed: [GAP-02]

coverage:
  - id: D1
    description: "Settings screen's three section cards (Log Config, Network Config, CRDT Config) re-skinned to GWCard with GWIcon.material+titleMd titles and an explicit gw.borderSubtle divider; GWScreen picked as the screen wrapper (recorded above) and the section's gw = Theme.of(context).extension<GWColors>() fail-soft read added so the screen's own chrome flips on a live appearance toggle"
    requirement: "GAP-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/settings/settings_screen.dart -- No issues found! (Task 1)"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 1 commit 25037bf"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 Settings walk (blocking-human, gate=blocking) -- confirms cards/title/divider actually render correctly and flip live in both modes"
        status: unknown
    human_judgment: true
    rationale: "Compile-time analyze proves the code reads the right token but cannot prove the screen visually re-skins live or that divider contrast holds in both modes — that requires the Task 3 human walk, which is outstanding (autonomous: false)."
  - id: D2
    description: "Config rows re-skinned: DropdownButton<String> (log-level) -> GWSelect<String>, SwitchListTile (boolean config) -> GWSwitch, TextFormField (numeric/text config) -> GWTextField, FilledButton.icon/OutlinedButton.icon (Apply/Save) -> GWButton primary/secondary with develop's exact labels; status-line color logic kept verbatim, colors mapped to static statusSuccess/statusError plus extension-resolved gw.textSecondary (neutral); every onChanged/value binding still points at develop's existing _loggerLevels/_networkConfig/_crdtConfig setState mutations and Apply/Save handlers"
    requirement: "GAP-02"
    verification:
      - kind: other
        ref: "flutter analyze lib/settings/settings_screen.dart -- No issues found! (Task 2)"
        status: pass
      - kind: other
        ref: "bash tool/verify_additive_boundary.sh -- PASSED after Task 2 commit c352192"
        status: pass
      - kind: manual_procedural
        ref: "Task 3 Settings walk -- confirms every action (Apply/Save, log-level change, config toggle/field edit) still works and status line shows the right token color in both modes, plus the LIVE-toggle re-skin (04-02 D-02) without re-navigation"
        status: unknown
    human_judgment: true
    rationale: "Analyze proves the code compiles and the read paths are correct, but cannot exercise config read/write behavior, confirm WCAG AA contrast, or confirm the live-toggle re-skin in a running app — all of that is the Task 3 human walk, which is outstanding (autonomous: false, gate=blocking)."

duration: ~10min (Tasks 1-2 only; Task 3 is a blocking-human checkpoint, not yet performed)
completed: 2026-07-18
status: blocked
---

# Phase 04 Plan 05: Settings screen re-skin Summary

**Settings screen (GAP-02) re-skinned to Phase 3's `gw_*` primitives — `GWScreen` wrapper, `GWCard` sections, `GWSelect`/`GWTextField`/`GWSwitch` rows, `GWButton` actions — with develop's config read/write logic, onChanged/value bindings, and status strings completely unchanged.**

Tasks 1-2 (both `type="auto"`) are complete and committed. **Task 3 — the Settings walk in both appearance modes — is a `checkpoint:human-verify` (`gate="blocking"`, `autonomous: false`) and has NOT been performed.** This SUMMARY documents the auto-task work only; the walk that confirms the re-skin actually renders correctly, every action still works, and the screen flips live on an appearance toggle remains outstanding.

## Performance

- **Started:** ~2026-07-18 (local)
- **Completed (Tasks 1-2):** 2026-07-18 (Task 2 commit `c352192`)
- **Duration:** ~10 min
- **Tasks:** 2 of 3 (Task 3 pending human verification)
- **Files modified:** 1 (`lib/settings/settings_screen.dart`)

## Accomplishments

- `build()` now returns `GWScreen(appBar: ..., padding: ..., maxContentWidth: ..., child: ...)` instead of a hand-rolled `Scaffold(appBar: ..., body: Center(child: SingleChildScrollView(...)))` — same visible chrome (title bar, max-width-768 centered scrollable column), now token-driven.
- `_buildSectionCard` (shared by all three sections) resolves `final gw = Theme.of(context).extension<GWColors>() ?? GWColors.dark();` once and uses it for the section's own appearance-aware reads: title icon/text color (`gw.textPrimary`), divider color (`gw.borderSubtle`), and neutral status-line color (`gw.textSecondary`).
- `Card` → `GWCard` (default `radiusLg`/`elevationCard`/`space8` padding — no explicit overrides needed, component defaults match the spec table).
- Section title `Icon`+bold `Text` → `GWIcon.material` + `GeniusWalletTypography.titleMd.copyWith(fontWeight: FontWeight.bold)`.
- `DropdownButton<String>` (log-level rows) → `GWSelect<String>`.
- `SwitchListTile` (boolean config rows) → `GWSwitch(label: ...)` — its own `label`/`description` params render the Row+Text+toggle pattern directly, no separate `ListTile` wrapper needed.
- `TextFormField` (numeric/text config rows) → `GWTextField`.
- `FilledButton.icon`/`OutlinedButton.icon` (Apply/Save) → `GWButton` primary/secondary variant, develop's exact button labels reused verbatim (`'Apply Log Changes'`, `'Save Network Overrides'`, `'Save CRDT Overrides'`).
- Status-line color logic (`status.contains('✅')` / `contains('Error')` / neutral) kept byte-identical; only the color source changed: `Colors.greenAccent` → `GeniusWalletColors.statusSuccess` (static, mode-invariant by design), `Colors.redAccent` → `GeniusWalletColors.statusError` (static), `Colors.grey` → `gw.textSecondary` (appearance-aware, extension-resolved).

## Task Commits

Each auto task was committed atomically:

1. **Task 1: Re-skin the three section cards, screen wrapper, and dividers** - `25037bf` (feat)
2. **Task 2: Re-skin the config rows, action buttons, and status-line colors** - `c352192` (feat)

**Task 3: Settings walk — criterion 5 (Settings half), both modes — NOT YET PERFORMED** (`checkpoint:human-verify`, `gate="blocking"`, `autonomous: false`). No plan-metadata commit has been made; STATE.md/ROADMAP.md are owned by the orchestrator and not updated by this run.

## Files Created/Modified

- `lib/settings/settings_screen.dart` — screen wrapper (`Scaffold`+`AppBar` → `GWScreen`), section chrome (`Card` → `GWCard`, title `Icon`+`Text` → `GWIcon.material`+`titleMd`, `Divider` → explicit `gw.borderSubtle`), config rows (`DropdownButton` → `GWSelect`, `SwitchListTile` → `GWSwitch`, `TextFormField` → `GWTextField`), action buttons (`FilledButton.icon`/`OutlinedButton.icon` → `GWButton`), status-line color mapping (`Colors.greenAccent`/`redAccent`/`grey` → `GeniusWalletColors.statusSuccess`/`statusError` (static) / `gw.textSecondary` (extension-resolved)). No config read/write logic, onChanged/value bindings, or user-facing strings changed.

## Decisions Made

- **Screen wrapper: `GWScreen`, not `AppScreenView`.** Settings today owns a nested `Scaffold`+`AppBar(title: 'Settings')` inside the `ShellRoute`'s `MobileOverlay`/`DesktopOverlay` chrome — the same pattern the sibling `/logs` route's `SubmitLogsScreen` uses (its own `Scaffold(appBar: AppBar(title: const Text('Send Feedback')))`), as opposed to routes like `DashboardScreen` that render no `Scaffold` of their own and rely entirely on the shell overlay's chrome. `GWScreen`'s `Scaffold`+`appBar` param is a direct token-ified replacement of that exact shape (`appBar`, `padding`, `maxContentWidth`, scroll+center already built in). `AppScreenView` has no `appBar`/title slot at all — picking it would have silently dropped the "Settings" title bar, which is a structural change (losing a screen title), not a re-skin. Passed `maxContentWidth: GeniusBreakpoints.medium` (768, matching the prior `ConstrainedBox(maxWidth: GeniusBreakpoints.medium)` exactly) and `padding: const EdgeInsets.all(GeniusWalletConsts.space8)` (16, matching the prior `EdgeInsets.all(16)` exactly) to keep the outer layout visually unchanged.
- **Divider color: explicit `gw.borderSubtle`, not left on the M3 default.** 04-01 dropped `dividerTheme`, so an unstyled `Divider()` now falls back to `colorScheme.outlineVariant`. Since Task 1/2's verify is automated-only (no way to visually confirm contrast against `GWCard`'s `surfaceElevated` fill in either mode), an explicit appearance-aware color was set proactively rather than deferred to the walk. This also has a correctness reason independent of contrast: `const Divider()` (the original code) would not re-skin on a live toggle even if colorized later (04-02's const-shortcut bug), so the divider was made non-const with an explicit `gw`-sourced color from the start. **This choice needs Task 3 confirmation** — swap to `gw.borderStrong` if `borderSubtle` reads too faint.
- **GWTextField has no style/fontFamily override API.** The original numeric/text config `TextFormField`s used `TextStyle(fontFamily: 'JetBrainsMono')` for a monospace editing feel; `GWTextField` hardcodes `GeniusWalletTypography.bodyLg` with no override hook. This is an accepted, unavoidable trade-off of the component mapping (§3.1's table has no fontFamily column) — not something this plan's scope permits extending `GWTextField`'s API to preserve (that would be a Rule 4 architectural change to a Phase 3 primitive, out of scope for a screen re-skin plan). The logger-name column (`entry.key`, not user-edited) keeps its own explicit `TextStyle(fontFamily: 'JetBrainsMono')` unchanged, since that's a plain `Text` widget this plan didn't touch.
- **Button leading icons use plain `Icon(...)`, not `GWIcon.material`.** Matches the existing convention already established in `lib/dev/design_gallery_screen.dart`'s `GWButton.icon` demos; `GWButton` wraps `leading`/`icon` in `IconTheme.merge` so the color is correctly overridden regardless of which Icon primitive is passed in.

## Deviations from Plan

None (Rules 1-4) — plan executed exactly as written for Tasks 1-2. The screen-wrapper choice, divider-color choice, and GWTextField font-family trade-off above are all decisions the plan's own `<action>` text explicitly asked the executor to make and record (not silent deviations); each is documented above per the plan's `<output>` instruction.

## Issues Encountered

None. `flutter analyze` and `bash tool/verify_additive_boundary.sh` passed cleanly after both auto tasks, no fix-attempt iterations needed.

## Verification Results

- **`flutter analyze lib/settings/settings_screen.dart`:** "No issues found!" after both Task 1 and Task 2.
- **`bash tool/verify_additive_boundary.sh`:** PASSED after both Task 1 (`25037bf`) and Task 2 (`c352192`) — no shadow-import drift, duplicate-class census unchanged, no `WIRE-` markers.
- **Task 3 (Settings walk, both appearance modes, LIVE toggle):** NOT YET PERFORMED — `checkpoint:human-verify`, `gate="blocking"`, `autonomous: false`. This is the outstanding piece of Criterion 5 (Settings half): confirm all three sections wear the redesign skin, every action (log-level change, config toggle, config field edit, Apply/Save) still works and shows the correct status color, dividers read cleanly against `GWCard`, the whole screen re-skins in place on a live toggle (no re-navigation) per 04-02 D-02, and WCAG AA contrast holds for text/dividers/neutral status in both modes.

## Known Stubs

None — no hardcoded empty values, placeholder text, or unwired data sources were introduced. Every config-row binding still reads/writes develop's existing `_loggerLevels`/`_networkConfig`/`_crdtConfig` state.

## Threat Flags

None — all changes fall within the plan's declared `<threat_model>` (T-04-05-01 through T-04-05-03), mitigated as specified: config row controls re-skinned with onChanged/value bindings unchanged (T-04-05-01, to be confirmed live at the Task 3 walk), additive-boundary guard green after every task (T-04-05-02), all appearance-aware reads (divider, neutral status text, title icon/text) sourced from `Theme.of(context).extension<GWColors>()` fail-soft, never the static getters (T-04-05-03).

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

Tasks 1-2 (the mechanical re-skin) are complete, committed, and pass both automated gates (`flutter analyze`, additive-boundary guard). **Task 3 — the blocking-human Settings walk — is outstanding** and must be performed before this plan can be marked fully complete: cold debug run (`flutter run -d windows --debug`), open Settings from the shell, exercise each section's primary action in both modes, confirm the LIVE-toggle re-skin (04-02 D-02, no re-navigation workaround), and confirm WCAG AA contrast for text/dividers/neutral status in both modes including the disabled/no-config-loaded states. Until that walk passes, Criterion 5's Settings half is not verified end-to-end, and 04-06/04-07 (which build on this phase's foundation) should treat GAP-02 as pending, not closed.

---
*Phase: 04-navigation-shell-chrome*
*Completed: 2026-07-18 (Tasks 1-2 only; Task 3 walk outstanding)*

## Self-Check: PASSED

`lib/settings/settings_screen.dart` verified present and modified on disk. Both task commit hashes (`25037bf`, `c352192`) verified present in `git log --oneline --all`.
