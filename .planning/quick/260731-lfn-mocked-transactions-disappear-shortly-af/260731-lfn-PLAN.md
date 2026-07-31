---
phase: 260731-lfn
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - packages/genius_api/lib/controllers/sgnus_transactions_controller.dart
  - test/dev/mock_transactions_sticky_test.dart
  - lib/dev/dev_tools_bubble.dart
autonomous: true
requirements: [QUICK-260731-LFN]
must_haves:
  truths:
    - "Pressing `Mock txns` puts transactions on screen and they are still there minutes later, through every 10s SGNUS poll and every route change."
    - "Pressing `Clear` removes them, and nothing else does."
    - "Pressing `Mock txns` twice shows 11 rows, not 22."
    - "A real SGNUS transaction arriving from the SDK is still shown, alongside the fixtures, and is never dropped by the fix."
  artifacts:
    - packages/genius_api/lib/controllers/sgnus_transactions_controller.dart
    - test/dev/mock_transactions_sticky_test.dart
  key_links:
    - "`SGNUSTransactionsController.setTransactions` is the SDK feed's writer and MUST NOT own locally-added transactions."
    - "`dev_tools_bubble.dart:748` already calls `getSGNUSTransactionsController().clear()`, so `clear()` staying the single release path means the Clear button needs no change."
---

<objective>
`Mock txns` in the dev panel injects a batch of fixtures that vanish within about ten
seconds. Make them behave like every other fixture in that panel: sticky until `Clear`.

Purpose: Jakub cannot walk the transactions surfaces because the fixtures evaporate
mid-walk. He named it on a live walk today: "upewnij sie, ze nie znikaja po moim
klikanciu."

Output: a fix at the cause in `SGNUSTransactionsController`, a regression test that
reproduces the DISAPPEARANCE (not merely the moment after injection), and an honest toast.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@AGENTS.md
@.planning/STATE.md
@packages/genius_api/lib/controllers/sgnus_transactions_controller.dart
@lib/dashboard/transactions/sgnus_transactions_screen.dart
@lib/dev/dev_mock_transactions.dart
</context>

<diagnosis>

## The verdict: hypothesis (c), with an exact mechanism

The transactions are NOT removed from `TransactionsCubit`. They are removed from a SECOND
source of truth that the same dev button also writes to, and that source is rebuilt from
the SDK on a 10-second timer.

Traced end to end, all four links read during planning:

1. `dev_tools_bubble.dart:398-416` - `Mock txns` writes to TWO places. The
   `isSgnus: false` batch goes into `TransactionsCubit.addTransactions`. The
   `isSgnus: true` batch goes into `GeniusApi.getSGNUSTransactionsController()`, one
   `addTransaction` call per fixture.
2. `dashboard_screen.dart:398-416` - `TransactionsDashboardView` branches on the selected
   wallet's type. An SGNUS wallet renders `SgnusTransactionsScreen`, NOT `TransactionsStream`.
   Only the second of those reads `TransactionsCubit`.
3. `sgnus_transactions_screen.dart:32-34` - that screen runs
   `Timer.periodic(const Duration(seconds: 10))` dispatching `StartSGNUSTransactionsStream()`.
   `router.dart:61` fires the same event on navigation.
4. `app_bloc.dart:502-507` calls `api.streamSGNUSTransactions()`, which ends at
   `genius_api.dart:879` with `getSGNUSTransactionsController().setTransactions(ret)` - and
   `setTransactions` (`sgnus_transactions_controller.dart:24-30`) opens with
   `_transactions.clear()`.

So the fixtures live at most ten seconds on the SGNUS wallet, and are gone the instant the
user navigates. That is "zaraz". Note `streamSGNUSTransactions` early-returns when the SDK
is not initialised, which is why this is intermittent rather than universal: with no node
running, nothing wipes them.

## The other three hypotheses, settled

- **(a) Wallet-address filtering: DISPROVED.** `TransactionsSlimView` filters on
  `isSGNUS` and on the selected `Filters` value only (`transactions_slim_view.dart:192-252`).
  No address is consulted anywhere in the render path, so the fixtures' `0xFromMocked01`
  addresses are irrelevant. Do not give the fixtures the wallet's address; it would fix
  nothing.
- **(b) `Set` identity: TRUE but MILD, and it is a SECOND defect.** `Transaction`
  (`packages/genius_api/lib/models/transaction.dart`) is a Hive class with no
  `operator ==`, no `hashCode`, no Equatable and no freezed. Both `Set<Transaction>` fields
  in play are therefore IDENTITY sets, and the comment at
  `sgnus_transactions_controller.dart:18` claiming "Will use freezed's equality
  implementation" is simply false. `batch()` returns fresh instances on every call, so
  pressing `Mock txns` twice appends a second copy of all 11. Fixed here for the controller
  only, by hash. Do NOT add value equality to the `Transaction` model - that is a Hive
  model used across the whole app and is not a quick task.
- **(d) Persistence asymmetry: same shape, different trigger, and NOT the live one.**
  `TransactionsCubit.loadInitial` is additive (`transactions_cubit.dart:17`) and the cubit
  is provided once at `main.dart:321` above the router, so no wallet reload can drop the
  non-SGNUS mocks. Confirm this cheaply in Task 1 rather than assuming it.

## Why the fix goes where it goes

`SGNUSTransactionsController.addTransaction` has EXACTLY ONE caller in the entire repo:
the dev panel. Any caller it ever gains would hit the same trap - a transaction that
silently evaporates on the next poll. A method whose effect expires in ten seconds is a
defective method, not a dev-tool inconvenience, so the fix is to make `addTransaction` mean
what its name says. That keeps the dev-only knowledge out of the package, changes no real
SDK behaviour (the feed still replaces the feed), and needs no change to the `Clear`
button, which already calls `clear()` at `dev_tools_bubble.dart:748`.

The rejected alternative: gating the poll behind a dev flag. It would freeze REAL SGNUS
transactions too, and it would miss the `router.dart:61` trigger entirely.

</diagnosis>

<constraints>

**DO NOT COMMIT AND DO NOT PUSH.** This overrides the GSD atomic-commit default. Jakub
reviews locally and opens the PR into `ui-redesign-port` himself. `AGENTS.md:23` says the
same thing ("Do not create commits"). Leave the work in the tree.

Branch is `redesign/jakub-260730`. The tree carries a full day of uncommitted work from
eight earlier quick tasks. Do not revert, reformat or tidy anything you did not write, and
do not `git stash`, `git checkout --` or `git restore` anything.

No em dashes anywhere, in code, comments, toasts or the summary. Write " - ".

**Concurrent sessions.** `260731-jx5` owns `lib/screens/banxa_buy_screen.dart`,
`lib/banxa/*`, `lib/components/gw_control_track.dart`, `lib/components/gw_timeframe_segment.dart`.
`260731-kc5` owns `lib/dashboard/compute/compute_panel.dart`, `lib/components/wallet_overview.dart`.
This plan touches none of them, so there is no hard conflict.

SOFT conflict, flag it and do not resolve it silently: `lib/dev/dev_tools_bubble.dart` has
no declared owner but was already edited earlier today by another quick task (see the
"Task 1 (2026-07-31)" note at `:735`). Task 3's edit there is confined to the four toast
lines at `:410-415`. If those lines have moved or already say something different when you
get there, STOP and report rather than reshaping someone else's edit.

</constraints>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Reproduce the disappearance in a failing test</name>
  <files>test/dev/mock_transactions_sticky_test.dart</files>
  <behavior>
    - Fixtures survive an SDK refresh that returns nothing: inject the batch, poll, all 11 still emitted. FAILS today.
    - Fixtures survive an SDK refresh that returns a real transaction: 11 fixtures plus the real one. FAILS today.
    - A real transaction from the SDK is still replaced by the next SDK refresh. PASSES today, and must keep passing.
    - Clear releases the fixtures: after clear the emission is empty. PASSES today, and must keep passing.
    - Two presses of the button do not duplicate: 11 rows, not 22. FAILS today.
  </behavior>
  <action>
    Create `test/dev/mock_transactions_sticky_test.dart`. Import ONLY the narrow paths -
    `package:genius_api/controllers/sgnus_transactions_controller.dart`,
    `package:genius_api/models/transaction.dart` and
    `package:genius_wallet/dev/dev_mock_transactions.dart`. Do NOT import the
    `package:genius_api/genius_api.dart` barrel: it pulls the FFI bindings in, and this
    test has no reason to load them.

    Each case builds a fresh `SGNUSTransactionsController`, injects
    `DevMockTransactions.instance.batch(isSgnus: true)` one fixture at a time through
    `addTransaction` (that is exactly what `dev_tools_bubble.dart:405-409` does), then
    SIMULATES THE 10-SECOND POLL by calling `setTransactions(...)` directly - that is the
    single line `GeniusApi.streamSGNUSTransactions` ends on at `genius_api.dart:879`, and
    calling it directly is what lets this run with no SDK, no node and no widget tree.

    Read the current value with `await controller.stream.first`; the backing subject is a
    `BehaviorSubject`, so `first` yields the latest emission rather than waiting for a new
    one. Assert on the SET OF HASHES, never on list order: the emission order is not the
    render order (`groupTransactionsByDay`, `transaction_utils.dart:568-593`, re-sorts by
    timestamp before painting), so an order assertion here would pin something the UI does
    not depend on.

    The "real transaction" in cases 2 and 3 is a hand-built `Transaction` with a hash that
    cannot collide with the fixtures' `0xdevmock01..11` - use something like `0xreal01`.

    Head the file with a short comment recording WHY it exists: the fixtures were wiped by
    `SgnusTransactionsScreen`'s 10s poll, and a test asserting only that injection worked
    would have passed against the broken build. Name the two file:line links (the poll and
    `setTransactions`) so the next reader does not have to re-trace them.

    While you are here, confirm the two planning claims cheaply and record the answer in
    the summary. First: `grep -n "operator ==\|hashCode\|Equatable" packages/genius_api/lib/models/transaction.dart`
    should return nothing, which is what makes case 5 fail today. Second:
    `grep -rn "\.clear()" lib/ --include=*.dart | grep -i transactionscubit` should show
    only `dev_tools_bubble.dart`, confirming hypothesis (d) is not the live cause.

    IF THE FIRST TWO CASES PASS AS WRITTEN, the diagnosis above is wrong. Stop, do not
    start Task 2, and report what you actually observed - a fix aimed at the wrong cause is
    worse than no fix.
  </action>
  <verify>
    <automated>flutter test test/dev/mock_transactions_sticky_test.dart 2>&1 | tail -30; echo "EXPECT: non-zero exit, 3 failing cases (survives-empty-refresh, survives-real-refresh, no-duplicate-on-second-press), 2 passing"</automated>
  </verify>
  <done>The new test file compiles and runs, exactly three cases fail, and the failure text names the fixtures missing after `setTransactions`. The two grep confirmations are recorded.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Make locally-added SGNUS transactions survive the SDK refresh</name>
  <files>packages/genius_api/lib/controllers/sgnus_transactions_controller.dart</files>
  <behavior>
    - All five cases from Task 1 pass.
    - `setTransactions` still replaces the SDK-owned set wholesale, so real feed behaviour is unchanged when nothing has been added locally.
    - `clear()` remains the only path that releases locally-added transactions.
  </behavior>
  <action>
    Split the controller's single `_transactions` set in two. Keep `_transactions` as the
    SDK feed's set, written only by `setTransactions`. Add a second set for transactions
    added through `addTransaction` - name it for what it is (locally added, not owned by
    the feed), not for the dev tool that happens to be its only caller today.

    `setTransactions` keeps its `clear()` plus `addAll(newTxs)` on the feed set and then
    emits the union of both sets. `addTransaction` writes to the local set only. `clear()`
    empties BOTH and emits an empty list, exactly as it does now - it is what the dev
    panel's `Clear` button already calls at `dev_tools_bubble.dart:748`, and it must stay
    the single release path.

    Fold the three emission sites into one small private emitter so the union can never be
    assembled two different ways. Preserve the existing `List.unmodifiable(...reversed...)`
    shape: emission order is not render order, but the emitted list being unmodifiable is a
    contract the current callers already have.

    Dedupe the local set by `hash` on insert, so a second press of `Mock txns` replaces the
    11 fixtures rather than appending a second copy. This is needed because `Transaction`
    has no value equality - the set is identity-based. Mark it with a `ponytail:` comment
    per `AGENTS.md:19`, naming the ceiling: it is a linear scan over the locally-added set,
    which is fine at 11 entries and would not be at thousands, and the real upgrade path is
    value equality on the `Transaction` model itself, which is out of scope here.

    DELETE the trailing comment on the old `_transactions.add(transaction)` line claiming
    the set uses freezed equality. It is false - the model is a plain Hive class - and it is
    exactly the claim that would stop the next reader from noticing the duplication.

    Do not touch `genius_api.dart`, `app_bloc.dart`, `router.dart` or
    `sgnus_transactions_screen.dart`. The poll is correct; it was the writer that was wrong.
  </action>
  <verify>
    <automated>flutter test test/dev/mock_transactions_sticky_test.dart</automated>
  </verify>
  <done>All five cases pass. `grep -c 'freezed' packages/genius_api/lib/controllers/sgnus_transactions_controller.dart` returns 0. `clear()` is still the only method that empties the locally-added set.</done>
</task>

<task type="auto">
  <name>Task 3: Make the toast honest, then run every gate</name>
  <files>lib/dev/dev_tools_bubble.dart</files>
  <action>
    The `Mock txns` toast at `dev_tools_bubble.dart:410-415` says "Added 8 mock
    transactions". The batch is 11 (`dev_mock_transactions.dart:43-213`), and it has been
    11 since the batch was widened to cover all seven `TransactionType` values. Correct the
    count, and say the fixtures are sticky until `Clear` - the panel's other fixtures
    already say so in their own toasts and their tooltips, and that convention is half of
    what this task is restoring. Keep it to those four lines. Read the region first; if it
    no longer matches, stop and report per the soft-conflict rule above.

    Then run every gate from the repo root and QUOTE the real output. Do not claim a
    baseline you did not run (`AGENTS.md:74-76`). The Flutter SDK is not on `PATH` by
    default in this environment - resolve it the way this repo's other sessions do before
    running, and do not skip a gate because the binary was not found on the first try.

    Record the pre-change `flutter analyze` count and the pre-change full-suite pass/fail
    numbers alongside the post-change ones. The tree carries a day of uncommitted work from
    eight other tasks, so a raw post-change number is meaningless on its own - only the
    DELTA attributable to these three files is yours. If the full suite shows failures you
    did not cause, name them as pre-existing rather than fixing them.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -5; flutter test 2>&1 | tail -15; bash tool/check_brace_style.sh; bash tool/check_raw_colors.sh</automated>
  </verify>
  <done>Toast reads 11 and states the fixtures hold until Clear. `flutter analyze` shows no new issue over the pre-change count. The full suite shows no new failure over the pre-change run, plus the new test file's cases passing. Both `tool/` scripts exit 0. Nothing is committed.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| native SDK to app | `streamSGNUSTransactions` reads FFI buffers into `Transaction` objects and hands them to the controller. Unchanged by this plan. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-lfn-01 | Spoofing | `SGNUSTransactionsController.addTransaction` | low | accept | The method now yields transactions that persist across SDK refreshes, so a caller could in principle keep a transaction on screen that the chain does not have. Its one caller is dev-gated behind `kDebugMode && kShowDevTools`, and `clear()` releases them. Accepted rather than mitigated because adding a release-mode guard inside the package would put dev-tool knowledge into production code, which is the coupling this fix exists to avoid. |
| T-lfn-02 | Tampering | dependencies | low | accept | No package installs. No dependency changes. |
</threat_model>

<verification>
1. `flutter analyze` - no new issue versus the pre-change count.
2. `flutter test` - full suite, no new failure, plus the five new cases.
3. `tool/check_brace_style.sh` exits 0.
4. `tool/check_raw_colors.sh` exits 0.
5. `git status` shows exactly three touched files and NO commit created.
6. Manual, optional, for Jakub rather than for the executor: run with
   `--dart-define=GW_DEV_TOOLS=true`, press `Mock txns`, wait past two 10-second polls,
   navigate away and back, confirm the rows are still there, then press `Clear` and confirm
   they go.
</verification>

<success_criteria>
- The disappearance is reproduced by a test that fails against the current build and passes
  after the fix. A test that only asserted presence immediately after injection would have
  passed against the broken build and is not acceptable.
- Injected transactions survive every 10-second poll and every route change, and `Clear`
  still removes them.
- Real SGNUS feed behaviour is unchanged: the SDK still replaces the SDK's own set.
- The report names WHICH hypothesis was true and what disproved the others.
- Nothing is committed and nothing is pushed.
</success_criteria>

<output>
Write `.planning/quick/260731-lfn-mocked-transactions-disappear-shortly-af/260731-lfn-SUMMARY.md`.
It must state the confirmed cause with its file:line chain, the verdict on each of the four
hypotheses, the pre-change and post-change gate numbers, and the soft conflict on
`dev_tools_bubble.dart` if it materialised.
</output>
