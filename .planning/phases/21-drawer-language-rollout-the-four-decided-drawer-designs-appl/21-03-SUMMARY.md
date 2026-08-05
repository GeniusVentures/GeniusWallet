---
phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl
plan: 03
subsystem: ui
tags: [flutter, drawers, design-system, gw-drawer-receipt-head, gw-drawer-status-pill, tx-status-colors, banxa, reown]

requires:
  - phase: 21-01
    provides: "GWDrawerStatusPill and GWDrawerReceiptHead (lib/components/bottom_drawer/drawer_content.dart)"
provides:
  - "GWDrawerReceiptHead with optional amount/amountColor (an omittable slot, not a mode flag)"
  - "lib/reown/swap_result_drawer.dart re-skinned onto the shared receipt vocabulary"
  - "lib/banxa/banxa_components/buy_success_drawer(_content).dart and buy_cancelled_drawer(_content).dart re-skinned onto the shared receipt vocabulary"
  - "test/components/result_receipt_family_test.dart -- the D-02/D-03 family check"
  - "tool/check_raw_colors.sh COVERED_DIRS += lib/banxa/banxa_components (standing gate)"
affects: [21-04, 21-05, 21-06]

tech-stack:
  added: []
  patterns:
    - "txStatusColors as the single status-colour source for every non-transaction receipt (Reown swap result, both Banxa results), matching the transaction receipt's own pill"
    - "GWDrawerReceiptHead's amount/amountColor as an omittable slot (String?/Color?) rather than a hasAmount boolean flag, with a constructor assert enforcing amountColor whenever amount is present"

key-files:
  created:
    - test/components/result_receipt_family_test.dart
  modified:
    - lib/components/bottom_drawer/drawer_content.dart
    - lib/reown/swap_result_drawer.dart
    - lib/banxa/banxa_components/buy_success_drawer.dart
    - lib/banxa/banxa_components/buy_success_drawer_content.dart
    - lib/banxa/banxa_components/buy_cancelled_drawer.dart
    - lib/banxa/banxa_components/buy_cancelled_drawer_content.dart
    - test/components/drawer_content_test.dart
    - tool/check_raw_colors.sh

key-decisions:
  - "Sequential-executor override, per orchestrator dispatch: the plan's own <constraints> say 'Do not commit -- Wave 1 runs four plans in parallel against one git index.' This dispatch explicitly overrides that -- I am the sequential executor for this plan and I DO commit, one commit per task, normal hooks on. No `--no-verify`. This is a deviation FROM THE PLAN TEXT, not from GSD's own execution contract, and it is recorded here because the plan's own words say the opposite."
  - "BuySuccessDrawerContent/BuyCancelledDrawerContent stay `const` -- the plan's action text says they 'cannot stay const,' reasoning that a const widget is the same defect class as a widget that never re-skins. That premise does not hold: `Theme.of(context)` registers a live InheritedWidget dependency on the Element every time `build()` runs, regardless of whether the widget instance was created via a `const` constructor. The actual defect in the shipped code was that it never called `Theme.of(context)` at all (fixed literal `Colors.greenAccent`/`Colors.redAccent`), not that the constructor was `const`. Kept `const` after `flutter analyze` flagged its removal as `prefer_const_constructors_in_immutables` (an info, which this repo's baseline treats as a failing exit code) -- fixing the analyzer regression is a stronger signal than an imprecise plan sentence, and the underlying re-skin correctness (live GWColors read in build()) is unchanged either way."
  - "Reworded the swap-result / Banxa footer button fix as 'pop the drawer, then invoke onClose if present' exactly as instructed -- Navigator.of(context).pop() is called directly rather than routing through any dismiss helper, since ResponsiveDrawer.show() opens via bare showDialog/showModalBottomSheet and the existing header close (X) button already uses the same Navigator.of(context).pop pattern."

requirements-completed: []

coverage:
  - id: D1
    description: "The three remaining result drawers (Reown swap result, Banxa success, Banxa cancelled) render the same GWDrawerReceiptHead/GWDrawerStatusPill as the transaction receipt -- same gap rhythm, same centring, same pill geometry"
    verification:
      - kind: unit
        ref: "test/components/result_receipt_family_test.dart#a success result renders a pill whose foreground is the SAME colour txStatusColors(completed) returns"
        status: pass
      - kind: unit
        ref: "test/components/result_receipt_family_test.dart#a result drawer with no amount renders no numeric headline at all"
        status: pass
    human_judgment: true
    rationale: "The family test pins the composition and the palette source with widgets, not the three real files. Whether the three ACTUAL drawers read as visually one family with the transaction receipt is the phase's own headline claim and requires a live app instance this session does not have -- see Outstanding Visual Verification below."
  - id: D2
    description: "Every status colour in these three drawers comes from txStatusColors -- the same function the transaction receipt's pill and Status row already share. Cancelled is slate, not red."
    verification:
      - kind: unit
        ref: "test/components/result_receipt_family_test.dart#a cancelled result's pill reads slate, not the error colour"
        status: pass
      - kind: unit
        ref: "test/components/result_receipt_family_test.dart#the D-03 guard: in a failed result, no text in the subtree is painted in the status colour except the pill's own label"
        status: pass
    human_judgment: false
  - id: D3
    description: "No amount, order number, payment method or fiat figure appears in any of the three drawers that the drawer's own API does not carry -- GWDrawerReceiptHead.amount is omitted entirely, never fabricated"
    verification:
      - kind: unit
        ref: "test/components/drawer_content_test.dart#an omitted amount renders no amount text at all (21-03)"
        status: pass
    human_judgment: false
  - id: D4
    description: "Every button in these three drawers is a GWButton -- filled gradient for the primary action, gradient outline for a secondary one. No raw accent-coloured Material button survives."
    verification:
      - kind: other
        ref: "grep -c 'GWButton' across the three drawer files (manual, not test-automated) -- swap_result_drawer.dart, buy_success_drawer.dart, buy_cancelled_drawer.dart all use GWButton exclusively; flutter analyze finds no ElevatedButton/OutlinedButton import remaining"
        status: pass
    human_judgment: false
  - id: D5
    description: "lib/banxa/banxa_components/ holds zero appearance-blind colour literals and is added to the standing CI gate, so it cannot regress"
    verification:
      - kind: other
        ref: "bash tool/check_raw_colors.sh (full run, exit 0) and bash tool/check_raw_colors.sh --self-test (exit 0)"
        status: pass
    human_judgment: false

duration: ~55min (estimate -- PLAN_START_TIME was not captured at session start; derived from the session's own task scope)
completed: 2026-07-30
status: complete
---

# Phase 21 Plan 03: Result receipt rollout Summary

**The three remaining result drawers (Reown swap result, both Banxa purchase outcomes) re-skinned onto 21-01's `GWDrawerReceiptHead`/`GWDrawerStatusPill`, coloured from one shared `txStatusColors` source, with `GWDrawerReceiptHead`'s amount made an omittable slot rather than forcing three receipts to fabricate one.**

## Performance

- **Duration:** ~55 min (estimate; PLAN_START_TIME capture was skipped at session start, matching the same gap 21-01-SUMMARY.md recorded)
- **Completed:** 2026-07-30T16:02:00Z
- **Tasks:** 4/4
- **Files modified:** 8 (1 primitive extended, 1 new test file, 6 files re-skinned, 1 CI gate script extended)

## Accomplishments

- `GWDrawerReceiptHead.amount`/`amountColor` are now `String?`/`Color?`, omitted entirely when null (never a placeholder, never a fabricated zero) — the slot three of the six D-02 receipts genuinely need, since none of their APIs carries an amount.
- `lib/reown/swap_result_drawer.dart` rebuilt on the shared vocabulary: one status-colour source (`txStatusColors`), the `deepBlueMenu` hash card replaced by a `GWCopyRow` inside a `GWDetailGrid`, both footer buttons now `GWButton`. Signature and both call sites (`handle_dapp_requests.dart`, `dev_tools_bubble.dart`) are byte-identical to HEAD.
- Both Banxa result drawers (`buy_success_drawer(_content).dart`, `buy_cancelled_drawer(_content).dart`) rebuilt the same way. Cancelled now reads slate, not red. Titles corrected to "Purchase complete"/"Purchase cancelled" (066-B's named defect). Two dead-button bugs fixed: success's onClose-only handler and cancelled's empty `onPressed` block now both actually close the drawer.
- `test/components/result_receipt_family_test.dart` pins the palette SOURCE (not a re-derived hex) and the D-03 guard (no text besides the pill's own label takes the status colour) against the exact composition Tasks 2/3 build.
- `tool/check_raw_colors.sh`'s `COVERED_DIRS` gains `lib/banxa/banxa_components`, measured at 0 offenders after Task 3, confirmed by running the gate against that directory BEFORE editing the array.

## Must-Have Truths — verdicts

1. **"The three remaining result drawers render the same head as the transaction receipt."** **PASS** by construction — all three now call `GWDrawerReceiptHead`/`GWDrawerStatusPill` directly, the same classes `transaction_displays.dart` would consume if it were migrated (it is deliberately not, per this plan's own constraints). Visual "reads as one family" verdict is **OUTSTANDING** (no live app instance this session) — see below.
2. **"Every status colour comes from `txStatusColors`. Cancelled is slate, not red."** **PASS**, automated: `result_receipt_family_test.dart`'s first three cases.
3. **"No amount, order number, payment method or fiat figure appears that the drawer's own API does not carry."** **PASS**. `amount` is never passed to any of the three `GWDrawerReceiptHead` call sites in this plan; `drawer_content_test.dart`'s new case proves the omitted slot renders nothing.
4. **"Every button in these three drawers is a `GWButton`."** **PASS** — `ElevatedButton`/`OutlinedButton` are gone from all three files; `flutter analyze` and a manual grep both confirm zero raw Material buttons remain.
5. **"`lib/banxa/banxa_components/` holds zero appearance-blind colour literals and is added to the standing CI gate."** **PASS** — `check_raw_colors.sh` (full run) and its `--self-test` both exit 0 with the directory now in scope.

## Task Commits

Each task was committed atomically (sequential executor, per this dispatch's override of the plan's "Do not commit" text — see Deviations):

1. **Task 1: `GWDrawerReceiptHead` learns that a result may have no amount** — `c082475` (feat)
2. **Task 2: the Reown swap result becomes a 031-B1 receipt** — `aaae508` (feat)
3. **Task 3: the two Banxa result receipts** — `5d8da5f` (feat)
4. **Task 4: the family check, and a standing gate over the Banxa half** — `30e8c38` (test)

**Plan metadata:** (this commit, docs)

## Files Created/Modified

- `lib/components/bottom_drawer/drawer_content.dart` — `GWDrawerReceiptHead.amount`/`amountColor` made `String?`/`Color?`, wrapped in an `if (amount != null)` block matching `fiat`/`exact`/`pill`; constructor assert enforces `amountColor` whenever `amount` is supplied; class doc extended with the measured reason (three of six receipts carry no amount) and the rejected alternative (forcing a fabricated figure).
- `lib/reown/swap_result_drawer.dart` — rebuilt body/footer on `GWDrawerReceiptHead`/`GWDrawerStatusPill`/`txStatusColors`/`GWCopyRow`/`GWDetailGrid`/`GWKicker`/`GWButton`. `deepBlueMenu` card and the duplicated coloured headline deleted.
- `lib/banxa/banxa_components/buy_success_drawer.dart` — title → "Purchase complete"; footer → `GWButton(variant: gradient)`; `onPressed` now pops the drawer, then calls `onClose` if supplied.
- `lib/banxa/banxa_components/buy_success_drawer_content.dart` — `GWDrawerReceiptHead` + `GWDrawerStatusPill` colour from `txStatusColors(completed)`; live `GWColors` read added; bold headline `Text` deleted (title carries it now).
- `lib/banxa/banxa_components/buy_cancelled_drawer.dart` — title → "Purchase cancelled"; footer → `GWButton(variant: gradientOutline)`; `onPressed` now actually pops the drawer (was an empty block).
- `lib/banxa/banxa_components/buy_cancelled_drawer_content.dart` — `GWDrawerReceiptHead` + `GWDrawerStatusPill` colour from `txStatusColors(cancelled)` (slate); glyph changed `Icons.cancel` → `Icons.cancel_outlined`; live `GWColors` read added.
- `test/components/drawer_content_test.dart` — two new cases for the omitted/supplied amount slot.
- `test/components/result_receipt_family_test.dart` — NEW. Four cases: palette-source pin, cancelled-is-slate, the D-03 text-walk guard, no-amount-no-headline.
- `tool/check_raw_colors.sh` — `COVERED_DIRS += "lib/banxa/banxa_components"`, with an inline comment naming this plan and recording why `lib/reown` stays out.

## Decisions Made

See `key-decisions` in frontmatter. In short: (1) this dispatch's sequential-executor instructions override the plan text's "Do not commit," and each task is committed individually, hooks on; (2) the two Banxa content widgets stay `const` because `flutter analyze`'s `prefer_const_constructors_in_immutables` info counts as a failing baseline in this repo, and keeping `const` does not compromise the live re-skin (which comes from the `Theme.of(context)` read inside `build()`, not from constructor constness).

## Deviations from Plan

### Auto-fixed Issues

**1. [Dispatch override, not a Rule 1-4 deviation] Committed each task, against the plan's own "Do not commit" text.**
- **Found during:** reading the plan before Task 1.
- **Issue:** `21-03-PLAN.md`'s `<constraints>` say "Do not commit. Leave every change in the working tree. Wave 1 runs four plans in parallel against one git index." This dispatch's own `<sequential_execution>` block explicitly overrides that: I am the sole sequential executor for this plan on this branch, not one of four parallel agents.
- **Fix:** Committed each task individually with normal hooks on, no `--no-verify`, as instructed by the dispatch.
- **Files modified:** all task files, per their own commits.
- **Committed in:** `c082475`, `aaae508`, `5d8da5f`, `30e8c38`.

**2. [Rule 1 — analyzer regression] Kept `BuySuccessDrawerContent`/`BuyCancelledDrawerContent` as `const`, against the plan's literal "they cannot stay const" instruction.**
- **Found during:** Task 3, first `flutter analyze` pass.
- **Issue:** Removing `const` from both constructors (as the plan's action text instructed) tripped `prefer_const_constructors_in_immutables` (an info-level lint), and this repo's baseline treats `flutter analyze` exiting non-zero on infos as a real failure — the environment notes explicitly warn against trusting the tail line over the real exit code.
- **Fix:** Restored `const` on both constructors. The underlying goal (a widget that actually re-skins on an appearance toggle) is still met: both `build()` methods perform a live `Theme.of(context).extension<GWColors>()` read, which registers an InheritedWidget dependency on the Element regardless of whether the widget instance itself was constructed via `const`. The plan's premise that "const" was the defect conflated two different things — the shipped code's actual defect was never calling `Theme.of(context)` at all (hardcoded `Colors.greenAccent`/`Colors.redAccent`), not the constructor's constness.
- **Files modified:** `lib/banxa/banxa_components/buy_success_drawer_content.dart`, `lib/banxa/banxa_components/buy_cancelled_drawer_content.dart`, and their two call sites (`ListView(children: const [...])` restored to match).
- **Verification:** `flutter analyze lib/banxa/banxa_components/` — 0 issues, exit 0.
- **Committed in:** `5d8da5f`.

---

**Total deviations:** 2 (1 dispatch-authorized process override, 1 Rule-1-class analyzer-driven correction to the plan's own text). **Impact on plan:** neither changes any must-have truth's verdict; both are documented departures from what the plan's prose literally said, in favour of what this dispatch instructed and what the analyzer actually requires.

## Issues Encountered

None beyond the two deviations above — no build errors, no flaky tests, no auth gates, no package-manager installs.

## Findings Recorded, Not Acted On

Per the plan's `<output>` instructions, both findings are recorded here and were NOT acted on:

1. **`BuySuccessDrawer`/`BuyCancelledDrawer` have no production caller.** The only references outside their own files are `lib/dev/dev_tools_bubble.dart:683,688` (confirmed by grep before and after this plan's changes — unchanged). Sketch 066-B's Purchase section (`Paid`, `Method`, `Order`) needs order data neither this API nor that dev-only caller supplies. No data was invented to fill those rows and neither drawer was deleted; whether these drawers should be wired to a real purchase result, or removed, is a decision for the developer, not this plan.
2. **`handle_dapp_requests.dart:174-184` builds a complete `Transaction` model two lines before calling `SwapResultDrawer.show`.** That model is exactly what `showTransactionDetails` consumes, meaning the Reown swap result could in principle take the same deletion-and-repoint `9ff7c04` applied to the two squid swap drawers, instead of being re-skinned as its own file. This is a Phase 10 mechanics call, outside this phase's fence — the evidence is recorded, the re-skin was done instead, and `git diff --stat -- lib/reown/handle_dapp_requests.dart` confirms zero lines moved.

## Outstanding Visual Verification (recorded, not claimed)

This session has no running app instance (the orchestrator owns `flutter run`, per this dispatch's own constraint). The following checks are genuinely visual and are recorded **OUTSTANDING**, not PASS, per this project's standing no-unearned-PASS rule — verbatim from the plan's `<human_verification>`:

- [ ] Dev bubble → **Buy OK**. Dark mode: title reads "Purchase complete"; one green check glyph; a "Completed" pill under it; the sentence below is quiet grey, NOT green; one filled-gradient "Done" that actually closes the drawer.
- [ ] Dev bubble → **Buy fail**. Title "Purchase cancelled"; the glyph and pill read **slate**, not red — a cancellation must not look like an error; the "Close" button is a gradient outline and actually closes the drawer.
- [ ] Dev bubble → the two swap-result buttons. Success shows a "Completed" pill and a TRANSACTION grid holding one copyable hash row; tapping the row shows the "Transaction hash copied" snackbar. Paste it somewhere and confirm the **full** 66-character hash arrived, not the truncated display form.
- [ ] The failure branch (empty hash) shows no empty grid and no bare kicker floating over nothing.
- [ ] Repeat all four in **light** mode. The slate cancelled pill is the one most likely to fail here.
- [ ] Put the three side by side with a real transaction receipt (Transactions tab → any row). Same icon size, same gap above the pill, same pill geometry. If they do not read as one family, that is a finding worth filing — it is the phase's headline claim.

## Next Phase Readiness

- All six D-02 receipts are now on 031-B1: converted here (Reown swap result, both Banxa results), already converted (`showTransactionDetails`), or deleted-and-repointed at the shared receipt by `9ff7c04` (both squid swap drawers). D-02's rollout is COMPLETE across the app, pending only the outstanding visual walk above.
- `GWDrawerReceiptHead`'s optional-amount slot is now proven by two consumers beyond its original author (21-01) — 21-04/21-05/21-06 can build on the same primitive without re-deriving this shape.
- The two Banxa result drawers' no-production-caller finding is a genuinely open product question — flagged for the developer, not silently resolved either way.

---
*Phase: 21-drawer-language-rollout-the-four-decided-drawer-designs-appl*
*Completed: 2026-07-30*

## Self-Check: PASSED

- FOUND: `lib/components/bottom_drawer/drawer_content.dart`
- FOUND: `lib/reown/swap_result_drawer.dart`
- FOUND: `lib/banxa/banxa_components/buy_success_drawer.dart`
- FOUND: `lib/banxa/banxa_components/buy_success_drawer_content.dart`
- FOUND: `lib/banxa/banxa_components/buy_cancelled_drawer.dart`
- FOUND: `lib/banxa/banxa_components/buy_cancelled_drawer_content.dart`
- FOUND: `test/components/drawer_content_test.dart`
- FOUND: `test/components/result_receipt_family_test.dart`
- FOUND: `tool/check_raw_colors.sh`
- FOUND commit: `c082475`
- FOUND commit: `aaae508`
- FOUND commit: `5d8da5f`
- FOUND commit: `30e8c38`
- `flutter analyze --no-pub` root: 0 issues, exit 0. `packages/genius_api`: 0 issues, exit 0.
- `flutter test --no-pub`: 740/740 passing (734 baseline per 21-02-SUMMARY.md + 2 Task 1 + 4 Task 4), 0 failing.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh --self-test`: exit 0. `bash tool/check_raw_colors.sh`: exit 0. `bash tool/check_no_new_key_logging.sh --scan-tree`: exit 0. `bash tool/check_onboarding_seed_safety.sh`: PASSED.
- `dart format --set-exit-if-changed lib test`: exit 0 (344 files, 0 changed).
- `git diff --stat -- lib/reown/handle_dapp_requests.dart lib/reown/reown_connect_button.dart lib/dev/dev_tools_bubble.dart`: empty — the three callers are byte-identical to HEAD.
