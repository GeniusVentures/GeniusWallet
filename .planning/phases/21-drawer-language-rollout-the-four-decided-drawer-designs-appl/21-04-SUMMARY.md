---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
plan: 04
subsystem: ui
tags: [flutter, drawers, design-system, reown, signing, gw-detail-grid, gw-copy-row, gw-button, contract-test]

requires:
  - phase: 21-01
    provides: "gw_detail_grid.dart (GWDetailGrid, kGWDetailRowPadding), gw_copy_row.dart (GWCopyRow) -- already shipped, consumed directly"
provides:
  - "lib/reown/send_transaction_details.dart re-skinned onto one merged GWDetailGrid, borderless amount hero, static GWWarningNote caution"
  - "lib/reown/approve_transaction_drawer.dart / approve_dapp_connection_drawer.dart re-skinned onto borderless identity + GWButton footers (D-01/D-05/D-07/D-08)"
  - "test/reown/approve_drawer_contract_test.dart -- the first test coverage lib/reown/ has ever had: approve/reject/dismiss proven via real show() + real gestures, both drawers, both desktop and mobile branches"
affects: [21-05, 21-06]

tech-stack:
  added: []
  patterns:
    - "GWDetailGrid + GWCopyRow as the one merged Details card for a signing-path confirm body, matching the receipt family's own use of the same primitives (21-01/21-03)"
    - "flutter_test's built-in HttpOverrides (status 400, no real network) as the T-21-12 broken-icon test fixture -- no custom mock, no new package"

key-files:
  created:
    - test/reown/approve_drawer_contract_test.dart
  modified:
    - lib/reown/send_transaction_details.dart
    - lib/reown/approve_transaction_drawer.dart
    - lib/reown/approve_dapp_connection_drawer.dart

key-decisions:
  - "The 'sending-to' line is folded into the same GWDetailGrid as the fee rows rather than floated alone above it -- a lone borderless To row between the amount hero and the card read as an accidental leftover of the five-box layout being replaced. Recorded in send_transaction_details.dart's class doc, per the plan's own <output> instruction."
  - "GWWarningNote was NOT forked and was NOT given a borderless flag -- gw_warning_note.dart has a hard-coded Border.all(...) and no borderless mode. This file is its fourth consumer, which is normally the Rule-of-Three threshold, but AGENTS.md's own Rule of Three text names 'needs a boolean flag to serve both callers' as the specific case NOT to extract. The caution keeps its existing half-alpha border; upgrade path (a second NAMED constructor, not a bool) recorded in the file comment."
  - "Every Details-grid row (From/To/You send/You receive/Gas Fee/Max Fee Per Gas/Priority Fee) is now individually guarded with isNotEmpty, not just the already-nullable receiveTokenSymbol -- matches the plan's literal 'only when their source string is non-empty' instruction and is a Rule 2 defensive improvement (an upstream empty string can no longer render a blank grid row)."
  - "_PlainDetailRow built as a small StatelessWidget rather than a helper method, even though the plan's own text says it should match transaction_displays.dart's top-level _buildRow (a helper FUNCTION, not a method, but still not a widget) -- AGENTS.md's 'widgets, not helper methods' rule is stricter and takes precedence per this dispatch's CLAUDE.md-enforcement instruction."
  - "Test-file network mocking: no custom HttpOverrides was written. flutter_test's own AutomatedTestWidgetsFlutterBinding already installs a global HttpOverrides that fails every HttpClient request with a synthetic 400 and zero real network I/O (package:flutter_test/src/_binding_io.dart#_MockHttpOverrides) -- this is exactly the deterministic Image.network failure T-21-12's test needed, for free, with no new package and no new mock class."
requirements-completed: []

coverage:
  - id: D1
    description: "Approving returns exactly what it returns today (true). Rejecting returns exactly what it returns today (false). Dismissing without choosing returns exactly what it returns today (null). All six outcomes (both drawers) are asserted through the real show() with a real gesture, on both the desktop panel and the mobile sheet."
    verification:
      - kind: unit
        ref: "test/reown/approve_drawer_contract_test.dart -- 12 gesture-driven cases (approve/reject/dismiss x {desktop, mobile} x {ApproveTransactionDrawer, ApproveDappConnectionDrawer})"
        status: pass
    human_judgment: false
  - id: D2
    description: "Every value the transaction drawer displays -- amount, sender, recipient, gas fee, max fee per gas, priority fee, receive symbol -- is the same string it displays today, character for character. Nothing in these three files parses, formats or computes."
    verification:
      - kind: unit
        ref: "test/reown/approve_drawer_contract_test.dart#Case 5: every one of the seven SendTransactionDetails strings is findable on screen, unmodified"
        status: pass
      - kind: unit
        ref: "test/reown/approve_drawer_contract_test.dart#Case 6: no fiat figure and no computed total appears -- only the four numeric fields actually passed in"
        status: pass
    human_judgment: false
  - id: D3
    description: "The two confirm drawers show one merged Details card instead of five separate boxes, with a borderless dApp identity, a borderless amount hero and a borderless sending-to line."
    verification:
      - kind: other
        ref: "grep -c 'GWDetailGrid' lib/reown/send_transaction_details.dart == 2 (import + one call); grep -c 'deepBlueCardColor' == 0; flutter analyze 0 issues"
        status: pass
    human_judgment: true
    rationale: "The composition is proven by construction (one GWDetailGrid call, zero legacy card literals) and by the contract test's string-presence assertions, but whether it actually READS as one calm card rather than five boxes is a visual judgment this session cannot make -- no live app instance. See Outstanding Visual Verification."
  - id: D4
    description: "The caution is static copy. It claims nothing the data cannot back, and no fiat figure appears that is not wired."
    verification:
      - kind: unit
        ref: "test/reown/approve_drawer_contract_test.dart#Case 6 (the '$' guard)"
        status: pass
      - kind: other
        ref: "manual read of send_transaction_details.dart's GWWarningNote call -- the literal sketch copy, no dynamic 'new address' claim, no fiat marker rendered at all (033's `*` is dropped per this plan's own constraint, not kept as an unimplemented marker)"
        status: pass
    human_judgment: false
  - id: D5
    description: "Reject and Approve (Deny and Allow) do not read as equally affirmative. The negative control is not a filled accent."
    verification:
      - kind: other
        ref: "grep -c 'GWButtonVariant.gradient\\b' vs 'GWButtonVariant.gradientOutline' across both drawer files -- affirmative is gradient (filled), negative is gradientOutline (transparent fill + gradient border), never the reverse"
        status: pass
    human_judgment: true
    rationale: "Whether the two buttons actually READ as different weights on screen -- the phase's own flagged open question (drawers-final/README.md: 'Reject gets the gradient outline for consistency ... if it should read cooler, that is a separate decision') -- requires a live look, not a grep. Recorded as an explicit human-check item, not resolved here."

duration: ~25min
completed: 2026-07-30
status: complete
---

# Phase 21 Plan 04: Signing drawers -- 033-B1 confirm re-skin + behavioural-identity proof Summary

**The two dApp signing drawers re-skinned onto 033-B1 (borderless identity, one merged Details card, `GWButton` footers) with a new contract test proving all six approve/reject/dismiss outcomes on both drawers survive the chrome change, byte-identical to HEAD.**

## Performance

- **Duration:** ~25 min (estimate from git commit timestamps 13:13:24 -> 13:24:34 plus the read/verification phase before the first commit; `PLAN_START_TIME` was not captured with an instrumented epoch call at session start)
- **Completed:** 2026-07-30T16:24:34Z (last task commit) / SUMMARY written same session
- **Tasks:** 3/3
- **Files modified:** 4 (3 re-skinned, 1 new test file)

## Accomplishments

- `send_transaction_details.dart` rebuilt: the five separate boxes (bordered From box, bordered To box, the amount hero, an "Estimated changes" caption, a `deepBlueCardColor` fee card) collapsed to a borderless neutral amount hero, the static `GWWarningNote` caution, and **one** `GWDetailGrid` holding From/To (`GWCopyRow`) plus the five fee/amount rows. Both appearance-blind literals (`deepBlueCardColor`, fixed `Colors.white70`/`Colors.white`) are gone. The class's 7 fields are unchanged in name, type and order.
- Both `approve_transaction_drawer.dart` and `approve_dapp_connection_drawer.dart`: the bordered/padding-only identity `Container` is gone, replaced by a borderless favicon+text row with a `gw.borderSubtle` hairline underneath. `OutlinedButton`s replaced by `GWButton` (gradient / gradientOutline, size `lg`). The connection drawer's question sentence moved from the footer into the body with `maxLines: 2` (T-21-13). Both `show()` signatures and both `pop(true)`/`pop(false)` argument values are byte-identical to HEAD -- verified by diffing the pre-change and post-change files directly (not just `git diff`), see Verification below.
- `test/reown/approve_drawer_contract_test.dart` -- the first test file `lib/reown/` has ever had. 14 cases: 12 gesture-driven approve/reject/dismiss outcomes (both drawers x both desktop/mobile branches), plus the two data-integrity cases (all seven `SendTransactionDetails` strings reach the screen unmodified; no fiat figure or computed total appears).
- A real bug was found and fixed while writing the test (Rule 1, not a deviation from the plan's design intent): removing the zero-inset `Padding` wrapper in `approve_transaction_drawer.dart` also removed the `Column` that gave the pre-existing `Flexible(child: content)` its required Flex ancestor. `ListView.children` is a sliver list, not a Flex, so the very first test run threw `Incorrect use of ParentDataWidget`. Fixed by re-wrapping the identity/hairline/content in a `Column(mainAxisSize: MainAxisSize.min, ...)` -- the Padding stays deleted (no no-op inset reintroduced), the Flexible's ancestor is restored.

## Must-Have Truths -- verdicts

1. **"Approving/Rejecting/Dismissing return exactly what they return today, on both drawers, real `show()` + real gesture."** **PASS**, automated -- 12 cases in `approve_drawer_contract_test.dart` (approve/reject/dismiss x {desktop, mobile} x {transaction, connection} drawers). Dismiss cases assert `null` distinctly from `false` via a settled/value pair, not a single nullable field.
2. **"Every displayed value is the same string, character for character. No arithmetic, parsing or formatting in these three files."** **PASS** -- Case 5 proves all seven `SendTransactionDetails` fields reach the screen unmodified (fixture addresses kept <=12 chars so `GWCopyRow`'s truncation never triggers, so "unmodified" is literally checkable). No `+`, `*`, `/`, `num.parse`, `toStringAsFixed` or similar exists anywhere in the three files -- confirmed by reading the final file content, not just diffing it.
3. **"One merged Details card instead of five boxes, borderless identity/hero/sending-to."** **PASS by construction** (grep-verified: one `GWDetailGrid` call, zero `deepBlueCardColor`/bordered-`Container` identity). Visual "reads as calm, not five boxes" is **OUTSTANDING** (no live app instance).
4. **"The caution is static, unbacked claims stay out, no fiat renders."** **PASS** -- the literal sketch copy is unchanged from the plan text; Case 6 asserts no `$` anywhere in the transaction drawer's tree.
5. **"Reject/Approve are not equally affirmative."** **PASS at the component level** (gradient vs gradientOutline, never the reverse, on both drawers). Whether it reads that way on screen is **OUTSTANDING** -- this is `drawers-final/README.md`'s own flagged open question, not resolved here.

## Task Commits

Each task was committed atomically (sequential executor, per this dispatch's override of the plan's own "Do not commit" text -- see Deviations):

1. **Task 1: the confirm body -- borderless hero, one merged Details card (D-05)** -- `af1f5f5` (feat)
2. **Task 2: the two confirm shells -- identity, inset, buttons (D-01/D-05/D-07/D-08)** -- `e56b9a3` (feat)
3. **Task 3: the behavioural-identity proof** -- `0fa14c9` (test) -- also carries the Rule 1 `Flexible`-ancestor fix and `dart format`'s own whitespace pass over Task 1's file

**Plan metadata:** (this commit, docs)

## Files Created/Modified

- `lib/reown/send_transaction_details.dart` -- rebuilt on `GWDetailGrid`/`GWCopyRow`/`GWKicker`/`GWWarningNote`; `_labeledBox`/`_fieldRow` helper methods and the `deepBlueCardColor` card deleted; `_PlainDetailRow` (a `StatelessWidget`, not a helper method) replaces the plain fee rows. Class doc records the "sending-to line folded into the grid" and "GWWarningNote not forked" decisions.
- `lib/reown/approve_transaction_drawer.dart` -- bordered identity `Container` deleted, replaced by a borderless Row + hairline inside a `Column` (restoring the `Flexible`'s Flex ancestor after the zero-inset `Padding` was removed); footer `OutlinedButton`s replaced by `GWButton`.
- `lib/reown/approve_dapp_connection_drawer.dart` -- bordered-looking-but-actually-padding-only `Container` deleted, replaced the same way; question sentence moved from footer to body with `maxLines: 2`; footer buttons replaced by `GWButton`.
- `test/reown/approve_drawer_contract_test.dart` -- NEW. 14 `testWidgets` cases across 6 groups.

## Decisions Made

See `key-decisions` in frontmatter.

## Deviations from Plan

### Dispatch override (not a Rule 1-4 deviation)

**Committed each task, against the plan's own "Do not commit" text.** `21-04-PLAN.md`'s `<constraints>` say "Do not commit. Leave every change in the working tree. Wave 1 runs four plans in parallel against one git index." This execution's dispatch explicitly overrides that: I am the sole sequential executor on this branch, not one of four parallel agents. Each task was committed individually, hooks on, no `--no-verify` -- matching 21-03's own precedent for the identical situation.

### Auto-fixed Issues

**1. [Rule 1 -- bug found by writing the required test] `approve_transaction_drawer.dart`'s `Flexible(child: content)` had no Flex ancestor after the zero-inset `Padding` was deleted.**
- **Found during:** Task 3, first test run (`flutter test test/reown/approve_drawer_contract_test.dart`).
- **Issue:** Task 2 deleted the `Padding(padding: EdgeInsets.zero, child: Column(...))` wrapper per the plan's literal instruction ("a zero-inset Padding is a no-op ... delete it"), but the surrounding `Column` was the ONLY thing giving the pre-existing `Flexible(fit: FlexFit.loose, child: content)` a valid Flex ancestor. Flattened into a bare `ListView.children` list (a sliver list, not a Flex), the very first widget pump threw `Incorrect use of ParentDataWidget: The ParentDataWidget Flexible(flex: 1) wants to apply ParentData of type FlexParentData to a RenderObject, which has been set up to accept ParentData of incompatible type ParentData.`
- **Fix:** Re-wrapped the identity Row, hairline and `Flexible(content)` in a `Column(mainAxisSize: MainAxisSize.min, ...)` as the ListView's single child. The zero-inset `Padding` stays deleted (satisfying the plan's actual intent -- no no-op inset); the `Flexible` keeps rendering `content` verbatim, satisfying the plan's other instruction that it "stays" untouched.
- **Files modified:** `lib/reown/approve_transaction_drawer.dart`.
- **Verification:** `flutter test test/reown/approve_drawer_contract_test.dart` -- 14/14 pass after the fix (all 8 failures beforehand were this exact exception, one per test that opened `ApproveTransactionDrawer` with a `SendTransactionDetails` content).
- **Committed in:** `0fa14c9` (folded into the Task 3 commit, since it was found while writing Task 3's required test, not as a separate task).

---

**Total deviations:** 1 dispatch-authorized process override (commit-per-task, matching 21-03's precedent) + 1 Rule-1 runtime bug found and fixed by the plan's own required test. **Impact on plan:** neither changes any must-have truth's verdict; the Rule 1 fix is exactly the kind of thing this plan's contract test exists to catch, and it caught something in THIS plan's own re-skin rather than a pre-existing defect.

## Issues Encountered

None beyond the deviation above -- no auth gates, no package-manager installs, no flaky tests.

## Verification (evidence quoted, not asserted)

```
flutter analyze --no-pub                        -> 0 issues, exit 0
(cd packages/genius_api && flutter analyze --no-pub) -> 0 issues, exit 0
flutter test --no-pub                            -> 754/754 passing, 0 failing (740 baseline + 14 new)
bash tool/check_brace_style.sh                   -> exit 0
bash tool/check_raw_colors.sh                    -> exit 0
bash tool/check_no_new_key_logging.sh --scan-tree -> OK
bash tool/check_onboarding_seed_safety.sh        -> PASSED (all 6 Section 3 checks)
dart format --set-exit-if-changed lib test       -> exit 0 (345 files, 0 changed)
git diff --stat -- lib/reown/handle_dapp_requests.dart lib/reown/reown_connect_button.dart -> empty
```

**Signing-contract verification (the plan's own required evidence):** both `show()` signatures and both `pop(true)`/`pop(false)` argument values were diffed directly against the pre-change file content (not merely `git diff`, to catch a reformat that happened to preserve semantics by accident) -- byte-identical in both drawers, only line numbers shifted.

## No new logging

`grep -n "debugPrint\|print(\|log("` across all three modified `lib/` files and the new test file returns nothing. No request payload, URI, address-with-context or signing data is logged anywhere this plan touched.

## Outstanding Visual Verification (recorded, not claimed)

This session has no running app instance (the orchestrator owns `flutter run`). The following are recorded **OUTSTANDING**, not PASS, per this project's standing no-unearned-PASS rule -- verbatim from the plan's `<human_verification>`:

- [ ] Dev bubble -> **Connection Request**. Dark mode: the dApp favicon, name and url sit borderless with one hairline under them; no pill, no box. The question sentence is in the body, not stacked above the buttons.
- [ ] Dev bubble -> **Transaction Request**. One Details card, not five boxes. The amount hero is large, centred and **neutral** -- not green, not red, not brand. The caution reads as generic advice and claims nothing specific.
- [ ] On both: `Approve`/`Allow` is a filled gradient and `Reject`/`Deny` is a gradient outline. **Look at them for two seconds and answer honestly: do they read as equally affirmative?** `drawers-final/README.md` flagged this as open. If the negative still reads as a recommendation, say so -- that is a decision to make, not a bug to hide.
- [ ] Tap the `To` row on the transaction drawer. Paste: the **full** address must arrive, not the truncated display form.
- [ ] Feed a deliberately long dApp name (a few hundred characters) through the dev fixture. Neither drawer's buttons may be pushed off screen or below the fold; the name must ellipsise.
- [ ] Feed a broken `iconUrl`. Nothing must render in the icon's place -- no broken-image glyph, no oversized box, no layout shift.
- [ ] Repeat the first three in **light** mode.
- [ ] Narrow the window below 768 so both become bottom sheets and re-check that the buttons are reachable and the body scrolls.

## Next Phase Readiness

- `lib/reown/` now has a standing behavioural contract test (`test/reown/approve_drawer_contract_test.dart`) that any future re-skin or refactor of these two drawers must keep passing -- the todo filed 2026-07-30 (`2026-07-30-lib-reown-has-zero-tests.md`) is substantially addressed for the signing-decision surface specifically, though the file's other ~1,300 lines (session handling, request routing) remain untested.
- `GWDetailGrid`/`GWCopyRow` now have a fourth and fifth call site respectively (after the transaction receipt, the Reown swap result, and both Banxa results), reinforcing them as the app's one shared detail-grid vocabulary ahead of 21-05/21-06.
- The negative-control legibility question (T-21-18, drawers-final's own flagged item) is still open and now has two more affected drawers riding on its eventual answer.

---
*Phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl*
*Completed: 2026-07-30*

## Self-Check: PASSED

- FOUND: `lib/reown/send_transaction_details.dart`
- FOUND: `lib/reown/approve_transaction_drawer.dart`
- FOUND: `lib/reown/approve_dapp_connection_drawer.dart`
- FOUND: `test/reown/approve_drawer_contract_test.dart`
- FOUND commit: `af1f5f5`
- FOUND commit: `e56b9a3`
- FOUND commit: `0fa14c9`
- `flutter analyze --no-pub` root: 0 issues, exit 0. `packages/genius_api`: 0 issues, exit 0.
- `flutter test --no-pub`: 754/754 passing (740 baseline + 14 new), 0 failing.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0. `bash tool/check_no_new_key_logging.sh --scan-tree`: OK. `bash tool/check_onboarding_seed_safety.sh`: PASSED.
- `dart format --set-exit-if-changed lib test`: exit 0 (345 files, 0 changed).
- `git diff --stat -- lib/reown/handle_dapp_requests.dart lib/reown/reown_connect_button.dart`: empty -- both callers byte-identical to HEAD.
