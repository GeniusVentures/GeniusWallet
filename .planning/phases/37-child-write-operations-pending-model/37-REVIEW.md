---
phase: 37-child-write-operations-pending-model
reviewed: 2026-09-29T11:39:14Z
depth: standard
iteration: 2
files_reviewed: 7
files_reviewed_list:
  - lib/child_wallets/child_operations_cubit.dart
  - lib/child_wallets/child_wallets_screen.dart
  - lib/child_wallets/child_operation_status.dart
  - lib/child_wallets/child_main_picker_dialog.dart
  - lib/child_wallets/child_operation_dialogs.dart
  - test/child_wallets/child_operations_cubit_test.dart
  - test/child_wallets/child_operation_actions_test.dart
findings:
  critical: 0
  warning: 3
  info: 0
  total: 3
status: issues_found
---

# Phase 37: Code Review Report (iteration 2)

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 7
**Status:** issues_found

## Summary

This pass checked `git diff 8d37e6ea..HEAD` against the iteration-1 findings, then re-read the whole
phase diff (`4061095c..HEAD`) for anything the fixes introduced.

- `submit()` is still the only SDK write path. A grep of `lib/` for all six wrappers finds calls only
  inside `ChildOperationsCubit.submit()`, and each call issues exactly one write.
- Reservations are released correctly. A resolve removes the op, which releases its reservation, and
  that includes "Check again" and a manual refresh, both of which call `resolve()`. A non-OK or
  refused submit appends nothing, and a timed-out op it would have replaced stays with its hold.
- Nothing is double-counted permanently in the normal path. The retry drops the old op and carries
  its total, so the carried amount counts once.
- Fund and Recover reservations use disjoint predicates (kind plus paying account). Neither can make
  the other resolve as done.
- Carry-forward composes across 3+ retries: `carried = replaced.totalMinions`, and the baseline is
  inherited unchanged. Recover is the exact mirror (`<= baseline - total`).
- The dev mock applies only the attempt's own `amountMinions`, which matches the real SDK.

Three new defects remain, all in the carry-forward path:
- its baseline has no age limit;
- `replaces` does not care which main paid;
- the retry never checks whether the attempt it replaces already landed.

## Resolved from iteration 1

| ID | Status |
|----|--------|
| CR-01 concurrent funds exceed balance | Resolved. `_committed`/`_lessCommitted` are used by both `submit()` and the amount dialog. The one exception is the cross-main path in WR-02 below. |
| CR-02 retry resolves on the abandoned attempt's late landing | Resolved for that case. The fix introduced WR-01 below. |
| WR-01 self-referential register/move | Resolved. Case-insensitive guard in `submit()`; a move to the current main is also refused. |
| WR-02 badge hides a sibling op | Resolved. `operationsFor()` puts one badge per op on the row and on the card. |
| WR-03 toast dropped before the navigator attaches | Resolved. Post-frame retry, no self-scheduled frames. |
| WR-04 `_buildFoo()` helpers | Resolved. Two private `StatelessWidget`s. |

The two conservative trade-offs from the brief were checked and not flagged: timed-out funds keep
their reservation, and a retry after a never-landing timeout ends "Not confirmed yet". Neither can
lose funds or report a false "done" on its own. WR-01 below is a separate mechanism.

## Warnings

### WR-01: A retry inherits a baseline of any age, so unrelated activity can report a false "done"

**File:** `lib/child_wallets/child_operations_cubit.dart:288-297, 396-403`

**Issue:** The retry uses `replaced.baselineMinions`, the child balance read when the *first*
attempt was submitted. That can be any age within the app's lifetime, because a timed-out op is
never evicted. `_signalMet` then counts every balance movement since that first read. Before the fix,
it only counted movement since the retry.

Example with Recover:
1. A recover of 10 GNUS times out and never lands.
2. The child spends 15 GNUS on its own over the next hour.
3. The user retries with 5 GNUS, and the node drops that attempt too.
4. The next poll sees `current <= B0 - 15`. It resolves and toasts "Recovered 5 GNUS from X", but
   the main received nothing.

The same happens for Fund when the child's balance rises from any source other than this registry.

A fresh baseline carried the same class of risk, but only for movement after the retry. Inheriting
the baseline adds every movement since the first attempt, with no limit, and that directly causes
a false "done". The reverse also happens: a correct retry never resolves if the child earned
(Recover) or spent (Fund) in between. Nothing in the code marks this limit. The only `ponytail:`
comments cover restart persistence and reservations.

**Fix:** Limit how long a baseline can be inherited, and mark the limit with a `ponytail:` comment:
```dart
// ponytail: an inherited baseline counts unrelated balance movement since the
// first attempt; past 2x the timeout a retry starts fresh instead.
final carry = replaced != null &&
    _now().isBefore(replaced.submittedAt.add(childOperationTimeout * 2));
final baseline = _hasAmount(kind)
    ? (carry ? replaced.baselineMinions : null) ?? _childBalance(target)
    : null;
// carriedMinions: carry ? replaced.totalMinions : null
```
Also add a test where the child's balance drifts between the first attempt and the retry.

### WR-02: `replaces` ignores which main paid, so after a Move one main's reservation moves to another

**File:** `lib/child_wallets/child_operations_cubit.dart:281-290, 198, 344-345`

**Issue:** `replaces` matches only on kind, `notConfirmed` and target. It does not check
`fromAccount` or `main`. Here is a reachable sequence:
1. Main M1 funds child C with 10 GNUS, and the fund times out.
2. C moves to M2. The move runs as C.
3. M1's timed-out op still shows its "Not confirmed yet" badge on C's row, now under M2, and Fund is
   enabled there.
4. M2 funds C with 5 GNUS. That retry drops M1's op and carries its 10 GNUS.

The consequences:
- M1's reservation disappears. `drawsOn` for Fund is `fromAccount == running`, and the carried 10
  now sits on an M2 op. After a switch back to M1 (allowed once M2's op times out), M1 can commit
  its full balance again while its own 10 GNUS may still land. That is the iteration-1 CR-01
  over-commit, reached through a different path.
- M2's free balance is reduced by 10 GNUS it never sent.
- If M1's attempt never lands, M2's retry can never resolve, and M2 holds that 10 GNUS until the
  app restarts.

No test covers a replacement across mains.

**Fix:** Only replace an op submitted by the same account:
```dart
bool replaces(ChildOperation existing) =>
    existing.kind == kind &&
    existing.notConfirmed &&
    existing.target.toLowerCase() == target.toLowerCase() &&
    existing.fromAccount.toLowerCase() == requiredRunner.toLowerCase();
```
The M1 op then stays as its own entry and keeps M1's hold. Allowing two ops for one kind and target
is safe here: `isPending` ignores notConfirmed ops, and `operationsFor` already renders every op.

### WR-03: A retry never checks whether the attempt it replaces already landed, and it announces only its own amount

**File:** `lib/child_wallets/child_operations_cubit.dart:288-290, 388-393`;
`lib/child_wallets/child_operation_dialogs.dart:34-74, 98-136`;
`lib/child_wallets/child_operation_status.dart:16-18, 34-38`

**Issue:** The poll timer stops once every op is notConfirmed (lines 390-393). After that, a timed-out
fund that lands late is noticed only on "Check again" or a manual refresh. Meanwhile the screen's own
10 s poll refreshes the child's balance, and the Fund menu item is enabled again.
`startFund`/`startRecover` open the amount dialog and `submit()` sends a second payment without ever
running `_signalMet(replaced)`. A user who retries "Not confirmed yet" can therefore pay twice when
the first attempt has already arrived. The money goes to their own child, so it is recoverable, but
it is an unintended duplicate that one balance read would prevent.

The copy also misleads after a retry. The badge reads "Funding 0.5 GNUS…" while the op waits for
1.5 to land. The success toast says "Funded 0.5 GNUS", and the first attempt's landing is never
announced. That toast is the only place a resolution is announced. The fund-retry test locks this
wording in by asserting `justResolved.single.amountMinions == 500000`.

**Fix:** Resolve before offering a retry, and name the carried amount:
```dart
// startFund / startRecover, before showDialog:
registry.resolve(); // a late-landed first attempt resolves and toasts here
```
In `pendingText`/`resolvedText`, when `op.carriedMinions != null`, show `op.totalMinions` and add
"(incl. earlier attempt)". Alternatively, keep the poll running while any amount-carrying op is
notConfirmed and holds a reservation.

---

_Reviewed: 2026-09-29_
_Depth: standard_
