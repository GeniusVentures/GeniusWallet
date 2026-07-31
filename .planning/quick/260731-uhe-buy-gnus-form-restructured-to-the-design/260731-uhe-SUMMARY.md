---
phase: quick-260731-uhe
plan: 01
subsystem: banxa-buy
status: complete
tags: [layout, form, banxa, responsive, test-seam]
requires:
  - 260731-ti5 (the orders rail derives its height from this card)
provides:
  - BanxaBuyForm (public test seam for the Buy GNUS form card)
  - GWTextField.textStyle (additive, backwards compatible)
affects:
  - lib/screens/banxa_buy_screen.dart
  - lib/components/inputs/gw_text_field.dart
tech-stack:
  added: []
  patterns:
    - "responsive decision computed in the page's LayoutBuilder and passed down as a number"
    - "fixed-height slot for a filterable control track"
key-files:
  created:
    - test/banxa/buy_form_layout_test.dart
  modified:
    - lib/screens/banxa_buy_screen.dart
    - lib/components/inputs/gw_text_field.dart
    - test/banxa/fixtures.dart
    - test/banxa/buy_page_layout_test.dart
    - test/banxa/orders_header_track_test.dart
decisions:
  - "A1: the Crypto Currency select stays, gated on cryptos.length > 1"
  - "A2: shortcut chips are denominated in the selected fiat and filtered by the payment method's range"
  - "A3: the CTA keeps its two-step Get quote / Buy GNUS label"
  - "A4: every label on this card is a GWKicker, the field's own label is null"
  - "the side-by-side threshold is 480px, set from the TYPICAL select pair, not the worst case"
metrics:
  tests_before: 978
  tests_after: 987
  completed: 2026-07-31
---

# Quick task 260731-uhe: Buy GNUS form restructured to the design Summary

The Buy GNUS form card now leads with the number being entered: a hero amount field in a 24px type step over a row of fiat-denominated shortcut chips, with Currency and Payment method side by side below it, on a threshold measured from the real controls rather than guessed.

## What changed

**`lib/components/inputs/gw_text_field.dart`** gains one additive parameter, `textStyle`, applied to both the value and the hint so an empty hero field and a filled one sit at the same size. It defaults to today's `bodyLg`, so all eight existing call sites are byte-identical.

**`lib/screens/banxa_buy_screen.dart`** is where the work is:

- The form card is extracted into a public `BanxaBuyForm extends StatefulWidget`, which renders the `GWCard` itself and owns both `TextEditingController`s and the two "sync controller text from state" blocks. That sync had to move with the controllers, or a chip tap would have updated the cubit and never reached the field.
- The card's body is reordered to the design: retry row, `YOU SPEND` + hero field, shortcut chips, `CURRENCY` / `PAYMENT METHOD`, the gated crypto select, `WALLET ADDRESS`, the quote grid, the CTA, the trailing payment line.
- `_amountLabel` is deleted. The min/max limits moved onto the hero field's `helper:`, which is now always present.
- A private `_AmountChip` (modelled on `_OrderToneChip` directly below it, no gradient in any state) and a private `_LabelledField` (the A4 kicker-over-field pairing) are added. No new shared component.
- The responsive decision is computed in the screen's existing `LayoutBuilder` and handed down as `cardInnerWidth`. No `LayoutBuilder` and no scroll viewport went anywhere inside the card.

## The four gates, as actually run

| Gate | Command | Result |
| --- | --- | --- |
| Analyzer | `flutter analyze` | `No issues found!` |
| Tests | `flutter test` | `04:44 +987: All tests passed!` |
| Brace style | `bash tool/check_brace_style.sh` | exit `0` |
| Raw colours | `bash tool/check_raw_colors.sh` | exit `0` |

Baseline was 978 (measured at the start of this session, not assumed). 987 = 978 + 11 new tests in `buy_form_layout_test.dart` - 2 deleted with the reconstruction group.

## Measured numbers

Everything below was pumped by the two `MEASUREMENT` tests in `test/banxa/buy_form_layout_test.dart`, not derived.

`GWSelect` intrinsic widths at real Banxa labels:

| Case | Currency | Payment method | Sum + `space8` gap |
| --- | --- | --- | --- |
| Worst case (`United States Dollar (USD)` / `Credit / Debit Card`) | 476.0 | 364.0 | 856.0 |
| Typical (`Euro (EUR)` / `Credit Card`) | 220.0 | 236.0 | 472.0 |
| Chrome only (`USD`) | 108.0 | - | - |

The form card's inner content width, predicted by `outer - 34` and confirmed against the rendered `GWDetailGrid` at every window:

| Window | Layout | Predicted | Measured |
| --- | --- | --- | --- |
| 375 | single column | 317.0 | 317.0 |
| 500 | single column | 442.0 | 442.0 |
| 1048 | two column (narrowest) | 470.0 | 470.0 |
| 1328 | two column | 610.0 | 610.0 |
| 1560 | two column (xxl cap) | 726.0 | 726.0 |

**Threshold chosen: `_sideBySideMinWidth = 480`** (472 typical budget + 8 headroom). Both branches are live in both page layouts: single column stacks below window 538 and goes side by side from 538 to 1047; two column stacks from 1048 to 1067 and goes side by side from 1068 up.

## Assumptions Jakub can flip in one line

None of these were answered before the build. Each is a defensible call, and each reverses cheaply.

**A1 - the Crypto Currency select stays, gated on `state.cryptos.length > 1`.** Deleting a live control that reads from `state.cryptos` is a behaviour change, not a layout change, so it is hidden rather than removed. On a GNUS-only Banxa response the form matches the design exactly.
*To flip:* delete the `if (state.cryptos.length > 1) ...[ ... ]` block in `BanxaBuyForm.build` (to drop it entirely), or change the condition to `state.cryptos.isNotEmpty` (to always show it).

**A2 - the shortcut chips follow the selected fiat and its payment method's limits.** `$100` is false with EUR selected, so the label is built from `state.selectedFiat.symbol`. The ladder is `[100, 500, 1000, 5000]` filtered by `state.minAmount` / `state.maxAmount`.
*To flip:* replace `_chipLabel`'s body with a hardcoded `'\$$amount'`, or drop the `.where(...)` on `_ladder` to stop filtering.

**A3 - the CTA keeps its two-step label**, `Get quote` until a quote exists and `Buy GNUS` after. The screenshot shows `Buy GNUS`, but a still image cannot tell "the quote step was removed" from "this is the post-quote state".
*To flip:* change `final ctaLabel = state.hasQuote ? 'Buy GNUS' : 'Get quote';` to `const ctaLabel = 'Buy GNUS';` (and decide separately what the enabled rung should then be).

**A4 - every label on this card is a `GWKicker`, with the field's own `label:` left null.** Mixing kickers and built-in sentence-case labels on one card is the partial-adoption failure `CONVENTIONS.md` names. Cost, and the reason this is an assumption: this card's labels now differ from Settings, onboarding and the account manager, which all still use the built-in label.
*To flip:* change `_LabelledField.build` to return `field` alone and pass the label back into each `GWSelect` / `GWTextField` as `label:`.

**The hero prefix: shipped as a `prefix:` symbol, NOT looked at live.** The plan's primary was a `prefix: Text(symbol)` and its recorded fallback was to drop the prefix and put the code in the kicker (`YOU SPEND (USD)`). I shipped the primary, and I have to say plainly that I did **not** look at it on screen: the app is running from this working tree and the task forbids rebuilding into it. So the known cost is unverified rather than accepted. `prefixIcon` carries Material's 48px minimum interactive slot, so the symbol sits in a gutter rather than tight against the digits, which is not what the screenshot draws. It does not change the field's height (the 24px value plus padding is already 64px), so no invariant turns on it.
*To flip:* delete the `prefix:` argument and change `_LabelledField('You spend', ...)` to `_LabelledField('You spend (${state.fiatCode})', ...)`.

**The measured side-by-side threshold, 480px.** This is the one judgement in the file that is not arithmetic. The worst-case budget is 856px and the card never exceeds 726px in the two-column layout, so a no-truncation rule would have made the side-by-side branch dead exactly where the design asks for it. A `GWSelect` ellipsizes rather than overflowing, so the floor is set from the typical pair instead.
*To flip:* change `_sideBySideMinWidth` in `_BanxaBuyFormState`. 856 forces stacked everywhere in two-column; 0 forces side by side everywhere.

## What this does NOT protect

The height invariant now holds across the quote arriving and across the ladder filtering to four, one or zero chips. It is **not** total, and the next reader should not assume it is:

- **Currency load changes the card's height.** If Banxa returns more than one crypto, the `Crypto currency` select appears (A1) and the card grows by one field. This happens on load, before the user interacts, so the rail settles once rather than jumping mid-interaction.
- **The limits helper would change the height if it ever wrapped.** It is always present, so its presence is constant, but its text is not. `Min: 20 / Max: 15000` is short enough not to wrap at the 317px phone-width card today; a payment method with very large limits in a currency with long grouping could in principle push it to two lines.
- **Nothing here protects the light theme or the visual walk.** No live look happened this session.

## Deviations from plan

**1. [Rule 3 - blocking] `orders_header_track_test.dart` needed its finders scoped.**
Four of its tests used a bare `find.byType(GWControlTrack)`, which was unambiguous until this task gave the form card beside the rail a track of its own. Both are the same shared container, so the type alone no longer identifies the rail's. Fixed by scoping through the rail's own card (`find.ancestor(of: find.text('YOUR ORDERS'), matching: find.byType(GWCard)).first`) in a new `railTrack` finder, with a comment recording why. This weakens no claim: every assertion still reads the rail's real geometry. Files: `test/banxa/orders_header_track_test.dart`.

**2. [Rule 2 - missing correctness] Test 5 was rewritten after a mutation showed it was hollow.**
The plan specified the ladder-length invariant as "four chips versus one". A mutation check (deleting the fixed slot's `height`) left that comparison **green**, because one chip is exactly as tall as four. The case the fixed slot actually exists for is the **empty** ladder, which only a payment method whose range excludes every amount reaches. The test now measures four, one and zero, and the zero case is the one that fails under the mutation (608 vs 648). Had I shipped the plan's version literally, the guard would have been decorative.

**3. `_labelled` was promoted from a helper method to `_LabelledField`.**
AGENTS.md:49 forbids a `_buildFoo()` returning a `Widget`. Caught before the gates, converted to a private `StatelessWidget`.

**4. Test count is 11 new, not the plan's 6.**
The plan's six claims are all present; they came out as nine tests plus the two `MEASUREMENT` tests, because the order chain and the type-step claim read more clearly apart, and the collapse claim needs three windows (side by side, stacked, and the 1400px `IntrinsicHeight` probe).

## Evidence the tests are real, not paperwork

The two height-invariance tests are the point of this task, so they were checked by mutation rather than trusted:

| Mutation | Test | Result |
| --- | --- | --- |
| Trailing payment line made `if (state.hasQuote)` | quote invariant | **FAILS** - 628 vs 648 |
| Fixed track slot `height:` deleted | ladder invariant | **FAILS** - 608 vs 648 (after the Deviation 2 rewrite) |

The implementation was restored byte-identically after each (md5 `5f6455d06137949a2fe4577f50302514` before and after).

The order, chip, fiat-symbol and collapse tests reference widgets the pre-restructure form did not contain at all (`YOU SPEND`, a `GWControlTrack` inside the form card, `CURRENCY` / `PAYMENT METHOD` kickers, `GWTextField.textStyle`), so they could not have passed against it.

## Out of scope, logged not fixed

`dart format --set-exit-if-changed lib test` reports two files as unformatted: `test/dev/dev_mock_sgnus_test.dart` and `test/dev/mock_transactions_sticky_test.dart`. Both are pre-existing drift from other work in this uncommitted tree and neither is touched by this task. Reformatting them would put unrelated churn in the review diff.

## Git state

**Nothing was committed and nothing was pushed.** No `git add`, no branch, no stash. Every change is unstaged in the working tree on `redesign/jakub-260730`, alongside the rest of the day's uncommitted work, for Jakub to review and open the PR himself into `ui-redesign-port`.

`.planning/todos/pending/2026-07-31-buy-gnus-form-restructure.md` moved to `.planning/todos/completed/`; its three open forks are answered by A1, A2 and A3 above.

## Human walk checklist

1. Read the card top to bottom against the screenshot: hero amount, chips, two selects side by side, wallet, grid, CTA.
2. **Look hard at the `$` prefix gutter** (see the assumptions section). This is the one thing shipped unseen.
3. Resize 1560 down to 375 and watch the currency/payment row collapse once and only once, with no overflow stripes.
4. With a live Banxa response, tap each chip and confirm the CTA enables when the amount is in range.
5. Confirm the orders rail does not move when a quote lands.

## Self-Check: PASSED

- `lib/screens/banxa_buy_screen.dart` - FOUND
- `lib/components/inputs/gw_text_field.dart` - FOUND
- `test/banxa/buy_form_layout_test.dart` - FOUND
- `test/banxa/fixtures.dart` - FOUND
- `.planning/todos/completed/2026-07-31-buy-gnus-form-restructure.md` - FOUND
- `.planning/todos/pending/2026-07-31-buy-gnus-form-restructure.md` - correctly ABSENT
- No commit hashes to verify: nothing was committed, by instruction.
