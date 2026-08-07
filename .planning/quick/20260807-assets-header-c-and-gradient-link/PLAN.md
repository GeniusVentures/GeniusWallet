---
phase: quick-260807-hdr
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/cards/gw_view_all_link.dart
  - lib/components/cards/gw_section_title.dart
  - lib/components/coins/view/coins_screen.dart
  - test/components/gw_view_all_link_gradient_test.dart
  - test/components/assets_header_scheme_c_test.dart
autonomous: false
requirements: [QUICK-260807-HDR]

must_haves:
  truths:
    - "The Assets panel header reads as ONE headline - a quiet uppercase ASSETS kicker over the portfolio total at 24px, with the 24h move inline beside it - and the View all link stands alone at the far right. Two elements in the row, not three."
    - "The Assets panel is EXACTLY as tall after this change as before it. Not approximately. The header's 44px reservation is consumed exactly, never exceeded."
    - "The rendered title-to-first-row gap on Assets is still 30, because contentTopInset stays 20 and the first widget under the header is still a CoinCardRow. Nothing about the vertical rhythm moves."
    - "GWSectionTitle is EXTENDED, not forked. All eight existing call sites pass a plain String and compile and render byte-identically with no edit."
    - "GWViewAllLink paints the brand CTA gradient AT REST, so it is legible as an affordance on iOS where no hover exists. All three render sites get it."
    - "The link still has a visible hover state on desktop - rest and hover do not look the same."
    - "The four false claims in gw_view_all_link.dart's comments are corrected, not left. The file stops contradicting itself."
    - "The accepted cost of scheme C - Assets no longer matching Markets and Transactions - is written into the source as a doc comment naming scheme A as the fallback, so it is a recorded decision rather than something rediscovered in three weeks."
    - "flutter analyze ends at 0 issues and flutter test ends at 1081 passing, with no assertion relaxed and no existing test edited."
  artifacts:
    - test/components/gw_view_all_link_gradient_test.dart
    - test/components/assets_header_scheme_c_test.dart
  key_links:
    - "The total's line height override (28/24) is LOAD-BEARING, not cosmetic. numericHeadline ships 32/24; kicker 16 + total 32 = 48, which BREAKS the 44px reservation and grows the capped panel by 4px. The override is what makes the height cost zero."
    - "GWSectionTitle keeps `title` REQUIRED even when titleBlock is supplied. That is what makes the change additive: no call site loses an argument, and the section keeps a canonical name in source."
    - "test/components/gw_section_title_rhythm_test.dart must stay green WITHOUT being edited. Its CONTRACT loop mounts GWSectionTitle with a plain String at four insets; if an additive titleBlock is done correctly that loop cannot notice this change. If it goes red, the change was not additive."
    - "brandCtaText(gw.surfaceElevated) - the appearance PROXY, not a literal backdrop match. Raw brandCta as text measures 1.65:1 and 2.28:1 on the light menu surface, so the raw gradient must not be used here."
    - "All three GWViewAllLink render sites sit on DashboardScrollContainer, whose GWDecorations.surface resolves to surfaceElevated (#0C0E14 dark). One surface, one proxy, one contrast answer for the whole census."
---

<objective>
Two changes Jakub decided on 2026-08-07 after reviewing sketch 178, in English:

> On 178, let's go with 178 C - it looks like a good solution; and on top of that, for
> View All, do the gradient the way you are suggesting.

**Change 1** is scheme C from the sketch: the Assets section header stops being a row of
three competing elements and becomes a row of two. The word "Assets" demotes to a small
uppercase kicker, the portfolio total becomes the section headline at 24px, and View all
stands alone at the far right.

**Change 2** makes `GWViewAllLink` paint the brand CTA gradient at rest instead of flat
`textSecondary`. This is a GLOBAL change across three render sites, and it is the change
that matters most on the actual target device: iOS has no hover, so today that link is
permanently the dimmest thing in every row it lives in.

Neither change is fixing a bug. The Assets row is not overflowing - measured at 390pt it
fits with about 25px to spare - so change 1 is a hierarchy decision, and a plan that only
rearranges pixels without deciding which element is dominant has not delivered it.

Purpose: Jakub, on his iPhone, 2026-08-07, on the current state: he does not like the
assets section, because it carries both view all and the amount on the right-hand side,
and he wants it solved properly, because as it stands it does not look good.

Output: one additive component parameter, one restyled call site, one global link
treatment, four corrected comments, two new guard tests, one recorded design cost, one
brand-rule recommendation put to Jakub, and a blocking on-device side-by-side check.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/sketches/178-assets-header-total-vs-view-all/README.md
@lib/components/cards/gw_section_title.dart
@lib/components/cards/gw_view_all_link.dart
@lib/components/cards/gw_kicker.dart
@lib/theme/genius_wallet_gradient.dart
@test/components/gw_section_title_rhythm_test.dart

Read `lib/components/coins/view/coins_screen.dart:304-403` before editing - that is the
Assets header call site, and the comment block above `trailing:` carries the measured
width budget this plan re-derives at the new type sizes.
</context>

<measured_baseline>
Both gates measured on this branch (`redesign/navigation-260806`) at plan time, 2026-08-07,
not quoted from memory:

| Gate | Baseline | Command |
| --- | --- | --- |
| `flutter analyze` | **No issues found** (0) | `flutter analyze` |
| `flutter test` | **+1081, All tests passed** (exit 0) | `flutter test` |

1081 is the number to return to. It is not a floor to be met by deleting a test - the two
new test files below ADD cases, so the finishing number is 1081 plus whatever they
contribute, with zero failures and zero pre-existing tests edited.

## Pre-existing em dashes, counted at plan time

The no-em-dash gate is not a formality here. Two of the three files being edited already
carry them, all in comments, all predating this task:

| File | Em dashes today | Where |
| --- | --- | --- |
| `lib/components/cards/gw_view_all_link.dart` | **3** | lines 12, 14, 41 - class doc and the `labelStyle` comment |
| `lib/components/coins/view/coins_screen.dart` | **4** | comments in and around the Assets header block |
| `lib/components/cards/gw_section_title.dart` | 0 | already clean |

Task 1 rewrites the `gw_view_all_link.dart` comments wholesale, so its three disappear as a
side effect - but only if the rewrite does not reintroduce them. In `coins_screen.dart` the
four are in comments this task is rewriting or sitting directly beside; clean all four while
in there. Both files must read 0 when the gate runs, so this is scoped work, not a surprise.
</measured_baseline>

<the_census>
## `GWViewAllLink` - every render site (change 2 is global)

Grepped, not assumed. **Three live render sites**, and every one is a dashboard panel:

| # | Site | Line | Surface | Notes |
| --- | --- | --- | --- | --- |
| 1 | `lib/components/coins/view/coins_screen.dart` | 400 | `DashboardScrollContainer` | Assets panel, dashboard only (`isDashboard`) |
| 2 | `lib/dashboard/chart/dashboard_markets.dart` | 106 | `DashboardScrollContainer` | Markets panel |
| 3 | `lib/dashboard/home/widgets/transactions_slim_view.dart` | 362 | `DashboardScrollContainer` | Transactions panel, dashboard only (`!widget.page`) |

Two further mentions are NOT render sites and need no work:
- `lib/screens/banxa_buy_screen.dart:1285` - a comment referencing the widget. Out of
  scope by constraint anyway (nothing under `/banxa`).
- `lib/components/effects/gw_hoverable.dart:18,59` - comments crediting where the no-op
  hover guard came from. Still accurate, leave them.

**The census pays off immediately:** all three sites paint on the same surface, so there is
ONE contrast question, not three, and one appearance proxy serves the whole change.

## `GWSectionTitle` - every call site (change 1 must not break any of them)

| # | Site | Line | Passes |
| --- | --- | --- | --- |
| 1 | `coins_screen.dart` | 321 | `title: 'Assets'` + trailing - **the only site this plan changes** |
| 2 | `transactions_slim_view.dart` | 326 | `title: 'Transactions'` + trailing |
| 3 | `dashboard_markets.dart` | 104 | plain String + trailing |
| 4 | `markets_screen.dart` | 220 | plain String, `const` |
| 5 | `compute_panel.dart` | 141 | `title: 'Compute'`, `const` |
| 6 | `crypto_news_screen.dart` | 363 | `title: 'Results'`, `const` |
| 7 | `crypto_news_screen.dart` | 382 | `title: 'More news'`, `const` |
| 8 | `crypto_news_screen.dart` | 513 | plain String, `const` |

Four of the eight are `const`. That is the sharpest reason the new parameter must be
optional with no default that breaks constness, and why `title` must stay `required`.
</the_census>

<the_arithmetic>
## Change 1: why the height cost is zero, and the one line that decides it

`kGWSectionTitleHeaderHeight` is 44. The left block becomes a Column of two line boxes and
must fit inside it.

```
kicker  GWKicker.style(dense: true)   fontSize 11, height 16/11  ->  16.0
total   numericHeadline.copyWith(...) fontSize 24, height 28/24  ->  28.0
                                                              sum =  44.0
```

**Exactly 44.** The reservation is consumed, never exceeded, so `ConstrainedBox(minHeight:
44)` still governs and the header does not grow by a pixel.

**Now the trap.** `GeniusWalletTypography.numericHeadline` ships as 24 with `height: 32/24`.
Used raw:

```
16 + 32 = 48   ->  the header grows 4px, on the panel phase 25 just capped
```

So `copyWith(height: 28 / 24)` is **load-bearing**, not a styling flourish. A future edit
that "cleans up" the override silently grows a capped panel. Say so in the code comment.

The sketch drew the kicker at a 14px line box and the total at 28, summing to 42. Using
`GWKicker`'s existing dense step gives 16 instead of 14 and sums to 44. Both clear the
reservation; the token is preferred over inventing a 14px line height, and 44 is the
tighter, more honest number to assert against.

### The 24h move adds no height

It sits inline beside the total in a baseline-aligned Row. `labelMd` is 13/18, an 18px line
box, shorter than the total's 28. Baseline alignment makes the Row
`max(ascentToBaseline) + max(descentBelowBaseline)`, and with Inter metrics both maxima come
from the 24px total, so the Row is 28 - the total's own line box. Adding the chip changes
nothing.

The all-zero state is guarded exactly as today (`if (total > 0)`), so with no chip the block
is still 16 + 28 = 44. **Two-line-stable in both states**, which is the property the current
call site's comment already claims and must keep.

### The assertion that is immune to the test harness font

The harness draws a fallback font, not Inter, so absolute glyph measurements drift in tests.
The height property does not, because it is decided by declared line heights and a
`ConstrainedBox`. For the Assets configuration:

```
contentTopInset  = 20
bottomPad        = max(0, 26 - 10 - 20) = 0
GWSectionTitle box height = edgePad(2) + max(44, leftBlock) + bottomPad(0) = 46
```

**Assert 46.** If the left block ever exceeds 44 the box exceeds 46 and the test goes red on
the exact failure mode this plan is worried about. That is the gate.

### The width budget, re-derived at the new sizes

The existing call-site comment measures the 390pt content box at **336** (390, minus 2x
`space3` list padding, minus 2x (`space6` + 1px border) card inset, minus 2x `space4` title
inset). `GWViewAllLink` takes about 86. Reserving a 12px minimum breathing gap leaves about
**238** for the left block.

The README measured the worst realistic total, `$1,234,567.89`, at about 143 at 20px. At
24px that is `143 x 24/20 = ~172`.

| Arrangement | Left block | Budget | Verdict |
| --- | --- | --- | --- |
| total 24px + `space4` + percent only (`+12.34%`, ~50) | ~230 | 238 | fits, ~8 spare |
| total 24px + `space4` + today's full pair (`+$1,234.56 · +12.34%`, ~126) | ~306 | 238 | **overflows by ~68** |

**This is why the 24h move goes to percent-only, and it is a geometry result, not a taste
call.** The sketch drew percent-only and the arithmetic says the full pair cannot go inline
at 24px. It is still a real information loss against what ships today, so it is named
explicitly in the checkpoint below rather than slipped in.

Ceiling, to be written into the comment: above roughly ten million the total alone
approaches the budget. The upgrade path if that ever becomes real is the one the existing
comment already names - drop the change to its own line, **not** a `FittedBox` (the 37639d5
pattern).

## Change 2: contrast, verified rather than re-derived

All three render sites paint on `DashboardScrollContainer`. Its `GWDecorations.surface`
resolves to `surfaceElevated`, which `genius_wallet_colors.dart:127` defines as `#0C0E14` -
the exact card colour the README measured against.

| State | Paint | On `#0C0E14` | Needs | |
| --- | --- | --- | --- | --- |
| rest, stop 1 | `#0AD89C` | **10.4:1** | 4.5:1 | pass |
| rest, stop 2 | `#0AAEE6` | **7.6:1** | 4.5:1 | pass |
| hover | `textPrimary` white | 19.6:1 | 4.5:1 | pass |
| light mode, collapsed | `brandPrimaryOnSurface` `#0A6885` | 6.30:1 | 4.5:1 | pass |

The link is text, so 4.5:1 is the bar and every state clears it in both appearances.

**One thing that will look like a contradiction and is not.** `genius_wallet_gradient.dart:38`
says the same two stops measure 9.4:1 and 6.8:1. That is against the **menu** surface, a
different and slightly lighter colour. Both sets of numbers are correct for their own
surface. Do not "fix" either one.
</the_arithmetic>

<open_decision>
## The one tension, surfaced with a recommendation

The project's standing rule is: **fill = commitment, outline = everything else, max one
gradient per surface.** After this change the dashboard carries three gradient View all
links, a gradient SWAP dock, a gradient active tab, plus the gradientOutline CTAs in Assets.
That is more gradient than the rule as written allows.

**Recommendation, and this is the favourite: ship the change and restate the rule as
governing gradient FILL.** The dashboard has exactly one gradient FILL - the SWAP dock - and
it stays unique, which is the property the rule was actually protecting. Gradient TEXT is a
different register: it adds no area, no border, no elevation, and it is already this app's
established "this is a navigational affordance" mark, used by `responsive_overlay`'s active
tab, `reown_connect_button` and `transactions_slim_view`'s active label. Making the three
View all links join that language leaves the dashboard MORE coherent, not less, because
today those links are the only navigational affordances in the app still painting flat
secondary. Record the restatement in `gw_view_all_link.dart`'s class doc.

**Runner-up, if Jakub reads it as noisy on glass: step down the bottom-bar active tab.** It
is the only gradient text on the dashboard that is not a link to somewhere else - it marks
where you already are - and the tab already carries other active affordances, so it is the
cheapest thing to make quieter. Named here so the answer exists before the question.

**Rejected: stepping down the View all links.** That is the change Jakub just asked for, and
undoing it to satisfy a rule about fills would be the rule wagging the design.

**This is a recommendation, not a resolution.** It goes into the checkpoint. Do not edit the
project rule anywhere outside `gw_view_all_link.dart`'s own doc comment in this task.
</open_decision>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: GWViewAllLink paints the brand gradient at rest, and its comments stop lying</name>
  <files>lib/components/cards/gw_view_all_link.dart, test/components/gw_view_all_link_gradient_test.dart</files>
  <behavior>
    - At rest, the link's shader is the brand CTA gradient: two DISTINCT stops, `0xFF0AD89C` then `0xFF0AAEE6`.
    - On hover, the shader collapses to two IDENTICAL stops, both `gw.textPrimary`, so rest and hover are visibly different states.
    - In light appearance the rest shader collapses to a single repeated light-safe stop rather than staying the raw brand gradient.
    - The widget still renders one `ShaderMask` with `BlendMode.srcIn` over opaque-white children - the paint path count does not change.
    - The arrow still translates 3px on hover.
  </behavior>
  <action>
    Change the colour decision so REST is the brand CTA gradient and HOVER is flat white.

    Lift the decision out of the inline `shaderCallback` into a public static on the widget,
    named for what it returns and taking `GWColors` plus a `hovered` flag. Use
    `GWKicker.style(gw, dense:)` as the precedent for the shape - a public static that
    exposes a styling decision so it is reusable and, critically here, assertable in a test
    without pixel-reading an opaque `Shader`. Do NOT reach for `@visibleForTesting`; the
    repo uses it in zero places today and this task is not where that starts.

    Rest returns `GeniusWalletGradient.brandCtaText(gw.surfaceElevated)`. Two things about
    that argument, both of which belong in the comment: it is `brandCtaText` and not raw
    `brandCta` because the raw gradient is unreadable on the light menu surface, per that
    method's own doc; and `surfaceElevated` is passed as a LUMINANCE proxy for the
    appearance, which happens also to be the literal surface all three census sites paint
    on. `responsive_overlay.dart:414` is the precedent for passing a surface token here.

    Hover returns a `LinearGradient` of `gw.textPrimary` repeated - the single flat stop the
    file already uses for this state. Keep the existing 3px arrow slide untouched; between
    the colour change and the slide the desktop affordance stays legible in both directions.

    Have `shaderCallback` call the new static and nothing else, so exactly one place decides
    colour.

    Then correct the comments. Four separate claims in this file are false against the code,
    and three of them will still be false after this change unless rewritten:

    1. The class doc says hover paints the gradient. After this change REST does, so the
       sentence inverts.
    2. The class doc also describes a gradient underline drawn under the label width. There
       is no underline anywhere in this file - the comment at the `Text` says so outright.
       The class doc has been contradicting its own widget body. Delete the underline claim
       from the class doc.
    3. The comment above `ShaderMask` repeats the same inverted rest/hover pairing.
    4. The comment inside `shaderCallback` says the hover paint is not the brand gradient.
       That half was the only accurate line in the file, and after this change its
       implication about rest is wrong too.

    Rewrite all four to describe what the code now does, once, in one place, and delete the
    duplicated restatements rather than maintaining three copies of the same paragraph.

    Add to the class doc a short paragraph recording the brand-rule position from this
    plan's open_decision: one gradient FILL per surface is the rule this respects, gradient
    TEXT is a shared affordance language, and the named step-down candidate if the dashboard
    ever reads noisy is the bottom-bar active tab rather than these links.

    Also record the contrast pairs and the fact that the numbers in
    `genius_wallet_gradient.dart` are against a different surface, so nobody reconciles two
    correct sets of figures into one wrong one.

    Write the test file. Pump the widget inside a theme carrying `GWColors.dark()`, read the
    static directly for both states, and assert the stop colours. Assert the two rest stops
    are DIFFERENT from each other - that single assertion is what would have caught the
    current bug, where a "gradient" was two copies of one colour. Add a light-appearance case
    asserting the rest shader collapses to two identical stops. Assert the `ShaderMask` is
    still present with `BlendMode.srcIn`.

    Prose only in comments. No em dash character anywhere in this file, in code or comment;
    write "a - b" with a plain hyphen.
  </action>
  <verify>
    <automated>flutter test test/components/gw_view_all_link_gradient_test.dart</automated>
    <automated>grep -c 'brandCtaText' lib/components/cards/gw_view_all_link.dart</automated>
    <automated>grep -vn '^\s*//' lib/components/cards/gw_view_all_link.dart | grep -c 'textSecondary' </automated>
    <automated>! grep -n "$(printf '\xe2\x80\x94')" lib/components/cards/gw_view_all_link.dart</automated>
  </verify>
  <done>
    The rest shader is the brand CTA gradient with two distinct stops; hover is flat
    `textPrimary`; the new test passes; `textSecondary` no longer appears in the non-comment
    body of the file (it was the rest colour and nothing else used it); no em dash character
    is present.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: GWSectionTitle gains an optional titleBlock, and Assets adopts scheme C</name>
  <files>lib/components/cards/gw_section_title.dart, lib/components/coins/view/coins_screen.dart, test/components/assets_header_scheme_c_test.dart</files>
  <behavior>
    - `GWSectionTitle` with only a `String title` renders exactly as it does today. All seven unchanged call sites, four of them `const`, still compile with no edit.
    - `GWSectionTitle` with a `titleBlock` renders that widget on the left instead of the title `Text`, keeps `trailing` at the far right, and keeps its own `ConstrainedBox` and derived bottom pad.
    - The Assets `GWSectionTitle` box measures 46px tall - `edgePad(2)` plus the 44px reservation plus a bottom pad of 0 - in BOTH the funded and all-zero states.
    - The Assets header lays out at a 390pt-equivalent width with the worst realistic total and throws no overflow exception.
    - `contentTopInset` on Assets is still 20.
    - `gw_section_title_rhythm_test.dart` passes unedited.
  </behavior>
  <action>
    First the component. Add ONE optional parameter, `Widget? titleBlock`, alongside the
    existing ones. Keep `title` `required` - that is what makes this additive rather than a
    fork: no call site loses an argument, no call site can accidentally render nothing, and
    the section keeps a canonical name in source even when the painted left side is a
    composite. Do not add a default that would break `const` at the four const sites.

    In `build`, when `titleBlock` is non-null render it in place of the title `Text`, wrapped
    in `Flexible` so a long total can never paint an overflow stripe. When it is null render
    the `Text` exactly as today, unwrapped - the existing doc explicitly says the title `Text`
    stays unwrapped to match the Assets reference, and that sentence still governs the
    string path.

    Deliberately do NOT add a `Semantics` wrapper around `titleBlock`. Every child of the
    Assets block - the kicker, the total, the change - is independently meaningful and must
    stay independently announced; wrapping them in one label would hide the balance from
    VoiceOver. The call site passes the section name into `GWKicker`, so the word is still
    spoken. Write that reasoning down; it is the kind of omission that looks like an
    oversight later.

    Update the component's class doc. Two sentences are now stale: the 44px constant's doc
    says 44 is "the height the 2-line Assets total needs (amount ~20/26 + 24h-change ~13/18)",
    which describes the arrangement this task is replacing. Restate it as the reservation
    that a two-line LEFT block now consumes exactly, and give the new arithmetic - an 11/16
    kicker over a 24/28 total sums to 44.0 - so the next reader can check it without
    remeasuring. Leave every word about the rendered-gap rule alone; none of it changes.

    Now the call site, `coins_screen.dart:321-403`. Import `gw_kicker.dart`.

    Build the left block as a `Column`, `mainAxisSize.min`, `crossAxisAlignment.start`:

    - `GWKicker('Assets', dense: true)`. Pass the section name in its natural casing - the
      widget upper-cases it, and its own doc forbids call sites pre-calling `toUpperCase()`
      because that loses the casing for screen readers.
    - A `Row`, `mainAxisSize.min`, `crossAxisAlignment.baseline` with
      `textBaseline: TextBaseline.alphabetic`, holding the total then the change, separated
      by `GeniusWalletConsts.space4`.
    - The total is `currencyFormatter.format(total)` in
      `GeniusWalletTypography.numericHeadline` with `fontWeight: FontWeight.w700`,
      `color: gw.textPrimary`, and `height: 28 / 24`.
    - The change keeps the existing `if (total > 0)` guard and the existing
      `statusSuccess` / `statusError` choice, in `labelMd`, and its string becomes the signed
      percentage alone.

    Three comments this call site must carry, because each records a decision that will
    otherwise be undone by someone tidying up:

    1. **The `height: 28 / 24` override is load-bearing.** `numericHeadline` ships 32/24;
       kicker 16 plus total 32 is 48, which breaks the 44 reservation and grows a panel that
       phase 25 deliberately capped. State the sum both ways so the trap is visible.
    2. **Why the change dropped to percent-only.** Give the width arithmetic from this plan:
       the 336px content box, about 86 for the link, a 12px minimum gap, leaving about 238;
       the total at 24px is about 172, so the percentage at about 50 fits with roughly 8
       spare while today's full pair at about 126 overflows by roughly 68. Keep the existing
       ceiling note and its upgrade path - drop the change to its own line, not a `FittedBox`.
    3. **The accepted cost, and the named fallback.** Assets now stops matching Markets and
       Transactions, whose names remain 18px white titles, while this name drops to an 11px
       secondary kicker. Jakub accepted that on 2026-08-07. If it reads wrong side by side on
       the phone, the fallback is sketch 178 scheme A: the title stays 18px and the total
       becomes a hero band beneath it, at a cost of 52px of height and a change to the
       approved title gap. Write scheme A into the comment by name so it is not rediscovered
       from scratch.

    Leave `contentTopInset: 20` and its entire existing comment block untouched. The first
    widget under the header is still a `CoinCardRow`, so the rendered 30px gap is unchanged
    and there is nothing to restate. Do not adjust it to compensate for anything.

    The `trailing` becomes `GWViewAllLink(onTap: () => context.push('/assets'))` alone - no
    wrapping `Row`, no `space12` spacer. Keep the `push` versus `go` comment; it is still
    correct and still load-bearing.

    Write the test file. Mount the Assets header composition - the component plus a left
    block built the same way - inside a `DashboardScrollContainer` at a 390pt-equivalent
    width, and assert the `GWSectionTitle` box is 46px in the funded state and 46px in the
    all-zero state. Assert `tester.takeException()` is null with the worst realistic total so
    an overflow becomes a red test rather than a stripe someone notices on a phone. If
    mounting the real `CoinsScreen` needs a bloc the existing tests do not already provide,
    build the header composition directly rather than dragging a bloc in - the property under
    test is geometry, not data flow.

    **If the measured box is anything other than 46, STOP and report it. Do not grow the
    panel and do not adjust the reservation to fit.** The zero height cost is the whole
    reason scheme C was chosen over A and D; a scheme C that costs height is not the scheme
    Jakub approved.

    No em dash character anywhere in either file, in code, comment or UI string.
  </action>
  <verify>
    <automated>flutter test test/components/assets_header_scheme_c_test.dart</automated>
    <automated>flutter test test/components/gw_section_title_rhythm_test.dart</automated>
    <automated>flutter test test/dashboard/dashboard_section_caps_test.dart test/dashboard/assets_screen_test.dart</automated>
    <automated>test -z "$(git diff --name-only -- test/components/gw_section_title_rhythm_test.dart)"</automated>
    <automated>grep -c 'contentTopInset: 20' lib/components/coins/view/coins_screen.dart</automated>
    <automated>! grep -n "$(printf '\xe2\x80\x94')" lib/components/cards/gw_section_title.dart lib/components/coins/view/coins_screen.dart</automated>
  </verify>
  <done>
    The Assets `GWSectionTitle` box measures 46px in both balance states; the new test
    passes; `gw_section_title_rhythm_test.dart` passes with an empty diff; the caps and
    assets-screen suites pass unedited; `contentTopInset: 20` is still present; no em dash
    character is present in either file.
  </done>
</task>

<task type="auto">
  <name>Task 3: full gates, and the census walked one site at a time</name>
  <files>lib/components/cards/gw_view_all_link.dart, lib/components/cards/gw_section_title.dart, lib/components/coins/view/coins_screen.dart</files>
  <action>
    Run both gates to completion and hold them against the measured baseline in this plan:
    `flutter analyze` at 0 issues, `flutter test` at 1081 passing plus the new cases, zero
    failures.

    If any pre-existing test goes red, fix the CODE. Do not edit the test, do not widen a
    tolerance, do not relax an assertion, do not add a skip. A red test here is information
    about the change, and the two most likely messengers are named in this plan:
    `gw_section_title_rhythm_test.dart` if the component change was not truly additive, and
    `dashboard_section_caps_test.dart` if the Assets trailing lost its `GWViewAllLink`.

    Then walk the three-site census from this plan and confirm each link still reads
    correctly with the gradient at rest - Assets, Markets, Transactions. Confirm by reading
    the code at each site that nothing else was assuming a flat secondary link: no sibling
    element was relying on being the brightest thing in its row, and no site paints the link
    on a surface other than `DashboardScrollContainer`. Report the result site by site in the
    summary rather than as one line, because "global change, checked globally" is the claim
    this task exists to substantiate.

    Report in the summary, for the checkpoint that follows:
    - the analyze and test numbers, both baseline and final
    - the measured Assets `GWSectionTitle` box height, stated as a number
    - the three census sites, each with a verdict
    - the brand-rule recommendation from this plan's open_decision, restated in two lines so
      Jakub can answer it without reading the plan

    Do NOT create any commit. Leave the working tree dirty for review.
  </action>
  <verify>
    <automated>flutter analyze 2>&amp;1 | tail -3 | grep -q 'No issues found'</automated>
    <automated>flutter test 2>&amp;1 | tail -3 | grep -q 'All tests passed'</automated>
    <automated>test -n "$(git status --porcelain)"</automated>
  </verify>
  <done>
    `flutter analyze` reports no issues; `flutter test` reports all tests passed with a count
    at or above 1081; no pre-existing test file appears in `git diff --name-only`; no commit
    has been created.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
    Two changes on the dashboard, both from sketch 178 and both decided on 2026-08-07.

    **Scheme C on the Assets header.** The left side of the title row is now a two-line
    block: a small uppercase ASSETS kicker over the portfolio total at 24px, with the 24h
    percentage inline beside it. View all stands alone at the far right. Two elements in the
    row instead of three. The panel is the same height it was, and the gap below the title is
    the same 30 you approved this morning.

    **View all is gradient at rest, everywhere.** All three links - Assets, Markets,
    Transactions - now paint the brand CTA gradient without needing a hover, which is the
    only state that exists on the phone. Hover on desktop lifts them to white.
  </what-built>
  <how-to-verify>
    Build to the iPhone in dark mode and open the dashboard.

    1. **The side-by-side. This is the one real cost of scheme C and the reason this
       checkpoint is blocking.** Look at the Assets header directly against the Markets and
       Transactions headers in the same scroll. Markets and Transactions still say their
       names in 18px white. Assets says its name in an 11px grey kicker and gives the big
       type to the number instead. Scroll slowly between all three. **Does the Assets panel
       read as deliberately different, or does it read as broken?** If it reads as broken,
       say so - the fallback is scheme A from sketch 178, which keeps the 18px title and pays
       52px of height for a hero band underneath, and it is a planned change rather than a
       rescue.

    2. **The height.** Compare the Assets panel against how it looked before. It must not be
       taller. The gap between the header and the first coin row must look unchanged.

    3. **The 24h move lost its dollar figure.** It used to read something like
       `+$1,234.56 · +2.31%`. It now reads `+2.31%` alone. That is not an oversight - the
       full pair does not fit beside a 24px total on a 390pt screen, the arithmetic is in the
       plan. Confirm you are happy losing the dollar amount here, or say if you want it back
       and the total drops back to 20px to make room.

    4. **The three links.** Assets, Markets, Transactions. All three View all links should
       now be visibly brand-coloured rather than grey. Check each one is comfortably readable
       against the dark card and that none of them now competes with something next to it.

    5. **The brand-rule question, which needs an answer either way.** The dashboard now
       carries three gradient links plus the gradient SWAP dock plus the gradient active tab.
       The standing rule is "max one gradient per surface". The recommendation is to keep all
       of it and restate the rule as being about gradient FILL, since the dock is still the
       only filled gradient and gradient text is already the app's affordance language. If it
       looks like too much on glass, the thing to step down first is the bottom-bar active
       tab, not the links. **Which do you want?**

    6. Toggle to light mode briefly and confirm the three links are still readable. They
       collapse to a flat brand blue there rather than staying gradient. Light is not the
       focus - flag anything only if it is badly wrong.
  </how-to-verify>
  <resume-signal>Type "approved", or name which of items 1, 3 and 5 you want changed.</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| none crossed | Presentation-only change. No new input parsing, no network call, no storage, no dependency added, no package installed. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- | --- |
| T-hdr-01 | Information disclosure | Assets header total | low | accept | The portfolio total is already rendered in this exact position today. Scheme C changes its size, not its visibility or its audience. |
| T-hdr-02 | Denial of service | `GWSectionTitle` layout | low | mitigate | An unbounded total string could overflow the title row. Mitigated by the `Flexible` wrapper in task 2 and asserted by the no-exception case in `assets_header_scheme_c_test.dart`. |
</threat_model>

<verification>
- `flutter analyze` ends at **No issues found**, against a measured baseline of 0.
- `flutter test` ends at **All tests passed**, at or above the measured baseline of 1081.
- `test/components/gw_section_title_rhythm_test.dart` is green and its diff is empty.
- No pre-existing test file appears in `git diff --name-only`.
- The Assets `GWSectionTitle` box measures 46px in both the funded and all-zero states.
- `contentTopInset: 20` survives in `coins_screen.dart`.
- All three `GWViewAllLink` census sites are walked and reported individually.
- No em dash character in any touched file.
- No commit created.
</verification>

<success_criteria>
- The Assets header is scheme C: kicker over total on the left, View all alone on the right.
- The panel height is unchanged and the title gap is unchanged.
- `GWSectionTitle` is extended by exactly one optional parameter, with `title` still required and all seven other call sites untouched.
- `GWViewAllLink` paints the brand CTA gradient at rest at all three sites, with a hover state that still differs from rest.
- All four false comments in `gw_view_all_link.dart` are corrected.
- The accepted cost of scheme C and its scheme A fallback are recorded in source.
- The brand-rule recommendation is put to Jakub as a question with a stated favourite.
- Both gates pass and the tree is left uncommitted for review.
</success_criteria>

<output>
Create `.planning/quick/20260807-assets-header-c-and-gradient-link/SUMMARY.md` when done.
</output>
