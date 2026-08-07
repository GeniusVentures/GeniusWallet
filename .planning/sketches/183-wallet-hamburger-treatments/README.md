# Sketch 183 - the wallet icon and the hamburger: six surface treatments

http://localhost:8899/183-wallet-hamburger-treatments/

Direct continuation of `181-wallet-control-compact`, whose scheme **F** Jakub picked on 2026-08-07: a
short-form wallet control plus a hamburger, both top-right, replacing the 224 px pill. **That is
settled.** The composition, the count of controls and their position are not reopened here.

## The request

Jakub, 2026-08-07, immediately after picking F:

> "chcialbym zebys przygotowal mi kilka innych opcji i jak beda one wyswietlane - czy z tym borderem,
> czy bez bordera, czy border z gradientem, i tak dalej. Wiec przygotuj 5-6 takich wersji, a
> zobaczymy."

So this sketch changes exactly one thing: **the skin**. Six treatments plus the shipped pill for
scale, all on the same geometry to the pixel.

## What is held constant, and it is held to the pixel

| Held constant in all six | Value |
| --- | ---: |
| title Row at 390pt | **342.00** |
| `BrandLockup`, mark 28 / wordmark 18 | 106.06 |
| Wallet control | 44.00 x 44.00 |
| Gap, `space6` | 12.00 |
| Hamburger | 44.00 x 44.00 |
| **Cluster** | **100.00** (25.6% of the bar, against the shipped pill's 223.94 / 57.4%) |
| Free space left in the title Row | 135.94 |

342, not 358: `AppBar` charges `titleSpacing` on **both** sides - `NavigationToolbar` lays the middle
slot at `width - leading - trailing - middleSpacing * 2`. And both icons stay in **`title`, not
`actions`**: in `actions` the title Row drops to **246.00** and the BRAND becomes the thing that
shrinks under Dynamic Type, which is backwards. Renders identically; fails differently.

Because the geometry is frozen, **a difference you can see in this sketch is a difference in the
treatment**. That is the whole point of it.

## The constraint that decides this, and it is not a matter of taste

`surfaceMenu` `#171A21` on `surfaceElevated` `#0C0E14` measures **1.11:1**. Not "low" - invisible.
No two dark surface tokens in this palette separate by even 1.2:1 (`surfaceSunken` on the bar is
**1.04:1**, `surfaceBase` is **1.004:1**). **A fill cannot identify a control in this bar.**

That is why the shipped pill has a border at all, and the token was created for it.
`genius_wallet_colors.dart`'s `_borderControl` doc calls it *"the edge of a CONTROL whose fill cannot
identify it"*, prints the same comparison table this sketch recomputes, and closes with *"Decorative
separators stay on `_borderSubtle` - a rule that carries no information has no 1.4.11 threshold to
meet, and painting every hairline at 36% would make the app a wireframe."*

So a **no-border** variant is not simply a cleaner look. It has to answer *"what identifies this as a
control at 3:1 instead"*, and there are only three honest answers: a stronger edge, the content
itself, or an accepted failure labelled as one. **Every variant carries its measured ratio and a pass
or a fail.** Two fail and are drawn anyway, because Jakub asked to see the range.

## The contrast table

WCAG 2.x sRGB relative luminance. **Translucent hairlines are composited over `surfaceElevated`
#0C0E14 first, then measured against it** - measuring the raw white before compositing would report
19.29:1 for a 12% border, which is how a failing edge gets shipped. Threshold **3:1**, WCAG 2.2
**1.4.11 Non-text Contrast**.

| Variant | Identifying element | Composited | vs the bar | 3:1 |
| --- | --- | --- | ---: | --- |
| **Now** - shipped pill | `borderControl` white 36% edge | `#636569` | **3.30:1** | **PASS** |
| **A** - hairline | `borderControl` white 36% edge | `#636569` | **3.30:1** | **PASS** |
| **B** - filled, no border | `surfaceMenu` fill | `#171A21` | **1.11:1** | **FAIL** |
| **C** - bare | no container - the glyphs alone | `#0AAEE6` / `#FFFFFF` | **7.54 / 19.29:1** | **PASS** |
| **D** - gradient ring | `brandCta` 1.5px edge, both stops | `#0AD89C` / `#0AAEE6` | **10.39 / 7.54:1** | **PASS** |
| **E** - borderSubtle | `borderSubtle` white 12% edge | `#292B30` | **1.36:1** | **FAIL** |
| **★ F** - split | wallet `borderControl` / hamburger glyph | `#636569` / `#FFFFFF` | **3.30 / 19.29:1** | **PASS** |
| *considered* - sunken well | `surfaceSunken` fill | `#06080C` | **1.04:1** | **FAIL** |

Supporting pairings, same method: `borderStrong` white 24% `#46484C` **2.11:1** (the bar's bottom
edge - below 3:1, shipped knowingly, because a separator carries no state); `brandPrimaryStrong`
#0AAEE6 disc on the bar **7.54:1**; `textOnBrand` #000B18 monogram on that disc **7.74:1**;
`textPrimary` bars **19.29:1** on the bar and **17.41:1** on `surfaceMenu`; `brandBorder` #14C8FF
**9.86:1** and #5BFFD0 **15.30:1**; the 4.5 px of `surfaceMenu` between D's ring and the disc
**6.81:1** against both.

### The two rows worth reading together

**B and C.** B keeps a container and that container **fails** at 1.11:1. C has no container at all
and **passes** at 7.54 and 19.29. **The variant with less paint measures better**, because in this
bar a fill is not an identifier and a bright glyph is. Neither is inaccessible - in both, the content
carries 1.4.11 - but only C is honest about it.

**E as the counter-example it was drawn to be.** E is the only variant that *paints a boundary below
threshold*. B's container also fails, but B never claims to have an edge. E draws one you can almost
see, and an edge you can almost see is worse than no edge: it looks like the control is identified
when it is not.

## Do the two controls get the same treatment, or different?

A real question, and the treatment - not the layout - decides which reading you get. The layout gap
is `space6` = **12.00** in every variant. The **ink** gap is not:

| | Ink gap | What it reads as |
| --- | ---: | --- |
| Both bordered (A, B, D, E) | **12.00** | 100.00 px of continuous chrome at a 56 px pitch - the geometry of a **segmented control** |
| Both bare (C) | **6 + 12 + 13 = 31.00** | Two separate icons. Maximum separation, and nothing says where to press |
| Split (F) | **12 + 13 = 25.00** | A chip and a glyph - two different kinds of object |

(The disc stops 6 px inside its 44 box; the hamburger's 18 px bars stop 13 px inside theirs.) So the
treatment changes how far apart the two controls *look* by a factor of **2.6**, while the touch
geometry never moves.

**The answer this sketch arrives at: different, for a reason about what the objects are rather than
how they look.** The wallet icon holds a *value* - which wallet, and through the 16 px badge which
chain - and its content changes when that value changes. The hamburger holds nothing; it is a fixed
door to a fixed list. In this codebase a thing with a value in it is a chip on `surfaceMenu` with a
`borderControl` edge (the recipe `responsive_drawer.dart` states in its own class doc, and the one
the sheet's network chips already use). A menu glyph is a bare icon, which is what every native phone
header ships. **Making them match would invent a similarity that is not there.**

## The gradient border: the component exists, and it is the wrong one

`lib/components/cards/gw_gradient_border_card.dart` does the geometry correctly - a `Container` with
the gradient as decoration, `padding: EdgeInsets.all(borderWidth)`, inner surface at
`radius - borderWidth`. Passing `width: 44, height: 44, radius: 22, padding: EdgeInsets.zero,
background: gw.surfaceMenu` would render D exactly. Three things are wrong with doing it, and the
third is disqualifying.

1. **Wrong gradient by default.** Its default is `GeniusWalletGradient.brandBorder` =
   **#14C8FF -> #5BFFD0**, not the `brandCta` #0AD89C -> #0AAEE6 this sketch was asked for. Both pass
   1.4.11 (9.86:1 and 15.30:1), so this is a brand-voice choice rather than a contrast one - but it
   must be passed explicitly or the header quietly gets a different gradient from the dock.
2. **It is a card, not a button.** `radius2xl` = 16 and `padding: EdgeInsets.all(space8)` both have to
   be overridden, which is the usual sign the component is not the one you want.
3. **The ripple disappears.** Its `onTap` path is `Material(color: transparent) > InkWell > card`, so
   the splash paints on the transparent Material *behind* an opaque gradient `Container` and is never
   seen. The shipped `WalletPill` does the opposite - `Material(color: surfaceMenu, shape:
   StadiumBorder(...), clipBehavior: Clip.antiAlias)` with the `InkWell` *inside* - so its ripple is
   visible and clipped to the stadium. On a card nobody notices. On a 44 px header button, tap
   feedback is most of the feedback there is.

**So: not a reuse.** D needs a small new widget - the gradient `Container` as the ring, with the
shipped Material-outside / InkWell-inside recipe as the disc. Roughly fifteen lines. Not a large
cost, simply not the "we already have this" it looks like from the file listing.

### Where a gradient edge sits against the standing CTA rule

The rule, verbatim: **fill means commitment, outline means everything else**; `gradientOutline` is
*"only for a secondary action standing beside or under a filled gradient CTA, as its deliberate twin.
Never for a lone secondary action."* And: **at most one filled gradient per surface.**

D does **not** break the *filled*-gradient reservation - the SWAP dock stays the only gradient fill in
the app. But **a gradient-edged header control is a lone secondary action wearing the signature**,
which is precisely the case the outline half of the rule names and refuses. The wallet icon and the
hamburger are not twins of the dock; they are at the other end of the screen and neither commits to
anything. Count the home surface with D applied: brand mark (gradient), two rings (gradient), SWAP
dock (gradient fill), active bottom-bar label (gradient text) - **five gradient objects, and the two
new ones are the only ones that are neither the brand nor the primary action.** The app is also
currently moving the other way: the dashboard's `View all` links were reverted from gradient to flat
grey at Jakub's request this week.

Two smaller observations, both real: the ring's blue stop **is** `brandPrimaryStrong` #0AAEE6, the
same colour as the disc it surrounds - they do not merge (the 4.5 px of `surfaceMenu` between them is
**6.81:1** against both) but the right-hand side becomes two concentric rings of one colour. And at
**1.5 px**, 4.5 physical px on a 3x iPhone, a two-stop ramp across a 44 px arc reads as a bright teal
ring, not as a gradient. **D pays the gradient's full systemic cost and collects very little of its
look.**

## One more treatment, measured and not built

**The sunken well** - `surfaceSunken` #06080C, a control *darker* than the bar. It fails twice before
taste. **Contrast:** 1.04:1, worse than `surfaceMenu`, so it needs `borderControl` anyway and
collapses into A with a darker middle. **Language:** the house interaction is the **lift chip** - an
element rises onto `surfaceElevated` with a card shadow and a 1 px upward translate. A control that
starts in a well has to fall to be pressed, and that is not a motion this app makes anywhere.
Recorded so it is not proposed later as new.

## Recommendation

**★ Ship F - the wallet keeps the hairline, the hamburger goes bare.** It is the only variant that
*decides* the same-or-different question instead of defaulting to one answer, and it decides it on
what the objects are: the wallet icon carries a value that changes, so it gets the app's existing chip
recipe (`surfaceMenu` + `borderControl`, **3.30:1**); the hamburger carries nothing and opens a fixed
list, so it gets the idiom every phone header uses, at **19.29:1**. Both identifiers pass 1.4.11 on
their own terms and **neither depends on the 1.11:1 fill**. It also fixes A's one real defect for
free: two identical stadiums 12 px apart read as a segmented control, and F's pair cannot, because
only one of them is a stadium.

**It is also the cheapest diff here.** The wallet control stays on the shipped `Material(color:
surfaceMenu, shape: StadiumBorder(side: BorderSide(gw.borderControl)))`, so the change to
`mobile_header.dart` is a *deletion* - the name column and the caret go, the decoration does not move.
The hamburger is a plain `IconButton` at 44 x 44. **No new token, no new component, no new gradient.**

**Runner-up: C - both bare.** If Jakub wants the header quieter than F, **C is the next stop and not
B**, which is the non-obvious part. C measures better than the shipped border does (7.54 and 19.29
against 3.30), it is the only variant with no chrome to get wrong in light mode, and it gives the
cleanest bar of the seven. What it gives up is the affordance: nothing says "press here", and the
ripple needs an explicit shape because there is no container to clip it to. **C is F with the wallet's
chip removed**, so the two are one edit apart in either direction - a safe pair to decide between on
device rather than on a screen.

**Explicitly rejected: D - the gradient ring.** Not on contrast, which it wins outright (10.39:1 and
7.54:1, the best pair in the sketch), but on three things contrast does not see: it is a lone
secondary action wearing the app's signature, which the standing CTA rule refuses in as many words;
the app is moving away from gradient edges this week, not toward them; and at 1.5 px it does not even
look like what it costs. Plus the component that appears to already do it buries the ink splash, so D
is new code as well.

**A - hairline as shipped** is third and the safe fallback: zero risk, zero new code, passes without
an argument, one class name away if F's split reads as inconsistency on device. **B - filled, no
border** is fifth, the middle that buys nothing: a container you can barely see doing none of the
identifying while the glyphs quietly do all of it. **E - borderSubtle** is last and was drawn on
purpose, because it is the edit that will otherwise be proposed later by someone reasonable on the
grounds that it looks calmer - which it does, at 1.36:1.

**I would ship F.**

## If F ships

| File | Change |
| --- | --- |
| `lib/components/overlay/mobile_header.dart` | `WalletPill` keeps its `Material` / `StadiumBorder` / `borderControl` decoration **unchanged** and loses the name `Flexible`, the `space2`, the caret and the trailing `space4`; the leading `space3` becomes symmetric padding around the 32 px avatar in a 44 px box. The hamburger is a new sibling with no decoration at all, `space6` to its right. `kWalletPillMaxWidth` is deleted |
| `lib/components/cards/gw_gradient_border_card.dart` | **untouched** - only D would have needed it, and D does not use it |
| tokens | **none added.** F uses `surfaceMenu`, `borderControl`, `textPrimary` and `space6`, all already imported by the header |
| `mobile_header_brand_and_pill_test.dart` | a test that the two hit boxes are both 44 x 44 **despite the different decorations** - the one assertion this sketch adds that 181 could not, because before there was only one treatment to assert about |

Still owned elsewhere and **not decided here**: which four destinations stand on the bottom bar once
`More` leaves (`182-bottom-nav-destinations`), and what is drawn inside the wallet disc - the monogram
from `181-E` is used throughout and is not reopened.

## Provenance

Tokens verbatim from `lib/theme/gw_colors.dart`, `genius_wallet_colors.dart` and
`genius_wallet_consts.dart`; gradients from `genius_wallet_gradient.dart`; the shipped recipe from
`lib/components/overlay/mobile_header.dart`; the gradient-border component from
`lib/components/cards/gw_gradient_border_card.dart`. Networks verbatim from
`assets/json/networks/networks.json`. Phones are 390 x 844 at 1:1 with real shipping geometry: **60 px
app bar with its 1 px `borderStrong` bottom edge**, 60 px bottom bar, 64 px dock, 26 px overhang,
84 px slot - the controls are drawn on that real bar, not on a flat swatch, because the bar is 1.004:1
against anything else and a treatment judged on another background is judged against the wrong number.
Text advances carried over from 181's walk of the bundled Inter `hmtx` table. Contrast ratios computed
from the listed hex values with translucent edges composited first, not eyeballed.

Spacing: `space2`=4, `space3`=6, `space4`=8, `space6`=12, `space8`=16; **`space3`=6 is the one
documented exception to the 4-pt grid** and is not used by any treatment here - the only untokened
number in the sketch is D's **1.5 px** ring width, which is `GWGradientBorderCard`'s own
`borderWidth` default and is called out rather than smuggled.

The monogram rule from `181-E` is carried over verbatim, **address test first**: `0x7a3f...0d3f6e21`
renders **7A**, not **21**. The live output is printed under every phone, so the address test runs on
every render. Four wallet states plus **NO WALLET** are selectable, since the monogram behaves
differently in each.

`node --check` clean; whole-file div balance **0**; **4407** render combinations (5 wallet states x
2 icon faces x 2 touch-target states x 2 ruler states x 7 variants x 3 sheet states x 5 networks, plus
every static block) execute without error and each produces a div-balanced fragment.
