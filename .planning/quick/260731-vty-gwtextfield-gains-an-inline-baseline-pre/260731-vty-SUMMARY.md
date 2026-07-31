---
phase: quick-260731-vty
plan: 01
subsystem: components/inputs
status: complete
tags: [gw-text-field, banxa-buy, input-decoration, geometry, tdd]
requires:
  - lib/components/inputs/gw_text_field.dart
  - test/banxa/gw_pump.dart
provides:
  - GWTextField.leadingIcon (gutter slot, 48px minimum, centred)
  - GWTextField.prefix (inline slot, baseline, content-sized, component-styled)
affects:
  - lib/screens/banxa_buy_screen.dart
  - lib/components/inputs/gw_text_field.dart (GWSearchField)
tech-stack:
  added: []
  patterns:
    - "InputDecoration.prefix + prefixStyle for an inline baseline affix"
    - "measure-before-you-touch: geometry literals pumped against unchanged lib/"
key-files:
  created:
    - test/components/gw_text_field_prefix_test.dart
  modified:
    - lib/components/inputs/gw_text_field.dart
    - lib/screens/banxa_buy_screen.dart
    - test/banxa/buy_form_layout_test.dart
    - test/theme/theme_contrast_test.dart
decisions:
  - "Two parameters, not an enum or a wrapper type: leadingIcon keeps the gutter, prefix is redefined as Material's inline slot."
  - "Claim B's threshold raised from the plan's 24 to 30: the $ glyph measures 24.25, so the plan's predicted headroom did not exist."
  - "textSecondary on surfaceElevated was NOT covered by any existing sweep; one real assertion added rather than a claim of coverage."
  - "The decision-3 fade is pinned through AnimatedOpacity, not FadeTransition, which resolves to five ancestors."
metrics:
  duration: ~50 min
  completed: 2026-07-31
  tests_before: 987
  tests_after: 997
---

# Quick Task 260731-vty: GWTextField gains an inline baseline prefix

`GWTextField` routed its one `prefix` parameter into Material's `prefixIcon` slot, which is
vertically centred inside a 48x48 minimum box. The Buy GNUS hero's `$` therefore sat in a 48px
gutter and off the digits' baseline. The slot is now split in the component: `leadingIcon` keeps
the gutter behaviour byte-for-byte, and `prefix` means what Material's own
`InputDecoration.prefix` means. Both of the repo's two call sites are migrated.

## What was built

| Piece | Detail |
| --- | --- |
| `GWTextField.leadingIcon` | New `Widget?`, maps to `InputDecoration.prefixIcon`. Carries today's behaviour unchanged. |
| `GWTextField.prefix` | Redefined `Widget?`, maps to `InputDecoration.prefix`. Inline, baseline-laid-out, content-sized. |
| `prefixStyle` | Set from a single new `secondaryStyle` local, which now also feeds `hintStyle` (one expression, two consumers, previously written once). |
| `GWSearchField` | `prefix:` argument renamed to `leadingIcon:`, nothing else touched. |
| Buy GNUS hero | Now `prefix: symbol.isEmpty ? null : Text(symbol)`. The `style:` argument is gone entirely; the field supplies the type step and the ink. |
| `test/components/gw_text_field_prefix_test.dart` | New, 6 tests. |
| `test/banxa/buy_form_layout_test.dart` | +2 tests (VTY-03 height invariants). No existing literal edited. |
| `test/theme/theme_contrast_test.dart` | +2 tests (the contrast gap the plan assumed was already covered). |

## RED before, GREEN after - the measured numbers

Every RED number below was printed by a test running against **unchanged `lib/`**, before a single
line of the component was edited. Claim A was run first, alone, and was green in that same state.

### Claim A (VTY-02) - GWSearchField, the regression guard

| Probe | Pre-change (pinned as a literal) | Post-change |
| --- | --- | --- |
| `find.byIcon(Icons.search)` | `Rect.fromLTRB(1.0, 5.0, 49.0, 53.0)` (48x48) | identical, test passes untouched |
| `find.byType(EditableText)` | `Rect.fromLTRB(53.0, 17.0, 299.0, 41.0)` | identical, test passes untouched |

The magnifier's own rect did come back 48x48, exactly as the plan predicted: the
`ConstrainedBox` minimum forces its way through `Icon`'s inner tight 20px `SizedBox`.

### Claims B, C, D (VTY-01, VTY-04) - the Buy GNUS hero

Pumped as `GWTextField(textStyle: numericHeadline, controller: '500.00', prefix: Text('$'))` at a
320px width.

| Probe | RED (unchanged lib/) | GREEN (after the split) |
| --- | --- | --- |
| symbol rect | `LTRB(0.0, 8.0, 48.0, 56.0)` | `LTRB(20.0, 16.0, 44.3, 48.0)` |
| symbol width | **48.0** | **24.25** |
| symbol height | **48.0** | **32.0** |
| symbol top | **8.0** | **16.0** |
| input rect | `LTRB(52.0, 16.0, 300.0, 48.0)` | `LTRB(44.3, 16.0, 300.0, 48.0)` |
| input top / height | 16.0 / 32.0 | 16.0 / 32.0 |
| gap between symbol and digits | 4.0px of gutter, plus 20px of empty box inside it | **0.0px - the symbol's right edge IS the input's left edge (44.3)** |
| field height | 64.0 | 64.0 |

Three assertion failures were recorded in that RED state, in the exact words the runner printed:

- Claim B: `Expected: a value less than <24>` / `Actual: <48.0>`
- Claim C: `Expected: a numeric value within <1.0> of <16.0>` / `Actual: <8.0>`
- Claim D: `Expected: <24.0>` / `Actual: <14.0>`

Claim D's RED number is the informative one. With a **bare** `Text('$')` in the old `prefixIcon`
slot, the symbol resolved to `fontSize 14.0, w400`, in the Material default near-black
`#1D1B20` - because `prefixIcon` merges an `IconTheme`, not a `DefaultTextStyle`, so nothing in
the component reached the glyph at all. That is the concrete proof that `prefixStyle` was
required and not merely tidy.

### VTY-03, the card height the orders rail rides on

| Probe | Pre-change | Post-change |
| --- | --- | --- |
| `BanxaBuyForm` height, quote + payment method | **648.0** | **648.0** |
| height with `amountText: ''` vs `'500.00'` | equal | equal (asserted exactly, not `closeTo`) |

## Verdict on the plan's type-step prediction: it HELD

`<decisions_settled>` item 1 predicted that the sizes already agreed and that the entire visible
defect was the 48px gutter plus centre-versus-baseline. **Measured, and it held.** In the RED
state, with the call site's own `style:` still in place:

```
RED symbolStyle size=24.0 height=1.3333333333333333 weight=FontWeight.w600 family=Inter color=#8A8F9D
RED inputStyle  size=24.0 height=1.3333333333333333 weight=FontWeight.w600 family=Inter color=#FFFFFF
```

Identical on all four properties before the change. The misalignment was 100% geometric: a 48px
box where a 24.25px glyph belonged, and a top edge 8px above where the digits started. Post-change
the two styles are still identical, but the symbol's now comes from the component rather than from
a restatement at the call site.

## One prediction that did NOT hold, and it is a finding

The plan wrote: *"24 is comfortably above what a single `$` glyph at 24px needs while staying far
under the gutter."* It is not. Inter's `$` advance at a 24px type step measures **24.25px** - very
slightly WIDER than the em, not comfortably under it. Claim B failed on the correct code for the
wrong reason on its first GREEN run (`Expected: a value less than <24>` / `Actual: <24.25>`).

The threshold is now **30**, which still falsifies the 48px gutter outright and leaves the real
glyph 5.75px of headroom. The measured number and the reason are recorded in the test's own
comment so the next reader does not tighten it back.

## Contrast: `textSecondary` on `surfaceElevated`

The plan's decision 2 required confirming this pairing was genuinely inside
`theme_contrast_test.dart`'s sweep. **It is not.** Part 3's
`five properties clear 4.5:1 on surfaceElevated/surfaceMenu/surfaceBase` sweep covers
`inputDecorationTheme.focusedBorder`, `dropdownMenu.focusedBorder`, `tabBarTheme.indicatorColor`,
`checkboxTheme.side` and `progressIndicatorTheme.color` - all chrome, no text tokens.
`compute_contrast_test.dart` does sweep `textSecondary`, but against the compute card's
`surfaceSheen` gradient stop, not against `surfaceElevated`.

Per the plan's own instruction, one assertion was added rather than a claim of coverage that was
not there: `Part 7b: GWTextField hint and inline prefix on the field fill`, two tests, one per mode.

| Mode | `textSecondary` | `surfaceElevated` | Measured ratio | Applicable AA floor |
| --- | --- | --- | --- | --- |
| dark | `#8A8F9D` | `#0C0E14` | **5.97:1** | 4.5:1 |
| light | `#5A606E` | `#FFFFFF` | **6.30:1** | 4.5:1 |

The floor asserted is 4.5:1, the body-text one, deliberately stricter than the 3:1 the Buy GNUS
hero alone would need. The hero renders at 24px w600 and does qualify as WCAG large text, but the
slot's DEFAULT type step is `bodyLg` (16px), so the general caller sets the requirement rather than
the one caller that happens to be bigger. Both modes clear the stricter floor with margin, so
nothing was tuned down to pass.

## Decision 3, the empty field, as actually observed

Confirmed live, not assumed. With an empty, unfocused field the symbol is present in the tree and
occupies its full rect, at **opacity 0.0**. Setting the controller's text to `500.00` and pumping
one second takes it to **opacity 1.0**, and the rect is byte-identical across both states:
`Rect.fromLTRB(20.0, 16.0, 44.3, 48.0)` before and after. Opacity is not layout, so no digit moves
when the symbol appears - which is exactly what VTY-03's `empty == filled` height assertion
independently confirms at the card level.

**The `FadeTransition` probe the plan proposed was DROPPED.**
`find.ancestor(of: find.text('$'), matching: find.byType(FadeTransition))` resolves to **five**
widgets, not one, so it cannot identify the affix's own fade. It was replaced with
`find.byType(AnimatedOpacity)`, which resolves to exactly **one** ancestor, and that one IS pinned
as a real assertion (opacity 0.0 empty, 1.0 filled, rect unchanged). For the record, the
`Opacity` probe resolves to zero.

## The `grep -rn "prefix:" --include="*.dart" lib test` hit list, after the rename

```
lib/screens/banxa_buy_screen.dart:680:              prefix: symbol.isEmpty ? null : Text(symbol),
lib/components/inputs/gw_text_field.dart:206:              prefix: prefix,
lib/dev/design_gallery_screen.dart:150:                        prefix: '\$',
test/components/gw_text_field_prefix_test.dart:42:        prefix: const Text('\$'),
test/components/gw_text_field_prefix_test.dart:203:                prefix: const Text('\$'),
```

Exactly one `GWTextField` call site outside the component file: the Buy GNUS hero, which is the one
this task fixed. `gw_text_field.dart:206` is the component's own forwarding line into
`InputDecoration`. `design_gallery_screen.dart:150` is `GWAnimatedNumber.prefix: '\$'`, a `String`
on a different widget, untouched and untouchable by this rename. **No third call site was silently
reinterpreted.**

## Gates - real numbers

| Gate | Result |
| --- | --- |
| `flutter analyze` | `No issues found! (ran in 20.0s)` |
| `flutter test` | **997 passing, "All tests passed!"** |
| `bash tool/check_brace_style.sh` | exit **0** |
| `bash tool/check_raw_colors.sh` | exit **0** |
| `dart format` (5 touched files only) | `Formatted 5 files (0 changed)` |

### Test arithmetic

The pre-change baseline was measured in this session, not trusted from the plan, and it did come
out at 987.

```
987  pre-change baseline, full suite, measured before any edit
+ 6  test/components/gw_text_field_prefix_test.dart (new file)
+ 2  test/banxa/buy_form_layout_test.dart      (11 -> 13)
+ 2  test/theme/theme_contrast_test.dart       (28 -> 30)
= 997  post-change full suite
```

Per-file counts re-run individually to confirm: prefix `+6`, buy form `+13`, contrast `+30`.

`test/banxa/buy_form_layout_test.dart` shows as untracked (`??`) rather than modified, because
260731-uhe created it and it is itself still uncommitted. **No existing expected height literal in
it was edited**, and all 13 of its tests pass. The new 648.0 literal is additive: every other
height check in that file is self-relative and would stay green if the whole card grew by 16px in
one step, so an absolute pin was worth adding while a pre-change number was still measurable.

## Deviations from plan

**1. [Rule 1 - Bug] Claim B's threshold was wrong in the plan**
- **Found during:** Task 2, first GREEN run
- **Issue:** The plan's `lessThan(24)` fails on correct code. Inter's `$` at 24px measures 24.25.
- **Fix:** Threshold raised to 30, still far below the 48px gutter it must falsify. Measured value
  and reasoning recorded in the test comment.
- **Files modified:** `test/components/gw_text_field_prefix_test.dart`

**2. [Rule 2 - Missing coverage] The contrast pairing the plan assumed was covered was not**
- **Found during:** Task 2, verifying decision 2
- **Issue:** `textSecondary` on `surfaceElevated` appears in no existing sweep in either
  `theme_contrast_test.dart` or `compute_contrast_test.dart`.
- **Fix:** Added `Part 7b`, 2 tests, one per mode. Not in the plan's `files_modified` list.
- **Files modified:** `test/theme/theme_contrast_test.dart`

**3. [Rule 2 - Missing coverage] Two claims added beyond the plan's four**
- `leadingIcon` gets its own 48px-gutter assertion, so the two slots cannot quietly collapse back
  into one behaviour. The plan pinned the inline slot but left the gutter slot proven only
  indirectly, through `GWSearchField`.
- The decision-3 fade is pinned rather than merely reported, because the "opacity is not layout"
  property is what VTY-03's height invariant depends on.

**4. [Scope] `test/theme/theme_contrast_test.dart` added to the touched-file set**
The plan named three files; five were touched. The two extra are `buy_form_layout_test.dart`
(which the plan explicitly allowed for the VTY-03 pair, and where `pumpForm`, `formHeight` and
`testFormState(amountText:)` already live - so putting them there cost nothing and duplicated
nothing) and `theme_contrast_test.dart` per deviation 2.

## Threat model

`T-vty-01` (IME hardening) is satisfied by inspection of `git diff`: `autocorrect`,
`enableSuggestions`, `enableIMEPersonalizedLearning` and `textCapitalization` appear only as
unchanged context lines in the constructor and the field list. Not reordered, not redefaulted, not
dropped. `T-vty-02` and `T-vty-SC` unchanged: no new data path, no package added or removed,
`pubspec.yaml` untouched.

## Incidental finding worth keeping

`leadingIcon` is not an invented name. Material itself already spells this slot
`MenuItemButton.leadingIcon`, and this repo already calls it that at two live call sites
(`lib/account/account_drawer.dart:287/309/322`, `lib/account/sdk_account_manager.dart:292`). The
split therefore lands the app on Flutter's own vocabulary for both slots at once, which is a
stronger argument for the naming than the plan made for itself.

## Self-Check: PASSED

- `lib/components/inputs/gw_text_field.dart` - FOUND, modified
- `lib/screens/banxa_buy_screen.dart` - FOUND, modified
- `test/components/gw_text_field_prefix_test.dart` - FOUND, created, 6 tests pass
- `test/banxa/buy_form_layout_test.dart` - FOUND, +2 tests, 13 pass
- `test/theme/theme_contrast_test.dart` - FOUND, +2 tests, 30 pass
- All four gates run, real output quoted above

## Nothing committed, nothing pushed

**No `git add`, no `git commit`, no `git push`, no `git stash`, no branch created.** `git reflog`
shows no new entry from this session; HEAD is still `2a4ef884` on `redesign/jakub-260730`, exactly
where it was when the task started. `git diff --cached` is empty. All five files are unstaged
working-tree changes awaiting Jakub's review and his own PR into `ui-redesign-port`.

## Outstanding

A human visual walk of the Buy GNUS hero field. The geometry is pinned by test, but the judgement
call in decision 3 - the symbol being invisible until the field is focused or typed into - has
never been seen live by anyone. If it reads as a missing symbol rather than as an affordance, the
one-line flip is `floatingLabelBehavior: FloatingLabelBehavior.always` on the `InputDecoration`,
and the VTY-03 height pair must be re-run before believing that flip is free.
