# Sketch 180 - the mobile header: brand on the left, ONE wallet control on the right

http://localhost:8899/180-mobile-header-brand-and-wallet/

> **AMENDED 2026-08-07** by quick task `20260807-mobile-header-brand-and-wallet-pill`, which
> implemented scheme B. Three claims in this sketch were wrong and are corrected **in place**, each
> marked where it stands rather than quietly rewritten: the "blocking dependency" on a missing logo
> asset (the logo exists and already ships), `borderStrong`'s contrast ratio, and `surfaceMenu`'s
> ratio against the body. A sketch that was wrong and was corrected is more useful than one that
> looks like it was always right. The scheme comparison, the defect analysis and the recommendation
> all stand unchanged.

## The request

Jakub, 2026-08-07, verbatim:

> "chcialbym miec na homepage'u logo Genius w lewym gornym rogu z nazwa, moze Genius AI. Ten wallet
> przesuniety w prawa strone, a faktycznie tam tylko jedna informacja odnosnie walletu, bo teraz mamy
> i wybor sieci, i wybor walleta. Natomiast po klikniecu wtedy sie wszystko by rozwijalo. Musimy to
> chyba troszeczke zre-designowac, wiec zastanow sie jak najlepiej to zrobic i mi zaprezentuj."

Three asks in one sentence: a **brand mark plus a wordmark on the left**, the wallet control **moved
to the right**, and **one** wallet affordance where there are two today, with everything else
revealed on tap.

## What is in the code today

`_MobileHeader`, `lib/components/overlay/responsive_overlay.dart:559`. A real `AppBar`.

- `title:` an `InkWell` on the **left** - `AccountAvatar(size: 32)` plus a column of
  `wallet?.walletName ?? 'No wallet'` over `WalletUtils.getAddressForDisplay(wallet.address)` -
  opening `AccountDrawer.show(context)`.
- `actions:` `const [NetworkDropdownSelector(), SizedBox(width: space8)]`.

So **two** controls, the wallet one on the wrong side, and **no brand mark anywhere** in the phone
shell.

## ~~Blocking dependency: there is no logo asset in this repository~~ CORRECTED 2026-08-07

**This section was wrong, and not merely incomplete. The logo exists, and it has been shipping in
the desktop app bar the whole time.** Corrected by quick task `20260807-mobile-header-brand-and-wallet-pill`.

The original search looked in `assets/images/`. This repo uses the Flutter **package-style** asset
layout: `pubspec.yaml` declares `name: genius_wallet` and lists its own assets under
`packages/genius_wallet/assets/images/...`, which resolves to **`lib/assets/images/`** on disk. Code
loads them with `package: 'genius_wallet'`. Looking in `assets/images/` could only ever have come up
empty.

| File | Canvas | Opaque glyph | Already rendered at |
| --- | --- | --- | --- |
| `lib/assets/images/geniusappbarlogo.png` | 38 x 38 | **28 x 38**, x[1..28] y[0..37] | `responsive_overlay.dart` - the DESKTOP app bar |
| `lib/assets/images/logo_and_title.png` | 239 x 52 | **222 x 51**, x[2..223] y[1..51] | `screens/splash.dart:191`, `components/splash.dart:80`, `onboarding/view/wallet_creation_screen.dart:40` |

Both decoded and their alpha channels walked for the true opaque bounding box.

Two consequences the original drew from the false premise both collapse:

- Option 2, "the GNUS coin mark reused - wrong, it is a token mark", was answering a question that
  never needed asking. Nobody has to reuse a coin mark; the brand mark exists.
- The consistency worry is settled in the same stroke. The mark mobile should use is the mark
  **desktop has been using all along**.

Option 3, a mark drawn from the brand gradient in code, is dead too. Do not draw a square.

**The exact path to write:** `'assets/images/geniusappbarlogo.png'` with `package: 'genius_wallet'`.
That is the form all four existing call sites use. Do not guess a `lib/`-prefixed path; the declared
package name and the disk path differ on purpose.

### The real constraint: no high-density variants

There is **no `2.0x` or `3.0x` directory anywhere in `lib/assets/images/`**, for any asset. The
mark's opaque glyph is 28 x 38. So every render on a 3x iPhone is an upscale, and the factor depends
entirely on the height chosen:

| Rendered height | Physical px at 3x | Upscale from 38 rows | Verdict |
| --- | --- | --- | --- |
| 32 | 96 | 2.53x | too soft for line art this fine |
| 28 | 84 | 2.21x | still soft |
| **24 - shipped** | **72** | **1.89x** | the largest step under 2x |
| 20 | 60 | 1.58x | crisper, small beside a 15px wordmark |
| 16 | 48 | 1.26x | nearly clean, reads as an icon not a brand |

The mark is an intricate line drawing - a brain circuit inside a head profile - and intricate line
art shows upscaling far more than a solid shape would. A 114 x 114 export is a pure drop-in with zero
layout change, because the render height is fixed in code.

### The 9px right gutter

The opaque glyph ends at x=28 in a 38px canvas: **9px of transparent margin on the right, 1px on the
left.** Rendered raw at height 24 the box is 24 wide but the visible mark is only 17.7 and sits hard
against the left, so a nominal 8px gap renders as roughly 13.7px of visible air. This is why the
desktop code carries a hand-computed `SizedBox(width: 15)` with a comment explaining the same
problem. Mobile crops instead - `Align(widthFactor: 29 / 38)` - so the gap token stays honest.

### The wordmark string

**Resolved 2026-08-07: the wordmark is `GNUS.AI`.** Jakub first said `GeniusAI`, was shown that
`logo_and_title.png` bakes `GNUS.AI` on the splash and on wallet creation, and chose `GNUS.AI` so the
app carries one brand string. The header ships it as **live text** rather than as that image, because
the image has no high-density variant while text is crisp at any density, respects Dynamic Type, and
is read as text by a screen reader. Splash and wallet creation are untouched.

## The four schemes plus the current state

Each is a whole scheme, differing in **what the single right-hand control is**, not in pixel
placement.

| | The ONE thing on the right | Taps to the network list | Double-address defect | Long name |
| --- | --- | --- | --- | --- |
| **Now** | nothing on the right - wallet block left, network chip right, two controls | 1 | **inherits it** (name over address) | eats the whole bar |
| **A** avatar only | a 44x44 avatar button, no text at all; opens one "Wallet and network" sheet | 1 | **no** - zero text in the header | immune, fixed 44px |
| **★ B** wallet pill | avatar with a 16px network badge, the name, a caret; opens the same combined sheet | 1 | **halved** - name only, no address line | ellipsizes inside a 236px cap |
| **C** segmented pill | one pill, two halves: left opens Networks, right opens Accounts | 1 | no | immune, fixed 96px |
| **D** network leaves the header | a 44x44 avatar; network becomes a named chip next to the Assets total | 1 from Home, **3 from News/Markets** | no | immune, fixed 44px |

Every sheet either **is** the sketch-174 `AccountDrawer` (SDK Accounts / Your Accounts) or **extends**
it with a network block on top. No scheme invents a third wallet surface.

## The defect, designed around rather than rediscovered

The header prints the address twice on some wallets. Already diagnosed: no code derives a name from
an address - the wallet was **saved** with an address-shaped name through the free-text field at
`import_security_screen.dart:236` (`walletName: walletNameController.text`). SDK wallets never hit it,
`app_bloc.dart:616` names them `'Super Genius Wallet'` / `'Super Genius Wallet N'`.

Consequence: **any header showing a name and an address together inherits it; one line, or none,
sidesteps it.** The real fix is validation on that text field and it is not this sketch's job.

The state selector in the sketch carries all four cases: short name, very long name, address-shaped
name, and no wallet.

## Geometry, measured at 390pt

**Amended 2026-08-07.** The numbers below were budgeted against an uncropped 28px mark box and the
two-word string "Genius AI". Both assumptions changed in the plan's favour: the mark is cropped to
`24 x 29/38 = 18.3` and the string is `GNUS.AI`. Every width in the amended row was measured by
walking the bundled Inter TTF's `hmtx` advances, not estimated.

| Piece | Width | Note |
| --- | --- | --- |
| Bar content box | 358 | 390 minus 2x space8 |
| ~~Brand, mark + wordmark~~ | ~~~102~~ | superseded, see below |
| **Brand, cropped mark + `GNUS.AI`** | **90.2** | 18.3 mark + 8 gap + 63.9 wordmark at Inter Bold 15 |
| Brand, wordmark only | 63.9 | `GNUS.AI`, Inter Bold 15 |
| A / D control | 44 | 212 of slack |
| ~~B control~~ | ~~up to 236~~ | ~~**4px of slack**~~ - recomputed below |
| **B control, as shipped** | up to 236 | 90.2 + 12 + 236 = 338.2 of 358, **19.8px of slack** |
| C control | 96 | two 48x44 halves |

For the record, the wordmark candidates at Inter Bold 15: `GNUS.AI` 63.9, `GeniusAI` 66.8,
`Genius AI` 70.3. The 236 cap is still not optional - it is what stops a 350px address-shaped name
from eating the brand block - but it is no longer hanging over a cliff.

**Names the app generates itself never ellipsize.** At the 236 cap the name column is 160px, and
Inter SemiBold 14 gives `Super Genius Wallet` 137.4, `Super Genius Wallet 2` 149.7 and
`Super Genius Wallet 10` 156.1. The cap exists for pathological user input, not for normal use.

**App bar height discrepancy.** Drawn at 56 per the brief. The shipped code says `toolbarHeight: 60`
*and* `preferredSize = 60` in the same class. Every scheme fits either; whoever implements should pick
one number deliberately rather than inherit both.

## Contrast, computed from the real tokens

| Pairing | Ratio | Needs | |
| --- | --- | --- | --- |
| Wordmark `#FFFFFF` on app bar `#0C0E14` | 19.3:1 | 4.5:1 | pass |
| Wordmark in brand gradient, both stops | 10.4:1 / 7.5:1 | 4.5:1 | pass |
| **Secondary `#8A8F9D` on the app bar** - address line, the "AI", the caret | **5.97:1** | 4.5:1 | pass |
| brandPrimary `#14C8FF` on `#0C0E14` | 9.9:1 | 4.5:1 | pass |
| textOnBrand `#000B18` on the gradient, both stops | 10.7:1 / 7.7:1 | 4.5:1 | pass |
| Network glyph, Polygon `#8247E5` on `#0C0E14` | 3.66:1 | 3:1 (1.4.11) | pass, thin |
| Network glyph, Base `#0052FF` on `#0C0E14` | **3.35:1** | 3:1 (1.4.11) | pass, marginal |
| borderSubtle hairline (white 12% over `#0B0D12` = `#282A2E`) against the bar | **1.34:1** | 3:1 | **fail** |
| App bar `#0C0E14` against body `#0B0D12` | **1.004:1** | - | indistinguishable |

Two findings that outlive whichever scheme wins:

1. **The app bar has no visible edge.** `surfaceElevated` and `surfaceBase` are 1.004:1 apart - the
   same colour to any eye - and the only separator is a 0.5px hairline at 1.34:1. Today that barely
   matters because the header is a name in a corner. The moment a brand block anchors the top-left the
   bar becomes a *band*, and a band with no edge floats. ~~One line to fix: `borderStrong` (white 24%)
   lands at 2.6:1, or give the bar `surfaceMenu #171A21` at 2.9:1 against the body.~~

   **Both numbers in that last sentence were wrong. Corrected 2026-08-07**, recomputed from the real
   tokens by compositing each hairline over the surface it actually sits on:

   | Edge | Composite | Against the bar `#0C0E14` |
   | --- | --- | --- |
   | `borderSubtle` white 12% | `#282A2E` | **1.34:1** (the original was right about this one) |
   | `borderStrong` white 24% | `#46484C` | **2.11:1**, not 2.6:1 |
   | `borderControl` white 36% | - | **3.30:1**, agreeing with the token's own doc |

   | Surface pairing | Real ratio |
   | --- | --- |
   | `surfaceMenu #171A21` vs `surfaceBase #0B0D12` | **1.12:1**, not 2.9:1 |
   | `surfaceElevated #0C0E14` vs `surfaceBase #0B0D12` | 1.01:1 |
   | `surfaceSunken #06080C` vs `surfaceBase #0B0D12` | 1.03:1 |

   **The general finding, which outlives this sketch: no two dark surface tokens in this palette
   separate by even 1.2:1. A surface swap can never give a bar an edge. Only a line can.**

   What shipped: `borderStrong` at 1px, so 1.34:1 at 0.5px becomes 2.11:1 at 1px and the painted area
   doubles from 1.5 physical px at 3x to 3. 3:1 is unreachable here - white at 34% is the first step
   that clears it, and the token at 36% is `borderControl`, explicitly reserved by its own
   documentation as the CONTROL edge with decorative separators staying subtle. A bar's bottom edge
   carries no state, so it takes `borderStrong` and the app's own rule survives. `borderControl` goes
   on the pill, whose fill genuinely cannot identify it.
2. **The network is identified by picture alone.** `NetworkDropdownSelector.build` renders
   `Image.asset(iconPath)` at 20x20 plus a caret, and its `Tooltip` says *"Select network"* - the
   action, not the current value. No text anywhere names the chain you are on. That is 1.1.1 as much
   as 1.4.11, and it survives untouched in Now, B and C. Only **D** fixes it. **Lift D's naming fix
   into whichever scheme wins.**

## Recommendation

**★ Ship B - the wallet pill with the network badged onto the avatar.** The only scheme that
satisfies all three halves of the request at once: brand on the left, **one** object on the right,
**one** tap that expands everything. Keeps the wallet name in the chrome, which A and D throw away.
Keeps network switching at today's tap count. Half-fixes the double-address defect for free by
dropping the address line. Two conditions, both cheap: cap the pill at 236px with ellipsis (4px of
slack, not optional), and name the network in the sheet it opens.

**Runner-up: A - avatar only.** The purest reading of the brief and the only scheme *structurally*
immune to every text problem here - no name, no address, no overflow, no double-print, whatever
anyone types into that free-text field. Pick A the moment Jakub says the name is noise, or the moment
the brand block grows and B's 4px of slack goes negative. A is also the better answer for a
single-wallet user, which is most users.

**Explicitly rejected: C - the segmented pill.** It looks diplomatic and is the smallest diff, which
is exactly why it needs naming rather than quietly shipping. Jakub's complaint was *"teraz mamy i
wybor sieci, i wybor walleta"* - two choosers. C still has two choosers wearing one border. It also
puts two 48px targets side by side in the top-right corner, the least accurate place a thumb reaches
on a 390pt phone, trading a design complaint for a mis-tap.

**On D**, which I like more than its ranking suggests: it is the only scheme with a real argument
about *where the network belongs* - next to the balances it silently rewrites, absent from News and
Markets where the chain means nothing - and the only one that names the network in text. Not
recommended because it is the largest diff (three placements instead of one, the only scheme editing
a screen other than the header) and because it makes switching 3 taps from News and Markets. If Jakub
decides the network is a per-screen concern, D is right and B is wrong. That is a product call.

## If B ships

| File | Change |
| --- | --- |
| `responsive_overlay.dart` `_MobileHeader` | `title` becomes the brand block, `actions` becomes the single pill, `NetworkDropdownSelector` leaves the header |
| `account_drawer.dart` | a Network section prepended above the two 174 sections; those sections untouched |
| `network_dropdown_selector.dart` | its drawer body is reused inside that section; only the collapsed header chip stops being mounted |
| `AccountAvatar` | gains an optional network badge, additively - it already serves both the drawer rows and the collapsed chip |
| a brand asset | **blocked on Jakub.** Ships as WORDMARK ONLY until it lands |

## Provenance

Tokens verbatim from `genius_wallet_colors.dart` / `genius_wallet_consts.dart`. Phones are 390x844 at
1:1 with real shipping bar geometry (56px app bar per the brief, 60px bottom bar, 64px dock, 26px
overhang, 84px slot). `shortAddr()` mirrors `WalletUtils.getAddressForDisplay` (first 6, ellipsis,
last 4). Contrast ratios computed from the listed hex values, not eyeballed. `node --check` clean;
whole-file div balance 0, and all 1200 render combinations (5 schemes x 4 wallet states x 3 brand
modes x 4 sheet states x 5 networks) execute without error and each produces a div-balanced fragment.
