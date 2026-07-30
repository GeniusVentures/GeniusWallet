---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
plan: 01
subsystem: ui
tags: [flutter, drawers, design-system, gw-select-row, gw-detail-grid, gw-kicker]

requires: []
provides:
  - "GWDrawerStatusPill (lib/components/bottom_drawer/drawer_content.dart) - generic label+fg/bg pill, maps no enum"
  - "GWDrawerReceiptHead (lib/components/bottom_drawer/drawer_content.dart) - identity+amount+optional fiat/exact/pill, D-03 neutral amount"
  - "Mobile bottom-sheet coverage for the shell's kDrawerBodyPadding (test/components/drawer_body_padding_test.dart)"
  - "token_selector_drawer.dart's row inlined directly onto GWSelectRow (no _TokenRow wrapper)"
affects: [21-02, 21-03, 21-04, 21-05, 21-06]

tech-stack:
  added: []
  patterns:
    - "Receipt hero (identity/amount/fiat/exact/pill) as GWDrawerReceiptHead, ready for 21-03/21-04's five remaining receipts"
    - "Generic status pill (GWDrawerStatusPill) separates physical pill geometry from any status enum's colour mapping"

key-files:
  created:
    - lib/components/bottom_drawer/drawer_content.dart
    - test/components/drawer_body_padding_test.dart
    - test/components/drawer_content_test.dart
  modified:
    - lib/squid_router/token_selector_drawer.dart

key-decisions:
  - "GWDrawerListRow, GWDrawerSection and GWDrawerDetailRow were NOT built - GWSelectRow (sketch 068-A) and GWKicker+GWDetailGrid already do that job, already shipped (commits 8044bdb/bd501d7/d7903fc) and already adopted by more callers than this plan would have converted"
  - "The padded-body mechanism (Task 1) was NOT changed to the plan's padBody opt-in bool - the shell already ships bodyPadding with a default-padded, EdgeInsets.zero-to-opt-out design, which is the more robust resolution of the same 07-06 problem (a forgettable opt-in cannot regress; a forgettable opt-out cannot exist because it is the default)"
  - "GeniusWalletGradient.brandSelectionTint promotion was declined - GWSelectRow's own _selectionTint is still a true single consumer (nothing else needs this exact gradient), and its own doc comment already records that one-consumer reasoning; promoting it now would be pure churn with no second consumer to justify it"
  - "token_selector_drawer.dart's own horizontal fromLTRB padding on the search field and the ListView was KEPT, not removed - it is the correct, deliberate opt-out half of the shell's padding design (a scrolling body supplies its own inset so it scrolls with the content), not the ad-hoc padding the plan's Task 3 assumed still needed removing"

requirements-completed: []

coverage:
  - id: D1
    description: "The shell's shared padded body (kDrawerBodyPadding, opt-out via EdgeInsets.zero) lands the body's left edge on the title's axis, proven on both the desktop panel and the mobile bottom-sheet branch"
    verification:
      - kind: unit
        ref: "test/components/responsive_drawer_body_padding_test.dart#the shell insets the body by kDrawerBodyPadding (desktop, pre-existing)"
        status: pass
      - kind: unit
        ref: "test/components/drawer_body_padding_test.dart#the shell insets the body by kDrawerBodyPadding on the mobile sheet too"
        status: pass
      - kind: unit
        ref: "test/components/drawer_body_padding_test.dart#a mobile-sheet caller that passes nothing still gets the inset"
        status: pass
    human_judgment: false
  - id: D2
    description: "A drawer opened without opting into the shell's padding remains unchanged - the two BottomDrawer callers (sdk_account_manager.dart's old shape, design_gallery_screen.dart) cannot be double-padded"
    verification:
      - kind: unit
        ref: "test/components/responsive_drawer_body_padding_test.dart#a caller that passes nothing still gets the inset (proves the OPPOSITE direction is also covered: the shell's default is now padding-on, and EdgeInsets.zero is the documented, tested opt-out every scrolling/self-padding caller uses)"
        status: pass
    human_judgment: true
    rationale: "The mechanism the shell actually ships (default-padded, opt-out) inverts the plan's opt-in assumption; the automated tests prove the mechanism is internally consistent and non-double-padding for callers that opt out, but confirming that NO live BottomDrawer caller anywhere in the app was missed requires a human or a future full-repo grep pass this plan did not scope."
  - id: D3
    description: "A selected list row reads as a rounded gradient tint with a gradient check, never a square full-bleed fill or a vertical accent bar"
    verification:
      - kind: unit
        ref: "test/components/gw_select_row_test.dart#a selected row carries the check glyph, an unselected one does not (pre-existing, GWSelectRow = the plan's GWDrawerListRow)"
        status: pass
      - kind: unit
        ref: "test/components/gw_select_row_test.dart#selection is also the tint, so the row does not rely on the glyph alone (pre-existing)"
        status: pass
    human_judgment: false
  - id: D4
    description: "GWDrawerStatusPill and GWDrawerReceiptHead exist, are built from caller-supplied colours/slots only (no enum mapping, no derived amount colour, no fabricated placeholder for an omitted slot)"
    verification:
      - kind: unit
        ref: "test/components/drawer_content_test.dart#GWDrawerStatusPill renders the caller-supplied colours directly, not from an enum mapping"
        status: pass
      - kind: unit
        ref: "test/components/drawer_content_test.dart#GWDrawerReceiptHead an omitted fiat, exact and pill each render nothing at all"
        status: pass
      - kind: unit
        ref: "test/components/drawer_content_test.dart#GWDrawerReceiptHead a supplied fiat, exact and pill all render"
        status: pass
      - kind: unit
        ref: "test/components/drawer_content_test.dart#GWDrawerReceiptHead the amount colour is the caller's own value, never derived here"
        status: pass
    human_judgment: false
  - id: D5
    description: "The token picker looks and behaves exactly as before, but its row and its padding now come from the shared source instead of its own file"
    verification:
      - kind: unit
        ref: "test/squid_router/ (whole directory, no test file edited) - all pre-existing behavioural tests (empty-state, search suppression, selection identity) pass unchanged against the inlined GWSelectRow call"
        status: pass
    human_judgment: true
    rationale: "The plan's own success criterion for this deliverable is a VISUAL one (\"looks... exactly as it does today\") and this session has no app instance to run - see Outstanding Visual Verification below."

duration: ~50min
completed: 2026-07-30
status: complete
---

# Phase 21 Plan 01: Drawer shared primitives Summary

**Two new receipt primitives (`GWDrawerStatusPill`, `GWDrawerReceiptHead`) plus mobile-branch test coverage for an already-shipped padded-body shell — most of this plan's other deliverables were found already built, tested and adopted before execution began.**

## Performance

- **Duration:** ~50 min (PLAN_START_TIME capture was skipped at session start; this is an estimate from the session's own scope, not an instrumented timestamp delta)
- **Completed:** 2026-07-30T14:53:13Z
- **Tasks:** 3/3 (all re-scoped against the current codebase — see Deviations)
- **Files modified:** 4 (1 new component file, 2 new test files, 1 edited caller)

## IMPORTANT: this plan was substantially superseded before execution

Before writing any code, `21-01-PLAN.md` was checked against the actual working tree (branch
`ui-redesign-port`, HEAD `9345ed4`). Three commits authored directly by Jakub — **not** through
GSD, with no corresponding SUMMARY — had already shipped most of what this plan's Task 1 and
Task 2 describe, days before this plan was ever read:

| Commit | What it shipped | Plan artifact it supersedes |
|---|---|---|
| `8044bdb` (2026-07-28) | The shell owns the body+footer inset; the panel became a card | Task 1's "padded body, opt-in" |
| `bd501d7` (2026-07-27) | The settings-form archetype; the token picker got body padding, visible rows, selection | Task 3's "convert the reference caller" |
| `d7903fc` (2026-07-28) | `GWKicker`, `GWSelectRow`, `GWWarningNote`, `GWDetailGrid`, `GWStatTile` promoted from 4+ hand-rolled copies each | Task 2's `GWDrawerListRow`/`GWDrawerSection`/`GWDrawerDetailRow` |

Concretely, at the start of this execution:
- `ResponsiveDrawer.show()` already had a `bodyPadding` parameter defaulting to `kDrawerBodyPadding`
  (20/24/20/20, i.e. `space10`/`space12`/`space10`/`space10`), with `EdgeInsets.zero` as the documented
  opt-out for a scrolling body — the **opposite mechanism** from the plan's proposed opt-in `padBody`
  bool, but resolving the exact same 07-06 problem more robustly (a forgettable *opt-in* silently
  regresses; a forgettable *opt-out* cannot happen because padding is the default).
- `test/components/responsive_drawer_body_padding_test.dart` already existed and already passed,
  covering 3 of the plan's 4 required behaviours (desktop panel padded, default-not-omitted, and the
  close-glyph axis). It runs at the flutter_test default 800x600 surface, which is **above**
  `GeniusBreakpoints.medium` (768) — so it only ever exercises the desktop `showDialog` branch. The
  mobile `showModalBottomSheet` branch was never covered. That gap is this plan's one genuine,
  non-duplicate contribution to Task 1 (see below).
- `GWSelectRow` (`lib/components/cards/gw_select_row.dart`) already existed: sketch 068-A's promotion
  of the exact row this plan's Task 2 wanted to name `GWDrawerListRow`, already consumed by
  `network_dropdown_selector.dart`, `sdk_account_manager.dart`, `account_drawer.dart` and
  `token_selector_drawer.dart` — four consumers, not the one the plan expected to create. It already
  had its own test, `test/components/gw_select_row_test.dart`, covering exactly the "gradient tint +
  gradient check, no square fill, no accent bar" behaviour Task 2 asked `drawer_list_row_test.dart`
  to prove.
- `GWKicker` (`lib/components/cards/gw_kicker.dart`) + `GWDetailGrid`/`kGWDetailRowPadding`
  (`lib/components/cards/gw_detail_grid.dart`) already existed and were already wired into
  `transaction_displays.dart`'s `showTransactionDetails` — which already renders the TRANSACTION and
  NETWORK section cards this plan's read_first notes describe as still-defective
  (`_buildDetailsCard`'s vertical-only padding). That defect is **already fixed**, by a finer answer
  than the plan's own `GWDrawerSection` spec asked for: `GWDetailGrid`'s rows own their own
  horizontal+vertical inset so a tappable copy row's hit area matches its painted cell.

Given AGENTS.md's explicit house rules ("deletion over addition", "no abstractions that weren't
explicitly requested", Rule of Three), re-building three already-adopted, already-tested primitives
under new class names would have been the exact fragmentation D-02/D-04 exist to remove — not
"sharing", a second copy. Each task below was re-scoped to (a) verify the plan's must-have truths
hold against what is actually shipped, (b) build only the genuine gap, and (c) leave a clear paper
trail for 21-02 through 21-06, which will consume these files directly.

## Must-Have Truths — verdicts

1. **"A drawer opened with the shared padded body lands its content's left edge on the same
   vertical axis as the drawer title, on both the desktop panel and the mobile sheet."**
   **PASS.** Desktop: `responsive_drawer_body_padding_test.dart` (pre-existing). Mobile: this
   plan's new `test/components/drawer_body_padding_test.dart` — the genuine gap this plan closed.
2. **"A drawer opened WITHOUT the shared padded body is unchanged from today - callers that supply
   their own shell (BottomDrawer) cannot be double-padded."**
   **PASS, by the mechanism's inverse.** The shell now defaults to padded; a caller that needs to
   stay unpadded (a scrolling viewport, or a caller supplying its own `BottomDrawer` shell) opts out
   with `EdgeInsets.zero`, which is proven non-destructive by the existing test suite. No live
   `BottomDrawer` caller was found still double-rendering a shell inside `ResponsiveDrawer.show()` —
   `sdk_account_manager.dart` already migrated off `BottomDrawer` onto the shell's own title.
   `design_gallery_screen.dart` still imports `BottomDrawer`; not touched by this plan (dev-only
   gallery, out of this plan's file scope) and recorded as **OUTSTANDING** for a future pass, not a
   regression this plan introduced.
3. **"A selected row in a drawer list reads as a rounded gradient tint with a gradient check, never
   a square full-bleed fill and never with a vertical accent bar."**
   **PASS**, via `GWSelectRow` and its pre-existing `gw_select_row_test.dart`.
4. **"There is exactly one status pill and exactly one receipt head in the app, so the six receipts
   read as one family."**
   **PARTIAL / infrastructure only.** `GWDrawerStatusPill` and `GWDrawerReceiptHead` now exist and
   are tested (this plan's genuine new work), but have **zero consumers today** — `_statusPill` in
   `transaction_displays.dart` was deliberately left untouched (out of this task's `<files>` scope;
   wiring it in is 21-03/21-04's job per the plan's own artifact-consumer table) and the other five
   receipts (`swap_result_drawer.dart`, `buy_success_drawer.dart`, `buy_cancelled_drawer.dart`) are
   still on their pre-redesign styling (raw `Colors.*`, `ElevatedButton`). This plan is Wave 1: it
   built the primitive; it did not, and per its own `<files>` scope should not, convert those five.
5. **"The token picker looks and behaves exactly as it does today, but its row and its padding now
   come from the shared source instead of its own file."**
   **PASS for "shared source"** (the row is now `GWSelectRow`, inlined with no intermediate wrapper
   class). **OUTSTANDING for "looks exactly as before"** — that is a visual claim this session
   cannot observe; see below.

## Task Commits

Each task was committed atomically:

1. **Task 1 (re-scoped): mobile-branch test coverage for the already-shipped padded body** -
   `e108553` (test)
2. **Task 2 (re-scoped): GWDrawerStatusPill + GWDrawerReceiptHead only** - `e752fd4` (feat)
3. **Task 3 (re-scoped): inline `_TokenRow` into `GWSelectRow` directly, reword two padding
   comments** - `20b85c2` (refactor)

**Plan metadata:** (this commit, docs)

## Files Created/Modified

- `lib/components/bottom_drawer/drawer_content.dart` - NEW. `GWDrawerStatusPill` (generic pill,
  no enum) and `GWDrawerReceiptHead` (identity+amount+optional fiat/exact/pill, D-03-neutral
  amount colour). File head documents why the other three plan-named primitives are not here.
- `test/components/drawer_body_padding_test.dart` - NEW. Mobile bottom-sheet coverage for
  `kDrawerBodyPadding`, the one real gap in the pre-existing padding test suite.
- `test/components/drawer_content_test.dart` - NEW. Covers both new widgets: pill colours are
  caller-supplied not enum-derived; head's optional slots render nothing when omitted; amount
  colour is never derived.
- `lib/squid_router/token_selector_drawer.dart` - `_TokenRow` (a one-consumer wrapper around
  `GWSelectRow`) inlined directly into the `ListView.builder`'s `itemBuilder` and deleted; two
  comments justifying this file's own horizontal padding reworded to name the shell's opt-out
  mechanism instead of only the title-axis coincidence. No behavioural change: search, selection,
  `_maxRows`, `onTokenSelected` all untouched.

## Decisions Made

See `key-decisions` in frontmatter. In short: match the plan's *intent* (one shared primitive per
pattern, proven on a caller) rather than its *literal artifact names*, because the artifact names
were already taken by better, already-adopted implementations that shipped between when this plan
was written and when it was executed.

## Deviations from Plan

### Auto-fixed / Re-scoped Issues

**1. [Rule 4-adjacent - pre-existing architecture, not a change I made] Task 1's opt-in `padBody`
mechanism was not implemented; the codebase's own opt-out `bodyPadding` mechanism was verified
instead.**
- **Found during:** Task 1 read_first (reading `responsive_drawer.dart` before any edit)
- **Issue:** The plan's Task 1 assumed the shell had no default body inset yet. It already did,
  shipped by commit `8044bdb`, with different (and per its own commit message, deliberately
  more-robust) mechanics.
- **Fix:** No production code change. Added the missing mobile-branch test case instead of
  building a second, competing mechanism.
- **Files modified:** `test/components/drawer_body_padding_test.dart` (new)
- **Verification:** `flutter test test/components/drawer_body_padding_test.dart` — 2/2 pass.
- **Committed in:** `e108553`

**2. [Rule 4-adjacent] Task 2's `GWDrawerListRow`/`GWDrawerSection`/`GWDrawerDetailRow` were not
built.**
- **Found during:** Task 2 read_first
- **Issue:** All three already exist under different names (`GWSelectRow`; `GWKicker` +
  `GWDetailGrid`), shipped by `bd501d7`/`d7903fc`, already adopted by 4+ callers each, already
  tested. Building a second copy would violate AGENTS.md's Rule of Three and "deletion over
  addition" directly.
- **Fix:** Built only the two genuinely-missing primitives (`GWDrawerStatusPill`,
  `GWDrawerReceiptHead`). Declined the `brandSelectionTint` promotion for the same reason
  (`GWSelectRow`'s own doc comment already records the "one consumer" rationale, and that is still
  true — nothing outside `GWSelectRow` needs this gradient today).
- **Files modified:** `lib/components/bottom_drawer/drawer_content.dart`,
  `test/components/drawer_content_test.dart`
- **Verification:** `flutter test test/components/drawer_content_test.dart` — 4/4 pass;
  `flutter analyze` clean.
- **Committed in:** `e752fd4`

**3. [Rule 4-adjacent] Task 3's "remove ad-hoc horizontal padding" was declined; the padding was
kept.**
- **Found during:** Task 3 read_first
- **Issue:** The plan assumed the shell's new padding would make `token_selector_drawer.dart`'s own
  `fromLTRB` insets redundant. In the actually-shipped mechanism, this file **opts out** of the
  shell's padding (`bodyPadding: EdgeInsets.zero`) because it owns a scrolling viewport — exactly
  the documented escape hatch `responsive_drawer.dart` itself calls out ("the half of 07-06's
  prohibition that was right"). Removing this file's own horizontal inset would have reintroduced
  an edge-to-edge search field and list, a real visual regression.
- **Fix:** Kept the padding; only inlined `_TokenRow` and reworded the two comments that explain
  why the padding still lives here.
- **Files modified:** `lib/squid_router/token_selector_drawer.dart`
- **Verification:** `flutter analyze` clean; `flutter test test/squid_router/` — all pass, no test
  file edited.
- **Committed in:** `20b85c2`

---

**Total deviations:** 3, all of the same class (pre-existing shipped architecture superseding this
plan's stale assumptions, discovered before any code was written). **Impact on plan:** the intent
of every must-have truth was verified true (or explicitly marked PARTIAL/OUTSTANDING with a named
reason); no scope creep; no duplicate abstractions added.

## Issues Encountered

None beyond the supersession described above — no build errors, no flaky tests, no auth gates.

## Outstanding Visual Verification (recorded, not claimed)

This session has no running app instance (per this execution's own constraint — the orchestrator
owns `flutter run`). The following checks are genuinely visual and are recorded **OUTSTANDING**,
not PASS, per this project's standing no-unearned-PASS rule:

- [ ] Open the token picker (Swap tab → tap either token field) in both dark and light mode.
      Confirm: search field and rows sit inset from the panel edges (not edge-to-edge); a
      previously-selected token shows the rounded gradient tint + gradient check; an unselected
      token shows neither; scrolling the list does not reveal any gap or double-padding at top or
      bottom.
- [ ] Open any drawer that uses the shell's default padding (e.g. Swap Settings) and confirm the
      body's left edge visually lines up with the title's left edge, on both a wide (desktop-panel)
      window and a narrow (mobile-sheet) window.
- [ ] Confirm `lib/dev/design_gallery_screen.dart`'s remaining `BottomDrawer` usage (if any is still
      reachable from the gallery) is not double-padded when opened through `ResponsiveDrawer.show()`.

## Next Phase Readiness

- `GWDrawerStatusPill` and `GWDrawerReceiptHead` are built, tested and ready for 21-03/21-04 to wire
  into `showTransactionDetails` (replacing the inline hero + proving the pill against a real,
  already-correct four-state consumer) and the five remaining pre-redesign receipts.
- `GWSelectRow`, `GWKicker` and `GWDetailGrid` remain the canonical list-row and section/detail-row
  primitives for 21-02/21-03/21-04/21-05 — no new class names to migrate to; those plans should be
  read against the actual current file names (`GWSelectRow`, not `GWDrawerListRow`) rather than
  21-01-PLAN.md's original artifact table.
- **Recommend a quick pass over 21-02 through 21-06's plan files before executing them** — given how
  much of this phase's Wave 1 was already shipped ahead of GSD tracking, later waves' target files
  (network_dropdown_selector.dart, account dropdowns, bridge_screen.dart, coins_screen.dart, the six
  receipts) may also be further along than their plans assume. This plan's experience is the
  concrete evidence for that recommendation.

---
*Phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl*
*Completed: 2026-07-30*

## Self-Check: PASSED

- FOUND: `lib/components/bottom_drawer/drawer_content.dart`
- FOUND: `test/components/drawer_body_padding_test.dart`
- FOUND: `test/components/drawer_content_test.dart`
- FOUND: `lib/squid_router/token_selector_drawer.dart`
- FOUND commit: `e108553`
- FOUND commit: `e752fd4`
- FOUND commit: `20b85c2`
- Full suite: 732/732 passing (baseline 726/726 + 6 new tests). `flutter analyze` 0/0 (root +
  `packages/genius_api`). `check_brace_style.sh` / `check_raw_colors.sh` both 0. `check_no_new_key_logging.sh`
  and `check_onboarding_seed_safety.sh` both PASSED. `dart format --set-exit-if-changed` exit 0.
