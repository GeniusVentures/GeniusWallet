---
quick_id: 260922-ftu
phase: quick-260922-ftu
plan: 01
type: execute
wave: 1
depends_on: []
autonomous: true
requirements: [FTU-01, FTU-02, FTU-03, FTU-04]
files_modified:
  - test/components/mobile_header_brand_and_pill_test.dart
  - test/submit_job/job_flow_test.dart
  - .planning/todos/pending/2026-09-21-flaky-inter-font-order-dependency.md

must_haves:
  truths:
    - "`flutter test` passes at 1550/5/0 under seeds 1049166414, 2784491144, 2469443488 and one fresh random seed."
    - "Neither failing file depends on which test inside it ran first: each passes alone under 2469443488."
    - "The 106.06 lockup assertion and the exact-affordability assertion are unchanged in value (FTU-03)."
    - "The mark's 21.37 contribution is guaranteed by the pump helper, not by a predecessor test warming the image cache."
  artifacts:
    - .planning/todos/completed/2026-09-21-flaky-inter-font-order-dependency.md
  key_links:
    - "_pumpHeader <-> every width assertion in the header file (the one place the decode is guaranteed)"
---

<objective>
Kill the two order-dependent failures that make CI `quality` a coin flip.

Purpose: three CI failures today across two PRs under three different seeds.
Output: two test-only fixes, proven against all three known seeds plus a fresh one.

**The premise in the todo and in the task brief is wrong, and this is measured, not argued.**
Both files fail ALONE under seed 2469443488 — no second file is in the process. These are
WITHIN-file order dependencies. `flutter test` gives each suite its own `flutter_tester`
process, so the cross-file `'Inter'` registration story cannot be the mechanism.

Failure #1 is not about fonts at all. `BrandLockup` renders
`Image.asset('assets/images/geniusappbarlogo.png', package: 'genius_wallet', height: 28)`
with **no `width`**. Before the PNG decodes, that `Image` is 0 wide, so the enclosing
`Align(widthFactor: 29/38)` contributes 0 instead of `28 * 29/38 = 21.368`.
Measured deficit: `106.06 - 84.693359375 = 21.367`. Exact. The test only ever passed
because some earlier test in the file had already warmed the global `imageCache`; the seed
puts the measuring test first. Proof in the same run: the harness-face test printed
`lockup=106.06178` — real-Inter metrics leaking from an earlier test — so fonts do leak
within a file, just harmlessly here.

Do NOT build a shared `test/support/` Inter loader. It fixes nothing that is broken,
and rung 1 of AGENTS.md is "does this need to be built at all".
</objective>

<context>
@AGENTS.md
@.planning/todos/pending/2026-09-21-flaky-inter-font-order-dependency.md
@lib/components/overlay/mobile_header.dart
</context>

<tasks>

<task type="tracer">
  <name>Task 1: guarantee the mark is decoded before anything measures it</name>
  <files>test/components/mobile_header_brand_and_pill_test.dart</files>
  <precondition>`export PATH="/c/Users/User/Documents/Projects/GNUS/flutter/flutter/bin:$PATH"` — Flutter 3.41.9 is not on PATH.</precondition>
  <action>
In `_pumpHeader`, after the widget is pumped and before it returns, decode the brand mark
through the real async zone, then pump once more:
`await tester.runAsync(() => precacheImage(const AssetImage('assets/images/geniusappbarlogo.png', package: 'genius_wallet'), tester.element(find.byType(BrandLockup))));`
followed by `await tester.pump();`. Fake async cannot drive `instantiateImageCodec`, which is
why `runAsync` is required and `pumpAndSettle` is not enough.
If `precacheImage` proves unreliable under flutter_tester, fall back to decoding the bytes
directly inside the same `runAsync` (`rootBundle.load` then `decodeImageFromList`) — the goal
is only that the global `imageCache` is warm before the measuring frame.
Comment it in two lines saying WHY (an undecoded `Image.asset` with only a height is 0 wide,
so the lockup would measure 84.69). Name no test file in that comment — AGENTS.md, and a
reviewer enforced exactly this today.
Then grep `test/` for other mounts of `BrandLockup` or `MobileHeader` that assert an absolute
width, and fix any the same way — one guard in the shared helper, not one per caller.
Change no assertion value.
  </action>
  <verify>
    <automated>flutter test --test-randomize-ordering-seed 2469443488 test/components/mobile_header_brand_and_pill_test.dart</automated>
  </verify>
  <done>That file passes alone under 2469443488 and in plain file order. 106.06 and 0.05 are untouched. Committed atomically, no Claude attribution.</done>
</task>

<task type="auto">
  <name>Task 2: diagnose, then fix, the job_flow affordability boundary</name>
  <files>test/submit_job/job_flow_test.dart</files>
  <action>
Root cause NOT established — diagnose before touching anything. Established facts: the file
fails ALONE under 2469443488 (so it is an in-file leak, same class as Task 1 but not
necessarily the same state), the assertion at :737 is `continueButton.onPressed, isNotNull`
with `seedJobCost: 10, seedGnusBalance: 10`, and the run emitted `Unable to load asset: ""` twice.

Diagnose in this order, recording the real output of each step:
1. Run that one test alone via `--plain-name 'exactly the job cost'` under the seed. If it
   PASSES alone, a predecessor leaks — that is the expected result and it confirms the shape.
2. Read the seed's printed order, then bisect the predecessors (halve the set with
   `--plain-name`, or temporarily `skip:` the others) down to the single test that poisons it.
3. Inspect that test for mutation of process-global state left unrestored. Strongest lead:
   `SubmitJobCubit` reads `DevMockJob.instance` — a singleton with a mutable `scenario`
   `ValueNotifier` and a `balance` — at four call sites. Also consider a leaked binding mock
   (the empty-asset message hints at one), a static, or an un-disposed listener.
4. Only now fix, at the leak's source: restore the global in `addTearDown` on the test that
   mutates it, so no ordering can carry it forward. Do not adjust the boundary numbers and do
   not loosen the assertion — if the assertion turns out to be genuinely wrong, stop and say so
   with the evidence instead.
If the diagnosis lands on the image cache after all, say so and note Task 1 already covers it.
  </action>
  <verify>
    <automated>flutter test --test-randomize-ordering-seed 2469443488 test/submit_job/job_flow_test.dart</automated>
  </verify>
  <done>The leaking state is named in the commit message with the evidence that identified it. File passes alone under 2469443488 and in file order. Committed atomically.</done>
</task>

<task type="auto">
  <name>Task 3: prove it across every known seed, then close the record</name>
  <files>.planning/todos/completed/2026-09-21-flaky-inter-font-order-dependency.md</files>
  <action>
Run the FULL suite four times: seeds 1049166414, 2784491144, 2469443488, and one fresh random
seed (record which one it drew). Quote the real pass/skip/fail line from each — never a
baseline you did not run. Target is 1550 pass / 5 skip / 0 fail each time; any other number is
a finding, not a rounding error. Also run `flutter analyze` and `bash tool/check_brace_style.sh`.

Then append to `.planning/todos/pending/2026-09-21-flaky-inter-font-order-dependency.md` a
`## RESOLVED 2026-09-22` section in the house style, stating plainly that the recorded
hypothesis was wrong — it is not the `'Inter'` family, it is an undecoded `Image.asset` — and
give the 21.37 arithmetic as the proof. `git mv` it to `.planning/todos/completed/`.
If Task 2 found a distinct cause, write its record straight into `.planning/todos/completed/`
as `2026-09-22-<slug>.md`, problem and resolution in one file; it was never pending, so do not
stage a fake pending entry. Keep both files LF — a CRLF file passes locally and fails CI.
Do not push, do not open a PR.
  </action>
  <verify>
    <automated>flutter test --test-randomize-ordering-seed 2469443488</automated>
  </verify>
  <done>Four seeds quoted with real output, all 1550/5/0. Todo(s) moved to completed/. Committed.</done>
</task>

</tasks>

<success_criteria>
CI `quality` stops being a coin flip: the suite passes under every seed tried, with no
assertion value changed and no `lib/` file touched.
</success_criteria>

<output>
Create `.planning/quick/260922-ftu-fix-the-two-order-dependent-test-failure/260922-ftu-SUMMARY.md` (<= 40 lines) when done.
</output>
