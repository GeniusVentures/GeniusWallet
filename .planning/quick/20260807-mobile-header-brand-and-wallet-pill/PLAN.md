---
phase: quick-260807-hbr
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/overlay/mobile_header.dart
  - lib/components/overlay/responsive_overlay.dart
  - lib/account/account_drawer.dart
  - lib/network/network_dropdown_selector.dart
  - test/components/mobile_header_brand_and_pill_test.dart
  - test/account/account_drawer_network_section_test.dart
  - .planning/sketches/180-mobile-header-brand-and-wallet/README.md
  - .planning/todos/pending/2026-08-07-wallet-name-field-accepts-an-address.md
  - .planning/todos/pending/2026-08-07-network-strip-needs-mainnet-testnet-grouping.md
autonomous: false
requirements: [QUICK-260807-HBR]

must_haves:
  truths:
    - "The phone header carries the brand at top-left: the shipping mark plus the wordmark GeniusAI as live text. Not a placeholder, not a gradient square drawn in code - the same PNG the desktop app bar has been rendering all along."
    - "There is exactly ONE control on the right. NetworkDropdownSelector is no longer mounted anywhere in the phone shell. Two affordances become one."
    - "Tapping that one control opens ONE sheet that carries both the network and the accounts. No third wallet surface is invented: it is the sketch-174 AccountDrawer with a Network section prepended."
    - "Switching network still costs 1 tap to see the list and 2 taps to commit, exactly as today. The count is measured and written down, not assumed."
    - "The header no longer prints an address. A wallet whose walletName IS an address renders that string ONCE, as an odd name, instead of twice as a bug."
    - "The app bar has a visible bottom edge - borderStrong at 1px, 2.11:1 against the bar, up from borderSubtle at 0.5px and 1.34:1 - because a brand block turns the bar into a band and a band with no edge floats."
    - "The current network is named in WORDS somewhere reachable: in the pill's accessible name at zero taps, and as text on the selected chip in the sheet at one tap. It is no longer identified by picture alone."
    - "Every interactive target in the header and the new network strip is at least 44 logical px tall."
    - "The desktop header is byte-identical. _DesktopTopBar is not edited, and NetworkDropdownSelector's own build(), Tooltip and drawer keep working exactly as they do today for the desktop control track at responsive_overlay.dart:183."
    - "The sketch 180 README's three false claims are corrected in place: that no logo asset exists, that reusing a coin mark was the only reuse option, and two contrast numbers that were computed wrong."
    - "flutter analyze reports zero issues attributable to this task's files, and flutter test ends with every pre-existing test passing and none edited."
  artifacts:
    - lib/components/overlay/mobile_header.dart
    - test/components/mobile_header_brand_and_pill_test.dart
    - test/account/account_drawer_network_section_test.dart
    - .planning/todos/pending/2026-08-07-wallet-name-field-accepts-an-address.md
    - .planning/todos/pending/2026-08-07-network-strip-needs-mainnet-testnet-grouping.md
  key_links:
    - "AccountDrawer.show gains includeNetwork with a default of FALSE. That default is what keeps test/account/account_drawer_show_test.dart green WITHOUT being edited - it asserts find.text('Accounts') findsOneWidget, and a retitled drawer would fail it. If that test goes red, the change was not additive."
    - "walletCubit.selectNetwork() has exactly ONE call site in the whole app: network_dropdown_selector.dart:85. Task 2 unmounts the widget that owns it from the phone. If Task 1's sheet does not write the cubit AND both Hive keys first, mobile loses the ability to change network at all. Task order is load-bearing: the sheet ships BEFORE the header change."
    - "The pill's badge reads WalletDetailsCubit.state.selectedNetwork, which app_bloc.dart:112-121 seeds at boot from the same two Hive keys. That is why the badge is correct on a cold start without any new resolver. Verified: app_bloc does the chainId+rpcUrl lookup with orElse networks.first before loadInitial."
    - "logo_and_title.png renders the wordmark GNUS.AI, not GeniusAI. Decoded and read at plan time. Shipping it in the header would put two different brand strings in one app - splash says GNUS.AI, header would say something else - so the mark-plus-live-text lockup is not a preference, it is the only option that honours the confirmed string."
    - "geniusappbarlogo.png is 38x38 canvas but its opaque glyph is 28x37 at x[1..28] - a 9px transparent right gutter. Measured, not assumed. Uncompensated it renders a visibly wrong gap, which is why desktop hard-codes SizedBox(width: 15). Mobile crops it instead so the gap token stays on grid."
    - "borderControl (white 36%, 3.30:1) is the CONTROL edge by its own token doc and goes on the pill. The bar's bottom edge is a decorative separator, so it takes borderStrong. Painting the bar edge at 36% would break the token's own stated rule that decorative separators stay subtle."
---

<objective>
Jakub picked scheme B from sketch 180 on 2026-08-07:

> Yes, 180B is great, exactly as you suggest - and you already have the Genius logo, so
> go ahead and bring it in.

and confirmed the wordmark string in the same session:

> Yes, write GeniusAI.

Three things move at once, and they are one change because none of them survives alone:

1. **Brand top-left.** The phone shell has no brand mark anywhere today. It gains the mark
   that already ships in the desktop app bar plus the wordmark `GeniusAI` as live text.
2. **The wallet control moves right and becomes ONE thing.** Today there are two controls
   and the wallet one is on the wrong side: an `InkWell` wallet block in `AppBar.title` on
   the LEFT, and `NetworkDropdownSelector` alone in `actions`. Jakub's complaint was that
   right now we have both a network chooser and a wallet chooser - two choosers for one question.
3. **Everything else expands on tap.** One sheet, "Wallet and network", carrying the
   network strip on top of the two account sections sketch 174 built this session.

This is not a bug fix. Nothing in the current header is broken enough to force a change -
it renders, it fits, it works. It is a hierarchy and identity decision, and a plan that
only moves widgets without deciding what the header is FOR has not delivered it. What the
header is for, after this: **whose wallet, on which chain, and one way in.**

Purpose: the phone shell currently announces nothing about the product it belongs to, and
spends its scarcest horizontal space on two controls that answer one question.

Output: one new file holding a testable mobile header, one additive parameter on the
accounts drawer, two additive public seams on the network selector, one corrected sketch
README, two captured follow-ups, two new test files, and a blocking on-device check.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@.planning/sketches/180-mobile-header-brand-and-wallet/README.md
@lib/components/overlay/responsive_overlay.dart
@lib/account/account_drawer.dart
@lib/network/network_dropdown_selector.dart
@lib/components/bottom_drawer/responsive_drawer.dart
@lib/components/cards/gw_select_row.dart
@lib/theme/genius_wallet_consts.dart
@test/account/account_drawer_show_test.dart

Read the sketch README with this plan's `<the_corrections>` section beside it. Three of its
claims are wrong and this plan fixes them in the README as part of the work.

`lib/components/overlay/responsive_overlay.dart` is heavily modified in the working tree
this session - mobile tab bar, gradient active tab, capped safe-area inset, 504 insertions
against HEAD. Plan and edit against the WORKING TREE, never against `git show HEAD:`.
</context>

<measured_baseline>
Measured on `redesign/navigation-260806` at plan time, 2026-08-07. Not quoted from memory,
not carried over from another task.

| Gate | Baseline | Command |
| --- | --- | --- |
| `flutter test` | **+1081, All tests passed**, exit 0 | `flutter test` |
| `flutter analyze` | **1 issue**, and it is NOT this task's | `flutter analyze` |

## The one analyze issue, and why it is not yours

```
error - The function 'FontLoader' isn't defined
        test/components/assets_header_scheme_c_test.dart:89:18 - undefined_function
```

That file did not exist when this plan started; it appeared at 09:41 today. It belongs to
the **Assets header quick task running in parallel right now** (`quick-260807-hdr`), which
owns `coins_screen.dart`, `gw_section_title.dart` and `gw_view_all_link.dart`. Its missing
import is theirs to fix.

**Your gate is therefore stated precisely:** after this task, `flutter analyze` must report
**zero issues in any file this plan touches**. Re-run and confirm the only surviving issue,
if any, still points at `test/components/assets_header_scheme_c_test.dart` or another file
in the parallel plan's ownership list. If a NEW file name appears, it is yours.

**Do not "fix" the parallel plan's error.** Two agents editing one file is how a working
tree gets corrupted. If it is already gone when you run, better.

## `flutter test` finishing number

1081 is the number to return to, plus whatever the two new test files add. It is not a
floor to be reached by deleting anything. **No pre-existing test may be edited**, and in
particular `test/account/account_drawer_show_test.dart` must stay green untouched - see
`<the_additive_contract>` for why that is the sharpest signal in this whole plan.

The 1081-test run emits a pre-existing RenderFlex overflow log from
`lib/tokens/token_info_screen.dart:907`. It does not fail the run today and it is not in
scope. Leave it.

## Em dash census, counted at plan time

The no-em-dash rule is not a formality; one of your files already carries one.

| File | Em dashes today | Where |
| --- | --- | --- |
| `lib/components/overlay/responsive_overlay.dart` | **1** | line 877, inside a comment in the desktop nav region |
| `lib/account/account_drawer.dart` | 0 | clean |
| `lib/network/network_dropdown_selector.dart` | 0 | clean |
| sketch 180 `README.md` | 0 | clean |

Line 877 is outside every region this plan edits, but it is in a file this plan owns, so
clean it while you are in there: one character, replaced by space hyphen space. All files
touched must read 0 when the gate runs, comments included.
</measured_baseline>

<the_corrections>
## The sketch README is wrong about the logo, and wrong twice about contrast

The sketch is a planning document, not code, so correcting it is in scope and is Task 3.

### Correction 1 - the logo exists, and it is already shipping

The README says, under a heading called "Blocking dependency":

> `assets/images/` holds screen furniture ... There is no app icon, no wordmark, no mark SVG.

The search looked in the wrong directory. This is a Flutter **package-style** asset layout:
`pubspec.yaml` declares `name: genius_wallet` and lists its own assets under
`packages/genius_wallet/assets/images/...` (lines 139 and 150), which resolves to
**`lib/assets/images/`** on disk. Code loads them with `package: 'genius_wallet'`.

| File | Canvas | Opaque glyph | Already rendered at |
| --- | --- | --- | --- |
| `lib/assets/images/geniusappbarlogo.png` | 38 x 38 | **28 x 37** at x[1..28], y[1..37] | `responsive_overlay.dart:676` - the DESKTOP app bar |
| `lib/assets/images/logo_and_title.png` | 239 x 52 | **222 x 51** at x[2..223] | `screens/splash.dart:191`, `components/splash.dart:80`, `onboarding/view/wallet_creation_screen.dart:40` |

Both decoded at plan time, alpha channel walked for the true opaque bounding box.

Two consequences the README drew from the false premise both collapse:

- Its option 2, "the GNUS coin mark reused - **wrong**, it is a token mark and would read as
  a balance", was answering a question that never needed asking. Nobody has to reuse a coin
  mark. The brand mark exists.
- Its consistency worry is settled in the same stroke. The mark mobile should use is the
  mark **desktop has been using all along**, which is the strongest possible answer to
  "will the two shells agree".

The README's third option, a mark drawn from the brand gradient in code, is also dead. Do
not draw a square.

**The exact path to write:** `'assets/images/geniusappbarlogo.png'` with
`package: 'genius_wallet'`. That is the form all four existing call sites use. Do not guess
a `lib/`-prefixed path; the declared name and the disk path differ on purpose.

### Correction 2 - `borderStrong` does not land at 2.6:1

README: "One line to fix: `borderStrong` (white 24%) lands at 2.6:1".

Recomputed from the real tokens, compositing the hairline over the surface it sits on:

| Edge | Composite | Against the bar `#0C0E14` |
| --- | --- | --- |
| `borderSubtle` white 12% | `#282A2E` | **1.34:1** (README right) |
| `borderStrong` white 24% | `#46484C` | **2.11:1** (README said 2.6) |
| `borderControl` white 36% | - | **3.30:1** (the token's own doc agrees) |

### Correction 3 - `surfaceMenu` is nowhere near 2.9:1 against the body

README: "or give the bar `surfaceMenu #171A21` at 2.9:1 against the body".

| Pairing | Real ratio |
| --- | --- |
| `surfaceMenu #171A21` vs `surfaceBase #0B0D12` | **1.12:1** |
| `surfaceElevated #0C0E14` vs `surfaceBase #0B0D12` | 1.01:1 |
| `surfaceSunken #06080C` vs `surfaceBase #0B0D12` | 1.03:1 |

**No two dark surface tokens in this palette separate by even 1.2:1.** A surface swap
cannot give the bar an edge. Only a line can. That is worth writing into the README because
it is the general finding, not a fact about this one bar.

### The numbers that were right

`borderSubtle` at 1.34:1, the glyph ratios (Base `#0052FF` 3.35:1, Polygon `#8247E5`
3.66:1), white on the bar at 19.3:1, `textSecondary` at 5.97:1, `brandPrimary` at 9.86:1,
and "Genius AI" at 15px w700 being about 66px wide. That last one is now measured exactly
rather than estimated - see `<the_arithmetic>`.
</the_corrections>

<the_asset_decision>
## What sits on the left, and why it is not the ready-made image

Two candidates. This is the one place where picking the convenient option ships a bug that
nobody would catch for weeks.

### `logo_and_title.png` says GNUS.AI

Decoded and rendered on the bar colour at plan time. The image is the head-and-brain mark
followed by the wordmark **`GNUS.AI`** - capitals, with a full stop.

Jakub confirmed the header wordmark as **`GeniusAI`** - one word, no space, no stop.

So the ready-made image is not a shortcut to the confirmed string, it is a **different
string**. Shipping it would put two brand spellings in one app: `GNUS.AI` on the splash and
on wallet creation, something else in the header. Worse, it would look like the request had
been honoured.

**This conflict is named, not resolved by this plan.** `logo_and_title.png` stays exactly
where it is on splash and onboarding. Whether the product is called GNUS.AI or GeniusAI is
Jakub's call and it is asked at the checkpoint, not decided here.

### The mark plus live text - ★ recommended

`geniusappbarlogo.png` for the mark, a real `Text` widget for `GeniusAI`.

Why this and not the image:
- It renders the **confirmed** string, and only this option can.
- Live text is crisp at every pixel density, respects Dynamic Type, and a screen reader
  reads it as text. Roughly 78% of the lockup's width therefore has no asset resolution
  problem at all.
- The mark is the one desktop already renders, which settles consistency for free.

### The sharpness problem, stated honestly

**There are no @2x or @3x variants.** `lib/assets/images/` has no `2.0x` or `3.0x`
subdirectory at all, for any asset. So every render of this mark on a 3x iPhone is an
upscale, and the number depends entirely on the height chosen.

The glyph is 37 source rows tall inside a 38px canvas. On a 3x screen:

| Rendered height | Physical px | Upscale from 37 rows | Verdict |
| --- | --- | --- | --- |
| 32 | 93.5 | **2.53x** | too soft for line art this fine |
| 28 (as drawn in the sketch) | 81.8 | 2.21x | still soft |
| **24 - recommended** | **70.1** | **1.90x** | the largest step under 2x |
| 20 | 58.4 | 1.58x | crisper, and small beside a 15px wordmark |
| 16 | 46.7 | 1.26x | nearly clean, but reads as an icon not a brand |
| 12.3 | 37 | 1.00x | pixel-perfect and far too small to be a mark |

The mark is an intricate line drawing - a brain circuit inside a head profile - and
intricate line art shows upscaling far more than a solid shape would.

**★ Ship at height 24.** It is the largest step that stays under a 2x upscale, it is on the
4-pt grid, it sits at about 2.1x the wordmark's cap height which is a normal lockup ratio,
and it deliberately leaves the pill's 32px avatar as the largest circular object in the bar
so the wallet control stays dominant - which is the entire point of the redesign.

**Runner-up: 20.** Take it if the circuitry reads mushy on device. One token step, no
layout consequence, 1.58x.

**Rejected: 32.** It matches the pill avatar and looks balanced in a static mockup, and it
is a 2.53x upscale on the device Jakub actually reviews on.

**Do not block on a better asset.** The mark ships at 24 today. Ask Jakub at the checkpoint
for a 3x export - 114 x 114, same artwork, same transparent margins - which is a pure
drop-in with zero layout change because the render height is fixed in code. That is the
difference between recording a dependency and being stopped by one.

### The 9px right gutter, and why it is not a rounding error

The opaque glyph ends at x=28 in a 38px canvas. There is **9px of transparent margin on the
right and 1px on the left.** Rendered raw at height 24, the box is 24 wide but the visible
mark is only 17.7 wide and sits hard against the left, so a nominal 8px gap to the wordmark
renders as roughly 13.7px of visible air. That is not subtle - it is why desktop's code
carries a hand-computed `SizedBox(width: 15)` with a comment explaining the same problem.

Mobile solves it by cropping rather than compensating, so the gap token stays honest:

```
ClipRect(
  child: Align(
    alignment: Alignment.centerLeft,
    widthFactor: 29 / 38,
    child: Image.asset(..., height: 24, excludeFromSemantics: true),
  ),
)
```

`29 / 38` keeps exactly one column of the original left margin and drops the right gutter.
The resulting box is 18.3 wide, `space4` of 8 is a real 8, and the number is derived from a
measurement that is written down here rather than tuned by eye.
</the_asset_decision>

<the_arithmetic>
## Width budget at 390pt, with GeniusAI as one unbreakable token

Every text width below was measured by walking the bundled Inter TTF's `hmtx` advances at
plan time, not estimated. Kerning is not applied, which makes each figure a slight
**over**-estimate - the safe direction for a budget.

### Wordmark

| String | Style | Width |
| --- | --- | --- |
| **`GeniusAI`** | Inter Bold 15 | **66.7** |
| `GeniusAI` | Inter Bold 14 | 62.3 |
| `GeniusAI` | Inter Bold 16 | 71.2 |
| `Genius AI` (the old two-word form) | Inter Bold 15 | 70.3 |

The confirmed one-word string is **3.6px narrower** than the two-word form the sketch
budgeted for. It cannot wrap and it cannot shed a word to fit, which is exactly why the
budget below is stated with its slack rather than asserted to be fine.

### The bar

```
390                     iPhone 14 / 15 logical width
 -16                    titleSpacing = space8
 -16                    trailing SizedBox = space8
=358                    content box

 18.3                   mark, cropped: 24 * 29/38
+ 8                     space4, mark to wordmark
+66.7                   GeniusAI, Inter Bold 15
=93.0                   brand lockup - NEVER shrinks

358 - 93.0 - 12         minus the space6 gap to the pill
=253.0                  available to the pill
-236                    the pill's cap
= 17.0 px of slack
```

**17px, not the sketch's 4.** The sketch budgeted an uncropped 28px mark box and the wider
two-word string. Both assumptions changed in the plan's favour. The 236 cap is still not
optional - it is what stops a long name from eating the brand - but it is no longer
hanging over a cliff.

For the record, at the runner-up mark height of 20: brand becomes 15.3 + 8 + 66.7 = 90.0
and slack grows to 20.0. Either height fits.

### Inside the pill, at the 236 cap

```
  6   space3 left inset (a circle needs less inset than a glyph)
+32   AccountAvatar, badged
+ 8   space4
+ n   the wallet name
+ 4   space2
+18   caret glyph
+ 8   space4 right inset
```

Fixed chrome = **76**, so at the cap the name gets **160px**. Measured against the names
this app actually produces, Inter SemiBold 14:

| Name | Width | Fits in 160? |
| --- | --- | --- |
| `Main` | 33.2 | yes |
| `Savings` | 54.0 | yes |
| `No wallet` (the empty state) | 63.0 | yes |
| `Super Genius Wallet` (`app_bloc.dart:616`, single SDK account) | 137.4 | **yes** |
| `Super Genius Wallet 2` (multiple SDK accounts) | 149.7 | **yes** |
| `Super Genius Wallet 10` | approx 158 | yes, barely |
| a 42-char address as a name | 350.6 | no - ellipsizes, by design |

**The names the app generates itself never ellipsize.** That is the result worth having:
the cap exists for pathological user input, not for normal use.

### Vertical

The bar is **60**. `toolbarHeight: 60` and `preferredSize` 60 already agree in the shipped
class - the sketch's "discrepancy" is between its own 56px drawing and the code, not inside
the code. Keep 60; no change.

A 44 pill in a 60 bar leaves 8 above and 8 below. On grid.

### The one off-grid value, and its reason

The badge's ring is **2px**. The 4-pt grid governs layout spacing; a ring is a stroke, like
`GWControlTrack`'s `EdgeInsets.all(3)` well padding, which is existing precedent in this
codebase. A 4px ring on a 16px badge would leave an 8px icon, which is below the point of
drawing a network icon at all. Write that reason in the code.

Everything else is a token: 6, 8, 12, 16, 18, 20, 24, 32, 44, and the 236 cap which is
4 x 59.
</the_arithmetic>

<the_decisions>
Nine questions the brief asked to be resolved out loud. Each answered with its cost.

### 1. What sits left

Cropped `geniusappbarlogo.png` at height 24, `space4`, then `Text('GeniusAI')` in Inter
Bold 15, `textPrimary` white, 19.29:1 on the bar.

**One colour, not two.** The sketch drew "Genius" white with "AI" in a muted tint, which
worked because there was a space to break on. In a single word a colour change mid-token
reads as a rendering fault, not as a design. The shipped `logo_and_title.png` also renders
its whole wordmark in one weight and one colour. Runner-up if Jakub wants the accent:
`AI` in `brandPrimary` at 9.86:1 - legitimate, still AA, still wrong for a single word.
Rejected: `AI` in `textSecondary`, because mid-word grey reads as disabled text.

**At the narrowest width the brand does not move.** The pill absorbs every pixel of
shrink; see `<the_layout>` for the widget shape that guarantees it. The wordmark carries
`maxLines: 1` and ellipsis inside a `ConstrainedBox(maxWidth: 180)` purely as an
extreme-Dynamic-Type guard - at normal scale it is 66.7 wide and never touches 180, so
the ellipsis is a fuse, not a behaviour.

### 2. What the ONE right-hand control is, and what it opens

The scheme B **wallet pill**: 44 tall, capped at 236, `surfaceMenu` fill with a
`borderControl` edge, holding a 32px `AccountAvatar` carrying a 16px network badge, the
wallet name, and a caret.

It opens `AccountDrawer.show(context, includeNetwork: true)` - the sketch-174 accounts
drawer, retitled "Wallet and network" and with a Network section prepended above the two
existing account sections. **No third wallet surface.** The two 174 sections, their
headers, their captions, their empty notes and their rows are not touched.

### 3. Where network switching lives, and what it costs in taps

Counted, both sides:

| | Today | After |
| --- | --- | --- |
| See the network list | 1 tap - the `actions` chip | 1 tap - the pill |
| Commit a switch | **2 taps** - chip, then row | **2 taps** - pill, then chip |
| Read which chain you are on, in words | never - the tooltip says "Select network", the action rather than the value | **0 taps** in the accessible name, 1 tap on screen |

**No regression. 1 tap to see, 2 taps to switch, identical to today**, and the network
gains a name it never had.

**The cost that IS real, stated with its number.** There are **10 networks** in
`assets/json/networks/networks.json`. As a horizontal chip strip they total **1294px**
against **350px** of visible sheet width - about 3.7 screens. The current chip is ordered
first so it is always visible without scrolling, and roughly three chips are reachable at
rest, but the tenth network needs about three swipes.

That cost is not new, it moved axis. Today the same 10 networks are a vertical list in a
sheet that also needs scrolling to reach the bottom of. What the strip buys is that the
**account sections stay visible when the sheet opens** - and the sheet is a wallet control
first, a network control second. A vertical network list would fill the sheet and push the
user's own wallets entirely below the fold, which inverts the priority of the surface.

The honest fix is a data change, not a layout one: mainnet/testnet grouping so the strip
shows 5 mainnets and tucks 5 testnets behind a disclosure. **Captured as a todo, not built
here** - it needs a field in `networks.json` that does not exist, and inferring "testnet"
from a name is the kind of guess that breaks silently.

### 4. The double-address defect

**Halved, not fixed, and the difference matters.**

Today the header prints `wallet.walletName` over
`WalletUtils.getAddressForDisplay(wallet.address)`. On a wallet imported through the
free-text name field, the "name" IS an address, so the header prints the address twice -
once whole-ish, once truncated.

The pill shows **the name only.** So an address-shaped name renders **once**. It looks like
an odd name rather than a bug.

It is not a fix. The defect is that
`lib/onboarding/existing_wallet/view/import_security_screen.dart:236` writes
`walletName: walletNameController.text` with no validation, so an address can be saved as a
name in the first place. SDK wallets never hit it - `app_bloc.dart:616` names them. **No
code anywhere derives a name from an address, and this plan must not add any.** Deriving one
would be inventing a heuristic that then disagrees with the drawer rows, which show name and
address as two separate lines and correctly need both to disambiguate.

Captured as a todo. Not built here.

The 236 cap with ellipsis is a **condition of the scheme**, not an option: it is what keeps
a 350px address-shaped name from eating the brand block.

### 5. The app bar's edge

`surfaceElevated #0C0E14` against `surfaceBase #0B0D12` is **1.01:1** - literally the same
colour to any eye - and the only separator is a 0.5px `borderSubtle` hairline at
**1.34:1**. Today that barely matters, because the header is a name in a corner. The moment
a brand block anchors the top-left the bar becomes a band, and a band with no edge floats.

**Change: `borderStrong` at 1px.** 1.34:1 at 0.5px becomes **2.11:1 at 1px** - the ratio
improves by half again and the painted area doubles, from 1.5 physical px at 3x to 3.

**Why not 3:1.** It is unreachable. White at **34%** alpha is the first step that clears
3:1 on this bar, and the token that sits at 36% - `borderControl` - is explicitly reserved
by its own documentation: "this is the CONTROL edge, not a general strong hairline.
Decorative separators stay on `borderSubtle` - a rule that carries no information has no
1.4.11 threshold to meet, and painting every hairline at 36% would make the app a
wireframe." A bar's bottom edge carries no information about a component's state. It gets
`borderStrong` and the app's own rule survives.

**Where `borderControl` DOES go: the pill.** The pill is a control whose fill cannot
identify it - `surfaceMenu` on `surfaceElevated` is 1.11:1 - so its boundary carries 1.4.11
alone, which is precisely the case the token was created for. 3.30:1. This is also the
established house recipe, stated in `responsive_drawer.dart`'s own class doc: a control on
a dark panel takes its fill UP to `surfaceMenu` and its edge to `borderControl`.

### 6. The network identified by picture alone

Real finding, and scheme B makes the picture **smaller**: 20px in the chip today, 16px as a
badge. It has to be answered somewhere other than the badge.

Three answers, all shipping together:

1. **The badge is declared decorative.** `excludeFromSemantics: true`. It is a
   change-detector - "the chain moved" - and it is not asked to be an identifier.
2. **The pill's accessible name states the network in words, at zero taps.**
   `Super Genius Wallet, on Polygon. Opens wallet and network.` That is strictly more than
   today's header offers, where the only network affordance is a `Tooltip` reading "Select
   network" - the action, never the value.
3. **The sheet names it on screen at one tap.** Every chip carries the network's name as
   text beside its icon, and the current one is marked by a brand-tinted fill plus a brand
   edge at 9.86:1, not by colour alone.

**The badge ring does real work too.** It is 2px of the bar colour, which measures 3.35:1
against Base `#0052FF` and 3.66:1 against Polygon `#8247E5` - the same marginal numbers the
glyph has against the bar today, so the badge is separated from both the avatar and the bar
by an edge that clears 1.4.11 on its own.

**What this does not fix, said plainly:** a sighted user still cannot read which chain they
are on from a 16px badge at a glance. That is scheme B's stated cost and Jakub accepted it
when he picked B. If it reads as unacceptable on device, the named fallback is a second line
in the pill carrying the network name at 11px - which reintroduces two lines but **not** an
address, so it does not resurrect the defect in item 4. Longest network name,
`Super Genius - TestNet`, measures about 110px and fits inside the 160px name column, so the
fallback costs no width. It is offered at the checkpoint, not built.

**Do not change `NetworkDropdownSelector.build()` or its Tooltip.** That widget is still
mounted in the DESKTOP control track at `responsive_overlay.dart:183`, and its tooltip is
desktop-visible. Fixing the tooltip's wording is a good idea for a different task with a
different blast radius.

### 7. Height

**60.** `toolbarHeight: 60` and `preferredSize` 60 already agree in the shipped class. The
sketch drew 56 because its own brief said 56. Verified against the tree; nothing to change.

### 8. Touch targets

- Pill: 44 tall exactly, and it is the only target in the bar.
- Network chips: 44 tall.
- The badge is decoration inside the pill, not a target, so there is no 16px hit area.
- The brand lockup is **not** interactive. It has no tap handler, so it has no target
  requirement, and it must not gain one - a second tappable object in the bar reopens the
  exact "two controls" complaint this task exists to close.

### 9. What must NOT change

- `_DesktopTopBar`, entirely. Not read, not edited.
- `NetworkDropdownSelector`'s `build()`, its `Tooltip`, its drawer, its rows, its toast
  copy and its Hive keys. Only additive public seams are added around them.
- The two sketch-174 account sections in `account_drawer.dart`.
- `AccountAvatar`'s behaviour for every existing caller.
- Anything under `/banxa` or `/squidrouter`.
- The three files owned by the parallel Assets plan (`coins_screen.dart`,
  `gw_section_title.dart`, `gw_view_all_link.dart`) and the two owned by the parallel
  transaction row plan (`transaction_displays.dart`, `transaction_utils.dart`).
</the_decisions>

<the_additive_contract>
## The one existing test, and the parameter default that keeps it green

Grepped: exactly **one** test file touches any of these surfaces -
`test/account/account_drawer_show_test.dart`. **No test asserts the mobile header's
structure today**, and none can, because `_MobileHeader` is private and unmountable without
the whole overlay. That is the second reason Task 2 extracts it to its own file.

What that one file asserts, and what would break it:

| Assertion | Breaks if |
| --- | --- |
| `find.text('Accounts')` findsOneWidget | the drawer title changes for the DEFAULT caller |
| `find.text('YOUR ACCOUNTS')` findsOneWidget | the 174 section header is renamed |
| `find.text('SDK ACCOUNTS')` findsNothing | an SDK section renders with no SDK wallets |
| `find.text('Wallet A' / 'Wallet B')` | the rows change shape |
| `find.text('Add Wallet')` findsOneWidget | the footer changes |

**Therefore `includeNetwork` defaults to `false`, and the title is derived from it inside
`show()`:** `'Accounts'` when false, `'Wallet and network'` when true. Every existing caller
- the compute panel's not-linked state included - passes nothing and gets byte-identical
behaviour.

**If `account_drawer_show_test.dart` goes red, the change was not additive.** Do not edit
that file to make it pass. Fix the change.

Same discipline on `AccountAvatar`: `networkIconPath` is a new optional named parameter
defaulting to null, and when it is null the widget returns **today's exact `CircleAvatar`**
with no `Stack` and no wrapper. The drawer rows at `account_drawer.dart:230` pass nothing
and must render unchanged.
</the_additive_contract>

<the_layout>
## The widget shape, and the one property it has to guarantee

The guarantee: **the brand never shrinks; the pill absorbs every pixel of shrink.** If the
brand shrank, `GeniusAI` would become `Geniu...` which reads as broken. If the pill shrinks,
the wallet name simply ellipsizes earlier, which is harmless and already expected.

`AppBar` lays out `actions` at their intrinsic size and gives the remainder to `title`,
which is the wrong priority - it would let a 236px pill squeeze the brand. So the pill does
**not** go in `actions`. Both blocks live in `title`, and `actions` carries only the right
inset:

```
actions: const [SizedBox(width: GeniusWalletConsts.space8)],
title: Row(
  children: [
    const _BrandLockup(),                       // intrinsic, non-flex, never shrinks
    const SizedBox(width: GeniusWalletConsts.space6),
    Expanded(                                   // takes ALL remaining width
      child: Align(
        alignment: Alignment.centerRight,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: kWalletPillMaxWidth), // 236
          child: const WalletPill(),
        ),
      ),
    ),
  ],
),
```

`Expanded` receives `358 - brand - 12`. `Align` pins the pill right. `ConstrainedBox` caps
it at 236. The pill's own `Row` is `MainAxisSize.min` with a `Flexible` name, so it is
naturally narrower than the cap for short names and ellipsizes at it for long ones. If the
brand ever grows - Dynamic Type - `Expanded` shrinks and the pill shrinks with it, brand
intact. That is the guarantee, expressed in layout rather than in a comment.

`kWalletPillMaxWidth = 236` is a named public constant in `mobile_header.dart` so the test
asserts against the same number the widget uses, rather than a literal typed twice.
</the_layout>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: the combined sheet - a Network section on the accounts drawer, plus the two public seams the header will need</name>
  <files>lib/network/network_dropdown_selector.dart, lib/account/account_drawer.dart, test/account/account_drawer_network_section_test.dart</files>
  <behavior>
    - `AccountDrawer.show(context)` with no new argument: title is still `Accounts`, no network section renders, both 174 account sections render, footer still `Add Wallet`. Byte-identical to today.
    - `AccountDrawer.show(context, includeNetwork: true)`: title is `Wallet and network`, a `NETWORK` section header renders above both account sections, and the current network's NAME renders as on-screen text.
    - With `includeNetwork: true`, the current network's chip is FIRST in the strip regardless of its index in the provider list.
    - Tapping a non-current chip pops the sheet and applies the selection: `WalletDetailsCubit.state.selectedNetwork` becomes that network, and both Hive keys are written.
    - Tapping the already-current chip is a no-op that does not re-emit and does not re-toast.
    - Every chip is at least 44 logical px tall.
  </behavior>
  <action>
Two additive public seams in `lib/network/network_dropdown_selector.dart`, then the drawer
section that uses them. Nothing existing in that file changes shape.

**Seam A - `NetworkSelection.apply`.** A new public class holding one static method that
performs the three side effects `_showNetworkDrawer` performs today at lines 85 to 97, in
the same order: `walletCubit.selectNetwork(network)`, then the success toast reading
`Switched to {name or symbol or "network"}.`, then `box.put` of both
`selectedNetworkKeyChainId` and `selectedNetworkKeyRpcUrl`. Then rewrite
`_showNetworkDrawer`'s body to call it, so there is exactly one implementation.

This matters more than it looks. `walletCubit.selectNetwork()` has **one call site in the
entire app** and Task 2 unmounts the widget that owns it from the phone. Following the
precedent `AccountDrawer.show` already set - side effects live in the entry, never at the
call site, because a caller that forgets the Hive write ships a selection that silently
does not survive a restart - this is the seam that keeps mobile able to change network at
all. Say so in the method's doc comment.

**Seam B - `NetworkSelectChip`.** A new public `StatelessWidget` taking `network`,
`selected` and `onTap`. Geometry: `SizedBox(height: 44)`, `StadiumBorder`, horizontal
padding `space4`, holding `Image.asset(network.iconPath ?? '')` at 20x20 with the same
`errorBuilder` fallback the existing rows use, `space4`, then `Text(network.name ??
'Unnamed')` at `labelMd` 13 w600.

Resting: `surfaceSunken` fill, `borderSubtle` edge, `textPrimary` label. Selected:
`brandPrimary` at 12% alpha fill, a `brandPrimary` edge at 9.86:1, `textPrimary` label.

Selected state is deliberately NOT the brand CTA gradient that `GWTimeframeSegment`'s
selected chip wears. The sheet already has one gradient fill - the `Add Wallet` footer
button - and the house rule is one filled gradient per surface, fill meaning commitment.
Picking a network you are already on is not a commitment. Write that reason in the code.

Carry `Semantics(selected: selected)` so selection is exposed as state, not only as colour.

**The section, in `lib/account/account_drawer.dart`.** Add `bool includeNetwork = false` to
`AccountDrawer.show`. Derive the title from it inside `show()` - `Accounts` when false,
`Wallet and network` when true. Read the network list ONLY when the flag is true, via
`Provider.of&lt;NetworkProvider&gt;(context, listen: false).networks`, captured at the call
site before the route is pushed and passed into `_AccountDrawerBody` as a plain list. That
mirrors `_showNetworkDrawer`, which already passes `networks` in rather than reading a
provider from inside a root-navigator route, and it makes the body a pure function of its
inputs so the test can seed it.

`_AccountDrawerBody` gains a matching field. When the list is non-empty it prepends, above
the existing SDK block:

- the existing `_AccountSectionHeader` with title `Network` and caption
  `Which chain the balances below are read from.`
- a `SizedBox(height: 44)` wrapping a horizontally scrolling `ListView` of
  `NetworkSelectChip`, `space4` between chips, ordered current-first then provider order
- a `SizedBox(height: GeniusWalletConsts.space8)` before the account sections

Reuse `_AccountSectionHeader` as it stands. Do not add a variant flag to it and do not
touch either existing section.

The current network comes from `context.read&lt;WalletDetailsCubit&gt;().state
.selectedNetwork`, matched on `chainId` and `rpcUrl`. That value is correct on a cold start
because `app_bloc.dart:112-121` resolves it from the same two Hive keys and seeds it through
`loadInitial` before the first frame - verified at plan time, and the reason no new resolver
is needed here.

On tap of a non-current chip: pop the sheet, then `NetworkSelection.apply`. On tap of the
current chip: nothing.

**The test**, `test/account/account_drawer_network_section_test.dart`. Copy the harness
discipline from `account_drawer_show_test.dart` verbatim - it is the file that solved the
`FakeAsync` plus real Hive I/O hang, and its header documents three prior agents stalling
there. Specifically: `Hive.openBox(name, bytes: Uint8List(0))` for the in-memory backend,
`_FakeGeniusApi` rather than a real `GeniusApi` whose constructor dlopens a native
framework, disposal in `finally` and never `addTearDown`, and `tester.runAsync` around
`appBloc.close()` only.

Seed networks with a `NetworkProvider` subclass overriding the `networks` getter - the same
seeding pattern `_SeededAppBloc` uses in that file. Do not call `loadNetworks()`; it reads
the asset bundle and this test has no business depending on the JSON's contents.

Cover: the default-title case, the combined-title case, `NETWORK` present only when the
flag is set, the current network's name present as text, current-first ordering, chip
height at least 44, and that a tap reaches both the cubit and both Hive keys.
  </action>
  <verify>
    <automated>flutter test test/account/account_drawer_network_section_test.dart test/account/account_drawer_show_test.dart</automated>
  </verify>
  <done>
Both files pass. `account_drawer_show_test.dart` passes with **zero edits** - confirm with
`git diff --stat test/account/account_drawer_show_test.dart` printing nothing. The default
`AccountDrawer.show(context)` renders a drawer titled `Accounts` with no network section.
`flutter analyze` reports nothing in `account_drawer.dart` or `network_dropdown_selector.dart`.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: the header - brand lockup left, one wallet pill right, extracted to its own testable file</name>
  <files>lib/components/overlay/mobile_header.dart, lib/components/overlay/responsive_overlay.dart, lib/account/account_drawer.dart, test/components/mobile_header_brand_and_pill_test.dart</files>
  <behavior>
    - The header renders the text `GeniusAI` exactly once.
    - The header renders the brand mark image exactly once.
    - No network dropdown widget is mounted in the phone header - one control on the right, not two.
    - The wallet pill is at least 44 logical px tall.
    - At 390pt with a 60-character wallet name, the pill's width is at most 236 and the brand lockup's width is IDENTICAL to its width with a 4-character name. The brand does not shrink.
    - With a wallet whose walletName IS its address, the truncated `0x1234...5678` display form does NOT appear anywhere in the header. The header prints no address line.
    - With no wallet, the pill renders `No wallet` and is still tappable.
    - The app bar's bottom border is 1px, not 0.5px.
  </behavior>
  <action>
**New file `lib/components/overlay/mobile_header.dart`**, holding three public widgets and
one public constant. New file rather than more lines in `responsive_overlay.dart` for two
reasons: that file is already 504 insertions ahead of HEAD this session, and a private
`_MobileHeader` cannot be mounted by a test without standing up the entire overlay - which
is why no test asserts the header's structure today.

`kWalletPillMaxWidth = 236`.

`MobileHeader` - public, `StatelessWidget implements PreferredSizeWidget`,
`preferredSize` 60. Move the existing class body across, keeping its `AppBar`,
`backgroundColor: gw.surfaceElevated`, `surfaceTintColor: Colors.transparent`,
`elevation: 0`, `toolbarHeight: 60`, `automaticallyImplyLeading: false` and
`titleSpacing: GeniusWalletConsts.space8`. **Carry the existing 24-07 comment across
intact** - the one recording why this is a real `AppBar` and not a hand-rolled `Container`,
because a `Container` rendered under the notch. That comment is a scar; do not lose it in
the move.

Three changes to the bar itself:
- `shape` becomes `Border(bottom: BorderSide(color: gw.borderStrong, width: 1))`, up from
  `borderSubtle` at 0.5. Comment it with the measured pair: 1.34:1 becomes 2.11:1, and note
  that no surface swap can help because the two dark surfaces are 1.01:1 apart, and that
  `borderControl` is not used here because it is the control edge by its own doc.
- `actions` becomes only `const [SizedBox(width: GeniusWalletConsts.space8)]`.
- `title` becomes the `Row` specified in this plan's `<the_layout>` section, verbatim.

`_BrandLockup` - private to the file, `MainAxisSize.min` `Row`:
`ClipRect` wrapping `Align(alignment: Alignment.centerLeft, widthFactor: 29 / 38)` wrapping
`Image.asset('assets/images/geniusappbarlogo.png', package: 'genius_wallet', height: 24,
excludeFromSemantics: true)`; then `SizedBox(width: GeniusWalletConsts.space4)`; then
`ConstrainedBox(maxWidth: 180)` around `Text('GeniusAI', maxLines: 1, overflow:
TextOverflow.ellipsis)` at `GeniusWalletTypography.labelMd.copyWith(fontSize: 15,
fontWeight: FontWeight.w700, color: gw.textPrimary)`.

Comment the `29 / 38`: it is the measured opaque bounding box, x[1..28] of a 38px canvas, so
cropping the transparent right gutter is what lets the gap stay a real `space4`. Comment the
height 24: a 1.90x upscale at 3x with no high-density variant in the repo, chosen as the
largest step under 2x. Comment the `maxWidth: 180`: a Dynamic Type fuse, never reached at
normal scale where the string measures 66.7. **The lockup takes no tap handler.**

`WalletPill` - public so the test can find it by type. Reads
`context.watch&lt;WalletDetailsCubit&gt;()` for both `selectedWallet` and `selectedNetwork`.

```
Material(
  color: gw.surfaceMenu,
  shape: StadiumBorder(side: BorderSide(color: gw.borderControl)),
  clipBehavior: Clip.antiAlias,
  child: InkWell(
    onTap: () => AccountDrawer.show(context, includeNetwork: true),
    child: SizedBox(height: 44, child: Semantics(label: ..., excludeSemantics: true, child: Row(...))),
  ),
)
```

The `Semantics` wraps the CONTENT, not the `InkWell` - the `InkWell` supplies the button
role and the tap action, and a `Semantics` placed outside it with `excludeSemantics: true`
would swallow them. Label: `'{walletName}, on {networkName}. Opens wallet and network'`,
or `'No wallet selected. Opens wallet and network'` when there is no wallet, or
`'{walletName}. Opens wallet and network'` when the network is somehow null. This is the
zero-tap answer to the network being identified by picture alone; comment it as such.

Row, `MainAxisSize.min`: `SizedBox(width: space3)`, the avatar, `SizedBox(width: space4)`,
`Flexible(child: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis))` at `labelMd`
14 w600 `textPrimary`, `SizedBox(width: space2)`,
`Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: gw.textSecondary)` at 5.97:1,
`SizedBox(width: space4)`.

Name is `wallet?.walletName ?? 'No wallet'`. **There is no second line and no address.**
Comment why: the header used to print the name over the truncated address, and on a wallet
imported through the free-text field at
`lib/onboarding/existing_wallet/view/import_security_screen.dart:236` the name IS an
address, so it printed twice. One line halves that. It does not fix it - the fix is
validation on that field, captured as a todo - and nothing here may derive a name from an
address.

Avatar when a wallet exists: `AccountAvatar(wallet: wallet, isSelected: true, size: 32,
networkIconPath: network?.iconPath)`. When there is none: a private 32px `CircleAvatar` on
`brandPrimaryStrong` with `Icons.add` in `textOnBrand` at 7.74:1.

**Additive badge on `AccountAvatar`** in `lib/account/account_drawer.dart`: a new optional
named `String? networkIconPath`, default null. **When null the build returns today's exact
`CircleAvatar` with no `Stack` and no wrapper** - the drawer rows at line 230 pass nothing
and must not change by a pixel. When non-null, wrap in a `SizedBox(size, size)` and a
`Stack` with the avatar filling it and a bottom-right 16px badge: a circular `Container`
filled `surfaceElevated` with 2px padding around a `ClipOval` holding
`Image.asset(networkIconPath)`, `excludeFromSemantics: true`, with the same `errorBuilder`
fallback shape the file's other `Image.asset` uses. Comment the 2px ring: it is a stroke and
not layout spacing, it measures 3.35:1 against Base and 3.66:1 against Polygon so it carries
1.4.11 separation on its own, and 4px would leave an 8px icon.

**In `lib/components/overlay/responsive_overlay.dart`:** delete the private `_MobileHeader`
class, import the new file, use `const MobileHeader()` at its mount, and drop the network
dropdown entry from that mount's `actions`. `_DesktopTopBar` is not read and not edited; the
desktop control track mount at line 183 stays exactly as it is. Fix the em dash at line 877
while you are in the file.

**The test**, `test/components/mobile_header_brand_and_pill_test.dart`. Mount
`MobileHeader` inside a `MaterialApp` + `Scaffold(appBar:)` at a 390x844 surface with the
providers it reads, using the same `_FakeGeniusApi` pattern. Assert every line of
`&lt;behavior&gt;` above.

Two harness facts to respect. First, the test font is not Inter, so **do not assert absolute
text widths**. Assert structure and invariants instead: 44 as a floor, `kWalletPillMaxWidth`
as a ceiling, and brand-lockup width EQUAL across a short-name and a long-name render -
which is a font-independent statement of "the brand does not shrink" and is the single most
valuable assertion in the file. Second, assert the pill's cap against the exported
`kWalletPillMaxWidth`, never a typed 236.
  </action>
  <verify>
    <automated>flutter test test/components/mobile_header_brand_and_pill_test.dart && flutter analyze lib/components/overlay/mobile_header.dart lib/components/overlay/responsive_overlay.dart lib/account/account_drawer.dart</automated>
  </verify>
  <done>
The new test passes, `flutter analyze` is clean on all three lib files, and
`LC_ALL=C grep -n $'\xe2\x80\x94' lib/components/overlay/responsive_overlay.dart lib/components/overlay/mobile_header.dart`
prints nothing (that byte sequence IS the em dash - written as an escape so this plan does
not itself contain the character it forbids). `grep -c 'NetworkDropdownSelector' lib/components/overlay/responsive_overlay.dart`
returns 2 - the import and the single surviving DESKTOP mount at line 183 - proving the
phone mount is gone and desktop is untouched.
  </done>
</task>

<task type="auto">
  <name>Task 3: correct the sketch README, capture the two follow-ups, run the full gates</name>
  <files>.planning/sketches/180-mobile-header-brand-and-wallet/README.md, .planning/todos/pending/2026-08-07-wallet-name-field-accepts-an-address.md, .planning/todos/pending/2026-08-07-network-strip-needs-mainnet-testnet-grouping.md</files>
  <action>
**Rewrite the README's "Blocking dependency" section.** It is not a blocking dependency and
it never was. Replace it with the table from this plan's `&lt;the_corrections&gt;`: both
assets, their real paths under `lib/assets/images/`, their canvas sizes, their measured
opaque bounding boxes, the `package: 'genius_wallet'` load form, and the four existing call
sites. State plainly that the search looked in `assets/images/` and that this repo uses the
package-style layout, so the finding was wrong rather than merely incomplete. Delete the
three-option list - reusing a coin mark and drawing a gradient square are both dead.

Add what the sketch could not know: `logo_and_title.png` renders the wordmark **GNUS.AI**,
the header ships **GeniusAI**, and that is an open product question rather than a layout
one.

Add the missing-density constraint as a real finding: no `2.0x` or `3.0x` directory exists
anywhere in `lib/assets/images/`, the mark's opaque glyph is 28x37, and the upscale table
from this plan.

**Fix the two contrast rows.** `borderStrong` is 2.11:1 and not 2.6:1; `surfaceMenu` is
1.12:1 against the body and not 2.9:1. Add the general finding underneath, because it
outlives this sketch: no two dark surface tokens in this palette separate by even 1.2:1, so
a surface swap can never give a bar an edge - only a line can.

**Update the geometry table** to the measured numbers: brand at 93.0 with the cropped mark
and the one-word string, and 17px of slack at the 236 cap rather than 4.

Mark the README as amended, dated 2026-08-07, naming this quick task. Do not silently
rewrite history - a sketch that was wrong and was corrected is more useful than one that
looks like it was always right.

**Two todos.**

`2026-08-07-wallet-name-field-accepts-an-address.md`: the free-text wallet name field at
`lib/onboarding/existing_wallet/view/import_security_screen.dart:236` writes
`walletName: walletNameController.text` with no validation, so an address can be stored as a
name. Record that the header no longer doubles it - one line instead of two - so the symptom
is halved but the cause is untouched, that SDK wallets are unaffected because
`app_bloc.dart:616` names them, and that the drawer rows still show the name and the address
as two lines and legitimately need both.

`2026-08-07-network-strip-needs-mainnet-testnet-grouping.md`: 10 networks in
`assets/json/networks/networks.json`, 5 of them testnets, totalling 1294px of chips against
350px of visible sheet width. Record that current-first ordering keeps the answer to "which
chain am I on" free but the tenth network costs about three swipes, that the fix is a
mainnet or testnet field in the JSON so the strip can group them, and that inferring it from
the name is a guess that breaks silently.

**Then the full gates**, both from the repo root, both to completion.
  </action>
  <verify>
    <automated>flutter analyze; flutter test 2>&1 | tail -3</automated>
  </verify>
  <done>
`flutter test` reports **All tests passed** with a count of at least 1081 plus the new cases,
and zero pre-existing tests edited - confirm with `git diff --stat test/` showing only the
two NEW files. `flutter analyze` reports zero issues in any file this plan touched; any
survivor still points at the parallel plan's `test/components/assets_header_scheme_c_test.dart`.
The README no longer claims the logo is missing, and both todos exist.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
Sketch 180 scheme B, on the phone shell only. The header now carries the brand mark plus the
wordmark `GeniusAI` at top-left, and ONE wallet pill on the right - a 32px avatar with a
16px network badge, the wallet name, a caret - replacing the two controls that were there.
Tapping it opens a single sheet titled "Wallet and network": a horizontal network strip on
top, then the SDK Accounts and Your Accounts sections exactly as sketch 174 built them. The
app bar gained a real bottom edge. The desktop header did not change.
  </what-built>
  <how-to-verify>
Run on the iPhone, dark mode. `flutter run -d <device> --dart-define=GW_DEV_TOOLS=true`.
If the field will not accept typing, that is a second app instance holding the Hive lock -
quit "Genius Wallet.app" fully and relaunch. Use a full relaunch, not hot restart `R`,
because a new widget tree is involved.

**1. The wordmark string.** It must read `GeniusAI` - one word, no space, no full stop.
This is DECIDED, not open; you are checking it rendered correctly and is not clipped, not
choosing it.

**2. The logo's sharpness at 3x.** Look closely at the brain circuitry inside the head. The
only asset in the repo is 38x38 with no @2x or @3x variant, so at 24pt it is upscaled about
1.90x. Is it acceptable, or does it read soft or mushy? Two answers are useful: "fine, ship
it", or "send a 114x114 export" - which drops straight in with zero layout change.

**3. A brand-string conflict that needs your call.** The splash screen and wallet creation
render a different image, `logo_and_title.png`, and that image says **GNUS.AI** - capitals,
with a full stop. So the app will now say GNUS.AI on launch and GeniusAI in the header. Is
that intentional, or should one of them change? Nothing was changed on the splash.

**4. A long wallet name.** Switch to an SDK account named `Super Genius Wallet 2`. The name
should render in full without an ellipsis, and the brand block on the left must not move by
a pixel. Then rename a wallet to something 60 characters long: it should ellipsize inside
the pill and the brand block still must not move.

**5. An address-shaped wallet name.** Import or rename a wallet so its NAME is an address.
It should print **once**, as an odd-looking name. It used to print twice - name on one line,
truncated address underneath. It is halved, not fixed; the real fix is validation on the
import field and it is captured as a todo.

**6. The no-wallet state.** With no wallet selected the pill shows a `+` avatar and the words
`No wallet`, and still opens the sheet so `Add Wallet` is reachable.

**7. How many taps a network switch costs.** Count them out loud. It should be **2** - tap
the pill, tap a chip - which is exactly what it cost before. Also check that the chip for the
chain you are currently on is FIRST in the strip and readable without scrolling, and that
your own wallets are visible below the strip without scrolling. Reaching the tenth network
needs about three horizontal swipes; that is the accepted cost and grouping mainnets versus
testnets is captured as a todo.

**8. The badge, and whether it is enough.** The 16px network badge on the avatar is a
change-detector, not an identifier - it tells you the chain moved, it does not tell you which
chain. The chain is named in words inside the sheet and in the VoiceOver label. If that is
not enough on the device, say so: the named fallback is a second line in the pill carrying
the network name at 11px, which costs no width and does not bring back the double address.

**9. The bar's edge.** There should now be a visible 1px line under the header separating it
from the page. It was 0.5px at 1.34:1 and is now 1px at 2.11:1. It cannot go higher without
breaking the app's own rule about which hairline token means what.

**10. The desktop header.** Open the app in a wide window and confirm the desktop top bar is
completely unchanged - same logo, same nav, same chain and wallet chips in the control track.
  </how-to-verify>
  <resume-signal>Type "approved", or name which of the ten is wrong</resume-signal>
</task>

</tasks>

<threat_model>
## Trust boundaries

| Boundary | Description |
| --- | --- |
| user free text to persisted wallet name | `import_security_screen.dart:236` stores unvalidated text as a wallet name, which the header then renders |
| Hive to UI | the persisted network chainId and rpcUrl are read at boot and drive which RPC balances are read from |
| bundled JSON to network list | `assets/json/networks/networks.json` supplies every rpcUrl the app will talk to |

## STRIDE register

| Threat ID | Category | Component | Severity | Disposition | Mitigation |
| --- | --- | --- | --- | --- | --- |
| T-HBR-01 | Spoofing | wallet name rendered in the pill | medium | mitigate | the pill renders `walletName` through a `Text` with `maxLines: 1` and a hard 236 cap, so a crafted name cannot overdraw the brand block or the caret and cannot impersonate chrome. The cap is asserted by test, not by eye. |
| T-HBR-02 | Tampering | network selection persistence | high | mitigate | `NetworkSelection.apply` writes the cubit and BOTH Hive keys in one place. A partial write - cubit without Hive - would silently revert the chain on next launch and read balances from an RPC the user did not choose. Single implementation, one call site each for desktop and mobile. |
| T-HBR-03 | Information disclosure | header address line | low | mitigate | the header no longer renders any address, truncated or whole. Asserted by test on an address-shaped name. |
| T-HBR-04 | Denial of service | missing or corrupt network icon asset | low | mitigate | every `Image.asset` in the badge and the chips carries the same `errorBuilder` sized-box fallback the existing rows use, so a bad `iconPath` degrades to blank rather than throwing during an `AppBar` build. |
| T-HBR-05 | Elevation of privilege | none | low | accept | no permission, credential, key or signing path is touched. This is presentation and one persisted preference. |
| T-HBR-SC | Tampering | package installs | low | accept | **no package-manager installs**. No dependency is added, removed or upgraded; `pubspec.yaml` is read for its asset declarations and not edited. The legitimacy gate does not fire. |
</threat_model>

<verification>
1. `flutter analyze` - zero issues in every file this plan touched. Any survivor must still
   point at the parallel Assets plan's `test/components/assets_header_scheme_c_test.dart`.
2. `flutter test` - **All tests passed**, at least 1081 plus the new cases, zero failures.
3. `git diff --stat test/` shows only the two NEW test files. No pre-existing test edited,
   no assertion relaxed. `test/account/account_drawer_show_test.dart` in particular passes
   untouched.
4. `LC_ALL=C grep -rn $'\xe2\x80\x94' lib/components/overlay/mobile_header.dart lib/components/overlay/responsive_overlay.dart lib/account/account_drawer.dart lib/network/network_dropdown_selector.dart`
   prints nothing.
5. `git diff --stat` names no file under `/banxa` or `/squidrouter`, and none of the five
   owned by the two parallel plans: `coins_screen.dart`, `gw_section_title.dart`,
   `gw_view_all_link.dart`, `transaction_displays.dart`, `transaction_utils.dart`.
6. `_DesktopTopBar` shows no diff, and the desktop control track's network mount at
   `responsive_overlay.dart:183` survives.
7. **No commits.** `git log --oneline -1` matches the SHA this task started from.
</verification>

<success_criteria>
- The phone header shows the brand mark plus `GeniusAI` at top-left and exactly one wallet
  control at the right. `NetworkDropdownSelector` is mounted nowhere in the phone shell.
- Tapping that control opens one sheet carrying the network strip above the two sketch-174
  account sections. No third wallet surface exists.
- A network switch costs 2 taps, the same as before, and the current chain is named in text
  in the sheet and in the pill's accessible name.
- The header prints no address. An address-shaped wallet name appears once, not twice.
- Every interactive target in the header and the strip is at least 44 logical px tall.
- The app bar has a 1px `borderStrong` bottom edge at 2.11:1.
- The desktop header is unchanged.
- The sketch 180 README no longer claims the logo is missing, and its two wrong contrast
  numbers are corrected.
- Both gates green, no pre-existing test edited, no commits created.
</success_criteria>

<output>
Create `.planning/quick/20260807-mobile-header-brand-and-wallet-pill/SUMMARY.md` when done.
</output>
