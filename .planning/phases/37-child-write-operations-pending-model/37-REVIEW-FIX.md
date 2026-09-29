---
phase: 37-child-write-operations-pending-model
fixed_at: 2026-09-29T00:00:00Z
review_path: .planning/phases/37-child-write-operations-pending-model/37-REVIEW.md
iteration: 3
findings_in_scope: 3
fixed: 3
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

---

# Iteration 3

**Source review:** 37-REVIEW.md (iteration 2): 3 warnings, all in the carry-forward path.
**Summary:** 3 in scope, 3 fixed, 0 skipped. Each fix has a regression test that failed before the change.

The rule applied throughout: nothing reads as done without its own signal. Where two options were
possible, the fix picks the one that ends in "Not confirmed yet" rather than a possible false toast.

## Fixed Issues

### WR-01: A retry inherits a baseline of any age

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** 47d002ce
**Status:** fixed: requires human verification (logic)
**Applied fix:** Each fund or recover now records `baselineAt`. A baseline older than three timeouts
(6 min) is never trusted. `_signalMet` returns false past that point, for every fund or recover op,
not just a retry. A retry keeps the earlier baseline only if it stays trusted through the retry's
own timeout, which means it was read less than 2x the timeout ago. Otherwise the retry reads a fresh
baseline. A `ponytail:` comment on `_baselineLifetime` names two ceilings: other movement inside the
window can still interfere, and a write that lands after the window holds its amount until restart.
The upgrade path is a per-write tx hash from the SDK.
**Deviation from the brief:** past the window, the retry still takes over the old attempt's amount
(fresh baseline, `carriedMinions` kept). It does not leave the old op as a separate entry. With a
separate entry, the stale attempt landing after the retry could satisfy the retry's fresh baseline
and toast a false "done". It would also hold its amount forever, because a stale op can no longer
resolve. Merging means the retry waits for both amounts. The worst case is "Not confirmed yet"
when the earlier attempt had already landed before the retry.
**Gating the old op too:** the resolve-before-dialog added in WR-03 would otherwise have resolved
the review's own example falsely ("Recovered 10 GNUS") at the one-hour mark.
**Test:** the review's recover example (100 GNUS, recover 10 times out, child spends 15 an hour
later, retry 5). Nothing resolves at the hour mark. The retry gets a fresh baseline of 85 and carries
10. It resolves only at 70.

### WR-02: `replaces` ignores which main paid

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `test/child_wallets/child_operations_cubit_test.dart`
**Commit:** d2ee0587
**Status:** fixed: requires human verification (logic)
**Applied fix:** `replaces` also requires `fromAccount` to equal the submitting account
(case-insensitive). The old main's op stays as its own entry, and its hold stays on the old main.
Keeping it separate made one new false "done" possible: the old main's attempt landing could
satisfy the new main's fresh baseline. So `submit()` records a signal-only `otherAttemptsMinions`,
the total of other accounts' tracked ops of the same kind on that child. `_signalMet` waits for that
total too. It is not counted in `_committed`, so nothing is reserved twice.
**Test:** M1 funds C with 10, and the fund times out. M2 funds C with 5, which leaves 2 ops. M1's
free balance (upper-cased address) is 90. M1's 10 lands, and only M1's op resolves. M2's 5 lands,
and then M2's op resolves.

### WR-03: A retry never checks whether the attempt it replaces landed, and names only its own amount

**Files modified:** `lib/child_wallets/child_operation_dialogs.dart`, `lib/child_wallets/child_operation_status.dart`, `test/child_wallets/child_operation_actions_test.dart`
**Commit:** b7504e13
**Applied fix:** `startFund` and `startRecover` call `registry.resolve()` before the amount dialog
opens. A late-landed earlier attempt then resolves, toasts and releases its hold, and the next fund
does not carry it. The badge and toast show `totalMinions` and add ", including an earlier attempt"
when `carriedMinions` is set. Examples: "Recovering 1.5 GNUS, including an earlier attempt…" and
"Recovered 1.5 GNUS from Game Wallet, including an earlier attempt". Without a carry, the wording is
unchanged. `submit()` is still the only write path.
**Tests (widget):** (1) A fund times out and then lands. Opening Fund toasts "Funded 1 GNUS to Game
Wallet", the badge clears, and the next 0.5 has no carry. (2) A recover retry shows the carried total
on the badge and in the toast.

## Verification (iteration 3)

All gates ran in the **main checkout** (`workflow.use_worktrees: false`) on `gsd/v3.0-child-wallets`,
at HEAD b7504e13:

- `flutter test`: 2162 passed / 5 skipped / 0 failed. That is the 2158 baseline plus 4 new tests.
- `flutter analyze lib test`: No issues found (exit 0).
- `dart format --set-exit-if-changed` on the 5 changed files: 0 changed.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0.
- `git ls-files --eol`: all 5 changed files are `i/lf w/lf`.
- No finding, decision, plan or phase identifiers in the changed source or tests. No `GeniusApi()`
  constructed. Amounts stay `BigInt` end to end.

---

_Fixed: 2026-09-29_
_Iteration: 3_
