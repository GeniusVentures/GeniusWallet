---
phase: quick-260807-s7n
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - lib/components/overlay/nav_destinations.dart
  - lib/components/overlay/more_sheet.dart
  - lib/components/overlay/responsive_overlay.dart
  - lib/components/overlay/mobile_header.dart
  - lib/components/coins/view/coins_screen.dart
  - lib/navigation/router.dart
  - test/components/mobile_nav_destinations_test.dart
  - test/components/mobile_header_brand_and_pill_test.dart
autonomous: false
requirements: [QUICK-260807-S7N]

must_haves:
  truths:
    - "The phone bottom bar reads Home, Assets, [Swap dock], Activity, News. Sketch 182 scheme S7, picked by Jakub on 2026-08-07."
    - "The header's right side is sketch 183 scheme F: a 44x44 wallet chip keeping its `surfaceMenu` fill and `borderControl` edge, then `space6`, then a bare 44x44 hamburger with no container at all. The cluster measures exactly 100.00 against the shipped pill's 223.94."
    - "NOTHING became unreachable. `More` leaves the bar and the hamburger lands IN THE SAME TASK, opening the SAME derived sheet body that is behind `More` today. Markets, Web, Feedback and Settings are all still one tap from anywhere."
    - "`/assets` gains its second entrance in the whole app and its FIRST navigational one. Before this task its only entrance was the dashboard Assets panel's `View all` link."
    - "The desktop bar is byte-identical. `allDestinations` is not edited, `_DesktopTopBar` is not edited, and on iOS `GeniusBreakpoints.isMobileApp()` makes `DesktopOverlay` unreachable at any width."
    - "The header no longer prints the wallet name anywhere. That is what F is, and its cost is measured and put to Jakub rather than shipped quietly: `AccountAvatar` paints the CURRENCY, not the wallet, so two ETH wallets now render identical headers."
    - "The mobile bar's destination set and the header's two hit boxes are PINNED by tests for the first time. Nothing asserted either before today."
  artifacts:
    - lib/components/overlay/nav_destinations.dart
    - lib/components/overlay/more_sheet.dart
    - test/components/mobile_nav_destinations_test.dart
  key_links:
    - "`moreDestinations` is a DERIVED getter, not a written list. It is `allDestinations` minus `/swap` minus whatever the mobile bar shows. Editing the bar edits the sheet with no second edit. A test asserts the union rather than the members."
    - "`/assets` is NOT a member of `allDestinations`, so the derivation CANNOT catch it. It is reachable only while it is on the bar. A ledger test names this so a future tab-set change cannot strand it silently."
    - "Both header controls live inside `AppBar.title`, never `actions`. In `actions` the title Row drops from 342.00 to 246.00 and the BRAND becomes the thing that shrinks under Dynamic Type, which is backwards. `actions` stays exactly as it is, one `SizedBox(width: space8)`, so nothing the header marks FROZEN is touched."
    - "The two controls carry DIFFERENT decorations on purpose. The wallet holds a value so it gets the chip recipe at 3.30:1; the hamburger holds nothing so it gets a bare glyph at 19.29:1. Two identical stadiums 12px apart would read as a segmented control, which is scheme A's defect and the reason F beat it."
    - "`_MobileMoreItem` must be DELETED, not left unused. An unreferenced private class fails `flutter analyze`, which is the gate that keeps the removal honest."
---

<objective>
Two decisions from Jakub on 2026-08-07 that only work together, so they ship
together.

**Sketch 182 scheme S7** - the phone bottom bar becomes **Home, Assets,
[Swap dock], Activity, News**, and the menu leaves the bar for a hamburger in
the header:

> Jakub, 2026-08-07: you can implement S7 now, but without the menu opening yet.

**Sketch 183 scheme F** - the header's right side becomes a 44x44 wallet chip
plus a bare 44x44 hamburger, replacing the 223.94px pill:

> Jakub, 2026-08-07: let's try 183F; if it turns out badly we can fall back to 183C later.

So: build S7 and F, and do NOT build the redesigned menu. The hamburger opens
the sheet that is behind `More` today, unchanged. Sketch 184 (the menu page) is
still unpicked and is out of scope.

Purpose: the bar's fourth slot stops being the one item that is not a place,
`/assets` reaches the bar, and the header's right side drops from 57.4% of the
bar to 25.6%.

Output: two new files that make the navigation model testable, a header carrying
the F cluster, a four-destination bar, the first tests that pin any of it, and a
blocking on-device checkpoint carrying the one thing F gives up.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
@$HOME/.claude/gsd-core/templates/summary.md
</execution_context>

<context>
@AGENTS.md
@.planning/sketches/182-bottom-nav-destinations/README.md
@.planning/sketches/181-wallet-control-compact/README.md
@.planning/sketches/183-wallet-hamburger-treatments/README.md
@lib/components/overlay/responsive_overlay.dart
@lib/components/overlay/mobile_header.dart
@lib/account/account_drawer.dart
@lib/navigation/router.dart
@lib/theme/genius_wallet_consts.dart
@lib/theme/genius_wallet_typography.dart
@lib/components/coins/view/coins_screen.dart
@test/components/mobile_header_brand_and_pill_test.dart
</context>

<findings>

## Baseline, measured on this tree while planning

`flutter test`: **1158 passing, 3 skipped, 0 failing.** Measured 2026-08-07 on
`redesign/navigation-260806` with the working tree as it stands. It has moved a
dozen times today - **re-measure before you start** and record both numbers.

`flutter analyze`: **No issues found**, repo-wide. It must end there.

Branch `redesign/navigation-260806`. Nothing is committed on it; the tree is
dirty across most of `lib/`. **`git status` is not a usable fence check today.**

---

## 1. The trap, verified line by line rather than trusted

`responsive_overlay.dart:140-147`:

    List<_TabDestination> get _moreDestinations => _allDestinations
        .where((d) => d.visible
            && d.path != '/swap'
            && !_mobileDestinations.any((m) => m.path == d.path))
        .toList();

**CONFIRMED: the sheet is DERIVED, not written.** The briefing's reading is
correct in every particular.

`_allDestinations` (lines 41-83) has **exactly eight entries**, in this order,
with one path that is not what its label suggests:

| Label | Path | Visible |
| --- | --- | --- |
| Dashboard | `/dashboard` | always |
| Transactions | `/transactions` | always |
| Swap | `/swap` | always, and excluded from the sheet by name |
| Markets | `/markets` | always |
| News | `/news` | always |
| Web | `/web` | `!Platform.isLinux`, so YES on iOS |
| **Feedback** | **`/logs`** | always |
| Settings | `/settings` | always |

So under S7 the derived sheet becomes exactly:

**Markets, Web, Feedback (`/logs`), Settings** - plus the `Accounts` row the
sheet body appends by hand.

**If `More` were removed from the bar without an entrance being added in the
same change, all four would become unreachable on the phone, Settings
included.** That is a strictly worse outcome than today. It is the same class of
defect the header task caught, where `walletCubit.selectNetwork()` had one call
site and unmounting its widget would have removed mobile's only way to change
network.

**Therefore the hamburger and the bar change are ONE task.** Not two, and not
one task with a follow-up.

## 2. `/assets` is not in the derivation, confirmed, and what that costs later

**CONFIRMED: `/assets` is NOT a member of `_allDestinations`.** Read the list
above. Phase 25 added the route straight to the router (`router.dart:239`) and
never added a destination entry, so `/assets` **cannot appear in the derived
sheet at any time, under any bar configuration.**

Its only entrance in the entire app today is `coins_screen.dart:409`, the
dashboard Assets panel's `View all` link. Verified: `grep -rn "'/assets'" lib/`
returns exactly three hits - the route, a comment beside it, and that one link.

Under S7 it gets a tab, which fixes the reachability. **What is NOT fixed is the
asymmetry**, and this is the part that has to be written down rather than
discovered:

> Every OTHER destination on the bar is a member of `allDestinations`, so
> removing it from the bar puts it in the sheet automatically. `/assets` is
> not, so removing it from the bar returns it to having exactly one entrance -
> a `View all` link on one panel of one page. **The self-repairing property of
> the derivation does not cover it.**

Three ways to answer that were considered:

1. **Add `/assets` to `allDestinations`.** REJECTED: that list drives the
   DESKTOP bar, which would go from eight tabs to nine. The briefing forbids
   changing what desktop shows.
2. **Do nothing.** REJECTED: it is a silent trap for the next tab-set change,
   and there has already been one this week.
3. **A ledger test plus a comment on the entry.** ADOPTED. Task 2 asserts that
   any mobile-bar path which is not a member of `allDestinations` appears in a
   written `kNonDerivableMobilePaths` map naming its fallback entrance. Change
   the tab set again and the test reddens and tells you what it costs.

## 3. Routes verified, not assumed

`grep -n "path:" lib/navigation/router.dart`:

| Path | Line | Inside the shell |
| --- | --- | --- |
| `/dashboard` | 223 | yes |
| `/transactions` | 225 | yes |
| **`/assets`** | **239** | **yes** |
| `/swap` | 241 | yes |
| `/markets` | 268 | yes |
| **`/news`** | **269** | **yes** |
| `/logs` | 317 | yes |
| `/settings` | 326 | yes |

**Both new tab destinations exist and both are inside the `ShellRoute`**, which
is what keeps the header and the bar mounted when you land on them. No new route
is needed. Task 2 pins this with a source scan so a renamed route reddens the
suite instead of shipping a dead tab.

## 4. The header under F: the width problem disappears, and one arrives

### The budget at 390pt, before and after

Every width below is an advance-width sum read from the bundled
`assets/fonts/Inter-*.ttf` at unitsPerEm 2048, not estimated. They agree with
sketch 183's held-constant table to the hundredth.

| Piece | px | |
| --- | ---: | --- |
| Bar | 390.00 | |
| `titleSpacing`, charged on **BOTH** sides (2 x `space8`) | -32.00 | `NavigationToolbar` lays the middle slot at `width - leading - trailing - middleSpacing * 2` |
| `actions`: one `SizedBox(width: space8)` | -16.00 | **UNCHANGED by this task** |
| **title Row** | **342.00** | |
| `BrandLockup` = 21.3684 + 8 + 76.6934 | -106.06 | mark `29/38 * 28`, `space4`, `GNUS.AI` at Inter Bold 18 |
| **F cluster** = 44 + `space6` 12 + 44 | **-100.00** | was 223.94 as a pill |
| **Free space left in the title Row** | **135.94** | was 12.00 |

**`actions` is not touched and neither is `titleSpacing`.** Both lines sit under
the header's FROZEN comment, and F needs neither. The pill was a remainder
absorber; the cluster is a fixed 100. There is no width crisis left to solve.

**One clarification, resolved from the sketch rather than guessed.** Sketch 183's
"If F ships" table says the hamburger has "`space6` to its right", which reads
like a second spacer. It is not: the sketch's own held-constant table lists ONE
`space6` gap and a cluster of exactly 100.00, and its free-space figure is
`342 - 106.06 - 100 = 135.94`. **There is one `space6`, between the two
controls.** Adding a trailing spacer would make the cluster 112 and contradict
every number the sketch pins. Do not add one.

### The two treatments, and why they differ on purpose

This is the whole of F and it must not be "tidied" later into a matching pair.

| Control | Decoration | Identifying element | Ratio | 1.4.11 (3:1) |
| --- | --- | --- | ---: | --- |
| Wallet chip | `Material(color: surfaceMenu, shape: StadiumBorder(side: BorderSide(borderControl)), clipBehavior: antiAlias)`, unchanged from the shipped pill | the `borderControl` edge, composited `#636569` | **3.30:1** | PASS |
| Hamburger | **none at all** - no `Material`, no `Container`, no border, no fill | the glyph itself, `textPrimary` `#FFFFFF` | **19.29:1** | PASS |

`surfaceMenu` on `surfaceElevated` is **1.11:1**, so a fill identifies nothing
in this bar - which is why the wallet needs its edge and why the hamburger is
better off with no container than with one. Sketch 183's variant B (filled, no
border) fails at 1.11:1 and variant E (`borderSubtle`) fails at 1.36:1; both were
drawn to be refused.

The split also fixes scheme A's one real defect for free: **two identical
stadiums 12px apart read as a segmented control** at a 56px pitch. F's pair
cannot, because only one of them is a stadium. Ink gap under F is `12 + 13 = 25`
against A's 12.

### The glyph is 18, not 24

Sketch 183 derives its ink gaps from "the hamburger's 18 px bars stop 13 px
inside theirs": `(44 - 18) / 2 = 13`. **`Icons.menu` renders at 18**, the same
size as the caret it replaces. Using 24 would break the sketch's measured
separation and is not what Jakub looked at.

### What F deletes, exactly

The wallet control is a **deletion**, not a redesign. Per sketch 183's file
table, its `Material` / `StadiumBorder` / `borderControl` decoration does not
move. What goes: the name `Flexible`, the `space2`, the caret `Icon`, and the
trailing `space4`. The leading `space3` becomes symmetric padding around the
32px avatar in a 44px box - `6 + 32 + 6 = 44`, which is exactly the sketch's
"the disc stops 6 px inside its 44 box". `space3` = 6 is the ONE documented
exception to the 4-pt grid and this is a legitimate use of it.

**`kWalletPillMaxWidth` is deleted.** There is nothing left to cap. This is the
one place the plan removes a public constant, and three test assertions depend
on it - see finding 5.

## 5. THE HEADER STOPS SAYING WHICH WALLET IS LIVE, and that has to be said out loud

This is the cost of F, it is measured in sketch 181, and it is the reason the
checkpoint exists.

`AccountAvatar.build` (`account_drawer.dart:602`) paints a `CircleAvatar` with
`backgroundColor: brandPrimaryStrong` and a child of
`Image.asset('assets/images/crypto/${wallet.currencySymbol.toLowerCase()}.png')`.
**No per-wallet colour, no blockie, no seed.** Sketch 181, finding 1, verbatim:
"Two ETH wallets render the same pixels."

And finding 2, the double-icon defect: the 32px circle draws
`crypto/{currencySymbol}.png` while the 16px badge draws `network.iconPath`,
which for Ethereum in `networks.json` is `assets/images/crypto/eth.png`. **For
an ETH wallet on Ethereum - this app's default state - those are the same
file**, now rendered 3px apart inside a 44px control.

So the header's information content changes like this:

| Question | Before F | After F |
| --- | --- | --- |
| Which wallet? | its NAME, in text, until it ellipsized | **nothing visible.** The picture is of the currency |
| Which chain? | a 16px badge picture, plus the name in the semantic label | a 16px badge picture, often the same picture as the disc |
| Which wallet and chain, for a screen reader | the semantic label | **unchanged** - the semantic label still names both |

**The semantic label is now the only place in the header that identifies
anything in words.** It must survive the deletion byte-for-byte and Task 2
asserts all three of its branches.

**The named remedy exists and is NOT in this task's scope.** Sketch 181 scheme
E puts a two-character monogram inside the same 44px circle, at zero extra
width, answering which wallet AND which chain; 181's own "If F ships" table
lists it as an additive `monogram` branch on `AccountAvatar`, and 183 renders
every variant with it. The relay's instruction is explicit that the wallet
control's decoration does not change and that the diff is a deletion, and the
monogram lives in `lib/account/account_drawer.dart`, which is not among this
task's files.

**So: build F with the shipped avatar, and put the monogram to Jakub at the
checkpoint as a measured consequence.** Do not add it silently and do not ship
the regression without naming it.

## 6. A Dynamic Type overflow that F creates, and its fix

The cluster is fixed at 100 and non-flex. `BrandLockup`'s wordmark is capped at
`maxWidth: 216`; the mark is an `Image` and does not scale, so the lockup maxes
out at `21.37 + 8 + 216 = 245.37`.

The `Expanded` holding the cluster receives `342 - lockup - 12` and needs 100:

    overflow when  342 - lockup - 12 < 100
                   lockup > 230.00
                   wordmark > 200.63
                   textScaler > 200.63 / 76.6934 = 2.616x

iOS AX5 reaches about 3.1x, so it is real, and above 2.816x the cap pins the
wordmark at 216 and the overflow settles at a constant 15.37px.

Before F this could not happen: the pill was the `Expanded` and absorbed
everything down to its own 76px of chrome, so a huge lockup produced a bare
ellipsis rather than a RenderFlex overflow.

**The fix, and it is an improvement rather than a patch: lower the wordmark cap
from 216 to 196.** On the grid at 4 x 49. Max lockup becomes 225.37, the
`Expanded` gets 104.63 against the 100 it needs, and there is **4.63px of
margin at every scale**. The next grid step up, 200, also works but leaves only
0.63px, which is too thin to defend against rounding.

The headroom figure the comment reports drops from `216 / 76.69 = 2.82x` to
`196 / 76.69 = 2.56x`. **The 2.82x was never real** - at 2.82x today's pill
already rendered nothing but an ellipsis. The new number is honest.

**Verify before changing it.** Task 1 pumps the header at 1.0, 2.0, 2.5 and 3.0
and asserts no exception. If the overflow does not reproduce, leave 216 alone
and report why.

Also check rather than assume: if `Icon.applyTextScaling` resolves true in this
theme, the hamburger's 18px glyph grows inside a fixed 44px box and overflows it
independently of the lockup. Measure it and report the value.

## 7. Label widths, re-verified, and the ceiling is not where anyone is looking

The bar's Row lays out four `Expanded` tabs around one fixed `_kDockSlotWidth`
of 84, and `_MobileBarSlot` adds VERTICAL padding only. So each label gets
`(390 - 84) / 4 = 76.50px` with nothing taken off it.

Measured from the bundled Inter faces at `fontSize: 10`, `labelMd` (no
letterSpacing, so the advance sum is the whole width):

| Label | w500 | w600 | Fits 76.50 | Horizontal ceiling |
| --- | ---: | ---: | --- | ---: |
| **Home** | 28.24 | 28.46 | yes | 2.69x |
| **Assets** | 32.52 | **33.20** | **yes** | **2.30x** |
| **Activity** | 36.21 | **37.15** | **yes** | **2.06x** |
| **News** | 27.11 | **27.39** | **yes** | **2.79x** |
| Markets (leaving the bar) | 38.93 | 39.57 | yes | 1.93x |
| More (deleted) | 24.91 | 25.20 | yes | 3.04x |

**S7 RAISES the bar's horizontal ceiling**, from 1.93x (Markets, today's binding
label) to 2.06x (Activity). Every candidate fits with room. Label length is not
an argument for or against anything here, exactly as sketch 182 said.

**But the horizontal ceiling is not the binding one, and this has never been
recorded.** The vertical budget inside the 60px bar:

    2 x space4 padding      16.00
    icon                    23.00   (_kIconSize)
    space2                   4.00
    labelMd line box        13.85   (fontSize 10 x height 18/13)
    -----------------------------
    total                   56.85   against _kMobileBarHeight = 60.00

That leaves **3.15px of slack**, and the label line is the only term that
scales. The column overflows once `13.846 * s > 17.00`, which is **textScaler
above roughly 1.23x** - far below every label's horizontal ceiling.

**So the honest answer to "state the Dynamic Type ceiling per label" is: no
label ever truncates, because the bar overflows vertically first, at about
1.23x.** This is PRE-EXISTING - today's bar has identical geometry - and S7
neither causes it nor worsens it. It is **out of scope** here: fixing it means
clamping `textScaler` on the bar or restyling the slot, which is a design
decision. Task 3 files it as a todo, and Task 2 pins the 56.85 against 60.00 as
a measured assertion so it cannot silently get worse.

## 8. What `More` becoming a hamburger does to the active tab

`_currentIndex` (lines 98-106) matches with `location.startsWith(dest.path)` and
returns **-1** when nothing matches. The 24-05 comment above it explains why: it
used to `return 0`, which lit Dashboard on every unlisted shell route, so you
could stand on the Buy form and the bar would claim you were on Dashboard.

**There is no fallback to restore. -1 is the shipped, deliberate answer.**
`_MobileMoreItem` was never drawn selected either, because no route stood behind
it.

The full before-and-after ledger for every in-shell route:

| Route | today | after S7 |
| --- | --- | --- |
| `/dashboard` | Home | Home |
| `/transactions` | Activity | Activity |
| `/assets` | **nothing** | **Assets** |
| `/news` | **nothing** | **News** |
| `/markets` | Markets | **nothing** |
| `/swap` | dock glows (`onSwap`, separate from the index) | unchanged |
| `/web`, `/logs`, `/settings` | nothing | nothing |
| `/buy`, `/token-info` | nothing | nothing |

**Unlit shell routes go from seven to six.** One route (`/markets`) loses its
lit tab and two (`/assets`, `/news`) gain one. Nothing lights WRONGLY, which is
the failure 24-05 fixed and the property that matters.

Lighting the hamburger instead was considered and REJECTED: the header has no
selection idiom, inventing one is the redesigned-menu work, and sketch 184 is
unpicked.

No prefix collision exists under S7: `/dashboard`, `/assets`, `/transactions`
and `/news` are pairwise non-prefixing, so `startsWith` is unambiguous. Task 2
pins the whole ledger as a pure unit test.

## 9. Nothing pins the mobile bar today, and that is why this is easy to get wrong

`grep -rln "responsive_overlay" test/` returns three files, and **not one of
them asserts anything about the bar's destinations**:

- `drawer_footer_inset_test.dart` uses `kMaxBottomSafeInset` only.
- `dev_tools_bubble_persistence_test.dart` mentions the file in a comment.
- `mobile_header_brand_and_pill_test.dart` is about the header.

`global_swap_fab_host_test.dart` asserts only that the FAB is ABSENT on the
mobile shell. `grep` for `find.text('Markets')`, `find.text('Activity')` and
`find.text('More')` across `test/` returns nothing.

**So the briefing's expectation that phase 24 tests assert the bar's contents
does not hold: nothing does.** The bar's destination set could be changed today
with a green suite. That is the strongest argument in this plan for Task 2, and
Task 2 is what makes the NEXT change to this bar safe.

## 10. Exactly which shipped header assertions move, and why each is at least as strict

`mobile_header_brand_and_pill_test.dart` is the only file asserting the header.
Five of its twelve cases are affected. **One assertion is DELETED, and it is the
only deletion in this plan - it is called out here so it is a decision on the
record rather than a casualty.**

| Case | Today | After F | Strictness |
| --- | --- | --- | --- |
| `NO network dropdown ... exactly one control remains` | `WalletPill` findsOneWidget | adds `HeaderMenuButton` findsOneWidget, and the comment stops claiming one control | **STRICTER** - two controls pinned instead of one |
| `the pill clears the 44px touch target floor` | `height >= 44` | `getSize == Size(44, 44)` on BOTH controls | **STRICTER** - exact equality on both axes replaces a floor on one |
| `THE BRAND DOES NOT SHRINK` | lockup equal under a 4-char and a 60-char name; `pill <= kWalletPillMaxWidth`; `longPill > shortPill` | lockup equal; cluster **== 100.00** and pill **== 44.00** under both names | **STRICTER** - "the pill grew to its cap" becomes "the right side is name-INDEPENDENT", which is a stronger statement of the same invariant. `longPill > shortPill` is now false BY CONSTRUCTION and its replacement proves why |
| `with no wallet the pill reads "No wallet"` | `find.text('No wallet')` plus `onTap != null` | the `_NoWalletAvatar` plus-glyph is mounted, `onTap != null`, and the semantic label is exactly `No wallet selected. Opens wallet and network` | **STRICTER** - pins the semantic path, which is now the ONLY textual identity in the header |
| `REAL INTER, 390pt` | `pill == available`; `pill <= 236`; **`pill > 180`** | lockup **== 106.06** unchanged; cluster **== 100.00**; free space **== 135.94**; pill **== 44.00**; hamburger **== 44.00**; gap **== 12.00** | equality replaces three inequalities, EXCEPT for `pill > 180` - see below |

**The one deletion: `expect(pill, greaterThan(180))`.** Its stated reason is
"the pill must stay wide enough to be the header control it is: avatar + a
readable name + the chevron". **F deletes the name and the chevron.** The
assertion is not being weakened, relaxed or skipped - its SUBJECT no longer
exists, and keeping it would mean keeping a 180px control F was picked to
remove. Its replacement, `pill == 44.00` exactly, is stricter in form but is a
different statement, and that difference goes in the SUMMARY and to Jakub.

Seven cases pass untouched: the wordmark once, the mark once, the address
absence (now trivially, so Task 2 strengthens it), the bottom edge, the mark at
28, the wordmark at 18, and the harness-width debug case (minus its cap
reference).

## 11. `/assets` must switch from `push` to `go`, and the code says so itself

`coins_screen.dart:409` calls `context.push('/assets')`, and the comment above
it justifies the choice with a premise this task falsifies:

> "`push`, not `go` - `/assets` is a content page, not a bottom-nav tab, so it
> must be poppable back to the dashboard."

`router.dart:235` repeats it: "Assets is NOT a nav tab (the bar is Home /
Markets / dock / Activity / More)".

Under S7 `/assets` IS a bottom-nav tab, so both comments become false the moment
the bar changes, and two entrances to one route would have different back
behaviour, which reads as randomness. The precedent is in the tree already:
`transactions_slim_view.dart:363` uses `context.go('/transactions')` with the
comment "`go`, not `push` - `/transactions` is a bottom-nav destination".

This is one line plus two comment rewrites, it is CAUSED by this task, and
sketch 182 names it as one of three things the winner must ship with. It is in
scope. The other two things sketch 182 names - a Buy GNUS CTA on the Assets zero
state, and the shape of the redesigned menu - are NOT in scope.

## 12. Why two new files, and why there is no import cycle

The hamburger lives in `mobile_header.dart`. The sheet it must open is
`_MoreSheetBody`, private to `responsive_overlay.dart`, which already imports
`mobile_header.dart`. Importing back would create a cycle.

The house pattern is already on record in `mobile_header.dart`'s own test file:
"Extracting it to `mobile_header.dart` is what makes every assertion below
possible, and that is half the reason the extraction happened." Do the same
thing again:

    nav_destinations.dart   <- no project imports at all
        ^            ^
        |            |
    more_sheet.dart  |      <- imports nav_destinations
        ^            |
        |            |
    mobile_header.dart      <- imports more_sheet
        ^
        |
    responsive_overlay.dart <- imports mobile_header, more_sheet, nav_destinations

No cycle, and both new units are mountable in a test on their own.

## 13. `GWGradientBorderCard` is not the component, and the reason is not taste

Sketch 183 checked it and refused it for scheme D, which is not even the scheme
that won. Recorded here so nobody reaches for it: its `onTap` path is
`Material(color: transparent) > InkWell > card`, so the splash paints on a
transparent Material BEHIND an opaque gradient `Container` and is never seen.
The shipped `WalletPill` does the opposite - `Material` outside, `InkWell`
inside, `clipBehavior: Clip.antiAlias` - so its ripple is visible and clipped to
the stadium. On a 44px header button, tap feedback is most of the feedback there
is. **Keep the shipped recipe. F needs no gradient, no new component and no new
token.**

</findings>

<constraints>

- **Do NOT create any commit.** Not per task, not at the end. Leave the tree
  dirty for Jakub. This overrides the execute-plan workflow's commit steps.
- **Do NOT design the redesigned menu.** The hamburger opens today's sheet body
  with today's rows and today's title. Sketch 184 is unpicked and out of scope.
- **Do NOT add sketch 181 scheme E's monogram.** `lib/account/account_drawer.dart`
  is not among this task's files. Its absence is a named consequence that goes
  to Jakub at the checkpoint, not a gap to close here.
- **Do NOT give the hamburger a container.** No `Material`, no `Container`, no
  border, no fill. That is scheme A or B, both of which lost, and A's specific
  defect is that two identical stadiums 12px apart read as a segmented control.
- **Do NOT use `GWGradientBorderCard`** or any gradient on either control. See
  finding 13.
- **Do NOT change what desktop shows.** `allDestinations` keeps all eight
  entries in their current order. `_DesktopTopBar`'s diff must be nothing but
  symbol renames.
- **Do NOT touch `titleSpacing` or `actions`.** Both sit under the header's
  FROZEN comment and F needs neither. `actions` stays as one
  `SizedBox(width: GeniusWalletConsts.space8)`.
- **Both controls stay inside `title`.** In `actions` the title Row drops from
  342.00 to 246.00 and the brand becomes what shrinks under Dynamic Type.
- Nothing under `lib/banxa/` or `lib/squid_router/`.
- Mobile only, iOS, dark mode first. Light mode is a later dedicated pass.
- Existing `GW*` components extended additively, never hand-rolled. The wallet
  control keeps its shipped `Material` / `StadiumBorder` / `InkWell` recipe; the
  hamburger is a plain `IconButton`.
- 4-pt grid, existing tokens only. `space3` = 6 is the ONE documented exception
  and F uses it correctly as the avatar's symmetric inset. New dimensions are on
  the grid: 44 = 4 x 11, 196 = 4 x 49. The glyph at 18 matches the caret it
  replaces and is the number sketch 183's ink-gap arithmetic is built on.
- **No em dashes**, in UI strings or code comments. Write "a - b" with a plain
  hyphen. Middle dots and the U+2212 minus already in the tree are not em dashes
  and are not yours to touch.
- Only lines this task adds or rewrites must obey the hyphen rule. Do not sweep
  unrelated existing lines.
- **No assertion may be relaxed or skipped.** Finding 10 lists every one that
  moves and why each replacement is at least as strict. Exactly ONE is deleted -
  `greaterThan(180)` - because F removes the name column and the caret it was
  written about, and that deletion must appear in the SUMMARY.
- Every doc comment moved between files moves VERBATIM. The 24-05 note on `-1`,
  the eight-tab truncation note, the `titleSpacing` charged-on-both-sides
  paragraph and the dock geometry notes are the record of why things are the way
  they are. Extend them; do not summarise them away.
- **Do not use "v1", "for now", "placeholder", "simplified" or "future
  enhancement" in any code comment or SUMMARY line.**

</constraints>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: S7 and F ship whole - the extraction, the header cluster and the four-tab bar in one change</name>
  <files>lib/components/overlay/nav_destinations.dart, lib/components/overlay/more_sheet.dart, lib/components/overlay/responsive_overlay.dart, lib/components/overlay/mobile_header.dart, lib/components/coins/view/coins_screen.dart, lib/navigation/router.dart</files>
  <behavior>
    - Bar: the mobile destination list is exactly Home `/dashboard`, Assets `/assets`, Activity `/transactions`, News `/news`, in that order.
    - Sheet: the derived list is exactly Markets `/markets`, Web `/web`, Feedback `/logs`, Settings `/settings` on a non-Linux host, and the body still appends the `Accounts` row.
    - Reachability: the union of bar paths and sheet paths covers every visible member of `allDestinations` except `/swap`. Equality, not containment.
    - Header: exactly one wallet control and one hamburger, both measuring 44 x 44, `space6` apart, cluster 100.00, and the hamburger opens the same sheet body the bar's `More` slot opened before this task.
    - Header decorations differ: the wallet carries `surfaceMenu` + a `borderControl` `StadiumBorder`; the hamburger carries no container at all.
    - Dynamic Type: pumping the header at 1.0, 2.0, 2.5 and 3.0 raises no overflow exception.
  </behavior>
  <action>
**Re-measure the baseline FIRST** and record both numbers in the SUMMARY:
`flutter test 2>&1 | tail -3` and `flutter analyze 2>&1 | tail -3`. It was 1158
passing, 3 skipped, 0 failing and 0 analyze issues when this plan was written,
and it moves several times a day.

**Re-verify the three facts this plan rests on** before writing anything, and
STOP and report if any has moved: the sheet derivation at
`responsive_overlay.dart:140-147`, the absence of `/assets` from the eight
entries of `_allDestinations`, and `/assets` at `router.dart:239` plus `/news`
at `router.dart:269` both inside the `ShellRoute`.

This is ONE task on purpose. At no point between its first edit and its last may
`Markets`, `Web`, `Feedback` or `Settings` be unreachable on the phone.

---

**(a) NEW `lib/components/overlay/nav_destinations.dart`.**

Move the navigation model out of `responsive_overlay.dart` so the header can
reach it without an import cycle, and so a test can reach it without mounting
the shell. Make public, with their doc comments moved VERBATIM and extended:

- `NavDestination` (today's `_TabDestination`), fields unchanged.
- `allDestinations` - today's `_allDestinations`, **all eight entries, same
  order, same icons, same `visible` flags, byte-identical**. This list drives
  the desktop bar. Adding `/assets` to it would put a ninth tab on desktop; say
  so in the comment.
- `visibleDestinations` - today's `_visibleDestinations`.
- `mobileDestinations` - **the S7 set**, four entries:

  | label | path | icon |
  | --- | --- | --- |
  | `Home` | `/dashboard` | `Icons.dashboard_outlined` |
  | `Assets` | `/assets` | `Icons.account_balance_wallet_outlined` |
  | `Activity` | `/transactions` | `FontAwesomeIcons.clock.data` |
  | `News` | `/news` | `Icons.article_outlined` |

  `Icons.account_balance_wallet_outlined` is the app's established holdings
  glyph - `assets_screen.dart:481` and `coins_screen.dart:231` both use it for
  the "No coins yet" state. Note in a comment that the sheet's `Accounts` row
  uses the same glyph, that the two are never adjacent because one is on the bar
  and one is a sheet away, and that reusing the app's own holdings glyph beat
  inventing a second one. `Icons.article_outlined` is copied from
  `allDestinations`'s own News entry, so the bar and the sheet cannot disagree
  about what News looks like.

  Extend the existing doc block: keep the eight-tab truncation history verbatim,
  then record that sketch 182 scheme S7 replaced Markets with Assets and `More`
  with News on 2026-08-07, that Markets moved to the sheet automatically because
  the sheet is derived, and that the horizontal label ceiling rose from 1.93x to
  2.06x as a result.

- `moreDestinations` - the derived getter, logic byte-identical. Its comment
  must now state the four members S7 produces AND the property that makes the
  change safe.
- `navIndexForLocation(String location, List<NavDestination> among)` - a PURE
  function carrying today's `startsWith` loop and its `-1` return, with the
  24-05 doc comment moved verbatim. Extracting it is what lets Task 2 pin the
  route-to-tab ledger without pumping a router.
- `currentIndex(BuildContext, List<NavDestination>)` - now a two-line wrapper
  reading `GoRouterState.of(context).uri.path` and delegating.

**Add the `/assets` guard**, per finding 2:

    /// Mobile bar paths that are NOT members of [allDestinations], so the
    /// derived [moreDestinations] sheet cannot catch them if they ever leave
    /// the bar. Each entry names the ONE entrance it falls back to.
    const Map<String, String> kNonDerivableMobilePaths = {
      '/assets': 'the dashboard Assets panel View all link '
          '(coins_screen.dart), and nothing else in the app',
    };

**(b) NEW `lib/components/overlay/more_sheet.dart`.**

Move `_MoreSheetBody` here as public `MoreSheetBody`, **body byte-identical** -
same `moreDestinations` map, same `GWSelectRow` rows, same `Accounts` row with
its `AccountDrawer.show(context)` call, same icon sizes and colours. Add a
static `MoreSheet.show(BuildContext)` carrying the exact
`GWBottomSheet.show<void>(context: context, title: 'More', child: ...)` call the
`More` slot makes today, **including the title string `More`**. Renaming it is
the redesigned menu's job and sketch 184 is unpicked.

Its class doc must say: this sheet is now opened from the header's hamburger
rather than a bar slot, its rows are derived and not written, and its `Accounts`
row duplicates the wallet control beside the hamburger - which was already true
of the pill and is not made worse here.

**(c) `lib/components/overlay/mobile_header.dart` - sketch 183 scheme F.**

Delete `kWalletPillMaxWidth` and its doc comment. There is nothing left to cap.

Add, in its place:

    /// The side of both header controls, in logical pixels. Public so the tests
    /// assert against the same number the widgets use rather than a literal
    /// typed twice, which is the rule `kWalletPillMaxWidth` set before it was
    /// deleted. 44 is Apple's minimum target and is on the 4-pt grid (4 x 11).
    const double kHeaderControlSize = 44;

**`WalletPill` is a DELETION.** Keep the class name, keep
`Material(color: gw.surfaceMenu, shape: StadiumBorder(side: BorderSide(color:
gw.borderControl)), clipBehavior: Clip.antiAlias)` and the `InkWell` inside it
byte-identical, and keep the `AccountDrawer.show(context, includeNetwork: true)`
call. Remove: the name `Flexible` and its `Text`, the `space2`, the caret
`Icon`, and the trailing `space4`. The `SizedBox` becomes
`kHeaderControlSize` on BOTH axes, and the leading `space3` becomes symmetric
padding around the 32px avatar - `6 + 32 + 6 = 44`, which is sketch 183's "the
disc stops 6 px inside its 44 box". `_NoWalletAvatar` stays and is centred the
same way.

**Keep the `semanticLabel` block and all three of its branches exactly.** It is
now the ONLY thing in the header that identifies the wallet or the chain in
words - see finding 5 - and the comment above it must be rewritten to say so
rather than describing a "zero-tap answer" beside a visible name that no longer
exists.

Update the class doc: the control is 44 x 44 and its `StadiumBorder` on a square
renders as a circle; the name `WalletPill` is kept so the sketch, the test file
and the code agree rather than churning three places for a shape word; the fill
is 1.11:1 against the bar so the `borderControl` edge carries 1.4.11 alone at
3.30:1; and the header no longer prints the wallet name, with `AccountAvatar`
painting the CURRENCY rather than the wallet (sketch 181 finding 1), the
monogram named as the remedy and recorded as not built here.

Add a public `HeaderMenuButton`. **A plain `IconButton` with no container of any
kind** - no `Material`, no `Container`, no border, no fill.
`icon: const Icon(Icons.menu, size: 18)`, `color: gw.textPrimary`,
`tooltip: 'Menu'` (which also supplies the semantic label), calling
`MoreSheet.show(context)`.

**Pin the box to 44 explicitly and verify it by measurement.** `IconButton`'s
Material 3 defaults are a 48px minimum plus
`MaterialTapTargetSize.padded`, either of which silently makes the box 48 and
breaks the 100.00 cluster. Set `padding: EdgeInsets.zero`,
`constraints: const BoxConstraints.tightFor(width: kHeaderControlSize, height:
kHeaderControlSize)` and `style: IconButton.styleFrom(tapTargetSize:
MaterialTapTargetSize.shrinkWrap)`, then confirm with `tester.getSize` in
Task 2 rather than trusting it.

Its class doc must carry the split, because this is the whole of F and it will
otherwise be "tidied" into a matching pair: the wallet holds a VALUE that
changes so it gets the app's chip recipe at 3.30:1; the hamburger holds nothing
and opens a fixed list so it gets a bare glyph at 19.29:1; both pass 1.4.11 on
their own terms and neither depends on the 1.11:1 fill; and two identical
stadiums 12px apart would read as a segmented control, which is scheme A's
defect and the reason F beat it. Name scheme C - the wallet's chip removed too -
as the one-edit fallback Jakub already reserved.

Restructure `title`. **`titleSpacing` and `actions` are NOT touched.** Both
controls sit in ONE right-aligned Row inside the existing `Expanded`, `space6`
apart, hamburger outermost, which is the order Jakub asked for - the wallet
icon, and the hamburger menu next to it:

    title: Row(children: [
      const BrandLockup(),
      const SizedBox(width: GeniusWalletConsts.space6),
      Expanded(child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          const WalletPill(),
          const SizedBox(width: GeniusWalletConsts.space6),
          const HeaderMenuButton(),
        ],
      )),
    ]),

**Exactly ONE `space6` inside the cluster.** Sketch 183's "If F ships" table
reads "`space6` to its right", which looks like a second spacer; its own
held-constant table pins the cluster at 100.00 and the free space at 135.94,
both of which require one gap. Do not add a trailing spacer.

Rewrite the `actions` comment rather than deleting it: it must now say that the
cluster is in `title` because `AppBar` lays `actions` out at intrinsic size and
hands the remainder to `title`, that in `actions` the title Row would drop from
342.00 to 246.00 and the brand would become what shrinks, and that `actions`
therefore stays exactly as it is.

Update `BrandLockup`'s width-budget comment to F's arithmetic - title Row
342.00, lockup 106.06, `space6` 12, cluster 100.00, free space 135.94 - and keep
the "`AppBar` charges `titleSpacing` on BOTH sides" paragraph verbatim. It is
the trap that made an earlier budget wrong and it is still the trap. Replace the
`kWalletPillMaxWidth` paragraphs, whose subject no longer exists, with the
statement that the right side is now a fixed 100 and the free space grew from
12.00 to 135.94.

**Then measure the Dynamic Type case before touching the 216.** If finding 6's
overflow reproduces, lower the wordmark's `maxWidth` from 216 to **196** and
rewrite its comment: the cluster is fixed and non-flex, so the `Expanded` starves
once the lockup passes 230; 196 caps the lockup at 225.37 and leaves 4.63px of
margin at every scale; 196 is on the grid at 4 x 49; and the headroom the
comment reports drops from 2.82x to 2.56x, where the 2.82x was never real
because at that scale the old pill already rendered nothing but an ellipsis. If
it does NOT reproduce, leave 216 untouched and report why. Also read and report
`Icon.applyTextScaling`'s effective value, since a scaling glyph overflows the
fixed 44px box independently of the lockup.

**(d) `lib/components/overlay/responsive_overlay.dart` - the bar.**

Import the two new files. Delete `_TabDestination`, `_allDestinations`,
`_visibleDestinations`, `_currentIndex`, `_mobileDestinations`,
`_moreDestinations` and `_MoreSheetBody`, and repoint `_MobileTabBar`,
`_MobileTabItem`, `_MobileBarSlot` and `_DesktopTopBar` at the moved symbols.
`_DesktopTopBar`'s diff must be nothing but those renames.

**Delete `_MobileMoreItem` entirely.** Leaving it unreferenced fails
`flutter analyze`, which is the gate that keeps this removal honest.

In `_MobileTabBar.build` the Row's fourth child becomes the fourth destination:

    _MobileTabItem(dest: destinations[0], selected: selected == 0),
    _MobileTabItem(dest: destinations[1], selected: selected == 1),
    const SizedBox(width: _kDockSlotWidth),
    _MobileTabItem(dest: destinations[2], selected: selected == 2),
    _MobileTabItem(dest: destinations[3], selected: selected == 3),

Rename `_kDockSlotWidth` to `kMobileDockSlotWidth`, `_kMobileBarHeight` to
`kMobileBarHeight` and `_kIconSize` to `kMobileNavIconSize`, all public, so
Task 2 computes the label slot and the vertical budget from the same numbers the
widget uses. Nothing else about the dock, the overhang, the safe-area cap or the
`ShaderMask` changes.

Add a comment on the bar recording the active-tab consequence: `/markets` now
lights no tab, `navIndexForLocation` returns -1 and that is the shipped 24-05
answer rather than a gap, and the count of unlit in-shell routes went from seven
to six.

**(e) `lib/components/coins/view/coins_screen.dart:409` and
`lib/navigation/router.dart:235` - `push` becomes `go`.**

Change `context.push('/assets')` to `context.go('/assets')`. Both comments
justify `push` on the premise that `/assets` is not a nav tab, and S7 makes that
false. Rewrite both to say `/assets` is a bottom-nav destination as of sketch
182 S7, cite `transactions_slim_view.dart:363` as the precedent that already
made this exact call for `/transactions`, and state the reason: two entrances to
one route with different back behaviour reads as randomness. Note what is given
up - the dashboard no longer stays mounted, so its market-data refresh timer is
disposed and re-armed - which is the same trade `/transactions` already made.

**Touch nothing else in either file.** `coins_screen.dart` is heavily modified
in this working tree; your diff there is one call and one comment.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3 && flutter test test/components/ test/dashboard/ test/account/ 2>&1 | tail -8</automated>
  </verify>
  <done>
`flutter analyze` reports 0 issues, which also proves `_MobileMoreItem` is gone
rather than orphaned. `test/components/`, `test/dashboard/` and `test/account/`
are green. The bar renders Home, Assets, [Swap], Activity, News. The header
carries a 44 x 44 wallet chip keeping its `surfaceMenu` fill and `borderControl`
stadium, `space6`, then a 44 x 44 hamburger with no container, cluster 100.00 in
a 342.00 title Row. `kWalletPillMaxWidth` is deleted, `titleSpacing` and
`actions` are untouched, and `allDestinations` and `_DesktopTopBar` are unchanged
apart from renames. The Dynamic Type measurement is recorded, and the wordmark
cap moved to 196 only if the overflow actually reproduced.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: pin the navigation model and the two header treatments, neither of which anything has ever asserted</name>
  <files>test/components/mobile_nav_destinations_test.dart, test/components/mobile_header_brand_and_pill_test.dart</files>
  <behavior>
    - Nothing in the suite asserts the bar's destinations today, so any test added here is strictly additive coverage.
    - Every visible member of `allDestinations` except `/swap` is reachable from the phone shell, proven by set equality.
    - Every mobile bar path exists as a route in `router.dart`, proven by a source scan.
    - `navIndexForLocation` returns the ledger's answer for every in-shell route, including -1 where it should.
    - The bar's four labels fit 76.50px at real Inter, and its vertical stack fits 60.00px.
    - Both header hit boxes measure exactly 44 x 44 DESPITE carrying different decorations, and the cluster measures exactly 100.00.
  </behavior>
  <action>
**NEW `test/components/mobile_nav_destinations_test.dart`.** Open it with a
comment stating the finding that justifies it: before this file, `grep` across
`test/` found no assertion anywhere on the bar's destination set, so the bar
could be re-pointed with a fully green suite. That is what this file closes.

Write these groups. Every expected value is written out in full so that any
change to the tab set reddens the suite and forces the author to look at it.

**1. The bar, exactly.** `mobileDestinations` maps to
`[('Home','/dashboard'), ('Assets','/assets'), ('Activity','/transactions'),
('News','/news')]`, in order. Equality on the whole list, not `contains`.

**2. The sheet, exactly.** `moreDestinations` maps to
`[('Markets','/markets'), ('Web','/web'), ('Feedback','/logs'),
('Settings','/settings')]` on a non-Linux host. Assert the `/logs` path
explicitly with a comment: the label says Feedback and the route says `/logs`,
and someone WILL assume `/feedback`. Guard the Web row on `Platform.isLinux` the
same way the destination itself does.

**3. THE REACHABILITY INVARIANT, and it is the most valuable test here.**
Assert that

    {every visible allDestinations path} minus {'/swap'}
      == {mobileDestinations paths} union {moreDestinations paths}

as SET EQUALITY. Containment would pass while something was stranded. In the
failure `reason`, print the symmetric difference and say plainly that a path on
neither side is unreachable on the phone. Reference `/swap` reaching the user
through the centre dock so its exclusion is justified rather than assumed.

**4. The `/assets` trap, named so it cannot be sprung.** Assert
`allDestinations` has exactly eight entries and contains no `/assets` - this is
a CURRENT FACT, and the test's job is to make it a loud one. Then assert that
every `mobileDestinations` path which is not a member of `allDestinations` is a
key of `kNonDerivableMobilePaths`. The failure reason must say: this path is on
the bar and cannot appear in the derived sheet, so taking it off the bar returns
it to whatever entrance is named in that map, and today for `/assets` that is
one `View all` link on one panel.

**5. Every bar path is a real route.** Scan `lib/navigation/router.dart` as text
- the pattern `freeze_rule_test.dart` already uses - and assert `path: '<p>'`
appears for every `mobileDestinations` and `moreDestinations` path. Assert the
file exists first, so a moved router reddens instead of silently scanning
nothing, exactly as that file does for its directories. A tab pointing nowhere
is worse than no tab.

**6. The route-to-tab ledger.** Call `navIndexForLocation(location,
mobileDestinations)` for every in-shell route and assert finding 8's table:
`/dashboard` 0, `/assets` 1, `/transactions` 2, `/news` 3, and **-1** for
`/markets`, `/web`, `/logs`, `/settings`, `/buy`, `/token-info` and `/swap`.
Carry the 24-05 reason: -1 is honest, and `return 0` is the bug that lit
Dashboard while you stood on the Buy form. Add a pairwise assertion that no
mobile path is a prefix of another, since `startsWith` is the matcher.

**7. Label widths at real Inter.** Load the four Inter faces with a
`FontLoader`, the same escape hatch `mobile_header_brand_and_pill_test.dart` and
`assets_header_scheme_a_test.dart` already use. Compute the slot from the
widget's own constants - `(390 - kMobileDockSlotWidth) / 4` - and assert it is
76.50. Then lay out each of the four labels with a `TextPainter` at
`GeniusWalletTypography.labelMd.copyWith(fontSize: 10, fontWeight:
FontWeight.w600)` (w600 is the ACTIVE weight, the wider of the two) and assert
each width is under the slot. `debugPrint` the measured widths and the implied
ceiling per label; expected Home 28.46, Assets 33.20, Activity 37.15, News
27.39.

**8. The vertical budget, which is the ceiling that actually binds.** Assert
`2 * space4 + kMobileNavIconSize + space2 + (10 * labelMd.height)` is at or
under `kMobileBarHeight`, computing every term from the real constants and never
from a literal. `debugPrint` the total and the slack; expected 56.85 against
60.00, so 3.15. Comment that this is PRE-EXISTING and out of scope, that the
slot overflows vertically at about 1.23x textScaler which is well below every
label's horizontal ceiling, and that this assertion exists so it cannot quietly
get worse.

**`test/components/mobile_header_brand_and_pill_test.dart`, migrated per finding
10.** Move exactly the five cases listed there and delete exactly one assertion.
Nothing else in the file changes.

- `NO network dropdown ... exactly one control remains`: add
  `expect(find.byType(HeaderMenuButton), findsOneWidget)` and rewrite the
  comment - there are two controls now, and the point that survives is that
  neither of them is a second network affordance.
- `the pill clears the 44px touch target floor`: **becomes the assertion sketch
  183 asked for.** `tester.getSize` on BOTH controls equals
  `Size.square(kHeaderControlSize)`, computed from the constant. Comment that
  this is the one thing 181 could not assert, because before F there was only
  one treatment.
- `THE BRAND DOES NOT SHRINK`: keep the lockup equality across a 4-character and
  a 60-character name verbatim. Replace the cap and the `longPill > shortPill`
  pair with: the wallet control is exactly 44.00 and the cluster exactly 100.00
  under BOTH names. Comment that this is stronger, not weaker - the old test
  proved the pill grew to a ceiling, and this one proves the right side does not
  vary with the name at all, so the brand can never be squeezed.
- `with no wallet the pill reads "No wallet"`: the string is gone. Assert
  instead that the plus glyph is mounted inside `WalletPill`, that its
  `InkWell.onTap` is non-null because the sheet it opens is where `Add Wallet`
  lives, and that the semantic label is exactly
  `No wallet selected. Opens wallet and network`. Add the other two branches
  from the same block: a wallet with no network, and a wallet with one, asserting
  the label names the wallet and the chain. **Comment that this is now the ONLY
  place the header identifies anything in words**, so it is load-bearing rather
  than decorative.
- `REAL INTER, 390pt`: keep `lockup == 106.06` and its reason verbatim. Replace
  the three pill assertions with exact equalities - wallet 44.00, hamburger
  44.00, gap 12.00, cluster 100.00, free space `342 - 106.06 - 100 = 135.94` -
  and keep the `titleRow` term spelled out at `390 - 2 * space8 - 16` so the
  charged-on-both-sides trap stays visible. **DELETE `expect(pill,
  greaterThan(180))`** and leave a comment where it stood recording exactly why:
  its reason was "avatar + a readable name + the chevron", F deletes the name
  and the chevron, so the assertion's subject no longer exists. This is the only
  deletion in the plan and it must be traceable in the diff.
- The harness-width debug case loses its cap reference and asserts
  `Size.square(kHeaderControlSize)` instead.

**Then add these, all new:**

- **The treatments differ, and the difference is pinned.** The `WalletPill`'s
  `Material` has `color == gw.surfaceMenu` and a `StadiumBorder` whose side
  colour is `gw.borderControl`. The `HeaderMenuButton` has NO `Material`,
  `Container` or `DecoratedBox` of its own between itself and the `AppBar`. The
  failure reason must say that giving the hamburger a matching stadium is scheme
  A, which lost because two identical stadiums 12px apart read as a segmented
  control.
- **The hamburger opens the sheet.** Tap it, pump and settle, assert
  `MoreSheetBody` is mounted with rows for `Markets`, `Web`, `Feedback` and
  `Settings`. THIS is the assertion that proves nothing was stranded, so its
  comment must say exactly that: `More` left the bar in the same change that
  added this button, and these four rows are what would otherwise have been
  lost.
- **The glyph is 18.** Assert `Icon.size` on the hamburger, with the sketch's
  ink-gap arithmetic in the comment: `(44 - 18) / 2 = 13`, and F's ink gap of
  `12 + 13 = 25` depends on it.
- **Dynamic Type.** Pump the header wrapped in a `MediaQuery` with `textScaler`
  at 1.0, 2.0, 2.5 and 3.0 and assert `tester.takeException()` is null at each
  step. Record in the comment which step overflowed BEFORE the wordmark cap
  changed, and the arithmetic: the cluster needs 100.00 and the `Expanded`
  starves once the lockup passes 230.

Run the FULL suite, not just these files. Report any test that passed at
baseline and does not now, and do not touch it.
  </action>
  <verify>
    <automated>flutter test test/components/mobile_nav_destinations_test.dart test/components/mobile_header_brand_and_pill_test.dart 2>&1 | tail -20 && flutter test 2>&1 | tail -5</automated>
  </verify>
  <done>
Both files pass, and the full suite is green at or above the re-measured
baseline plus the added tests, with 3 skipped and 0 failing. The reachability
invariant holds as set equality. Every bar and sheet path is proven to exist in
`router.dart`. The route-to-tab ledger matches finding 8 exactly, including -1
for `/markets`. Both header controls measure exactly 44 x 44 with different
decorations and the cluster measures 100.00 at real Inter. Exactly one assertion
was deleted, `greaterThan(180)`, with its reason recorded in place.
  </done>
</task>

<task type="auto">
  <name>Task 3: the gates, the fence and the record</name>
  <files>.planning/quick/20260807-bottom-nav-s7/SUMMARY.md, .planning/todos/pending/2026-08-07-mobile-bar-overflows-vertically-at-1.23x-dynamic-type.md, .planning/todos/pending/2026-08-07-header-no-longer-identifies-which-wallet-is-live.md</files>
  <action>
Run every gate and record each result verbatim.

`flutter analyze` must end at **0 issues**. Not zero errors with warnings, zero.

`flutter test` must end green at or above the baseline you re-measured in Task 1
plus the tests Task 2 added, with **3 skipped and 0 failing**. Report both the
before and after counts. If any test that passed at baseline now fails, stop and
report it. Do not weaken it, do not delete it, do not add a skip.

Sweep added lines for em dashes, writing the character as a byte escape so it
never appears literally in this repo:

    git diff -U0 -- lib test | grep '^+' | grep -c $'\xe2\x80\x94'

The count must be 0.

Confirm the fences held:

    git diff -- lib/components/overlay/responsive_overlay.dart | grep -n "_DesktopTopBar" -A 5
    git diff -- lib/components/overlay/mobile_header.dart | grep -nE "titleSpacing|actions:"
    git diff --stat -- lib/banxa lib/squid_router lib/account lib/components/cards

`_DesktopTopBar`'s diff must contain nothing but symbol renames. `titleSpacing`
and `actions:` must not appear as changed lines. The banxa, squid_router,
account and cards stats must be empty - `account_drawer.dart` in particular,
because that is where the monogram would have gone and it is not in scope.
`git status` alone is NOT a fence check on this branch, since most of `lib/` was
already dirty before this task started.

**File two todos.**

`2026-08-07-mobile-bar-overflows-vertically-at-1.23x-dynamic-type.md`: the
slot's stack measures 56.85 against a 60.00 bar, only the 13.85px label line
scales, so it overflows at about 1.23x - well before any label truncates at
2.06x. State that it is pre-existing, that S7 neither caused nor worsened it,
that Task 2 now pins the 56.85, and name the two candidate remedies (clamp
`textScaler` on the bar, or drop the label above a threshold) without choosing.

`2026-08-07-header-no-longer-identifies-which-wallet-is-live.md`: under F the
header prints no wallet name, and `AccountAvatar` paints
`crypto/{currencySymbol}.png` with a flat `brandPrimaryStrong` background, so
two ETH wallets render identical headers - sketch 181 finding 1. Add the
double-icon defect: the 32px disc and the 16px badge resolve to the same file
for an ETH wallet on Ethereum. Name the remedy precisely: sketch 181 scheme E's
monogram, an additive `monogram` branch on `AccountAvatar` in
`lib/account/account_drawer.dart`, zero extra width, with the address-shaped
rule FIRST so an address never renders its trailing digits as a monogram. Record
that the semantic label still names both the wallet and the chain, so this is a
sighted-user gap rather than a total one.

Then write the SUMMARY. It must carry, in this order:

1. Before and after `flutter test` counts and the `flutter analyze` result.
2. **The trap, and how it was closed.** The derivation verified at
   `responsive_overlay.dart:140-147`, the four routes that were at risk
   (Markets, Web, Feedback, Settings), and the fact that the hamburger landed in
   the same change so none of them was ever unreachable.
3. **`/assets`: confirmed NOT one of the eight members of `allDestinations`**,
   why the derived sheet can never catch it, what happens if the tab set changes
   again, and the `kNonDerivableMobilePaths` guard that now makes that loud.
4. **The header budget under F**: title Row 342.00, lockup 106.06, cluster
   100.00, free space 135.94 against the pill's 12.00, and the statement that
   `titleSpacing` and `actions` were not touched because F needed neither.
5. **What F gives up**, in full: no wallet name in the header, `AccountAvatar`
   painting the currency rather than the wallet, the double-icon defect at 44px,
   and the semantic label as the only remaining textual identity. Name the
   monogram as the remedy and say it was deliberately not built.
6. **The Dynamic Type finding**, whether the overflow reproduced, whether the
   wordmark cap moved from 216 to 196, and the measured value of
   `Icon.applyTextScaling`.
7. **The label table** with the measured w600 widths and the note that the
   horizontal ceiling ROSE from 1.93x to 2.06x, followed by the vertical 1.23x
   finding that makes the horizontal one moot.
8. **The route-to-tab ledger**, and the count of unlit in-shell routes going
   from seven to six.
9. **How desktop was fenced**, all four mechanisms from the constraints.
10. **The assertion ledger from finding 10**: the four that moved with the
    reason each replacement is stricter, and the ONE that was deleted
    (`greaterThan(180)`) with the reason its subject no longer exists.
11. That no commit was created, that the monogram was not added, and that sketch
    184 was not touched.

Create no commit. Leave the tree dirty.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -3 && flutter test 2>&1 | tail -3 && git diff -U0 -- lib test | grep '^+' | grep -c $'\xe2\x80\x94'</automated>
  </verify>
  <done>
`flutter analyze` reports 0 issues. `flutter test` is green at or above the
re-measured baseline plus the added tests, 3 skipped, 0 failing, with both
counts recorded. Zero em dashes on added lines. `_DesktopTopBar`'s diff is
renames only, `titleSpacing` and `actions` are unchanged, and nothing under
`lib/banxa/`, `lib/squid_router/`, `lib/account/` or `lib/components/cards/` was
touched. Both todos are filed. The SUMMARY carries all eleven items with
measured numbers throughout. No commit was created.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
Both decisions from today are in.

**Bottom bar (sketch 182, S7):** Home, Assets, [Swap], Activity, News. `More` is
gone from the bar.

**Header (sketch 183, F):** the 224px wallet pill is now a **44px circle** that
keeps its border, and beside it a **bare hamburger** with no border and no
background. The pair is 100px wide where the pill alone was 224 - **from 57% of
the bar down to 26%.**

The hamburger opens **exactly today's More sheet, unchanged** - Markets, Web,
Feedback, Settings and Accounts. The redesigned Menu page is not built and
sketch 184 is still unpicked, as you asked.

**The one thing F costs, and you should decide about it before you get used to
it.**

The header no longer shows the wallet's name anywhere. That was the point - it
was eating half the bar. But the circle that replaces it **cannot tell you which
wallet is live**, and that is not a taste judgement, it is what the code does:
`AccountAvatar` draws `crypto/eth.png` based on the wallet's CURRENCY, with a
flat blue background. It has no per-wallet colour, no blockie and no seed. **Two
ETH wallets draw the same pixels.**

It is slightly worse than that at 44px: the small badge on the circle draws the
NETWORK's icon, and for Ethereum that is the same `eth.png` file. So an ETH
wallet on Ethereum renders the same picture twice, 3px apart, and neither
picture says which wallet you are on.

**The fix costs zero pixels and is one sketch away.** Sketch 181 scheme E puts a
two-character monogram inside that same circle - `S1` and `S2` for your two
generated wallets, `7A` for an imported one. It answers which wallet AND which
chain at 44px. I did not build it, because the instruction was that the wallet
control's decoration does not change and the monogram lives in a different file.
**Say the word and it is a small additive change.**

Until then the wallet and the chain are still named for VoiceOver - the semantic
label survived intact and there is now a test on all three of its branches - so
this is a sighted-user gap, not a total one.

**Two smaller things worth knowing.**

**Markets moved into the hamburger, and it no longer lights up.** It is in the
sheet automatically, because that sheet is derived from what the bar does NOT
show - no second edit was needed and nothing could have been dropped by
accident. But standing on the Markets page, no tab lights. That is already the
shipped behaviour for Settings, Web and Feedback, and lighting the WRONG tab was
a real bug that got fixed in phase 24. Six in-shell pages now light nothing,
down from seven.

**Assets had exactly ONE entrance in the entire app before today.** The holdings
page had no nav entry at all - only the `View all` link on the dashboard's
Assets panel - and it could not appear in the More sheet either, because it was
never registered as a destination. It now has a tab, and the `View all` link now
switches tabs instead of stacking a page, so both entrances behave the same.
  </what-built>
  <how-to-verify>
Run the app on your iPhone in DARK mode. `--dart-define=GW_DEV_TOOLS=true` if
you want mock data.

**A. The four tabs and the dock. Every one, not a sample.**

  1. **Home** opens the dashboard, Home tab lit in the brand gradient.
  2. **Assets** opens the holdings page with its search and sort. Assets lit.
  3. **Swap dock** opens Swap. No tab lit; the dock glows.
  4. **Activity** opens Transactions. Activity lit.
  5. **News** opens the crypto news list. News lit.

Tap through all five in a row and back again. Every label should be whole - no
ellipsis on any of them.

**B. The hamburger reaches everything that left the bar.**

Tap the hamburger, top right. The sheet must contain **Markets, Web, Feedback,
Settings** and **Accounts**. Open all five:

  6. **Settings** - this is the one that would have been stranded. Confirm it
     opens.
  7. **Feedback**, **Web**, **Markets** - all three open their real page.
  8. **Accounts** opens the accounts drawer, the same one the wallet circle
     opens.

While you are on Markets, **look at the bottom bar: no tab is lit.** Confirm
that reads as acceptable rather than broken.

**C. THE RULING: the header, and whether you can tell which wallet you are on.**

  9. The brand and `GNUS.AI` are unchanged and the same size as this morning.
 10. **Switch between two wallets** and watch the circle. If both are ETH it
     will not change at all. **This is the question.** Say whether you want the
     monogram (`S1` / `S2` inside the circle, zero extra width), or whether the
     circle is fine as a door and the name belongs only in the drawer.
 11. Look at the circle closely: for an ETH wallet on Ethereum, the big disc and
     the small badge are the same picture. Say whether that reads as a defect.
 12. The wallet circle has a thin border; **the hamburger has none.** That is
     deliberate - the wallet holds a value so it gets the app's chip treatment,
     the hamburger holds nothing so it is just a glyph. If that reads as
     inconsistent rather than as two different kinds of object, **that is 183C**
     and it is a one-line change: remove the wallet's border too.
 13. Tap the circle and the hamburger in turn a few times. They are 12px apart;
     confirm you can hit each reliably with one thumb without a regrip, and that
     the wallet's ripple is clipped to its circle.
 14. Both open different sheets - the circle opens Wallet and network, the
     hamburger opens the menu. Confirm you do not confuse them.

**D. Nothing became unreachable.**

 15. Walk the app for a minute: the five tabs, the five sheet rows, Buy GNUS
     from the dashboard, a coin page from the Assets list, and the accounts
     drawer.

Not checkable on the phone and covered by tests instead: the desktop bar, which
still shows all eight destinations and is untouched.
  </how-to-verify>
  <resume-signal>Type "approved", or rule on the two open questions: the wallet circle ("add the monogram" / "leave it as a door"), and the split treatment ("keep F" / "go to 183C" and I will drop the wallet's border too).</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| route path to navigation | `GoRouterState.of(context).uri.path` is compared with `startsWith` against a static destination list, and the result selects which tab is lit |
| wallet model to header identity | `wallet.walletName` and `wallet.currencySymbol` are user or chain supplied and are the only inputs to what the header shows about which wallet is live |
| destination list to reachability | the sheet's contents are DERIVED from two lists, so an edit to one list silently changes what a user can reach |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- | --- |
| T-s7n-01 | Denial of Service | reachability of `/settings`, `/logs`, `/web`, `/markets` | **high** | mitigate | Removing `More` before another entrance exists strands four routes, Settings included. The hamburger ships in the SAME task, wired to the same derived sheet body, and Task 2 asserts the union of bar and sheet paths equals every visible destination minus `/swap` as SET EQUALITY, so a stranded route reddens the suite. |
| T-s7n-02 | Denial of Service | reachability of `/assets` under a future tab-set change | medium | mitigate | `/assets` is not one of the eight members of `allDestinations`, so the derivation cannot catch it and it is reachable only while it is on the bar. `kNonDerivableMobilePaths` plus a test walking every bar path against `allDestinations` makes the next tab-set change fail loudly with the fallback entrance named. |
| T-s7n-03 | **Spoofing** | **the wallet control's identity under scheme F** | **high** | **accept, with the acceptance put to the user** | The header stops printing the wallet name, and `AccountAvatar` is keyed to `currencySymbol` with a flat `brandPrimaryStrong` fill, so two ETH wallets render identical headers and a user can act on the wrong wallet believing it is another. Accepted only because the drawer one tap away still distinguishes them and the semantic label still names both. The remedy is named and costed (sketch 181 scheme E's monogram, zero extra width, address-shaped rule first so an address never renders its trailing digits), filed as a todo, and is ruling 1 at the checkpoint. This must NOT be closed silently. |
| T-s7n-04 | Denial of Service | the header's title Row under Dynamic Type | medium | mitigate | The cluster is fixed at 100 and non-flex, so the `Expanded` starves once the lockup passes 230, at about 2.616x textScaler. Before F the pill absorbed shrink down to its own chrome and produced an ellipsis instead. Task 1 measures it, lowers the wordmark cap to 196 if it reproduces (4.63px of margin at every scale), and Task 2 walks 1.0 / 2.0 / 2.5 / 3.0 asserting `takeException()` is null. |
| T-s7n-05 | Denial of Service | the bottom bar's slot under Dynamic Type | low | accept | The slot's stack measures 56.85 against a 60.00 bar and overflows at about 1.23x. PRE-EXISTING with identical geometry today; S7 neither causes nor worsens it and RAISES the horizontal label ceiling from 1.93x to 2.06x. Accepted, pinned by an assertion, and filed as a todo rather than fixed inside a navigation change. |
| T-s7n-06 | Tampering | a tab pointing at a route that does not exist | medium | mitigate | A tab whose path is not routed is a dead control that looks live. `/assets` (router.dart:239) and `/news` (router.dart:269) were verified inside the `ShellRoute` during planning, and Task 2 adds a source scan asserting every bar and sheet path appears as `path: '<p>'` in `router.dart`, with an existence check on the file first so a moved router reddens instead of scanning nothing. |
| T-s7n-07 | Spoofing | the lit tab misreporting the current page | low | mitigate | `navIndexForLocation` returning 0 on no match was a real defect: the bar claimed you were on Dashboard while you stood on the Buy form. The `-1` fix is preserved verbatim through the extraction, and Task 2 pins the full route-to-tab ledger including every -1, plus a pairwise check that no mobile path is a prefix of another since `startsWith` is the matcher. |
| T-s7n-08 | Information disclosure | a wallet name that is an address | low | mitigate | The import screen stores unvalidated free text, so a name can be an address, and the old header printed it. F removes the name from the header entirely, so that string no longer reaches the bar at all. The underlying input defect is recorded as a todo and is not this task's. |
| T-s7n-09 | Tampering | the two header treatments being made to match later | low | mitigate | F's whole argument is that the two controls carry different decorations because they are different kinds of object. A later "consistency" edit giving the hamburger a stadium recreates scheme A's segmented-control defect. Task 2 asserts the wallet's `surfaceMenu` fill and `borderControl` stadium AND the hamburger's absence of any container, with the reason in the failure message. |
| T-s7n-SC | Tampering | package installs | low | accept | This task installs nothing. No `pubspec.yaml` change, no new dependency, no package manager runs. |
</threat_model>

<verification>
- `flutter analyze` reports 0 issues, which also proves `_MobileMoreItem` was
  deleted rather than orphaned.
- `flutter test` is green at or above the re-measured baseline plus the added
  tests, with 3 skipped and 0 failing, both counts recorded.
- The bar's destinations are exactly Home `/dashboard`, Assets `/assets`,
  Activity `/transactions`, News `/news`, asserted as an ordered list.
- The derived sheet is exactly Markets, Web, Feedback `/logs`, Settings, and the
  `Accounts` row still follows it.
- Bar paths union sheet paths EQUALS every visible `allDestinations` path minus
  `/swap`. Set equality, not containment.
- Every bar and sheet path appears as a route in `lib/navigation/router.dart`,
  proven by a source scan that first asserts the file exists.
- `allDestinations` still has exactly eight entries in their original order and
  contains no `/assets`, and every bar path that is not a member of it is a key
  of `kNonDerivableMobilePaths` naming its fallback.
- The route-to-tab ledger matches finding 8 exactly, `-1` cases included, and no
  mobile path is a prefix of another.
- The four bar labels measure under `(390 - kMobileDockSlotWidth) / 4` at real
  Inter w600, computed from the widget's own constants.
- The slot's vertical stack measures at or under `kMobileBarHeight`, computed
  from the real tokens, with the slack printed.
- **Both header controls measure exactly `Size.square(kHeaderControlSize)`
  despite carrying different decorations**, the gap is `space6`, and the cluster
  is 100.00 in a 342.00 title Row at real Inter.
- The wallet control keeps `surfaceMenu` and a `borderControl` `StadiumBorder`;
  the hamburger has no `Material`, `Container` or `DecoratedBox` of its own.
- The hamburger's glyph is `Icons.menu` at 18.
- Tapping the hamburger mounts `MoreSheetBody` with rows for Markets, Web,
  Feedback and Settings.
- All three branches of the wallet control's semantic label are asserted, since
  it is now the only textual identity in the header.
- `kWalletPillMaxWidth` is deleted and no reference to it remains.
- `titleSpacing` and `actions` are unchanged, and `BrandLockup`'s structure is
  unchanged apart from the wordmark cap if the overflow reproduced.
- No overflow exception at textScaler 1.0, 2.0, 2.5 or 3.0 on the header.
- `_DesktopTopBar`'s diff contains nothing but symbol renames.
- No file under `lib/banxa/`, `lib/squid_router/`, `lib/account/` or
  `lib/components/cards/` was modified. The monogram was NOT added.
- Exactly one assertion was deleted, `greaterThan(180)`, with its reason
  recorded in place and in the SUMMARY. No other assertion was relaxed, deleted
  or skipped.
- Zero em dashes on added lines.
- No commit was created.
</verification>

<success_criteria>
1. The phone bottom bar is Home, Assets, [Swap dock], Activity, News - sketch
   182 scheme S7.
2. The header's right side is sketch 183 scheme F: a 44 x 44 wallet chip keeping
   its shipped `surfaceMenu` fill and `borderControl` stadium, `space6`, then a
   bare 44 x 44 hamburger with no container. Cluster exactly 100.00 against the
   pill's 223.94, and `titleSpacing` and `actions` untouched.
3. Nothing became unreachable at any point. Markets, Web, Feedback and Settings
   moved into the derived sheet, and the hamburger that opens that sheet landed
   in the same change that took `More` off the bar.
4. `/assets` has a nav entrance for the first time, and the fact that the
   derived sheet can never catch it is recorded in code and pinned by a test, so
   the next tab-set change cannot strand it silently.
5. **What F gives up is measured and put to Jakub, not shipped quietly**: the
   header no longer identifies which wallet is live, the monogram is named as
   the remedy, and it is ruling 1 at the checkpoint.
6. The desktop bar is unchanged, fenced four independent ways, and its widget's
   diff is renames only.
7. The mobile navigation model and both header treatments are asserted for the
   first time: nothing in the suite pinned either before today.
8. `flutter analyze` is at 0 issues and `flutter test` is green at or above
   baseline with 3 skipped and 0 failing.
9. Jakub has walked all five tabs, all five sheet rows and the header on his
   iPhone in dark mode, and has ruled on the wallet circle's identity and on
   whether the split treatment stays or reverts to 183C.
</success_criteria>

<output>
Create `.planning/quick/20260807-bottom-nav-s7/SUMMARY.md` when done, carrying
the eleven items Task 3 lists with MEASURED numbers throughout rather than this
plan's derived ones, plus Jakub's two rulings recorded verbatim once the
checkpoint resolves.
</output>
