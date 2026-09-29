---
phase: 37-child-write-operations-pending-model
reviewed: 2026-09-29T11:53:39Z
depth: deep
iteration: 3
files_reviewed: 5
files_reviewed_list:
  - lib/child_wallets/child_operations_cubit.dart
  - lib/child_wallets/child_operation_dialogs.dart
  - lib/child_wallets/child_operation_status.dart
  - test/child_wallets/child_operations_cubit_test.dart
  - test/child_wallets/child_operation_actions_test.dart
findings:
  critical: 3
  warning: 1
  info: 0
  total: 4
status: issues_found
---

# Phase 37: Code Review Report (iteration 3)

**Reviewed:** 2026-09-29
**Depth:** deep
**Files Reviewed:** 5
**Status:** issues_found

## Summary

This pass read `git diff d3b7d510..HEAD` against the whole cubit. It traced `submit()`, `resolve()`,
`_signalMet`, `_committed` and the two dialog entry points, plus `GeniusApi.getChildBalanceAll` and
the SDK header's contract for it.

The iteration-3 fixes do what they say for the cases they test: a same-account retry, a stale
baseline, and M1 10 followed by M2 5. The cross-account mechanism is one-directional, though.
`otherAttemptsMinions` protects the new op from the old op's landing, but nothing protects the old
op from the new op's landing. It is also lost when a retry inherits a baseline. Both produce a
false "Funded"/"Recovered" toast and release a hold whose money can still land. A third false
"done" is older but is now more reachable: the SDK documents a balance read of 0 as ambiguous
(`GeniusSDK.h:586-598`, "no balance vs. not-yet-synced"), and a Recover resolves on a 0 read. The
new `resolve()` in `startFund`/`startRecover` runs straight after `ensureRunningAs` may have
restarted the node on another account.

Checks that came back clean:
- **(d)** `submit()` is still the only write path. A grep of `lib/` for all six wrappers and
  `submitWrite` finds calls only in `child_operations_cubit.dart:350-373`.
- **(b)** `otherAttemptsMinions` is not summed in `_committed`. The carried amount moves with the
  retry, and the retry comes from the same account, so the hold stays on the same balance.
- **(c)** Nothing lets the running account send more than its balance less its own holds, except
  after a false resolve (CR-01, CR-02, CR-03), which releases a hold early.

## Resolved from earlier iterations

| ID | Status |
|----|--------|
| it.1 CR-01 concurrent funds exceed balance | Resolved (still holds; exceptions are the early releases below) |
| it.1 CR-02 retry resolves on the abandoned attempt | Resolved for same-account retries |
| it.1 WR-01..WR-04 | Resolved, unchanged this iteration |
| it.2 WR-01 baseline of any age | Resolved. `_baselineTrusted` gates every fund/recover signal at 6 min; the retry inherits only if the baseline stays trusted through its own timeout |
| it.2 WR-02 `replaces` ignores the payer | Resolved for the hold. The signal-side follow-up has gaps (CR-01, CR-02) |
| it.2 WR-03 retry never checks a late landing | Resolved. `registry.resolve()` runs before the amount dialog; copy shows `totalMinions` plus ", including an earlier attempt" |

## State and transition model (fund / recover)

| State | Representation | Holds (`_committed`) | Can resolve |
|-------|----------------|----------------------|-------------|
| Pending | in `operations`, `notConfirmed == false` | amount + carried | yes (baseline always trusted: the 2-min window ends before `baselineAt + 6 min`) |
| Timed out | `notConfirmed == true`, `now < baselineAt + 6 min` | amount + carried | yes |
| Expired baseline | `notConfirmed == true`, `now >= baselineAt + 6 min` | amount + carried, until restart | never |
| Merged / carried | removed; its `totalMinions` becomes the same-account retry's `carriedMinions` | moves to the retry | through the retry only |
| Counted as another attempt | stays its own op; its `totalMinions` is snapshotted into a later other-account op's `otherAttemptsMinions` | its own, unchanged | yes, **against its own awaited total only** (CR-01) |
| Resolved | removed, placed in `justResolved`, toast | released | n/a |

| # | Trigger | From -> To | Code |
|---|---------|------------|------|
| T1 | `submit` OK, no same-account notConfirmed op | none -> Pending, fresh baseline, `otherAttempts` = snapshot | `:300-347` |
| T2 | `submit` OK, same-account notConfirmed op R | R -> Merged; new Pending carries `R.total`; baseline inherited if R trusted at `now + 2 min`, else fresh; `otherAttempts` recomputed from the **current** list | `:312-345` |
| T3 | `submit` refused / non-OK | no change | `:268-298, :374` |
| T4 | `resolve`, signal met while trusted | Pending/Timed out -> Resolved | `:410-413, :435-442` |
| T5 | `resolve`, 2 min since `submittedAt` | Pending -> Timed out | `:415-418` |
| T6 | clock passes `baselineAt + 6 min` | Timed out -> Expired (implicit) | `:461-462` |
| T7 | poll (only while something is Pending), Refresh, Check again, opening Fund/Recover | runs `resolve` | `:391, screen:33, dialogs:45, :110` |
| T8 | restart | everything forgotten | memory-only registry |

The CR items below are the edges where T4 fires without the attempt's own money landing.

## Critical Issues

### CR-01: A later attempt from another main resolves the earlier main's op as done

**File:** `lib/child_wallets/child_operations_cubit.dart:315-319, 378-388, 437-439, 457-458`

**Issue:** When M2 submits while M1's op A on the same child is timed out, only the new op B gets
`otherAttemptsMinions = A.total`. A itself is not updated, so A's signal is still
`balance >= A.baseline + A.total`. If B's amount is at least A's, B landing alone satisfies A.

Trace, with C at 0 and the reachable move path from iteration 2:
1. M1 funds C with 5 (A: baseline 0, awaited 5). It times out at 2 min.
2. C moves to M2, and M2 funds C with 10 (B: baseline 0, total 10, others 5, awaited 15).
3. Only B lands, so C = 10.
4. On the next `resolve`, A passes (`10 >= 0 + 5`) and toasts **"Funded 5 GNUS to C"**. M1 sent
   nothing that arrived.

After that, B needs 15 and ends "Not confirmed yet" even though its own money arrived. M1's 5-GNUS
hold is released while A can still land, which reopens the CR-01 over-commit (c). A still has to be
trusted when B lands (within 6 min of A's baseline), and in dev-mock confirm mode B lands after 3 s.
The recover mirror is the same. The new test only covers M1 10 followed by M2 5, where the order
hides this.

**Fix:** When a fund or recover is appended, add its own new amount to every other-account op of
the same kind and target. Then each side waits for the other. The worst case is "Not confirmed yet".
```dart
// ChildOperation.copyWith gains `BigInt? otherAttemptsMinions`.
for (final existing in state.operations)
  if (!replaces(existing))
    _hasAmount(kind) && sameKindAndTarget(existing)
        ? existing.copyWith(
            otherAttemptsMinions:
                (existing.otherAttemptsMinions ?? BigInt.zero) + amountMinions!,
          )
        : existing,
```
Bump by `amountMinions`, not `totalMinions`: the carried part was already added when the replaced
op was submitted. Add the reversed-amounts test (M1 5, then M2 10, only M2's lands, nothing resolves).

### CR-02: A retry that inherits a baseline drops the other-account attempts that baseline predates

**File:** `lib/child_wallets/child_operations_cubit.dart:315-319, 323-345`

**Issue:** `inherited` keeps `replaced.baselineMinions`, but `otherAttemptsMinions` is recomputed
from the current list. An other-account op that was in the replaced op's snapshot and has since
landed and resolved is no longer in that list. Its landing is still inside the inherited baseline's
delta, though, so the retry counts it as its own money.

Trace, with C at 0:
1. M1 fund O = 10 times out.
2. M2 fund R = 5 (baseline 0, others 10).
3. O lands, C = 10, and O resolves correctly. R needs 15 and stays.
4. R times out. Within 4 min of R's baseline, M2 retries with X = 5. `resolve()` leaves R because
   `10 < 15`. X inherits baseline 0 and carries 5, and its others is 0 because O is gone. So
   awaited = 10.
5. The next `resolve` passes X (`10 >= 0 + 10`) and toasts **"Funded 10 GNUS to C, including an
   earlier attempt"**. Neither of M2's attempts landed, and M2's 10-GNUS hold is released while
   both can still land (c).

**Fix:** When the baseline is inherited, inherit the others total with it. With CR-01's bump in
place, `R.otherAttemptsMinions` already covers every other-account amount since R's baseline:
```dart
otherAttemptsMinions: inherited != null
    ? inherited.otherAttemptsMinions
    : otherAttempts,
```
Add the O-lands-then-M2-retries test above.

### CR-03: A Recover resolves on a 0 balance read, which the SDK defines as possibly "not yet synced"

**File:** `lib/child_wallets/child_operations_cubit.dart:147-149, 440-442`;
`lib/child_wallets/child_operation_dialogs.dart:40-45, 107-110`

**Issue:** `GeniusSDKGetChildBalanceAll` returns 0 both for an empty child and for one the local
CRDT view has not synced yet (`GeniusSDK.h:586-588, 596-598`; the phase-36 research lists it as
Pitfall 5). `_signalMet` for recover is `current <= baseline - awaited`. Any trusted recover passes
on a 0 read, because `amount <= payingBalance <= baseline`. The result is **"Recovered X GNUS from
C"** and the child-side hold is released while the recover can still land.

Iteration 3 made this more reachable. `startFund`/`startRecover` now call `registry.resolve()`
straight after `ensureRunningAs`, which can have just switched the node to another account and
restarted it. That is the moment a child's balance is most likely unsynced, and it happens while an
earlier recover (from M1, timed out, under 6 min old) is still trusted. The screen's own footnote
admits "Balances come from the node's synced view and can lag". A partial sync that under-reads is
the same failure with a non-zero number.

**Fix:** Never resolve a recover on a 0 read. A recover that empties the child then ends "Not
confirmed yet", which is the accepted conservative outcome. Mark it:
```dart
case ChildOperationKind.recover:
  // ponytail: 0 also means "not synced" to the SDK, so a recover that
  // empties the child ends "Not confirmed yet"; upgrade path is a tx receipt.
  final current = _childBalance(op.target);
  return _baselineTrusted(op, now) &&
      current > BigInt.zero &&
      current <= op.baselineMinions! - _awaited(op);
```
Add a test: a recover of 10 from 100 times out, the read drops to 0, and nothing resolves.

## Warnings

### WR-01: A Fund baseline read as 0 by an unsynced node lets a pre-existing balance read as the fund landing

**File:** `lib/child_wallets/child_operations_cubit.dart:332-334, 438-439`

**Issue:** The same 0 ambiguity applies to the baseline. After `ensureRunningAs` switches the node,
the Fund baseline is read at `submit()` a few seconds later. If C is not synced yet, the baseline is
0. Once C syncs to its real balance, say 50, a fund of 10 passes `50 >= 0 + 10` and toasts
"Funded 10" before anything has landed. This is a WARNING rather than a BLOCKER because it needs the
main's own balance (`payingBalance`) to have synced while the child's has not. The code has no way
to tell a real 0 (a newly registered child being funded for the first time) from an unsynced 0.

**Fix:** Cheapest honest option: when the fund baseline reads 0 and `ChildWalletsCubit`'s last OK
row for that child showed a non-zero balance, refuse the submit ("Balances are still syncing. Try
again."). Alternatively, record a zero-baseline fund as unresolvable on the balance (it ends "Not
confirmed yet") and mark that with a `ponytail:` comment.

---

_Reviewed: 2026-09-29_
_Depth: deep_
