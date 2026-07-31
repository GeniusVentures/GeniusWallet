---
phase: quick-260731-uhe
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/inputs/gw_text_field.dart
  - lib/screens/banxa_buy_screen.dart
  - test/banxa/fixtures.dart
  - test/banxa/buy_form_layout_test.dart
  - test/banxa/buy_page_layout_test.dart
  - .planning/todos/pending/2026-07-31-buy-gnus-form-restructure.md
autonomous: true
requirements: [260731-uhe]

must_haves:
  truths:
    - "The Buy GNUS form card renders in the design's order, provable by geometry (tester.getRect().top), not by presence: YOU SPEND kicker and hero amount field, then the amount shortcut track, then CURRENCY and PAYMENT METHOD, then WALLET ADDRESS, then the You get / Rate / Banxa fee grid, then the CTA."
    - "The amount field is the visual hero: it renders in a larger type step than every other field on the card, measurable as a font size strictly greater than bodyLg's 16."
    - "Tapping an amount shortcut chip writes that amount into the field and marks that chip selected; the chip reports its selection through Semantics, so the test never reaches into a private widget."
    - "Chip labels are denominated in the SELECTED fiat. With a non-USD fiat selected no chip label starts with a dollar sign (A2)."
    - "The ladder respects the selected payment method's min/max when one is selected (state.minAmount / state.maxAmount are real and non-null in that case), and the code says plainly in a comment that nothing is validated when no payment method is selected."
    - "The form card's rendered height is IDENTICAL with quote == null and with a real quote, at the same width. This is the load-bearing invariant: the orders rail derives its height from this card through IntrinsicHeight (260731-ti5), so a reflow makes the rail jump, not merely shift."
    - "The form card's rendered height is also identical whether the ladder shows four chips or one, so a payment method with a narrow range cannot resize the rail either."
    - "CURRENCY and PAYMENT METHOD sit side by side when the card's own inner width allows it and stack when it does not. The threshold is MEASURED from the two selects' real intrinsic widths and the card's real inner width, and the crossover arithmetic is recorded in a comment in the style of _OrdersRail._inlineTrackMinWidth."
    - "No LayoutBuilder and no scroll viewport is introduced anywhere inside the form card. Both throw when IntrinsicHeight queries them, which is exactly what the two-column layout does to this card."
    - "The Crypto Currency select still exists and still reads from state.cryptos, rendering only when there is a choice to make (A1). No live control is deleted as part of a layout change."
    - "The CTA keeps its two-step label: Get quote until a quote exists, Buy GNUS after (A3)."
    - "The Couldn't load currencies. retry row is untouched and still reachable."
    - "Every control is an existing component: GWCard, GWKicker, GWSelect, GWTextField, GWControlTrack, GWDetailGrid, GWButton. The only component change is one additive, backwards-compatible parameter on GWTextField."
    - "flutter analyze clean, full flutter test green at or above 978, bash tool/check_brace_style.sh 0, bash tool/check_raw_colors.sh 0, all four quoted as real numbers the executor actually ran."
    - "NOTHING is committed and nothing is pushed. Jakub reviews locally and opens the PR himself into ui-redesign-port."
  artifacts:
    - test/banxa/buy_form_layout_test.dart
    - .planning/quick/260731-uhe-buy-gnus-form-restructured-to-the-design/260731-uhe-SUMMARY.md
  key_links:
    - "BanxaBuyForm is the test seam. BanxaBuyScreen builds its own MakeOrderCubit with no injection point, so the real screen can only ever reach the offline no-quote state under flutter_test. Extracting the card into a PUBLIC widget that takes a MakeOrderState makes the quote state, a non-USD fiat and a min/max-bounded payment method all reachable in a widget test, against the real production widget instead of a hand-copied reconstruction of it."
    - "The responsive flag is computed in the screen's EXISTING LayoutBuilder and passed down as a number, because a LayoutBuilder inside the card would be asked for an intrinsic height by IntrinsicHeight and throw. The same one-condition-read-once idiom 260731-ti5 used for wide/bounded."
    - "GWCard's inner content width is its outer width minus 34: space8 (16) of padding each side plus 1px each side of hairline, because Container adds decoration.padding on top of its own padding. Already measured and documented at _OrdersRail._inlineTrackMinWidth; the same two pixels decide this threshold."
    - "The amount shortcut chips are GWControlTrack plus a chip modelled on _OrderToneChip, not a fifth chip language. Flat surfaceMenu for selected, never the brand gradient: this card already carries the gradient CTA, and giving a filter chip that weight is the exact mistake _OrderToneChip's own doc records replacing."
    - "The chip LABEL is formatted (symbol, thousands separator) and the VALUE written to the field is a bare parseable number. state.amountValue is a double.tryParse, so writing a formatted string would silently disable the CTA."
---

<objective>
Restructure the Buy GNUS form card into the order Jakub's screenshot shows, on
existing components, without changing the card's height in either direction when
a quote arrives.

Target order, top to bottom:

  1. `YOU SPEND` kicker over a hero amount field, in a bigger type step than any
     other field on the card
  2. A row of amount shortcut chips, the active one filled
  3. `CURRENCY` and `PAYMENT METHOD` side by side, collapsing to stacked on a
     narrow card
  4. `Wallet Address` - not in the design, kept at Jakub's explicit instruction
  5. The `You get` / `Rate` / `Banxa fee` grid
  6. The full-width gradient CTA

Today it is one stacked column with Fiat, Crypto Currency and Payment Method
above the amount, so the one number the user actually types sits fourth from the
top at body size.

Purpose: the form should lead with the number being entered. Output: a
restructured `BanxaBuyForm`, a test seam that makes the quote state reachable
under `flutter_test` for the first time, and six tests that fail today.

**DO NOT COMMIT AND DO NOT PUSH.** This overrides the GSD atomic-commit default
and is Jakub's standing rule. He reviews locally and opens the PR himself into
`ui-redesign-port`.

**No em dashes anywhere** - not in code, not in comments, not in the SUMMARY.
Write " - " instead.
</objective>

<decisions>
Three questions were put to Jakub and left unanswered. These are the planner's
calls, made to be defensible and cheap to reverse. Implement them AND record
them in the SUMMARY under a clearly marked heading so any one can be flipped in
one line.

**A1 - the Crypto Currency select stays, and renders only when there is a choice
to make.** The design has no crypto picker and the screen is called Buy GNUS,
but deleting a live control that reads from `state.cryptos` is a behaviour
change, not a layout change. Gate it on `state.cryptos.length > 1`. On a
GNUS-only Banxa response the form matches the design exactly; if Banxa ever
offers more, nobody is locked out.

Placement when it does render: full width, directly under the CURRENCY /
PAYMENT METHOD row and above `Wallet Address`. Two reasons, both to be written
into the code as a comment. It belongs with the other "what am I trading"
selects rather than after the wallet field. And it must not join that row as a
third column: the row's collapse threshold is measured for exactly two selects,
and a third would invalidate the measurement and cramp the card at every width.

**A2 - the shortcut chips are denominated in the selected fiat.** The design
draws dollars because the design drew USD. With EUR selected, `$100` is simply
false. `FiatCurrency.symbol` exists on the model (`banxa_model.dart`) and
`state.selectedFiat` carries it. Ladder: 100 / 500 / 1000 / 5000 in that
currency.

`MakeOrderState` DOES expose limits - `minAmount` / `maxAmount`, both derived
from `selectedPaymentMethod.minimum` / `.maximum`. Respect them: filter the
ladder to the legal range. They are null only while no payment method is
selected, and in that state `canGetQuote` is false anyway (it requires
`hasSelections`), so an out-of-range chip cannot reach Banxa. Say exactly that
in a comment rather than implying the unfiltered ladder is validated.

**A3 - the CTA keeps its two-step label.** `Get quote` until a quote exists,
`Buy GNUS` after. The screenshot shows `Buy GNUS`, but a still image cannot
distinguish "the quote step was removed" from "this is the post-quote state",
and removing a quote step is a flow change nobody asked for.

**A4 - every label on this card becomes a GWKicker.** The design draws
uppercase kickers (`YOU SPEND`, `CURRENCY`, `PAYMENT METHOD`). `GWSelect` and
`GWTextField` render their own `label` in sentence case at `labelMd`. Using
kickers for some fields and the built-in label for others is the "partial
adoption reads as a different design language on the same screen" failure
CONVENTIONS.md names. So: `GWKicker` above every field, `label: null` on the
field itself. `GWKicker` also owns the accessible casing (call sites pass
sentence case, the widget uppercases for display), which pre-uppercasing a
`label:` string would lose. Cost, and the reason this is an assumption rather
than a fact: this card's labels will then differ from Settings, onboarding and
the account manager, which all use the built-in sentence-case label. One line to
flip back.
</decisions>

<context>
@.planning/todos/pending/2026-07-31-buy-gnus-form-restructure.md
@AGENTS.md
@lib/screens/banxa_buy_screen.dart
@lib/components/inputs/gw_text_field.dart
@lib/components/inputs/gw_select.dart
@lib/components/gw_control_track.dart
@lib/components/cards/gw_kicker.dart
@lib/components/cards/gw_detail_grid.dart
@lib/banxa/banxa_order/create_order_state.dart
@lib/banxa/banxa_order/create_order_cubit.dart
@test/banxa/buy_page_layout_test.dart
@test/banxa/fixtures.dart
</context>

<known_traps>
Read these before writing a line. Each one has already been paid for once in
this file.

1. **A LayoutBuilder inside the form card throws.** In the two-column layout the
   card is a child of `IntrinsicHeight` (`banxa_buy_screen.dart:502`), which
   asks every child for an intrinsic height. `_RenderLayoutBuilder` answers that
   query by throwing in debug and returning a wrong 0 in release. The file
   already records this: `_ZeroIntrinsicHeight`'s doc says the rail's own
   `LayoutBuilder` "would throw for the same reason, and is shielded by the same
   0". The form card is NOT shielded and must not be, because it is the widget
   whose intrinsic height defines the row. So the responsive decision is made in
   the screen's existing `LayoutBuilder` (`:450`) and handed down as a number.
2. **A scroll viewport inside the form card throws for the same reason.**
   `RenderViewport` refuses intrinsic queries outright. The orders rail wraps its
   chip track in a horizontal `SingleChildScrollView`; that is legal only because
   `_ZeroIntrinsicHeight` sits above it. Do not copy that idiom here. The amount
   chips must be overflow-proof by construction instead (see Task 2).
3. **`state.amountValue` is `double.tryParse(amountText)`.** A chip that writes
   `'1,000'` or `'$1,000'` parses to null, which silently makes `canGetQuote`
   false and disables the CTA with no error. Format the LABEL, write a bare
   number as the VALUE.
4. **`banxa_reskin_literals_test.dart` counts `Colors.` references in this file
   and asserts EQUAL to 1** (the boot overlay scrim). `Colors.transparent` is
   excluded by that gate and by `tool/check_raw_colors.sh`. Any other raw colour
   fails the suite. Read colours through
   `Theme.of(context).extension<GWColors>() ?? GWColors.dark()` in every new
   widget - the same gate asserts that live-read is present in the file.
5. **`buy_page_layout_test.dart` greps this file's source for `\bTextField\(`**
   and only drops lines whose TRIMMED form starts with `//`. A trailing comment
   on a code line is not filtered. Do not write that token in a trailing comment.
6. **`flutter analyze` exits non-zero on infos.** That is intentional in this
   repo. Clean means clean.
7. **The two shell gates are not executable in this checkout.** Invoke them as
   `bash tool/check_brace_style.sh` and `bash tool/check_raw_colors.sh`.
8. **Every `if` gets braces with the body on its own line** (AGENTS.md, enforced
   by `check_brace_style.sh`). Prefer conditional expressions in widget trees.
</known_traps>

<tasks>

<task type="auto">
  <name>Task 1: The test seam, the type-step parameter, and the measurement</name>
  <files>lib/components/inputs/gw_text_field.dart, lib/screens/banxa_buy_screen.dart, test/banxa/buy_form_layout_test.dart</files>
  <action>
Three moves, all of which leave the rendered form BYTE-IDENTICAL to today. The
restructure is Task 2. Keeping them apart is what makes "the existing suite still
passes" a meaningful check on the extraction.

**1a. Add one parameter to `GWTextField`: `textStyle`.**

`GWTextField` hardcodes `style: GeniusWalletTypography.bodyLg`, so a hero amount
field cannot be built from it today. Add `final TextStyle? textStyle;` to the
constructor and apply it in exactly two places: the `TextFormField`'s `style:`,
and the `hintStyle:` inside the decoration (so a placeholder in a hero field is
not rendered at body size next to a 24px value). Both default to today's value
when null, so all eight existing call sites are unchanged.

This is an additive parameter on an existing component, in the same shape as the
`fill`, `borderless` and `focusRing` parameters already there. It is not a new
component, and no new component is needed anywhere in this plan.

**1b. Extract the form card into a public `BanxaBuyForm` widget.**

Today `BanxaBuyScreen` builds `MakeOrderCubit(BanxaApiService())` itself with no
injection seam, and the Banxa sandbox is unreachable under `flutter_test`. Both
existing test files record the consequence: the real screen can only ever be
pumped into its offline no-quote state, so the height-invariance claim is
currently pinned against a hand-copied RECONSTRUCTION of the card
(`buy_page_layout_test.dart:178-266`), which the file's own doc admits is a
design-contract proxy and not a regression guard.

Fix that by extraction rather than by injection. Create, in
`lib/screens/banxa_buy_screen.dart`:

```
class BanxaBuyForm extends StatefulWidget
```

- Public, so a test in another library can reach it. Dart privacy is per-file,
  which is exactly why the reconstruction exists.
- It RENDERS THE `GWCard` ITSELF. The screen's local `formCard` variable becomes
  `BanxaBuyForm(...)`. This is what lets a test measure the card's height with
  `tester.getSize(find.byType(BanxaBuyForm))`.
- It OWNS the two `TextEditingController`s. Move `_amountController` and
  `_walletController`, their `dispose()`, and the two "sync controller text from
  state" blocks (`:143-154`) out of `_BanxaBuyScreenState` and into this widget's
  `State`. They serve nothing else. The sync MUST move with them, or a chip tap
  would update the cubit and never reach the field.
- A `StatefulWidget`, not a helper method returning a `Widget` (AGENTS.md:49).

Parameters:

- `final MakeOrderState state;`
- `final double cardInnerWidth;` - the card's own available content width,
  computed by the caller. Task 2 uses it; in this task it is accepted and stored
  and nothing reads it yet. Do not add it in Task 2 instead: threading it now is
  what keeps Task 2 a pure layout change.
- `final VoidCallback onRetryCurrencies;`
- `final VoidCallback onGetQuote;`
- `final VoidCallback onBuy;`

The CTA's LABEL and ENABLED state are pure functions of `state` and move into the
widget verbatim from `:164-167`:

    label   = state.hasQuote ? 'Buy GNUS' : 'Get quote'
    enabled = state.hasQuote ? state.canCreateOrder : state.canGetQuote
    onPressed = enabled ? (state.hasQuote ? onBuy : onGetQuote) : null

The CTA's ACTIONS stay in the screen, because they show dialogs and sheets and
touch `context.read` and navigation: the disclaimer dialog, the
`showCheckoutOptionsSheet` re-open branch and `createOrder()` (`:169-209`) all
become the body of the `onBuy` callback the screen passes down. `onGetQuote` is
`() => context.read<MakeOrderCubit>().getQuote()`. `onRetryCurrencies` is the
existing `loadCurrencies(...)` call with its four `widget.initial*` arguments,
which is why it is a callback rather than something the form rebuilds itself.

Everything else moves across unchanged and in today's order: the retry row, the
three selects, the amount field, the wallet field, the grid, the CTA, the
trailing payment line. Keep every existing comment with the code it explains,
including the two invariant comments at `:324-326` and `:356-363`.

In the screen, inside the existing `LayoutBuilder` at `:450`, compute the number:

```
// GWCard's inner content width is its outer width MINUS 34: space8 (16) of
// padding each side PLUS one pixel each side for the hairline, because
// Container adds decoration.padding on top of its own padding. Measured and
// reasoned at _OrdersRail._inlineTrackMinWidth, which turns on the same two
// pixels.
```

with the outer width being `(constraints.maxWidth - GeniusWalletConsts.space8) / 2`
in the two-column branch and `constraints.maxWidth` in the stacked branch. Read
it from the SAME `wide` flag that already picks the layout, so the number and the
layout can never disagree - the idiom 260731-ti5 established two comments above.

**1c. Write the measurement test.**

New file `test/banxa/buy_form_layout_test.dart`. Follow the MEASUREMENT idiom at
`orders_header_track_test.dart:346-368`: read geometry, print it, assert only
that it is non-zero, so Task 2 can quote real numbers instead of an estimate.

Measure and print:

- The intrinsic widths of a `CURRENCY` and a `PAYMENT METHOD` `GWSelect` at
  representative worst-case Banxa labels. Use `'United States Dollar (USD)'` and
  `'Credit / Debit Card'`. Also print the sum plus one `space8` gap: that sum is
  the floor for Task 2's side-by-side threshold.
- The form card's real inner width at five window widths: 375, 500, 1048, 1328
  and 1560. Prove the formula rather than trusting it: pump the real
  `BanxaBuyScreen` offline at each width and compare `tester.getSize` of the
  full-width `GWDetailGrid` inside the card against the arithmetic above. If they
  disagree, the formula is wrong and Task 2's threshold would be built on a lie.
  1048 is the narrowest two-column window (the check is `constraints.maxWidth >=
  1024` and the page padding is 24), and 1560 is where the page hits its
  `GeniusBreakpoints.xxl` cap and stops growing.

Use the existing offline pump helper shape from `buy_page_layout_test.dart:50-70`
(`setSurfaceSize`, then ten 100ms pumps, never `pumpAndSettle`, which can hang on
the boot scrim).
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -5; flutter test test/banxa/ -r compact 2>&1 | tail -20</automated>
  </verify>
  <done>
`flutter analyze` is clean. Every pre-existing test in `test/banxa/` still passes
with no edit to any of them, which is the proof the extraction changed nothing.
The measurement test prints the two select widths, their sum plus gap, and the
five measured card inner widths, and the measured widths match the formula. The
executor has those numbers written down for Task 2.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: The form restructured to the design's order</name>
  <files>lib/screens/banxa_buy_screen.dart, test/banxa/fixtures.dart, test/banxa/buy_form_layout_test.dart, test/banxa/buy_page_layout_test.dart</files>
  <behavior>
Write these six as failing tests FIRST, against `BanxaBuyForm` and the real
screen. Every one fails today. "Assert on presence" is not acceptable for the
first one: presence passes today and proves nothing.

- **Test 1, the order.** Pump the real `BanxaBuyScreen` offline at a wide window.
  Compare `tester.getRect(...).top` in a chain: the `YOU SPEND` kicker is above
  the hero field, which is above the `GWControlTrack`, which is above the
  `CURRENCY` kicker, which is above the `WALLET ADDRESS` kicker, which is above
  the `GWDetailGrid`, which is above the CTA. Offline every one of these renders
  (empty currency lists still build a `GWSelect`), so this needs no seeded state.
- **Test 2, the chip tap.** Tap a shortcut chip. The hero field's text becomes
  that amount, and that chip reports `isSelected` through `Semantics`. Scope the
  finder with `find.descendant(of: find.byType(GWControlTrack), ...)` so it
  cannot accidentally match the amount now showing in the field. Use
  `tester.ensureSemantics()` and `matchesSemantics(isSelected: true)`; never
  reach into the private chip widget.
- **Test 3, the fiat symbol.** Pump `BanxaBuyForm` with a state carrying a EUR
  `FiatCurrency` (symbol `€`). No chip label starts with `$`, and at least one
  contains `€`.
- **Test 4, the height invariant.** Pump `BanxaBuyForm` at a fixed width with
  `quote == null`, measure `tester.getSize(find.byType(BanxaBuyForm)).height`,
  pump again with a real quote at the same width, measure again. Equal within
  1px. This is the one that protects the orders rail.
- **Test 5, the ladder length invariant.** Same measurement, but comparing a
  state whose payment method admits all four ladder amounts against one whose
  `maximum` admits only 100. Equal within 1px. A narrow-range payment method must
  not resize the rail either.
- **Test 6, the collapse.** At a window where the card's measured inner width
  clears the threshold, the `CURRENCY` and `PAYMENT METHOD` kickers share a
  `top` and differ in `left`. At a narrow window they differ in `top`. Pick both
  windows from Task 1's measured numbers and name them in the test's comment.
  Assert `tester.takeException()` is null at 1400 as well: that is the width
  where `IntrinsicHeight` queries the card, and it is what catches a
  `LayoutBuilder` or a scroll viewport sneaking inside.

Also assert `tester.takeException()` is null at 375, which is how a chip-row
overflow surfaces in a widget test.
  </behavior>
  <action>
**Fixtures first.** `testQuoteState()` in `test/banxa/fixtures.dart` has exactly
one consumer, and it is the reconstruction group this task deletes. Repurpose it
in place rather than adding a second fixture beside it: rename to
`testFormState`, and give it `fiatSymbol` (default `'$'`), `withQuote` (default
true), `paymentMethod` and `amountText` parameters, so one fixture serves the
quote/no-quote pair, the EUR case and the narrow-range case. Update its doc
comment: it is no longer "the quote card's fixture".

Then delete the group `quote grid height invariance (design-contract
reconstruction ...)` from `test/banxa/buy_page_layout_test.dart` along with the
paragraph of the file doc that explains it. Test 4 now pins the real widget, and
leaving a hand-copied replica behind is a thing that can pass while production
breaks. Do not delete the rest of that file: its offline group and its router
group still pin live claims.

**Then the form body**, in this order inside `BanxaBuyForm`'s `GWCard`:

1. The `Couldn't load currencies.` retry row, unchanged and still first. It is an
   error surface, not chrome.

2. `GWKicker('You spend')`, `space4` gap, then the hero `GWTextField`:
   - `textStyle: GeniusWalletTypography.numericHeadline` - 24px against
     `bodyLg`'s 16, with tabular figures so a live-typed number does not jitter
     column to column. Not `numericDisplay` (32px): this field lives in a card
     that is 470px wide at the narrowest two-column window, sharing that width
     with a symbol prefix.
   - `prefix: Text(symbol, ...)` in the same style, where `symbol` is
     `state.selectedFiat?.symbol`. Note that `prefixIcon` carries Material's
     48px minimum interactive slot, so the symbol sits in a gutter rather than
     tight against the digits. If that reads wrong on screen, the recorded
     fallback is to drop the prefix and put the code in the kicker
     (`YOU SPEND (USD)`); take it only if you looked, and say which you shipped
     in the SUMMARY.
   - `keyboardType` and `onChanged` unchanged from today.
   - `helper:` carries the limits, ALWAYS non-null, e.g. `Min: 20 / Max: 15000`
     and `Min: - / Max: -` when no payment method is selected. A helper that
     appears only sometimes changes the card's height at the moment a payment
     method is chosen, which is the same failure mode as the quote reflow. The
     `-` placeholder idiom is the one the quote grid already uses. Delete
     `_amountLabel` (`:557-565`): the limits move here and it has one call site.

3. The shortcut track. A private `_AmountChip` in this file, modelled on
   `_OrderToneChip` directly below it: same 32px height, same 120ms
   `AnimatedContainer`, same `radiusPill`, same `GWHoverable` lift onto
   `surfaceElevated`, same `Semantics(button: true, selected: ...)`, selected
   state a FLAT `gw.surfaceMenu` fill with `gw.textPrimary`. **No gradient in any
   state.** `GWTimeframeSegment`'s selected tab does wear the brand gradient, and
   copying that here would be the exact mistake `_OrderToneChip`'s own doc
   records replacing: this card carries the gradient CTA, and a shortcut chip
   must not be given the visual weight of the screen's one commitment action.
   Difference from `_OrderToneChip`: a label only, no count.

   Wrap the chips in `GWControlTrack` - the shared recessed well, whose five
   geometry values live in one file precisely so a fifth track cannot drift.
   Each chip goes in an `Expanded`, so the track fills the card width and the
   four chips share it evenly. That is what the screenshot draws, and it is also
   what makes the row overflow-proof at every width without a scroll viewport,
   which trap 2 forbids.

   The ladder is `const [100, 500, 1000, 5000]`, filtered by
   `state.minAmount` / `state.maxAmount` when they are non-null, with the honest
   comment from A2 about what is and is not validated when they are null.

   Label: `NumberFormat.currency(symbol: symbol, decimalDigits: 0).format(v)`,
   the idiom already used at `markets_table.dart:401`. `intl` is already a
   dependency. When `symbol` is empty (Banxa can return one), fall back to
   `'<amount> <code>'` using `state.fiatCode` rather than printing a bare number.

   Tap writes a bare parseable number: `setAmountText(v.toStringAsFixed(0))`.
   Selected is `state.amountValue == v`, so typing 500 by hand lights the same
   chip. Nothing new is stored: no `setState`, no local selection field.

   Wrap the track in a fixed-height `SizedBox` whose height is the chip height
   plus 8 (3+3 of track padding, 1+1 of hairline), with that arithmetic in the
   comment, and render a null child when the filtered ladder is empty. Without
   this, a payment method whose range excludes every ladder amount collapses the
   row and resizes the rail. Test 5 is the guard.

4. `CURRENCY` and `PAYMENT METHOD`, side by side above the threshold and stacked
   below it. Decide from `widget.cardInnerWidth` against a private
   `static const double _sideBySideMinWidth`, set from Task 1's measured select
   widths plus a `space8` gap plus headroom. Document the crossover in the style
   of `_OrdersRail._inlineTrackMinWidth`: the measured intrinsic widths, the
   arithmetic, and the window sizes at which each branch is live in both the
   single-column and two-column page layouts. State whether the stacked branch is
   reachable at all in the two-column layout, given that the card's inner width
   there runs 470px at the narrowest two-column window to 726px at the page cap.
   A branch that is unreachable at every real window size should be said to be
   unreachable, not quietly kept.

   Side by side is a `Row` of two `Expanded` columns with a `space8` gap. No
   `LayoutBuilder` (trap 1). Each column is kicker, `space4`, `GWSelect` with
   `label: null`, so both branches keep identical vertical rhythm.

   `CURRENCY` is today's `Fiat` select, relabelled. Its `items` and `onChanged`
   are unchanged.

5. The `Crypto Currency` select, full width, only when
   `state.cryptos.length > 1` (A1), with the placement rationale from the
   decisions section as a comment.

6. `WALLET ADDRESS` kicker and its field, unchanged apart from A4's label move.

7. The `GWDetailGrid`, the CTA and the trailing payment line, all unchanged, and
   with their two invariant comments intact. Extend the first of those comments
   by one sentence: the reflow risk is no longer only the grid and the trailing
   line, it is now also the chip row's fixed slot and the always-present limits
   helper.

Reread the traps before running the suite. The two most likely ways this task
fails are a `LayoutBuilder` inside the card (green at 500px, throws at 1400px)
and a formatted string reaching `setAmountText`.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -5; flutter test test/banxa/ -r compact 2>&1 | tail -30</automated>
  </verify>
  <done>
All six tests pass, and each one was seen failing before the implementation
landed. Every other test in `test/banxa/` passes unedited, except the
reconstruction group which was deliberately deleted and is named as such. The
threshold constant carries its measured arithmetic and its live/unreachable
branch finding in a comment. `flutter analyze` is clean.
  </done>
</task>

<task type="auto">
  <name>Task 3: Gates, real numbers, and the assumptions record</name>
  <files>.planning/quick/260731-uhe-buy-gnus-form-restructured-to-the-design/260731-uhe-SUMMARY.md, .planning/todos/pending/2026-07-31-buy-gnus-form-restructure.md</files>
  <action>
Run all four gates and quote what they actually printed. The baseline before this
task is 978 passing, analyze clean, both shell gates 0. The test count will have
moved: six added, two deleted with the reconstruction group. Report the real
number, not the arithmetic you expected.

    flutter analyze
    flutter test
    bash tool/check_brace_style.sh
    bash tool/check_raw_colors.sh

Neither shell script is executable in this checkout, hence `bash`. `flutter
analyze` exits non-zero on infos by design; clean means clean.

Write `260731-uhe-SUMMARY.md`. Beyond the usual what-changed, it must carry:

**A section headed `## Assumptions Jakub can flip in one line`**, listing A1
(crypto select gated on `cryptos.length > 1`), A2 (chips follow the selected
fiat and its payment-method limits), A3 (the CTA keeps its two-step label), A4
(every label on this card is a `GWKicker`), the hero prefix decision from Task
2, and the measured side-by-side threshold. One line each for what was assumed,
one for what to change to flip it.

**A section recording what the restructure does NOT protect.** The height
invariant now holds across the quote arriving and across the ladder filtering.
It does not hold across currency load: the `Crypto Currency` select appearing
when Banxa returns more than one crypto changes the card's height, and so does
the limits helper's text if it ever wraps. Both happen before the user
interacts, not mid-interaction, which is why they are accepted. Say so plainly
rather than letting the next reader assume the invariant is total.

**The measured numbers** from Task 1: the two select widths, the five card inner
widths, and the threshold chosen from them.

Then move
`.planning/todos/pending/2026-07-31-buy-gnus-form-restructure.md` to
`.planning/todos/completed/`, since its three open forks are now answered by A1,
A2 and A3.

**DO NOT COMMIT AND DO NOT PUSH.** Leave the working tree dirty for Jakub.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3; flutter test 2>&1 | tail -5; bash tool/check_brace_style.sh; echo "brace exit=$?"; bash tool/check_raw_colors.sh; echo "rawcolor exit=$?"; git status --short | head -20</automated>
  </verify>
  <done>
Four gates run and quoted with real output: analyze clean, the full suite's real
pass count at or above 978, both shell gates exit 0. The SUMMARY carries the
assumptions section, the not-protected section and the measured numbers. The todo
is in `completed/`. `git status` shows the changes UNSTAGED and UNCOMMITTED, and
`git log -1` is still the same commit the task started on.
  </done>
</task>

</tasks>

<verification>
- Read the form card top to bottom in the browser or on macOS and check it
  against the screenshot: hero amount, chips, two selects side by side, wallet,
  grid, CTA.
- Resize the window from 1560 down to 375 and watch the currency/payment row
  collapse once and only once, with no overflow stripes and no exception.
- With the app running against a live Banxa response, tap each chip and confirm
  the CTA enables when the amount is in range.
- Confirm the orders rail beside the form does not move when a quote lands. This
  is the invariant the whole plan is built around.
</verification>

<success_criteria>
- The form renders in the design's order, proven by geometry rather than by
  presence.
- The amount field is the hero, in a type step strictly larger than every other
  field on the card.
- Chips are denominated in the selected fiat, respect the payment method's
  limits when there are any, and write a parseable value.
- The card's height is identical with and without a quote, and identical across
  ladder lengths.
- The currency/payment row collapses at a MEASURED threshold, with the
  measurement recorded in the code.
- No new component. One additive parameter on `GWTextField`. No `LayoutBuilder`
  and no scroll viewport inside the card.
- The retry row survives and stays reachable.
- Four gates quoted with real numbers.
- Nothing committed, nothing pushed.
</success_criteria>

<output>
Create `.planning/quick/260731-uhe-buy-gnus-form-restructured-to-the-design/260731-uhe-SUMMARY.md` when done.
</output>
