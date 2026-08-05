---
phase: 23-design-system-consolidation-theme-tokens-shared-components
plan: 03
subsystem: ui
tags: [flutter, theming, wcag, contrast, gw-colors, dapp-approval, toast, buttons]

requires:
  - phase: 23-01
    provides: "GWColors ThemeExtension with full name parity to GeniusWalletColors, including the appearance-aware brandPrimaryOnSurface/btnFilter getters and the statusSuccess/statusError/textSecondary AA-divergent exceptions"
  - phase: 23-02
    provides: "the AST codemod (tool/codemod_colors.dart) and its 72-site residue inventory (23-02-RESIDUE.md): 45 const-refused + 27 no-context-refused GeniusWalletColors call sites lib/-wide"
provides:
  - "23-02's full 72-site residue closed (71 migrated to context.gw/an in-scope GWColors param, 1 deliberately left with a recorded reason)"
  - "toast_widget.dart's palette re-derived from context.gw (was fixed regardless of appearance)"
  - "gw_button.dart's destructive variant AA failure fixed (was 3.27:1/3.86:1, now 9.45:1 both modes) via gw.foundationError, plus a Rule-1 disabled-background alpha bug fix"
  - "lib/reown/'s dApp-approval surface (connect/approve/reject drawers, tx details, session-request fallback) moved off a fixed dark-canvas palette onto context.gw"
  - "swap_settings_drawer.dart's forked warning widget deleted; the warning tone now shares GWWarningNote's documented light-mode amber fix"
  - "12 new WCAG-ratio assertions in test/theme/theme_contrast_test.dart (Parts 5-7), reusing the file's existing contrastRatio/themeFor helpers"
  - "(orchestrator follow-up, 8d154b7) GWColors.statusWarningText token: the light-mode amber this plan introduced is now a real token, not a hand-copied literal in 4 files"
  - "(orchestrator follow-up, b6995c9) status-pill warning label fixed in both pill functions, Part 8 added, and a NEW pre-existing light-mode AA failure in the success/error pill tones discovered and filed as a todo"
affects: [23-04, 23-05, 23-06]

tech-stack:
  added: []
  patterns:
    - "Thread an already-in-scope GWColors gw (or context.gw) through a no-context helper instead of leaving GeniusWalletColors.<field> in place -- applied to CustomPainters (gw_mesh_background.dart, gw_spinner.dart), non-widget session handlers (handle_dapp_requests.dart), and private StatelessWidget helper methods (send_transaction_details.dart)."
    - "Fill-purposed vs. foreground-purposed tokens are not interchangeable: gw.statusError is tuned as a foreground/icon colour (meant to sit ON a surface), not a fill safe to paint text on top of. gw.foundationError is the token meant for that job. The same split now exists explicitly for warning: gw.statusWarning (fill) vs. gw.statusWarningText (foreground)."
    - "A fixed (non-appearance-aware) surface/fill must pair with a fixed foreground, never gw.textPrimary -- documented as an explicit annotated exception per this plan's own guidance, not tokenized."
    - "(superseded by 8d154b7, see below) Rule of Three crossed: the light-mode amber workaround (GWAppearance.isLight ? #92400E : gw.statusWarning) had 4 independent occurrences -- flagged in-place as the next promotion candidate. The orchestrator promoted it in a follow-up commit rather than leaving it flagged; see the Follow-up section."

key-files:
  created:
    - .planning/phases/23-design-system-consolidation-theme-tokens-shared-components/23-03-CONTRAST.md
    - (orchestrator follow-up) .planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md
  modified:
    - lib/components/toast/toast_widget.dart
    - lib/components/buttons/gw_button.dart
    - lib/squid_router/swap_settings_drawer.dart
    - lib/reown/approve_dapp_connection_drawer.dart
    - lib/reown/approve_transaction_drawer.dart
    - lib/reown/handle_dapp_requests.dart
    - lib/reown/reown_connect_button.dart
    - lib/reown/send_transaction_details.dart
    - lib/reown/swap_result_drawer.dart
    - test/theme/theme_contrast_test.dart
    - (37 further files closing 23-02's residue -- see Task Commits below)
    - (orchestrator follow-up, 8d154b7) lib/theme/gw_colors.dart, lib/components/feedback/gw_warning_note.dart, lib/dashboard/compute/compute_panel.dart, lib/submit_job/view/widgets/job_steps.dart, test/theme/gw_colors_parity_test.dart
    - (orchestrator follow-up, b6995c9) lib/banxa/banxa_components/order_status_style.dart, lib/dashboard/home/widgets/transaction_displays.dart, test/banxa/order_status_style_test.dart

key-decisions:
  - "gw_button.dart's destructive variant fill switched from gw.statusError to gw.foundationError (previously 0 call sites) because statusError is a foreground/icon-tuned token, not a fill meant to carry text -- neither white nor ink cleared 4.5:1 against it in both modes, foundationError with a documented fixed-white label clears 9.45:1 in both."
  - "swap_settings_drawer.dart's private _Message class deleted; its warning tone now renders GWWarningNote directly (no new parameter added to the shared component), and its error/ok tones moved to a small inline _SlippageStatusRow instead of forcing GWWarningNote to grow a variant flag for one caller."
  - "lib/main.dart:265 (ErrorWidget.builder) deliberately NOT migrated -- the file's own pre-existing doc comment states no Theme ancestor is guaranteed there, and GeniusWalletColors.statusError is mode-invariant regardless, so migrating it would contradict a documented architectural choice for zero behavioural gain. This is the sole entry on the 23-04 allowlist (see below)."
  - "A Rule-1 bug was found and fixed while auditing gw_button.dart's disabled state: `.withAlpha(140)` replaces rather than scales the alpha channel, so a Colors.transparent background jumped to an opaque-ish black wash on disabled secondary buttons (the ghost-only guard had missed it) and gradientOutline. Fixed by gating the dim on the actual background value instead of enumerating variant names."
  - "(orchestrator, 8d154b7) GWColors gained statusWarningText rather than a divergent light value on statusWarning itself, because statusWarning is still read as a FILL by order_status_style.dart/transaction_badge.dart -- darkening it for light mode would have darkened those fills. A second, explicitly foreground-purposed token was the correct shape, mirroring how statusSuccess/statusError already diverge for the same reason but without a fill/foreground conflict on those tokens."
  - "(orchestrator, b6995c9) A pre-existing test (test/banxa/order_status_style_test.dart) was found asserting the light-mode bug itself (dark==light warning foreground) under a title framing it as an intentional fact. Flipped to isNot(equals(...)) rather than left in place, since a passing test that pins a defect is worse than no test."
  - "(orchestrator, b6995c9) Status-pill success/error labels were found to ALSO fail WCAG AA in light mode (2.91-3.89:1 depending on surface, vs the 4.5:1/3:1 floors) -- pre-existing, not introduced by 23-03, and NOT fixed in this follow-up. Filed as a todo rather than silently tuning the new Part 8 test to admit the failure, which would have been the unearned PASS this project explicitly forbids."

patterns-established:
  - "Doc-comment bracket references (`[GeniusWalletColors.foo]`) are real AST nodes to package:analyzer (CommentReference), which is why the codemod's dry-run flagged action_button.dart:17 and responsive_drawer.dart:82/90 as no-context refusals despite no executable code being present. Fixed by rewriting the doc text to plain, non-bracketed mentions of the migrated call."
  - "(orchestrator follow-up) A hand-copied appearance-conditional literal duplicated across N call sites is itself a Rule-1/Rule-2-class defect once N passes the Rule of Three, even when every individual copy is byte-identical and correct -- the fix is a token in lib/theme/, not another documented ponytail comment at site N+1."

requirements-completed: [ORG-04]

coverage:
  - id: D1
    description: "23-02's 72-site residue (45 const + 27 no-context) is fully worked: every entry migrated to context.gw or an in-scope GWColors param, except lib/main.dart:265 which is deliberately left with a recorded architectural reason."
    requirement: ORG-04
    verification:
      - kind: unit
        ref: "tool/codemod_colors.dart --dry-run (Sites rewritten: 0, refused (const): 1, refused (no-context): 0 -- down from 45/27)"
        status: pass
    human_judgment: false
  - id: D2
    description: "toast_widget.dart and gw_button.dart (the two named design-system offenders) read semantic gw tokens in every state, with every touched pair clearing its WCAG threshold in both appearance modes."
    requirement: ORG-04
    verification:
      - kind: unit
        ref: "test/theme/theme_contrast_test.dart#Part 5: ToastWidget clears AA in both appearances (23-03) -- 6 cases"
        status: pass
      - kind: unit
        ref: "test/theme/theme_contrast_test.dart#Part 6: GWButton primary + destructive clear AA (23-03) -- 4 cases"
        status: pass
    human_judgment: false
  - id: D3
    description: "swap_settings_drawer.dart's forked warning widget is gone; the warning tone shares GWWarningNote's documented light-mode amber fix, measured before (1.59:1, fails) and after (7.09:1, passes)."
    requirement: ORG-04
    verification:
      - kind: unit
        ref: "test/theme/theme_contrast_test.dart#Part 7: swap_settings_drawer warning uses GWWarningNote's amber fix (23-03) -- 2 cases"
        status: pass
    human_judgment: false
  - id: D4
    description: "lib/reown/'s dApp-approval surface (connect/approve/reject drawers, transaction details, session-request fallback content) moved off a fixed dark-canvas palette onto context.gw; raw-colour count re-measured at 12, every survivor a documented always-one-mode exception or a grep false positive."
    verification:
      - kind: unit
        ref: "flutter analyze --no-pub lib/reown (No issues found)"
        status: pass
    human_judgment: true
    rationale: "No existing test harness in this repo constructs a ReownWalletKit/GeniusApi to reach ApproveDappConnectionDrawer/ApproveTransactionDrawer through their real call sites (the same limitation url_bar_focus_remount_test.dart's own header comment names for WebViewMobile), so the Allow/Approve button's contrast was verified by a by-hand ratio table in 23-03-CONTRAST.md rather than a live widget test, and this plan's own live-walk requirement for this specific flow could not be performed by this executor (no interactive device-control tool available). Flagged explicitly in 23-03-CONTRAST.md as the one verification gap to check live before this plan is considered fully proven."
  - id: D5
    description: "(orchestrator follow-up, 8d154b7) The light-mode amber this plan hand-copied into 4 files (gw_warning_note.dart, toast_widget.dart, compute_panel.dart, job_steps.dart) is now GWColors.statusWarningText, a single token declared in lib/theme/gw_colors.dart. All four call sites, three now-dead helper functions, and five now-unused imports were removed."
    requirement: ORG-04
    verification:
      - kind: unit
        ref: "test/theme/gw_colors_parity_test.dart (field-count tripwire 64 -> 65)"
        status: pass
      - kind: other
        ref: "flutter analyze --no-pub / tool/check_brace_style.sh --count / dart format --set-exit-if-changed / flutter test --no-pub, all quoted by the orchestrator at 8d154b7: analyze clean, braces 0, format clean, tests 705/0"
        status: pass
    human_judgment: false
  - id: D6
    description: "(orchestrator follow-up, b6995c9) order_status_style.dart and transaction_displays.dart's status-pill warning label read statusWarningText instead of the fill-tuned statusWarning (was 1.47:1/1.59:1 against the composited wash, now 5.93:1+); a pre-existing test that asserted the bug (dark==light warning foreground) was flipped; a new Part 8 group added. A NEW pre-existing failure (success/error pill labels also fail AA in light mode, 2.91-3.89:1) was found and deliberately NOT fixed here -- filed as a todo, and Part 8 does not assert it (would be an unearned PASS)."
    requirement: ORG-04
    verification:
      - kind: unit
        ref: "test/theme/theme_contrast_test.dart#Part 8: status-pill foregrounds on their own wash (23-03 follow-up) -- 2 cases (dark all-tones, light warning-only)"
        status: pass
      - kind: unit
        ref: "test/banxa/order_status_style_test.dart#warning foreground differs between hosts, like every other tone"
        status: pass
    human_judgment: true
    rationale: "The new pre-existing finding (status-pill success/error labels fail WCAG AA in light mode) is explicitly NOT fixed by this commit and needs a human decision on priority/scheduling -- filed at .planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md rather than silently left for a future phase to rediscover."

duration: ~110min (executor) + orchestrator follow-up (8d154b7, b6995c9)
completed: 2026-07-29
status: complete
---

# Phase 23 Plan 03: Residue Closure + Design-System Offenders + dApp Approval Colours Summary

**Closed 23-02's entire 72-site colour-migration residue, fixed a genuine WCAG AA failure in `gw_button.dart`'s destructive variant (was failing in BOTH modes), re-derived `toast_widget.dart`'s fully-inverted palette, migrated `lib/reown/`'s dApp-approval surface off a fixed dark-canvas palette, and deleted `swap_settings_drawer.dart`'s forked warning widget in favour of the shared `GWWarningNote` — with every touched colour pair's WCAG ratio measured and asserted in both appearance modes. Two orchestrator follow-up commits (documented below, not authored by this execution) then promoted this plan's own hand-copied amber literal to a real `GWColors.statusWarningText` token and fixed the two status-pill functions' warning label, discovering in the process a NEW pre-existing light-mode AA failure in those same pills' success/error labels — filed as a todo, not fixed.**

## Performance

- **Duration:** ~110 min (this execution) + orchestrator follow-up work (2 commits, not timed by this executor)
- **Tasks:** 3 (residue closure; toast + button fix; reown + forked widget)
- **Files modified:** 44 (37 residue-closing files + `toast_widget.dart` + `gw_button.dart` + 6 `lib/reown/` files + `swap_settings_drawer.dart`, minus overlaps) + `test/theme/theme_contrast_test.dart` + `test/dashboard/transaction_badge_test.dart` by this execution; **+9 more** by the two orchestrator follow-up commits (see below)
- **Files created:** `23-03-CONTRAST.md` (this execution); `.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md` (orchestrator follow-up)

## Accomplishments

- **Task 1 — residue closed.** `tool/codemod_colors.dart --dry-run` went from **45 const-refused + 27 no-context-refused = 72 total** down to **1 refused** (`lib/main.dart:265`, a deliberate, documented exception). Every other site now reads `context.gw.<field>` or an already-in-scope `GWColors gw` parameter. No site was moved to a *different* token than the one it had — confirmed per-site during the edit, and the two AA-divergent exception fields (`statusError`/`statusSuccess`/`textSecondary`) that DO change value between the legacy static and `gw.<field>` were migrated anyway, since that divergence is the field's own designed AA correction, not a different semantic choice.
- **Task 2 — the two named offenders, with measured ratios.** `toast_widget.dart`'s entire palette (surface, text, per-type accent) was re-derived from `context.gw`; every pair measured and asserted for both modes (`23-03-CONTRAST.md`). `gw_button.dart`'s destructive variant was found FAILING WCAG AA in **both** modes (3.27:1 dark, 3.86:1 light) — `gw.statusError` is a foreground/icon-tuned token, not a fill meant to carry text. Fixed with `gw.foundationError` (a fill-purposed dark red already in the palette with zero call sites) + a documented fixed-white label, now 9.45:1 in both modes. A second Rule-1 bug (an `.withAlpha(140)` alpha-replacement bug painting an unintended black wash on disabled `secondary`/`gradientOutline` buttons) was found and fixed in the same pass.
- **Task 3 — `lib/reown/` + the forked widget.** Six files in the dApp-approval surface (connect/approve/reject drawers, transaction details, session-request fallback content) moved off a fixed, dark-canvas-only palette (`Colors.white`/`white70`/`grey`) onto `context.gw`; raw-colour count re-measured at 12 survivors, all documented exceptions or grep false positives. `swap_settings_drawer.dart`'s private `_Message` class — which re-derived its warning tone from the raw, un-fixed `statusWarning` token (measured 1.59:1 on light's white panel, effectively invisible) instead of reusing `GWWarningNote`'s documented amber fix — is deleted; the warning tone now renders `GWWarningNote` directly (no new parameter added to it), measured at 7.09:1 (light) / 12.11:1 (dark).
- **Orchestrator follow-up 1 (`8d154b7`) — the amber literal became a token.** This plan's own fix (correct in substance) had landed as a hand-copied `GWAppearance.isLight ? #92400E : gw.statusWarning` conditional in 4 files plus 2 test sites — a raw hex outside `lib/theme/`, past the Rule of Three, exactly the duplication 23-01 warned about. `GWColors` gained `statusWarningText` (a second, explicitly foreground-purposed token, since `statusWarning` itself is still read as a fill elsewhere); all four call sites, three now-dead helper functions and five now-unused imports were removed.
- **Orchestrator follow-up 2 (`b6995c9`) — the status pills, and a new finding.** `gw_warning_note.dart`'s own doc comment had predicted two more consumers of the light-mode amber bug by name: the two status-pill functions (`order_status_style.dart`, `transaction_displays.dart`), both painting their label in fill-tuned `statusWarning` at 1.47:1/1.59:1 against their own wash. Fixed to `statusWarningText`; a pre-existing test that had been asserting the bug itself was flipped; new Part 8 assertions added. In the process, a **new pre-existing failure** was found and left open: the SAME pills' success/error labels also fail AA in light mode (2.91–3.89:1), unrelated to this plan's own changes and not fixed here — filed as a todo with the full measured table.

## Task Commits

Each task was committed per-directory batch, atomically:

1. **Task 1 (residue, batch 1 — account/banxa/components):** `7c97670`
2. **Task 1 (residue, batch 2 — components):** `3ae73f6`
3. **Task 1 (residue, batch 3 — dashboard/dev/logs/reown/screens/squid_router/submit_job/tokens/web):** `954930e`
4. **Task 2 (toast + button fix + contrast tests):** `bf9c0b6`
5. **Task 3 (lib/reown/ raw-colour migration):** `fb9294e`
6. **Task 3 (forked widget deletion + amber fix + contrast tests):** `d14dc83`
7. **docs (this plan's original completion commit):** `05e92b9`

**Orchestrator follow-up commits (not authored by this execution — folded into this SUMMARY per the orchestrator's instruction, code unchanged by this documentation update):**

8. **`statusWarningText` token promotion:** `8d154b7`
9. **Status-pill warning label fix + Part 8 + new-finding todo:** `b6995c9`

_No separate "plan complete" metadata commit was made beyond this SUMMARY's own commit, per the executor protocol's final-commit step._

## Files Created/Modified

- `.planning/phases/23-.../23-03-CONTRAST.md` — measured WCAG ratios for every pair touched in Tasks 2-3, before/after for the amber fix, the re-measured `lib/reown/` raw-colour survivor list, and an honest statement of what could and could not be verified live in this environment.
- `lib/components/toast/toast_widget.dart` — whole palette re-derived onto `context.gw`.
- `lib/components/buttons/gw_button.dart` — destructive variant fill/foreground fixed; disabled-background alpha bug fixed; primary/gradient/gradientOutline residue closed with strengthened exception comments.
- `lib/squid_router/swap_settings_drawer.dart` — `_Message` deleted; warning tone now `GWWarningNote`; error/ok now `_SlippageStatusRow`.
- `lib/reown/approve_dapp_connection_drawer.dart`, `approve_transaction_drawer.dart`, `handle_dapp_requests.dart`, `reown_connect_button.dart`, `send_transaction_details.dart`, `swap_result_drawer.dart` — raw colours moved onto `context.gw`; remaining literals documented.
- `test/theme/theme_contrast_test.dart` — Parts 5 (toast, 6 cases), 6 (button, 4 cases), 7 (swap-settings warning, 2 cases): 12 new tests, all reusing the file's existing `contrastRatio`/`themeFor` helpers.
- `test/dashboard/transaction_badge_test.dart` — updated for `badgeGlyphColor`'s new `GWColors gw` parameter (see Deviations).
- 31 further files closing residue sites: `lib/account/account_drawer.dart`, `sdk_account_manager.dart`; `lib/banxa/banxa_components/order_status_style.dart`; `lib/components/action_button.dart`, `custom_future_builder.dart`, `incorrect_pin.dart`, `registration_header.dart`, `wallet_information.dart`, `wallets_overview.dart`, `bottom_drawer/responsive_drawer.dart`, `buttons/gw_swap_fab.dart`, `continue_button/isactive_false.dart`, `isactive_true.dart`, `effects/gw_mesh_background.dart`, `feedback/gw_error_state.dart`, `gw_loading_state.dart`, `inputs/gw_select.dart`, `gw_text_field.dart`, `loading/gw_spinner.dart`, `overlay/responsive_overlay.dart`; `lib/dashboard/compute/compute_panel.dart`, `home/widgets/transaction_badge.dart`, `transaction_displays.dart`; `lib/dev/design_gallery_screen.dart`; `lib/logs/submit_logs_screen.dart`; `lib/screens/splash.dart`; `lib/squid_router/token_flip_button.dart`; `lib/submit_job/view/widgets/job_step_list.dart`, `job_steps.dart`; `lib/tokens/token_info_screen.dart`; `lib/web/web_view_mobile.dart`, `web_view_windows.dart`.

### Orchestrator follow-up (`8d154b7`, `b6995c9`) — code NOT written by this execution, listed for completeness

- `lib/theme/gw_colors.dart` — new `statusWarningText` field, declared on the constructor and both `.light()`/`.dark()` factories.
- `lib/components/feedback/gw_warning_note.dart`, `lib/components/toast/toast_widget.dart`, `lib/dashboard/compute/compute_panel.dart`, `lib/submit_job/view/widgets/job_steps.dart` — repointed to `gw.statusWarningText`; three now-dead helper functions and five now-unused imports removed.
- `test/theme/gw_colors_parity_test.dart` — field-count tripwire updated 64 → 65.
- `lib/banxa/banxa_components/order_status_style.dart`, `lib/dashboard/home/widgets/transaction_displays.dart` — pill `fg:` repointed to `statusWarningText` (wash unchanged).
- `test/banxa/order_status_style_test.dart` — a test that had been asserting the light-mode bug itself was flipped to assert the fix.
- `test/theme/theme_contrast_test.dart` — new Part 8 group (2 cases).
- `.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md` — new todo recording the NEW pre-existing finding (status-pill success/error labels fail AA in light mode), with the full measured table and upgrade path.

## Decisions Made

- **`gw.foundationError` over a new token.** The destructive-button fix reused an existing, previously-unused (`0 call sites`) palette field rather than inventing a new colour — `foundationError` was already documented as "fill-purposed dark red," exactly the missing piece.
- **`GWWarningNote` gained no parameter.** `_Message`'s error/ok tones were split off into a small local `_SlippageStatusRow` rather than adding a variant flag to the shared component — the Rule-of-Three guard in `AGENTS.md` applied directly (one caller needing a second shape is not grounds to complicate a shared component).
- **`lib/main.dart:265` left on the primitive layer.** Its own pre-existing doc comment names an explicit architectural reason (no guaranteed `Theme` ancestor in `ErrorWidget.builder`); `GeniusWalletColors.statusError` is mode-invariant regardless, so migrating it would buy nothing while contradicting a documented decision. This is the sole entry on the 23-04 allowlist.
- **Doc-comment bracket references treated as real sites.** `package:analyzer` parses dartdoc `[Foo.bar]` references into `CommentReference` AST nodes, which is why the codemod's dry-run flagged two purely-documentary mentions (`action_button.dart:17`, `responsive_drawer.dart:82/90`) as no-context refusals. Fixed by rewriting the doc text to plain (non-bracketed) mentions of the already-migrated call, rather than leaving a stale/misleading doc reference.
- **The 4th occurrence of the light-mode amber workaround was reused, not promoted, by this execution — then promoted by the orchestrator.** `toast_widget.dart`'s warning type needed the same `GWAppearance.isLight ? #92400E : gw.statusWarning` pattern already duplicated 3 times elsewhere. This plan's own text flagged the promotion as outstanding ("the next thing to actually do, not just note") but left it as a ponytail comment, since the promotion touches `lib/theme/gw_colors.dart`, outside this plan's declared `files_modified`. The orchestrator's follow-up commit `8d154b7` made that promotion (`GWColors.statusWarningText`) rather than leaving it deferred — see the Follow-up section below.
- **(Orchestrator, `8d154b7`) A second, foreground-purposed token rather than a divergent value on `statusWarning` itself.** Unlike `statusSuccess`/`statusError`, `statusWarning` could not simply gain a divergent light-mode value, because it is still read as a FILL elsewhere in the app (`order_status_style.dart`, `transaction_badge.dart`) — darkening it for light-mode foreground use would have darkened those fills too.
- **(Orchestrator, `b6995c9`) The new status-pill success/error failure was filed as a todo, not fixed inline.** Tuning the new Part 8 test to admit a 2.91:1 pairing would have been the "unearned PASS" this project explicitly forbids; the correct fix (mirroring `statusWarningText` with `statusSuccessText`/`statusErrorText`) is scoped as follow-up work, not squeezed into this commit.

## Deviations from Plan

### Auto-fixed Issues

**1. [Rule 1 - Bug] `gw_button.dart` destructive variant failed WCAG AA in both modes**
- **Found during:** Task 2
- **Issue:** `background: gw.statusError` + `foreground: gw.textPrimary` measured 3.27:1 (dark, white on `#FF4D4D`) and 3.86:1 (light, ink on `#D92D2D`) — both below the 4.5:1 body-text floor. `gw.statusError` is a foreground/icon-tuned token, not a fill meant to carry text on top of it.
- **Fix:** Switched the fill to `gw.foundationError` (`#920000`, fixed, previously 0 call sites) with a documented fixed-white label; now 9.45:1 in both modes.
- **Files modified:** `lib/components/buttons/gw_button.dart`
- **Verification:** `test/theme/theme_contrast_test.dart#Part 6`, both modes; `23-03-CONTRAST.md`.
- **Committed in:** `bf9c0b6`

**2. [Rule 1 - Bug] `gw_button.dart` disabled-state alpha-replacement bug**
- **Found during:** Task 2 (auditing disabled state per the plan's own instruction)
- **Issue:** `.withAlpha(140)` REPLACES rather than scales the alpha channel, so a `Colors.transparent` background (alpha 0) jumped to alpha 140 (an opaque-ish black wash) on every disabled `secondary` button (the pre-existing `ghost`-only guard had missed it) and every disabled `gradientOutline` button.
- **Fix:** Gated the dim on `palette.background != Colors.transparent` instead of enumerating variant names one at a time.
- **Files modified:** `lib/components/buttons/gw_button.dart`
- **Verification:** `flutter analyze --no-pub`, full test suite green.
- **Committed in:** `bf9c0b6`

**3. [Rule 3 - Blocking] `badgeGlyphColor` signature change broke a test's compilation**
- **Found during:** Task 1 (residue closure — `transaction_badge.dart`'s no-context sites needed the function to accept a `GWColors gw`)
- **Issue:** `test/dashboard/transaction_badge_test.dart:27` called `badgeGlyphColor(spec.fill)` with the OLD one-argument signature, causing a compilation failure across the whole test run (`Too few positional arguments: 2 required, 1 given`).
- **Fix:** Updated the call site to `badgeGlyphColor(spec.fill, gw)`.
- **Files modified:** `test/dashboard/transaction_badge_test.dart`
- **Verification:** Full test suite green at 693 (pre-existing baseline) after the fix; re-confirmed at 705 after Tasks 2-3's new tests; re-confirmed at **707** after the orchestrator's two follow-up commits added Part 8 (2 more tests).
- **Committed in:** `954930e`

---

**Total deviations:** 3 auto-fixed by this execution (2 Rule 1 bugs, 1 Rule 3 blocking fix), plus 2 further Rule-1/Rule-2-class fixes by the orchestrator's follow-up commits (the amber-literal duplication, and the status-pill warning-label fill/foreground confusion) and 1 new pre-existing finding deliberately left open (status-pill success/error AA failure in light mode).
**Impact on plan:** All fixes were necessary for correctness — this execution's three were found while doing exactly what the plan asked (auditing every button state in both modes, and a residue-closing signature change); the orchestrator's two follow-ups corrected a shape defect in this execution's own fix (a raw hex duplicated past the Rule of Three) and closed two more consumers of the same bug class the fix's own doc comments had already predicted by name. No scope creep: the new pill success/error finding was filed as a todo rather than folded into this plan's scope.

### Raw-colour count is NOT final at this document's original count

This plan's own Task 2 fix for the toast/button amber problem was correct in
effect but introduced a fresh violation of `AGENTS.md`'s "no `Colors.*`/`Color(0x…)`
outside `lib/theme/`" rule: a hand-copied hex literal, duplicated past the
Rule of Three across four files. The first orchestrator follow-up
(`8d154b7`) fixed this by promoting the literal to `GWColors.statusWarningText`.
The second (`b6995c9`) found and fixed two more consumers of the SAME
underlying bug (`statusWarning` used as a foreground) that this plan's own
`gw_warning_note.dart` comment had already named by identity — and, in
verifying those fixes, discovered a NEW, unrelated pre-existing failure
(status-pill success/error labels also fail AA in light mode) that remains
open. Treat this plan's earlier "12 survivors, all documented" raw-colour
claim (Task 3, `lib/reown/` only) as accurate for that specific directory
and commit, not as a claim that the phase's colour surface is now fully
closed — see `23-03-CONTRAST.md`'s closing section for the same caveat
stated against the primary evidence.

## Issues Encountered

- **A bash quoting mistake corrupted one commit message.** The `bf9c0b6` commit message was passed through `git commit -m "..."` with unescaped backticks inside a double-quoted string, which bash interpreted as command substitution — several backtick-quoted terms (`secondary`, `ghost`, `gradientOutline`, `.withAlpha(140)`) were stripped from the final message. The commit's actual diff and effect are unaffected and fully described in this SUMMARY and in `23-03-CONTRAST.md`; per the "never amend, create new commits" rule this was not corrected via `--amend`. Later commits in this plan used `git commit -F <file>` to avoid the same failure mode.

## User Setup Required

None — no external service configuration required.

## Next Phase Readiness

- **23-04** (which demotes `GeniusWalletColors`' public members to private primitives) can now proceed with a near-empty residue: only `lib/main.dart:265` still reads the legacy static directly, with a recorded, deliberate reason — 23-04 should either add a narrow named accessor for it or leave it be, per its own scope.
- ~~The 4th occurrence of the light-mode amber workaround... is flagged in-place and is a strong candidate for promotion~~ — **done.** The orchestrator's follow-up commit `8d154b7` performed this promotion (`GWColors.statusWarningText`); no further action needed on this specific item.
- **New, open item for a future phase:** the status-pill success/error labels fail WCAG AA in light mode (2.91–3.89:1, both below the 4.5:1 floor and both `surfaceBase` figures below even 3:1) — pre-existing, discovered during the orchestrator's `b6995c9` follow-up, not fixed there. Filed at `.planning/todos/pending/2026-07-29-status-pill-success-error-fail-aa-in-light-mode.md` with the measured table and an upgrade path (`statusSuccessText`/`statusErrorText` mirroring `statusWarningText`). 23-04/23-05/23-06 should pick this up, or it should be triaged into a future milestone's requirements.
- **One verification gap, stated honestly:** the dApp connect flow's Allow/Approve buttons (`lib/reown/approve_dapp_connection_drawer.dart`, `approve_transaction_drawer.dart`) have no existing test harness reaching them (both need a live `ReownWalletKit`/`GeniusApi`), so their fix was verified by `flutter analyze`/`flutter test` plus a by-hand ratio table, not a widget test or a live device walk — this executor has no interactive device-control tool and the environment brief for this run prohibited spawning a new `flutter run`. This is the first thing to walk live before this plan is considered fully proven.
- **Gates as of the orchestrator's `b6995c9` (the current tip):** `flutter analyze --no-pub` → "No issues found!"; `tool/check_brace_style.sh --count` → 0; `dart format --output=none --set-exit-if-changed lib test` → exit 0; `flutter test --no-pub` → **707/0**. Re-confirmed independently by this executor at the same commit before writing this update.

---
*Phase: 23-design-system-consolidation-theme-tokens-shared-components*
*Completed: 2026-07-29*

## Self-Check: PASSED

All created/modified files confirmed present on disk (`toast_widget.dart`, `gw_button.dart`, `swap_settings_drawer.dart`, `23-03-CONTRAST.md`, `23-03-SUMMARY.md`). All six of this execution's task commits confirmed present in `git log --oneline --all` (`7c97670`, `3ae73f6`, `954930e`, `bf9c0b6`, `fb9294e`, `d14dc83`), plus the two orchestrator follow-up commits folded into this update (`8d154b7`, `b6995c9`). Full gate suite independently re-run by this executor at the current tip (`b6995c9`): `flutter analyze --no-pub` → "No issues found!"; `tool/check_brace_style.sh --count` → 0; `dart format --output=none --set-exit-if-changed lib test` → exit 0; `flutter test --no-pub` → 707/0 — matching the orchestrator's own quoted numbers exactly.

## Documentation-Update Addendum (this pass)

This SUMMARY and `23-03-CONTRAST.md` were updated after the fact to fold in
two orchestrator commits (`8d154b7`, `b6995c9`) that landed on top of this
plan's own work following Braian's acceptance. Per the orchestrator's
explicit instruction, **no code was changed in this pass** — only these two
documents. All gate numbers quoted above were independently re-verified by
this executor against the current tip, not merely copied from the
orchestrator's message.
