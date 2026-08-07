# Sketch 184 - the Menu page: what the hamburger opens

http://localhost:8899/184-menu-page/

Follows **182** (S7 picked: Home, Assets, [Swap dock], Activity, News) and **181** (scheme F: a wallet
icon plus a hamburger in the header's top-right). Those two decide that a menu exists and where it is
reached from. This sketch is about what is inside it.

Jakub, 2026-08-07: build the sketches from your own feedback, but with proper sections and the like,
using our components exactly as they are.

And, arriving mid-build and overriding the brief that started this, he added: the menu is to hold only
what we have today, and only what the logic and the code are already built for, so nobody steps out of
line - everything is to be done on the basis of the code.

**Every row in every variant was found in the code before it was drawn.** The proof list is below. Four
items the original brief asked for were looked up and are not here, because they do not exist.

## The finding: the menu has four rows

The contents were derived, not designed. `_allDestinations` (`responsive_overlay.dart:41`) holds eight
entries. Subtract the S7 bottom bar - Home (`/dashboard`), Assets, the Swap dock, Activity
(`/transactions`), News - and what is left is:

**Markets, Web, Feedback, Settings.**

That is the whole menu. Under `GW_DEV_TOOLS` it is seven. A thin menu is information about the app's
current surface area, and the variants are drawn at 1:1 so it can be read rather than argued about.

The list is also **self-maintaining**: `_moreDestinations` (`responsive_overlay.dart:110`) is computed
as all destinations minus the bar minus Swap. Promote a destination to a tab and it leaves the menu on
its own, with no second edit.

## Every row, with the code that proves it

| Row | Declared | Route | Screen / handler |
| --- | --- | --- | --- |
| **Markets** | `responsive_overlay.dart:58` | `router.dart:268` | `MarketsScreen` |
| **Web** | `responsive_overlay.dart:68` (`visible: !Platform.isLinux`) | `router.dart:257` | web view |
| **Feedback** | `responsive_overlay.dart:74` | `router.dart:317` (`/logs`) | `SubmitLogsScreen` |
| **Settings** | `responsive_overlay.dart:79` | `router.dart:326` | `SettingsScreen` |
| Design gallery (dev) | `dev_tools_bubble.dart:1210` | `router.dart:208` | `DesignGalleryScreen` |
| Token probe (dev) | `dev_tools_bubble.dart:1206` | `router.dart:202` | `TokenProbeScreen` |
| Appearance (dev) | `dev_tools_bubble.dart:1219` | no route | `GWAppearance.setMode`, `gw_appearance.dart:40` |

The dev flag itself is `kShowDevTools` = `bool.fromEnvironment('GW_DEV_TOOLS')`, `dev_flags.dart:15`.

## Four things the original brief asked for that the code does not have

### 1. Settings is not a preferences screen

`lib/settings/settings_screen.dart` contains exactly three cards:

- **Log Config** - per-logger spdlog level, one `GWSelect` per logger, `Apply Log Changes`
- **Network Config** - PubSub Port, Bind Address, UPnP, High Water, Low Water
- **CRDT Config** - Backup Enabled, Interval (min), Keep Count, Auto Restore

It reads and writes JSON overrides in the SDK directory. **There is no appearance, no security, no
currency, no language and no notifications setting anywhere in `lib/`.** The brief's four Settings
sub-rows are deleted, not deferred.

Which raises a second-order question this sketch notices but does not answer: under `GW_DEV_TOOLS` the
menu then holds two developer groups, one of which is called Settings.

### 2. There is no version and no About

`pubspec.yaml` says `1.0.0+1`. Nothing in `lib/` renders it - no `PackageInfo`, no
`showAboutDialog`, no licence page, no string "About" anywhere. So **Support is one row: Feedback.**

### 3. Appearance is the one genuine grey area, and it is stated precisely

The logic is complete and persisted. `GWAppearance` is a `ValueNotifier<GWAppearanceMode>` that writes
to the Hive `preferences` box, follows the OS on first launch, and re-skins the whole app live
(`gw_appearance.dart:40`). **Its only user-facing control is inside the dev-tools bubble**
(`dev_tools_bubble.dart:1219`).

Its own doc comment, `gw_appearance.dart:12`, says it is *"toggled from the Preferences sheet
(Appearance row)"* - **a sheet that does not exist.** So the row is drawn only inside the DEVELOPER
group, where its control actually lives today. Promoting it to a user-facing row is a one-line decision
this sketch is not authorised to take, and it is listed under Still open.

### 4. No wallet section, and the Accounts row has to go

181-F puts the wallet icon 12px from the hamburger, both opening from the same header cluster.
`_MoreSheetBody` ships an `Accounts` row today (`responsive_overlay.dart:528`, subtitle "SDK accounts
and your wallets", opening `AccountDrawer.show`). Under F it must be deleted, or two adjacent icons lead
to the same drawer. **That deletion is why the menu is four rows and not five.** Its absence is the
design.

## Sections, renamed to fit what is actually there

The brief's Explore / Settings / Support / Developer does not survive the inventory: a "Settings"
section would hold one row called Settings, which is a group header over its own child.

| Section | Rows | Why it is a group |
| --- | --- | --- |
| **Explore** | Markets, Web | two places you go to look at something outside your wallet |
| **App** | Settings | the one row that configures the thing itself |
| **Support** | Feedback | the one row that talks to us |
| **Developer** | Design gallery, Token probe, Appearance | only under `GW_DEV_TOOLS` |

**Two of the four sections hold one row.** That is not a drafting problem to tidy away. Variants B and C
exist partly to show what a one-row group looks like at 1:1, and variant A takes the opposite view and
refuses to group four things at all.

**News is deliberately absent.** Under S7 it owns a tab, and a tab plus a menu row to the same route are
two answers to "where does News live". The derived `_moreDestinations` removes it automatically, so
honouring this costs nothing.

## The governing rule

**The menu holds what you do rarely or once. Anything you do often belongs on a tab or in the header.**
If a row here turns out to be reached constantly, that is a signal to promote it to the bar, not
evidence that the menu is wrong.

## Page or sheet, re-argued honestly against a four-row menu

The brief gave three reasons for a full page. Measured against the real inventory, one is strong and two
are weaker than claimed. Quoting all three at equal weight would be arguing backwards from a conclusion.

| Argument | Holds? | Why |
| --- | --- | --- |
| The menu has children | **holds, strongly** | `/settings`, `/markets`, `/web`, `/logs` are all full screens. A sheet that opens a screen must dismiss itself first - which is exactly what `responsive_overlay.dart:523` already does, `Navigator.pop` then `context.go`. On iOS the sheet also owns the swipe-down gesture the pushed screen then wants for back. |
| A sheet has a height ceiling | **weak at four rows** | `GWBottomSheet` passes `isScrollControlled: true` (`gw_bottom_sheet.dart:14`), so the ceiling is nearly the full screen. Four rows never approach it. **Seven rows do** at a 62% sheet - and that is a `GW_DEV_TOOLS` build nobody ships. |
| A menu is a place you look around in | **weak at four rows** | Four rows is a pick-one-and-return list, which is precisely what sheets are good at. This argument earns its keep only if the menu grows. |

So **the case for a page rests on the first row plus a bet on growth**, and variant E is drawn at 1:1 so
the bet can be judged.

## The five variants, and what each buys and costs

They differ in **structure**, not decoration.

| | Structure | New components | Buys | Costs |
| --- | --- | --- | --- | --- |
| **A** | one `GWCard`, four rows, no groups | none | the smallest possible diff | dev rows separated by a rule, which names nothing |
| **B** | a `GWCard` per section, kicker above | none | grouping is unmistakable, dev is boxed off | 4 boxes for 4 rows; the box is a 1.01:1 fill on a 1.36:1 hairline |
| **★ C** | kickers + hairlines, nothing boxed | none | names every group for free, scales both ways | structure is purely typographic |
| **D** | two-up tile grid | 2 | the page stops looking empty | a second visual language, and it dresses the least-visited surface as a dashboard |
| **E** | the bottom sheet (the control) | none - it is a **deletion** | cheapest thing here; it is today minus one row | cannot hold children; scrolls internally at 7 rows |

### Component mapping, per part, per variant

| Part | Component | Status |
| --- | --- | --- |
| Page title "Menu" | `GWPageHeader(title:)`, `gw_page_header.dart` - title only, no trailing | exists |
| Section labels | `GWKicker`, default 13px step, `gw_kicker.dart` | exists |
| Every row | `GWSelectRow(leading:, title:, subtitle:, onTap:)` - leading icon at 21px `textPrimary80`, exactly as `responsive_overlay.dart:520` renders it | exists |
| Section box (B only) | `GWCard`, default `space8` pad, `radiusLg` 15 | exists |
| Group terminator (C only) | a bare `borderSubtle` hairline | **adapted** - sketch 065 drew this as variant D and did **not** pick it, so C reopens it deliberately |
| Appearance control | control track: `surfaceSunken` + hairline + `radiusPill` + 3px pad, per `CONVENTIONS.md` | exists |
| Back to the menu from a child | `GWBackLink(label:, onTap:)`, `gw_back_link.dart` | exists |
| The sheet (E) | `GWBottomSheet.show` + `_MoreSheetBody` minus its Accounts row | exists |
| Tile (D) | `GWCard(onTap:, hoverLift: true)` in an icon-over-label-over-sublabel layout | **new** - no surface renders this today |
| Tile grid (D) | 2-column grid, its column rule and odd-count behaviour | **new** |

**A, B, C and E need no new component at all.** D needs two, and the reader should see that a variant
costing two new components is a more expensive variant.

### One variant candidate the inventory killed

The brief suggested "a variant that surfaces one or two frequently-wanted rows at the top". With four
rows there is no top to surface to - promoting one of four leaves three below it, which is a hierarchy
over nothing. Not drawn, and the reason is the inventory rather than taste.

## Conventions respected

- **One `GWPageHeader`, at the top, with no `GWSectionTitle` under it.** The duplicate-title defect
  Jakub flagged on Transactions is recorded at `assets_screen.dart:354`. Sections here are `GWKicker`,
  which is a label, not a header - and `gw_kicker.dart` says so explicitly.
- **No fills and no gradient decoration.** Nothing in this menu is a commitment, so nothing is filled.
  The Swap dock stays the app's only gradient fill (`responsive_overlay.dart:452` documents it as the
  single deliberate exception), and the dashboard `View all` links were just reverted from gradient to
  flat grey (`gw_view_all_link.dart`), so the app is moving away from gradient decoration.
- **Spacing on the 4-pt grid**, with `space3` = 6 as the one documented exception
  (`genius_wallet_consts.dart:26`).

## Contrast, computed from the real tokens

Alpha borders composited over their real surfaces first, then measured against them.

| Pairing | Ratio | Needs | |
| --- | ---: | --- | --- |
| row label `#FFFFFF` on `surfaceBase` `#0B0D12` (C, D) | 19.43:1 | 4.5:1 | pass |
| row label `#FFFFFF` on `surfaceElevated` `#0C0E14` (A, B) | 19.29:1 | 4.5:1 | pass |
| row label `#FFFFFF` on `surfaceMenu` `#171A21` (E) | 17.41:1 | 4.5:1 | pass |
| sublabel `#8A8F9D` on `surfaceBase` | 6.01:1 | 4.5:1 | pass |
| sublabel `#8A8F9D` on `surfaceElevated` | 5.97:1 | 4.5:1 | pass |
| sublabel `#8A8F9D` on `surfaceMenu` | 5.39:1 | 4.5:1 | pass |
| **`GWKicker` `#8A8F9D` on `surfaceBase`** - C's entire structure | **6.01:1** | 4.5:1 | pass |
| leading icon `textPrimary80` -> `#CECFD0` on `surfaceBase` | 12.46:1 | 3:1 | pass |
| chevron `textPrimary60` -> `#9D9EA0` on `surfaceBase` | 7.25:1 | 3:1 | pass |
| track chip rest `#8A8F9D` on `surfaceSunken` `#06080C` | 6.20:1 | 4.5:1 | pass |
| track chip selected `#000B18` on `#0AAEE6`, the worst gradient stop | 7.74:1 | 4.5:1 | pass |
| track edge `borderControl` -> `#606163` on `surfaceSunken` | 3.23:1 | 3:1 | pass |
| **group hairline `borderSubtle` -> `#282A2E` on `surfaceBase`** | **1.35:1** | 3:1 | **fail** |
| **`GWCard` fill `#0C0E14` on page `#0B0D12`** - B's boxes | **1.01:1** | - | **invisible** |
| `GWCard` edge `borderSubtle` -> `#292B30` on `surfaceElevated` | 1.36:1 | 3:1 | fail |
| app bar bottom edge `borderStrong` -> `#46484C` on `surfaceElevated` | 2.11:1 | 3:1 | below, shipped knowingly (181) |

**Read the three failing rows together, because they are one finding.** Neither the hairline, nor the
card edge, nor the card fill can carry meaning on this page. That is acceptable only because **none of
them is asked to**: the sections are named in text at 6.01:1, and every row is fully readable with all
three removed. This is the same argument `gw_detail_grid.dart` already records for its own rules -
decorative separators, not WCAG 1.4.11 graphical objects.

**Variant B is the one that leans on them**, which is a real strike against B rather than a footnote.

## Recommendation

**★ Ship C - the full page, kickers and hairlines, no boxes.** It is the only variant honest about all
three facts at once: the menu has **four rows**, two of its sections hold **one row**, and a `GWCard` on
this page is a **1.01:1 fill carried by a 1.36:1 hairline**. A kicker over one row is a label and costs
nothing; a box over one row is a container with nothing in it. C uses `GWPageHeader`, `GWKicker` and
`GWSelectRow` exactly as they ship, adds no component, and is the only variant where turning
`GW_DEV_TOOLS` on adds a named group without restyling anything above it.

**Runner-up: A - the flat list.** Genuinely close, and it wins outright if you accept that four things
do not need headings. A is `_MoreSheetBody` given a page: zero new anything, the smallest diff in the
sketch. They differ on exactly one point - whether the DEVELOPER group can live behind a rule rather
than a name. **A is strictly inside C**, so adding kickers to A is C and nothing built for A is wasted.

**Explicitly rejected: D - the tile grid.** Two new components and a second visual language for "a place
you can go", to fix the fact that a four-row page has whitespace. The menu is the app's least-visited
surface and D gives it the visual weight of a dashboard, inverting the rule the sketch is built on. If
the page looks thin, that is information about the app, not a defect to decorate away.

**On E, which is not rejected.** At today's four rows the sheet is defensible and it is the cheapest
option here, because two of the brief's three arguments for a page are weak at this size and only the
children argument holds. **Ship the page anyway** - for that one surviving reason: every row opens a
full screen, and a sheet that opens a screen destroys itself to do it. If that reason ever stops
mattering, E is the honest fallback, and it is a deletion rather than a build.

## If C ships

| File | Change |
| --- | --- |
| `lib/navigation/router.dart` | a `/menu` route inside the shell |
| a new `MenuScreen` | `GWPageHeader` + three `GWKicker` groups over `GWSelectRow`s driven by `_moreDestinations`, plus a `kShowDevTools` group |
| `lib/components/overlay/responsive_overlay.dart` | `_MoreSheetBody` and its `Accounts` row are deleted; `_moreDestinations` stays and becomes the page's source |
| `lib/components/overlay/mobile_header.dart` | the 181-F hamburger targets `/menu` |

## Still open

- **Does Appearance get promoted out of the dev bubble?** The logic ships and persists; the user-facing
  control does not exist, and `gw_appearance.dart:12` documents a Preferences sheet that was never
  built. One row would close a stale comment and give the menu its first item that is not a destination.
  Not taken here, because the instruction was to draw only what exists.
- **Is "Settings" the right label** for a screen of spdlog levels, PubSub ports and CRDT backup
  intervals? Under `GW_DEV_TOOLS` the menu holds two developer groups, one called Settings.
- **Where does the menu page go back to?** The hamburger toggles in this mock. A pushed `/menu` inside
  the shell has no back affordance of its own; Transactions and Assets both push without one today.
- **`go` vs `push`.** 182 already flagged that `/assets` is pushed from the dashboard and `go`-ed from a
  tab. The menu will hit the same question for `/markets`, `/web`, `/logs` and `/settings`, and today's
  `_MoreSheetBody` uses `context.go` (`responsive_overlay.dart:524`).
- No device verification - browser at 1:1, not Jakub's iPhone. Light mode not computed, per the
  dark-first rule.

## Provenance

Tokens verbatim from `lib/theme/gw_colors.dart` and `genius_wallet_consts.dart`. Header geometry
verbatim from `mobile_header.dart` - 60px app bar (`toolbarHeight: 60`), 1px `borderStrong` bottom edge,
mark 28 / wordmark 18 lockup, `space8` titleSpacing, and the 181-F cluster at 44 + `space6` 12 + 44. Bar
geometry from `responsive_overlay.dart` - 60px bar, 20pt capped inset, 64px dock with 26px overhang in
an 84px slot, S7 destinations. Phones are 390 x 844 at 1:1. Contrast by the WCAG 2.x relative-luminance
formula.

`node --check` clean; whole-file div balance 0 (186 open / 186 close); **170 render combinations** (5
variants x 2 dev states x home + menu + sheet + 7 destinations + 7 returns) executed headlessly against
a DOM shim, every fragment div-balanced, no throws, dev rows correctly gated in both directions and a
back link present on every child screen.
