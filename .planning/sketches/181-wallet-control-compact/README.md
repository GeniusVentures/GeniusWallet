# Sketch 181 - the wallet control is too wide: six ways to give the bar its pixels back

http://localhost:8899/181-wallet-control-compact/

Follows sketch 180, whose scheme B shipped this morning as
`lib/components/overlay/mobile_header.dart`. This sketch is about the one thing 180 got wrong by
omission: how much of the bar that pill eats.

## The request

Jakub, 2026-08-07, on device:

> He would still reconsider how the wallet on the right is presented, because he does not really
> like it. Prepare 4-5 designs of how you would handle it. Maybe a wallet icon and then everything
> expands, or some shorter form, because right now it takes up half the screen, which he is not
> happy with.

Jakub, later the same day, a new direction that arrived mid-build and is now scheme F:

> Try putting a wallet icon in the top-right corner, or something similar in a shorter form, with
> the hamburger menu next to it. And then, instead of 'more' at the very bottom, we could put
> something like 'news'.

## He is right, and he is under by seven points

The complaint is width. It is arithmetic, and it can be checked.

| Piece | Width at 390pt | |
| --- | ---: | --- |
| Bar | 390.00 | |
| `titleSpacing`, charged on **both** sides | -32.00 | `NavigationToolbar` lays the middle slot at `width - leading - trailing - middleSpacing * 2` |
| `actions` | -16.00 | one `SizedBox(width: space8)` |
| **title Row** | **342.00** | not 358 |
| `BrandLockup` at mark 28 / wordmark 18 | -106.06 | 21.37 mark (`29/38 * 28`) + 8 gap + 76.69 `GNUS.AI` at Inter Bold 18 |
| `space6` | -12.00 | |
| **Left for the pill** | **223.94** | vs the declared `kWalletPillMaxWidth` of 236 - **the cap no longer binds** |

**223.94 px is 57.4% of the bar.** Every width in this sketch was derived by walking the bundled
Inter TTF's `hmtx` advance table (`assets/fonts/Inter-*.ttf`), not estimated. At the previous 24/15
lockup the pill had 239.77 available and the 236 cap did bind; the brand growing this morning is
what pushed it over.

Because the number is the whole design problem, **it is printed under every phone in the sketch**
and drawn as a ruler across the bar itself.

## Three code-grounded findings, two of them new

### 1. The avatar is not a wallet identity. It is a currency icon.

`AccountAvatar.build` (`lib/account/account_drawer.dart:602`) paints a `CircleAvatar` with
`backgroundColor: brandPrimaryStrong` and a child of
`Image.asset('assets/images/crypto/${wallet.currencySymbol.toLowerCase()}.png')`. No per-wallet
colour, no blockie, no seed. **Two ETH wallets render the same pixels.**

This is not a nuance, it decides the sketch. "Just show the avatar" is not a smaller version of
"show the name" - on a multi-wallet device it conveys nothing at all. Every icon-only scheme is
tested against it in a live proof block: three wallets, all on Ethereum, drawn at the real 44 px.

### 2. The pill can print the same picture twice - the double-icon defect

The 32 px circle draws `crypto/{currencySymbol}.png`. The 16 px badge draws `network.iconPath`,
which for Ethereum in `assets/json/networks/networks.json` is `assets/images/crypto/eth.png`. For an
ETH wallet on Ethereum - the default state of this app - **those are the same file**, rendered 3 px
apart at two sizes. 224 px spent to say "Ethereum" twice and a name once.

### 3. The double-address defect, and a sibling in the same file

Wallets imported through the free-text field at `import_security_screen.dart:236`
(`walletName: walletNameController.text`) can carry an address as their name. The shipped header
already halved this by printing the name only; any scheme that reintroduces a name **and** an
address together brings it back at full strength, which is exactly what scheme D's expanded row
does.

Noted for a todo, not fixed here: `account_drawer.dart` decides which row is selected with
`w.walletName == _selectedWallet?.walletName`, so two wallets sharing a name both highlight. **Names
are not identity anywhere in this app**, which is the thread running through all six schemes.

## The six schemes

Every one is judged on width first. `space6` = 12, `space4` = 8, `space3` = 6 (the one documented
exception to the 4-pt grid).

| | The control | Width at 390pt | % of bar | Knowable without tapping | Wallet / network taps | Double-address |
| --- | --- | ---: | ---: | --- | --- | --- |
| **Now** | avatar + name + caret | 139.02 - **223.94** | 35.6 - **57.4%** | which wallet (until it ellipsizes), which chain by a 16 px badge | 2 / 2 | halved |
| **A** | a bare 44 x 44 avatar | **44.00** | 11.3% | **neither** - and provably, see finding 1 | 2 / 2 | no |
| **B** | avatar + name clamped to 84 px, no caret | **138.00** fixed | 35.4% | which wallet, badly; which chain by badge | 2 / 2 | leaks |
| **C** | avatar + the chain NAME, clamped to 88 px | **142.00** fixed | 36.4% | **which chain, in words** - a first for this app; not which wallet | 2 / 2 | no |
| **D** | 44 px icon that expands in place, then the sheet | 44.00 / **342.00** | 11.3 / **87.7%** | nothing at rest, everything expanded | 2 / 2 | **yes, it returns** |
| **★ E** | 44 x 44 with a 2-character **monogram** in the circle | **44.00** | 11.3% | **which wallet AND which chain** | 2 / 2 | **no, and it improves on it** |
| **★ F** | wallet icon + hamburger, 12 px apart | **100.00** | 25.6% | whatever you put in the left icon | 2 / 2 | no |

All six clear the 44pt floor. All six leave wallet and network switching at today's 2 taps, because
all six open the same `AccountDrawer.show(context, includeNetwork: true)` that shipped this morning.
**No scheme invents a third wallet surface.**

### What each answer actually costs

The table that makes the recommendation almost automatic:

| Question | Cheapest honest answer | Cost at 390pt |
| --- | --- | ---: |
| Which wallet? | a 2-character monogram inside the existing circle | **0 px** |
| Which wallet, by its real name? | an 84 px text column | 94 px, and it still collapses `Super Genius Wallet 1` and `2` to the same string |
| Which chain? | the 16 px badge already on the avatar | **0 px** |
| Which chain, by name? | an 88 px text column | 98 px, and every testnet name still ellipsizes |
| Reach the sheet | a 44 px target | 44 px |
| Reach the app's other destinations | a second 44 px target beside it | 56 px, and it frees a bottom-bar slot |

Both things the header must say can be said for nothing, inside pixels already spent. Every text
column costs about 95 px and none of them finishes the job it was bought for.

### The measurement that kills B

An 84 px column at Inter SemiBold 14 holds 70.62 px of glyphs before the ellipsis.
`Super Genius Wallet 1` (146.88) and `Super Genius Wallet 2` (146.88) **both render as
"Super Ge..."**. B pays 94 px more than E to keep the name, then fails on precisely the wallets a
name exists to disambiguate - the ones `app_bloc.dart:616` generates. Separating them needs a 150 px
column, which puts the control back at 224.

### The measurement that kills C

`networks.json` holds ten networks, six of them testnets. The widest mainnet name is
`Super Genius` at 84.53, which is why C's column is 88. Every testnet ellipsizes, and
**`Super Genius - TestNet` measures 147.28**, needing a 223 px control - exactly today's width.
Naming the chain in the header costs the same as naming the wallet.

C noticed a real gap: the chain has only ever been a picture, and `NetworkDropdownSelector`'s tooltip
said "Select network" - the action, not the value. **Lift that finding into the winner and pay for it
elsewhere**: the chain is already named on the sheet's chips and in the control's semantic label,
which is 0 px and reaches screen readers too.

### Scheme E's monogram rule, and the bug in it

Deterministic, no storage, never prints an address:

1. address-shaped -> the two characters after `0x`, uppercased. `0x7a3f...` -> **7A**
2. name ends in 1-2 digits -> first letter plus those digits. `Super Genius Wallet 1` -> **S1**
3. two words or more -> the initials. `Main wallet` -> **MW**
4. one word -> its first two letters. `Savings` -> **SA**

**The order is load-bearing and it was a bug on the first pass of this sketch.** An address ends in
hex, which is very often two digits, so with 1 and 2 the other way round
`0x7a3f9b2c...0d3f6e21` renders as **21** - an address fragment in the one header that is supposed to
be incapable of printing one. Fixed, and the fix is recorded because the next person will write the
rules in the obvious order.

Fit: widest possible output `WW` at Inter Bold 12 is 24.90 px inside a 32 px circle (3.55 px each
side); the longest real output, `S10`, is 21.12. Contrast: `textOnBrand` #000B18 on
`brandPrimaryStrong` #0AAEE6 is **7.74:1**.

## Scheme F in detail, because it arrived last and may win

**100.00 px of control: `44 + space6 12 + 44`, 25.6% of the bar.** Second-narrowest here and less
than half of today's 223.94.

**Read the accounting honestly.** The wallet control in F is 44 px, the same as A and E. The extra
56 px is not buying wallet information - it is buying back a bottom-bar slot. F is therefore
*A-or-E plus a hamburger*, and it inherits whichever icon you put in the left target: with the
shipped coin avatar it cannot say which wallet is live, with E's monogram it can. The sketch has a
global **WALLET ICON** toggle so the two can be compared in place; the difference is the whole
argument for F.

**What the hamburger opens, and how the split is kept visible.** The wallet icon opens
*Wallet and network* (network chips, SDK Accounts, Your Accounts). The hamburger opens the existing
`_MoreSheetBody` - News, Web, Feedback, Settings. Both sheets are drawn in the mock so the split can
be read rather than assumed.

**Two dependencies, both real:**

1. **The bottom bar must give up `More`**, or the hamburger and the More slot are the same menu in
   two places. What replaces the freed fourth slot is **not decided here** - Jakub's suggestion is
   `News`, and that question belongs to **`182-bottom-nav-destinations`**. The phone in tab F draws
   News in the slot purely as an illustration of the dependency, not as a recommendation. F must not
   ship while `More` is still in the bar.
2. **The `Accounts` row inside `_MoreSheetBody` has to go.** It exists today
   (`responsive_overlay.dart`, `_MoreSheetBody`, a `GWSelectRow` titled "Accounts" with the subtitle
   "SDK accounts and your wallets"). Leaving it means two icons 12 px apart both reach the accounts
   drawer. Open the hamburger in the sketch and look at the struck-through row.

**Touch geometry.** Two 44 x 44 targets **12 px apart**, centres 56 px apart. `space4` = 8 also
clears Apple's minimum but puts the centres 52 apart in the top-right corner, the least accurate
place a thumb reaches on a 390pt phone. 12 costs 4 px. Sketch 180 rejected its scheme C partly for
this exact geometry; F survives it because its two targets are visually unlike (a filled circle and
three lines) and open obviously different sheets, so a mis-tap is recoverable rather than confusing.

**Where the two icons must live in the widget tree.** The obvious move is `actions`. **Do not.**
`AppBar` lays `actions` out at intrinsic size and hands the remainder to `title`: with a
`44 + 12 + 44 + 16` trailing block the title Row drops from **342.00** to **246.00**, and the brand
becomes the thing that shrinks under Dynamic Type - reversing the priority the shipped header was
built to express. Keep the cluster inside `title`, right-aligned in the same `Expanded` the pill uses
now, and leave `actions` as the single `SizedBox(width: space8)`. Rendered result identical; failure
mode not. Free space is the same either way: `342 - 106.06 - 100 = 135.94`.

## Contrast, computed from the real tokens

| Pairing | Ratio | Needs | |
| --- | ---: | --- | --- |
| `surfaceMenu` #171A21 on `surfaceElevated` #0C0E14 | **1.11:1** | - | the fill identifies nothing |
| `borderControl` white 36% over the bar (#636569) | **3.30:1** | 3:1 (1.4.11) | pass - **the border carries the control alone** |
| `borderStrong` white 24% over the bar (#46484C) | 2.11:1 | 3:1 | below, shipped knowingly as the bar's bottom edge |
| `borderSubtle` white 12% over the bar (#292B30) | 1.36:1 | 3:1 | fail - never a control edge |
| `textPrimary` #FFFFFF on `surfaceMenu` | 17.41:1 | 4.5:1 | pass |
| `textSecondary` #8A8F9D on `surfaceMenu` | 5.39:1 | 4.5:1 | pass |
| `brandPrimaryStrong` #0AAEE6 avatar fill on the bar | **7.54:1** | 3:1 (1.4.11) | pass - **this is what lets A/E/F drop the border if they want** |
| `textOnBrand` #000B18 on that fill - **E's monogram** | **7.74:1** | 4.5:1 | pass |
| Network glyph, Base #0052FF on `surfaceMenu` | **3.03:1** | 3:1 | pass by 0.03 |
| Network glyph, Polygon #8247E5 on `surfaceMenu` | 3.30:1 | 3:1 | pass, thin |
| White on the BNB glyph #F3BA2F | **1.77:1** | 4.5:1 | fail - the badge label must flip to #000B18 (11.19:1) on light chains |

**The rule that binds every scheme:** `surfaceMenu` on `surfaceElevated` is 1.11:1, so a control in
this bar is invisible unless its edge or its fill does the work. `borderControl` does it at 3.30:1. A
scheme that drops the border must name its replacement - and for A, E and F the replacement exists
and is stronger: the avatar's own #0AAEE6 disc at 7.54:1.

## Recommendation

**★ Ship F - the wallet icon plus the hamburger - with E's monogram inside the icon.** It is the
direction Jakub asked for, it cuts the control from 223.94 px to **100.00** (57.4% of the bar down to
25.6%), and the accounting is honest: the wallet control itself is 44 px, exactly as small as the
icon-only schemes, and the other 56 px buys back the bottom bar's fourth slot rather than header
decoration. The one thing F gets wrong on its own is the one thing E fixes for nothing - a bare coin
avatar cannot say which wallet is live, because `AccountAvatar` is keyed to the currency. Put the
monogram in that circle and F answers **which wallet** and **which chain** at 44 px, which no other
scheme here does under 100.

Three conditions, none optional: the bottom bar gives up `More` (see `182`), the `Accounts` row
leaves `_MoreSheetBody`, and both icons stay inside `title`.

**Runner-up: E alone - the monogram avatar at 44 px.** If the bottom bar keeps `More`, the hamburger
has no job and E is simply F minus 56 px: the narrowest control here that still tells you which
wallet and which chain. E is also the piece of F worth building first, because it is additive - a new
branch inside `AccountAvatar`, no layout change anywhere - and because it fixes the double-icon
defect on the way past. **Build E, then decide F.** Not a hedge: E is a strict prerequisite for F
being any good.

**Explicitly rejected: B - the short pill.** The literal answer to "jakas bardziej krotsza forme" and
the worst value per pixel here, which is why it needs refusing out loud rather than quietly losing.
94 px more than E to keep the wallet name, and then both `Super Genius Wallet 1` and
`Super Genius Wallet 2` render as "Super Ge...". Widening until they separate puts the control back
at 224. **A name is either full width or it is decoration**, and B is the middle.

**On A**, Jakub's own first idea: right about everything except one fact it could not have known -
the circle it relies on is a picture of the currency, not of the wallet. Everything else about A is
exactly right, and E keeps all of it. **A and E are the same scheme; E is A after reading
`AccountAvatar.build`.**

**On C**, fourth: it noticed the best problem in this sketch (the chain has never been named in text)
and picked the most expensive place to fix it.

**On D**, fifth and the only scheme I would argue against building even if it were free. "Everything
expands" is the right instinct and A, E and F all honour it - **the sheet is the expansion.** D only
differs by animating an intermediate state on the way there, and that state costs 260 ms before a
sheet a single tap could have opened, a second layout of data the sheet already lays out, the width
problem returning on a timer at 87.7% of the bar, and the name-plus-address pairing the header just
got rid of. Switch to ADDRESS-SHAPED NAME in tab D and expand: the address renders twice, 340 px
wide.

## If F ships

| File | Change |
| --- | --- |
| `lib/components/overlay/mobile_header.dart` | `WalletPill` loses its name column and caret and becomes a 44 px icon button; a hamburger joins it in the same right-aligned `Expanded`, `space6` apart. `kWalletPillMaxWidth` and its doc comment are deleted - there is nothing left to cap |
| `lib/account/account_drawer.dart` `AccountAvatar` | a `monogram` branch, additively, the same way `networkIconPath` was added: null keeps today's exact `CircleAvatar` for the drawer rows |
| `lib/components/overlay/responsive_overlay.dart` | `More` leaves the bottom bar; `_MoreSheetBody` is reused verbatim behind the hamburger **minus its Accounts row** |
| the bottom bar's fourth slot | **not decided here** - see `182-bottom-nav-destinations` |
| `mobile_header_brand_and_pill_test.dart` | width assertions move from "the pill is capped at 236" to "the cluster is 100 and the lockup is untouched at 106.06". The invariant that matters - `GNUS.AI` never truncates - gets easier to hold, not harder |

## Provenance

Tokens verbatim from `lib/theme/gw_colors.dart` and `genius_wallet_consts.dart`. Networks verbatim
from `assets/json/networks/networks.json`. Phones are 390 x 844 at 1:1 with real shipping geometry:
**60 px app bar** (`toolbarHeight: 60`, 1px `borderStrong` bottom), 60 px bottom bar, 64 px dock,
26 px overhang, 84 px slot, and the just-shipped lockup at mark 28 / wordmark 18 so the width trade
is honest. Text advances measured from the bundled Inter TTFs; the mock falls back to the system font
and is letter-spacing-calibrated onto those advances, so a name that fits in the shipped app fits
here. `shortAddr()` mirrors `WalletUtils.getAddressForDisplay` (first 6, ellipsis, last 4). Contrast
ratios computed from the listed hex values, not eyeballed.

`node --check` clean; whole-file div balance 0; all **4200** render combinations (7 schemes x 5
wallet states x 2 icon faces x 2 ruler states x 3 sheet states x 5 networks x 2 expand states)
execute without error and each produces a div-balanced fragment.
