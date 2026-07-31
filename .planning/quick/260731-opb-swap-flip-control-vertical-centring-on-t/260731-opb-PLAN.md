---
phase: quick-260731-opb
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/squid_router/swap_seam.dart
  - lib/squid_router/swap_screen.dart
  - test/squid_router/swap_flip_centring_test.dart
autonomous: true
requirements: [QUICK-260731-OPB]

must_haves:
  truths:
    - "The flip control's vertical centre equals the midpoint of the gap between the two SwapField cards in EVERY state, not only at rest."
    - "A pay card taller than the receive card does not move the control off the seam."
    - "The control stays tappable across its full 44px height, including the parts that overlap the two cards."
    - "No pixel constant tuned to today's card heights exists anywhere in the layout; the only numeric inputs are the space8 gap token and the children's own measured sizes."
  artifacts:
    - lib/squid_router/swap_seam.dart
    - test/squid_router/swap_flip_centring_test.dart
  key_links:
    - "swap_screen.dart builds SwapSeam instead of Stack(alignment: Alignment.center); if it reverts, the geometry test fails."
    - "SwapSeam receives its gap from GeniusWalletConsts.space8, the same token the deleted SizedBox used, so the visual gap is unchanged."
    - "The control is SwapSeam's LAST child, so defaultPaint draws it on top and defaultHitTestChildren offers it the tap first - both properties the old Stack had and neither may be lost."
---

<objective>
The Swap flip control sits exactly on the seam between the two amount cards in every
state, not only when both cards happen to be the same height.

Purpose: at rest the control looks centred; select a token and it drifts, because the
current layout centres it on the bounding box of BOTH cards rather than on the boundary
between them. Reported by Jakub on the 2026-07-31 walk, item 3 of HANDOFF-2026-07-31.md.

Output: a small layout widget that makes the seam a computed position rather than an
assumption, the screen rewired onto it, and a geometry test that fails today.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@lib/squid_router/swap_screen.dart
@lib/squid_router/swap_field.dart
@lib/squid_router/token_flip_button.dart
@lib/tokens/token_info_screen.dart
@test/squid_router/route_details_card_test.dart
@test/dashboard/compute_panel_wiring_test.dart
</context>

<findings>

## What was confirmed against the real source before planning

Read `swap_field.dart` end to end. The handoff's description of the growth mechanism is
close but not accurate, and the plan is built on what the widget actually does.

**The gap between the cards is `GeniusWalletConsts.space8` = 16.0** (`genius_wallet_consts.dart:29`),
emitted as a `SizedBox` at `swap_screen.dart:726-728`. The flip control is 44x44 with a
5px `surfaceElevated` border (`token_flip_button.dart:42-51`), so it overlaps 14px into
each card and the border blends into the card fill. That overlap is the design and it is
preserved.

**The arithmetic of the drift.** The Stack's height is `payH + 16 + receiveH`, so
`Alignment.center` puts the control's centre at `(payH + 16 + receiveH) / 2`. The seam's
midpoint is `payH + 8`. The difference is `(receiveH - payH) / 2`, exactly half the height
difference. A taller pay card therefore pulls the control UP, which is precisely what
Jakub reported (*"zostaje w miejscu lub przesuwa sie do gory"*).

**What actually makes the pay card taller - three mechanisms, in order of size:**

1. **The token pill grows when a token is selected.** With `selectedToken != null` the pill
   gains a 32x32 `ClipOval` logo (`swap_field.dart:220-257`). The right-hand `Column`
   (pill + `space4` + balance row) then overtakes the 38px hero amount slot, which is the
   `Row`'s height driver when no token is chosen. This is the largest contributor and it
   fires on token SELECTION alone.
2. **The MAX chip.** `showMax = isSelectingFrom && selectedToken?.balance != null`
   (`swap_field.dart:63`) - pay side only, by construction. The chip carries `vertical: 2`
   padding plus a 1px border on each side, so the balance row grows about 6px over the bare
   balance text.
3. **The fiat sub-line.** `usdValue != null` requires `selectedToken != null` AND a known
   price (`fiatValue` returns null on an unknown symbol, `transaction_utils.dart:126-133`).
   It is NOT pay-side-only: whichever side has a token and a price gets it. It adds
   `space2` (4.0) plus one `bodySm` line.

**Two corrections to the bug report, recorded deliberately:**

- **The balance/MAX row does not "appear".** The `Padding` wrapping it is unconditional
  (`swap_field.dart:276-355`); when there is no balance the `Text` renders `""` and still
  occupies a line box. Only the MAX chip appears, and it changes the row's height by the
  chip's own padding and border, not by a whole row.
- **Typing an amount does not change the card's height.** The `TextField` is single-line
  and scrolls horizontally rather than wrapping, and the placeholder branch is pinned to
  the same 8px `contentPadding` on purpose (`swap_field.dart:155-164`). The fiat sub-line
  shows `$0.00` with an empty amount as soon as a price is known, so it is token selection
  that changes the geometry, not the digits. An amount is still typed in the test, because
  that is the state that was reported and it must be proven.

**Everything the screen needs in a widget test is already mocked.** `fetchTokens()` returns
`mockTokens` and `fetchBalances()` returns `mockSquidBalances` with no network call
(`squid_token_service.dart:9-53`). ETH on chainId 1 carries a 1 ETH balance, so
`SwapScreen(preselectSymbol: 'ETH', preselectChainId: 1)` seats ETH on the PAY side
(`swap_preselection.dart:76` - held seats pay). `_loadTokens` reads only
`WalletDetailsCubit.state.selectedWallet?.address` and force-unwraps it, so the test needs
one seeded cubit and nothing else. `TransactionsCubit` is read only inside the submit
handler (`swap_screen.dart:313`) and is not needed to build.

## The freeze rule: checked, and it does not literally apply

`test/freeze_rule_test.dart` and commit `37639d5` ban `AutoSizeText` and `FittedBox`
because each derives a continuous font size or scale from available space, handing skia's
`ParagraphCache` a new key per frame. The banned thing is a continuously varying TEXT
STYLE, not a continuously varying position, and the guard scans only dashboard-reachable
directories, which `lib/squid_router/` is not. So the letter of the rule does not hit a
measure-then-position approach. Approach (b) is still rejected below, on its own merits.

</findings>

<decision>

## Approach chosen: (c), an exact single-pass layout - implemented as a custom RenderBox

The control's centre must land at `payHeight + gap / 2`. That number is not knowable
without the pay card's laid-out height, so the only correct answers are ones that read it.

**Why not (a), structural / overlap inside the Column.** It breaks the tap target, which
hard constraint 2 forbids. `RenderBox.hitTest` gates everything behind
`_size.contains(position)`, so a child painted outside its parent's box is not hit-testable
in the overflowing region. A 44px control centred on a 16px `OverflowBox` or a
`heightFactor: 0` `Align` would answer taps in at most the middle 16px of its height, and
`RenderFlex` hit-tests its children in reverse order, so the top 14px would be swallowed by
the pay card's `TextField` instead. The visual would be right and the control would be
half dead. This is a provable defect, not a preference.

**Why not (b), measured.** It needs two frames: measure the pay card, then reposition on
the next build. That means the control is off-seam for one frame after every height change,
and a size-reporting wrapper feeding `setState` is a relayout loop of exactly the shape
this project has been bitten by twice on a drag-resize. It also reintroduces a derived
number into the layout, which is the property the original comment was right to be proud of.
The freeze rule does not literally cover it (see findings), and it is rejected anyway.

**Why the chosen approach is not `CustomMultiChildLayout`.** That widget cannot size itself
from its children: `RenderCustomMultiChildLayoutBox.performLayout` calls
`delegate.getSize(constraints)` BEFORE laying any child out, and the default is
`constraints.biggest`. This layout sits inside a `SingleChildScrollView`, so the incoming
height constraint is infinite and `getSize` would have to return a hardcoded height - the
exact magic number hard constraint 1 forbids. `Flow` has the same limitation. A
`MultiChildRenderObjectWidget` with a hand-written `RenderBox` does not: it lays the cards
out first and sizes itself from them.

The repo already has this pattern, at a smaller scale: `_FillHeight` / `_RenderFillHeight`
in `lib/tokens/token_info_screen.dart:1568-1581`, including the `ponytail:` comment naming
its ceiling. Match that house style.

**The tap target under the chosen approach.** The control is centred on the seam, which is
at least 14px below the top of the box and 14px above its bottom whenever both cards are
taller than 14px. It therefore lies entirely inside the parent's bounds and
`_size.contains` passes for all 44px. Because it is the LAST child,
`defaultHitTestChildren` (which walks from `lastChild` backwards) offers it the tap before
either card. Both properties match what the current `Stack` gives. The test proves it
anyway - hard constraint 2 says the tap target does not change, so it gets measured, not
assumed.

</decision>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: The failing geometry test - the tall pay card state</name>
  <files>test/squid_router/swap_flip_centring_test.dart</files>
  <behavior>
    - Test A (rest, both cards empty): the flip control's centre dy equals the midpoint
      between the pay card's bottom and the receive card's top, within 0.5px. PASSES today
      and must keep passing.
    - Test B (pay token seated plus an amount typed): the pay card is measurably taller
      than the receive card, AND the control's centre still equals the seam midpoint within
      0.5px. FAILS today. This is the only test in the file that proves anything about the
      bug.
    - Test C (tap target, tall state): a tap 2px below the control's top edge and a tap 2px
      above its bottom edge each flip the tokens. PASSES today and is a regression guard on
      the fix, not a bug repro.
  </behavior>
  <action>
Create `test/squid_router/swap_flip_centring_test.dart`.

Host: copy the two-part harness that already exists in this repo rather than inventing one.
Take the `_host` shape from `test/squid_router/route_details_card_test.dart` (a
`MaterialApp` with `ThemeData(extensions: [GWColors.dark()])` and a `Scaffold` body) and
the seeded-cubit shape from `test/dashboard/compute_panel_wiring_test.dart`: a private
`_SeededWalletDetailsCubit extends WalletDetailsCubit` that calls
`emit(state.copyWith(selectedWallet: ...))` in its own constructor, plus a four-line
`_UnusedApi implements GeniusApi` stand-in using `noSuchMethod` exactly as
`test/tokens/coin_page_stat_rail_test.dart` declares it. The seeded wallet needs a non-null
`address`, because `_loadTokens` force-unwraps it; nothing else on the wallet is read by
this screen. `selectedNetwork` may stay null - `fetchBalances` ignores its `chainIds`
argument and returns `mockSquidBalances` regardless. Do NOT provide a `TransactionsCubit`:
it is read only inside the submit handler and adding it would hide the fact that the build
path does not need it.

Wrap the screen in `BlocProvider<WalletDetailsCubit>` and mount `SwapScreen`. The screen
starts with `isLoading == true` and renders `Loading()`; drive it with explicit
`tester.pump()` calls, NOT `pumpAndSettle`, because `Loading()` may animate forever and
`pumpAndSettle` would hang rather than fail. Set a deterministic surface with
`tester.view.physicalSize` and `tester.view.devicePixelRatio`, and reset both with
`addTearDown(tester.view.reset)`; pick a width that leaves the 560px capped column
un-squeezed, for example 1200x1400, so the cards are laid out at their natural width and
the whole column fits without scrolling.

Geometry helpers, all real, no golden pixel values. `find.byType(SwapField)` yields the two
cards in document order: `.at(0)` is You Pay, `.at(1)` is You Receive. Compute
`payRect = tester.getRect(find.byType(SwapField).at(0))`,
`receiveRect = tester.getRect(find.byType(SwapField).at(1))`, and
`seamY = (payRect.bottom + receiveRect.top) / 2`. Take the control's centre with
`tester.getCenter(find.byType(TokenFlipButton)).dy` rather than a rect: `TokenFlipButton`
wraps its content in `AnimatedRotation`, and a rotation about the centre leaves the centre
fixed while it does move the corners. Assert with `closeTo(seamY, 0.5)`.

Test A mounts `const SwapScreen()` and asserts the invariant at rest.

Test B mounts `SwapScreen(preselectSymbol: 'ETH', preselectChainId: 1)`. ETH on chainId 1
holds 1 ETH in `mockSquidBalances`, so `resolvePreselection` seats it on the PAY side.
After the pump, type into the pay amount with
`tester.enterText(find.byType(TextField).first, '1.5')` and pump again. Then, BEFORE the
centring assertion, assert `payRect.height, greaterThan(receiveRect.height)` with a `reason`
saying in full that a fixture which does not make the pay card taller turns this test into a
duplicate of Test A and proves nothing about the bug. Record the two measured heights and
the measured drift in the task's report. If typing triggers the route debounce and the test
ends with a pending timer, pump past the debounce window recorded in `_debouncedFetchRoute`
rather than removing the `enterText`.

Test C reuses Test B's state. Read `controlRect = tester.getRect(find.byType(TokenFlipButton))`,
then `tester.tapAt(controlRect.topCenter + const Offset(0, 2))`, pump past the 400ms
`AnimatedRotation`, and assert the tokens swapped - the observable is that the pay side's
symbol is now on the receive side, readable from the two `SwapField` widgets via
`tester.widget<SwapField>(find.byType(SwapField).at(n)).selectedToken`. Repeat for
`controlRect.bottomCenter - const Offset(0, 2)`, which flips them back. State in the test's
doc comment that this test passes before the fix as well, and that it exists because two of
the three approaches considered would have silently made those two points untappable.

Write a file-level doc comment recording the arithmetic of the bug: the Stack's centre is
`(payH + gap + receiveH) / 2`, the seam is `payH + gap / 2`, so the control drifts by half
the height difference. Do not add a fourth test yet; the extreme-difference case lands in
Task 2 with the widget it needs.

Braces on every `if`, body on its own line (`AGENTS.md`). No `Colors.*` or `Color(0x...)`.
No em dashes anywhere in the file - write " - " instead.
  </action>
  <verify>
    <automated>flutter test test/squid_router/swap_flip_centring_test.dart</automated>
  </verify>
  <done>
The file compiles and runs. Test A passes, Test C passes, Test B FAILS with a measured
pixel gap between the control's centre and the seam. The report quotes the real failure
output including both card heights and the drift. A run in which Test B passes means the
fixture failed to produce an asymmetric pay card and the test must be fixed before Task 2
is started - a green Test B before the fix is a broken test, not a working layout.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: SwapSeam - the seam becomes a computed position, and the screen is rewired</name>
  <files>lib/squid_router/swap_seam.dart, lib/squid_router/swap_screen.dart, test/squid_router/swap_flip_centring_test.dart</files>
  <behavior>
    - Test D (new, extreme difference): SwapSeam given a 40px-tall first child and a
      400px-tall second child centres its third child on the boundary between them, within
      0.5px. A layout carrying any offset tuned to today's cards fails this.
    - Tests A, B and C from Task 1 all pass unchanged, against the same finders.
  </behavior>
  <action>
Create `lib/squid_router/swap_seam.dart`.

Public `SwapSeam extends MultiChildRenderObjectWidget` with a `double gap` field and three
named `Widget` parameters - `payCard`, `receiveCard`, `control` - forwarded to
`super(children: [payCard, receiveCard, control])` in the initializer list. It cannot be a
`const` constructor because it builds that list. Implement `createRenderObject` returning
the render object below and `updateRenderObject` assigning `gap`.

The render object: `RenderSwapSeam extends RenderBox with
ContainerRenderObjectMixin<RenderBox, _SeamParentData>` and
`RenderBoxContainerDefaultsMixin<RenderBox, _SeamParentData>`, where
`_SeamParentData extends ContainerBoxParentData<RenderBox>`. Override `setupParentData` to
install it. Give `gap` a setter that returns early when the value is unchanged and calls
`markNeedsLayout` otherwise.

`performLayout`:
- Assert three children and `constraints.hasBoundedWidth`. Take `width` as
  `constraints.maxWidth`.
- Lay the two cards out with `BoxConstraints.tightFor(width: width)` and
  `parentUsesSize: true`. Full width matches what they get today: the enclosing `Column`
  passes loose constraints and each card's `Row` holds a `Flexible`, so they already expand.
- Lay the control out with `const BoxConstraints()` and `parentUsesSize: true`, so it keeps
  choosing its own 44x44. Do not hand it a size.
- Offset the pay card to `Offset.zero` and the receive card to
  `Offset(0, payHeight + gap)`.
- The seam is `payHeight + gap / 2`. Offset the control to
  `Offset((width - controlWidth) / 2, seam - controlHeight / 2)`.
- `size = constraints.constrain(Size(width, payHeight + gap + receiveHeight))`.

Override `paint` to call `defaultPaint`, which draws first child to last, so the control
lands on top of both cards exactly as the `Stack` drew it. Override `hitTestChildren` to
call `defaultHitTestChildren`, which walks from `lastChild` backwards, so the control is
offered the tap before either card. Both overrides are load-bearing; say so in a comment
naming what breaks without them.

Do not implement `computeDryLayout`. Leave a `ponytail:` comment in the house style
(`_FillHeight` / `_RenderFillHeight` at `lib/tokens/token_info_screen.dart:1568-1581` is
the local precedent)
naming the ceiling - this box has no dry layout, so it must not be placed under a parent
that asks for one, such as `IntrinsicHeight` - and the upgrade path, which is to lay the
two cards out with `ChildLayoutHelper.dryLayoutChild` and return the same sum.

`swap_seam.dart` must not import anything from the swap feature. It takes three opaque
children and knows nothing about `SwapField` or `TokenFlipButton`, which is what lets Test D
drive it with plain sized boxes.

Then rewire `swap_screen.dart`. Replace the `Stack(alignment: Alignment.center)` at
`swap_screen.dart:682-757` with a `SwapSeam` whose `gap` is `GeniusWalletConsts.space8` -
the same token the deleted `SizedBox` used, so the visual gap is byte-identical - whose
`payCard` and `receiveCard` are the two existing `SwapField` calls moved across verbatim
(every argument unchanged: labels, controllers, `onChanged`, `tokensForSide` calls,
`pickerEmptyTitle`/`pickerEmptyMessage`, the D-09 `emptyPlaceholder`), and whose `control`
is the existing `TokenFlipButton(onFlip: _flipTokens)` unchanged. Delete the `SizedBox`
that used to separate the two cards - its height now lives in `gap` and leaving both would
double it. Do not touch `TokenFlipButton` itself.

Replace the comment above that block. The one there now asserts that near-equal card
heights put the Stack's centre on the seam, which is the false premise this task removes.
The replacement states what the layout now guarantees and why the two rejected approaches
were rejected, in this substance: the seam is computed as the pay card's laid-out height
plus half the gap, so it cannot drift as the cards diverge; the control is not put inside
the `Column` with an overflowing wrapper because a `RenderBox` refuses hits outside its own
size, which would have left most of the 44px control dead to taps; and it is not positioned
from a measured height fed back through `setState`, because that costs a frame of lag on
every height change and puts a derived number back into the layout. Keep the property the
old comment was right about and make it true this time: no hardcoded pixel offset exists in
this layout, only the `space8` token and the children's own measured sizes. No em dashes in
the comment.

Finally add Test D to `test/squid_router/swap_flip_centring_test.dart`: mount `SwapSeam`
directly inside the same `MaterialApp` host with `payCard` a `SizedBox(height: 40)`,
`receiveCard` a `SizedBox(height: 400)`, `control` a keyed `SizedBox(width: 44, height: 44)`,
and `gap: GeniusWalletConsts.space8`. Assert the control's centre equals
`(payBottom + receiveTop) / 2` within 0.5px. Note in its doc comment that a 10x height
difference is not a realistic swap state and that this is the point: it is the case that a
tuned constant cannot survive.

Braces on every `if`, body on its own line. No `Colors.*` or `Color(0x...)`. No em dashes
anywhere in either file. Do not change the control's size, gradient, border, tap target or
`onFlip` behaviour.
  </action>
  <verify>
    <automated>flutter test test/squid_router/swap_flip_centring_test.dart && grep -c 'SwapSeam' lib/squid_router/swap_screen.dart</automated>
  </verify>
  <done>
All four tests pass, Test B included. `grep -c 'SwapSeam' lib/squid_router/swap_screen.dart`
reports at least 2 (the import and the call site). `lib/squid_router/swap_seam.dart` imports
nothing from `lib/squid_router/` other than Flutter itself. `token_flip_button.dart` is
untouched.
  </done>
</task>

<task type="auto">
  <name>Task 3: Run every gate, report real numbers, leave the tree uncommitted</name>
  <files>(no files modified; verification only)</files>
  <action>
Run the four gates from the repo root and quote the REAL output of each. Do not paraphrase
and do not claim a baseline that was not run this session (`AGENTS.md`: "Quote real output;
never claim a baseline you didn't run"). The Flutter SDK lives at
`/Users/jakub/development/flutter/bin/flutter` if it is not on `PATH`.

1. `dart format lib/squid_router/swap_seam.dart lib/squid_router/swap_screen.dart test/squid_router/swap_flip_centring_test.dart` - report which files it changed.
2. `flutter analyze` - report the issue count for the root package. It exits non-zero on
   infos, which is intentional; a non-zero exit with 0 new issues is not a failure, a new
   issue is.
3. `flutter test` - the FULL suite, not just the new file. Report the passing and failing
   counts as printed. The pre-existing baseline is roughly 930 passing per
   HANDOFF-2026-07-31.md; report the exact number this run produced and the delta, and name
   the four new tests as the expected increase. Any other movement is a regression and must
   be investigated, not rounded off.
4. `bash tool/check_brace_style.sh` and `bash tool/check_raw_colors.sh` - both must report 0.
   Note that `check_raw_colors.sh` covers a fixed directory list; report whether
   `lib/squid_router` is inside it, so the 0 is not read as coverage it does not have.

Then STOP. Do NOT run `git add`, `git commit`, `git push`, or any other git write. This
overrides the GSD atomic-commit default. The branch is `redesign/jakub-260730`, Jakub
reviews the change locally and opens the PR into `ui-redesign-port` himself. Leave every
file modified and unstaged.

Close the report with the one thing automation cannot settle: the visual walk. Give Jakub
the exact steps - run
`flutter run -d macos --dart-define=GW_DEV_TOOLS=true`, open Swap, confirm the control sits
on the seam with both cards empty, pick a pay token and confirm it is still on the seam,
type an amount, then pick a receive token as well, and tap the control at its very top edge
and at its very bottom edge to confirm both still flip. Include the measured pay and
receive card heights from Test B so he knows how large a drift he is looking for the absence
of.
  </action>
  <verify>
    <automated>bash tool/check_brace_style.sh && bash tool/check_raw_colors.sh && git status --porcelain lib/squid_router test/squid_router</automated>
  </verify>
  <done>
Both shell gates report 0. `flutter analyze` shows no new issues. The full `flutter test`
run is quoted with real counts and the delta accounted for by the four new tests.
`git status --porcelain` shows the three files as modified or untracked and NOTHING staged
or committed. `git log -1` is unchanged from the start of the task.
  </done>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
|----------|-------------|
| (none new) | This change moves widgets inside one screen's layout. It crosses no process, network or storage boundary, adds no dependency, and reads no user input that was not already read by the unchanged `SwapField`. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
|-----------|----------|-----------|----------|-------------|-----------------|
| T-OPB-01 | Denial of Service | `RenderSwapSeam.performLayout` | low | mitigate | A hand-written `RenderBox` that sized itself wrong could loop layout or overflow. Bounded by construction: one pass, no `markNeedsLayout` from inside layout, no feedback from a child's size into its own constraints. Test D proves the size is correct at a 10x height difference. |
| T-OPB-02 | Tampering | flip control tap surface | low | mitigate | A layout change can silently shrink an interactive target, which on a wallet's swap control means a user aiming at flip lands on the pay amount field instead. Test C measures taps 2px inside both the top and bottom edges of the 44px control. |
| T-OPB-SC | Tampering | npm/pip/cargo installs | n/a | accept | No package install of any kind is in this plan. No `pubspec.yaml` change, no new dependency. |
</threat_model>

<verification>
- `flutter test test/squid_router/swap_flip_centring_test.dart` - four tests, all green, and
  Test B was demonstrated red before Task 2.
- Full `flutter test` - no regression against the roughly 930 baseline beyond the four
  additions.
- `flutter analyze` - no new issues.
- `bash tool/check_brace_style.sh` - 0.
- `bash tool/check_raw_colors.sh` - 0.
- No commit, no push, no staged files.
</verification>

<success_criteria>
- The flip control's vertical centre equals the midpoint between the two cards within 0.5px
  in all four measured states: both empty, pay token seated with an amount typed, and a
  synthetic 40px-versus-400px pair.
- The control remains tappable 2px inside both its top and bottom edges in the tall-pay
  state, and both taps flip the tokens.
- No pixel constant tuned to the cards exists in the layout. The only numbers are
  `GeniusWalletConsts.space8` and sizes measured from the children in the same layout pass.
- `TokenFlipButton` is byte-identical to its pre-plan state.
- The comment above the layout is replaced with one that is true and that records why the
  overlap and measured approaches were rejected.
- The working tree is left uncommitted on `redesign/jakub-260730`.
</success_criteria>

<output>
Create `.planning/quick/260731-opb-swap-flip-control-vertical-centring-on-t/260731-opb-SUMMARY.md` when done.
</output>
</content>
</invoke>
