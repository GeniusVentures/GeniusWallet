---
quick_id: 260728-q7c
status: complete
date: 2026-07-28
commit: none - CLAUDE.md forbids commits
sketches: [067-A, 156-A]
files_modified:
  - lib/squid_router/swap_settings_drawer.dart
  - lib/squid_router/token_selector_drawer.dart
  - lib/components/bottom_drawer/responsive_drawer.dart
  - lib/theme/genius_wallet_colors.dart
  - lib/theme/gw_colors.dart
  - lib/account/account_dropdown_selector.dart
  - lib/account/sdk_account_manager.dart
  - lib/squid_router/slippage_state.dart
  - test/theme/theme_contrast_test.dart
  - test/squid_router/slippage_state_test.dart
gates:
  analyze_lib: 59
  analyze_baseline: 59
  flutter_test: 334 pass / 1 fail
  flutter_test_baseline: 332 pass / 1 fail
verification: WALKED by Jakub 2026-07-28 - accepted with 3 corrections, all applied (see Live walk)
---

# Quick 260728-q7c - SUMMARY

067-A and 156-A, shipped together because 067's decision note says they only work together.

## 067-A - one widget, plus one gap

`GWKicker('Slippage tolerance')` at the default 13 step replaces the sentence-case `Text`. The gap
below it went **4 to 12**: with no container the gap is the only thing grouping the section, so it
cannot be the 4px that was there when a label sat directly on its own description.

That is the whole of 067-A. It introduces no new widget, which was the point of the sketch.

## 156-A - and the number 156 got wrong

The pair is what 156 specified: panel down to `surfaceElevated`, an input's fill up to `surfaceMenu`,
a stronger edge on the input. Two of those three are literal token swaps. The third had to be
re-measured.

**156 proposed white 30% and called it 3.0:1. It is 2.63:1.** The mistake is worth recording because
it is easy to repeat: 30% was measured against the *field*, but `GWFocusRing` does not use a
`Border` - it paints an outer `DecoratedBox` in the edge colour and covers all but 1.5px of it with
the field. **The visible ring therefore composites over the PANEL, not the field.** Sketch 067's own
table had already arrived at the right answer independently - white **36% = 3.30:1** - so the value
shipped is 067's, not 156's.

That became `GeniusWalletColors.borderControl`, a third border token beside `borderSubtle` and
`borderStrong`, carried through `GWColors` (field, both factories, `copyWith`, both
value-preservation asserts). Light mode takes ink at 46%, which is what 3:1 on a pure-white panel
costs.

## What 156 did not enumerate, and what it cost

156 named three knock-ons. The fourth is the one that would have shipped a broken drawer: **anything
inside a drawer already painted `surfaceElevated` becomes invisible the moment the panel takes that
colour.** Two real cases, both found by reading rather than by walking:

- `account_dropdown_selector.dart` - the account rows' `tileColor` (a list of rows at 1.00:1)
- `sdk_account_manager.dart` - the account card's `background`, likewise

Both moved UP to `surfaceMenu`, the same inversion the input fields took. Two `MenuAnchor` popups in
the same files also sat at `surfaceElevated`; a menu floating above a `surfaceElevated` panel has no
edge, so they took `surfaceMenu` too - which is what the token is named for.

**Three things got BETTER for free**, all of which were broken today and nobody had noticed, because
they were painted correctly for a card and the drawer was not one:

| | today | after |
|---|---|---|
| the receipt's action badge (`surfaceMenu` chip) | invisible on a `surfaceMenu` panel | reads |
| the receipt avatar's 2px punch-out ring (`surfaceElevated`) | wrong colour in the drawer | matches |
| the bridge network rows (`surfaceMenu` fill) | invisible | read |

The `token_selector_drawer` selection tint was re-measured as 156 asked: 1.44:1 to 1.39:1 against
the panel. Unchanged in practice, and it is not the identifier anyway - the row's `hoverEdge` border
and the check glyph are. The `brandPrimarySubtle` header hairline goes 1.25:1 to 1.21:1; it is
declared decorative in the code and stays so.

## The change 156-A did not ask for, and why it is here anyway

**A drawer painted `surfaceElevated` has no silhouette.** The same arithmetic 156 used to kill a
darker field applies to the panel against the scrimmed page behind it:

| panel edge vs `black54` over the page (#050608) | contrast |
|---|---|
| old #171A21, no border | 1.16:1 |
| new #0C0E14, no border | **1.05:1** |
| new #0C0E14 + **`borderSubtle` 12%** - shipped | **1.30:1** |
| new #0C0E14 + `borderStrong` 24% | 2.01:1 |

Two near-blacks cannot separate by fill - which is finding 4 of sketch 156 itself, pointed at the
panel instead of the field. So the panel takes a card's whole recipe, fill **and** hairline, on the
desktop `Container` and the mobile sheet's `shape`.

**It first shipped at `borderStrong` and Jakub overruled that on the walk** (correction 4 below):
*"co do borderów drawerów, to użyj takie jakie mają swap boxy"*. Those are `GWCard`s at
`borderSubtle` width 1, so the drawer wears a card's hairline rather than a heavier one - if it is a
card, it should not be a card trying harder than every other card on screen. The cost is accepted
and is 2.01:1 down to **1.30:1**. No WCAG threshold applies to a modal sheet's outline (its scrim,
position and content identify it), so this is a legibility call, made with the panel on screen
rather than in a table.

## The check

One test, in `theme_contrast_test.dart` because the contrast helper lives there and its own comment
forbids a second copy. It **opens a real drawer and reads the panel the shell actually paints**,
rather than the token this reasoning assumes it uses, then composites `borderControl` over it and
asserts 3:1. Both appearance modes.

**Corrected 2026-07-28, same day.** That claim was half wrong: white 36% measures 3.30:1 on #0C0E14
and **3.33:1 on #171A21**, so the contrast assertion passes on either panel and would NOT have
caught a revert. The test now also asserts the panel's IDENTITY (`panel == gw.surfaceElevated`), and
that line is the actual net. Contrast alone catches the alpha drifting; identity catches the canvas
moving.

## Gates

- `flutter analyze lib` = **59**, baseline 59.
- `flutter test` = **334 pass / 1 fail**, baseline 332/1. The two new passes are this task's; the
  single failure is the inherited `test/local_wallet_storage_test.dart` (no `main()`), confirmed by
  an isolated run.
- Hot-reloaded into the live app, 129 of 3650 libraries.
- **No commit** - `CLAUDE.md`.

## Follow-up

- **Human walk.** 156's own note stands: *"once the panel is #0C0E14 the transaction receipt stops
  being distinguishable from the cards behind it. That is intended but it is the change nobody has
  seen."* Now also: the panel's new hairline, on desktop and on the mobile sheet.
- **`GWFocusRing`'s default resting edge is still `borderSubtle`.** Deliberately left alone: the
  two drawer fields pass `borderControl` explicitly, but `submit_logs_screen.dart`'s message field
  sits on a different canvas and was not in this task's scope. If the answer is "every input in the
  app deserves a 3:1 edge", that is one line in `gw_focus_ring.dart` and a separate look.

## Live walk, 2026-07-28 - three corrections, all applied

Jakub walked the Swap Settings drawer against sketch 067's own mockup. *"nie jest źle, na chwilę
obecną może zostać"* - the canvas holds. Three things did not.

### 1. The field is RECESSED, not raised - this reverses a third of 156-A

*"back/fill tego field powinien być ciemniejszy - sprawdź opcje komponentów"*.

156-A's premise for the field was **up**: `surfaceMenu` on a `surfaceElevated` panel, the lighter
object on a darker canvas. On screen that reads as a raised tile, not as something you type into.

The palette's options against a #0C0E14 panel:

| fill | vs panel | reads as |
|---|---|---|
| `surfaceMenu` #171A21 (156-A's pick) | 1.11:1 lighter | a raised tile |
| **`surfaceSunken` #06080C** | 1.04:1 darker | **a well** |
| `surfaceBase` #0B0D12 | 1.01:1 | nothing |
| transparent | 1.00:1 | border only |

`surfaceSunken` is not a new idea and not a deviation: it is **already this app's fill for a recessed
control** - `pin_screen.dart`, `token_info_screen.dart`'s own fields, the control-track standard in
`dashboard_screen.dart`, the news and transactions search wells. And it is sketch **156's own scheme
C**. Jakub's eye landed on the option the sketch had already drawn and 156-A had passed over.

**The edge is untouched by this.** `GWFocusRing` paints its ring as an OUTER `DecoratedBox`, so the
ring composites over the panel, never over the fill. `borderControl` stays 3.30:1 whatever the fill
is - which is also why the contrast test still passes unchanged.

Applied to both drawer inputs (slippage field, token search) so the two stay one control.

### 2. The field had no label

067-A draws `Wartość własna` above the field; the shipped drawer had a `Custom` **placeholder**
instead. A placeholder is not a label: it vanishes the moment the field has a value, and it always
does - a preset is selected when the drawer opens, so that word had never once been on screen.

Now `Custom value` at `labelMd`/w500/`textPrimary70` (9.59:1), 8 above the ring. The placeholder was
deleted rather than kept: saying the same word twice for a state that lasts one keystroke is not
worth an extra string.

### 3. The comfortable band now speaks

067-A draws an ⓘ line under the field in the OK state. `slippageState()` returned `message: null`
there, documented as *"Inside the comfortable band - nothing to say"*, so `_Message` was unreachable
for `ok` and the design's line could never render.

It says `Typical for most pairs.` now, in `textSecondary` (5.97:1) with `info_outline`. Two reasons
beyond matching the drawing: it **confirms** rather than corrects, which is the only feedback a
settings field can give someone who got it right; and it **holds the row**, so the panel no longer
jumps in height the moment a typed value crosses into the warning band.

`_Message` grew a third tone for it - without one, reassurance would have fallen through to amber
and been painted as a warning.

**Empty stays silent**, deliberately. That was the original reasoning's good half and it survives:
nothing typed, nothing to confirm. The test was rewritten from *"the comfortable band is silent"* to
*"the comfortable band confirms, and empty stays silent"* and now pins both halves.

### Also swept

Three user-facing strings in `slippage_state.dart` carried em dashes, against the standing copy
rule. Fixed while in the file.

### Gates after the walk

`analyze lib` **59** = baseline. `flutter test` **334 / 1**, unchanged - the ok-state change
rewrote an existing test rather than adding one. Hot-reloaded live (3 libraries).

### 4. The panel hairline is the swap boxes', not a heavier one

*"co do borderów drawerów, to użyj takie jakie mają swap boxy"* - `gw.borderSubtle`, width 1,
exactly `swap_field.dart`'s `GWCard`. Applied in the shell, so all ~19 drawers took it at once, on
desktop and on the mobile sheet. Measurements in the table above and in `ResponsiveDrawer`'s class
doc.

**The FIELD edge does not follow it** and stays at `borderControl` 36% / 3.30:1. A card's border is
decoration; an input's border is the only thing that says "this is an input". 1.4.11 applies to one
and not the other, and collapsing them would have undone the day's contrast work to match a hairline.

## Follow-up filed

`.planning/todos/pending/2026-07-28-drawer-input-fields-are-hand-assembled-while-gwtextfield-exists.md`

Jakub asked whether `Custom value` came from a component. It did not, and neither does most of the
field around it: both drawer fields are `GWFocusRing` + a raw `TextField` + a hand-written label +
a hand-written message row, while `GWTextField` and `GWSearchField` already do exactly this. The
blocker is one hardcoded line (`fillColor: gw.surfaceElevated`, no parameter), and the finding that
makes it bigger than one parameter is that **`GWSearchField` does not use `GWFocusRing`** - it
rolls its own gradient ring, so the app carries two implementations of one idea.

Deferred by agreement: nothing is broken for a user, the honest fix touches Settings/News/Markets/
onboarding rather than drawers, and the direct payoff is two call sites.