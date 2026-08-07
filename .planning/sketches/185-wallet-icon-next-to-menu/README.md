# Sketch 185 - a wallet ICON beside the menu icon: five treatments of the pair

http://localhost:8899/185-wallet-icon-next-to-menu/

Direct continuation of `183-wallet-hamburger-treatments`, whose scheme **F** shipped this afternoon and
is live in `lib/components/overlay/mobile_header.dart` right now.

## The request

Jakub, 2026-08-07, on device, immediately after walking the S7 header:

> One change he wants to make: just show a wallet icon next to the menu icon there - design a few
> treatments of those icons and send over 4-5 designs in HTML.

So the header's left control stops being the account avatar and becomes a generic **wallet glyph**
beside the menu glyph. Five whole treatments of that pair, plus the shipped bar for scale, all
interactive at 1:1 on the real 390 x 844 phone.

## The thing this change knocks out, before any pictures

Scheme F was not a taste call. It shipped on one specific argument, quoted from 183's README:

> the wallet icon holds a **value** - which wallet, and through the 16px badge which chain - and its
> content changes when that value changes. The hamburger holds nothing; it is a fixed door to a fixed
> list. **Making them match would invent a similarity that is not there.**

That asymmetry is the entire reason F beat 183's scheme A (both chipped) and scheme C (both bare), and
the shipped `HeaderMenuButton` doc restates it in the code, in capitals, precisely so the next reader
does not "tidy" it into a matching pair.

**Jakub's change removes the value.** A generic wallet glyph has identical pixels for every wallet,
every chain and every state but one. It is strictly *less* identifying than the avatar it replaces,
which at least varied by currency. Both controls become the same kind of object - a value-free door to
a sheet - so the similarity F said "is not there" **is now there**, and by F's own reasoning the pair
should match. That is 183 scheme **C**, both bare, the fallback Jakub reserved himself when he said
let's try 183F and fall back to 183C later if it turns out badly.

Schemes **A**, **B** and **E** here are that pair. **C** and **D** keep containers and have to earn them
on some other ground. Two are available and neither holds:

| Ground for keeping the chip | Why it fails |
| --- | --- |
| **Anchoring.** The hamburger is pinned to the screen edge by the 16px `actions` inset; the wallet floats with **135.94** of empty bar to its left, and a chip gives it a reference | The wallet is **12.00** from the hamburger. The two read as one anchored group, not as a floating mark beside a pinned one. Two bare glyphs at a 56px pitch are unmistakably a pair |
| **Consequence.** Switching wallets changes every number on screen; opening a menu changes nothing, so the wallet could earn more emphasis | In this bar the chip's fill is **1.11:1**, so the only visible part of a chip is its edge - and `borderControl`'s own doc defines it as *"the edge of a CONTROL whose fill cannot identify it"*, an **identification** token, not an emphasis one. A bare glyph already identifies at **19.29:1**, nearly six times the edge's 3.30:1. The chip buys emphasis with the wrong token, on the control that needs identification least |

There is one honest residual: the chip is where the **network badge** can live. That is a real argument
and it is the only thing keeping C on the page.

## What is lost, in one paragraph, because the decision should be made knowing it

With a generic glyph **nothing in the header says which wallet is live.** That is close to already true:
`AccountAvatar` paints `crypto/{currencySymbol}.png` on a flat `brandPrimaryStrong` disc - no per-wallet
colour, no blockie, no seed - so it identifies the **currency**, not the wallet, and two ETH wallets
render an identical header today (sketch 181, finding 1; the shipped `WalletPill` doc admits it in
sixteen lines). What changes is not the present, it is the **future**: the avatar could have recovered
the information at zero extra width, via sketch 181 scheme E's two-character monogram inside the same
32px disc. A generic glyph forecloses that, because there is no disc left to put a monogram in.

| Recovery path, after this change | What it recovers | Cost |
| --- | --- | --- |
| Do nothing. The `semanticLabel` still names wallet and chain, and the sheet is one tap | nothing visually; VoiceOver keeps everything | **free**, and it is the status quo for the chain already |
| Keep the badge (needs a container, so scheme C or D) | the chain, as a change-detector - by its own doc it says *the chain moved*, not which chain | 0 lines beyond picking C or D |
| A 6px chain-coloured dot on the glyph corner | the chain, at 1/7 the badge's area, without needing a container | roughly 10 lines, new geometry, untokened radius |
| Name the chain as text on the Assets header (sketch 180 scheme D) | the chain, **in words** - the only path that does | real work in another screen, and it is 3 taps away from News/Markets |
| Put the monogram back | which wallet | **undoes this change** - it needs the disc back |

He asked for icons, not a lecture, so that is the whole of it. The rest is the icons.

## The glyphs, opened and measured

Every mark in the sketch is the **real outline**: the Material glyphs are traced out of
`MaterialIcons-Regular.otf` in the pinned SDK, the SVGs are the repo files verbatim, the PNGs are the
files inlined as data URIs at their true pixel sizes. Nothing is a redraw and nothing is substituted.

Ink was measured by rasterising each outline at 960px on its own viewBox and counting opaque pixels,
then scaling back to the glyph's own grid. That is not fussiness: the first attempt used a signed-area
walk of the contours and reported the **filled** billfold as *lighter* than the **outlined** one, which
is impossible. Rasterising caught it.

| Asset | What it actually depicts | Ink | Viable at 24 in a header? |
| --- | --- | ---: | --- |
| `Icons.account_balance_wallet_outlined` | outlined billfold, card compartment, dot | **30.75%** | **yes** - and it is already the Assets tab, the More sheet Accounts row and two empty states |
| `Icons.person_outline` | outlined bust | **17.79%** | **yes** - and unused anywhere in the phone shell |
| `Icons.menu` (the pair's other half) | three bars, bbox 18.00 x 12.00 | **18.75%** | shipped at 18 |
| `walleticon.svg` 18x18 | **solid** billfold, artwork edge to edge, cut lip, clasp slot, fill hardcoded `#FFFFFF` | **88.77%** | only if you want the wallet to dominate - see below |
| `navwalletbuttoncustom.svg` 18x18 | **solid** card-stack, filled with **a third gradient** #00A9FE to #00F4A8 | **74.59%** | no - see below |
| `navwalletbuttonactive.png` 18x18 | the same card-stack, white, rasterised | 72.8% opaque | **no** - no @2x/@3x anywhere in the repo |
| `navwalletbuttoncustom.png` 16x16 | the card-stack silhouette, hardcoded `#43444B` | 78.9% opaque | **no** - 4.5x upscale at 24pt on a 3x iPhone |
| `navwalletbuttoncustom2.png` 16x16 | **not a wallet** - three bars and a side rail, i.e. a *list* mark, `#43444B` | 63.3% opaque | **no** |
| `copywalletsymbol.svg` 14x16 | **not a wallet** - two stacked documents, i.e. a *copy* glyph. The filename lies | 30.03% | n/a |
| `profileicon.png` 33x33 | person bust, hardcoded `#43444B` | 51.2% opaque | **no** - `Icons.person_outline` is the same idea, vector and tintable |

### "Reuses a shipping asset" is worth less here than the rule assumes

The standing rule is that a treatment reusing a shipping asset beats one needing a new export. Here it
is **weaker than it looks**, and one grep is the reason: `walleticon.svg`, `navwalletbuttoncustom.svg`,
`navwalletbuttoncustom.png`, `navwalletbuttoncustom2.png`, `navwalletbuttonactive.png`,
`copywalletsymbol.svg` and `profileicon.png` are declared in `pubspec.yaml` and referenced by **zero
Dart files**. They ship in every build and are drawn by nothing. "Reuse" means adopting art nobody has
ever seen on a screen, not continuing something the app already does.

What **is** worth reusing is the Material set, which is genuinely in service, plus
`lib/components/gw_icon.dart` - the house wrapper that exists so call sites stop mixing `Icons.*`,
`SvgPicture.asset` and `Image.asset`. It already applies a `ColorFilter`, so the hardcoded white fill in
`walleticon.svg` is a one-liner, not a blocker:
`GWIcon.svg('assets/images/walleticon.svg', size: 13.5, color: gw.textPrimary)`.

Two colour facts that would otherwise be found on device: the three greyscale PNGs are hardcoded
`#43444B`, which measures **1.99:1** on the bar and is invisible untinted; and
`navwalletbuttoncustom.svg`'s gradient is neither `brandCta` (#0AD89C to #0AAEE6) nor `brandBorder`
(#14C8FF to #5BFFD0). It is a **third** gradient nothing else in the app uses.

### The trap: `Icons.wallet_outlined` is not outlined

The obvious move - a Material glyph that says wallet and does not collide with the Assets tab - is
`Icons.wallet_outlined`, which exists in the pinned SDK at `0xf0724`. Extracting both glyphs from the
shipped font and comparing shows `Icons.wallet_outlined` and `Icons.wallet` are the **same 330-character
path, byte for byte**, both rendering a solid 40.85%-coverage mark. There is no outlined variant of that
glyph in the font. Recorded so it is not proposed later as new.

## Optical weight: the pair is what is being designed

A 24px outlined wallet beside a 3-bar hamburger can look mismatched at identical box sizes, so the
sketch carries two match modes and you can flip between them live.

| Mode | `Icons.menu` | billfold | person | `walleticon.svg` |
| --- | ---: | ---: | ---: | ---: |
| **BOX** - one nominal size | 18 | 18 | 18 | 13.5 |
| ink area, px² | 60.75 | 99.65 | 57.63 | 161.78 |
| **INK** - one ink area (geometric mean 77.80 px²) | 20 | 16 | 20 | 9 |
| ink area, px² | 75.00 | 78.73 | 71.15 | 71.90 |

Both INK sizes for the Material pair land on the 4-pt grid - menu 20, wallet 16 - which is luck rather
than design and is stated as such. `walleticon.svg`'s **13.5** in BOX mode is the one untokened value in
the sketch, and its reason is exact: the asset has no 24-grid padding, its artwork runs edge to edge, so
its nominal size *is* its ink size, and 13.5 is `Icons.menu`@18's ink width. Sizing it at 18 would make
its ink box 33% wider than the hamburger's.

**The rule this sketch arrives at: match CLASS first, then bounding box, then area.**

1. **Class.** Two Material outlines at one nominal size have the **same stroke by construction** - 2
   units on the 24 grid, 1.50px at 18. Nothing is measured, nothing is nudged, nothing drifts if the
   size changes later. Every non-Material wallet mark here breaks that and must be matched by hand.
2. **Bounding box.** `Icons.menu` is 18.00 x 12.00 on the grid - a wide flat mark that can never match a
   square wallet mark on height. That is idiomatic and not a defect: SF `line.3.horizontal` is 17 x 11
   in a 20 box. Match the **width** and the stroke, not the height.
3. **Area.** Useful only within a class. A solid mark and a stroke mark cannot be area-matched at any
   sensible size: to carry `Icons.menu`@18's ink, `walleticon.svg` would render at **8.27px**. Flipping
   the sketch to INK mode drives it to 9 and shows exactly that. It is the proof, not a bug.

By that rule the best-balanced pair on the page is **E** (person 57.63 against menu 60.75, **5.1%
apart**, stroke-matched, bbox 12.02 against 13.50) and the worst is **B**.

## Contrast, computed and composited

WCAG 2.x sRGB relative luminance. **Translucent edges are composited over `surfaceElevated` #0C0E14
first, then measured against it** - measuring raw white before compositing reports 19.29:1 for a 12%
border, which is how a failing edge gets shipped. Threshold **3:1**, WCAG 2.2 1.4.11.

| Element | Composited | vs the bar | 3:1 |
| --- | --- | ---: | --- |
| `textPrimary` #FFFFFF glyph - **every bare scheme, both controls** | - | **19.29:1** | **PASS** |
| `borderControl` white 36% edge - C's and D's chips | `#636569` | **3.30:1** | **PASS** |
| `surfaceMenu` #171A21 fill - **the load-bearing fact, re-verified** | `#171A21` | **1.11:1** | **fail** |
| `borderStrong` white 24% - the bar's own bottom edge, shipped knowingly | `#46484C` | **2.11:1** | fail |
| `borderSubtle` white 12% | `#292B30` | **1.36:1** | fail |
| `brandPrimaryStrong` #0AAEE6 disc - Now, and every scheme's NO WALLET state | - | **7.54:1** | **PASS** |
| `textOnBrand` #000B18 on that disc | - | **7.74:1** | **PASS** |
| `#43444B` - the three greyscale PNGs, untinted | - | **1.99:1** | fail |
| `walleticon.svg` at its own `#FFFFFF` | - | **19.29:1** | **PASS** |

`surfaceMenu` on `surfaceElevated` is **1.11:1** exactly as 183 measured it, `surfaceSunken` is
**1.04:1** and `surfaceBase` **1.01:1**. **A fill still cannot identify a control in this bar**, which is
why removing the chip costs nothing in contrast and removing the *glyph* would cost everything.

Badge ring (`surfaceElevated` against the chain colour), all five networks: Ethereum **5.23:1**, Polygon
**3.66:1**, Super Genius **10.39:1**, BNB **10.91:1**, Base **3.35:1**. All pass, unchanged from today.

One footnote worth having: `borderControl` composited measures **2.98:1** against `surfaceMenu`, its own
fill. It clears 3:1 against the **bar**, which is the direction 1.4.11 asks about, but the inner side is
0.02 short. Not a failure, and not something to fix by darkening a fill that identifies nothing.

## The network badge: it survives exactly where there is a container

Every treatment is drawn with the badge **on and off**. The judgement is the same in all of them and it
ties the badge question to the container question:

- **With a container (Now, C, D)** the 16px disc sits at the bottom-right of the 44px ring - the oldest
  badge position there is - and reads as attached. **D hosts it best**, because both rings make the
  pattern obvious.
- **With no container (A, B, E)** there is nothing for it to hang off. It lands in empty bar roughly 10
  to 14px from the glyph's ink and reads as a **third object beside two icons**, not as a badge on one.
  In those schemes I would drop it, and chain identity goes to the recovery table above.

## Touch targets

Every treatment ships **44.00 x 44.00** on both controls regardless of decoration, and the sketch draws
the overlay on the real bounds so it is checkable rather than asserted. That is the one assertion 181
could not make, because before F there was only one treatment to assert about. Ink separation moves by a
factor of 2.6 across the set - **12.00** in D, **25.00** in C, up to **31.00** in the bare pairs - while
the touch geometry never moves at all.

## Geometry, held to the pixel in all six

| Held constant | Value |
| --- | ---: |
| title Row at 390pt - `AppBar` charges `titleSpacing` on **both** sides | **342.00** |
| `BrandLockup`, mark 28 / wordmark 18 | 106.06 |
| wallet control | 44.00 x 44.00 |
| gap, `space6` | 12.00 |
| menu control | 44.00 x 44.00 |
| **cluster** | **100.00** |
| free space left in the title Row | 135.94 |

342 and not 358, because `NavigationToolbar` lays its middle slot at
`width - leading - trailing - middleSpacing * 2`. Both controls stay in `title` and not in `actions`: in
`actions` the title Row drops to 246.00 and the BRAND becomes the thing that shrinks under Dynamic Type,
which is backwards. Because the geometry is frozen, **a difference you can see in this sketch is a
difference in the pair.**

## The five treatments

| | Wallet glyph | Wallet | Menu | Badge reads? | New asset? |
| --- | --- | --- | --- | --- | --- |
| **Now** | `AccountAvatar` 32 + badge | chip | bare | yes | shipped |
| **★ A** | `Icons.account_balance_wallet_outlined` @18 | **bare** | bare | no, it floats | none |
| **B** | `walleticon.svg` @13.5 | **bare** | bare | no, it floats | none (but 0-ref) |
| **C** | `Icons.account_balance_wallet_outlined` @18 | chip | bare | **yes** | none |
| **D** | `Icons.account_balance_wallet_outlined` @18 | chip | **chip** | **yes, best** | none |
| **E** | `Icons.person_outline` @18 | **bare** | bare | no, it floats | none |

### A's cost, named rather than waved away

`Icons.account_balance_wallet_outlined` is **already the Assets tab** on the bottom bar
(`nav_destinations.dart`:153), and that file's own comment justifies the reuse on the grounds that *"the
two are never adjacent - one is on the bar, the other is a sheet away"*. Under A they are **not** a sheet
away: both are on screen at once, meaning two different things. The sketch draws the real bottom bar
underneath every phone specifically so this is judgeable at size rather than argued about.

My reading: a **cost, not a defect**. The header mark is 18px and unlabelled at the top right; the tab
mark is 23px with the word **Assets** under it at the bottom. They also mean adjacent things - your
holdings, and the wallet those holdings sit in - so a shared glyph reads as a family rather than as an
error. But it is why A is not free, and if it grates on device the fix is one word (`E`), not an export.

### D's defect, unchanged from 183

Two identical 44px stadiums 12px apart at a 56px pitch read as a **segmented control** - one object with
two halves - rather than as two objects. D also re-adds exactly what F deleted: `HeaderMenuButton` needs
a `Material` / `StadiumBorder(borderControl)` wrapper, and the class doc that currently forbids this in
four paragraphs has to be rewritten.

## Recommendation

**★ Ship A - both bare, on the app's own outlined billfold.** It is the pair the expired argument points
to, it is the fallback Jakub already reserved, and it wins on three grounds that survive the change.
**Contrast:** both identifiers sit at **19.29:1**, nearly six times the 3.30:1 edge it deletes, and
neither depends on the 1.11:1 fill - the header gets *more* identifiable by having less paint on it.
**Optics:** both marks come off the same Material 24 grid, so their strokes are identical **by
construction** at 1.50px, with nothing to tune and nothing to drift; every other wallet mark here has to
be matched by hand. **Cost:** no new token, no new component, no new asset, about six lines. Its one real
cost is the duplicated Assets-tab glyph, stated above and judged survivable.

**Runner-up: C - keep F's chip, put the generic glyph inside it.** Not because the argument holds - it
does not, and the sketch says so in two rows of a table - but because C is **one edit from A in either
direction** and it is the only realistic home for the network badge. If Jakub wants chain identity to
stay in the bar, C is the honest answer and A is not. C and A are a safe pair to decide between on
device rather than on a screen, which is exactly how 183's C and F were framed.

**Explicitly rejected: B - `walleticon.svg`.** It looks like the "reuses a shipping asset" winner and is
not one. It has **zero Dart references**, so it is bundled art nobody has ever seen rendered, which is
not the same thing as continuity. And it fails on measurement rather than taste: **88.77%** ink coverage
against `Icons.menu`'s **18.75%** means a solid mark beside a stroke mark, matchable only by bounding
box, still reading roughly four times heavier, and area-matchable only at an absurd **8.27px**. Rejected
because the number says so, not because it looks wrong.

**D - the chip pair** is fourth: it is the most obvious "these are two buttons" affordance and the best
home for the badge, and it pays for both with 183's segmented-control read plus ten lines that undo F.
**E - the person mark** is the most interesting near-miss and is filed rather than ranked: it is the
best-balanced pair on the page (5.1% ink apart, stroke-matched, unique in the shell, no new export) and
it is the only option that solves all three of A's constraints at once. It loses on meaning, not on
measurement - the sheet behind it is `AccountDrawer.show(context, includeNetwork: true)`, wallets and
chains, and a person mark promises a profile this app does not have. It is also not what was asked for:
the words were *"pokazal wallet icon"*.

**I would ship A.**

### The cheapest diff against the code that shipped today

**C, at three lines** - and cheapest is not the same as recommended.

| Scheme | Diff |
| --- | --- |
| **C** | **3 lines** in `WalletPill`. Only the child changes; the `Material` / `StadiumBorder` / `borderControl` decoration stays byte for byte |
| **★ A** | **about 6 lines** in `WalletPill`. Drop `color`, `shape` and `clipBehavior` from the `Material` - keep the `Material` itself with `color: Colors.transparent, shape: const CircleBorder()` so the ripple still clips round - and swap the `Padding` + `AccountAvatar` child for `Icon(Icons.account_balance_wallet_outlined, size: 18, color: gw.textPrimary)`. `HeaderMenuButton` untouched |
| **E** | **as A**, with a different `IconData` |
| **B** | **about 7 lines**: as A, but the child is `GWIcon.svg(...)` plus one import. `flutter_svg` is already a dependency |
| **D** | **C plus about 10 lines** in `HeaderMenuButton`, which regains the wrapper F deleted |

**The cost none of those line counts contains, and it is the real work.** Three doc comments in
`mobile_header.dart` currently state F's rationale **as fact**: `WalletPill`'s class doc, the `Material`
comment inside it, and `HeaderMenuButton`'s "THE SPLIT IS THE WHOLE OF SCHEME F" block. All three become
false the moment the avatar leaves. Rewriting them is how this change is actually finished, and leaving
them is precisely how the next reader restores a border on an argument that expired.

Unchanged in every scheme, and it must be: the `semanticLabel` block. It is the only place in the header
that names the wallet or the chain in words, and it becomes **more** load-bearing once the avatar goes,
not less. Also unchanged: `_NoWalletAvatar`. Whether a wallet exists at all is the one piece of
information a generic glyph still carries, and the sheet it opens is where `Add Wallet` lives - so all
five schemes keep the brand disc with the `+` for that state, and the sketch's wallet picker includes
**NO WALLET** so it can be checked.

Still owned elsewhere and **not decided here**: what the More sheet contains (`184-menu-page`), which
four destinations stand on the bottom bar (`182-bottom-nav-destinations`), and whether the monogram from
`181-E` ever ships - this sketch only records that a generic glyph forecloses it.

## Provenance

Shipped code read directly, not described: `lib/components/overlay/mobile_header.dart` (the live scheme
F), `lib/account/account_drawer.dart` (`AccountAvatar` and the 16px badge with its 2px ring),
`lib/components/overlay/nav_destinations.dart` (the Assets tab glyph, `kMobileNavIconSize` = 23),
`lib/components/overlay/responsive_overlay.dart`, `lib/components/gw_icon.dart` (the house icon wrapper),
`lib/components/wallet_type_icon.dart` (`FontAwesomeIcons.wallet` at 20). Tokens verbatim from
`lib/theme/genius_wallet_colors.dart` and `lib/theme/gw_colors.dart`; the `borderControl` doc quoted from
its own source. Networks verbatim from `assets/json/networks/networks.json`. Asset inventory from
`lib/assets/images/`, cross-checked against `pubspec.yaml` and against a grep of every `.dart` file.

Material outlines extracted from `MaterialIcons-Regular.otf` in the pinned Flutter SDK with `fontTools`
and emitted as 24-grid SVG paths, so the glyphs on the page are the shipping glyphs. Repo SVGs traced
verbatim from the files. The three rasters are the files themselves, inlined as data URIs at 18x18,
16x16 and 33x33 so the page is self contained and the resolution ceiling is visible rather than claimed.
Ink areas measured by rasterising at 960px and counting opaque pixels.

Phones are 390 x 844 at 1:1 with the real shipping bar - **60px app bar with its 1px `borderStrong`
bottom edge**, the real bottom bar and dock - because the bar is 1.01:1 against anything else and a
treatment judged on another background is judged against the wrong number. No scaled thumbnails and no
swatch-on-flat-background anywhere.

Spacing: `space2`=4, `space3`=6, `space4`=8, `space6`=12, `space8`=16; **`space3`=6 is the one documented
exception to the 4-pt grid**. The only untokened number in the sketch is `walleticon.svg`'s **13.5** in
BOX mode, whose reason is stated above rather than smuggled.

`node --check` clean on the single `<script>` block; whole-file `<div>` balance **0**; **3200** render
combinations (5 wallet states x 5 networks x 2 badge x 2 weight modes x 2 touch-target x 2 ruler x 8
tabs) execute without error and every one produces a div-balanced fragment; 12 sheet states likewise.
All eight panes and all six phones verified to render **distinct DOM** - the trap that made an earlier
sketch show five identical phones - with chip and bare counts asserted per scheme: Now 1/1, A 0/2,
B 0/2, C 1/1, D 2/0, E 0/2.
