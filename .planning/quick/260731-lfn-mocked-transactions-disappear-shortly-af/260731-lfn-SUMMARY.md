---
phase: 260731-lfn
plan: 01
subsystem: transactions
tags: [dev-tools, sgnus, rxdart, hive]

requires: []
provides:
  - "SGNUSTransactionsController.addTransaction now yields transactions that survive every SDK poll (setTransactions), releasable only via clear()"
  - "Regression test reproducing the disappearance itself (not just post-injection presence)"
affects: [transactions, dev-tools-bubble]

tech-stack:
  added: []
  patterns:
    - "Split SDK-owned vs locally-added state inside a stream controller, with one private emitter folding all emission sites into a single union"

key-files:
  created:
    - test/dev/mock_transactions_sticky_test.dart
  modified:
    - packages/genius_api/lib/controllers/sgnus_transactions_controller.dart
    - lib/dev/dev_tools_bubble.dart

key-decisions:
  - "Fixed at the controller (the single addTransaction caller's contract), not by gating the poll behind a dev flag - a dev-flag gate would have frozen real SGNUS transactions too and missed the router.dart:61 trigger entirely"
  - "Deduped the locally-added set by Transaction.hash (a Map<String, Transaction>) rather than adding value equality to the Transaction model - Transaction is a Hive model used across the whole app; that upgrade is out of scope for this quick task"

requirements-completed: [QUICK-260731-LFN]

coverage:
  - id: D1
    description: "Locally-added SGNUS transactions (Mock txns fixtures) survive every SDK poll (setTransactions) and are released only by clear()"
    requirement: "QUICK-260731-LFN"
    verification:
      - kind: unit
        ref: "test/dev/mock_transactions_sticky_test.dart#fixtures survive an SDK refresh that returns nothing"
        status: pass
      - kind: unit
        ref: "test/dev/mock_transactions_sticky_test.dart#fixtures survive an SDK refresh that returns a real transaction"
        status: pass
      - kind: unit
        ref: "test/dev/mock_transactions_sticky_test.dart#Clear releases the fixtures"
        status: pass
    human_judgment: false
  - id: D2
    description: "Real SGNUS feed behaviour unchanged - the SDK-owned set is still replaced wholesale by setTransactions when nothing has been added locally"
    requirement: "QUICK-260731-LFN"
    verification:
      - kind: unit
        ref: "test/dev/mock_transactions_sticky_test.dart#a real transaction from the SDK is still replaced by the next SDK refresh"
        status: pass
    human_judgment: false
  - id: D3
    description: "A second press of Mock txns replaces the 11 fixtures rather than appending a duplicate 11 (Transaction has no value equality; dedupe now keyed by hash)"
    requirement: "QUICK-260731-LFN"
    verification:
      - kind: unit
        ref: "test/dev/mock_transactions_sticky_test.dart#two presses of the button do not duplicate: 11 rows, not 22"
        status: pass
    human_judgment: false
  - id: D4
    description: "The fix survives BOTH real-world triggers - the 10s SgnusTransactionsScreen timer and the StartSGNUSTransactionsStream router.dart:61 navigation dispatch - because both converge on the single setTransactions call this fix protects against"
    verification:
      - kind: unit
        ref: "test/dev/mock_transactions_sticky_test.dart (setTransactions is called directly, which is the one line both triggers end on per genius_api.dart:879)"
        status: pass
    human_judgment: true
    rationale: "No live SDK/node was available this session to run the app and drive the actual 10s timer or a real navigation. The structural proof (both triggers dispatch StartSGNUSTransactionsStream -> AppBloc._onStartSGNUSTransactionsStream -> api.streamSGNUSTransactions() -> setTransactions(ret), confirmed by reading router.dart:61 and app_bloc.dart:502-507) is strong but a human live walk is the final confirmation Jakub asked for."
  - id: D5
    description: "Toast is honest: states 11 (not 8) and that fixtures are sticky until Clear, matching the panel's existing convention"
    verification:
      - kind: other
        ref: "lib/dev/dev_tools_bubble.dart:410-416 read back after edit"
        status: pass
    human_judgment: false

duration: ~50min
completed: 2026-07-31
status: complete
---

# Quick Task 260731-lfn: Mock transactions no longer disappear Summary

**Fixed `SGNUSTransactionsController` to keep an SDK-owned set and a separately-tracked, hash-deduped locally-added set, so `Mock txns` fixtures survive every SDK poll and are released only by `Clear`.**

## Performance

- **Duration:** ~50 min
- **Completed:** 2026-07-31
- **Tasks:** 3/3
- **Files modified:** 2 modified, 1 created

## The confirmed cause

**Hypothesis (c) - confirmed, exact mechanism traced end to end:**

1. `dev_tools_bubble.dart:398-416` - `Mock txns` writes SGNUS fixtures one at a time via `getSGNUSTransactionsController().addTransaction(tx)`.
2. `sgnus_transactions_screen.dart:32-34` - `Timer.periodic(const Duration(seconds: 10))` dispatches `StartSGNUSTransactionsStream()`. `router.dart:61` fires the same event on every navigation (`LoadWallets()` + `StartSGNUSTransactionsStream()` together, gated on `subscribeToWalletStatus == AppStatus.initial`).
3. `app_bloc.dart:502-507`'s `_onStartSGNUSTransactionsStream` calls `api.streamSGNUSTransactions()`, which ends at `genius_api.dart:879` on `getSGNUSTransactionsController().setTransactions(ret)`.
4. `setTransactions` (`sgnus_transactions_controller.dart`, pre-fix) opened with `_transactions.clear()` - the SAME set `addTransaction` had just written to. So the fixtures lived at most ten seconds, and were gone the instant the user navigated.

**Verdict on all four hypotheses:**
- **(a) Wallet-address filtering: DISPROVED**, as the plan predicted - render path never reads an address.
- **(b) `Set` identity: TRUE, confirmed by grep and by test.** `grep -n "operator ==\|hashCode\|Equatable" packages/genius_api/lib/models/transaction.dart` returned nothing - `Transaction` is a plain Hive class with no value equality. Case 5 of the new test (`two presses of the button do not duplicate`) failed against the pre-fix build with 22 entries emitted from 11 fixtures pressed twice, confirming the `Set<Transaction>` was identity-based.
- **(c) Two sources of truth, one rebuilt from the SDK on a timer: CONFIRMED as the live cause.** This is what Task 2 fixes.
- **(d) Persistence asymmetry via a wallet reload: NOT the live cause, confirmed cheaply.** `grep -rn "\.clear()" lib/ --include=*.dart | grep -i transactionscubit` shows only `dev_tools_bubble.dart:744` as a caller - nothing else clears `TransactionsCubit`, so no wallet reload is silently dropping the non-SGNUS mocks either.

## Task 1: RED-first reproduction

Created `test/dev/mock_transactions_sticky_test.dart` with five cases, importing only `package:genius_api/controllers/sgnus_transactions_controller.dart`, `package:genius_api/models/transaction.dart`, and `package:genius_wallet/dev/dev_mock_transactions.dart` (no barrel import, no FFI). Each case builds a fresh controller, injects fixtures via `addTransaction` exactly as the dev button does, then calls `setTransactions(...)` directly to simulate the poll - the exact line both the 10s timer and the router-navigation trigger converge on.

**Baseline run against the pre-fix build** (exactly as Task 1 required):

```
+0: fixtures survive an SDK refresh that returns nothing (FAILS today) [E] - Expected 11, Actual 0
+0: fixtures survive an SDK refresh that returns a real transaction (FAILS today) [E] - Expected 12, Actual 1
+2: a real transaction from the SDK is still replaced by the next SDK refresh (PASSES today, must keep passing)
+3: Clear releases the fixtures (PASSES today, must keep passing)
+3: two presses of the button do not duplicate: 11 rows, not 22 (FAILS today) [E] - Expected 11, Actual 22
```

Exactly 3 failing, 2 passing - matching the plan's `done` criteria precisely, confirming the diagnosis was correct before any fix was made.

**One authoring bug caught and fixed in the test itself, before treating the baseline as trustworthy:** the first draft asserted on `emitted.map((tx) => tx.hash).toSet()` for every case, including the no-duplicate case. Converting straight to a `Set<String>` silently collapses 22 identity-distinct `Transaction`s with 11 unique hash values down to a set of length 11 either way - so that assertion would have passed whether or not the duplication bug existed, making case 5 a false negative. Fixed by asserting `.length` on the raw emitted `List<Transaction>` for counts, and reserving the hash-set conversion for membership checks only (`hashes.contains('0xreal01')`). Re-ran against the pre-fix build afterward to confirm the corrected assertion still produced the expected 22-not-11 failure.

## Task 2: The fix

`SGNUSTransactionsController` now holds two collections:
- `_transactions` (`Set<Transaction>`) - the SDK feed's own set, written only by `setTransactions`, which still does `clear()` + `addAll(newTxs)` exactly as before. Real feed behaviour is unchanged.
- `_locallyAdded` (`Map<String, Transaction>`, keyed by `hash`) - written only by `addTransaction`. Keying by hash rather than using a `Set<Transaction>` is what makes a second press replace rather than append, since `Transaction` has no value equality.

A single private `_emit()` folds all three emission sites (`addTransaction`, `setTransactions`, and the constructor's initial empty emission is left as-is) into one place, emitting `[..._transactions, ..._locallyAdded.values].reversed` as an unmodifiable list - preserving the existing `List.unmodifiable(...reversed...)` contract callers already depend on. `clear()` empties both collections and emits `[]`, unchanged in shape from before, and remains the only method that releases `_locallyAdded` - `dev_tools_bubble.dart:744-748`'s `Clear` button needed no code change.

Marked the hash-keyed dedupe with a `ponytail:` comment naming the ceiling (linear scan over `_locallyAdded.values` on every emit - fine at 11 entries, not at thousands) and the real upgrade path (value equality on `Transaction` itself, out of scope here).

**Deleted** the old trailing comment claiming `_transactions.add(transaction)` "Will use freezed's equality implementation" - it was false (`Transaction` is a plain Hive class, confirmed by the Task 1 grep) and was exactly the claim that hid the duplication bug from the next reader. Confirmed `grep -c 'freezed' packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` now returns `0`.

All 5 cases pass after the fix:
```
+0: fixtures survive an SDK refresh that returns nothing (FAILS today)
+1: fixtures survive an SDK refresh that returns a real transaction (FAILS today)
+2: a real transaction from the SDK is still replaced by the next SDK refresh (PASSES today, must keep passing)
+3: Clear releases the fixtures (PASSES today, must keep passing)
+4: two presses of the button do not duplicate: 11 rows, not 22 (FAILS today)
+5: All tests passed!
```

## Task 3: Honest toast, then every gate

Read the toast region first (`dev_tools_bubble.dart:398-416`) - it matched the plan's soft-conflict prediction exactly (still the four lines at 410-415, untouched since the plan was written), so no stop-and-report was needed. Changed:

```dart
message: 'Added 8 mock transactions',
```
to
```dart
message: 'Added 11 mock transactions. STICKY until Clear.',
```

11 matches `DevMockTransactions.instance.batch()`'s actual length (verified by reading the file - it has been 11 since the batch was widened to cover all seven `TransactionType` values). "STICKY until Clear." matches the exact phrasing the panel's other fixtures already use (found at `dev_tools_bubble.dart:1114`, `:1136`, `:1160`), restoring the convention this task exists to fix.

### Gate results (quoting real output)

**`flutter analyze`:** `No issues found! (ran in 164.1s)` - post-change count is 0. No separate whole-repo pre-change run was captured before starting Task 1 (an honest gap in my own process - I should have run it before touching any file). Since the post-change count is the floor (0, the tool's exit-0 success state), the delta attributable to these three files cannot be positive regardless of what the pre-change count was.

**`flutter test` (full suite):** `929 passed, 1 failed` (final line: `07:22 +929 -1: ... Some tests failed.`). The one failure:
```
test/dashboard/compute_balance_unit_track_test.dart: the width cost is measured, not estimated, at both widths at 320.0px, with a large minions balance [E]
```
This is a `dashboard/compute` test - per this session's stated concurrency note, `260731-kc5` owns `lib/dashboard/compute/compute_panel.dart` and is mid-edit. **This is named as pre-existing/concurrent, not my regression** - it touches none of my three files (`sgnus_transactions_controller.dart`, `dev_tools_bubble.dart`, `test/dev/mock_transactions_sticky_test.dart`), and I did not touch anything under `lib/dashboard/compute/`. Two `EXCEPTION CAUGHT BY RENDERING LIBRARY` blocks also appeared later in the run (`tokens/coin_page_range_tile_test.dart`, a `RenderFlex overflowed` in `token_info_screen.dart`) but did not add to the cumulative failure count (`-1` stayed at `-1` through to the final line) - Flutter caught and logged them without failing the assertion, and neither file is mine.

The new test file's own 5 cases ran silently within the full-suite output (the compact reporter overwrites fast-completing tests' progress lines and did not print each of my file's individual test names to the piped log), but the cumulative failure count staying at exactly 1 (the pre-existing compute-panel failure) through to the end confirms all 5 of my new cases passed within the full run too, consistent with the isolated re-run above.

**`tool/check_brace_style.sh`:** exit 0.
**`tool/check_raw_colors.sh`:** exit 0.

**`git status`:** exactly three files touched (`packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` modified, `lib/dev/dev_tools_bubble.dart` modified, `test/dev/mock_transactions_sticky_test.dart` new/untracked). No commit created.

## Files Created/Modified
- `test/dev/mock_transactions_sticky_test.dart` - new regression test, 5 cases, reproducing the disappearance itself
- `packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` - split SDK-owned vs locally-added state, hash-deduped local set, single `_emit()` union
- `lib/dev/dev_tools_bubble.dart` - toast now says 11 (not 8) and states the fixtures hold until Clear

## Decisions Made
- Fixed at the controller rather than gating the poll behind a dev flag (see key-decisions in frontmatter for the rejected alternative and why)
- Deduped by `Transaction.hash` via a `Map`, not by adding value equality to the `Transaction` model (out of scope - a Hive model used app-wide)

## Deviations from Plan

None beyond the test-authoring self-correction described in Task 1 above (a flaw in my own first-draft assertion, caught and fixed before treating the baseline as trustworthy - not a deviation from the plan's instructions, which explicitly required asserting on hashes; the fix was correcting my own implementation of that instruction).

## Second defect (Transaction has no equality) - what was done about it

Confirmed via grep (`operator ==`/`hashCode`/`Equatable` all absent from `transaction.dart`) and via the pre-fix test (case 5 emitted 22 entries from two presses of an 11-fixture batch). **Fixed at the controller only**, by keying `_locallyAdded` on `Transaction.hash` (a `Map<String, Transaction>` instead of a `Set<Transaction>`) so a second press replaces rather than appends. **Did NOT add value equality to the `Transaction` model itself** - per the plan's explicit instruction, that is a Hive model used across the whole app and out of scope for this quick task. **Did correct the false comment**: deleted "Will use freezed's equality implementation" from the old `_transactions.add(transaction)` line - it was never true (no freezed, no Equatable, no manual `operator ==`) and was the exact claim that would have stopped the next reader from noticing the duplication. Verified by `grep -c 'freezed' packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` returning `0`.

## Issues Encountered
- Full-suite `flutter analyze` and `flutter test` runs each took several minutes; ran them in the background and polled rather than blocking, per this environment's guidance.
- No live app/SDK instance was available this session, so the two real-world triggers (10s timer, router navigation) could not be walked manually - covered structurally instead (both dispatch the same event, handled by the same bloc method, ending on the same `setTransactions` call the test exercises directly). See D4 in the coverage block above.

## Next Phase Readiness

Nothing blocks Jakub's own walk. Working tree is dirty as required (no commit made) with exactly the three named files touched. Concrete walk steps below.

### Walk steps for Jakub

1. Run with `--dart-define=GW_DEV_TOOLS=true`, open the dev tools bubble on an SGNUS wallet.
2. Press **Mock txns**. Confirm the toast now reads "Added 11 mock transactions. STICKY until Clear."
3. Wait at least 15 seconds without touching anything (past at least one 10-second poll). Confirm the 11 rows are still on screen.
4. Navigate away from the transactions screen and back. Confirm the rows survive the navigation (this is the `router.dart:61` trigger).
5. Press **Clear**. Confirm the rows are gone.

---
*Phase: 260731-lfn*
*Completed: 2026-07-31*
