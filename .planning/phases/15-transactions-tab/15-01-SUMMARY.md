---
phase: 15-transactions-tab
plan: 01
subsystem: dashboard/transactions
tags: [amount-honesty, repudiation, tone, pure-functions, tdd]
requires:
  - txRowContent / TxRowContent / TxAmountTone (12-02)
  - formatTxAmount / exactTxAmount / _fiatLine (12-02)
  - transaction_displays.dart `_toneColor` (12-03)
provides:
  - "process rows: fee as the amount, at outgoing weight, with a `<fiat> fee` value line"
  - "dead rows: the type's real signed amount, overridden to tone=none + `Not charged`"
  - "the type x status amount loop that makes TT-06 permanent"
affects:
  - "15-06 (walk — the strings below are what to read off the screen)"
  - "12-03 row widget + drawer (unchanged code, changed strings)"
tech-stack:
  added: []
  patterns:
    - "Dead status is an OVERRIDE applied after the type branches, never a leading gate — one amount derivation, no per-status duplicate"
    - "Absence over fabrication holds on the new fee line too: unpriced coin drops the value line rather than printing `$0.00 fee`"
    - "Every new assertion proved by a named mutation that reddens it"
key-files:
  created: []
  modified:
    - lib/dashboard/home/widgets/transaction_utils.dart
    - test/dashboard/transaction_utils_test.dart
decisions:
  - "A completed job's fee takes TxAmountTone.outgoing (-> textPrimary), the same full weight a successful send gets — that GNUS is just as gone, so it must not read quieter"
  - "A dead row keeps TxAmountTone.none (-> textSecondary) but now for a NEW reason: not 'there is no number' but 'this number did not move'"
  - "`amount` stays `final`, only `tone` loses it — the definite-assignment guard on the amount is the thing stopping a future arm from forgetting to assign"
  - "DEVIATION: `_emDash` was DELETED from the lib file, not kept. It had zero remaining consumers, and the plan's verification asked for both 'the file still contains _emDash' and 'flutter analyze reports no issues' — mutually exclusive"
metrics:
  duration: ~50 min
  completed: 2026-07-22
requirements: [TT-06]
status: complete
---

# Phase 15 Plan 01: Amount honesty on the two rows that printed a dash Summary

`transaction_utils.dart` gave both a failed transaction and a processing job `amount = '—'` and
demoted the real number to the small grey value line. A job genuinely spends `tx.fees` and that
GNUS genuinely leaves the wallet, so the dash was not caution — it was a missing fact. Both rows
now print a real signed number, and the failed row's `Not charged` line is what stops that number
from asserting a balance change.

45 tests in `test/dashboard/transaction_utils_test.dart` (was 40), of which **8 are new or
rewritten and every one of them was proved to go red against a named mutation** (table below).

## What changed

One function, one block: the amount/tone/value section of `txRowContent`
(`lib/dashboard/home/widgets/transaction_utils.dart`). **No widget code changed at all** —
`transaction_displays.dart` renders `TxRowContent` verbatim, so the visual change is entirely a
change of strings and of which `TxAmountTone` arrives.

### The structural change

The chain went from

```
if (isDead) … else if (process) … else if (swap) … else { transfer/mint/escrow/… }
```

to

```
if (process) … else if (swap) … else { transfer/mint/escrow/… }
if (isDead) { tone = none; valueLine = 'Not charged'; }
```

**Why an override and not a fourth branch.** The literal reading — "a failed row prints the real
signed amount" — has a hole for `TransactionType.process`: a failed job has no transfer amount at
all, so a dedicated failed-branch would have to re-derive the fee, and the two copies would drift.
Running the type first means a failed job automatically prints the same `− 0.42 GNUS` its completed
twin does, and gets `Not charged` on top. One rule, no duplication. That reasoning is in a comment
in the file, because a future reader will otherwise "simplify" it back into a leading gate — and
the failed-job test is there to catch them when they do.

`amount` and `exactAmount` are deliberately left exactly as the type branch computed them. Only
`tone` lost its `final`; `amount` is still definitely-assigned exactly once, and widening it to
`var` would give up the one compiler guarantee that stops a future arm forgetting to assign it.

### The `process` branch

| | Before (12-02) | After |
|---|---|---|
| `amount` | `—` | `− 0.42 GNUS` (`_minus`, `formatTxAmount(tx.fees)`, `tx.coinSymbol`) |
| `tone` | `none` → `textSecondary` | `outgoing` → `textPrimary` |
| `valueLine` | `0.42 GNUS spent` | `$0.36 fee`, or **null** when the coin has no price |
| `exactAmount` | null | `exactTxAmount(tx.fees)` — the 12-03 hover tooltip now works on this row too |

The old `'<fee> <symbol> spent'` string is gone: the amount column carries that now, and repeating
it would state the same fact twice while crowding out the fiat the value line exists for.

## The exact strings — REQUIRED READING FOR 15-06's WALK

Measured, not derived: printed from `txRowContent` against the dev-mock rows and the dev-mock
prices (`GNUS 0.85`, `ETH 3200`) via a throwaway probe, which was deleted after use.

| Dev mock | Row | `amount` | `tone` → colour | `valueLine` | subtitle |
|---|---|---|---|---|---|
| **09** | completed job, GNUS, `fees: '0.42'` | `− 0.42 GNUS` | `outgoing` → `gw.textPrimary` | `$0.36 fee` | `Job 0xdevm...mock` |
| — | the same job as **failed** | `− 0.42 GNUS` | `none` → `gw.textSecondary` | `Not charged` | `Job 0xdevm...mock · Failed` |
| **06** | failed purchase, 100 ETH | `+ 100.00 ETH` | `none` → `gw.textSecondary` | `Not charged` | `Card purchase · Failed` |
| **11** | cancelled sent transfer, 3.5 ETH | `− 3.50 ETH` | `none` → `gw.textSecondary` | `Not charged` | `0xTo... · Cancelled` |
| — | failed sent transfer, 0.75 ETH | `− 0.75 ETH` | `none` → `gw.textSecondary` | `Not charged` | `0x5555...8888 · Failed` |
| — | failed **received** transfer | `+ 0.75 ETH` | `none` → `gw.textSecondary` | `Not charged` | `0x1111...4444 · Failed` |

Four things a walker should specifically check, and one they should NOT report:

1. **The sign is U+2212, not a hyphen.** `− 0.42 GNUS`. If it looks narrow or sits at a different
   height from the `+` on the row above, that is a real finding.
2. **Mock 06 is the "never green" case on screen.** A failed *purchase* is incoming-shaped, so it
   prints `+ 100.00 ETH`. It must be **grey**, not `statusSuccess` green. Green there would be the
   app's success colour on a transaction that failed. There is no failed-*receive* in the dev
   mocks, so mock 06 is the only place this is visible.
3. **Every dead row must still show `Not charged`.** This is load-bearing, not decoration — a
   full-weight `− 0.75 ETH` with no value line reads as a wallet that lost 0.75 ETH. If the line is
   missing or clipped on any failed/cancelled row, that is the defect this whole plan is balanced
   on. Sketch 021 wanted the sign dropped instead; sketch 022 records Jakub overruling that, and
   the override holds **only** because this line stays.
4. **The completed job's `$0.36 fee` must read as a fee, not a transfer.** The word `fee` is the
   only thing distinguishing it.
5. **Do NOT report the `Job 0xdevm...mock` subtitle as wrong data.** The model carries no job id;
   that is a truncated tx hash standing in for one (12-02 documented this). Unchanged here.

**`— ` no longer appears anywhere in this surface**, in any type × status combination. That is
TT-06, and it is now a test loop rather than a claim.

## Why the tones differ between the two rows

This is the part the plan asked to be argued rather than asserted, so it is argued in the code too.

**Completed job → `outgoing` → `gw.textPrimary`.** A completed job genuinely spent that money, so
it must not be quieter than any other spend. The old `none` → `textSecondary` is the treatment for
"this is not really a number" — exactly the claim being removed.

**Dead row → `none` → `gw.textSecondary`.** Three reasons, in order of force:

- `outgoing` → `textPrimary` is the exact ink a successful spend uses, so a failed row at that
  weight is indistinguishable from a completed one when scanning the column — the double-counting
  sketch 021 §2 objected to.
- `incoming` → `statusSuccess` **green** on a failed receive would be actively false.
- `none` → `textSecondary` measures 6.0:1 dark (`#8A8F9D` on `#0C0E14`) and 6.3:1 light (`#5A606E`
  on white). AA text in both appearances, so quiet here is not weak. **Carried forward from the
  plan's measurement, not re-measured in this plan** — see Not verified.

No fourth `TxAmountTone` was added. `none` + `Not charged` + the failed badge + the `· Failed`
subtitle already state it three times over; a fourth tone would need a colour decision and a
contrast measurement in both appearances that no design contract asked for.

## Every new assertion, and the mutation that reddens it

The instruction was that a test which passes against unmodified code is worse than no test. Each
mutation below was applied to `transaction_utils.dart` by exact-literal substitution (a script that
**refuses to write if the target text is absent**, so a silently-skipped mutation cannot be
mistaken for a passing test), the file suite was run, and the file restored from a byte-copy.

| Mutation | Tests it reddens |
|---|---|
| **M1** process `amount` back to `_emDash` | processing-job, job-precision, unpriced-fee, failed-job, **the type × status loop** |
| **M2** process `tone` back to `TxAmountTone.none` | processing-job |
| **M3** process `_minus` → ASCII hyphen | processing-job, job-precision, unpriced-fee, failed-job |
| **M4** unpriced fee falls back to a fabricated `$0.00 fee` | unpriced-fee |
| **M5** restore the leading `if (isDead)` gate | failed-send, cancelled, failed-receive, failed-job, **the loop** |
| **M6** override drops `tone = none` | failed-send, cancelled, **failed-receive**, failed-job |
| **M7** override drops `valueLine = 'Not charged'` | failed-send, cancelled, failed-receive, failed-job |
| **M8** transfer branch `_minus` → ASCII hyphen | failed-send, cancelled, `sign and tone follow the money`, `empty recipients does not throw` |

Coverage check — no new or rewritten test is unproved:

| Test | Reddened by |
|---|---|
| `a processing job prints the fee it spent, at full weight` (rewritten) | M1, M2, M3 |
| `a job fee keeps its full precision for the tooltip` (new) | M1, M3 |
| `an unpriced job fee drops the value line, never fabricates one` (new) | M1, M3, M4 |
| `failed prints the real amount, quietly, and no currency zero` (rewritten) | M5, M6, M7, M8 |
| `cancelled behaves like failed` (rewritten) | M5, M6, M7, M8 |
| `a failed receive is never green` (new) | M5, M6, M7 |
| `a failed job still prints its fee, and still says Not charged` (new) | M1, M3, M5, M6, M7 |
| `no row anywhere prints a dash where the number belongs` (new) | M1, M5 |

The RED phase was also run for real before either implementation edit: Task 1's three tests failed
`+19 -3` against the untouched file, Task 2's five failed `+17 -5` against the Task-1-only file.

`M6` is the one that matters most structurally: it is the mutation under which a failed **receive**
keeps `TxAmountTone.incoming` and would render in `gw.statusSuccess` green. That is T-15-01, and it
is the single assertion standing between the current code and a wallet showing a green success
colour on a transaction that failed.

## Deviations from Plan

**1. [Rule 3 — Blocking] `_emDash` was DELETED from the lib file, against the plan's verification**

- **Found during:** Task 2, at the first `flutter analyze` after the restructure.
- **Issue:** The plan's `<verification>` asks for two things that cannot both be true:
  *"The file still contains `_emDash` (other consumers may exist)"* and
  *"`flutter analyze lib/dashboard/home/widgets` reports no issues."*
  There are **no other consumers**. `grep -rn '_emDash' lib test` returns exactly one declaration
  (`:173`) and, after the restructure, zero references — so keeping it produces
  `warning • The declaration '_emDash' isn't referenced • unused_element`, and analyze does not
  come back clean. Verified empirically, not assumed: analyze reported that exact warning.
- **Fix:** deleted the constant, left a comment in its place recording why it went and where the
  em dash the test loop asserts against now lives. CLAUDE.md's "deletion over addition" points the
  same way, and the plan's *other* verification line — `txRowContent` no longer assigns an em dash
  in any branch — is satisfied more strongly by the constant not existing.
- **Not silently adapted:** the plan's factual claim ("other consumers may exist") is wrong about
  the tree, and this is the item to overrule if the intent was something else.
- **The test-side `const emDash` at `:48` stays**, exactly as the plan required — that is what the
  type × status loop asserts against, and it is independent of the lib-side constant.

**2. [Rule 1 — Stale doc comment] Two doc comments were corrected**

- `TxRowContent.amount` said *"an em dash when there is no transfer amount"* — false as of this
  plan. Now: never empty, every type produces a real number, and `valueLine` is what says whether
  it moved.
- The `TxRowContent` class doc said the fee's *"one survivor is the `process` value line"* — the
  fee moved to that row's amount column. Corrected in place with the plan number.
- Left uncorrected on purpose: `transaction_displays.dart:20-22`'s comment describing `none` as
  *"a dash: failed, cancelled, a processing job"*. That file is another session's active territory
  in this shared tree and the comment is descriptive, not load-bearing. **Flagged for 15-06.**

**3. [Scope] Three tests were renamed, not two**

The plan named only Task 1's rename. `'failed emits one dash and no currency zero anywhere'` is now
`'failed prints the real amount, quietly, and no currency zero'` — the old name asserts the exact
behaviour this plan removes, and leaving it would have made the file lie about itself. All of its
kept assertions are kept, per the plan; only the name and the `expect(content.amount, emDash)` line
changed, plus the dropped `exactAmount isNull` the plan called out.

**4. [Deviation from the stated baseline] The tree's test baseline is not 187**

The task statement gives a baseline of 187 passing / 1 failing. **The measured baseline before any
edit of mine was 193 passing / 1 failing**, and by the end of this plan a clean full run reports
**205 / 1**. My net contribution is **+5 tests** (40 → 45 in `transaction_utils_test.dart`); the
rest arrived in the same tree during the session from the concurrent session's work on
`boot_sequence_test.dart` and `transaction_filters_test.dart`. The invariant that actually matters
is unchanged and holds: **the single failure is `test/local_wallet_storage_test.dart`, pre-existing,
a load failure in a fully commented-out file with no `main()`.** Not fixed, not counted.

**5. [Scope] No commits created, nothing staged.** CLAUDE.md holds the commit gate, the plan's
`<objective>` repeats it, and the task statement repeats it again. The executor's per-task atomic
commit protocol was suppressed for both tasks. `git diff --cached` is empty. No `git add`, no
`git add -A`, no `git commit`. The three other independent change sets in this tree — including
`cmake/*.cmake` and the concurrent session's files — are in exactly the state I found them.

**6. [Scope] `STATE.md` / `ROADMAP.md` not touched**, consistent with every 12-0x summary in this
milestone: the tree is shared, both files already carry the user's and the other session's
uncommitted edits, and touching them would collide.

## Verification actually run

| Check | Command | Real output |
|---|---|---|
| Baseline before any edit | `flutter test` | `00:18 +193 -1: Some tests failed.` |
| Baseline failure identified | `flutter test 2>&1 \| grep -i failed` | `Failed to load ".../test/local_wallet_storage_test.dart": Missing definition of 'main' method.` |
| Task 1 RED | `flutter test test/dashboard/transaction_utils_test.dart` | `+19 -3` — all three new/rewritten job tests red against the untouched file |
| Task 1 GREEN | same | `00:00 +42: All tests passed!` |
| Task 2 RED | same | `+17 -5` — all five new/rewritten dead-row tests red against the Task-1-only file |
| Task 2 GREEN | same | `00:00 +45: All tests passed!` |
| Mutation matrix | 8 mutations, each applied + run + restored | every mutation reddened its intended tests; table above |
| Restored-file green | `flutter test test/dashboard/transaction_utils_test.dart` | `00:00 +45: All tests passed!` |
| Plan verification | `flutter analyze lib/dashboard/home/widgets test/dashboard` | `No issues found! (ran in 7.3s)` |
| No regression | `flutter test` ×2 consecutive | `00:21 +205 -1` and `00:18 +205 -1` |
| No regression, contention-free | `flutter test --concurrency=1` | `02:43 +205 -1: Some tests failed.` |
| Sole failure unchanged | `grep -E "\[E\]"` over the serial run's full log | exactly one distinct line: `loading .../test/local_wallet_storage_test.dart [E]` |
| Dashboard + components in full | `flutter test test/dashboard test/components` | `00:12 +170: All tests passed!` |
| No em dash left in lib | `grep -rn '_emDash' lib test` | one hit, and it is the comment recording the removal |
| Nothing staged | `git diff --cached --name-only` | empty |
| My files only | `git status --short <both files>` | `M lib/.../transaction_utils.dart`, `?? test/dashboard/` (the dir was already untracked) |

### Two intermediate full runs showed extra failures, and neither was mine

A `flutter test` mid-session reported `+202 -4` and a later one `+204 -2`, both with extra failures
in `transaction_filters_test.dart`. Investigated rather than waved off:

- That file passes **45/45 in isolation, three consecutive times**, and again inside
  `flutter test test/dashboard test/components` → `+170: All tests passed!`.
- It tests the filter bar and never calls `txRowContent`; `grep -n 'txRowContent\|TxAmountTone'`
  over it returns nothing.
- Wall-clock for a full run drifted from **18s** early in the session to **4m18s** at the end, on
  the same machine — the concurrent session is building and running its own tests in this tree.
- Re-run with `--concurrency=1` to remove the contention: **`+205 -1`**, one distinct failure.

So these are load-induced widget-test flakes from a shared tree, not a regression. Recorded rather
than hidden, because a `-2` or `-4` in someone else's later run has this explanation — and because
the honest statement is "the failures are not reproducible in isolation or serially", not "the
suite is green".

## Threat mitigations delivered

| Threat ID | Delivered | Test that enforces it |
|---|---|---|
| **T-15-01** (repudiation — a full-weight amount asserting money moved) | `Not charged` kept on every dead row; `TxAmountTone.none` forced by the override regardless of direction | `Not charged` asserted on 4 tests; `a failed receive is never green` asserts `+` amount **and** `tone == none` **and** `isNot(TxAmountTone.incoming)`; M6/M7 both proved to redden them |
| **T-15-02** (DoS — untrusted `tx.fees` reaching text layout for the first time) | `tx.fees` goes through `formatTxAmount` exactly like every other raw amount; its unparseable/NaN/infinite early return — the 37639d5 freeze guard — is untouched and its existing unit tests still pass | `formatTxAmount` group unchanged and green (`NaN`, `Infinity`, `-Infinity`, `not-a-number`, `''`); no arithmetic on constraints, no `AutoSizeText`, no `FittedBox`, no derived `fontSize` was added anywhere |
| **T-15-03** (spoofing — fee fiat) | Accepted as planned: an unpriced or attacker-chosen symbol yields **no** value line, not `$0.00 fee` | `an unpriced job fee drops the value line, never fabricates one` (`coinSymbol: 'NOPE'` → `valueLine` is null, amount still states the fee); M4 proves it |
| **T-15-SC** | No package installed, no `pub add`, no dependency added | `pubspec.yaml` untouched |

## Not verified

- **Nothing was rendered.** No app run, no pump, no golden in this plan. Whether `− 0.42 GNUS` and
  `$0.36 fee` fit the row at the panel's real width, and whether the grey reads as "quiet" rather
  than "disabled" next to a full-weight neighbour, are 15-06 eyeballs. The widget-level
  `transaction_row_test.dart` fit tests pass, but none of them assert the new strings.
- **The contrast figures were carried forward, not re-measured.** 6.0:1 dark and 6.3:1 light for
  `textSecondary` come from the plan; I did not recompute them from `lib/theme/`. The tone mapping
  itself is verified (`transaction_displays.dart:23-27`, `none → gw.textSecondary`), so if those
  numbers are stale the tone is still right and only the justification needs updating.
- **Light mode** — nothing in this plan is appearance-dependent; the same tone maps through
  `GWColors` in both.
- **`transaction_displays.dart` was read, not modified.** Its `_toneColor` mapping is what turns
  this plan's tone decisions into pixels; it needed no change, so it got none.

## Success criteria

- [x] No `TransactionType` × `TransactionStatus` combination produces an em-dash amount — a loop over all 8 types × 4 statuses × 2 directions
- [x] A completed job reads `− <fee> <symbol>` at `outgoing` weight with a `<fiat> fee` value line
- [x] A failed transaction reads the same signed amount its completed twin would — asserted by direct string comparison against the completed row, not a hand-copied literal
- [x] A failed receive is never `incoming`/green; a failed job prints its fee, not a transfer amount
- [x] `Not charged`, the badge resolution and the subtitle status append are all untouched
- [x] A `ponytail:` comment on the override names its ceiling and upgrade path
- [x] No commit created

## Self-Check: PASSED

- `lib/dashboard/home/widgets/transaction_utils.dart` — FOUND (556 lines, modified)
- `test/dashboard/transaction_utils_test.dart` — FOUND (634 lines, 45 tests, all passing)
- `test/dashboard/zz_probe_15_01_test.dart` — CONFIRMED DELETED (temporary probe; `ls test/dashboard/` shows only the four real test files)
- Commits — intentionally none (CLAUDE.md gate); `git diff --cached` empty.
- Files the concurrent session owns (`boot_sequence*`, `.planning/phases/13-*`, `14-*`, `sketches/015-018`, `spikes/`, `cmake/*`) — untouched.
