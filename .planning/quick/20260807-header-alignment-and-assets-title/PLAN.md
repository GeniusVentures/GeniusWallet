---
phase: quick-260807-aln
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/cards/gw_view_all_link.dart
  - lib/components/cards/gw_section_title.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/components/overlay/mobile_header.dart
  - test/components/gw_view_all_link_gradient_test.dart
  - test/components/gw_view_all_link_paint_test.dart
  - test/components/assets_header_scheme_c_test.dart
  - test/components/assets_header_scheme_a_test.dart
  - test/components/mobile_header_brand_and_pill_test.dart
autonomous: false
requirements: [QUICK-260807-ALN]

must_haves:
  truths:
    - "The Assets section title says Assets in 18px white titleLg, the same component, size and colour as Markets, Transactions and Compute. Scrolled past in one pass the four titles are indistinguishable in treatment."
    - "The portfolio total is still on the dashboard. It moves to its own full-width band directly under the title, not back into the title row, so the crowding that started sketch 178 does not come back with it."
    - "GWViewAllLink paints flat textSecondary grey at rest again, at all three render sites, exactly as it did before 2026-08-07. Hover stays flat textPrimary white and the 3px arrow slide is untouched."
    - "The four false claims that were in gw_view_all_link.dart's comments BEFORE today do not come back with the colour. The file describes what it actually paints, and it records that the brand gradient was tried on 2026-08-07 and reverted, so nobody restores it a third time."
    - "The brand mark and the GNUS.AI wordmark are both visibly larger in the phone header. Nothing else in that header moves: titleSpacing stays at the AppBar default and actions stays at space8."
    - "GWSectionTitle carries no dead parameter. titleBlock had exactly one consumer, that consumer is gone, and the component is back to one shape for eight call sites."
    - "test/components/gw_section_title_rhythm_test.dart is byte-identical to its pre-task state and green. Its md5 is the gate."
    - "flutter analyze ends at 0 issues and flutter test ends at 1142 or more passing with 0 failing. No assertion is relaxed anywhere."
    - "Nothing is committed. The working tree is left dirty for Jakub."
  artifacts:
    - test/components/assets_header_scheme_a_test.dart
    - test/components/gw_view_all_link_paint_test.dart
  key_links:
    - "contentTopInset goes 20 -> 0 on the Assets GWSectionTitle. It is a MEASURED description of the first widget under the title, and after this change that widget is the total band (paints at its own top pixel), not a CoinCardRow ListTile. Leaving it at 20 renders a 30px gap under a band that has no slack of its own and re-breaks the rhythm."
    - "The total drops the height: 28/24 override and uses numericHeadline as shipped (24/32). That override existed ONLY to squeeze a two-line block into GWSectionTitle's 44px reservation. Outside the reservation it is a bug, not a feature - it would tighten the band's line box for no reason."
    - "The band is a SIBLING of GWSectionTitle in the Column, not a child, so it must carry its own horizontal space4 padding to line its left edge up with the title. Without it the total hangs 8px left of the word Assets."
    - "The pill's borderControl edge is load-bearing and is NOT touched by this task. surfaceMenu on surfaceElevated is 1.11:1, so the boundary carries WCAG 1.4.11 alone at 3.30:1."
    - "The brand lockup is non-flex and intrinsic in the AppBar title Row; the pill is the Expanded that absorbs every pixel of shrink. That is why growing the brand can never truncate GNUS.AI, and why the measured slack figure is an observation rather than a risk."
---

<objective>
Three changes Jakub asked for on his iPhone, 2026-08-07, in four messages over the course of
the walk. All three are the same instinct: **put the dashboard sections back to one
consistent treatment**, and make the brand readable.

**Change 1 - the Assets section title goes back to the standard component.** In English:

> The assets section on the dashboard looks alright, but Assets was supposed to respect the
> same component - the same colour and everything, like transaction, like compute, like
> market - so it needs changing.

This reverses sketch 178 scheme C, which shipped hours ago. C demoted the word Assets to an
11px uppercase kicker in textSecondary and promoted the total to the section headline. His
objection is exactly the cost that was recorded and flagged at the time, in
`coins_screen.dart`'s own comment: Markets, Transactions and Compute all say their names in
18px white `titleLg` and Assets stopped matching. The named fallback in that comment is
sketch 178 **scheme A**, and that is what this plan builds.

**Change 2 - the brand lockup gets bigger, and only bigger.** This one narrowed twice on
device. It began as four asks (bigger, move left, pill moves right, corner radius) and
landed here:

> Leave the logo where it is, the alignment is right, just make it bigger.
> Just make the logo and the name bigger for now, leave the wallet and the alignment as
> they are, we will judge after the changes.

So: the mark and the wordmark grow together. **Nothing else in the header moves.** He is
deferring the rest until he has seen the bigger lockup. The `WalletPill` radius question he
asked directly is answered in this plan as ANALYSIS with a recommendation, and deliberately
not built.

**Change 3 - View all goes back to grey.** In English:

> And on view all - let's go back to the old grey colour it used to have.

This reverses the second half of the same quick task that shipped scheme C. It belongs in
this plan rather than its own, because it is the same instinct as Change 1: the dashboard
sections back to one treatment.

Purpose: three things shipped this morning that made the dashboard read as four sections
with three different rules. This puts it back to one rule, keeps the number a wallet exists
to show, and makes the brand legible.

Output: four source files reverted or grown, two test files replaced by honestly-named
successors, one test file extended, nothing committed.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/sketches/178-assets-header-total-vs-view-all/README.md
@.planning/codebase/CONVENTIONS.md
@lib/components/cards/gw_section_title.dart
@lib/components/cards/gw_view_all_link.dart
@lib/components/overlay/mobile_header.dart
</context>

<measurements>

Everything below was measured against the working tree on `redesign/navigation-260806`, not
quoted from the sketch. Where a sketch figure and a measured figure disagree, the measured
one governs and the difference is stated.

## Baseline gates, measured now

| Gate | Value |
| --- | --- |
| `flutter test` | **1142 passing, 0 failing** |
| `flutter analyze` | **No issues found** (0 repo-wide) |

## Change 1 - what scheme A actually costs in Flutter

`GWSectionTitle`'s box height is `edgePad(2) + max(44, leftBlock) + bottomPad`, where
`bottomPad = max(0, 26 - slack(10) - contentTopInset)`.

| | today (scheme C) | scheme A |
| --- | --- | --- |
| left block | kicker 16 + total 28 = 44 | `titleLg` line box = 24 |
| `max(44, block)` | 44 | 44 (the reservation wins) |
| `contentTopInset` | 20 (`CoinCardRow` ListTile snap) | 0 (the band paints at its own top) |
| `bottomPad` | `max(0, 26-10-20)` = 0 | `max(0, 26-10-0)` = **16** |
| **title box** | **46** | **62** |
| total band | (inside the title) | `numericHeadline` 24/32 line box = **32** |
| extra spacer under the band | n/a | **0** - see below |
| **panel header cost** | **46** | **94** |

**Measured delta: +48px.** The sketch recorded +52. The difference is deliberate and is two
decisions:

1. **No spacer between the band and the first row.** The sketch put 14px there. The
   `CoinCardRow` already brings 20px of ListTile centring slack of its own, which is
   *exactly* the gap that ships today between the total and the first row under scheme C.
   Adding 14 on top would render 34 below the band against 26 above it and read
   bottom-heavy. Zero new spacing token, and the band-to-row relationship is preserved by
   construction.
2. **The total stays at 24px, not the sketch's 28.** There is no 28px token. `numericHeadline`
   is 24 with a shipped `height: 32/24`, and 28/32 and 24/32 have the *same* 32px line box,
   so this costs nothing in height and buys an on-token size. It also lets the
   `height: 28/24` override die: that override existed only to squeeze a two-line block
   inside the 44px reservation, and there is no reservation to squeeze into any more.

**If the measured delta comes out above 52, STOP** and report rather than adjusting a
number. Something else grew.

### The title gap, and the fact that the approved 30 is already gone

The sketch records "Jakub approved `contentTopInset: 20`, rendered gap 30 on device this
morning", and lists scheme A as changing it to 26. Both true, and there is a third fact
neither the sketch nor the code says out loud:

| state | slack | bottomPad | contentTopInset | rendered R2 |
| --- | --- | --- | --- | --- |
| before scheme C (plain title) | 10 | 0 | 20 | **30** - the number he approved |
| today, scheme C | **0** | 0 | 20 | **20** |
| scheme A | 10 | 16 | 0 | **26** |

Under scheme C the `titleBlock` consumes the full 44px reservation, so there is no
centring slack left, and the rendered gap silently became 20. **The 30 he approved has not
existed on this branch since scheme C shipped.** Scheme A moves it 20 -> 26, and 26 is the
number every other panel renders. This is still a change to an approved input and is named
at the checkpoint - but it is a move *towards* the value he approved, not away from it.

R1 (box to title, frozen at 12 by his 2026-08-06 constraint) is `edgePad(2) + slack(10)` and
is **unchanged** by everything in this plan.

### Width at 390pt, measured by walking the bundled Inter `hmtx` advances

Content box inside the title: `390 - 2*space3(6) - 2*(space6(12)+1px border) - 2*space4(8)` = **336**.

| element | face / size | measured |
| --- | --- | --- |
| `Assets` | Inter SemiBold 18 (`titleLg`) | 59.76 |
| `GWViewAllLink` (`VIEW ALL` + 6 gap + 15 icon) | Inter SemiBold 11, tracking 0.6 | 77.94 |
| **title row slack** | | **198.30** |
| `$1,234,567.89` | Inter Bold 24 (`numericHeadline` w700) | 172.63 |
| `+12.34%` | Inter Medium 13 (`labelMd`) | 55.62 |
| **band slack, percent only** | | **99.75** |

Nothing is near an overflow. The `numericHeadline` figure uses default advances; `tnum` is
on, which can shift it a hair, so the widget probe in the new test is what actually holds
it.

### The dollar day-change: NOT restored, and why that is a decision

`coins_screen.dart` records that scheme C dropped the dollar figure from the 24h move
because `+$1,234.56 - +12.34%` (139.64 measured) beside a 24px total overflowed the title
row, and calls it "a real information loss against what shipped before 2026-08-07".

Scheme A's band has 336px with no link competing, so the full pair fits: `336 - 172.63 - 8 -
139.64` = **15.73px of slack** at the worst realistic total.

**Do not restore it in this task.** It fits, but 15.73px is thin, Jakub asked for the title
treatment and not the total's content, and he explicitly asked to keep this small and judge
it after the changes land. Restoring it here would confound the thing he is about to
assess. Recorded as a named one-line follow-up with its real margin attached.

### Desktop, which this reaches whether we like it or not

`coins_screen.dart` is one file for both surfaces and `ContributionsDashboardView` mounts it
on desktop too. The desktop Assets panel therefore also grows 48px, inside a slot whose
`SingleChildScrollView` absorbs it - nothing overflows, roughly one row's worth of list
scrolls out of first view.

**Do not fork the header by breakpoint to avoid this.** Two different Assets headers in one
app is the exact inconsistency Jakub is complaining about, relocated. One header, both
surfaces. Named at the checkpoint so he knows before he opens a desktop build; he reviews on
iPhone, so this is a note and not a blocker.

## Change 2 - the brand size, and the upscale that constrains it

`lib/assets/images/geniusappbarlogo.png` is **38x38**, verified by reading the IHDR. There is
no 2.0x or 3.0x directory anywhere under `lib/assets/images/`, so on a 3x iPhone the render
is a straight bilinear upscale.

| logical height | physical at 3x | upscale from 38 | verdict |
| --- | --- | --- | --- |
| 24 (today) | 72 | **1.89x** | already off the pixel grid, already soft |
| **28 (recommended)** | 84 | **2.21x** | last step before the smear reads as blur |
| 32 | 96 | 2.53x | **this is where I expect him to see it** |
| 36 | 108 | 2.84x | no |

**Where softness begins, stated plainly:** the mark is an intricate line drawing, so a
1-source-pixel stroke renders `3H/38` device pixels wide with no hard edge. Below about 2.5x
that reads as antialiasing; at and above it, it reads as blur. 24 is already borderline -
the shipped comment concedes it, calling 24 "the largest step that stays under a 2x
upscale". **28 is the largest size I would draw from this asset.** 32 is not a taste call
against 28, it is the point where the artefact becomes the thing you notice.

### Wordmark, and the lockup width budget at 390pt

Measured from `assets/fonts/Inter-Bold.ttf` by summing `hmtx` advances. `GNUS.AI` at 15 is
**63.91px**, which reproduces the earlier work's figure exactly, so the model below is
trustworthy.

Lockup = `29/38 * H` (the crop) + `space4`(8) + wordmark. Pill available =
`390 - titleSpacing(16) - actions(16) - lockup - space6(12)`. Slack = available minus
`kWalletPillMaxWidth`(236).

| mark | word | mark box | `GNUS.AI` | lockup | pill available | slack vs 236 |
| --- | --- | --- | --- | --- | --- | --- |
| 24 | 15 | 18.32 | 63.91 | 90.23 | 255.77 | **+19.77** (today) |
| 28 | 17 | 21.37 | 72.43 | 101.80 | 244.20 | +8.20 |
| **28** | **18** | **21.37** | **76.69** | **106.06** | **239.94** | **+3.94** |
| 32 | 18 | 24.42 | 76.69 | 109.11 | 236.89 | +0.89 |
| 32 | 20 | 24.42 | 85.21 | 117.64 | 228.36 | **-7.64** |

**Recommendation: mark 28, wordmark 18px.** Slack is **+3.94px, positive** - the pill's
declared 236 cap still binds at 390pt. Reasons for 18 over 17: 18 is on the type scale
(it is `titleLg`'s size, so the wordmark now reads at the same size as the section titles
Change 1 is restoring - a real systemic tie, not a coincidence), and the growth is
1.20x against the mark's 1.167x, near-proportional either way.

Runner-up: **28 / 17**, +8.20 slack, marginally more proportional, but 17 is not a step on
the scale. Rejected: **32 / 20**, which is both the softness threshold and the only row
where slack goes negative.

**On negative slack, since the brief asked:** it is not a defect and must not be hidden by
trimming `kWalletPillMaxWidth`. The Row lays the non-flex `BrandLockup` out first and hands
the remainder to the `Expanded` pill, whose name `Text` ellipsizes. Negative slack means only
that the 236 cap stops being the binding constraint at 390pt; the brand can never be the
thing that shrinks. At 28/18 the question is moot - slack is positive.

### The Dynamic Type fuse moves to hold an invariant, not to change one

The wordmark carries `ConstrainedBox(maxWidth: 180)`, a fuse that ellipsizes `GNUS.AI` if
Dynamic Type ever drives it that wide. Today's headroom is `180 / 63.91` = **2.82x**. Left at
180 with an 18px wordmark it drops to `180 / 76.69` = **2.35x**, silently. Scaling the fuse
by the same 1.20 (180 -> **216**) preserves the shipped 2.82x exactly. This is holding an
existing invariant constant while changing what it derives from, which is the opposite of
scope creep - but it is a number change and it is named here so it is visible.

### The gap between mark and wordmark stays at `space4`

The `ClipRect(widthFactor: 29/38)` crop drops the source's right gutter, so `space4` renders
as a true 8 and the mark's own left ink margin is one source column = `28/38` = **0.74px** at
H=28 (was 0.63px at H=24). The brand's left ink edge therefore moves right by 0.11px, which
is why "the alignment is frozen" survives a size change literally and not just in spirit.
Growing the gap to `space6` would widen the lockup 4 more and push slack to -0.06. Named as
the one-token step if the lockup reads cramped; not taken.

### The named asset upgrade

`lib/assets/images/geniusappbarlogo.png` re-exported at **114x114** (3x of 38) is a pure
drop-in: the render height is fixed in code and the crop is a `widthFactor`, so no layout
number changes. At 114 the mark is lossless up to `height: 38`. Same path, same filename.

## Change 2, part two - the WalletPill component question, ANSWERED not BUILT

He asked directly: "Sprawdz czy mamy taki komponent czy to byl nowo utworzony." He deserves
the answer even though he has deferred the change.

**`WalletPill` is NEW.** Hand-built in `mobile_header.dart` this session as
`Material(color: gw.surfaceMenu, shape: StadiumBorder(side: BorderSide(color: gw.borderControl)))`.
A `StadiumBorder` is fully rounded by definition, which is why the corners read as round.

**But the SHAPE is not new.** Census of what this app uses for equivalent chrome:

| candidate | shape | what it is |
| --- | --- | --- |
| `_NetworkChip`, `network_dropdown_selector.dart:97` | `Material` + `StadiumBorder(side:)` + `Clip.antiAlias` + `SizedBox(height: 44)` | **the identical recipe**, and the widget `WalletPill` replaced in this slot |
| `GWControlTrack` | `surfaceSunken` + `borderSubtle` hairline + `radiusPill`(48) + `EdgeInsets.all(3)` | a track holding chips, not a single control |
| `GWCard` | `radiusLg` (15) | a card |
| `GWSelectRow` | `radiusMd` (12) | a row in a list |
| account drawer rows | `radiusXs` (4) | list rows |
| bridge / banxa / transactions chips | `radiusPill` (48) | pill controls, everywhere |

`radiusPill` is 48 and a 44-tall box clamps it to 22, so **`radiusPill` and `StadiumBorder`
paint the identical curve at this height** - `GWControlTrack` already relies on that clamp.

**Recommendation, for the follow-up and not for this task: the stadium is correct, and the
widget should express it through `radiusPill` rather than the `StadiumBorder` class.** One
line, pixel-identical, and it puts the pill on the same token as every other pill control.
Reuse-wholesale is rejected: `_NetworkChip` is private, takes a `Network` and a `selected`
flag, and extracting it would drag the network drawer into this diff.

If he still reads it as too round after seeing it beside the network chips in the drawer it
opens, the named squarer step is `radius2xl` (16) via `RoundedRectangleBorder`. **Whatever
happens to the shape, `borderControl` stays:** `surfaceMenu` on `surfaceElevated` is 1.11:1,
so the fill cannot identify the control and the boundary carries WCAG 1.4.11 alone at
3.30:1.

## Change 3 - the View all revert

`textSecondary` `#8A8F9D` on `surfaceElevated` `#0C0E14`, computed from the real tokens
(`genius_wallet_colors.dart:182` and `:127`): relative luminances 0.2749 and 0.004425, ratio

```
(0.2749 + 0.05) / (0.004425 + 0.05) = 5.97:1
```

**5.97:1**, against a 4.5:1 bar for text. Passes AA at all three render sites, which all sit
on `DashboardScrollContainer` and therefore on one surface. It does not reach AAA's 7:1, but
AA is the bar and this is the colour that shipped for months.

### The four doc claims that must NOT come back

`git show HEAD:lib/components/cards/gw_view_all_link.dart` carries them. Reverting the
colour must not revert the prose. Concretely, the restored file must not claim:

1. that hover paints the brand-CTA gradient - the code painted flat white on hover;
2. that the widget draws a gradient underline under the label width - variant D shipped
   without one and the body has never drawn one;
3. the same underline claim a second time, in the `labelStyle` comment's justification for
   `height: 1.0`;
4. that this is a `StatefulWidget` - hover moved to `GWHoverable` in 23-05.

<!-- planner-discipline-allow: gradient underline -->
<!-- planner-discipline-allow: StatefulWidget -->

**Read that list as forbidden strings, not as text to paraphrase into the file.** Task 1's
gates negative-grep the file for these exact literals, so quoting the list back into a doc
comment - even as a "what this does NOT do" note - turns the gates red. Describe the widget
positively instead: what it paints, and that hover state lives in `GWHoverable`.

Write what the widget does after the revert, and **keep the record** that it wore the brand
gradient for part of 2026-08-07 and why it came back.

### What the revert does to the "max one gradient per surface" question

Before: three gradient `GWViewAllLink`s + the gradient SWAP dock (fill) + the gradient
bottom-bar active tab, on one screen. After: **the dock and the active tab.**

Read as governing gradient FILL, which is how the house rule is written (fill = commitment,
outline = everything else, max one per surface), **the rule now holds as written** - exactly
one gradient fill on the dashboard, the dock.

**Recommendation on the active tab: leave it.** Do not reopen it. It is now the only gradient
text on the screen, so its meaning sharpened from "a navigational affordance" (diluted across
four sites) to "this is where you are"; the bottom bar is chrome on its own surface, so "per
surface" is satisfied; and Jakub approved it explicitly on 2026-08-06 ("follow the
component"). Changing it here would be precisely the quick-task-regresses-a-plan-decision
failure this project has already been bitten by.

One honest wrinkle to write down rather than bury: `gw_view_all_link.dart`'s current doc
calls gradient text "this app's mark for a navigational affordance". With the links flat,
the only gradient text left is a marker that leads nowhere, so that sentence is falsified by
this change and must not survive it.

</measurements>

<tasks>

<task type="auto">
  <name>Task 1: GWViewAllLink back to flat grey, with prose that matches the paint</name>
  <files>lib/components/cards/gw_view_all_link.dart, test/components/gw_view_all_link_gradient_test.dart, test/components/gw_view_all_link_paint_test.dart</files>
  <action>
Revert the colour decision in `GWViewAllLink.gradient(gw, {required bool hovered})` to what
shipped before 2026-08-07: at rest, a `LinearGradient` whose two stops are both
`gw.textSecondary`; on hover, both stops `gw.textPrimary`. Keep the static exposed - it is
what makes the stops assertable instead of pixel-reading an opaque `Shader`. Drop the now
unused `genius_wallet_gradient.dart` import.

Leave untouched: the single `srcIn` `ShaderMask`, the opaque-white children, the `GWHoverable`
plumbing, the `IntrinsicWidth` residue and its comment, and the 3px arrow slide on hover.

Rewrite the class doc and the `gradient` doc to describe the widget as it will then be. Four
specific things the pre-2026-08-07 prose got wrong are enumerated in the `<measurements>`
section above under "The four doc claims that must NOT come back" - do not let any of them
back in while restoring the colour. Positively, the doc must state: rest is flat secondary
grey, hover is flat primary white, there is no underline anywhere in this widget, hover
state lives in `GWHoverable` so this is a `StatelessWidget`, and the measured 5.97:1 for
grey on the one surface all three sites paint on.

Then write the record that stops a third round. In prose: the brand gradient was put at rest
on 2026-08-07 on the argument that iOS has no hover, so rest is the only state the target
device ever renders and flat grey was permanently the dimmest thing in every panel row.
That observation was correct. Jakub saw it on device the same day and chose consistency
across the three sections over the emphasis, verbatim "a z view all - wrocmy do starego
szarego koloru jak byl". Colour is therefore decided; if the link ever reads too quiet, the
next lever is weight or size, not colour.

Also note in the doc that with these links flat, the only gradient text left on the
dashboard is the bottom-bar active tab, so this file may no longer describe gradient text
as this app's general mark for a navigational affordance.

Rename `test/components/gw_view_all_link_gradient_test.dart` to
`test/components/gw_view_all_link_paint_test.dart` - a file whose name says gradient while
asserting there is none is exactly the kind of stale label this codebase's comments exist to
prevent. Then take its five tests one at a time:

1. The rest-stops test: REWRITE, do not delete. Its subject inverts - rest is now one colour
   repeated - but the file's most valuable idea survives and changes sign: assert rest's two
   stops are `gw.textSecondary`, assert they are equal to each other, and assert they are
   NOT `GeniusWalletGradient.brandCta.colors`. That last one is the regression guard that
   keeps the gradient from coming back a third time, and it is the reason to rewrite rather
   than delete.
2. The hover test: KEEP, assertions unchanged. Hover is still flat `textPrimary`, and rest
   and hover still differ (secondary vs primary). Only its comment needs the new framing.
3. The light-appearance test: REWRITE, do not delete, and the harness fix must survive
   verbatim. `GWColors.light()` does NOT return light values on its own - its surface fields
   read an appearance-aware getter off the `GWAppearance` singleton, so under a dark global
   a naive light test silently asserts the dark branch. Keep the
   `GWAppearance.instance.value` flip plus the teardown restore, keep the luminance
   precondition, and repoint the assertion: light rest paints `light.textSecondary`, still
   one repeated stop, still not the raw brand stops. Keeping this test alive is what keeps
   that harness fix in running code rather than in a comment.
4. The one-`ShaderMask` test: KEEP unchanged. Still true, still the thing that catches a
   second paint path.
5. The 3px arrow slide test: KEEP unchanged, including its comment about measuring the icon
   rather than the `AnimatedContainer`.
  </action>
  <verify>
    <automated>flutter test test/components/gw_view_all_link_paint_test.dart</automated>
    <automated>test ! -f test/components/gw_view_all_link_gradient_test.dart</automated>
    <automated>grep -vE '^\s*(//|///)' lib/components/cards/gw_view_all_link.dart | grep -c 'brandCtaText' | grep -qx 0</automated>
    <automated>grep -c 'gradient underline' lib/components/cards/gw_view_all_link.dart | grep -qx 0</automated>
    <automated>grep -c 'StatefulWidget' lib/components/cards/gw_view_all_link.dart | grep -qx 0</automated>
    <automated>grep -c 'painted with the brand-CTA GRADIENT' lib/components/cards/gw_view_all_link.dart | grep -qx 0</automated>
    <automated>LC_ALL=C grep -c $'\xe2\x80\x94' lib/components/cards/gw_view_all_link.dart test/components/gw_view_all_link_paint_test.dart | grep -vq ':[1-9]'</automated>
  </verify>
  <done>
The link paints flat `textSecondary` at rest and flat `textPrimary` on hover at all three
sites. The arrow still slides 3px. `gw_view_all_link_paint_test.dart` has five tests, all
green, with the `GWAppearance` harness fix intact and a live assertion that rest is not the
brand stops. None of the four pre-2026-08-07 false claims is present, and the file records
why the gradient came and went.
  </done>
</task>

<task type="auto">
  <name>Task 2: the Assets title back to the sibling treatment, total to its own band</name>
  <files>lib/components/coins/view/coins_screen.dart, lib/components/cards/gw_section_title.dart, test/components/assets_header_scheme_c_test.dart, test/components/assets_header_scheme_a_test.dart</files>
  <action>
Build sketch 178 scheme A in `coins_screen.dart`. The `if (isDashboard)` header becomes two
siblings in the existing `Column`:

First, `GWSectionTitle(title: 'Assets', trailing: GWViewAllLink(onTap: () => context.push('/assets')))`
with **no** `titleBlock` and **no** `contentTopInset` - the default 0 is correct and the
reason must be written at the call site: `contentTopInset` is a MEASURED description of the
first widget under the title, that widget is no longer a `CoinCardRow`, and the band paints
at its own top pixel. The 20 that is there today describes a `ListTile` centring snap that
now sits one widget further down. Leaving it at 20 renders a 30px gap under a band with no
slack of its own.

Second, a total band. Give it its own `StatelessWidget` in this file (AGENTS.md - not a
`_buildBand()` helper) taking the already-computed `total`, `dayChange` and `pctOfTotal`.
Structure: `Padding(EdgeInsets.symmetric(horizontal: GeniusWalletConsts.space4))` wrapping a
baseline-aligned `Row` of the formatted total in `GeniusWalletTypography.numericHeadline`
`copyWith(fontWeight: FontWeight.w700, color: gw.textPrimary)` - **as shipped, with no
`height` override** - then, guarded by `total > 0` exactly as today, a `SizedBox(width: space4)`
and the percentage in `labelMd` coloured `statusSuccess` or `statusError`.

The horizontal `space4` is load-bearing and must be commented as such: the band is a SIBLING
of `GWSectionTitle`, not a child, so it does not inherit the title's own `space4` inset, and
without it the total hangs 8px left of the word Assets.

Write at the call site why the `height: 28/24` override is gone rather than just deleting
it: it existed solely to make a two-line block consume `GWSectionTitle`'s 44px reservation
exactly. Outside that reservation `numericHeadline`'s shipped 32/24 is correct and the
override would only tighten the band's line box for no reason.

**Add no spacer between the band and the first `CoinCardRow`.** The row's own ~20px ListTile
snap is the gap, and it is byte-for-byte the total-to-first-row relationship that ships
today. State that, so nobody adds the sketch's 14px later.

Note at the call site that the value-empty footer's `if (isDashboard && total == 0)` branch
lower down is untouched, and that `state.coins.isEmpty` still returns a `GWEmptyState` above
this header so the band never renders against no data.

Record the decision itself in the same comment: this is a revert of sketch 178 scheme C to
scheme A, Jakub on device 2026-08-07, verbatim quote included, because the 18px white
`titleLg` treatment shared with Markets, Transactions and Compute was the thing he wanted
back. Include the measured +48px cost and the R2 change 20 -> 26 so the next reader does not
have to re-derive them.

Also record there, since the pinned test cannot be edited: `gw_section_title_rhythm_test.dart`'s
doc table lists Assets at `C=20 / R2=30` and its `ROW INSET - CoinCardRow (Assets)` case
labels its output as the Assets gap. Both describe the pre-scheme-A panel and are now stale.
The test's assertions remain correct and green - `CoinCardRow` really does bring more inset
than the pad can absorb - so this is a documentation debt, named here, to be paid in a
docs-only pass.

In `gw_section_title.dart`, **remove the `titleBlock` parameter**, its `Flexible` branch and
its ~40 lines of doc, restoring the unconditional `Text(title, ...)` left side. It had
exactly one consumer in `lib/`, that consumer is what this task deletes, and it was added
this session for one scheme its decider has now rejected - so "it might be wanted again" has
already been answered by the person who decides. Leaving it standing would advertise a
composite title as a supported pattern in the one component whose whole job is to give eight
sections one shape, with a `Flexible`-versus-unwrapped-`Text` fork that no call site
exercises. Replace the removed doc section with two sentences recording that the parameter
existed on 2026-08-07 for sketch 178 scheme C and was removed with that scheme, so the git
history is findable and nobody re-adds it speculatively.

Do NOT touch: `kGWSectionTitleHeaderHeight`, `kGWSectionTitleLineHeight`,
`kGWSectionTitleSlack`, `kGWSectionTitleEdgePad`, `kGWSectionTitleRenderedGap`, the derived
`bottomPad` arithmetic, or the class doc sections describing the rendered-gap rule. Do prune
the class doc's scheme-C-specific paragraph about the 44px reservation being spent exactly
by Assets, which stops being true.

Delete `test/components/assets_header_scheme_c_test.dart` and create
`test/components/assets_header_scheme_a_test.dart`. Deletion rather than rewrite is the
honest call: the file's name, its library doc, its `kAssetsHeaderBoxHeight` constant, its
`AssetsTitleBlock` fixture and every one of its assertions are about a composition that will
no longer exist, and a file called `scheme_c` testing scheme A is a lie in the filename. Two
things carry forward verbatim and must:

- the `_loadInter()` `FontLoader` helper and the reason it exists (the harness typeface draws
  digits ~1.7x wider than real Inter, which fabricates overflows that never happen on
  device), plus the 390x844 at devicePixelRatio 3 view setup;
- the split between wide height probes and a real-metrics width probe, and the reason.

New assertions:

1. HEIGHT - pin the whole header cost. Mount `GWSectionTitle` plus the band inside a
   `DashboardScrollContainer` at a wide probe width and assert the combined height is
   **94** = `edgePad(2) + reservation(44) + bottomPad(16) + band(32)`. Express it from the
   exported constants, never a typed 94. Give it a reason string saying that a value above
   94 means the +48 budget slipped and is a STOP rather than a number to adjust.
2. HEIGHT - assert the title box alone is `edgePad + reservation + (renderedGap - slack)`,
   which is what proves `contentTopInset` really is 0 and the band really does pay nothing.
3. RHYTHM - assert the rendered gap from the title's line box down to the band's first
   painted pixel is `kGWSectionTitleRenderedGap` (26). This is the assertion that would catch
   `contentTopInset: 20` being left behind.
4. WIDTH - with real Inter loaded at the 390pt-equivalent content width, in BOTH the funded
   and all-zero states: no exception, and the band keeps positive slack. Log the measured
   slack via `debugPrint` so the follow-up decision about restoring the dollar day-change has
   a real number the next time it is opened.

The band must be exercised in both `total > 0` and `total == 0`, because the percentage is
guarded and a band that only fits in one state is not stable.
  </action>
  <verify>
    <automated>flutter test test/components/assets_header_scheme_a_test.dart</automated>
    <automated>flutter test test/components/gw_section_title_rhythm_test.dart test/dashboard/dashboard_section_caps_test.dart test/dashboard/compute_panel_height_test.dart</automated>
    <automated>md5 -q test/components/gw_section_title_rhythm_test.dart | grep -qx 0c3007e426116ddf9cb3f49339b787e3</automated>
    <automated>test ! -f test/components/assets_header_scheme_c_test.dart</automated>
    <automated>grep -vE '^\s*(//|///)' lib/components/cards/gw_section_title.dart | grep -c 'titleBlock' | grep -qx 0</automated>
    <automated>grep -vE '^\s*(//|///)' lib/components/coins/view/coins_screen.dart | grep -c 'GWKicker' | grep -qx 0</automated>
    <automated>LC_ALL=C grep -c $'\xe2\x80\x94' lib/components/coins/view/coins_screen.dart lib/components/cards/gw_section_title.dart test/components/assets_header_scheme_a_test.dart | grep -vq ':[1-9]'</automated>
  </verify>
  <done>
The Assets title renders `Assets` in 18px white `titleLg` with `GWViewAllLink` at the far
right, identical in treatment to Markets and Transactions. The total sits in its own band
directly beneath, at 24px, with the 24h percentage inline. Measured header cost is 94 against
today's 46, a +48 delta pinned by test. The rendered title gap is 26. `GWSectionTitle` has no
`titleBlock`. `gw_section_title_rhythm_test.dart` is byte-identical and green.
  </done>
</task>

<task type="auto">
  <name>Task 3: the phone brand lockup gets bigger, and nothing else in the header moves</name>
  <files>lib/components/overlay/mobile_header.dart, test/components/mobile_header_brand_and_pill_test.dart</files>
  <action>
In `BrandLockup`, change the mark's `Image.asset(... height: 24 ...)` to **28** and the
wordmark's `fontSize: 15` to **18**. Change the wordmark's `ConstrainedBox(maxWidth: 180)` to
**216**.

Three things must not change, and one of them is the whole point of the task's narrowness:
`titleSpacing: GeniusWalletConsts.space8` on the `AppBar` stays, `actions: const [SizedBox(width: GeniusWalletConsts.space8)]`
stays, and the `SizedBox(width: GeniusWalletConsts.space4)` between mark and wordmark stays.
Jakub judged the alignment correct on device on 2026-08-07 - leave the logo where it is, the
alignment is right, just make it bigger - after an earlier message had asked for the opposite.
Write that at the call site, with the date, so the next reader does not helpfully re-align
it.

Rewrite the two comments that currently justify the old numbers, because both become false:

The `height:` comment claims 24 is the largest step under a 2x upscale and that it keeps the
pill's 32px avatar the largest circular object in the bar. Replace with the measured table:
28 renders 84 physical pixels at 3x from a 38px source, a **2.21x** upscale against today's
1.89x; 32 would be 2.53x, which is where the bilinear smear on an intricate line drawing
stops reading as antialiasing and starts reading as blur, so 28 is the largest size worth
drawing from this asset. Record the avatar-dominance argument as SUPERSEDED rather than
deleting it - it was a real argument for keeping the mark small and Jakub has overruled it,
and at 28 the 32px avatar is still the larger circle, so the ordering it protected happens to
survive. Name the upgrade explicitly: `lib/assets/images/geniusappbarlogo.png` re-exported at
**114x114**, 3x of 38, a pure drop-in because the render height is fixed in code and the crop
is a `widthFactor`; at 114 the mark is lossless up to `height: 38`.

The `maxWidth: 180` comment calls itself a Dynamic Type fuse and quotes `GNUS.AI` at 63.91
logical pixels against Inter Bold 15. Update it: **76.69px at Inter Bold 18**, measured by
walking the bundled `Inter-Bold.ttf` `hmtx` advances, and state that 216 is 180 scaled by the
same 1.20 specifically to hold the shipped 2.82x scale headroom constant rather than let it
silently drop to 2.35x.

Add one short comment recording the width budget at 390pt so it is not re-derived: the lockup
measures 106.06 (mark box `29/38 * 28` = 21.37, plus `space4`, plus 76.69), which leaves the
`Expanded` pill 239.94 against its 236 cap - **3.94px of positive slack, so the cap still
binds**. Note the mechanism that makes this safe rather than tight: the lockup is non-flex and
laid out first, the pill is the `Expanded` that absorbs shrink and ellipsizes its name, so
`GNUS.AI` can never be the thing that truncates.

In `mobile_header_brand_and_pill_test.dart`, **add** to the existing tests, do not touch
them. The brand-does-not-shrink test in particular is the file's most valuable assertion and
its equality still holds. New cases:

1. Assert the mark's rendered `height` is 28 by reading the `Image` widget the existing
   `_markFinder` already locates. This is the assertion that makes a future accidental revert
   to 24, or a creep to 32, fail loudly.
2. Assert the mark's rendered height and the wordmark's font size move together, by reading
   the `Text` style off `find.text('GNUS.AI')` and asserting `fontSize` is 18. A mark that
   outgrows its text is the failure mode the proportional bump exists to prevent.
3. Assert the pill still clears 44 and still sits at or under `kWalletPillMaxWidth` after the
   growth. The existing test already asserts both; add a `debugPrint` of the measured
   `BrandLockup` width and the measured `WalletPill` width at the 390pt fixture so the slack
   figure is observable in CI output rather than only in this plan.

Do not assert any absolute TEXT width - the harness font is not Inter and the existing file's
header comment explains why that rule exists.
  </action>
  <verify>
    <automated>flutter test test/components/mobile_header_brand_and_pill_test.dart</automated>
    <automated>grep -c 'titleSpacing: GeniusWalletConsts.space8' lib/components/overlay/mobile_header.dart | grep -qx 1</automated>
    <automated>grep -c 'actions: const \[SizedBox(width: GeniusWalletConsts.space8)\]' lib/components/overlay/mobile_header.dart | grep -qx 1</automated>
    <automated>grep -c 'StadiumBorder' lib/components/overlay/mobile_header.dart | grep -qx 1</automated>
    <automated>grep -c 'gw.borderControl' lib/components/overlay/mobile_header.dart | grep -qx 1</automated>
    <automated>LC_ALL=C grep -c $'\xe2\x80\x94' lib/components/overlay/mobile_header.dart test/components/mobile_header_brand_and_pill_test.dart | grep -vq ':[1-9]'</automated>
  </verify>
  <done>
The mark renders at 28 and the wordmark at 18, both pinned by test. `titleSpacing`, `actions`
and the mark-to-wordmark gap are unchanged. The pill's `StadiumBorder` and its `borderControl`
edge are untouched. The comments state the measured 2.21x upscale, the 114x114 upgrade path,
and the 3.94px of positive pill slack.
  </done>
</task>

<task type="auto">
  <name>Task 4: gates, fence and no-commit check</name>
  <files>(no files modified)</files>
  <action>
Run the full gates and confirm the fence held. Nothing here changes code; if any gate fails,
fix the cause in the owning task rather than relaxing the gate.

`flutter analyze` must report **No issues found**. The repo was at 0 repo-wide before this
task and must end there.

`flutter test` must report **0 failing** and **at least 1142 passing**. The baseline measured
at the start of this task was exactly 1142 passing / 0 failing. The count is expected to move
UP: task 1 keeps five tests (some rewritten) and task 3 adds three; task 2 deletes a
three-test file and adds a four-or-more-test file. A count that goes DOWN by more than the one
net test that scheme C's `plain-String path is untouched by titleBlock` case represents is a
STOP - it means something was dropped rather than carried.

Confirm no assertion anywhere was relaxed: no `expect` changed from an equality to a range, no
`closeTo` epsilon widened, no test marked `skip`.

Confirm the file fence held. `lib/dashboard/home/widgets/transaction_displays.dart` and
`lib/dashboard/home/widgets/transaction_utils.dart` belong to a separately-planned task and
must be byte-identical to their state at the start of this one.

Confirm `test/components/gw_section_title_rhythm_test.dart` is byte-identical.

Confirm no commit was created: `git log` must show `f1ed0af4` as HEAD, exactly as it did at
the start. The working tree is left dirty on purpose - Jakub reviews before anything is
committed.
  </action>
  <verify>
    <automated>flutter analyze 2>&amp;1 | tail -1 | grep -q 'No issues found'</automated>
    <automated>flutter test 2>&amp;1 | tail -1 | tee /dev/stderr | grep -q 'All tests passed'</automated>
    <automated>md5 -q lib/dashboard/home/widgets/transaction_displays.dart | grep -qx 0c6d4dcd1a00b9b31df91d9fc46ccdc7</automated>
    <automated>md5 -q lib/dashboard/home/widgets/transaction_utils.dart | grep -qx 5b3d29151cc22ee87ff2288e2d1e7063</automated>
    <automated>md5 -q test/components/gw_section_title_rhythm_test.dart | grep -qx 0c3007e426116ddf9cb3f49339b787e3</automated>
    <automated>git rev-parse --short HEAD | grep -qx f1ed0af4</automated>
  </verify>
  <done>
`flutter analyze` at 0 issues. `flutter test` at 0 failing and 1142 or more passing. Both
fenced transaction files and the rhythm test are byte-identical. HEAD is unmoved and the tree
is dirty.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <name>Task 5: on-device review on the iPhone, dark mode</name>
  <files>(no files modified)</files>
  <action>
Stop. Do not proceed, do not commit, do not start any follow-up. Present the
`<what-built>` and `<how-to-verify>` below to Jakub verbatim and wait for his word.
  </action>
  <what-built>
Three reverts and one growth, all on the phone:

1. **Assets title** back to 18px white `titleLg` with `View all` at the far right, matching
   Markets, Transactions and Compute. The portfolio total moved to its own band directly
   under the title at 24px with the 24h percentage beside it. Panel is **48px taller**.
2. **View all** back to flat grey at all three sections.
3. **Brand lockup** grown: mark 24 -> 28, `GNUS.AI` 15 -> 18. Nothing else in the header
   moved.

Not built, deliberately, and needing his word: the `WalletPill`'s corner radius, its
position, and the dollar figure on the 24h change.
  </what-built>
  <how-to-verify>
Run the app on the iPhone in dark mode. `flutter run -d <device> --dart-define=GW_DEV_TOOLS=true`
if the mock-tx tool is wanted; the define is required on every run.

**1. The four titles, in ONE scroll.** From the top of the dashboard, scroll once through
Compute, Assets, Transactions and Markets without stopping. All four section names must read
as the same thing: same size, same white, same weight, same position in their card. This is
the whole point of Change 1 - if Assets still stands out, say how.

**2. The total, in its new place.** Directly under the word Assets there is now a band with
your portfolio total and the 24h percentage. Check: is the total still obviously the number
the section is about, now that the word Assets is white and 18px above it? And is the gap
above the band comfortable against the gap below it?

**3. The gap you approved this morning has changed, and you should know the whole story.**
You approved a 30px gap under the Assets title this morning. That 30 stopped existing when
scheme C shipped a few hours later - the two-line block ate the slack and the real gap became
20, silently. It is now **26**, which is the number Compute, Transactions, Markets and every
other panel already renders. So it moved back toward what you approved rather than away, but
it is not 30 and you did not ask for that.

**4. The panel is 48px taller.** Measured, not estimated. On the phone the page just scrolls,
nothing is cut. On DESKTOP the Assets panel sits in a fixed slot, so about one row's worth of
list scrolls out of first view there. You review on iPhone so this is a heads-up, not a
question - but if you open a desktop build and it bothers you, say so.

**5. View all is grey again.** All three sections. Check it still reads as tappable at
5.97:1 on the card. If it now looks too quiet on the phone, say so - the answer next time
would be weight or size, not colour, because colour is now decided.

**6. The logo's sharpness at the new size.** This is the one thing only you can judge. The
mark is drawn from a **38x38** source with no @2x or @3x file anywhere in the repo, so at
`height: 28` on your 3x screen it is a **2.21x** upscale - up from 1.89x today. Hold the
phone at normal reading distance and look at the thin strokes inside the mark. If they look
soft or smeared, that is the upscale and **not something a code change fixes**. What fixes it
is a **114x114** export of `geniusappbarlogo.png` (same name, same folder). With that file
dropped in, 28 becomes lossless and 32 and 36 become available too. Without it, 28 is as far
as I would go; 32 is where I expect the blur to be visible.

**7. Is the lockup big enough?** 24 -> 28 on the mark and 15 -> 18 on the text is +17% and
+20%. If it is still not decidedly bigger, the answer is the 114x114 export followed by
32 or 36, not a bigger draw from the file we have.

**8. Both ends of the header, since nothing moved.** The logo still sits at the `AppBar`
default 16 from the left and the wallet pill still sits at 16 from the right, exactly where
you judged them correct. Confirm the bigger lockup did not change how that reads - it is the
one thing a size change could have spoiled.

**9. The wallet pill's corners - your question, answered, nothing built.** You asked whether
it is an existing component or a new one. **It is new**, hand-rolled today as a
`StadiumBorder`, which is fully round by definition. But the SHAPE is not new: the network
chips inside the drawer that pill opens use the identical `Material` + `StadiumBorder` +
`borderControl` recipe, and they are the widget the pill replaced in that slot. Open the
drawer, look at the pill and the network chips together, and tell me whether they agree. My
recommendation is to keep the stadium and express it through the `radiusPill` token, which
paints identically. If you want squarer, `radius2xl` (16) is the named one-line step.
  </how-to-verify>
  <resume-signal>
Type "approved" to accept all three changes, or describe what is wrong.

Four things are waiting on your word and are deliberately not built:
  - the 114x114 logo export, and whether to go past 28 once it exists;
  - the `WalletPill` radius (recommendation: keep the stadium, take it from `radiusPill`);
  - the `WalletPill`'s position, which you deferred until after the changes land;
  - the dollar figure on the 24h change, which scheme C dropped for want of width and the new
    band has room for again (measured: it fits with 15.73px to spare at the worst realistic
    total).
  </resume-signal>
</task>

</tasks>

<verification>

Run in order. Every one must pass before the checkpoint.

1. `flutter analyze` reports **No issues found**.
2. `flutter test` reports **0 failing**, **1142 or more passing**.
3. `test/components/gw_section_title_rhythm_test.dart` md5 is `0c3007e426116ddf9cb3f49339b787e3`.
4. `lib/dashboard/home/widgets/transaction_displays.dart` md5 is `0c6d4dcd1a00b9b31df91d9fc46ccdc7`.
5. `lib/dashboard/home/widgets/transaction_utils.dart` md5 is `5b3d29151cc22ee87ff2288e2d1e7063`.
6. `git rev-parse --short HEAD` is `f1ed0af4` - **no commit was created**.
7. No em dash in any file this task touched.
8. `grep -vE '^\s*(//|///)' lib/components/cards/gw_section_title.dart | grep -c titleBlock` is 0.
9. `lib/components/overlay/mobile_header.dart` still contains exactly one `titleSpacing: GeniusWalletConsts.space8`, one `actions: const [SizedBox(width: GeniusWalletConsts.space8)]`, one `StadiumBorder` and one `gw.borderControl`.

</verification>

<success_criteria>

- Assets, Markets, Transactions and Compute all render their section names through
  `GWSectionTitle`'s plain `String` path: 18px `titleLg`, `textPrimary`, `space4` inset.
- The portfolio total is still on the dashboard, in a band of its own, and the title row is
  back to two elements.
- The measured Assets header cost is 94 (was 46), a +48 delta, pinned by an automated
  assertion built from exported constants rather than a typed literal.
- The rendered title-to-content gap on Assets is 26, the shared value.
- `GWViewAllLink` paints flat `textSecondary` at rest and flat `textPrimary` on hover, at all
  three sites, with the 3px arrow slide intact.
- No claim in `gw_view_all_link.dart` describes behaviour the widget does not have, in either
  direction - not the four that predate today, and not the gradient prose that replaced them.
- The `GWAppearance.instance.value` light-mode harness fix survives in a running test.
- The phone brand mark renders at 28 and the wordmark at 18, with the upscale factor, the
  114x114 upgrade path and the 3.94px pill slack all written at the call site.
- `titleSpacing`, `actions`, the pill's shape and the pill's `borderControl` edge are
  byte-identical to their pre-task state.
- Gates 1 through 9 in `<verification>` all pass.
- Nothing is committed.

</success_criteria>

<followups>

Named here so they are one step to pick up, not rediscoveries.

| # | Item | Recommendation |
| --- | --- | --- |
| 1 | `geniusappbarlogo.png` at **114x114** (3x of 38), same path, same name | Ask Jakub. It is a pure drop-in - the render height is fixed in code and the crop is a `widthFactor`, so no layout number changes. Unlocks `height` up to 38 losslessly. |
| 2 | `WalletPill` shape | Keep the stadium; express it as `RoundedRectangleBorder(BorderRadius.circular(GeniusWalletConsts.radiusPill))`, which clamps to 22 at h=44 and paints identically. Squarer step if wanted: `radius2xl` (16). Keep `borderControl` either way. |
| 3 | `WalletPill` position | Deferred by Jakub until after the changes land. He asked twice for it to move right before freezing the logo's position, so expect it back. |
| 4 | The dollar figure on the Assets 24h change | Fits the new band with **15.73px** to spare at `$1,234,567.89` with `+$1,234.56 - +12.34%`. Restores what shipped before 2026-08-07. Held back only so it does not confound this review. |
| 5 | `gw_section_title_rhythm_test.dart` doc table | Its Assets row (`C=20 / R2=30`) and the `ROW INSET - CoinCardRow (Assets)` label describe the pre-scheme-A panel. Assertions stay correct; the prose is stale. Docs-only pass. |
| 6 | The bottom-bar active tab gradient | **Leave it.** With the links flat it is the only gradient text on the dashboard, so its meaning sharpened rather than blurred, it is on a different surface, and Jakub approved it on 2026-08-06. Listed so it is a decision on the record, not an oversight. |

</followups>

<output>
Create `.planning/quick/20260807-header-alignment-and-assets-title/SUMMARY.md` when done.
</output>
