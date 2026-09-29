---
phase: 37-child-write-operations-pending-model
fixed_at: 2026-09-29T00:00:00Z
review_path: .planning/phases/37-child-write-operations-pending-model/37-REVIEW.md
iteration: 1
findings_in_scope: 6
fixed: 6
skipped: 0
status: all_fixed
---

# Phase 37: Code Review Fix Report

**Fixed at:** 2026-09-29
**Source review:** .planning/phases/37-child-write-operations-pending-model/37-REVIEW.md
**Iteration:** 1

**Summary:**
- Findings in scope: 6 (2 critical, 4 warning)
- Fixed: 6
- Skipped: 0

Every fix stays inside the registry or its two view files. `submit()` is still the only write path.
Each fix went in with a regression test that failed before the change (CR-01..WR-03). WR-04 is a
pure refactor, so no test can fail before it. The existing picker widget tests cover it.

## Fixed Issues

### CR-01: Concurrent Fund/Recover submissions from one account can jointly exceed its real balance

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** a5f11640
**Status:** fixed: requires human verification (logic)
**Applied fix:** `payingBalance()` now subtracts `_committed()`, which is the total of every tracked
op drawing on the same balance: Fund ops from the running account, or Recover ops on that child.
The result is floored at zero. `submit()` and the amount dialog both call `payingBalance()`, so the
second over-balance Fund is refused with the existing "{payer} doesn't have that much GNUS." message
and no SDK call. **Decision:** timed-out ops still count, because with no tx hash the SDK may still
land them. A `ponytail:` comment marks the ceiling: an op that never lands holds its amount until a
restart or a resolve. There is also a brief conservative double-count between a write landing and
the next resolve poll. Tests cover 60+60 against 100 GNUS (the second is refused, `fundCallCount`
stays 1, the remaining 40 still passes, the hold survives a timeout) and a timed-out recover still
holding its share of the child's balance.

### CR-02: A resubmitted operation can resolve on an unrelated, older operation's late-arriving effect

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** 6563386f
**Status:** fixed: requires human verification (logic)
**Applied fix:** The timed-out op is carried forward instead of dropped. The retry inherits the old
op's `baselineMinions` and gets a new `carriedMinions` equal to the old op's total. `totalMinions`
(amount + carried) drives `_signalMet` (Fund: `>= baseline + total`, Recover: `<= baseline - total`)
and `_committed`. Badges and toasts still show only the retry's own amount. A 3-line WHY comment sits
in `submit()`. **Trade-off:** if the abandoned attempt never lands, the retry cannot resolve and
reads "Not confirmed yet". That is honest, but it can happen in the dev bubble when "Writes time
out" is followed by "Writes confirm". Tests: a timed-out fund of 1 is followed by a retry of 0.5,
the old 1 lands, and the retry stays pending. It resolves at +1.5 with the retry's 0.5 in the toast.
The recover mirror is tested too.

### WR-01: `submit()` has no registry-level guard against a self-referential register/move

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** fdfd57e3
**Applied fix:** `submit()` returns null with no SDK call when a register's main equals the target
(the running account), or when a move's newMain is null, equals the target, or equals the current
main. All comparisons are case-insensitive. Tests use upper-cased addresses to prove it.

### WR-02: A badge shows only the most-recently-submitted operation, hiding a concurrently-pending sibling

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `lib/child_wallets/child_wallets_screen.dart`, `test/child_wallets/child_operation_actions_test.dart`
**Commit:** 6ffb5019
**Applied fix:** `latestFor()` is replaced by `operationsFor()`, which returns every tracked op on the
target in submission order. The child row renders one `ChildOperationBadge` per op in a
right-aligned `Column` (`space2` apart). The "This account" card renders each op under the status
line. Widget tests: Fund+Revoke on a child and Detach+Move on the card both show both badges. The
existing 320px no-overflow test still passes.

### WR-03: `ChildOperationToasts` silently drops a resolution toast if the navigator hasn't attached

**Files modified:** `lib/child_wallets/child_operation_status.dart`, `test/child_wallets/child_operation_actions_test.dart`
**Commit:** 52025627
**Applied fix:** When `navigatorKey.currentContext` is null, the listener now retries through
`addPostFrameCallback` instead of returning. It does not schedule frames itself, so there is no busy
loop. `labelFor` is captured when the listener fires. Widget test: the op resolves while no
`Navigator` is mounted, then the `MaterialApp` attaches, and "Funded 1 GNUS to Game Wallet" appears.

### WR-04: `_MainPickerDialogState` repeats the `_buildFoo(): Widget` helper-method pattern AGENTS.md forbids

**Files modified:** `lib/child_wallets/child_main_picker_dialog.dart`
**Commit:** 5a57149c
**Applied fix:** `_listContent`/`_manualContent` became the private StatelessWidgets
`_MainPickerListContent` (candidates, nameFor, picked, onPick, onManual) and
`_MainPickerManualContent` (controller, error, onBack, onChanged). The manual-entry error moved to a
`_manualError` getter on the State. Copy and behaviour are unchanged. All picker widget tests in
`test/child_wallets/child_main_picker_test.dart` pass.

## Verification

All gates ran in the **main checkout** (`workflow.use_worktrees: false`, so no worktree was created)
on `gsd/v3.0-child-wallets`, at HEAD 5a57149c:

- `flutter test`: 2158 passed / 5 skipped / 0 failed. That is the 2149 baseline plus 9 new tests.
- `flutter analyze lib test`: No issues found (exit 0).
- `dart format --set-exit-if-changed` on the 6 changed files: 0 changed.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0.
- `git ls-files --eol`: all changed files are `i/lf w/lf`.
- No finding, decision, plan or phase identifiers in the changed source or tests.
- No test constructs `GeniusApi()`. All tests use the `implements GeniusApi` fakes.

---

_Fixed: 2026-09-29_
_Iteration: 1_
