---
status: superseded-in-part
superseded_on: 2026-08-07
superseded_by: >
  Jakub, after this plan was written: ok, so let's stay with the Menu that
  opens from the bottom. The Menu stays a BOTTOM SHEET. Everything in this plan that builds
  a top-level `/menu` route is dead - the new screen, the router entry, the
  right-to-left transition, the chromeless surface, the "back to where you came
  from" control, the `?from=` origin query parameter and the "‹ Menu" links on
  the four child screens. The hamburger keeps calling `MoreSheet.show`.

  What SURVIVES and is why this file is kept: the row inventory and its
  file-and-line citations; that the menu has exactly four derived rows (Markets,
  Web, Feedback -> `/logs`, Settings) plus Accounts; that `SettingsScreen` is
  SDK configuration and not preferences, so no appearance, security, currency,
  language or notification rows exist to build; that variant C needs zero new
  components because `GWSelectRow` already rests on a transparent fill and a
  transparent border; and the trap that the path-to-kicker map must ORDER and
  LABEL only, never decide which rows exist, or promoting a destination off the
  bar silently strands it.

  The remaining work is small: put variant C's body inside the existing sheet.
phase: quick-260807-menu
plan: 01
type: execute
wave: 2
depends_on:
  - quick-260807-s7n
files_modified:
  - lib/menu/menu_screen.dart
  - lib/navigation/router.dart
  - lib/components/overlay/mobile_header.dart
  - lib/components/overlay/more_sheet.dart
  - lib/dashboard/chart/markets_screen.dart
  - lib/settings/settings_screen.dart
  - lib/logs/submit_logs_screen.dart
  - lib/web/web_view_screen.dart
  - lib/web/web_view_mobile.dart
  - test/menu/menu_screen_test.dart
  - test/components/mobile_nav_destinations_test.dart
autonomous: false
requirements: [QUICK-260807-MENU]

must_haves:
  truths:
    - "Tapping the header hamburger opens a FULL SCREEN Menu page that slides in from the right, with no bottom navigation bar and no app header. Sketch 184 variant C, picked by Jakub on 2026-08-07."
    - "The Menu page's back control returns to whatever route the user came from - a pop, not a hard-coded push to /dashboard (D-02, Jakub: 'tak tak, system powrotow ok')."
    - "The four child screens keep their bottom bar AND their normal top navigation, unchanged (D-03, Jakub: 'tak dzieci konkretne page maja pasek i top navigation normalnie'). /menu is the ONLY chromeless surface in the app."
    - "A child reached FROM the menu shows a back link reading the origin passed to it. A child reached any other way renders exactly the widget tree it renders today, with no back link at all - so the label can never lie about where back goes."
    - "The menu's rows stay DERIVED from `moreDestinations`. Promote a destination onto the bar and it leaves the menu with no second edit, and a test proves set equality rather than membership."
    - "`more_sheet.dart` is retired, not left orphaned. Its only caller was `HeaderMenuButton`, and this task retargets that caller."
    - "Full screen, no bottom bar and the right-to-left slide all come from ONE structural fact - `/menu` is declared OUTSIDE the `ShellRoute` - and cost no custom transition, no custom page builder and no new component."
  artifacts:
    - lib/menu/menu_screen.dart
    - test/menu/menu_screen_test.dart
  key_links:
    - "`/menu` is a TOP-LEVEL `GoRoute`, a sibling of the `ShellRoute` at `router.dart:213` and not a child of it. That single placement delivers all three of Jakub's requirements at once. Moving it inside the shell silently restores the bottom bar and the header."
    - "The hamburger uses `context.push`, never `context.go`. `go` replaces the match list, which destroys the route the menu's back control has to pop to."
    - "Origin travels as a QUERY PARAMETER read in the route builder, never as `extra`. `/logs` already binds `extra` to a String prefill (`router.dart:323`) and `/web` binds it to `WebViewExtras` (`router.dart:259`), so `extra` is occupied on half the destinations."
    - "The group map in `menu_screen.dart` must never be the thing that decides which rows exist. Any `moreDestinations` member no group claims renders under a final catch-all group, so the derivation stays self-maintaining."
    - "`GWSelectRow` ships with a transparent resting background (`gw_select_row.dart:108-111`). That is what makes variant C possible with zero new components - the row is already card-less."
---

<objective>
Build the Menu page: sketch 184 variant C, as a full-screen route outside the
shell, reached from the header hamburger that quick task `20260807-bottom-nav-s7`
has just landed.

Jakub, 2026-08-07, picking C and amending it in the same breath:

> Let's build option C, only it will be full screen, with a breadcrumb back to
> <- Menu in the top left corner and with no bottom navigation bar. When you tap
> menu, the menu slides in from the right - it will look basically like this,
> plus the breadcrumb (back to the previous page).

And ruling on the two questions that amendment opened:

> Yes, the back system is fine.
> Yes, the individual child pages keep their bar and top navigation as normal.

Purpose: the hamburger currently opens a bottom sheet whose four rows each open
a full screen, and a sheet that opens a screen must destroy itself to do it.
Variant C's own recommendation rests on that one surviving argument.

Output: `/menu`, a `MenuScreen`, a retired `more_sheet.dart`, and a back link on
the four destinations that only appears when it is telling the truth.
</objective>

<execution_context>
@$HOME/.claude/gsd-core/workflows/execute-plan.md
</execution_context>

<context>
@.planning/sketches/184-menu-page/README.md
@.planning/quick/20260807-bottom-nav-s7/PLAN.md
@lib/components/overlay/nav_destinations.dart
@lib/components/overlay/mobile_header.dart
@lib/components/overlay/more_sheet.dart
@lib/components/cards/gw_select_row.dart
@lib/components/cards/gw_kicker.dart
@lib/components/gw_back_link.dart
@lib/components/scaffold/gw_page_header.dart
@lib/navigation/router.dart
</context>

<findings>

## 0. SEQUENCING: this task runs AFTER `20260807-bottom-nav-s7`, and that is not advisory

`.planning/quick/20260807-bottom-nav-s7/PLAN.md` ships sketch 182 scheme S7 (the
bar becomes Home, Assets, [Swap dock], Activity, News) and sketch 183 scheme F
(a 44x44 wallet chip plus a bare 44x44 hamburger in the header). It edits
`mobile_header.dart`, `responsive_overlay.dart` and `router.dart`. This task
edits two of those three.

**Verified on disk while planning, 2026-08-07 13:40.** S7 is mid-execution. Its
first three artifacts already exist and are untracked:

| File | State | Evidence |
| --- | --- | --- |
| `lib/components/overlay/nav_destinations.dart` | landed | `allDestinations` 37, `mobileDestinations` 137, `moreDestinations` 184, `kNonDerivableMobilePaths` 196 |
| `lib/components/overlay/more_sheet.dart` | landed | `MoreSheet.show` 22, `MoreSheetBody` 40 |
| `lib/components/overlay/mobile_header.dart` | landed | `kHeaderControlSize` 14, `HeaderMenuButton` 493, `onPressed: () => MoreSheet.show(context)` **522** |
| `lib/components/overlay/responsive_overlay.dart` | **NOT YET** | still the 10:34 version, still holds `_MoreSheetBody` and `_MobileMoreItem` |
| S7 Task 2 test files | **NOT YET** | `test/components/mobile_nav_destinations_test.dart` does not exist |

**The executor must confirm S7 is fully complete before starting.** The gate is
`flutter analyze` clean plus `test/components/mobile_nav_destinations_test.dart`
existing and passing. Starting mid-S7 means editing a `mobile_header.dart` whose
sibling `responsive_overlay.dart` still declares a duplicate `_MoreSheetBody`.

**What S7 leaves that this task consumes:**

- `moreDestinations` derives to exactly **Markets, Web, Feedback, Settings**.
  Confirmed by reading the landed file: `allDestinations` holds the eight
  entries, `mobileDestinations` holds `/dashboard`, `/assets`, `/transactions`,
  `/news`, and the getter at 184 subtracts those plus `/swap`.
- **`Feedback` routes to `/logs`, not `/feedback`** (`nav_destinations.dart:70`,
  `router.dart:317`). The label and the path disagree and both are correct.
- `HeaderMenuButton` **already exists and already opens a sheet**. This task's
  change to it is a **retarget of one line**, not a creation.

## 1. The structural finding: full screen, no bar, and the slide are all one decision

`router.dart:213` declares a `ShellRoute` whose builder mounts `MobileOverlay`,
and `MobileOverlay` (`responsive_overlay.dart:794-831`) is the `Scaffold` that
owns `appBar: const MobileHeader()` and
`bottomNavigationBar: const _MobileTabBar()`.

**Thirteen `GoRoute`s already sit OUTSIDE that shell**, verified by reading the
file: `/` 75, `/buy/orders` 81, `/createOrder` 90, `/orderDetails` 104,
`/banxa/callback` 118, `/checkoutQR` 141, `/kyc` 173, `/checkout` 179,
`/network` 192, `/dev/token-probe` 201, `/design_gallery` 207, `/bridge` 367,
`/submit_job` 377.

A top-level `/menu` therefore gets no `MobileOverlay`, which means **no bottom
bar and no header**, for free.

**This is not inference. The codebase already documented the behaviour, twice,
as a defect it was fixing in the opposite direction:**

> `router.dart:228-231`, on `/assets`: "INSIDE the shell is load-bearing:
> outside it the page would replace the bottom bar and the wallet header with
> its own chrome"

> `router.dart:327-332`, on `/token-info`: "It was the only screen in the app
> outside it, which is why it was the only screen with no navigation"

Outside-the-shell pages replacing the chrome is observed, shipped behaviour in
this repo. This task wants exactly that, deliberately, for one route.

### The transition, checked rather than asserted

The brief asked for this to be verified before planning around it. It was.

| Claim | Checked | Result |
| --- | --- | --- |
| App is a `MaterialApp.router` | `main.dart:365`, `routerConfig: geniusWalletRouter` at 385 | confirmed |
| No custom `pageBuilder` anywhere | `grep -rn "pageBuilder" lib` | **zero hits** |
| No `NoTransitionPage` / `CustomTransitionPage` | same grep | **zero hits** |
| No app-wide transition override | `grep -rn "pageTransitionsTheme\|PageTransitionsTheme\|PageTransitionsBuilder" lib` | **zero hits** |
| No `ThemeData.platform` override | `lib/theme/theme.dart:61` `ThemeData(` block | no `platform:` key |

Every route in `router.dart` uses `builder:`, never `pageBuilder:`. With a
`MaterialApp` ancestor go_router wraps a `builder` route in a `MaterialPage`,
whose transition resolves through `Theme.of(context).pageTransitionsTheme`.
Unset, that is Flutter's default map, which pairs `TargetPlatform.iOS` with
`CupertinoPageTransitionsBuilder` - a right-to-left slide.

**So the slide is free on iOS, and this plan adds no transition code.** It is
still a framework default read from source rather than a behaviour observed on
device, so it is the FIRST item at the checkpoint. If it does not slide, the
remedy is a `CustomTransitionPage` on this one route and nothing else changes.

## 2. `push`, not `go`, and the reason is Jakub's own back requirement

`MoreSheetBody` navigates with `context.go(d.path)` (`more_sheet.dart:55`).
`go` REPLACES the match list. Applied to the hamburger it would destroy the
route the menu's back control has to return to, and D-02 requires a pop.

So the hamburger uses `context.push('/menu')` and the menu's rows use
`context.push(path)`.

### Pushing a shell child from outside the shell is already shipped

This was the one genuinely risky part of the design, and the precedent exists in
the tree. `lib/submit_job/view/widgets/job_steps.dart:806`:

    final router = GoRouter.of(context);
    ...
    router.push('/logs', extra: message);

with the comment above it stating the exact situation, at 792-796: the drawer
route was "pushed on the ROOT navigator ... while `/logs` lives under the
`ShellRoute`". `lib/web/web_utils.dart:19` does the same for `/web`.

**A GoRouter push from a root-level location into a `ShellRoute` child is
therefore shipped, commented and in use.** It mounts the shell for the pushed
match, which is precisely what D-03 asks for - the child arrives with its bar and
its header.

### One push gotcha, already documented in this repo

`global_swap_fab_host.dart:133-143` records that an imperative `push` appends an
`ImperativeRouteMatch` **without moving `currentConfiguration.uri`**, and that
this once left the FAB floating over the screen it had just opened.

Consequence for this task: **do not read the origin from
`GoRouterState.of(context)` inside a screen's `build`.** Read it in the ROUTE
BUILDER, where `state` is unambiguously the matched route's own state. That is
already the house pattern - see finding 4.

### The FAB cannot float over the menu

Same file, 156-161: `hidden` is true whenever `usesMobileShell` is true, and
`GeniusBreakpoints.isMobileApp()` makes that unconditional on iOS. The swap FAB
is never mounted on a phone, so a chromeless `/menu` gains no stray floating
control. `DevToolsBubbleHost` sits at the same level and is `kDebugMode &&
kShowDevTools` only.

## 3. What the four child screens actually have today, and it is not what a reviewer would guess

The brief asked whether a second back control would conflict with an existing
one. **Read all four. Three of them have no back affordance of any kind.**

| Screen | File | Top chrome today | Back affordance today |
| --- | --- | --- | --- |
| Markets | `markets_screen.dart:105` | `GWPageHeader(title: "Markets")`, no `AppBar` | **none** |
| Feedback | `submit_logs_screen.dart:425-464` | `Scaffold` with an explicit "No AppBar" comment at 426, then `GWPageHeader` | **none** |
| Settings | `settings_screen.dart:170-171` | `GWScreen(appBar: AppBar(title: const Text('Settings')))` | **none rendered** - see below |
| Web | `web_view_mobile.dart:354-361` | `Scaffold` > `SafeArea` > tab strip + search bar + webview, no `AppBar` | **browser back only** - see below |

**So "‹ MENU" on the children is NEW work on at least three screens, not a label
change on an existing back button.** That is worth stating plainly because the
opposite assumption would have made this task look like a one-liner.

### Settings: an `AppBar` that renders no leading, and why

`AppBar` implies a leading `BackButton` only when its enclosing route reports
`impliesAppBarDismissal`, which means "not the first route in ITS navigator".
`/settings` lives in the `ShellRoute`, so its `AppBar` sits inside the shell's
NESTED navigator. Pushed from `/menu`, the root navigator gains a page but the
shell's nested navigator still holds exactly one - so no leading arrow appears.

**This must be confirmed at run time, not trusted.** If an arrow does appear,
the fix is `automaticallyImplyLeading: false` on that one `AppBar`, never a
second back control beside it. Task 2 states both branches.

### Web: a real double-back risk, named rather than glossed

`web_view_mobile.dart:596` renders `Icons.arrow_back` inside `_omniboxNavButton`,
gated on `_controllers[...].canGoBack()`. **That is the BROWSER's back, not the
route's.** Adding a route back link to this screen puts two different backs on
one surface.

They are separable: the route back is a labelled text link at the top edge, the
browser back is an icon inside the omnibox row lower down. The plan ships it and
makes it the checkpoint's second question. It is the one place where Jakub's
"children read ‹ Menu" ruling has a visible cost.

Also note `WebViewScreen` already carries an `includeBackButton` flag
(`web_view_screen.dart:10`) that `web_utils.dart:19` sets to `true` for a link
launch and that the menu's `go` leaves null. **That flag is not the route back
and must not be reused for it.**

## 4. The origin mechanism: a query parameter, read in the builder

Jakub's ruling says children read "‹ Menu". The brief asks what happens when a
child is reached some other way, since a hard-coded label would then lie.

**It would lie in three real cases, all verified:**

| Route | Other entrance | Call |
| --- | --- | --- |
| `/markets` | dashboard Markets panel | `dashboard_markets.dart:106`, `context.go('/markets')` |
| `/logs` | job flow "Get help" | `job_steps.dart:806`, `router.push('/logs', extra:)` |
| `/web` | any in-app link | `web_utils.dart:19`, `context.push('/web', extra:)` |
| `/settings` | **none** | menu only |

### The pick: an explicit origin, defaulting to no link at all

Not a context-dependent guess, and not an accepted lie. **The caller states its
own origin**, and a child that was not told one renders no back link and is
therefore byte-identical to today.

This is the repo's own written rule, at `router.dart:308-311` on `/buy`:

> "The back link's label ... Each caller passes its own origin explicitly -
> never sniffed from the nav stack, which breaks silently on a deep link.
> `BanxaBuyScreen` falls back to 'BACK' when absent."

So this task reuses `/buy`'s shipped `originLabel` shape on four more routes.

### Why a query parameter and not `extra`

`extra` is already occupied on half the destinations:

- `/logs` binds it to a `String?` prefill, `router.dart:323`
- `/web` binds it to `WebViewExtras`, `router.dart:259-261`

A uniform origin through `extra` would collide with both. A query parameter
touches neither, and `navIndexForLocation` reads `uri.path`
(`nav_destinations.dart:98/108`), which strips the query - so the bottom bar's
active-tab logic is unaffected. **Task 2 must confirm that `.path` read survived
S7's extraction verbatim.**

The menu pushes `'${d.path}?from=MENU'`. The value is the LABEL, already
uppercased, exactly as `GWBackLink` expects (`gw_back_link.dart:22-28`: "rendered
exactly as given, so a caller decides its own casing").

## 5. Variant C needs zero new components, verified against each one

The sketch claims this. Every component was opened and checked.

| Part | Component | API supports C? |
| --- | --- | --- |
| Page title | `GWPageHeader(title:)`, `gw_page_header.dart:9` | yes, `title` is the only required param, owns `space8` below at 212 |
| Section labels | `GWKicker(label)`, `gw_kicker.dart:23` | yes, owns no padding at all (doc at 21-22), which is what lets the call site place it |
| Every row | `GWSelectRow`, `gw_select_row.dart:34` | **yes, and this is the load-bearing one** - see below |
| Row chevron | `GWSelectRow.trailing`, `gw_select_row.dart:65` | yes, an existing slot |
| Back link | `GWBackLink(label:, onTap:)`, `gw_back_link.dart:37` | yes, `onTap` is a callback so `pop` is expressible |
| Group hairline | inline `Container(height: 1, color: gw.borderSubtle)` | sanctioned - see below |

### `GWSelectRow` is already card-less, which is the whole reason C is cheap

`gw_select_row.dart:104-119`: the decoration is
`color: selected ? null : (hovered ? GWDecorations.hoverFill : Colors.transparent)`
with a border that is `Colors.transparent` unless selected or hovered. Its own
comment at 30-33 says the resting state is transparent because "a row painted the
panel's own colour is decoration nobody sees".

**So the shipped row already renders as bare text on the page background with a
kicker above it.** No card, no fill, no edge. Variant C is `GWSelectRow` used
exactly as it ships, which is what the sketch claimed and it holds.

`leading` is `required` and non-nullable - every menu row has an icon
(`nav_destinations.dart` gives each destination one), so this is satisfied
rather than worked around.

### The hairline is the ONE adapted part, and `gw_kicker.dart` spells the recipe

`gw_kicker.dart:37-41` says sketch 065 drew this and did not pick it, then names
the exact shape: "it is an `Expanded(Container(height: 1, color:
gw.borderSubtle))` in this Row". Using that literal shape is following a
documented recipe, not hand-rolling a widget. **Do not promote it to a
component**: one consumer does not earn one, which is the bar `gw_page_header.dart:31`
and `gw_kicker.dart:44-49` both state.

## 6. Contrast, and the three failing rows are load-bearing information

From the sketch, recomputed against `lib/theme/genius_wallet_colors.dart` tokens.
**Everything on this page sits on `surfaceBase` `#0B0D12`**, so `MenuScreen`'s
`Scaffold.backgroundColor` MUST be `gw.surfaceBase` or every number below is
wrong. That is also what `MobileOverlay` itself uses (`responsive_overlay.dart:816`).

| Pairing | Ratio | Needs | |
| --- | ---: | --- | --- |
| row label `#FFFFFF` on `surfaceBase` | 19.43:1 | 4.5:1 | pass |
| `GWKicker` `#8A8F9D` on `surfaceBase` - C's entire structure | **6.01:1** | 4.5:1 | pass |
| leading icon `textPrimary80` composited `#CECFD0` | 12.46:1 | 3:1 | pass |
| chevron `textPrimary60` composited `#9D9EA0` | 7.25:1 | 3:1 | pass |
| back link `textSecondary` `#8A8F9D` | 6.01:1 | 4.5:1 | pass |
| group hairline `borderSubtle` composited `#282A2E` | **1.35:1** | 3:1 | **fail** |

**The hairline failure is accepted, and the reason is why C beat B.** The groups
are NAMED IN TEXT at 6.01:1, so the line carries no information and WCAG 1.4.11
does not apply to it - the same argument `gw_detail_grid.dart` already records
for its own rules. Remove every hairline and the page is still fully readable.

The measurement that killed the boxed variant: **`GWCard` fill `#0C0E14` on page
`#0B0D12` is 1.01:1**, carried by a 1.36:1 edge. A card on this page is a
hairline pretending to be a container. **Do not add one.**

## 7. Derived, not hard-coded - and the trap that would silently break it

The brief asks whether `/menu` keeps deriving its rows. **It does.**

`moreDestinations` (`nav_destinations.dart:184`) is `allDestinations` minus
`/swap` minus whatever the bar shows. The sketch calls this self-maintaining and
S7's own key_links pin it with a set-equality test.

**The trap is the GROUPING, not the list.** Variant C needs EXPLORE / APP /
SUPPORT, which is a path-to-kicker map. If that map is the thing that decides
which rows render, then promoting a destination off the bar puts it into
`moreDestinations` with no group - and it vanishes from the menu silently. That
would destroy the exact property the derivation exists for.

**So the group map orders and labels; it never filters.** Any `moreDestinations`
member no group claims renders under a final catch-all. Task 3 pins this with a
test that adds a fake unclaimed destination and asserts it still renders.

## 8. `more_sheet.dart` becomes dead, and the analyzer will NOT tell you

Verified: `MoreSheet` and `MoreSheetBody` have exactly one consumer between
them, `mobile_header.dart:522`. Nothing in `test/` references either
(`grep -rln "MoreSheet\|more_sheet\|HeaderMenuButton" test/` returns nothing).

Retargeting line 522 leaves the file with zero callers. **Dart's analyzer does
not flag unused PUBLIC top-level symbols**, so unlike S7's `_MobileMoreItem`
(private, and S7's own key_link notes `flutter analyze` is what keeps that
removal honest) this one would linger silently and rot.

**Delete the file.** Two things must be checked first, because S7's Task 2 had
not run when this was planned:

1. `test/components/mobile_nav_destinations_test.dart` may mount `MoreSheetBody`
   to assert the sheet-plus-bar union. If it does, repoint it at `MenuScreen` -
   the union assertion still holds, because the menu derives from the same
   `moreDestinations`.
2. `AccountDrawer` import: `more_sheet.dart:2` is the only thing keeping that
   import path alive here, and the sheet's `Accounts` row does NOT move to the
   menu (finding 9).

## 9. The `Accounts` row does not move to the menu, and that is sketch 184's design

`more_sheet.dart:59-71` carries an `Accounts` row opening
`AccountDrawer.show(context)`. Sketch 184 deletes it, and the README states why
at its own section 4: under sketch 183 scheme F the wallet chip sits 12px from
the hamburger and both would lead to the same drawer. **"That deletion is why the
menu is four rows and not five. Its absence is the design."**

S7 already shipped that adjacency (`mobile_header.dart:124`, `HeaderMenuButton`
beside `WalletPill`). So the row goes, and it goes because the control beside the
hamburger already does its job.

## 10. The DEVELOPER group, and the one row that is not a destination

Gated on `kDebugMode && kShowDevTools`. `dev_flags.dart` is explicit: "Always
combine with `kDebugMode` at the call site so these can never ship in a release
build, whatever the define says." `kShowDevTools` alone is not the gate.

| Row | Route | Where | Shape |
| --- | --- | --- | --- |
| Design gallery | `/design_gallery` | `router.dart:207`, **outside** the shell | `GWSelectRow` |
| Token probe | `/dev/token-probe` | `router.dart:201`, **outside** the shell | `GWSelectRow` |
| Appearance | none | `GWAppearance.setMode`, `gw_appearance.dart:40` | **not a destination** |

Both dev routes are already outside the shell, so pushing them from `/menu` is a
plain root push with no shell involved and no `?from=` handling needed.

**Appearance is the awkward one and it is in scope.** Its logic is complete and
persisted, and its only control today is in the dev bubble
(`dev_tools_bubble.dart:1219`). Its own doc comment at `gw_appearance.dart:12`
points at a "Preferences sheet (Appearance row)" that was never built. Task 1
states its two acceptable shapes and forbids inventing a third.

## 11. Spacing, and the one value that deliberately differs from every other page

All from `genius_wallet_consts.dart`: `space2` 4, `space3` 6, `space4` 8,
`space6` 12, `space8` 16, `space12` 24, `space32` 64.

Components that own their own spacing, so the call site must NOT double it:

- `GWPageHeader` owns `space8` BELOW itself (`gw_page_header.dart:212`)
- `GWSelectRow` owns `margin: bottom space2` and `padding: space6` on both axes
  (`gw_select_row.dart:99-103`)
- `GWBackLink` owns `EdgeInsets.fromLTRB(12, 0, 12, space4)`
  (`gw_back_link.dart:55-60`)

**The page gutter is 0 on the outer padding and 12 on each child.** Verbatim the
rule `assets_screen.dart:287-291` states: "GWBackLink already carries its own 12,
so an outer 12 would double it and push the back link off the x-axis every other
content page shares."

**The top gap is `space8` (16), not `space32` (64), and this is the one stated
deviation.** Every shell page uses 64 as the navbar-to-title gap
(`markets_screen.dart:85`, `assets_screen.dart:290`). `/menu` has no navbar - the
64 exists to clear a 60px `AppBar` band that this page does not have. Using it
here would park 64px of dead space under the notch. 16 is on the 4-pt grid and
sits below a `SafeArea` that already supplies the notch inset.

</findings>

<decisions>

Settled by Jakub on 2026-08-07. Not to be re-opened or re-argued in the SUMMARY.

- **D-01** - Build sketch 184 **variant C**: kickers plus hairlines, nothing
  boxed. Sections EXPLORE (Markets, Web), APP (Settings), SUPPORT (Feedback),
  and DEVELOPER only under the dev flag.
- **D-02** - The **Menu page's** back control returns to whatever route the user
  came from. A pop, not a hard-coded destination. Source: "tak tak, system
  powrotow ok".
- **D-03** - The **child screens keep their bottom bar and their normal top
  navigation**. Source: "tak dzieci konkretne page maja pasek i top navigation
  normalnie". `/menu` is the only chromeless surface.
- **D-04** - The child screens' back affordance reads **"‹ Menu"** when reached
  from the menu.
- **D-05** - `/menu` is **full screen, no bottom navigation bar, and slides in
  from the right**.

</decisions>

<constraints>

- **Do NOT create any commit.** Not per task, not at the end. Leave the tree
  dirty for Jakub. Branch is `redesign/navigation-260806`, base `develop`, HEAD
  `47e0565c`. This overrides the execute-plan workflow's commit steps.
- **Do NOT start until S7 is complete.** See finding 0 for the gate.
- **Do NOT put `/menu` inside the `ShellRoute`.** It is a sibling of it. That one
  placement is D-05 in its entirety.
- **Do NOT add a `GWCard`, a fill or a border to any menu group.** 1.01:1 on
  1.36:1, finding 6. C beat B on exactly this measurement.
- **Do NOT add a second back control anywhere.** If a screen already renders one,
  suppress the existing one or use it - never stack two. Finding 3.
- **Do NOT reuse `WebViewScreen.includeBackButton`** for the route back. It is
  the browser's control and `web_utils.dart:19` already sets it.
- **Do NOT pass the origin through `extra`.** It is occupied on `/logs` and
  `/web`. Finding 4.
- **Do NOT read the origin from `GoRouterState.of(context)` inside a screen
  build.** Read it in the route builder. Finding 2.
- **Do NOT hard-code the menu's four rows.** They derive from `moreDestinations`.
  Finding 7.
- **Do NOT let the group map filter rows.** It orders and labels only. Finding 7.
- **Do NOT move the `Accounts` row into the menu.** Finding 9.
- **Do NOT add rows for appearance, security, currency, language or
  notifications as user-facing settings.** None exist in `lib/`. `SettingsScreen`
  is SDK configuration - Log Config, Network Config, CRDT Config.
- **Do NOT add a version row or an About row.** Nothing in `lib/` renders
  `pubspec.yaml`'s version and there is no `showAboutDialog` anywhere.
- **Do NOT promote the group hairline to a component.** One consumer.
- Existing `GW*` components, extended additively, never hand-rolled. Variant C
  needs zero new ones and finding 5 checks each API.
- Mobile only, iOS. Dark mode first; light mode is a later dedicated pass.
- 4-pt grid, existing tokens only. `space3` = 6 is the ONE documented exception.
  The single untokened value is the top gap's reason in finding 11.
- WCAG AA computed from real tokens: 4.5:1 text, 3:1 non-text state indicators.
  The hairline's 1.35:1 is accepted with the argument in finding 6 recorded in
  the code, not silently.
- **No em dashes**, in UI strings, code comments or the SUMMARY. Write "a - b"
  with a plain hyphen. Only lines this task adds or rewrites must obey it; do not
  sweep unrelated existing lines.
- **Do not use "v1", "for now", "placeholder", "simplified", "basic" or "future
  enhancement"** in any code comment or SUMMARY line.
- Nothing under `lib/banxa/` or `lib/squid_router/`.

</constraints>

<tasks>

<task type="auto" tdd="true">
  <name>Task 1: the /menu route, the MenuScreen, and the hamburger retarget</name>
  <files>lib/menu/menu_screen.dart, lib/navigation/router.dart, lib/components/overlay/mobile_header.dart, lib/components/overlay/more_sheet.dart, test/menu/menu_screen_test.dart</files>
  <behavior>
    - Given a phone shell on /dashboard, tapping the header hamburger pushes /menu.
    - MenuScreen renders no bottom navigation bar and no MobileHeader, because it is not inside the ShellRoute.
    - MenuScreen renders one GWPageHeader titled Menu, and no GWSectionTitle under it.
    - MenuScreen renders exactly one GWSelectRow per member of moreDestinations - Markets, Web, Feedback, Settings.
    - A moreDestinations member that no group claims still renders, under a final catch-all kicker.
    - MenuScreen renders no GWCard and no boxed group.
    - With kShowDevTools off, no DEVELOPER kicker renders.
    - Tapping a row pushes that destination's path carrying the origin query value MENU.
    - The back control pops when there is something to pop, and falls back to /dashboard when there is not.
  </behavior>
  <action>
**Precondition.** Confirm S7 is complete per finding 0 before editing anything:
`flutter analyze` clean, `responsive_overlay.dart` no longer declaring
`_MoreSheetBody` or `_MobileMoreItem`, and
`test/components/mobile_nav_destinations_test.dart` present and passing. If S7 is
still mid-flight, stop and report rather than editing a half-migrated tree.

**(a) NEW `lib/menu/menu_screen.dart`.**

A `StatelessWidget` named `MenuScreen` taking one nullable `String originLabel`
constructor parameter. Directory `lib/menu/` is new and matches the house layout
that already gives `lib/settings/` and `lib/logs/` their own folders.

Root is a `Scaffold` with `backgroundColor: gw.surfaceBase` - required, per
finding 6, because every contrast number for variant C was computed on
`#0B0D12`, and it is the same value `MobileOverlay` sets at
`responsive_overlay.dart:816`. Read `gw` with the fail-soft
`Theme.of(context).extension<GWColors>() ?? GWColors.dark()` pattern every other
component in this codebase uses, so a live appearance toggle rebuilds the page.

Body is a `SafeArea` wrapping a scrollable column. The page has no `AppBar`, so
`SafeArea` is what supplies the notch inset - state that in a comment, because it
is the thing a reader will assume the shell was doing.

Outer padding `EdgeInsets.fromLTRB(0, space8, 0, space8)`. Horizontal gutter is 0
here and 12 on each child, per finding 11 and verbatim the rule
`assets_screen.dart:287-291` states. The `space8` top is the ONE deliberate
departure from the app's `space32` navbar-to-title gap and its reason goes in a
comment: 64 exists to clear a 60px app bar band that this page does not have.

Children, in order:

1. `GWBackLink(label: originLabel ?? 'BACK', onTap: () => context.canPop() ?
   context.pop() : context.go('/dashboard'))`. The `canPop` ternary is the
   shipped recipe at `assets_screen.dart:347-348`, copied for the reason its own
   comment gives - a deep link has nothing to pop. `'BACK'` is the documented
   fallback string `router.dart:311` already names for `/buy`. Do NOT wrap it in
   a `Padding`: `GWBackLink` carries its own 12.
2. `GWPageHeader(title: 'Menu')` inside `Padding(horizontal: 12)`. **The page's
   only title.** Mount no `GWSectionTitle` under it - that is the duplicate-title
   defect recorded at `assets_screen.dart:354`. `GWPageHeader` owns the `space8`
   below itself, so add no spacer after it.
3. The groups.

**Group model.** A private ordered list of records, each pairing a kicker string
with the destination paths it claims:

    const _kMenuGroups = <({String kicker, List<String> paths})>[
      (kicker: 'Explore', paths: ['/markets', '/web']),
      (kicker: 'App', paths: ['/settings']),
      (kicker: 'Support', paths: ['/logs']),
    ];

Pass the kicker strings in normal casing. `GWKicker` upper-cases them itself and
its doc at `gw_kicker.dart:26-28` forbids callers pre-calling `toUpperCase()`,
because a pre-uppercased label reads identically but loses its casing for screen
readers.

**The map ORDERS and LABELS; it must never FILTER.** Build the rendered groups by
walking `_kMenuGroups`, selecting from `moreDestinations` the members whose path
that group claims, and skipping a group that ends up with no members - which is
what makes `/web` disappearing on Linux collapse EXPLORE cleanly rather than
leaving an empty heading. Then append a final group holding every
`moreDestinations` member no group claimed. Finding 7 is the whole reason: the
derivation is self-maintaining and a filtering map would silently strand a
destination promoted off the bar. Give that final group a kicker of `'More'`.

**Each group renders as:** `GWKicker(kicker)` inside `Padding(horizontal: 12)`,
then `space4`, then its rows, then the terminator hairline.

**Each row:** `GWSelectRow` with `leading: Icon(d.icon, size: 21, color:
gw.textPrimary80)` - byte-identical to the leading `more_sheet.dart:51` already
renders, so the rows look the same as the sheet's did - `title: d.label`,
`trailing: Icon(Icons.chevron_right, size: 18, color: gw.textPrimary60)` at
7.25:1, and `onTap: () => context.push('${d.path}?from=MENU')`. Wrap the row list
in `Padding(horizontal: 12)`.

No `subtitle` on any destination row. The sheet carried none and none of the four
labels needs one.

`trailing` is an existing `GWSelectRow` slot (`gw_select_row.dart:65`), so the
chevron is a use of the component, not an extension of it. Note in a comment that
the sheet shipped no chevron and this page adds one because every row here opens
a full screen, which is variant C's own surviving argument for being a page.

**The group terminator hairline:** `Container(height: 1, color: gw.borderSubtle)`
inside `Padding(horizontal: 12)`, with `space6` above and below. This is the one
part sketch 184 marks adapted, and `gw_kicker.dart:37-41` spells the exact shape
and records that sketch 065 drew it and did not pick it. Do NOT promote it to a
component. Its doc comment must carry finding 6's argument: it measures 1.35:1
against the page, which is below 3:1, and that is acceptable ONLY because every
group is also named in text at 6.01:1 and nothing here depends on the line. Omit
the hairline after the last group so the page does not end on a rule.

**DEVELOPER group.** Gated on `kDebugMode && kShowDevTools`, both, per
`dev_flags.dart`. Appended after the derived groups, kicker `'Developer'`, with:

- a `GWSelectRow` for Design gallery, `Icons.palette_outlined`, pushing
  `/design_gallery`
- a `GWSelectRow` for Token probe, `Icons.science_outlined`, pushing
  `/dev/token-probe`
- an Appearance row

Both dev routes are already outside the shell (`router.dart:207` and `201`), so
push them plainly with no origin query value - they are not destinations that
need a labelled way back.

**Appearance has exactly two acceptable shapes and a third is forbidden.** Open
`dev_tools_bubble.dart:1219` first. If the control it builds there is already a
separate widget, mount that widget as the row's `trailing`. If it is inline and
private to the bubble, render a `GWSelectRow` whose `subtitle` is the current
`GWAppearance.instance.value` name and whose `onTap` advances the mode through
`GWAppearance.setMode`. Do NOT hand-roll a new segmented control, and do NOT
touch `dev_tools_bubble.dart`.

**(b) `lib/navigation/router.dart` - the `/menu` route.**

Add a top-level `GoRoute` for `/menu` as a SIBLING of the `ShellRoute` at line
213, not a child of it. Place it immediately before the `ShellRoute` so the
adjacency is visible in a diff.

    GoRoute(
      path: '/menu',
      builder: (_, state) =>
          MenuScreen(originLabel: state.uri.queryParameters['from']),
    ),

Its comment must state the four things a future reader will otherwise undo,
because moving this route inside the shell is a silent one-line regression of
every one of them: it is outside the `ShellRoute` deliberately; that placement is
what removes the bottom bar and the header; on iOS the resulting `MaterialPage`
takes the default `CupertinoPageTransitionsBuilder`, which is the right-to-left
slide Jakub asked for, with no `pageBuilder` here or anywhere in this file; and
the origin arrives as a query value read HERE rather than inside the screen,
because an imperative push does not move `currentConfiguration.uri`, which
`global_swap_fab_host.dart:133-143` already records the cost of.

Point it at the two existing outside-the-shell comments on `/assets` (228-231)
and `/token-info` (327-332), which describe this same behaviour as the defect
they were fixing in the other direction.

**(c) `lib/components/overlay/mobile_header.dart` - retarget the hamburger.**

`HeaderMenuButton.onPressed` currently reads `() => MoreSheet.show(context)` at
line 522. That is the ONE line that changes. Everything sketch 183 scheme F
pinned stays untouched: no container, `Icons.menu` at 18, `kHeaderControlSize`
box, `padding: EdgeInsets.zero`, the tight `constraints`, the `shrinkWrap`
`tapTargetSize`, the `tooltip`, and the position in `title` beside `WalletPill`.

It becomes a push to `/menu` carrying the current destination's label as the
origin, so the menu's own back link can name where it will return to:

    final path = GoRouterState.of(context).uri.path;
    final origin = allDestinations
        .where((d) => path.startsWith(d.path))
        .firstOrNull
        ?.label
        .toUpperCase();
    context.push(
      origin == null ? '/menu' : '/menu?from=$origin',
    );

`push`, never `go` - `go` replaces the match list and destroys the route D-02
requires the menu to pop back to. Say that in the comment.

Reading the location here is safe in a way it is not inside a pushed screen: this
button is mounted in the shell's own `AppBar`, so it is reading the DECLARATIVE
location it currently sits on, which is exactly what
`nav_destinations.dart`'s own `currentIndex` reads for the bar.

A path that is not a destination - `/buy`, `/token-info` - yields no origin and
the menu falls back to `'BACK'`. That is the documented `/buy` behaviour at
`router.dart:311`, reused rather than reinvented.

Import `nav_destinations.dart` directly. `more_sheet.dart` was supplying that
import transitively and is about to be deleted. No cycle: S7's own import diagram
puts `nav_destinations.dart` at the bottom with no project imports at all.

Rewrite `HeaderMenuButton`'s class doc so the F treatment split survives - the
wallet holds a value so it gets the chip recipe at 3.30:1, the hamburger holds
nothing so it gets a bare glyph at 19.29:1 - and add that its destination is now
a full-screen page outside the shell rather than a sheet.

**(d) Delete `lib/components/overlay/more_sheet.dart`.**

After (c) it has zero callers. Check both couplings named in finding 8 FIRST:
grep `test/` for `MoreSheet` and for `more_sheet`, and if S7's
`mobile_nav_destinations_test.dart` mounts `MoreSheetBody`, repoint it at
`MenuScreen` in Task 3 rather than deleting the assertion - the union it proves
still holds, because the menu derives from the same `moreDestinations`.

Do not preserve the `Accounts` row. Finding 9: sketch 184 deletes it because the
wallet chip sits 12px from the hamburger and both would open the same drawer.

`moreDestinations` STAYS in `nav_destinations.dart` and becomes the menu's
source. Update its doc comment: it now feeds a page, not a sheet.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -5 && flutter test test/menu/menu_screen_test.dart</automated>
  </verify>
  <done>
`/menu` resolves to a chromeless `MenuScreen`; the hamburger pushes it with an
origin; the menu's rows are derived, grouped, card-less and push their paths with
`from=MENU`; `more_sheet.dart` no longer exists; `flutter analyze` is clean.
  </done>
</task>

<task type="auto" tdd="true">
  <name>Task 2: the way back from a child, on the four destinations, without a second back control</name>
  <files>lib/dashboard/chart/markets_screen.dart, lib/settings/settings_screen.dart, lib/logs/submit_logs_screen.dart, lib/web/web_view_screen.dart, lib/web/web_view_mobile.dart, lib/navigation/router.dart</files>
  <behavior>
    - Reached from the menu, each of Markets, Web, Settings and Feedback renders one back link reading MENU.
    - Reached any other way, each renders no back link at all and is otherwise unchanged.
    - Each keeps its bottom navigation bar and its normal top navigation.
    - No screen renders two back controls.
    - Tapping the back link returns to the menu.
  </behavior>
  <action>
D-03 is the governing decision here and it makes most of this task nothing: the
four screens are ALREADY inside the `ShellRoute` (`/web` 257, `/markets` 268,
`/logs` 317, `/settings` 326), so they already keep their bar and their top
navigation when pushed. **No route moves and no chrome is added.** Finding 3 is
the survey; confirm it still reads true before editing.

**(a) `router.dart` - thread the origin into four builders.**

Each of the four gains `originLabel: state.uri.queryParameters['from']`. A query
value, never `extra`: `/logs` binds `extra` to a `String?` prefill at 323 and
`/web` binds it to `WebViewExtras` at 259-261, so `extra` is occupied on half of
them. Finding 4.

`/markets` and `/settings` are `const` builders today and stop being const. That
is the whole cost.

Leave `/logs`'s existing `state.extra as String?` prefill exactly as it is. The
two mechanisms are independent and both must keep working - the job flow's "Get
help" button at `job_steps.dart:806` passes a message and no origin.

**(b) Each screen gains a nullable `String originLabel` and renders the link only
when it is non-null.**

The shape is identical on all four:

    if (originLabel != null)
      GWBackLink(
        label: originLabel!,
        onTap: () =>
            context.canPop() ? context.pop() : context.go('/menu'),
      ),

**Absent an origin, the widget tree is byte-identical to today.** That is what
makes the label incapable of lying: Markets reached from
`dashboard_markets.dart:106`, `/logs` reached from the job drawer and `/web`
reached from an in-app link all render exactly what they render now. This is the
repo's own rule at `router.dart:308-311` - the caller states its origin and it is
never sniffed from the nav stack.

Placement, per screen:

- **Markets** (`markets_screen.dart:103-107`): directly above the
  `Padding(horizontal: 12)` that wraps `GWPageHeader(title: "Markets")`, as a
  sibling in the same `Column`, with NO horizontal padding of its own -
  `GWBackLink` carries its own 12 and that is what puts it on the same x-axis as
  the header. Same arrangement `assets_screen.dart:341-352` already ships.
- **Feedback** (`submit_logs_screen.dart:462-466`): the same, above its
  `GWPageHeader`. Preserve the "No AppBar" comment at 426 - it is still true and
  still the reason.
- **Settings** (`settings_screen.dart:170-183`): as the first child of the
  `GWScreen`'s `Column`, above `_buildLogSection()`. **Do not restructure the
  `AppBar`** - D-03 says it keeps its normal top navigation.
- **Web**: `WebViewScreen` (`web_view_screen.dart`) passes `originLabel` through
  to `WebViewMobile` alongside the existing `url` and `includeBackButton`.
  `WebViewMobile` renders the link as the FIRST child of the `Column` inside its
  `SafeArea` at 356-361, above `_buildTabStrip()`.

**Two Web-specific rules, both from finding 3.** `WebViewScreen.includeBackButton`
is the BROWSER's control, already set true by `web_utils.dart:19` for link
launches - do NOT reuse it for the route back and do not change its default.
And `web_view_mobile.dart:596` already renders an `Icons.arrow_back` inside
`_omniboxNavButton`, gated on `canGoBack()`: that is browser history, this is the
route stack, and the two are different. They are separable because the route link
is labelled text at the top edge and the browser control is an icon in the
omnibox row below it. Say so in a comment at the insertion point, and note that
this is the checkpoint's second question.

**(c) Settings' implied leading - verify, then act on what you find.**

`settings_screen.dart:171` mounts `AppBar(title: const Text('Settings'))` with
`automaticallyImplyLeading` left at its default of true. Finding 3 reasons that
no arrow should appear, because `/settings` sits in the shell's NESTED navigator
and that navigator still holds one page even when the root navigator has pushed
one. **Confirm it on device or in a widget test rather than trusting the
reasoning.**

If no arrow appears: change nothing beyond (b).

If an arrow DOES appear: set `automaticallyImplyLeading: false` on that one
`AppBar`. Do NOT keep both - a bare arrow beside a labelled "‹ MENU" link is the
double-back the brief warned about, and D-04 asks for the labelled one.

Record which branch happened in the SUMMARY either way. A verification that came
out clean is a result, not a non-event.
  </action>
  <verify>
    <automated>flutter analyze 2>&1 | tail -5 && flutter test test/menu/</automated>
  </verify>
  <done>
All four destinations render one back link reading MENU when reached from the
menu and none when reached otherwise; all four keep their bar and top navigation;
no screen renders two back controls; the Settings branch is recorded.
  </done>
</task>

<task type="auto">
  <name>Task 3: pin the derivation, the chrome absence and the origin gate</name>
  <files>test/menu/menu_screen_test.dart, test/components/mobile_nav_destinations_test.dart</files>
  <action>
Nothing asserted the More sheet's contents before S7, and S7's own test file is
the first thing that does. These assertions extend that rather than duplicating
it.

**In `test/menu/menu_screen_test.dart`:**

1. **Set equality, not containment.** The set of row titles `MenuScreen` renders
   equals the set of `moreDestinations` labels. Equality is what catches a row
   the grouping dropped, and containment is what would miss it.
2. **The catch-all holds.** This is the assertion finding 7 exists for. Drive
   `MenuScreen` with a `moreDestinations` member whose path no group in
   `_kMenuGroups` claims and assert the row still renders. Expose the group
   walk as a testable pure function rather than adding a test-only constructor
   parameter to the widget, so the seam is a function boundary rather than a
   hole in the widget's API.
3. **No card.** Assert zero `GWCard` descendants in the rendered tree. Finding 6:
   a card here is a 1.01:1 fill on a 1.36:1 edge, and this is the assertion that
   stops one being added back by someone tidying.
4. **No shell chrome.** Assert `MenuScreen` renders no `MobileHeader` and no
   `BottomNavigationBar`, and that `/menu` is not a descendant of the
   `ShellRoute`. Prefer a source-level scan of `router.dart` for the second one:
   locate the `/menu` `GoRoute` and assert its offset is OUTSIDE the
   `ShellRoute`'s `routes:` list. A widget test cannot easily prove absence of a
   parent, and a source scan reddens the suite the moment someone moves the route
   inside the shell - which is the single regression this whole task is exposed
   to.
5. **The dev gate.** With `kShowDevTools` false, no Developer kicker renders.
   `kShowDevTools` is a `bool.fromEnvironment` const, so drive this by asserting
   the gate expression's inputs rather than trying to mutate it at run time; if
   that is not expressible, assert the default-build case only and say so in a
   comment rather than writing an assertion that cannot fail.
6. **The origin gate, both directions.** `MenuScreen(originLabel: null)` renders
   a back link reading `BACK`; `MenuScreen(originLabel: 'HOME')` renders one
   reading `HOME`. Then the child half: pump each of the four destinations with
   `originLabel: null` and assert **zero** `GWBackLink` descendants, and with
   `originLabel: 'MENU'` and assert exactly **one**. The zero-case is the
   assertion that proves the label cannot lie.
7. **Exactly one back control per child.** Assert the count is one, never two, on
   each of the four. This is the one the brief called the central question.

**In `test/components/mobile_nav_destinations_test.dart`:** if S7's version
mounts `MoreSheetBody`, repoint it at `MenuScreen`. The union assertion it makes
- that the bar's paths plus the menu's paths cover every visible member of
`allDestinations` except `/swap` - still holds and is now the property that keeps
`/menu` honest. Do not weaken it to containment while repointing it.

Check `nav_destinations.dart`'s `navIndexForLocation` still reads `uri.path`
rather than `uri.toString()`. Task 2 appends `?from=MENU` to four locations, and
a path comparison against the full URI would break the bar's active-tab
highlight on exactly those four. Add an assertion that a location carrying a
query value still resolves to the same index as the bare path.
  </action>
  <verify>
    <automated>flutter test test/menu/ test/components/mobile_nav_destinations_test.dart</automated>
  </verify>
  <done>
The derivation, the catch-all, the absent chrome, the absent card, the origin
gate in both directions and the single-back-control rule are all asserted; the
query value does not disturb the bar's index; the suite is green.
  </done>
</task>

<task type="checkpoint:human-verify" gate="blocking">
  <what-built>
Sketch 184 variant C as a full-screen `/menu` route outside the shell, reached
from the S7 hamburger, with a back link on the four destinations that only
appears when it was told where it came from.
  </what-built>
  <how-to-verify>
Run on the iPhone, dark mode:

    flutter run -d <iphone> --dart-define=GW_DEV_TOOLS=true

1. **The slide (finding 1).** From Home, tap the hamburger. The menu must come in
   from the RIGHT. This is the one thing derived from a Flutter default rather
   than observed - if it fades or jumps, say so, and the fix is a
   `CustomTransitionPage` on this route alone.
2. **The chrome is gone.** No bottom bar, no GNUS.AI header. The page should be
   the only surface in the app that looks like this.
3. **Variant C reads as grouped.** EXPLORE over Markets and Web, APP over
   Settings, SUPPORT over Feedback, DEVELOPER at the bottom. Nothing boxed. The
   question worth your eye: two of the four groups hold ONE row. The sketch
   argued a kicker over one row is a label and costs nothing while a box over one
   row is an empty container. Does that hold on the device?
4. **Back from the menu.** The top-left link should read where you came from -
   "‹ HOME" from the dashboard, "‹ ACTIVITY" from Activity. Tap it and land back
   there. From a non-destination such as a coin page it reads "‹ BACK".
5. **A child keeps everything (D-03).** Open Settings from the menu. Bottom bar
   present, its own Settings top bar present, and ONE back control reading
   "‹ MENU". If you can see two, that is the defect this task was most exposed
   to. Same for Markets and Feedback.
6. **The label cannot lie.** Reach Markets from the dashboard Markets panel's
   "View all" instead. There must be NO back link at all - the page as it is
   today.
7. **Web, and this is the honest cost (finding 3).** Open Web from the menu. It
   now carries a "‹ MENU" link at the top AND the browser's own back arrow in the
   omnibox below. Two backs meaning two different things on one screen. Acceptable
   or not?
8. **The Accounts row is gone (finding 9).** The menu has four rows, not five.
   The wallet chip beside the hamburger is the way to the accounts drawer.

Open questions carried up, none of them blocking:

- **Appearance.** Its logic ships and persists, and `gw_appearance.dart:12`
  documents a Preferences sheet that was never built. It is in DEVELOPER here.
  Promote it to a user-facing row?
- **The word "Settings"** labels a screen of spdlog levels, PubSub ports and CRDT
  backup intervals. Under the dev flag the menu holds two developer groups, one
  called Settings.
- **The sheet is now unreachable code that was deleted.** If the page turns out
  to be worse than the sheet, variant E is the fallback and it is a deletion, not
  a build.
  </how-to-verify>
  <resume-signal>Type "approved" or describe what is wrong</resume-signal>
</task>

</tasks>

<threat_model>
## Trust Boundaries

| Boundary | Description |
| --- | --- |
| none crossed | This task adds one route, one screen and a conditional link. No network call, no persistence, no user input, no package install. |

## STRIDE Threat Register

| Threat ID | Category | Component | Severity | Disposition | Mitigation Plan |
| --- | --- | --- | --- | --- | --- |
| T-menu-01 | Information disclosure | DEVELOPER group | medium | mitigate | Gate on `kDebugMode && kShowDevTools`, both, per `dev_flags.dart`'s explicit instruction. `kShowDevTools` alone can be set by a define in a release build. Task 3 assertion 5 pins the default-build case. |
| T-menu-02 | Tampering | `/menu?from=` query value | low | mitigate | The value is rendered as text in a `GWBackLink` label and never used as a route target. Navigation is `context.pop()` with a fixed `/menu` fallback, so a crafted value cannot redirect anyone. It is displayed, not dispatched. |
| T-menu-SC | Tampering | package installs | low | accept | This task installs nothing. No `pubspec.yaml` change, no new dependency, and sketch 184 variant C needs zero new components. |
</threat_model>

<verification>
- `flutter analyze` clean.
- `flutter test test/menu/ test/components/` green.
- `grep -n "path: '/menu'" lib/navigation/router.dart` returns a line whose
  offset is outside the `ShellRoute`'s `routes:` list.
- `test ! -f lib/components/overlay/more_sheet.dart`.
- `grep -rn "MoreSheet" lib test` returns nothing.
- `grep -c "context.go('/menu')" lib/components/overlay/mobile_header.dart`
  returns 0 - the hamburger pushes, it does not go.
- No em dash in any line this task added. Match it by codepoint so this check
  does not itself contain the character it forbids:
  `git diff -U0 | grep '^+' | grep -cP '\x{2014}'` returns 0.
</verification>

<success_criteria>
- The hamburger opens a full-screen `/menu` that slides in from the right, with
  no bottom bar and no header (D-01, D-05).
- The menu's back returns to the route the user came from (D-02).
- The four destinations keep their bar and their top navigation (D-03) and read
  "‹ MENU" when reached from the menu (D-04).
- A destination reached any other way renders no back link and is otherwise
  unchanged.
- The menu's rows derive from `moreDestinations`, and an unclaimed member still
  renders.
- Zero new components. Zero commits.
</success_criteria>

<output>
Create `.planning/quick/20260807-menu-page/SUMMARY.md` when done. It must record:
the Settings implied-leading branch that actually happened, the Appearance shape
that was used, whether the iOS slide was observed or needed a
`CustomTransitionPage`, and Jakub's answer on the Web double-back.
</output>
