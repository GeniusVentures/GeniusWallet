---
phase: 37-child-write-operations-pending-model
reviewed: 2026-09-29T12:11:37Z
depth: deep
iteration: 4
files_reviewed: 6
files_reviewed_list:
  - lib/child_wallets/child_operations_cubit.dart
  - lib/child_wallets/child_operation_dialogs.dart
  - lib/child_wallets/child_operation_status.dart
  - lib/child_wallets/child_wallets_screen.dart
  - test/child_wallets/child_operations_cubit_test.dart
  - test/child_wallets/child_operation_actions_test.dart
findings:
  critical: 0
  warning: 5
  info: 3
  total: 8
status: clean
---

# Phase 37: Code Review Report (iteration 4)

**Reviewed:** 2026-09-29
**Depth:** deep
**Files Reviewed:** 6
**Status:** issues_found

## Summary

This pass read `git diff b45d1f63..HEAD` against the whole cubit. It traced `submit()`,
`resolve()`, `_signalMet`, `balanceLockReason`, `_committed` and the poll, plus the callers:
`ensureRunningAs`, the account drawer's switch lock, `DevMockChildWallets`, and
`GeniusApi.getChildBalanceAll`/`selectGeniusAccountAsync`.

The simplification works. Deleting the carry and merge code removes all three iteration-3 false
"done" traces rather than patching them. The one-per-child lock holds as an invariant. No BLOCKER
could be proven. The remaining risk is **where** a balance is read, not how the ops are
combined: a timed-out op keeps resolving for four more minutes across an account switch
(WR-01). Its expiry also depends on a wall clock that the `expired` flag does not guard (WR-02).

Answers to the brief:

- **(a) False "done":** no path is left inside the registry's own accounting. Two paths remain
  through the read itself. WR-01 is a baseline from one node view compared with a read from
  another, after a switch. WR-03 is a mixed mock/real source in debug builds. A backwards clock
  step can also revive an expired op (WR-02). "Other movement" and the 0-baseline fund are the
  documented ceilings.
- **(b) Lock:** sound. `submit()` and `resolve()` are synchronous, so nothing interleaves. The lock
  check and `replaces` read the same `state.operations` in one turn. `balanceLockReason` has no
  account filter, so an op from another account after a switch is refused (the new tests prove
  both of iteration 3's traces). At the exact boundary `_baselineTrusted` and `expires` both use
  the same `now`, so the op cannot resolve and expire in the same pass. The lock can't get stuck:
  every holding op comes from `submit()`, which starts the timer, and the timer is cancelled only
  when nothing holds. The one exception is the wall clock (WR-02).
- **(c) Reservations:** no double count beyond the documented "landed but not yet resolved"
  window. `startFund` calls `resolve()` first, which narrows that window. Releasing a hold at
  expiry can over-commit a fund still in flight (IN-03).
- **(d) Writes:** a grep of `lib/` and `packages/genius_api/lib` finds the six wrappers and
  `submitWrite` called only from `submit()` (`child_operations_cubit.dart:351-374`). Clean.
- **(e) Poll and `expired`:** the poll stops at the emit where every op is notConfirmed and nothing
  holds. It keeps running through the 2-6 min window and emits at expiry, and
  `ChildWalletRow`/`_AmountDialog` rebuild from that emit. So the menus unlock with no refresh,
  up to 10 s after the 6-minute mark. No test exercises this (WR-04).
- **(f) AGENTS.md:** braces, colours, no plan IDs, LF endings and the ponytail markers are all
  fine. Two doc comments this diff touched exceed 3 lines (WR-05).

## Resolved from earlier iterations

| ID | Status |
|----|--------|
| it.3 CR-01 later other-account attempt resolves the earlier op | Resolved. A second fund/recover on the child is refused at `submit()` (`:305-310`); test "after the child moves…" |
| it.3 CR-02 inherited baseline drops other-account attempts | Resolved by deletion. No inheritance; the baseline is always read at submit (`:346`) |
| it.3 CR-03 recover resolves on a 0 read | Resolved for 0 (`:454`). The non-zero half (an under-read after a switch) is WR-01 |
| it.3 WR-01 fund baseline read as 0 before sync | Accepted ceiling (amendment), marked `ponytail:` at `:443-445` |
| it.2 WR-01..WR-03 (baseline age, `replaces` payer, retry never checks) | Superseded. The machinery is gone; the 6-min trust window and resolve-before-dialog are kept |
| it.1 CR-01 concurrent funds exceed balance | Holds while an op holds; released at expiry (IN-03) |
| it.1 CR-02, WR-01..WR-04 | Resolved, unchanged |

## State model (fund / recover)

| State | `notConfirmed` / `expired` | Holds + locks child | Can resolve |
|-------|----------------------------|---------------------|-------------|
| Pending | F / F | yes | yes |
| Timed out | T / F | yes | yes, until `submittedAt + 6 min` |
| Expired | T / T | no | no (by the clock only, see WR-02) |
| Resolved | removed, in `justResolved` | no | n/a |

Transitions: submit OK -> Pending (refused while any holding op is on the child; drops expired
fund/recover ops on it). Resolve: signal met -> Resolved. At >= 2 min -> Timed out. At >= 6 min
-> Expired (it can go straight from Pending if the first resolve is late). A restart forgets
everything. Invariant: **at most one holding fund/recover per child (case-insensitive), from any
account**. It holds because the lock and `replaces` are evaluated synchronously on the same
list.

## Warnings

### WR-01: A timed-out fund/recover keeps resolving on another account's node view after a switch

**File:** `lib/child_wallets/child_operations_cubit.dart:440-455, 181-185`;
`lib/child_wallets/child_operation_dialogs.dart:45, 110`;
`lib/child_wallets/child_operation_switch_dialog.dart:34`

**Issue:** The baseline is read on the node running as `op.fromAccount`. SWT-06 (`hasPendingFrom`)
lifts at the 2-minute timeout, but the op stays trusted and keeps resolving until 6 minutes. In
that window any `ensureRunningAs` can switch the node to another account, and the poll and the
`registry.resolve()` straight after the switch (`dialogs:45, 110`) then compare M1's baseline with
the new selection's view of the child. `GeniusSDK.h` says the read comes "from the locally-synced
CRDT UTXO view". D-19 covers only a read of 0. A partial or stale **non-zero** read still passes:

1. M1 recovers 10 from C (baseline 100). It times out at 2 min.
2. At 3 min the user starts any action that needs M2, and the switch lands.
3. `resolve()` reads C on M2's view. Any value in `1..90` toasts **"Recovered 10 GNUS from C"** and
   releases the lock while M1's recover can still land.

A stale-high read does the same to a fund. The poll can also run while `selectGeniusAccountAsync`
is mid-flight: `selectedSDKAccount` still names the old account, and the read comes from an SDK
that is switching. This is a WARNING rather than a BLOCKER only because the SDK does not document
whether the view differs per account. If selecting an account restarts or resyncs the view, it is
a BLOCKER.

**Fix:** Resolve a balance op only on the view that read its baseline. Anywhere else it waits, and
it resolves or expires once the user switches back:
```dart
bool _sameView(ChildOperation op) =>
    runningAccount?.toLowerCase() == op.fromAccount.toLowerCase();
// fund:    return _sameView(op) && _baselineTrusted(op, now) && ...
// recover: return _sameView(op) && _baselineTrusted(op, now) && current > BigInt.zero && ...
```
A round trip M1 -> M2 -> M1 within the window still resolves on a resyncing view. The full fix is to
expire holding ops whenever `SelectSDKAccount` lands, which ends them "Not confirmed yet". Add a
test: recover times out, `running` flips to another account, the read drops to a non-zero value
below the target, and nothing resolves.

### WR-02: `expired` does not stop a resolve; expiry and the lock hang on the wall clock

**File:** `lib/child_wallets/child_operations_cubit.dart:70-72, 110, 446-455, 470-471`

**Issue:** The doc on `expired` says the op "can no longer resolve", but `_signalMet` never reads
the flag. It re-derives trust from `_now()`, which defaults to `DateTime.now`, a wall clock. If the
clock steps backwards (NTP correction, manual change), an expired op becomes trusted again. On a
later rise or fall it resolves against a baseline more than 6 minutes old, which breaks the (a)
bound. A backwards step on a pending op likewise delays `expires` and the timeout, which extends
both the child lock and the SWT-06 switch lock by the size of the step. The recover arm also reads
the balance (`:452`) before the trust check, so expired recovers still hit the FFI on every poll.

**Fix:** Make the flag authoritative:
```dart
bool _signalMet(ChildOperation op, DateTime now) {
  if (op.expired) {
    return false;
  }
  ...
```
Optionally measure elapsed time with a `Stopwatch` started at submit rather than `DateTime`
differences.

### WR-03: Debug builds mix mock and real reads across one op's lifetime

**File:** `lib/child_wallets/child_operations_cubit.dart:127-137, 346, 477-484`;
`lib/dev/dev_mock_child_wallets.dart:83-92, 319-336`

**Issue:** `_devMocked` is re-evaluated on every read, so the baseline and the resolve read can come
from different sources. A real fund with baseline 0 is pending when the tester arms a preset.
`DevMockChildWallets.balanceFor(realAddress)` returns 250 GNUS, which passes `>= 0 + amount`, and
the tester sees a false **"Funded"**. A real pending revoke resolves the same way, because the mock
registrations do not list the real child. In the other direction, `clear()` drops `_addedTo` and
`_removedFrom`, and mock-submitted revokes and detaches then resolve on real reads. Release builds
are unaffected (`kDebugMode`). The dev mocks are the walk-through tool for this very model, though,
so a false toast during a walk misleads the verifier.

**Fix:** Record the source on the op (`final bool mocked`, set from `_devMocked` at submit). In
`_signalMet`, return false when `op.mocked != _devMocked`, which leaves the op to time out or
expire. The alternative is to have `DevMockChildWallets.arm`/`clear` drop the registry.

### WR-04: The poll's new stop condition, the thing that unlocks the menus on time, has no test

**File:** `lib/child_wallets/child_operations_cubit.dart:432-437`;
`test/child_wallets/child_operation_actions_test.dart:409-468`;
`test/child_wallets/child_operations_cubit_test.dart:395-465`

**Issue:** Every new expiry test sets `now` to 6 min and calls `resolve()` by hand. Reverting line
434 to the old `remaining.every((op) => op.notConfirmed)` would stop the poll at the 2-minute
timeout. The menu would then stay locked until a manual refresh or restart, and all 2165 tests
would still pass. The fix report's claim that the poll keeps running until expiry and the menus
rebuild on time has no check behind it.

**Fix:** Add one widget test that drives the timer. Inject `now` and submit a fund. Then advance
both `now` and `tester.pump(const Duration(seconds: 10))` past 2 min, where the lock stays, and
past 6 min, where Fund is enabled, with no manual `resolve()` call.

### WR-05: Two doc comments this diff edited exceed the 3-line limit

**File:** `lib/child_wallets/child_operations_cubit.dart:271-275` (5 lines),
`:397-400` (4 lines)

**Issue:** AGENTS.md sets "Doc comment: 3 lines max". This diff grew `submit`'s doc from 4 lines to
5 and `resolve`'s from 3 to 4.

**Fix:** Trim to three lines. For example, `submit`: "Submits [kind] against [target], or returns
null with no SDK call when the side, main, lock or amount is wrong. Appends and emits only on
`RET_OK`."

## Info

### IN-01: "Check again" on an expired op can never change it

**File:** `lib/child_wallets/child_operation_status.dart:77-89`;
`lib/child_wallets/child_operations_cubit.dart:70-72`

**Issue:** An expired fund/recover still renders "Not confirmed yet" with "Check again" until a
restart or the next fund/recover on that child. The lock copy tells the user to "wait a few
minutes". After the wait the badge looks exactly the same, and the button does nothing for it.
**Fix:** Hide "Check again" when `op.expired`, or accept it and say so in the badge semantics.

### IN-02: MAX on Recover submits an op that cannot confirm by construction

**File:** `lib/child_wallets/child_operation_dialogs.dart:505-513`;
`lib/child_wallets/child_operations_cubit.dart:453-455`

**Issue:** MAX fills the child's whole free balance. Under D-19 that recover can only end "Not
confirmed yet", and it locks the child for 6 minutes even when it lands. That outcome is certain,
not "uncertain", and the dialog gives no hint of it.
**Fix:** Add a one-line `GWWarningNote` when the typed amount equals the child's balance, or leave
it as is and note the consequence beside D-19.

### IN-03: Expiry releases a hold whose fund may still be in flight

**File:** `lib/child_wallets/child_operations_cubit.dart:262-269`

**Issue:** At 6 min the hold is released even if the SDK has not yet debited the main. The main can
then fund another child with the same money. Consensus rejects one of the two, so no funds are
lost. The `ponytail:` comment names the "holds until it expires" ceiling but not this consequence.
**Fix:** Extend the existing ponytail with "…and one still in flight after it can over-commit the
paying balance".

---

_Reviewed: 2026-09-29_
_Depth: deep_

## Resolution

All iteration-4 warnings fixed (REVIEW-FIX iterations 5-7), plus: a fund/recover expires for resolution the moment the node switches away from its submitting account, keeping its hold and per-child lock until 6 minutes after submit. Remaining accepted ceilings: a fund whose baseline read 0 before the child synced; a MAX recover cannot confirm. Both carry ponytail comments.
