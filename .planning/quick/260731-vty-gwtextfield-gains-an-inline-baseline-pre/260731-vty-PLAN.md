---
phase: quick-260731-vty
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/inputs/gw_text_field.dart
  - lib/screens/banxa_buy_screen.dart
  - test/components/gw_text_field_prefix_test.dart
autonomous: true
requirements: [VTY-01, VTY-02, VTY-03, VTY-04]
must_haves:
  truths:
    - "The Buy GNUS hero field's currency symbol sits on the same baseline as the digits beside it, tight against them, not in a 48px gutter (VTY-01)."
    - "GWSearchField's magnifier renders at byte-identical geometry to today, proven by numbers measured before the change (VTY-02)."
    - "The Buy GNUS form card's height is unchanged, at an empty amount and at a filled one, so the orders rail's IntrinsicHeight does not move (VTY-03)."
    - "The prefix's type step and colour come from GWTextField itself, so the call site states neither (VTY-04)."
    - "GWTextField's API names the two leading slots apart, so a future caller cannot get the gutter when they meant the baseline (VTY-01)."
  artifacts:
    - test/components/gw_text_field_prefix_test.dart
    - lib/components/inputs/gw_text_field.dart
    - lib/screens/banxa_buy_screen.dart
  key_links:
    - "GWTextField.prefix maps to InputDecoration.prefix (inline, baseline-laid-out), NOT InputDecoration.prefixIcon."
    - "GWTextField.leadingIcon maps to InputDecoration.prefixIcon (gutter, centred, 48 minimum) and is what GWSearchField passes."
    - "GWTextField sets InputDecoration.prefixStyle from its own resolved textStyle in gw.textSecondary, so a bare Text at the call site renders at the field's own type step."
---

<objective>
`GWTextField` currently routes its one `prefix` parameter into Material's `prefixIcon` slot. That slot is centred and carries a 48x48 minimum box, so the Buy GNUS hero field's `$` sits in a gutter and off the digits' baseline. This plan splits the one ambiguous parameter into two honestly named ones - `leadingIcon` for the gutter icon and `prefix` for a true inline, baseline-aligned prefix - and migrates both of the repo's two call sites.

Purpose: Jakub's instruction is "przestrzegaj naszych komponentow" - fix it in the component, not at the call site.
Output: a two-slot `GWTextField` API, a simplified Buy GNUS call site, and a new geometry test file that measures the fix and pins the regression it could cause.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@AGENTS.md
@.planning/codebase/CONVENTIONS.md
@lib/components/inputs/gw_text_field.dart
@.planning/quick/260731-uhe-buy-gnus-form-restructured-to-the-design/260731-uhe-SUMMARY.md
</context>

<framework_findings>
These were read out of the pinned SDK at `/Users/jakub/development/flutter` (Flutter 3.41.9, revision `00b0c91f06`) while planning. They are stated with file and line so the executor can re-check rather than trust them, but they do not need re-deriving.

**`packages/flutter/lib/src/material/input_decorator.dart:2461-2499` - `prefixIcon` is centred and floored at 48.**
`decoration.prefixIcon` is wrapped in `Center(widthFactor: 1.0, heightFactor: 1.0)` around a `ConstrainedBox` whose constraints default to `BoxConstraints(minWidth: kMinInteractiveDimension, minHeight: kMinInteractiveDimension)` - 48x48. A one-character `Text` handed to that slot is therefore laid out as a 48x48 box, with the glyph at that box's top-left. Both halves of the reported defect follow from this one wrapper.

**`input_decorator.dart:1476` vs `1489` (RTL) and `1513` vs `1526` (LTR) - centre versus baseline, in the layout code itself.**
`_RenderDecoration` positions `prefixIcon` with `centerLayout(...)` and `prefix` with `baselineLayout(...)`. `input` is positioned with `baselineLayout(...)` at `1529`. So the framework baseline-aligns `prefix` with the input text as a layout guarantee, and does not do so for `prefixIcon`. This is the whole fix.

**`input_decorator.dart:2419-2428` and `1802-1838` - `prefix` inherits the hint's style by default.**
`decoration.prefix` is wrapped in `_AffixText`, which does `DefaultTextStyle.merge(style: prefixStyle ?? hintStyle)`. `GWTextField`'s `hintStyle` is already `(textStyle ?? bodyLg).copyWith(color: gw.textSecondary)`, so an unstyled `Text` in this slot would already render at the field's own type step in `textSecondary`. The plan still sets `prefixStyle` explicitly - see Task 2 - because relying on a private fallback is not a contract.

**`input_decorator.dart:1828` with `1967` and `2074-2076` - the inline prefix hides when the field is empty and unfocused.**
`_AffixText` renders at `opacity: labelIsFloating ? 1.0 : 0.0`, and `labelShouldWithdraw` is `!isEmpty || (isFocused && decoration.enabled) || floatingLabelBehavior == FloatingLabelBehavior.always`. So an empty, unfocused field shows no symbol; focusing it or typing fades the symbol in over `_kTransitionDuration`. Opacity does not affect layout, so nothing shifts when it appears. See `<decisions_settled>` item 3.

**`packages/flutter/lib/src/rendering/box.dart:2472-2488` - `getDistanceToBaseline` is NOT available to a widget test.**
Its third assert switches on the `PipelineOwner` and the fall-through case is `PipelineOwner() => false`. Called from a settled test, outside layout and outside paint, it throws. Task 1 therefore proves baseline agreement by rects and style equality instead, which is equivalent - see the note in Task 1.
</framework_findings>

<api_decision>
**Chosen: two parameters. `leadingIcon` takes today's gutter behaviour, `prefix` is redefined as Material's inline slot.**

`GWTextField.leadingIcon` maps to `InputDecoration.prefixIcon`. `GWTextField.prefix` maps to `InputDecoration.prefix`. Both are `Widget?`, both default to null.

Why the inline meaning earns the name `prefix`, and the icon does not:

1. **It is the framework's own vocabulary.** Material spells the gutter slot `prefixIcon` and the inline slot `prefix`. A component that maps its `prefix` to `prefixIcon` means the exact opposite of the identically spelled parameter sitting four lines away in the same `InputDecoration` literal. That is the trap that produced this defect. `leadingIcon` also names the constraint out loud: it must be an icon, because an icon is what a 48px minimum tap-target box is for.
2. **The default a future caller will reach for is the inline one.** Somebody adding a currency symbol, a `+48` dial code or a `https://` will type `prefix:`. Under this split they get the baseline. Under the reverse split they would silently get the gutter and file this same bug again.
3. **The migration is one line, and that is a measured fact.** `grep -rn "prefix:" --include="*.dart" lib test` returns exactly three hits: `gw_text_field.dart:384` (the search field, inside the component's own file), `banxa_buy_screen.dart:675` (the hero, which this task is fixing anyway), and `design_gallery_screen.dart:150`, which is `GWAnimatedNumber.prefix: '\$'` - a `String` on a different widget, untouched by any of this. So the rename costs one edited argument outside the component file, and there is no third call site to be silently reinterpreted.

Rejected, with reasons:

- **Keep `prefix` for the icon, add `inlinePrefix`.** Zero migration, and that is its only merit. It leaves the ambiguous, framework-colliding name attached to the rarer meaning and makes the common case the one with the odd name. It preserves the trap rather than closing it.
- **An enum, `prefixPlacement`, on one slot.** Every call site would pass two arguments to say one thing. Worse, the two placements do not differ only in position: they differ in what widget is legal, in the constraints applied, and in whether the content is styled by `prefixStyle`. One slot plus a mode flag is exactly the "needs a boolean flag to serve both callers" shape `AGENTS.md` tells us not to extract.
- **A wrapper type, `GWFieldPrefix.icon(...)` / `.inline(...)`.** The most expressive option and the only one that makes the wrong call impossible at the type level. It costs a new public class and a switch in `build` for a component with two call sites. Revisit if a third leading-slot variant ever appears - Rule of Three.

**Not in scope, named so it is a decision and not an oversight:** `GWTextField.suffix` keeps mapping to `suffixIcon`. Both of its callers pass an `IconButton` (the password toggle at `:306`, the search clear at `:386`), which genuinely wants the 48px tap target. `gw_select.dart:90` also passes `prefixIcon: leading` - a select's leading slot really is an icon gutter. Neither is touched.
</api_decision>

<decisions_settled>
**1. The type step. Prediction, to be confirmed or corrected by measurement in Task 1.**
The call site passes an explicit `style:` to the prefix `Text`, and `Text` merges its own `style` over the ambient `DefaultTextStyle`, so `fontSize: 24`, `height: 32/24`, `fontWeight: w600` and the tabular `fontFeatures` from `numericHeadline` all take effect today. `prefixIcon` merges an `IconTheme`, not a `DefaultTextStyle`, so it cannot be overriding them. **The sizes are therefore predicted to already agree, and the misalignment is predicted to be entirely the gutter plus centre-versus-baseline.** The one property `numericHeadline` leaves unset is `letterSpacing`, which the two texts inherit from different ancestors and which affects only trailing advance, not baseline. Task 1 measures both resolved styles and Task 2's summary reports the real numbers. If the measurement contradicts this prediction, the summary says so plainly rather than quietly agreeing with it.

**2. The colour. It survives the move, unchanged, and is now easier to defend, not harder.**
The symbol stays `gw.textSecondary` against digits in `textPrimary`. The hierarchy is deliberate and the move does not touch it - it only moves where the component states it, from the call site into `prefixStyle`. On the contrast question: the symbol renders at 24px `w600`, which is WCAG large text (the threshold is 18.66px bold or 24px regular), so its AA floor is 3:1 rather than 4.5:1. The type step made this pairing safer than it was at `bodyLg`. `test/theme/theme_contrast_test.dart` already sweeps text tokens against surface tokens with its own `contrastRatio` helper at `:21`; Task 2 requires the executor to confirm `textSecondary` on `surfaceElevated` is genuinely inside that sweep and to report the measured ratio for both themes. No new colour is introduced and no existing one is changed.

**3. The empty field shows no symbol, and that is Material's decision, which we accept.**
Per `<framework_findings>`, `_AffixText` gives the inline prefix opacity 0 while the field is empty and unfocused, and fades it in on focus or on the first character. Accepted for two reasons. A lone `$` hanging over an empty field with no digits beside it reads as a stuck placeholder, whereas revealing it the instant the user focuses is the affordance version of the same pixel. And because opacity is not layout, the box is reserved the whole time, so no digit ever shifts when the symbol appears - which is the property VTY-03's height invariant depends on.
*To flip in one line:* add `floatingLabelBehavior: FloatingLabelBehavior.always` to the `InputDecoration` in `gw_text_field.dart`. `GWTextField` never sets `labelText` (it draws its label as a separate `Text` above the field), so there is no label for that flag to float and its only visible effect is to pin the prefix visible. If this flip is ever taken, the VTY-03 height tests must be re-run before believing it is free.

**4. Call sites. Two, and that is grep-proven, not estimated.** See `<api_decision>` point 3 for the command and its three hits.
</decisions_settled>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: Measure today, in a test that fails today</name>
  <files>test/components/gw_text_field_prefix_test.dart</files>
  <behavior>
    Four claims, written and RUN BEFORE `gw_text_field.dart` is touched. The search-field claim must pass on unchanged code, because its job is to pin what already exists. The three hero claims must FAIL on unchanged code, because they encode the target. A hero claim that passes before the fix is a hollow test and must be strengthened until it fails.

    - Claim A (VTY-02, GREEN today, must stay GREEN): pumping a bare `GWSearchField`, the magnifier's rect and the field's rect are exactly the numbers this run measures.
    - Claim B (VTY-01, RED today): the hero field's symbol occupies well under the 48px gutter.
    - Claim C (VTY-01, RED today): the hero field's symbol box and its input text box share a top edge and a height, which given claim D is a shared baseline.
    - Claim D (VTY-04, RED today once the call site drops its own `style:` in Task 2; assert the resolved styles agree): symbol and digits resolve to the same `fontSize`, `height`, `fontFamily` and `fontWeight`, and the symbol resolves to `gw.textSecondary`.
  </behavior>
  <action>
Create `test/components/gw_text_field_prefix_test.dart`. Reuse `test/banxa/gw_pump.dart`'s `gwHost` idiom for the theme wrapper rather than hand-rolling a `MaterialApp` (import it, or copy the three-line helper locally if a cross-directory test import is awkward - say which in the summary). Pump directly against `GWTextField` and `GWSearchField`; do NOT pump the whole Buy GNUS screen here, that surface is already covered by `test/banxa/buy_form_layout_test.dart`.

Claim A, the regression guard, and run this one FIRST. Pump `GWSearchField` inside `gwHost` at a fixed width via a `SizedBox`. Record `tester.getRect(find.byIcon(Icons.search))` and `tester.getRect(find.byType(EditableText))` and assert both against the literal numbers this run prints. Write the numbers into the test as literals with a comment saying they were measured against unchanged `gw_text_field.dart` on this exact date, because hard constraint 2 says prove it rather than assert it, and a test written after the change proves nothing. Expect the icon's own rect to come back 48x48 - the `ConstrainedBox` at `input_decorator.dart:2468` forces its minimum through `Icon`'s inner tight `SizedBox` - and if it does not, record the number you actually got and use that. Run this claim, confirm it is green, and only then write the rest.

Claims B, C and D, against a `GWTextField` configured exactly as the hero is: `textStyle: GeniusWalletTypography.numericHeadline`, a `TextEditingController` seeded with `500.00`, and a prefix carrying a `$`. Write these against the API Task 2 will introduce, so they do not compile until Task 2 lands - that is acceptable and expected for a TDD task, but you must still produce a RED measurement first. Do that by temporarily seeding the same widget through today's `prefix:` parameter in a scratch copy of the test, running it, and recording the real numbers in the summary; then rewrite to the target API. State in the summary exactly which numbers came from which run.

Claim B: assert `tester.getRect(find.text('\$')).width` is under 24. Under today's `prefixIcon` routing this returns 48.0, so the claim falsifies the present code directly, and 24 is comfortably above what a single `$` glyph at 24px needs while staying far under the gutter.

Claim C: assert `tester.getRect(find.text('\$')).top` equals `tester.getRect(find.byType(EditableText)).top` within 1.0, and that the two rect heights agree within 1.0. Note in a comment why this is a baseline proof and not a weaker substitute: `RenderBox.getDistanceToBaseline` throws when called from a settled test (`rendering/box.dart:2486`), and two text boxes carrying an identical `TextStyle` place their alphabetic baseline at an identical offset below their own top edge, so equal tops plus equal heights plus claim D's style equality is exactly a shared baseline. Under today's routing the symbol's box is forced to 48 tall and the input's is 32, so both halves of this claim fail before the fix.

Claim D: read the symbol's fully merged style with `tester.renderObject<RenderParagraph>(find.text('\$')).text.style` - this returns the span style after `DefaultTextStyle` merging, which is the only honest probe once the call site stops passing `style:`. Read the input's with `tester.widget<EditableText>(find.byType(EditableText)).style`. Assert `fontSize`, `height`, `fontWeight` and `fontFamily` are equal across the two, and that the symbol's `color` is `GWColors.dark().textSecondary`. Do not assert `letterSpacing`: `numericHeadline` leaves it unset and the two texts inherit it from different ancestors, so an equality there would be a claim about ambient theme wiring rather than about this fix.

No em dashes in anything you write here. Use " - ".
  </action>
  <verify>
    <automated>flutter test test/components/gw_text_field_prefix_test.dart</automated>
  </verify>
  <done>The file exists. Claim A passed against unchanged `gw_text_field.dart` and its literals are the numbers that run printed. Claims B, C and D have a recorded RED measurement taken against unchanged code, with the real numbers captured for the summary. Nothing in `lib/` has been edited yet.</done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: Split the leading slot in GWTextField and migrate both call sites</name>
  <files>lib/components/inputs/gw_text_field.dart, lib/screens/banxa_buy_screen.dart, test/components/gw_text_field_prefix_test.dart, test/banxa/buy_form_layout_test.dart</files>
  <behavior>
    - `GWTextField.prefix` renders inline on the input's baseline, sized to its own content, styled by the component.
    - `GWTextField.leadingIcon` renders exactly where `prefix` used to: gutter, vertically centred, 48px minimum.
    - `GWSearchField` renders at byte-identical geometry.
    - The Buy GNUS form card's height is identical to today, at an empty amount and at a filled one.
  </behavior>
  <action>
In `lib/components/inputs/gw_text_field.dart`:

Rename the existing `prefix` field and constructor parameter to `leadingIcon`, keeping it a `Widget?` and keeping its mapping to `InputDecoration.prefixIcon` at the line that currently reads `prefixIcon: prefix`. Add a NEW `Widget? prefix` field and constructor parameter, mapped to `InputDecoration.prefix`. Declare both in the same region of the constructor and the same region of the field list, adjacent, so a reader meets them together.

Give each a doc comment that names the other and states the difference in behaviour, not just in wiring: `leadingIcon` goes in its own gutter with a 48px minimum box and is vertically centred, which is correct for an icon and wrong for text; `prefix` is laid out inline on the input's baseline and sized to its content, which is correct for a currency symbol, a dial code or a scheme. State in `prefix`'s doc that this component's `prefix` deliberately means the same thing Material's `InputDecoration.prefix` means, and that it did NOT before this change - that sentence is the whole reason the rename exists. Do not reproduce framework line numbers in the doc comment; cite the behaviour, not the SDK revision.

Set `prefixStyle` on the `InputDecoration` to the same resolved value the field already builds for `hintStyle`: the effective `textStyle` fallback-defaulted to `bodyLg`, with `color: gw.textSecondary`. Extract that expression to a single local in `build` and use it for both `hintStyle` and `prefixStyle` rather than writing it twice. Add a short comment recording that Material's own fallback for `prefixStyle` is `hintStyle` and would coincide today, and that we state it anyway because a private fallback is not a contract.

Do not add `prefixIconConstraints`. Do not touch `suffix`, which keeps mapping to `suffixIcon` for the reasons in the plan's api_decision. Do not sweep the file's pre-existing em dashes; the no-em-dash rule binds what you write, and a file-wide comment rewrite would bury this diff.

At `GWSearchField`'s call into `GWTextField`, change the argument name `prefix:` to `leadingIcon:` and change nothing else about it - same `Icon(Icons.search, size: 20, color: gw.textSecondary)`.

In `lib/screens/banxa_buy_screen.dart`, at the hero `GWTextField` inside `BanxaBuyForm`: keep passing `prefix:`, and simplify what it carries. The conditional on `symbol.isEmpty` stays. The `Text` loses its `style:` argument entirely, because the component now supplies the type step and the colour - a bare `Text(symbol)` is the point of the change and leaving a restated `numericHeadline.copyWith(color: ...)` there would silently defeat `prefixStyle`. Update the surrounding comment to record that the symbol is now an inline baseline prefix rather than a gutter icon, and that its style comes from the field.

Then re-point and finish the tests. Rewrite Task 1's claims B, C and D onto the final API and run them to green. Add two more to the same file, or to `test/banxa/buy_form_layout_test.dart` if the seeded-state pump helper there makes them cheaper - say which you chose and why:

- VTY-03: the Buy GNUS form card's height with an empty amount equals its height with `500.00` typed, exactly. This is the invariant the orders rail's `IntrinsicHeight` rides on, and it is also the concrete proof that the opacity-based reveal in decision 3 costs no layout.
- VTY-03: the card's height after the change equals the number the existing `buy_form_layout_test.dart` invariants already assert. **You may not edit any existing expected height literal in that file.** If one of them now fails, that is a finding to report and a change to reconsider, not a number to update.

Run the full gates and report real numbers, not "clean":
`flutter analyze`; `flutter test`; `bash tool/check_brace_style.sh`; `bash tool/check_raw_colors.sh`. Measure the pre-change `flutter test` count yourself rather than trusting the 987 in this plan - the tree is uncommitted and shared with the rest of the day's work - and report before, after, and the arithmetic that connects them.

Run `dart format` on only the three files this task touched. Do NOT format `test/dev/dev_mock_sgnus_test.dart` or `test/dev/mock_transactions_sticky_test.dart`; both carry pre-existing drift from other work and reformatting them would put unrelated churn in Jakub's review diff.

Confirm the colour claim from decision 2: grep `test/theme/theme_contrast_test.dart` for the sweep that pairs text tokens with surface tokens, confirm `textSecondary` against `surfaceElevated` is genuinely inside it, and report the measured ratio for both themes plus the applicable AA threshold. If the pairing turns out not to be covered, add one assertion for it rather than claiming coverage that is not there.

Finally, re-run `grep -rn "prefix:" --include="*.dart" lib test` and confirm the only `GWTextField` hit is the Buy GNUS hero, so no third call site was silently reinterpreted by the rename. Report the hit list.

**Do not run `git add`, `git commit`, `git stash` or `git push`.** Everything stays unstaged in the working tree on `redesign/jakub-260730`. Jakub reviews locally and opens the PR himself into `ui-redesign-port`.
  </action>
  <verify>
    <automated>flutter analyze && flutter test && bash tool/check_brace_style.sh && bash tool/check_raw_colors.sh</automated>
  </verify>
  <done>`flutter analyze` reports no issues. `flutter test` passes with a count equal to the measured pre-change baseline plus the new tests, arithmetic shown. Both shell gates exit 0. The search-field geometry literals from Task 1 still pass untouched. No existing height literal in `buy_form_layout_test.dart` was edited and all of them pass. Nothing is committed and nothing is pushed.</done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| user keyboard to amount field | The only untrusted input this diff sits near. It is unchanged by this task: `keyboardType`, `inputFormatters`, `onChanged` and the cubit's `setAmountText` are all untouched. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-vty-01 | Tampering | `GWTextField` IME opt-ins (`autocorrect`, `enableSuggestions`, `enableIMEPersonalizedLearning`, `textCapitalization`) | high | mitigate | The constructor's IME-hardening block is load-bearing for key material. This task edits the same constructor. Do not reorder, redefault or drop any of the four; the diff on that block must be empty. |
| T-vty-02 | Information disclosure | `prefixStyle` and the prefix widget | low | accept | The inline prefix renders a caller-supplied `Widget`, exactly as the gutter slot did. No new data path, no new persistence, no new field content. |
| T-vty-SC | Tampering | package installs | low | accept | No package is added, removed or upgraded by this task. `pubspec.yaml` is not in `files_modified`. |
</threat_model>

<verification>
1. `flutter analyze` - no issues, reported as the tool prints it.
2. `flutter test` - full suite, with the pre-change baseline measured this session and the arithmetic to the post-change number shown.
3. `bash tool/check_brace_style.sh` - exit 0.
4. `bash tool/check_raw_colors.sh` - exit 0.
5. The search-field geometry literals, measured before any `lib/` edit, still pass after it.
6. No existing expected height literal in `test/banxa/buy_form_layout_test.dart` was edited, and every one of them passes.
7. `git status` shows only unstaged working-tree changes; no new commit exists on `redesign/jakub-260730`.
</verification>

<success_criteria>
- The hero symbol's own rect is under 24px wide, where it is 48.0 today.
- The symbol's box and the input's box share a top edge and a height within 1px, and their resolved styles agree on `fontSize`, `height`, `fontWeight` and `fontFamily`.
- The symbol resolves to `gw.textSecondary` with no `style:` at the call site.
- `GWSearchField`'s magnifier geometry matches numbers measured against unchanged code.
- The Buy GNUS card's height is identical empty versus filled, and identical to the existing pinned literals.
- `GWTextField` exposes `leadingIcon` and `prefix` as two documented slots, each naming the other.
- Four gates run with real numbers reported.
- Nothing committed, nothing pushed.
</success_criteria>

<output>
Create `.planning/quick/260731-vty-gwtextfield-gains-an-inline-baseline-pre/260731-vty-SUMMARY.md` when done.

The summary must carry, beyond the standard sections:
- The measured RED numbers from Task 1 and the GREEN numbers after Task 2, side by side.
- A plain verdict on the type-step prediction in `<decisions_settled>` item 1: did the sizes already agree, or did the measurement contradict the plan.
- The `textSecondary` on `surfaceElevated` contrast ratios for both themes, with the applicable AA threshold named.
- The full `grep -rn "prefix:"` hit list after the rename.
- The decision-3 empty-field behaviour as actually observed, and whether the `FadeTransition` opacity probe was pinned as an assertion or only reported. If `find.ancestor(of: find.text('\$'), matching: find.byType(FadeTransition))` does not resolve to exactly one widget, drop the assertion and say so.
- An explicit statement that nothing was committed and nothing was pushed.
</output>
</content>
</invoke>
