---
phase: 37-child-write-operations-pending-model
reviewed: 2026-09-29T00:00:00Z
depth: standard
files_reviewed: 20
files_reviewed_list:
  - lib/account/account_drawer.dart
  - lib/account/sdk_account_manager.dart
  - lib/child_wallets/child_main_picker_dialog.dart
  - lib/child_wallets/child_operation_dialogs.dart
  - lib/child_wallets/child_operation_status.dart
  - lib/child_wallets/child_operation_switch_dialog.dart
  - lib/child_wallets/child_operations_cubit.dart
  - lib/child_wallets/child_wallets_cubit.dart
  - lib/child_wallets/child_wallets_screen.dart
  - lib/components/data/gw_row_badge.dart
  - lib/dev/dev_mock_child_wallets.dart
  - lib/dev/dev_tools_bubble.dart
  - lib/main.dart
  - test/account/sdk_account_rows_test.dart
  - test/child_wallets/child_main_picker_test.dart
  - test/child_wallets/child_operation_actions_test.dart
  - test/child_wallets/child_operation_switch_dialog_test.dart
  - test/child_wallets/child_operations_cubit_test.dart
  - test/child_wallets/child_wallets_screen_test.dart
  - test/dev/dev_mock_child_wallets_test.dart
findings:
  critical: 2
  warning: 4
  info: 0
  total: 6
status: issues_found
---

# Phase 37: Code Review Report

**Reviewed:** 2026-09-29
**Depth:** standard
**Files Reviewed:** 20
**Status:** issues_found

## Summary

Reviewed `git diff 4061095c..HEAD` for the child-write-operations pending model. The amount
path is genuinely double-free of floating point (`BigInt` end to end, `toBaseUnits`/`minionsToGnus`
are integer-only), address comparisons are consistently case-insensitive, `ChildOperationsCubit.submit()`
is confirmed to be the *only* call site for all six SDK write wrappers (verified by grep across
`lib/`), dev mocks are correctly gated behind `kDebugMode && kShowDevTools` with no real-SDK call
reachable while a preset is armed, the 2:00 timeout is exact (`!now.isBefore(submittedAt + timeout)`,
tested at 1:59.999 / exactly 2:00), and the SWT-06 switch-away lock and its await-the-real-signal
switch dialog are both implemented as specced.

However, two money-safety/honesty gaps survive that the UI-SPEC and tests do not cover:

1. **Concurrent same-kind operations from one account, to different targets, are not netted
   against the account's real balance** — each `submit()` call checks the amount against a fresh
   balance read with no knowledge of other already-submitted-but-unconfirmed operations from the
   same account, so two legitimate Fund calls can jointly commit more than the account holds.
2. **A timed-out (`notConfirmed`) operation's tracking is discarded on resubmission**, so its real
   SDK effect — if it lands late — has no owner left to be checked against, and can silently
   satisfy a *different*, newer operation's balance-based resolution instead.

Also flagged: no registry-level guard against a self-referential register/move (relies entirely on
the picker's client-side exclusion set), a badge that can hide a second concurrently-pending
operation on the same target, a private `Widget`-returning helper method that repeats an
AGENTS.md-forbidden pattern, and a resolution toast that is silently dropped if fired before the
root navigator has attached.

## Critical Issues

### CR-01: Concurrent Fund/Recover submissions from one account can jointly exceed its real balance

**File:** `lib/child_wallets/child_operations_cubit.dart:184-198, 205-296`
**Issue:** `submit()`'s amount guard (`amount > payingBalance(kind, target)`) and `payingBalance()`
both read the account's *current* SDK-reported balance at the moment of that single call
(`BigInt.tryParse(_api.getMinionsBalance())` for Fund, `_childBalance(target)` for Recover). Nothing
in `ChildOperationsCubit` sums the amounts of other operations already submitted from the same
account that are still pending (unconfirmed by the node). `isPending(kind, target)` only blocks a
second operation of the *same kind* against the *same target* — it does not block, and
`hasPendingFrom` is never consulted inside `submit()` to block, a second Fund from the same main to
a *different* child.

Concretely: a main with a real balance of 100 GNUS can Fund child A with 60 GNUS (accepted — 60 ≤
100), and, before that Fund's balance change is observed by the node, Fund child B with another 60
GNUS (also accepted — 60 ≤ 100, since the local balance read has not yet moved). 120 GNUS has now
been committed against a 100 GNUS balance, both writes having gone through the one real write path.
No test in `test/child_wallets/child_operations_cubit_test.dart` exercises two concurrent pending
operations from the same account against a shared balance, and neither `37-CONTEXT.md` nor
`37-UI-SPEC.md` calls this out as an accepted ceiling (`ponytail:`) — the only `ponytail:` in this
file is about restart persistence (line 87), not balance netting.

**Fix:** Track a running "committed" total per paying account (sum of `amountMinions` for every
still-pending Fund — and, symmetrically, Recover per child — from that account) and subtract it
from the balance read before comparing:

```dart
BigInt _committedFrom(String account, ChildOperationKind kind) => state.operations
    .where((op) => !op.notConfirmed &&
        op.kind == kind &&
        op.fromAccount.toLowerCase() == account.toLowerCase())
    .fold(BigInt.zero, (sum, op) => sum + op.amountMinions!);

// in submit(), before the amount check:
final available = payingBalance(kind, target) - _committedFrom(requiredRunner, kind);
if (amount > available) { return null; }
```

---

### CR-02: A resubmitted operation can resolve on an unrelated, older operation's late-arriving effect

**File:** `lib/child_wallets/child_operations_cubit.dart:278-285, 335-354`
**Issue:** PEND-02 correctly allows resubmitting the same kind+target once the earlier attempt is
`notConfirmed` (D-16: "Timed-out operations do not lock"). But `submit()` implements this by
**dropping** the old, timed-out operation from `state.operations` entirely (the `for` comprehension
at lines 280-284 filters it out before appending the new one) — its `baselineMinions` and
`amountMinions` are simply forgotten.

If the SDK write behind the abandoned operation was genuinely fire-and-forget and still lands after
the timeout (the SDK docs and `PITFALLS.md` both note there is no tx hash and no reliable
cancellation), its balance delta becomes indistinguishable "unrelated activity" against the *new*
operation's `_signalMet` check (`current >= baseline + amount` for Fund,
`current <= baseline - amount` for Recover). Because `baseline` for the new op was captured *after*
the old op was submitted but *before* its late effect lands, the new op can resolve — with a
"Funded {amount} GNUS" success toast and cleared badge — from a credit that is wholly or partly the
old, abandoned operation's money, not the new operation's own confirmed write. This is exactly the
"can a balance change from unrelated activity resolve the wrong operation" case the review brief
calls out, and it is directly reachable through the shipped retry path (no dev-only gate).
`test/child_wallets/child_operations_cubit_test.dart:362-395` ("after notConfirmed, a new submit
leaves exactly one op for that child") confirms the old op's tracking is discarded, but does not
exercise the old op's write later landing.

**Fix:** Keep the discarded operation's baseline+amount around as an "orphaned" record (at least
until its own funds would have satisfied it, or forever, memory-bounded) so `resolve()` can still
attribute a matching balance delta to it instead of crediting whichever tracked operation happens to
be checked next; or, more conservatively, use a monotonically-increasing sequence/nonce in the
resolve check so a new op only counts a delta that arrives strictly after its own baseline read and
is not already claimed by a still-tracked or newly-orphaned prior op for that account+target+kind.

## Warnings

### WR-01: `submit()` has no registry-level guard against a self-referential register/move

**File:** `lib/child_wallets/child_operations_cubit.dart:205-270`; callers in
`lib/child_wallets/child_operation_dialogs.dart:278-349, 354-427`; exclusion logic in
`lib/child_wallets/child_main_picker_dialog.dart:74-89`
**Issue:** The review brief asks whether any path can "send to a malformed/self address." Today it
cannot, but only because `_MainPickerDialogState._isExcluded`/`excluded` (populated by the two
callers as `{account}` for Register and `{account, oldMain}` for Move) is the *sole* place that
prevents choosing `main == target` or `newMain == target`. `submit()` — documented as "the only
path a write takes" — performs no equivalent check itself. A future caller of `submit()` (another
screen, a fixed picker bug, a test harness) that passes `main == target` or `newMain == target`
would sail through every existing guard (`running` check, `isPending`, amount check — N/A for these
kinds) and call `_api.registerChild(target, ...)` or `_api.replaceMain(target, ...)` against the
node's own address.
**Fix:** Add a cheap self-reference guard inside `submit()` itself:
```dart
if (kind == ChildOperationKind.register && main.toLowerCase() == target.toLowerCase()) {
  return null;
}
if (kind == ChildOperationKind.move && newMain!.toLowerCase() == target.toLowerCase()) {
  return null;
}
```

### WR-02: A badge shows only the most-recently-submitted operation, hiding a concurrently-pending sibling

**File:** `lib/child_wallets/child_operations_cubit.dart:144-153` (`latestFor`); consumed at
`lib/child_wallets/child_wallets_screen.dart:127, 278`
**Issue:** PEND-02 deliberately locks by `(kind, target)`, not by target alone (confirmed by
`37-UI-SPEC.md`'s "partial" row: "Revoke stays available on a row whose Fund is pending"). That
means a child row, or the "This account" card, can legitimately have two operations of different
kinds pending at once (e.g. Fund then Revoke on the same child; Detach then Move on "This account").
`latestFor()` returns only the single most-recently-submitted operation for that target, so the
badge silently stops showing the earlier one the moment the second is submitted — even though its
own menu item is still correctly locked (`isPending` is checked independently per kind). A user
sees "Already funding this child" on a greyed-out Fund item with no visible badge explaining why,
because the row's one badge slot is occupied by the newer Revoke. The success toast for the hidden
operation still fires later (via `justResolved`, independent of `latestFor`), so no money-safety
issue, but it is a real "can anything look less busy than it truly is" gap the UI-SPEC's own
"backstop" note (which only covers *different children*, not same-target/different-kind) does not
address.
**Fix:** Either render every pending operation for a target (a small stack of badges), or make the
"not-confirmed" state, at minimum, additive rather than last-write-wins in the badge slot.

### WR-03: `ChildOperationToasts` silently drops a resolution toast if the navigator hasn't attached

**File:** `lib/child_wallets/child_operation_status.dart:106-125`
**Issue:** `justResolved` is a one-shot signal — it is empty on every emission except the exact one
produced by the `resolve()` call that resolved it. If `navigatorKey.currentContext` happens to be
`null` at that instant (e.g., `resolve()`'s 10s poll fires during a route transition, or very early
in the app's life before the root `Navigator` has mounted), the method returns immediately at line
111-113 and the toast for that operation — the one and only place "Funded X GNUS" is ever
communicated to the user — is lost forever. The row's own data (updated balance/registration list)
still reflects the truth once the screen refreshes, so this is not a data-correctness bug, but for a
money-moving action losing the one explicit confirmation is a real (if narrow) UX/honesty gap.
**Fix:** Retry on the next frame (`WidgetsBinding.instance.addPostFrameCallback`) instead of
dropping silently when `currentContext` is null, or fall back to `scaffoldMessengerKey`-style queuing
already used elsewhere in the toast plumbing if one exists.

### WR-04: `_MainPickerDialogState` repeats the `_buildFoo(): Widget` helper-method pattern AGENTS.md forbids

**File:** `lib/child_wallets/child_main_picker_dialog.dart:112, 169`
**Issue:** AGENTS.md is explicit: "Widgets, not helper methods. Extract to a `StatelessWidget`,
never a `_buildFoo()` returning a `Widget`." `_listContent(BuildContext)` and
`_manualContent(BuildContext)` are private `State` methods returning `Widget` used to switch the
dialog's body — the exact shape the rule names (not `const`-able, invisible to DevTools, rebuilds
the whole dialog State on every keystroke). This mirrors a pre-existing violation already in
`lib/dev/dev_tools_bubble.dart` (`_buildExpandedPanel`/`_buildCollapsedBubble`, not part of this
diff), but this phase adds two new instances of the same anti-pattern rather than following the
`_AmountDialog`/`_AmountDialogState` pattern in the same PR, which correctly stays inline in `build`.
**Fix:** Extract `_MainPickerListContent` and `_MainPickerManualContent` as small `StatelessWidget`s
taking the state they need as constructor parameters (candidates/excluded/nameFor/onPick, and
controller/error/onBack respectively).

---

_Reviewed: 2026-09-29_
_Depth: standard_
