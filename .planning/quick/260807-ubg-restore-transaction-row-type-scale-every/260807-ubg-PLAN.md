---
task: 260807-ubg
title: Restore the transaction row type scale everywhere
branch: redesign/navigation-260806
type: quick
autonomous: false
requirements: [260807-ubg]
files_modified:
  - lib/dashboard/home/widgets/transaction_displays.dart
  - test/dashboard/transaction_row_test.dart
must_haves:
  truths:
    - "On the iPhone, a transaction row prints its title at titleMd, its subtitle at bodySm, and its amount at 16 - the same sizes the desktop row prints."
    - "The leading identity icon is 40 on the phone, and the name block takes an equal share against the amount."
    - "The 44pt filter-bar touch target is untouched and transaction_filters_test.dart is still green."
    - "banxa_buy_screen.dart's orders rail renders through an unchanged TransactionRow signature."
    - "No comment in transaction_displays.dart states a font size or a measured width the code no longer produces."
  artifacts:
    - lib/dashboard/home/widgets/transaction_displays.dart
    - test/dashboard/transaction_row_test.dart
  key_links:
    - "GeniusWalletTypography.bodySm / titleMd are the ONLY source of the row's subtitle and title size - no local fontSize override survives on that path."
    - "The `compact` local survives and still gates padding, the dropped time column and the icon gap - deleting it entirely would revert density this task keeps."
---

# Quick Task 260807-ubg: Restore the transaction row type scale everywhere

## The problem

`develop`'s 260806-hfe (`d5993c58`) added a phone density pass to `TransactionRow` gated on

```
final bool compact = !GeniusBreakpoints.useDesktopLayout(context);   // line 308
```

`useDesktopLayout` reads the **window** (`MediaQuery.sizeOf(context).width > medium && !isMobileApp()`),
so on a phone `compact` is true on **every** surface - the Home dashboard panel included, which was
never its target. Jakub saw it on device on 2026-08-07.

Full analysis, the trap and the line table:
`.planning/todos/pending/2026-08-07-dashboard-transaction-rows-lost-their-type-scale-to-compact.md`.

Jakub's call, 2026-08-07: **Option B** - remove the type-scale half of the gate so BOTH the Home
panel and the full `/transactions` page render our sizes. The density-parameter-from-call-site
approach (option A) is rejected and must not be built.

## Provenance check (done during planning, do not redo)

`git show d5993c58 -- lib/dashboard/home/widgets/transaction_displays.dart` confirms **every**
`compact` gate in the file arrived in that one commit. None of them predate the merge, so "our
value" is in all cases the `else` branch that is already written beside each gate. Nothing has to
be reconstructed from memory.

## Two findings that change what the executor writes

### Finding 1 - `bodySm` is 14, not 13

`genius_wallet_typography.dart:111` has read `fontSize: 14` since `b63a0d2e` created it, verified by
`git log -L 111,113`. It has never been 13. The 13px floor Jakub referenced is a **different** token:
`labelMd` (line 123-125, `// Floor raised 12->13: 12px read too small on a touchscreen`).

So the locked decision's "subtitle `bodySm` 13" names the right **token** and the wrong **number**.
The action is unambiguous either way - **delete the override and let the token govern** - and that is
what this plan does. It renders **14**, one step above the recorded 13px floor rather than on it.

The executor MUST NOT hard-code 13. That would contradict the locked decision's own rule (remove the
type-scale gate) and plant a fresh magic number under the token.

Same class of error inside the file: the subtitle comment at line 508 says the title above it is
"15px w600". `titleMd` is **16** (`genius_wallet_typography.dart:98`), overridden to w600 at line 450.
Both numbers in that sentence are wrong today.

### Finding 2 - the 113.0px arithmetic describes a row that HAS the time column

`test/dashboard/transaction_row_subtitle_test.dart:46` derives the 113.0px line as

```
366 - 2*space6 padding - 44 time - space6 - 40 identity - space6, then 234 less space4, split 1:1
```

Every term there is the **non-compact** branch, including the 44px time column that `compact` drops
on a phone. That test's `_host` wraps the row in `SizedBox(width: 366)` inside a default 800x600
harness window, so `800 > medium(768)` and `compact` is **false** - it has always measured the
desktop presentation. `transaction_row_test.dart` does the same.

Consequence: 113.0 / `Minted` 48.5 / ellipsis 12.3 / `Processing job` 103.6 / `Cancelled` 66.0 are
correct **for the desktop dashboard panel and for those two test hosts**, and they were measured at
`bodySm`'s real 14px. They are NOT the phone row's numbers, before this change or after it.

**Derived phone geometry** (390pt device: 6pt page gutter + 6pt card padding leaves the same 366pt
row, but compact drops the time column):

| | row | -padding | -icon | -gap | -gutter | name block | subtitle line |
|---|---:|---:|---:|---:|---:|---:|---:|
| now (icon 28, flex 2:1) | 366 | 354 | 326 | 320 | 312 | 208 | 208 |
| after (icon 40, flex 1:1) | 366 | 354 | 314 | 308 | 300 | 150 | 150 |

So the subtitle line **narrows from ~208px to ~150px** while its type grows 11 -> 14. Scaling the
measured 103.6px `Processing job` lead: it costs ~81px today inside ~164px of paragraph (fits with
room), and ~103.6px after this change inside ~95px of paragraph once a `Pending` tail takes its
share - **it will ellipsise by roughly 9px on a pending compute-job row.**

These are derived, not measured. They are the single most important thing for Jakub to look at on
device, and Task 3 makes that an explicit check rather than a footnote.

## What stays exactly as it is

- `test/dashboard/transaction_filters_test.dart` and the 44pt chips it pins (52/243). Different
  widget, real accessibility gain, out of scope.
- `lib/screens/banxa_buy_screen.dart:1380`. No parameter is added to `TransactionRow`, so no call
  site changes at all - not the orders rail, not `transactions_slim_view.dart:695`.
- The **density** half of the gate: row padding (lines 374/377), the dropped time column (396) and
  the icon gap (417). Padding and the dropped minute are the "more history fits" decision and are
  not type scale. The icon gap stays `space3` deliberately: restoring the 40px icon already spends
  12px of the name block's width and the flex change spends more, so the plan does not spend another
  6 on a gap the locked decision never named.

---

## Tasks

<task type="auto">
  <name>Task 1: Remove the type-scale half of the compact gate</name>
  <files>lib/dashboard/home/widgets/transaction_displays.dart</files>
  <action>
Nine edits, all of them a deletion or a collapse to the branch already written beside the gate. Line
numbers are from the current tree; work top-down so earlier deletions do not shift the ones below,
or locate each by its surrounding text.

1. Amount size (line 326): collapse the ternary so the amount is always 16.
2. Amount-to-value-line gap (line 346): collapse to `GeniusWalletConsts.space2`.
3. Value-line size (line 354): delete the whole `fontSize:` argument so `bodySm` governs, and keep
   the comment beside it - "Matches the subtitle across the row" becomes true again, since both the
   value line and the subtitle now take the token.
4. Identity icon (line 415): collapse to `size: 40`, and DELETE the `// 40 -> 28 on a phone (30%
   smaller).` comment above it, which stops being true at this edit.
5. Name block flex (line 422): drop the `flex:` argument entirely rather than writing `flex: 1` -
   1 is `Expanded`'s default and the shorter form is this repo's ladder (AGENTS.md rung 6).
6. Title size (line 449): delete the whole `fontSize:` argument so `titleMd` (16) governs. `w600`
   and the `gw.textPrimary` colour stay.
7. Title-to-subtitle gap (line 457): collapse to `const SizedBox(height: GeniusWalletConsts.space2)`
   - it can be `const` once the ternary is gone.
8. Subtitle paragraph size (line 535): delete the whole `fontSize:` argument.
9. Subtitle status tail size (line 560): delete the whole `fontSize:` argument.

Then delete the now-orphaned `_narrowNameFlex` constant AND its eight-line doc comment (lines
42-49). Edit 5 removes its only reference and the analyzer flags an unused private top-level
declaration, so leaving it behind is a guaranteed non-zero `flutter analyze`.

<!-- planner-discipline-allow: fontSize: compact -->
<!-- planner-discipline-allow: _narrowNameFlex -->

Do NOT touch: lines 374/377 (row padding), 396 (`if (!compact)` time column), 417 (icon gap). They
keep the `compact` local in use, so no unused-variable warning appears and the
`GeniusBreakpoints` import stays needed. Do NOT add a parameter to `TransactionRow` - option A is
rejected and both call sites must stay byte-identical.

Run `dart format` on the file when done; several collapsed ternaries will re-wrap.
  </action>
  <verify>
    <automated>test "$(grep -v '^\s*//' lib/dashboard/home/widgets/transaction_displays.dart | grep -c 'fontSize: compact')" = 0</automated>
    <automated>test "$(grep -r '_narrowNameFlex' lib/ | wc -l | tr -d ' ')" = 0</automated>
    <automated>test "$(grep -c 'compact' lib/dashboard/home/widgets/transaction_displays.dart)" -ge 4</automated>
    <automated>flutter analyze lib/dashboard/home/widgets/transaction_displays.dart</automated>
  </verify>
  <done>
No `fontSize` is gated on `compact` anywhere in the file's code. The orphaned flex constant and its
doc comment are gone. The `compact` local still exists and still gates padding, the time column and
the icon gap. `flutter analyze` on the file is clean. No call site changed.
  </done>
</task>

<task type="auto">
  <name>Task 2: Re-state every comment the edit invalidated</name>
  <files>lib/dashboard/home/widgets/transaction_displays.dart</files>
  <action>
This file argues its layout in prose and six of those arguments are now wrong. Leaving them is worse
than the original bug, because the next reader trusts them. Fix each in place - do not bulk-delete,
the reasoning is worth keeping, only its numbers and its provenance claims are stale.

1. **Lines 310-316** (the deleted-locals note) ends "Their `compact` font sizes were carried to their
   replacements rather than lost." That is now false. Re-state: those sizes were carried across the
   merge and then removed on 2026-08-07 when the type-scale half of the gate went, per Jakub's call.

2. **Lines 444-449** (title) attributes the size to develop's `titleText` local. The attribution
   outlived the code. Replace with what the line now does: the title takes `titleMd` at every width,
   w600 for the row.

3. **Lines 454-456** ("`compact ? 1` comes from develop's phone-width work ... kept through this
   merge") describes a gate that no longer exists. Replace with the restored gap and why it is one
   value, not two.

4. **Lines 479-512** (the big subtitle-lead argument). The reasoning survives intact - colour beats a
   middle dot because a separator costs width this line does not have - but three claims must change:
   - "One weight step at 13px" and "this is 13px": the subtitle is `bodySm` = **14** (Finding 1).
   - "that is 15px w600": the title is `titleMd` = **16** w600.
   - "The line is 113.0px ... leaving 9.4px": say which row that measures. 113.0 is the desktop
     dashboard panel and the two test hosts, where the 44px time column is present. State the phone
     row separately: the time column is dropped there, but the 40px icon and the 1:1 flex leave the
     subtitle ~150px, of which a pending row's tail takes its share - so `Processing job` ellipsises
     on the phone and does not on the desktop panel. Mark the phone figures as DERIVED and pending
     the device check in Task 3; do not present them as measured.

5. **Lines 528-533** ("`fontSize: compact ? 11` is develop's phone-width shrink ... it buys back line
   width") is now doubly wrong: the shrink is gone AND the line width it bought back is spent.
   Re-state honestly - the paragraph now runs at the token size on a narrower line, which is the
   cost Jakub accepted for legible type. **The literal token this comment currently quotes must not
   survive the rewrite**, or Task 1's grep gate counts a comment and reports a false positive.

6. **Lines 556-558** ("Same shrink as the paragraph beside it. If only one of the two shrank...").
   The parity rule is still the point; the mechanism changed. Re-state: both take `bodySm` from the
   token, so the subtitle cannot print at two sizes on one line.

Also check **lines 59-66** (`_narrowStatusMaxWidth`). Its `Cancelled` = 66.0px at `bodySm` claim is
CORRECT and stays. Its "NARROWEST middle column the suite pumps - 90px at the 320px stress case"
describes the non-compact harness this task does not touch, so it also stays - but add one line: on a
real phone the middle column is now narrower than it was (the 1:1 flex), and the 76 cap still clears
it. Do not re-derive the 90; it is not this task's number.

Every re-stated number must come from this plan's Findings or from the file's own non-compact branch.
Do not invent a measurement. Repo rule: English only, and no em dashes anywhere in the prose.
  </action>
  <verify>
    <automated>grep -n '13px\|15px\|11px\|260806-hfe\|carried across' lib/dashboard/home/widgets/transaction_displays.dart</automated>
    <automated>flutter analyze lib/dashboard/home/widgets/transaction_displays.dart</automated>
  </verify>
  <done>
Every surviving occurrence of a font size in a comment matches what the code renders (16 title / 14
subtitle / 16 amount). No comment attributes a live line to a gate that was deleted. The 113.0px
argument names the geometry it measures. The phone figures are labelled derived. The grep in Task 1
still reports 0 with comments filtered out AND with them included.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 3: Pin the phone type scale, run the suite, then walk it on Sidney</name>
  <files>test/dashboard/transaction_row_test.dart, lib/dashboard/home/widgets/transaction_displays.dart</files>
  <behavior>
    - At a PHONE window (so `compact` is true), the row's title paints at `GeniusWalletTypography.titleMd.fontSize` (16).
    - At the same window, the subtitle paragraph paints at `GeniusWalletTypography.bodySm.fontSize` (14).
    - At the same window, the amount paints at 16.
    - The test reads the sizes from the tokens, never from a literal, so a deliberate future token change moves the test with it and only a re-introduced local override reddens it.
  </behavior>
  <action>
**Write the test first and watch it fail against `git stash`ed work if you want the RED**, but the
cheaper proof is that this test is impossible to satisfy with the pre-task-1 file.

Add ONE `testWidgets` to the EXISTING `test/dashboard/transaction_row_test.dart` - no new file
(AGENTS.md: fewest files possible). Its `_host` currently pumps into the default 800x600 harness
window, which is why every test in it and in `transaction_row_subtitle_test.dart` has always
exercised the NON-compact branch and why neither of them would have caught this regression. The new
test must set a phone window so `compact` is true:

    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

Then pump the existing `_host` and resolve each `Text`'s painted size via its `RenderParagraph`
(`transaction_row_subtitle_test.dart` already has the content-addressed `_paragraphWith` and
`_styleOf` pattern - read it and reuse the shape, do not import across test files). Assert against
`GeniusWalletTypography.titleMd.fontSize` and `.bodySm.fontSize`, not against 16 and 14.

Head the test with WHY it exists: a merge shrank this row once and no test noticed, because every
existing host sits above the 768 breakpoint. This is the guard for that specific blind spot.

Note this row's harness runs the fallback one-em-per-character font - that is fine here, because the
assertion is a resolved style property, not a measured width.

Then run the full verification list below. `dart format` and re-run if it touches anything.

**Do NOT commit. Do NOT relaunch or rebuild the app.** Jakub reviews on device first and the working
tree stays dirty until he says otherwise.
  </action>
  <verify>
    <automated>flutter test test/dashboard/transaction_row_test.dart</automated>
    <automated>flutter test test/dashboard/transaction_row_subtitle_test.dart</automated>
    <automated>flutter test test/dashboard/transaction_filters_test.dart</automated>
    <automated>flutter test test/dashboard/transactions_page_frame_test.dart</automated>
    <automated>flutter test test/dashboard/</automated>
    <automated>flutter analyze</automated>
    <human-check>
Hot reload the ALREADY RUNNING session on the iPhone "Sidney" - press `r` in the live `flutter run`
terminal. Do NOT hot restart (`R`) and do NOT relaunch: `R` crashes this app on the RocksDB lock.

1. **Home dashboard, Transactions panel.** Title, subtitle and amount all read at the restored
   scale. This is the surface Jakub reported.
2. **Full `/transactions` page.** Same scale. Confirm the filter chips still look and feel like the
   44pt target develop built - they are untouched, so any visible change there is a real regression.
3. **A PENDING compute-job row, if one is reachable.** This is Finding 2's live question: does
   `Processing job` clip? The derivation says it ellipsises by roughly 9px on a 390pt phone. If it
   does, that is the recorded cost of legible type, not a bug - report it to Jakub with the row
   visible rather than fixing it here.
4. **Narrow stress.** Nothing overflows; no yellow-and-black stripes and no console `RenderFlex
   overflowed`.
5. **Buy GNUS orders rail** (`banxa_buy_screen.dart`). It shares `TransactionRow` and this task
   changes no call site, so it should now render at the restored scale too. Confirm nothing broke.
    </human-check>
  </verify>
  <done>
All four named test files pass, `flutter test test/dashboard/` is green with no new failures against
the session baseline, and `flutter analyze` reports **0 issues** (this repo's norm - any non-zero is
a regression from this task, not an inherited condition). The new test fails if the type-scale gate
is ever re-introduced. Jakub has walked items 1-5 on Sidney. Nothing is committed.
  </done>
</task>

## If `transactions_page_frame_test.dart` reddens

The brief expected this file to be the one at risk. Planning says otherwise and the executor should
know why before debugging it: `grep` finds **no** `TransactionRow` reference, no `fontSize` and no
`Text` assertion in it. It measures page frame geometry - gutters, the xxl cap, the section title,
the 52px filter track. Of its three phone-width tests, two pump an EMPTY transaction list (lines
183, 286) and render no rows at all.

Only line 312 ("phone: the filter chips are a real touch target", `_surface(tester, 320, 800)` with
the default non-empty fixture) renders real rows at `compact == true`, and it ends on
`expect(tester.takeException(), isNull)`.

So there is **nothing in this file asserting the shrunk sizes to update**. If it goes red it will be
that exception check catching a genuine `RenderFlex` overflow at 320. Geometry says it should not:
every row child is `Expanded` or fixed, fixed total is 40 icon + 6 gap + 8 gutter + 12 padding = 66
against 320, and the subtitle line's only non-flex child is the 76px status cap inside a ~127px
column. **If it reddens anyway, that is a real defect in Task 1's edit - fix the code, do not relax
the test.**

`dashboard_section_caps_test.dart` was also checked and is safe: it tests `groupTransactionsByDay`
and row counts, pure functions, no pixel heights. `transactions_slim_view.dart` has no `itemExtent`
or `prototypeItem`, so taller rows cannot break a fixed extent.

## Out of scope, on purpose

- The density-parameter-from-call-site approach (option A). Rejected.
- The 44pt filter bar and `transaction_filters_test.dart`.
- Any change to `banxa_buy_screen.dart`.
- The desktop / non-compact branch. Not one of its values moves.
- **Any commit.** Locked decision 4.
