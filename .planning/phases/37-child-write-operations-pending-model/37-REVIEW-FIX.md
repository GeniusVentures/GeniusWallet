---
phase: 37-child-write-operations-pending-model
fixed_at: 2026-09-29T00:00:00Z
review_path: .planning/phases/37-child-write-operations-pending-model/37-REVIEW.md
iteration: 7
findings_in_scope: 1
fixed: 1
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

---

# Iteration 4 — simplification

**Source review:** 37-REVIEW.md (iteration 3): 3 critical, 1 warning.
**Decisions applied:** the CONTEXT amendment (one fund or recover per child at a time, no zero-read recover).
**Summary:** 4 in scope. 3 fixed, 1 accepted as a documented ceiling (WR-01). Deletion first: the
carry/merge machinery is gone, not patched.

## What was removed

`carriedMinions`, `otherAttemptsMinions`, `totalMinions`, `baselineAt`, `_awaited`, baseline
inheritance, cross-account absorption, and the ", including an earlier attempt" copy. With no
inheritance, the baseline is always read at submit, so `submittedAt` dates it.

## What was kept

The per-op baseline, the 6-minute trust window, the paying account's reserved balance (a main
funding two children still can't overspend), and `resolve()` before the amount dialog opens.

## Fixed Issues

### CR-01, CR-02: cross-account and inherited-baseline false "done"

**Files modified:** `lib/child_wallets/child_operations_cubit.dart`, `lib/child_wallets/child_operation_status.dart`, `lib/child_wallets/child_operation_dialogs.dart`, `lib/child_wallets/child_wallets_screen.dart`, both test files
**Commits:** 74d78806 (registry), ebc1edea (menu + dialog)
**Status:** fixed: requires human verification (logic)
**Applied fix:** `balanceLockReason(target)` is the single lock. `submit()` refuses a Fund or Recover
while any fund or recover on that child, from any account, is pending or timed out but not
expired. A new explicit `expired` flag is set by `resolve()` past 6 minutes. From then on the op
can't resolve and releases its hold and its lock. The poll keeps running until expiry, so the menus
rebuild on time. An expired op gives its badge up to the next fund or recover on that child.
Register, revoke, detach and move are unchanged.
The reason copy is "Already funding this child" or "Already recovering from this child" while
pending. Once timed out, it reads "An earlier transfer for this child hasn't confirmed yet. Check
again, or wait a few minutes." The copy appears on both disabled menu items (Tooltip, the
UI-SPEC's lock styling) and in the amount dialog (a `GWWarningNote` with the primary action
disabled). The dialog follows the registry live.
**Both review traces are now impossible:** the second main's fund and the retry are refused at
`submit()`, with no SDK call. Both tests failed on the old code with `Expected: null, Actual:
GENIUS_NODE_RET_OK`.

### CR-03: recover resolves on a 0 read

**Commit:** 5aff522f
**Status:** fixed: requires human verification (logic)
**Applied fix:** `_signalMet` for recover requires `current > 0`, marked with a `ponytail:` comment.
A recover that empties the child ends "Not confirmed yet". The review's own test (recover 10 from
100 times out, read drops to 0) and a whole-balance recover both failed first.

## Accepted (not fixed)

### WR-01: fund baseline read as 0 before the child synced

**Commit:** 859e770b
**Reason:** the amendment accepts this as a known ceiling. A `ponytail:` comment on the fund signal
names it. The upgrade path is a per-write tx hash.

## Tests

- **Removed as obsolete (7):** the retry-carry tests (fund, recover, stale baseline), the two-op
  move test, "after notConfirmed, a new submit leaves exactly one op", and the two carry-wording
  widget tests.
- **Added or rewritten (10):**
  - a pending recover locks a fund;
  - a timed-out fund locks a fund and a recover until expiry, while another child stays free;
  - Check again seeing it land unlocks;
  - an expired recover never resolves, and the next recover reads a fresh baseline;
  - both review cross-account traces;
  - an expired fund releases its hold;
  - two zero-read recover tests;
  - the dialog locking live.
- The menu lock widget test was rewritten: pending, then timed out, then expired.

## Verification (iteration 4)

All gates ran in the **main checkout** (`workflow.use_worktrees: false`) on `gsd/v3.0-child-wallets`,
at HEAD 859e770b:

- `flutter test`: 2165 passed / 5 skipped / 0 failed (2162 - 7 removed + 10 new).
- `flutter analyze lib test`: No issues found, exit 0.
- `dart format --set-exit-if-changed lib/child_wallets test/child_wallets`: exit 0.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0.
- `git ls-files --eol`: all 6 changed files are `i/lf w/lf`.
- No finding, decision, plan or phase identifiers in source or test names. No `GeniusApi()` is
  constructed. Amounts stay `BigInt`. `submit()` is still the only write path.

_Iteration: 4_

---

# Iteration 5

**Source review:** 37-REVIEW.md (iteration 4): 5 warnings, 3 info.
**Summary:** WR-01..WR-05 in scope. All 5 fixed, 0 skipped. Each behaviour change had a regression
test that failed first. IN-01 and IN-03 stay as documented info. IN-02 got one comment line.

## Fixed Issues

### WR-01: a timed-out fund/recover resolves on another account's view after a switch

**Commit:** 3d89be2a · **Status:** fixed: requires human verification (logic)
**Applied fix:** `_onOwnView(op)` requires the running account to equal `op.fromAccount`
(case-insensitive) before a fund or recover can resolve. On another account the op stays
pending or timed out. It still expires at 6 minutes, because expiry does not go through the
signal. **Test:** the review's trace. A recover of 10 from 100 times out, the node switches, and
the read drops to 50. Nothing resolves, the lock holds, and it expires at 6 min. **Two existing
tests changed:** both cross-main tests resolved the old main's op while the node ran as the new
main. That is exactly the path now closed. They now switch back to the old main before it lands.
**Not done:** the review's "full fix", expiring holding ops on every `SelectSDKAccount`. A round
trip M1 -> M2 -> M1 inside the window still resolves on a view that may be resyncing.

### WR-02: `expired` does not stop a resolve

**Commit:** 0b0b6115 · **Status:** fixed: requires human verification (logic)
**Applied fix:** `_signalMet` returns false first when `op.expired`. As a side effect, expired
recovers no longer read the balance on every poll. The `Stopwatch` option was not taken. A
backwards step still delays timeout and expiry of a live op. **Test:** a fund expires, the clock
steps back to 3 min, and the balance meets the signal. It stays expired, nothing resolves, and no
lock returns.

### WR-03: debug builds mix mock and real reads across one op

**Commit:** 1f2fb4da · **Status:** fixed: requires human verification (logic)
**Applied fix:** `ChildOperation.mocked` is set from `_devMocked` at submit. `_signalMet` returns
false while `op.mocked != _devMocked`, so the op times out or expires instead. This covers every
kind, including revoke and detach. **Seam:** `kShowDevTools` is a compile-time `false` under
`flutter test`, so the registry takes `devTools` (default `kShowDevTools`). `kDebugMode` still
gates it, and `lib/main.dart` is unchanged. **Tests:** (1) A real fund, then a preset armed. The
mock's 250 GNUS does not resolve it. After `clear()`, it resolves on its own real landing. (2) A
mock fund in timeout mode makes no SDK call. After `clear()` a 300 GNUS real read does not
resolve it. `justResolved` stays empty in both, so no toast.

### WR-04: the poll's stop condition had no test

**Commit:** c1575e7f
**Applied fix:** a widget test moves the injected clock and the fake timers together, 10 s per
tick, with no manual `resolve()`. Fund and Recover stay locked at 2 min and unlock at 6. The
registry is left open, so a poll that outlives expiry fails the test as a pending Timer.
**Mutation checks (reverted):** the old `every((op) => op.notConfirmed)` condition fails on
`expired`. A poll that never stops fails with "A Timer is still pending…".

### WR-05: two doc comments over 3 lines

**Commit:** c8887712
**Applied fix:** `submit` and `resolve` are now 3 lines each. They keep the reasons: a refused
write never shows as pending, the signal is checked before the timeout, and there is no emit
without a change.

## Info

- **IN-01** (Check again on an expired op), **IN-03** (expiry releases a hold still in flight):
  left as documented. Not changed.
- **IN-02:** the recover `ponytail:` now says a MAX recover empties the child and cannot confirm.
  It ends "Not confirmed yet" and locks the child until expiry. Commit 437fd6d3.

## Verification (iteration 5)

All gates ran in the **main checkout** (`workflow.use_worktrees: false`) on `gsd/v3.0-child-wallets`,
at HEAD 437fd6d3:

- `flutter test`: 2170 passed / 5 skipped / 0 failed (2165 + 5 new).
- `flutter analyze lib test`: No issues found, exit 0.
- `dart format --set-exit-if-changed lib/child_wallets test/child_wallets`: exit 0.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0.
- `git ls-files --eol`: all 3 changed files are `i/lf w/lf`.
- No finding, decision, plan or phase identifiers in the diff. No `GeniusApi()`. Amounts stay
  `BigInt`. `submit()` is still the only write path. No commit carries a trailer.

_Iteration: 5_

---

# Iteration 6

**Scope:** the item left open in iteration 5, the round trip M1 -> M2 -> M1 inside the 6-min window.
**Commit:** 9ee14b7f · **Status:** fixed: requires human verification (logic)

**Applied fix:** in `resolve()`, a fund or recover also expires when `_onOwnView(op)` is false. The
registry now takes `appStates` (AppBloc's stream, wired in `lib/main.dart`) and runs `resolve()` on
every distinct change of the running account. Before this it only pulled the account on a poll
tick, so a round trip between two ticks went unseen. The op ends "Not confirmed yet", can never
resolve, and frees its hold and its per-child lock.

**Tests:** new: fund 10 from M1, time out, switch to M2 and back to M1 at 3 min, balance rises by
10. Nothing resolves, `justResolved` stays empty (no toast), the op is expired, the lock is null, and
M1's paying balance is whole again. It failed first with the plumbing in place and no expiry. A
mutation check with the subscription disabled also fails it. Changed: the off-view recover test
now expires on the first pass on the other account, not at 6 min.

**Open trade-off, for a decision:** releasing the lock at the switch reopens iteration 3's
cross-account trace in the 2-6 min window. M1's fund times out, the user switches to M2, and M2
funds the same child. If M1's write then lands, it satisfies M2's baseline and toasts a false
"Funded". Before this change the lock refused M2 until 6 min, and the `_baselineLifetime` ponytail
accepted this only after the window. The fix, if wanted, is to keep an op that expired on a switch
locking and holding until `submittedAt + 6 min` while still never resolving. The two cross-main
tests still pass only because they never call `resolve()` while on the new main.

## Verification (iteration 6)

All gates ran in the **main checkout** (`workflow.use_worktrees: false`) on `gsd/v3.0-child-wallets`,
at HEAD 9ee14b7f:

- `flutter test`: 2171 passed / 5 skipped / 0 failed (2170 + 1 new).
- `flutter analyze lib test`: No issues found, exit 0.
- `dart format --set-exit-if-changed` on the 3 changed files: exit 0.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0.
- `git ls-files --eol`: all 3 changed files are `i/lf w/lf`. No identifiers in source or test names,
  no `GeniusApi()`, no trailer.

_Iteration: 6_

---

# Iteration 7

**Decision applied:** safety over convenience. An op that switched away never resolves, but it keeps
its hold and its lock until 6 min after submit.
**Commit:** 65549888 · **Status:** fixed: requires human verification (logic)

**Applied fix:** a new `switchedAway` flag separates "can no longer resolve" from "released". A
switch sets it (plus `notConfirmed`), and `_signalMet` refuses on it. `expired` now only means the
6-min window has passed, so `_holdsBalance` (the hold and the lock) still ends only at expiry. The
poll keeps running until then, so the lock lifts on time. A 3-line WHY comment is in `resolve()`.

**Tests:** new, the reported trace: M1's fund times out, and the node switches to M2 at 3 min through
the app-state stream. M2's fund on the same child is refused with the timed-out lock reason. M1's
write lands at 4 min and nothing is toasted. M2 is still refused at 5:59.999. At 6:00 the lock
lifts. M2's fund then reads a baseline that already includes M1's landing, so it stays pending with
no false "Funded". This test failed first with `Expected: null, Actual: GENIUS_NODE_RET_OK`.
Updated: the off-view recover and the switch round-trip tests now expect the lock and hold to stay
through 3 min (not expired, M1's paying balance 0), then expired and released at 6:00, and never
resolved. Both failed before the change.

## Verification (iteration 7)

All gates ran in the **main checkout** (`workflow.use_worktrees: false`) on `gsd/v3.0-child-wallets`,
at HEAD 65549888:

- `flutter test`: 2172 passed / 5 skipped / 0 failed (2171 + 1 new).
- `flutter analyze lib test`: No issues found, exit 0.
- `dart format --set-exit-if-changed lib/child_wallets test/child_wallets`: exit 0.
- `bash tool/check_brace_style.sh`: exit 0. `bash tool/check_raw_colors.sh`: exit 0.
- `git ls-files --eol`: both changed files are `i/lf w/lf`. No identifiers in source or test names,
  no `GeniusApi()`, no trailer.

_Iteration: 7_
