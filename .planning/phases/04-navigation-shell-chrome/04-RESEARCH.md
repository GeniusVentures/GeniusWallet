# Phase 4: Navigation shell & chrome - Research

**Researched:** 2026-07-17
**Domain:** Flutter theme reconciliation, `go_router` `ShellRoute` nav-chrome re-skin, appearance-reactive `MaterialApp` wiring
**Confidence:** HIGH (every claim below is grounded in a direct read of develop's code, the reference worktree's code, or the git history of the carried fix commit — not training-data assumption)

<user_constraints>
## User Constraints (from CONTEXT.md)

### Locked Decisions

**theme.dart sequencing**
- **D-01:** Plan 04-01 is theme-only. Its entire scope is wiring the appearance-aware `theme.dart`
  and wrapping `MaterialApp` in a `ValueListenableBuilder<GWAppearanceMode>` (develop currently
  applies `theme: getThemeData()` at `main.dart:294` with NO `ValueListenableBuilder`, so the theme
  never rebuilds on toggle). No shell or screen re-skin in 04-01.
- **D-02:** After 04-01, re-walk the gallery (`/design_gallery`, both modes) and derive the
  dark-only component COUNT that Phase 3 recorded as NOT DERIVABLE. That count and this re-walk are
  the gate before any shell/screen re-skin begins.

**Default appearance**
- **D-03:** First launch follows the OS light/dark setting. The in-app toggle (`GWAppearance`)
  overrides thereafter and persists (Hive-backed). Light mode is a shipping surface from first
  launch — any light-mode BUG must be FIXED before Phase 4 closes; it cannot be deferred. Deliberate
  dark-only DESIGN choices remain acceptable.

**Phase 3 loose ends (resolved at the 04-01 re-walk)**
- **D-04:** Split Phase 3's carried findings by type at the re-walk: BUGS → fix in Phase 4 (theme
  confound residue: token-row/wallet-card/empty-error text, button font, icons; `Screen wrappers`
  blank in dark mode — unexplained, needs a real repro; disabled checkbox invisible in dark — root
  cause unconfirmed). DESIGN CHOICES → user decides at the re-walk (canvas grain, mesh blobs,
  `GWSwitch` disabled==off, `GWSwitch` off-thumb near-black in light — all byte-identical Alex ports).
- **D-05:** The 04-01 re-walk is when the light-mode grain question gets a real answer.

**Wallet drawer UX (criterion 4)**
- **D-06:** Delete uses a confirmation dialog (destructive). CONDITIONAL on whether develop already
  confirms wallet deletion. **Resolved by this research (see §4 below): develop ALREADY confirms via
  an `AlertDialog` in `account_dropdown_selector.dart:106-126`. This is a pure re-skin. The
  "sanctioned exception" clause does NOT activate — record this in the SUMMARY so it isn't mistaken
  for the exception firing.**
- **D-07:** All other criterion-4 behaviors (rename, keep-at-least-one guard, deleted-selected
  re-selects another, live drawer row updates, "Network Changed" toast) are develop's existing
  behaviors — preserve and re-skin, do not redesign.

### Claude's Discretion
- HOW `theme.dart` is reconciled (line-by-line vs adopt-Alex's-wholesale) is a planner/executor call,
  bounded by "take Alex's visual." See §1 below for a line-by-line hazard enumeration to inform that
  call.
- Desktop rail vs mobile bottom-nav breakpoint logic follows develop's existing
  `GeniusBreakpoints.useDesktopOverlay` / `isMobileApp` — no new breakpoint.

### Deferred Ideas (OUT OF SCOPE)
- Wiring `tool/verify_additive_boundary.sh` into CI — not Phase 4 scope.
- The two missing gallery sections (dropdowns, `wallet_type_icon`) from Phase 3 criterion 6 Part B —
  fold into whichever Phase 4 plan touches the gallery, or a Phase 3 follow-up. Not a blocker.
- Folded todo: design-system-has-no-light-mode-treatment — folded into D-04/D-05.
</user_constraints>

<phase_requirements>
## Phase Requirements

| ID | Description | Research Support |
|----|-------------|------------------|
| NAV-01 | App shell wears the redesign skin (desktop rail + mobile bottom nav) on develop's `go_router` config, every existing route reachable | §2 (nav synthesis), §2.1 (Gen A/B Cubit trap), §2.2 (destination set), confirms "rail" = existing top-bar pattern, not a literal `NavigationRail` widget — see §2.3 |
| NAV-02 | Shell survives startup/navigation with no runtime exceptions, including the `!_dirty` crash (`7a63b4f`) | §3 — `7a63b4f`'s target file (`GlobalSwapFabHost`) does not exist on this branch yet; this is a **build-fresh**, not a **patch-existing**, task. See §3 for the concrete hazard and the WIRE-02 coupling risk |
| BEH-02 | 3 verified fixes ported with their components; `7a63b4f` is the last, closing here | §3 — the fix must be written into the file from its first commit, not ported-then-patched |
| GAP-02 | Settings screen re-skinned in place, structure/rows unchanged | §4.1 (component mapping verified against the live file), §1 (dividerTheme drop affects `Divider()` calls in this file) |
| GAP-03 | SDK account manager re-skinned in place, structure unchanged | §4.2 (verified against the live file: `MenuAnchor` absent here, but `OutlinedButton.icon` footer actions present — `outlinedButtonTheme` drop is relevant) |
</phase_requirements>

## Summary

This phase's risk is concentrated in one file (`lib/theme/theme.dart`) and one architectural
mismatch (two nav-shell "generations" on Alex's branch, neither of which is directly portable).
Both were investigated by reading the actual `develop` and reference-worktree source, not by
re-deriving what the already-approved `04-UI-SPEC.md` says.

**Three new, load-bearing findings this research adds beyond the UI-SPEC:**

1. **`gw_appearance.dart`'s `load()` does not read OS brightness at all.** It defaults to
   `GWAppearanceMode.dark` unconditionally and only overrides from a *persisted* Hive value. D-03
   ("first launch follows the OS setting") is currently **false** in code — this is a required
   code change for 04-01, not just a wiring exercise. See §3.4.
2. **`GlobalSwapFabHost` — the file `7a63b4f` patches — does not exist anywhere in this repo yet.**
   It is one of the 9 excluded nav-shell files from Phase 3. Carrying BEH-02 into Phase 4 means
   *introducing this file for the first time*, and Alex's original version couples the Swap FAB to
   `GWAiFab` (`lib/ai/`, WIRE-02, explicitly out of scope). Porting it verbatim would both
   reintroduce a historical crash (if the `_ready` guard isn't included from the first commit) and
   violate WIRE-02. See §3.1-§3.3 — this is flagged as an **open question for the planner**, not
   silently resolved, because it is also arguably new navigational capability, not a re-skin.
3. **Both of Alex's nav-shell "generations" depend on `NavigationOverlayCubit`/`NavigationOverlayState`**
   — a BLoC-based navigation-selection architecture that does not exist on develop and is not
   mentioned in `04-UI-SPEC.md` §2.2's Gen A/B comparison. Neither generation's *widget* is portable
   without either porting this Cubit (new architecture — arguably restructuring) or discarding it and
   wiring only the visual layer onto develop's existing `GoRouterState`-derived `_currentIndex()`
   mechanism. See §2.1.

**Primary recommendation:** Treat `theme.dart` as a line-by-line reconciliation (not a wholesale
adopt-then-patch), because Alex's file silently drops six `ThemeData` sections develop's code
depends on (`floatingLabelBehavior` — already known; plus `toggleButtonsTheme`, `filledButtonTheme`,
`outlinedButtonTheme`, `dialogTheme.actionsPadding`, `menuTheme`, `dividerTheme` — newly found here).
For the nav shell, extract only Generation B's *visual* pattern (colors/typography/border) and wire
it to develop's own destination-derivation function — never adopt either generation's Cubit or
either generation's file wholesale. Resolve `GlobalSwapFabHost`'s scope with the user before planning
it in, since it is not covered by any of the phase's 6 success criteria as currently written.

---

## Architectural Responsibility Map

| Capability | Primary Tier | Secondary Tier | Rationale |
|------------|-------------|----------------|-----------|
| Theme/appearance resolution (`getThemeData()`, `GWAppearance`) | Frontend Client (Flutter widget tree) | — | Pure client-side `ThemeData` computation + a `ValueNotifier` singleton; no server/API involvement |
| Nav shell chrome (desktop top bar / mobile bottom nav) | Frontend Client | — | `ShellRoute` builder in `go_router`, entirely client-rendered |
| Wallet rename/delete/re-select | Frontend Client (dialog + `AlertDialog`) | Local Storage (Hive `walletBoxName`) | UI dispatches `RenameWallet`/`DeleteWallet` to `AppBloc`; persistence is local Hive, not a remote API |
| SDK account management | Frontend Client (drawer) | Native SDK (FFI, `genius_api`) | The drawer is chrome; the actual account list/mutation is owned by the native Genius SDK via FFI — Phase 4 only re-skins the drawer, never the FFI calls |
| Settings (log/network/CRDT config) | Frontend Client | Local config (develop's existing persistence, unchanged) | Re-skin only; config read/write logic is untouched |
| Build-time exception recovery | Frontend Client (`ErrorWidget.builder`) | — | Framework-level error boundary, no backend involvement |
| Window-close SDK shutdown | Platform integration (`window_manager` plugin) | Native SDK (`geniusApi.shutdownSDK()`) | Not a UI capability at all — verify-only this phase, no re-skin surface |

No capability in this phase touches an API/backend tier in a way this phase's own work can affect —
every re-skin target is client-only chrome around already-correct develop logic. This is exactly
why "re-skin, never restructure" is enforceable here: nothing in this phase's file set has a second
tier that could silently absorb a structural change.

---

## Standard Stack

This phase introduces **no new package dependencies**. It is a reconciliation of existing files
(`theme.dart`, `main.dart`, `router.dart`, `responsive_overlay.dart`, `account_dropdown_selector.dart`,
`sdk_account_manager.dart`, `settings_screen.dart`) plus the first real consumption of Phase 3's
already-landed `gw_*` component library. `pubspec.yaml` should show zero diff from this phase.

**Verification:** confirmed no new imports appear in either `04-UI-SPEC.md`'s component-mapping
tables or in this research's own reading of the reference files — every widget referenced
(`GWCard`, `GWButton`, `GWDialog`, `GWTextField`, `GWSelect`, `GWSwitch`, `GWIcon`, `BottomDrawer`,
`GWErrorState`) already exists in `lib/components/` from Phase 3.

## Package Legitimacy Audit

**Not applicable.** This phase installs zero external packages. `pubspec.yaml`/`pubspec.lock` should
show no diff attributable to this phase's own commits (Phase 2's three token-file appends are the
only pre-existing `pubspec.yaml`-adjacent changes on this branch, per `03-VERIFICATION.md`'s own
reconciliation — not this phase's).

---

## Architecture Patterns

### §1. `theme.dart` reconciliation — the concrete diff hazards

Read directly: `lib/theme/theme.dart` (develop, 276 lines) vs.
`GNUS-compare/GeniusWallet-3514/lib/theme/theme.dart` (Alex, 309 lines). `[VERIFIED: direct file read, both sides]`

**What Alex's version correctly adds (must land):**
- `getThemeData()` reads `GWAppearance.isLight` and builds a light **and** dark `ColorScheme`
  (develop's is a single hardcoded `const ColorScheme.dark(...)`).
- `brightness: isLight ? Brightness.light : Brightness.dark` (develop: hardcoded `Brightness.dark`).
- `textTheme: GeniusWalletTypography.toMaterialTextTheme()` (develop: no `textTheme:` key at all).
- `scaffoldBackgroundColor: GeniusWalletColors.surfaceBase` — appearance-aware (develop:
  `colorScheme.surfaceDim`, a legacy hardcoded-dark-family token that never flips).
- `onPrimary: GeniusWalletColors.textOnBrand` in **both** light and dark `ColorScheme` — a
  deliberate WCAG AA fix (inline comment: "white on the bright brand fill failed WCAG AA for
  Material widgets in dark mode"). Carry forward exactly; never substitute `Colors.white`/`black`.

**Six `ThemeData` sections develop sets that Alex's file drops entirely** (not overridden — absent):
`[VERIFIED: direct file read, both sides — grep-confirmed absent from Alex's 309 lines]`

| Dropped section | develop's value | Consumer(s) found in this repo | Risk if silently dropped |
|---|---|---|---|
| `inputDecorationTheme.floatingLabelBehavior` | `FloatingLabelBehavior.always` | Every `TextField`/`TextFormField` app-wide | **Already known (finding 36) — binding rule already in UI-SPEC §1.2. Confirmed again here by direct read: Alex's `inputDecorationTheme` (lines 168-181) has no such key.** |
| `toggleButtonsTheme` | `borderRadius: circular(borderRadiusButton)` | `ToggleButtons(` — **used in `lib/components/wallet_overview.dart` and `lib/components/wallets_overview.g.dart`** (GAP-06, Phase 5 scope) `[VERIFIED: grep]` | Not this phase's screen, but the *theme* change lands this phase — Phase 5 will inherit un-radiused (square) toggle buttons unless this theme key is explicitly carried or Phase 5 re-adds it. Record as a note for Phase 5, do not silently drop. |
| `filledButtonTheme` | explicit `textStyle`/padding | `FilledButton`/`FilledButton.icon` — **used 13 places**, including `lib/account/account_dropdown_selector.dart`'s own drawer footer "Add Wallet" button (this phase's own file, §4) `[VERIFIED: grep]` | The drawer's `FilledButton.icon` already sets its own `style: FilledButton.styleFrom(textStyle:, iconSize:)` inline, so it is **not** fully theme-dependent — but its `padding`/`shape`/`backgroundColor` do fall back to Material 3 defaults once `filledButtonTheme` is gone. Low-severity but should be a deliberate choice, not an accident. |
| `outlinedButtonTheme` | explicit padding/textStyle/`foregroundColor: white` | `OutlinedButton`/`OutlinedButton.icon` — **used 19 places**, including `sdk_account_manager.dart`'s own two footer buttons ("Add with mnemonic" / "Add with private key" — this phase's own file, §4.2) `[VERIFIED: grep + direct read]` | Same shape as `filledButtonTheme` above — these two specific buttons are in a file this phase re-skins, so falling back to Material 3 defaults changes their padding/foreground color unless the token-mapping table (§3.2 of `04-UI-SPEC.md`) explicitly restyles them, which it does not currently name these two specific footer buttons. |
| `dialogTheme` (`actionsPadding: EdgeInsets.all(12)`) | — | Bare `AlertDialog(` — **used in `account_dropdown_selector.dart`'s rename (line 56) and delete (line 108) dialogs** — this phase's own D-06 target `[VERIFIED: direct read]` | **Resolved by this research: irrelevant if these two dialogs are converted to `GWDialog` (§4, recommended) — `GWDialog` builds on a bare `Dialog`, not `AlertDialog`, and supplies its own `Container`/`Wrap` for actions, so it never reads `DialogThemeData`.** Only matters if the executor falls back to a token-styled `AlertDialog` instead of `GWDialog` — then the actions row loses develop's explicit 12px padding and falls back to Material 3's own dialog action padding. |
| `menuTheme` | `MenuStyle(shape: RoundedRectangleBorder(radius: borderRadiusCard))` | `MenuAnchor`/`MenuItemButton` — **used in `account_dropdown_selector.dart`'s per-wallet "..." menu (copy/rename/delete) and `sdk_account_manager.dart`** `[VERIFIED: grep + direct read]` | Not resolved by switching to `GWDialog` (the popup is a `MenuAnchor`, not a dialog). Once `menuTheme` is gone, the account-drawer row's context menu falls back to Material 3's default menu container styling (`_MenuDefaultsM3`) — visually acceptable but un-branded (no `radiusCard`). §4.1's binding rule ("token-styled equivalents") should explicitly cover the `MenuAnchor`'s own `style:`/`menuStyle:` parameter, not just its `MenuItemButton` children. |
| `dividerTheme` | `color: colorScheme.surfaceContainerHighest` | `Divider(` — **used in `lib/settings/settings_screen.dart`** (this phase's GAP-02 target, §4.1) plus 6 other files `[VERIFIED: grep]` | Material 3's own default `Divider` color resolves from `colorScheme.outlineVariant` when no `dividerTheme.color` is set — a reasonable fallback, not a broken one, but worth a deliberate check during the GAP-02 re-skin rather than assuming Divider "just works." |

**Two additional deltas found, not collisions with develop-only code but worth flagging:**
- `bottomNavigationBarTheme.selectedIconTheme`/`unselectedIconTheme` size: develop = **30**, Alex =
  **35**. A real, small visual change — note it as a deliberate adopt (Alex's is the redesign target)
  rather than an accidental drift.
- `navigationRailTheme.useIndicator: false` — present in Alex's version, absent from develop's. Not
  observably consequential given neither codebase uses a literal `NavigationRail` widget (see §2.3),
  but carry it forward since it's part of the theme object either way.

**`toMaterialTextTheme()` maps only 10 of Material's 15 `TextTheme` slots** (`displayLarge/Medium`,
`headlineLarge/Medium`, `titleLarge/Medium`, `bodyLarge/Medium/Small`, `labelMedium` — missing
`displaySmall`, `headlineSmall`, `titleSmall`, `labelLarge`, `labelSmall`). `[VERIFIED: direct read, genius_wallet_typography.dart:133-144]`
Flutter's `ThemeData` merges a partial `textTheme` onto its own Material-3 default, so the 5 missing
slots don't go blank — they render in the *default* Roboto family, color-corrected to the active
`colorScheme` by the merge, but not in Inter and not at `GeniusWalletTypography`'s sizes. `[ASSUMED — Flutter framework merge behavior, not re-verified via tool this session]`
Explicit `ButtonStyle.textStyle` overrides in `elevatedButtonTheme`/`textButtonTheme` cover buttons
regardless, so this is a low-severity residual risk, not a blocker — flag it as something to watch
for during the D-02 re-walk if any text looks like the wrong font.

### §2. The nav-shell synthesis — concrete architecture trap

`04-UI-SPEC.md` §2.2 already documents that Alex's branch carries two nav-shell "generations" and
prescribes taking Generation B's token vocabulary applied to develop's 8-destination set. This
research adds one load-bearing detail the UI-SPEC did not surface:

#### §2.1 Both generations depend on a Cubit that does not exist on develop

`[VERIFIED: direct read of both generations' source]`

- **Generation A** (`desktop_tab_bar.dart`, `destinations.dart`, `genius_destination.dart`): reads
  selection via `context.watch<NavigationOverlayCubit>().state.selectedScreen`, dispatches taps via
  `context.read<NavigationOverlayCubit>().navigationTapped(screen)`.
- **Generation B** (`gw_bottom_nav.dart`): identical pattern —
  `BlocBuilder<NavigationOverlayCubit, NavigationOverlayState>`, `state.selectedScreen`,
  `context.read<NavigationOverlayCubit>().navigationTapped(item.screen)`.

`NavigationOverlayCubit`/`NavigationOverlayState` live at
`lib/bloc/overlay/navigation_overlay_cubit.dart` / `navigation_overlay_state.dart` on Alex's branch
— **files that do not exist anywhere in today's `develop`/`ui-redesign-port` tree.** Porting either
generation's actual widget file wholesale means also porting a parallel BLoC-based navigation-state
architecture that replaces develop's own mechanism
(`GoRouterState.of(context).uri.path` → `_currentIndex(context)` in
`responsive_overlay.dart`, confirmed still in use on develop today). That is not a re-skin — it is a
second, competing navigation-state source, and risks divergence from `go_router`'s own notion of
the current route (exactly the class of bug `7a63b4f` was about — two systems each believing they
own "what screen is selected").

**Binding recommendation:** do not port `NavigationOverlayCubit` or either generation's file
wholesale. Extract only the *rendering* pattern (color logic, `GWDecorations.surfaceSheen` top
border, `GeniusWalletTypography.labelMd` label style, icon-selection styling) into a new/modified
widget that continues to derive its selected index from develop's own `GoRouterState`-based
`_currentIndex(context)` — exactly as `04-UI-SPEC.md` §2.2 already prescribes for the *token*
layer, extended here to explicitly also exclude the *state* layer.

#### §2.2 Destination-set and top-bar composition confirmed against live develop code

`[VERIFIED: direct read, lib/components/overlay/responsive_overlay.dart]`

- develop's `_allDestinations` (8 items: Dashboard, Transactions, Swap, Markets, News, Web
  [hidden on Linux], Feedback→`/logs`, Settings) is shared by **both** `_MobileTabBar` and
  `_DesktopTopBar` today via the same `_visibleDestinations` getter — confirming the phase's premise
  that develop already has one unified 8-destination set to re-skin (not synthesize from scratch).
- develop's `MobileOverlay` already has an `AppBar` (title "Genius Wallet") **and** a
  `bottomNavigationBar` — i.e., today's mobile shell is app-bar-plus-bottom-nav, not bottom-nav-only.
  Confirm during planning whether the redesign's `Generation B` (no app bar, only a bespoke
  `_OverlayTopBar` with 3 icons) implies dropping develop's "Genius Wallet" titled app bar on
  mobile — if so, that changes where the action-row widgets (`NetworkDropdownSelector`,
  `SDKAccountManagerButton`, `AccountDropdownSelector`, `ReownConnectButton`, dev tools) physically
  sit on mobile, which is currently inside the `AppBar.actions` `Flexible`+`SingleChildScrollView`.
  Not a hidden risk — `04-UI-SPEC.md` §2.4/§2.5 already says this action row is unchanged in
  membership/order, but the *container* it lives in (app bar vs. Gen-B's bespoke top row) is an
  open composition detail this research did not find explicitly pinned down. Flag for the plan.
- Alex's `Generation B` `MobileOverlay` wraps its **entire body** in `GWCanvasBackground` (the
  dark-gated grain texture, confirmed dark-only by design in Phase 3). If this is adopted at the
  shell level rather than per-screen, every mobile screen in the app would render on top of the
  grain (invisible in light mode per its own `if (!isLight)` gate, present in dark). This is a
  bigger, more consequential decision than a component-level re-skin choice — record it explicitly
  in the plan's SUMMARY if adopted, do not let it happen implicitly as a side effect of composing
  Gen B's file.
- Alex's `Generation B` `_OverlayTopBar` (mobile) and `Generation A`'s `DesktopTopBar` both import
  `lib/preferences/preferences_button.dart` (the currency picker, **WIRE-07, explicitly out of
  scope per REQUIREMENTS.md WIRE-02**). Neither generation's top-bar file is portable wholesale for
  this reason alone, independent of the Cubit issue above. `[VERIFIED: grep of both reference files]`

#### §2.3 "Desktop rail" is not a literal `NavigationRail` widget — in either codebase

`[VERIFIED: grep, both develop and reference worktree, zero matches for "NavigationRail("]`

Neither develop nor Alex's reference implements a literal Flutter `NavigationRail`. The desktop
treatment in both is a horizontal top bar (`_DesktopTopBar` / `DesktopTopBar`) with tab-style
destinations, not a vertical side rail. Both codebases' `theme.dart` configure a
`navigationRailTheme` that has **no live consumer** in either app. ROADMAP/REQUIREMENTS' "desktop
rail" phrasing should be read as "the desktop top-bar destination row," not literal `NavigationRail`
— building an actual side rail would be a restructuring, not a re-skin, and is not what either
reference implements.

#### §2.4 Breakpoint confirmation

`[VERIFIED: direct read, lib/utils/breakpoints.dart]` — `useDesktopOverlay` switches at `large`
(1024px), not `medium` (768px, which governs only the drawer per `04-UI-SPEC.md` §2.3/§5.1). No
new breakpoint needed; this matches the UI-SPEC's binding rule exactly.

### §3. `NAV-02`/BEH-02 — the `!_dirty` crash guard and `GlobalSwapFabHost`

`[VERIFIED: git show 7a63b4f on branch ui-redesign-3.514-develop; file existence checked on this branch]`

#### §3.1 The fixed file does not exist on this branch yet

`7a63b4f` ("fix(nav): stop GlobalSwapFabHost tripping !_dirty on startup") modifies exactly one
file: `lib/components/overlay/global_swap_fab_host.dart`. This file is **one of the 9 excluded
nav-shell files** Phase 3 deliberately did not port (`03-VERIFICATION.md`'s own excluded-file grep
pattern lists it explicitly). Confirmed absent from today's tree:
```
$ find lib -iname "*global_swap*"
(no output on ui-redesign-port; only lib/components/buttons/gw_swap_fab.dart exists — the standalone button Phase 3 ported unwired)
```
**Consequence: carrying BEH-02's `7a63b4f` into Phase 4 is not "patch an existing file" — it is
"introduce a new file for the first time, already containing the fix."** There is no risk of
forgetting to apply a patch to an untouched file; the risk is the opposite — copying Alex's
*original, pre-fix* `global_swap_fab_host.dart` (which is what a naive "port this reference file"
approach would do, since the reference worktree's checked-out state has no branch pointer back to
where `7a63b4f` landed relative to it) and reintroducing the exact historical `!_dirty` crash.

#### §3.2 The root cause, restated precisely (for whoever writes this file fresh)

`GlobalSwapFabHost` sits inside `MaterialApp.router`'s `builder`, so its `child` parameter is the
router's own `Navigator`. Mounting that child during the widget's own `build()` (inside
`ComponentElement.performRebuild`, after the dirty flag has already been cleared) causes the
router delegate to resolve the initial route and fire a change notification synchronously, which
then calls `setState()` — re-dirtying an element whose rebuild pass has already completed, tripping
Flutter's internal `assert(!_dirty)`. The existing (broken) guard only deferred `setState()` when
`SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks`, but the initial
mount runs under `attachRootWidget`, where the phase is `idle` — so the guard never fired on first
launch (only on later, mid-frame navigations). **The correct fix is structural, not timing-based:**
guard `_onRouteChanged` with an `if (!_ready) return;` early-out (mirroring `build()`'s own
`if (!_ready) return widget.child;`), so the listener is a no-op until the widget's first
post-frame callback has already flipped `_ready = true`. See §Code Examples for the exact pattern.

#### §3.3 The WIRE-02 coupling — open question for the planner

`[VERIFIED: direct read, reference worktree]` Alex's `GlobalSwapFabHost` renders **two** floating
buttons in a `Stack` over `widget.child`: `GWSwapFab` (bottom-right, pushes `/swap`) and `GWAiFab`
(bottom-left, "live AI-processing %", pushes `/submit_job`). `GWAiFab` is defined in
`lib/components/buttons/gw_ai_fab.dart`, which Phase 3 explicitly **excluded** from the component
port ("imports `lib/ai/`, WIRE-02 out of scope for this milestone" —
`03-02-SUMMARY.md`/`03-GAP-INVENTORY.md`). `gw_ai_fab.dart` does not exist in this repo.

**This means Alex's `GlobalSwapFabHost` cannot be ported verbatim under any circumstances** — it
would fail to compile (`gw_ai_fab.dart` import unresolved) even before the `!_dirty` question is
reached. The only viable path is a **stripped fork**: a new `GlobalSwapFabHost` that hosts only
`GWSwapFab` (already ported, standalone, in Phase 3 — `04-UI-SPEC.md` and `03-UI-SPEC.md` both note
this component is "self-contained — no `lib/ai/` coupling") and omits the AI FAB half entirely.

**A second, more fundamental question this research surfaces but does not resolve:** a
persistent, globally-floating Swap button reachable from every screen (including screens pushed
outside the `ShellRoute`, per the file's own doc comment) is **new navigational capability develop
does not have today.** None of Phase 4's 6 success criteria in `ROADMAP.md` mention a global swap
FAB. `04-UI-SPEC.md` (this phase's own approved design contract) does not mention
`GlobalSwapFabHost`, `GWSwapFab`'s wiring, or a floating action button anywhere in its 9 sections.
Yet `ROADMAP.md`'s Phase 4 entry explicitly lists `Carries: 7a63b4f` and `REQUIREMENTS.md`'s
traceability table maps `BEH-02` to Phase 4 as the closing phase for that fix.

**This is a genuine, unresolved tension between "re-skin never restructure" and "carry the fix
commit," not something this research should silently pick a side on.** Two readings, both
defensible:
1. **Narrow reading:** BEH-02 is satisfied by ensuring the fix *travels with the file whenever it
   eventually lands* — since no criterion requires a global swap FAB this phase, `GlobalSwapFabHost`
   is out of scope for Phase 4's actual plans, and BEH-02's Phase-4 closure is really about not
   regressing it if some other file this phase touches happens to need it (it doesn't — nothing
   currently in scope imports it).
2. **Broad reading:** the ROADMAP's "Carries" line is a deliberate instruction to introduce this
   file now, precisely because Phase 4 is "the frame every screen mounts into" and this is
   shell-level chrome — in which case it should be planned as an explicit, called-out addition (the
   same pattern as D-06's "sanctioned exception" clause), built stripped of `GWAiFab` and
   born-fixed per §3.2.

**Recommendation for the planner:** resolve this explicitly with the user before committing either
way, using the same discipline `04-UI-SPEC.md` already applied to the Gen A/B ambiguity (flag
rather than silently resolve). If reading 2 is chosen, the stripped `GlobalSwapFabHost` must (a)
never import `gw_ai_fab.dart`/`lib/ai/`, (b) include the `if (!_ready) return;` guard in
`_onRouteChanged` from its very first commit, and (c) be called out in the phase SUMMARY as new
capability explicitly authorized by BEH-02/ROADMAP, not discovered as an accidental scope-creep.

#### §3.4 `GWAppearance.load()` does not implement D-03 as written

`[VERIFIED: direct read, lib/theme/gw_appearance.dart]`

```dart
class GWAppearance extends ValueNotifier<GWAppearanceMode> {
  GWAppearance._() : super(GWAppearanceMode.dark);   // <- unconditional dark default
  ...
  void load() {
    final saved = Hive.box(preferencesBoxName).get(appearanceModeKey) as String?;
    if (saved == 'light') value = GWAppearanceMode.light;   // <- only branch that changes value
    // no `else` branch reads the OS brightness at all
  }
```

On a genuinely first launch (no persisted Hive value), `load()` is a no-op and the app stays on the
constructor's hardcoded `dark` default, regardless of the OS's actual light/dark setting. **D-03**
("first launch follows the OS light/dark setting") is not yet true in code — this is a required
code change for 04-01, distinct from (and in addition to) the `ValueListenableBuilder` wrap. See
§Code Examples for the fix shape.

### §4. The 8 findings — re-verified directly against live code (not re-derived from the findings doc)

`04-UI-SPEC.md` §4 already asserts all 8 are true on develop today; this research independently
re-read the two files that carry 6 of the 8 (`main.dart`, `account_dropdown_selector.dart`) rather
than trusting the prior document's table, and confirms it:

- **Findings 2, 11, 12** (`lib/main.dart`): `await geniusApi.loadStoredWallets();` at line 112,
  before the empty-wallets check; `ErrorWidget.builder` (lines 223-258) renders a branded recovery
  `Material` with "Go to Dashboard"; `onWindowClose` (lines 150-171) reaches
  `geniusApi.shutdownSDK()` unconditionally, with only the *webview* dispose step gated on
  `Platform.isWindows`. All three **directly confirmed by this research's own read of `main.dart`**,
  independent of `04-UI-SPEC.md`'s claim.
- **Findings 4, 5, 23** (`lib/account/account_dropdown_selector.dart`): `_confirmRenameWallet`
  (lines 49-88, `AlertDialog` + `TextField`, dispatches `RenameWallet`); `_confirmDeleteWallet`
  (lines 90-143, keep-at-least-one guard via snackbar, `AlertDialog` confirm with a red-styled
  "Delete" `TextButton`, dispatches `DeleteWallet`, re-selects a remaining wallet if the deleted one
  was selected); the whole drawer body is wrapped in `BlocBuilder<AppBloc, AppState>` (line ~151),
  so it is reactive to live state, not a static snapshot. **All directly confirmed.**
- **Findings 27, 35**: not re-verified by direct file read this session (out of this research's
  file-reading scope) — taken from `04-UI-SPEC.md`'s own citation (`router.dart:226` for `/web`;
  `network_dropdown_selector.dart:72-74` for the toast). No reason to doubt them; flagged here only
  for completeness of provenance.

**D-06 resolution, restated with exact line numbers:** develop's delete confirmation
(`account_dropdown_selector.dart:106-126`) is a real `AlertDialog` with Cancel/Delete actions and
the guard-before-dialog ordering (guard checked first, dialog shown second). This is unambiguously
already a confirmation flow — D-06's condition resolves to "develop already confirms," so this
phase's delete-dialog work is a pure re-skin (replace `AlertDialog` with `GWDialog`, keep copy and
behavior identical), not the sanctioned exception.

#### §4.1 Settings screen — component mapping confirmed live

`[VERIFIED: direct read, lib/settings/settings_screen.dart]` The `Divider(` grep hit above is real
— confirm during the GAP-02 re-skin whether removing `dividerTheme` changes any visually-adjacent
spacing/contrast now that `Card`→`GWCard` changes the surrounding surface color too (a `Divider`
tuned against develop's old `deepBlueCardColor` card fill may read differently against
`GWCard`'s `surfaceElevated`/`radiusLg` treatment).

#### §4.2 SDK account manager — component mapping confirmed live

`[VERIFIED: direct read, lib/account/sdk_account_manager.dart]` `SDKAccountManagerButton` opens via
`ResponsiveDrawer.show()`, matching `04-UI-SPEC.md` §3.2 exactly. The footer uses two
`OutlinedButton.icon` calls ("Add with mnemonic" / "Add with private key") — **no explicit inline
`style:` override on either**, unlike the `FilledButton.icon` in `account_dropdown_selector.dart`
which does override its style. This means these two specific buttons are **fully dependent** on
`outlinedButtonTheme` for padding/shape/foreground color — if the reconciled `theme.dart` drops
`outlinedButtonTheme` without a deliberate replacement, these two buttons visibly change appearance
(fall back to Material 3 defaults) as a direct, observable side effect of the theme.dart work,
independent of whether `04-2`'s GAP-03 plan touches this file's button widgets at all. Flag this as
a concrete thing to check at the D-02 re-walk or this file's own re-skin, whichever lands second.

`GWDialog` (the first real consumer this phase reaches for, per `04-UI-SPEC.md` §3.2/§5.2) is built
on a bare `Dialog`, not `AlertDialog` — it sets `backgroundColor: Colors.transparent`,
`elevation: 0`, and supplies its own `Container`/`BoxDecoration`/`Wrap` of `GWButton` actions. It
therefore **does not read `DialogThemeData` at all**, which resolves the `dialogTheme.actionsPadding`
drop non-issue for any dialog that adopts `GWDialog` (both the rename and delete flows, per D-06's
resolution above).

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Appearance-reactive top-level rebuild | A custom `InheritedWidget`/`Provider` for theme mode | `ValueListenableBuilder<GWAppearanceMode>` on `GWAppearance.instance` | Already the proven pattern in this repo (`token_probe_screen.dart`, `design_gallery_screen.dart`) — this phase is only the third use, at a higher (MaterialApp) level, not a new pattern |
| First-launch OS-appearance detection | A custom platform-channel brightness poll | `WidgetsBinding.instance.platformDispatcher.platformBrightness` (or `MediaQueryData.platformBrightness` if read post-first-frame) | Standard Flutter API for reading OS-level light/dark preference; no new dependency needed |
| Confirmation dialogs (rename/delete) | A bespoke `showModalBottomSheet` confirm flow | `GWDialog.show()` (Phase 3, first real consumer) | Already carries the token-correct container/shadow/border and a `GWDialogAction` list that maps cleanly onto a 2-button confirm/cancel shape |
| Destructive-action guard (keep-at-least-one wallet) | A new validation layer | develop's existing `if (appBloc.state.wallets.length <= 1)` guard in `_confirmDeleteWallet` | Already correct, already tested informally by the fact that findings 4/5/23 are confirmed working today — do not re-implement, only re-skin the snackbar/dialog around it |
| Nav-item selection state | A new Cubit/BLoC mirroring Alex's `NavigationOverlayCubit` | develop's existing `_currentIndex(context)` derived from `GoRouterState.of(context).uri.path` | See §2.1 — introducing a second navigation-state source is exactly the class of bug `7a63b4f` fixed (two systems racing to decide "what's selected") |

**Key insight:** every "don't hand-roll" item above already has a correct, working implementation
somewhere in this repo (either develop's own logic or Phase 2/3's already-landed primitives). This
phase's job is composition and token substitution, never new logic.

---

## Common Pitfalls

### Pitfall 1: Treating `theme.dart` as a wholesale file replacement
**What goes wrong:** Copying Alex's 309-line file over develop's 276-line file (or generating a
diff patch that effectively does the same) silently drops `floatingLabelBehavior`,
`toggleButtonsTheme`, `filledButtonTheme`, `outlinedButtonTheme`, `dialogTheme`, `menuTheme`, and
`dividerTheme` — six of which have live consumers in files this exact phase touches (§1).
**Why it happens:** "take Alex's visual wholesale" (CONTEXT.md's discretion note) reads as
permission for a full-file swap; it is permission for the *values*, not for skipping a diff against
develop's own `ThemeData` keys.
**How to avoid:** Reconcile key-by-key. For every `ThemeData` named parameter present in develop's
276 lines but absent from Alex's 309, make an explicit decision (carry forward / deliberately drop
because Material 3 default is acceptable) and record it in the plan's SUMMARY — do not let a
3-way merge or "adopt wholesale" silently resolve it by omission.
**Warning signs:** `git diff` on `theme.dart` shows large deletion blocks with no corresponding
insertion for the same `ThemeData` key.

### Pitfall 2: `GlobalSwapFabHost` ported from the reference worktree's checked-out state
**What goes wrong:** The reference worktree at `GNUS-compare/GeniusWallet-3514` is a snapshot; its
`global_swap_fab_host.dart` may or may not include `7a63b4f`'s fix depending on which commit that
worktree is checked out at (it is a separate repo/worktree from `ui-redesign-3.514-develop`, the
branch that actually carries the fix commit). Copying this file directly, or reading it without
cross-checking against `7a63b4f`'s diff, risks reintroducing the exact `!_dirty` crash this fix
exists to prevent.
**Why it happens:** "port the reference file" is the phase's general MO for every other nav-shell
file; this is the one file where that MO is actively dangerous because a *fixed* and *unfixed*
version of it exist in different places.
**How to avoid:** Write this file with the `if (!_ready) return;` guard (§3.2) present from its
first commit — do not port-then-patch. Cross-check against `git show 7a63b4f` on
`ui-redesign-3.514-develop` before considering the file done.
**Warning signs:** `_onRouteChanged` in the written file lacks an early-return keyed on `_ready`
before the `schedulerPhase` check.

### Pitfall 3: Adopting `GWAiFab` transitively via `GlobalSwapFabHost`
**What goes wrong:** If `GlobalSwapFabHost` is ported/forked without first stripping the `GWAiFab`
half, the file fails to compile (`gw_ai_fab.dart` doesn't exist in this repo) — or worse, an
executor "fixes" the compile error by also porting `gw_ai_fab.dart` and its `lib/ai/` dependency
closure, which is explicitly out of scope per WIRE-02.
**Why it happens:** The two FABs are visually and structurally coupled in Alex's single file (one
`Stack`, two `Positioned` children) — it doesn't look like two separable features from the file
alone.
**How to avoid:** If `GlobalSwapFabHost` is built this phase (pending the open question in §3.3),
build it stripped: only the `GWSwapFab` `Positioned` child, delete the `GWAiFab` positioned child
and its import entirely.
**Warning signs:** any import of `package:genius_wallet/components/buttons/gw_ai_fab.dart` or
`package:genius_wallet/ai/` anywhere in a Phase 4 commit — this should trip
`tool/verify_additive_boundary.sh`'s WIRE-tripwire-adjacent conventions even though it isn't a
literal `WIRE-` marker; a manual grep for `gw_ai_fab` should be added to this phase's own gate.

### Pitfall 4: Assuming `GWAppearance.load()` already satisfies D-03
**What goes wrong:** Since D-03 is described as a product decision (not a code task) in
`04-CONTEXT.md`, a plan could wire the `ValueListenableBuilder` (D-01's explicit task) and consider
D-03 "already handled" by the existing `load()` call — but `load()` has no OS-brightness branch at
all (§3.4). First-launch users on a light-set OS would still see dark mode.
**Why it happens:** `load()`'s docstring ("Restore the persisted mode") reads as complete; the gap
is an omission, not a bug in existing logic — there's nothing wrong to notice by reading the
docstring alone.
**How to avoid:** Add an explicit OS-brightness branch to `load()` for the no-persisted-value case
(see Code Examples). Test by clearing the Hive `preferences` box (uninstall/reinstall, or delete
the persisted key) and observing first-launch mode matches the OS setting.
**Warning signs:** the app boots to dark mode on a machine whose OS-level setting is light, with no
prior run of this app.

### Pitfall 5: Missing the settled `MenuAnchor` styling gap
**What goes wrong:** `04-UI-SPEC.md` §4.1's binding rule says to token-style the `MenuAnchor`'s
`MenuItemButton`s but doesn't explicitly call out the `MenuAnchor` container's own shape/background,
which depended on the now-dropped `menuTheme`. The re-skin could complete "the items are styled"
while the popup container itself silently reverts to an un-branded Material 3 default.
**Why it happens:** the container styling is theme-inherited, not explicit in the widget tree, so
it's easy to review the `MenuItemButton` children and consider the menu "done."
**How to avoid:** explicitly set `MenuAnchor(style: MenuStyle(...))` (or an equivalent themed
`menuStyle`) rather than relying on the now-absent `menuTheme` ThemeData key.
**Warning signs:** the context menu's corners/background look like stock Material 3 rather than
matching `GWCard`'s `radiusLg`/`surfaceElevated` treatment used elsewhere in the same drawer.

---

## Code Examples

### `main.dart` — the `ValueListenableBuilder` wrap (D-01)

`MyApp` is currently a `StatelessWidget` whose `build()` directly returns `MultiBlocProvider(...
child: MaterialApp.router(...))`. The wrap must go around `MaterialApp.router`, inside the existing
`MultiBlocProvider`/`RepositoryProvider` tree (not around the whole app — those providers don't need
to rebuild on an appearance flip):

```dart
// lib/main.dart — inside MyApp.build(), replacing the direct MaterialApp.router return
child: ValueListenableBuilder<GWAppearanceMode>(
  valueListenable: GWAppearance.instance,
  builder: (context, mode, _) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      title: 'Genius Wallet',
      theme: getThemeData(),        // re-evaluated on every appearance change
      routerConfig: geniusWalletRouter,  // stable top-level final -- not recreated
    );
  },
),
```

`GWAppearance.instance.load()` should be called once before this widget tree is reached — either in
`main()` after `initHive()` (alongside the other one-time init calls already there:
`networkProvider.loadNetworks()`, `geniusApi.loadStoredWallets()`, etc.), which avoids needing to
convert `MyApp` to a `StatefulWidget` just to call `load()` in an `initState`.

### `gw_appearance.dart` — OS-brightness fallback for D-03

```dart
// lib/theme/gw_appearance.dart
import 'dart:ui' show PlatformDispatcher, Brightness;
// ...
void load() {
  final saved = Hive.box(preferencesBoxName).get(appearanceModeKey) as String?;
  if (saved == 'light') {
    value = GWAppearanceMode.light;
  } else if (saved == 'dark') {
    value = GWAppearanceMode.dark;
  } else {
    // No persisted preference yet (genuine first launch): follow the OS setting.
    final osBrightness = PlatformDispatcher.instance.platformBrightness;
    value = osBrightness == Brightness.light
        ? GWAppearanceMode.light
        : GWAppearanceMode.dark;
  }
}
```

### `GlobalSwapFabHost` — born-fixed, stripped of `GWAiFab` (§3.1-§3.3, pending scope resolution)

```dart
// lib/components/overlay/global_swap_fab_host.dart -- IF this phase's plan resolves
// to build it (see the open question in this document). Note: no gw_ai_fab.dart import,
// no AI FAB Positioned child, and the !_ready guard present in _onRouteChanged from commit 1.
class _GlobalSwapFabHostState extends State<GlobalSwapFabHost> {
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    widget.router.routerDelegate.addListener(_onRouteChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) setState(() => _ready = true);
    });
  }

  void _onRouteChanged() {
    if (!mounted) return;
    if (!_ready) return; // <- the fix: no-op before the first frame settles the router
    if (SchedulerBinding.instance.schedulerPhase == SchedulerPhase.persistentCallbacks) {
      WidgetsBinding.instance.addPostFrameCallback((_) { if (mounted) setState(() {}); });
    } else {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready) return widget.child;
    // ... single Positioned(GWSwapFab) only -- no GWAiFab child
  }
}
```

---

## Assumptions Log

| # | Claim | Section | Risk if Wrong |
|---|-------|---------|---------------|
| A1 | Flutter's `ThemeData` merges a partial `textTheme` onto its Material-3 default rather than leaving unset slots null/unstyled | §1 (missing TextTheme slots) | Low — if wrong, unstyled text would render with no color at all (a much more visible bug), which the 04-01 re-walk would catch immediately regardless of this assumption |
| A2 | `MenuAnchor`'s popup container styling is governed by `ThemeData.menuTheme` (`MenuThemeData`) when the widget's own `style`/`menuStyle` param is unset | §1, §4.2, Pitfall 5 | Low-medium — if the actual fallback source differs (e.g. a `MenuButtonThemeData` interaction), the practical guidance (explicitly set `MenuAnchor`'s own style rather than relying on ThemeData) still holds either way |

**Both assumptions are low-risk**: in both cases, the recommended mitigation (explicit styling,
verify visually at the re-walk) is correct regardless of which exact Flutter internal mechanism is
responsible — this table is provided for provenance, not because either affects the plan's shape.

## Open Questions

1. **Is `GlobalSwapFabHost`/the global Swap FAB in scope for Phase 4 at all?**
   - What we know: `ROADMAP.md` lists `Carries: 7a63b4f` under Phase 4, and `REQUIREMENTS.md`'s
     traceability table closes BEH-02 in Phase 4. Neither of Phase 4's 6 success criteria nor
     `04-UI-SPEC.md`'s 9 sections mention this component.
   - What's unclear: whether "carries the fix" means "must introduce the file this phase" or "must
     not regress the fix whenever the file eventually lands" (and nothing currently in Phase 4's
     scope needs it).
   - Recommendation: raise with the user before planning. If in scope, plan it as an explicit,
     called-out addition (new capability, sanctioned similarly to D-06) — never as an implicit
     side effect of "porting the reference nav files." See §3.3 for the full analysis.

2. **Does the mobile shell keep develop's `AppBar` (title "Genius Wallet") once Gen B's visual
   pattern is applied, or does Gen B's bespoke `_OverlayTopBar` composition replace it?**
   - What we know: develop's `MobileOverlay` has both an `AppBar` and a `bottomNavigationBar`.
     Alex's Generation B `MobileOverlay` has no `AppBar` at all — only a custom `Row` of 3 widgets
     plus the bottom nav.
   - What's unclear: `04-UI-SPEC.md` §2.4/§2.5 describes the desktop top bar and mobile bottom nav
     in detail but does not explicitly say whether develop's mobile `AppBar` title/structure
     survives the re-skin or is replaced by Gen B's top-row composition.
   - Recommendation: keep develop's `AppBar` shell (title, action-row `Flexible`+
     `SingleChildScrollView` for the 5 action widgets) and re-skin its colors/type only — this is
     the conservative reading consistent with "re-skin, never restructure," since dropping the
     `AppBar` changes where dev tools/network selector/account selector/reown button physically
     sit. Flag as a decision to confirm during planning, not assume.

3. **Should `GWCanvasBackground` wrap the whole mobile shell body, or stay screen-scoped?**
   - What we know: Gen B's `MobileOverlay` wraps its entire body in `GWCanvasBackground`. Phase 3
     only ever instantiated this component in the design gallery (a bounded demo box), never at a
     whole-shell scope.
   - What's unclear: whether this is part of "Alex's visual" that should be taken wholesale, or an
     example of Gen B's file being more than a token re-skin (a structural layout decision).
   - Recommendation: treat as a discretionary call, but require it be a deliberate, recorded choice
     in the plan's SUMMARY (per D-04/D-05's pattern of not letting design choices happen silently).

---

## Validation Architecture

> This project has no working `flutter test` harness (APP-02, deferred to v2) and every phase's
> own precedent (`02-VERIFICATION.md`, `03-VERIFICATION.md`) treats `flutter analyze` as a gate,
> never evidence. This section maps Phase 4's 6 criteria + BEH-02 + the 8 findings + D-01/D-02's
> re-walk gate onto **observable-by-running-the-app** checks, not tests.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | None (`flutter test` does not compile — APP-02) |
| Config file | none — see mechanical gates below |
| Quick run command | `flutter analyze lib` (0-errors gate; never evidence of runtime correctness) |
| Full suite command | `bash tool/verify_additive_boundary.sh` (shadow-import boundary + duplicate-class census + WIRE- tripwire) + a debug-build human walk (below) |

### Phase Requirements → Observation Map

| Req/Criterion | Behavior | Observation method | Command / Recipe |
|---|---|---|---|
| D-01/D-02 gate | Theme flips live, gallery re-walked, dark-only count derived | Human walk, both appearance modes | `flutter run -d windows --debug --dart-define=GW_DEV_TOOLS=true` → `Dev` → `Gallery` → toggle appearance icon → walk all 30 sections; **this gate must close before any other criterion below is attempted** |
| Criterion 1 (`!_dirty`, boot, every route reachable) | No crash on boot or on navigating every `go_router` route | Human walk | Cold `flutter run -d windows --debug` (no dart-define — real user path), navigate to every one of the 8 shell destinations plus every non-shell route reachable from them |
| Criterion 2 (shell skin, desktop rail/mobile bottom nav, Web tab lands correctly) | Visual match to reference; every route still reachable; `/web` resolves correctly | Human walk + side-by-side with Release exe | Resize window across 1024px (the real desktop/mobile shell breakpoint per §2.4) and confirm the flip; separately resize across 768px only if the drawer is opened (a different breakpoint, §5.1) |
| Criterion 3 (`loadStoredWallets()` at boot) | Wallets present on dashboard immediately after cold start | Human walk | Cold start (not hot reload — this is a boot-sequencing behavior), land on `/dashboard`, confirm wallet balances render without a manual refresh |
| Criterion 4 (rename/delete/guard/re-select/live-update/toast) | All 6 sub-behaviors observable | Human walk, scripted sub-steps | Open account drawer → rename a wallet (confirm dialog, name updates) → attempt delete down to 1 wallet (confirm guard snackbar fires) → delete a non-selected wallet (confirm list updates live while drawer stays open) → delete the selected wallet (confirm another auto-selects) → switch network (confirm "Network Changed" toast) |
| Criterion 5 (Settings + SDK account manager re-skinned, behavior intact) | Visual match; every existing settings action (Apply/Save, log level change, config toggle) still works; SDK account add/select/delete still works | Human walk | Open Settings from the shell, exercise each of its 3 sections' primary action; open the SDK account manager drawer, add an account via each footer button, select/delete an account |
| Criterion 6 (branded exception screen; SDK shutdown) | Deliberately-triggered build-time exception renders the branded screen (both appearance modes); window close reaches `shutdownSDK()` | Human walk, deliberate fault injection | Trigger a build-time exception (e.g., a deliberately-thrown error in a widget's `build()` during a debug session) in both light and dark mode; separately, close the app window and confirm the debug console logs `"Window closed. GeniusApi shutdown: ..."` before the process exits |
| BEH-02 (`!_dirty` / `GlobalSwapFabHost`) | If built this phase (pending Open Question 1): no `!_dirty` assertion on cold boot | Human walk | Cold `flutter run -d windows --debug`, confirm no `ErrorWidget`/`"'!_dirty': is not true"` in console on first launch |

### Sampling Rate
- **Per task commit:** `flutter analyze lib` (0 errors) — mechanical shape check only.
- **Per plan (theme-only 04-01):** the D-02 re-walk — this is not optional and is the gate for
  every subsequent plan in this phase.
- **Per plan (shell/screen re-skins, 04-02+):** `bash tool/verify_additive_boundary.sh` (confirm the
  shadow-import allowlist and duplicate-class census haven't drifted) + a targeted human walk of
  just that plan's surface, both appearance modes.
- **Phase gate:** the full criteria table above, both appearance modes, immediately before
  `/gsd-verify-work` — per D-03, a light-mode failure on any of these 6 criteria blocks phase close;
  it cannot be deferred the way Phase 3's theme-confound gaps were.

### Wave 0 Gaps
- No test file gaps — there is no test infrastructure to extend (APP-02 stands).
- One tooling gap worth considering (not a blocker): add a manual `grep -rn "gw_ai_fab\|lib/ai/" lib/components/overlay/` check to whatever plan touches `GlobalSwapFabHost` (if built), since Phase 3's `verify_additive_boundary.sh` does not know about this specific coupling risk (it only tripwires literal `WIRE-` string markers, not import-graph reachability into `lib/ai/`).

*(No automated framework gaps beyond the above — this project's validation spine is the human walk,
consistent with Phases 2 and 3.)*

---

## Security Domain

`security_enforcement: true`, `security_asvs_level: 1` per `.planning/config.json`. This phase is a
UI/chrome re-skin with no new authentication, session, or cryptographic code — most ASVS categories
are not newly implicated. Two surfaces this phase touches carry pre-existing sensitivity and are
worth naming explicitly (both are **re-skin only**, no logic change):

### Applicable ASVS Categories

| ASVS Category | Applies | Standard Control |
|---|---|---|
| V2 Authentication | No | This phase has no login/auth flow |
| V3 Session Management | No | No session tokens touched |
| V4 Access Control | No | No permission/role logic touched |
| V5 Input Validation | Marginal | Wallet rename `TextField` — develop's existing validation (or lack thereof) is unchanged; not this phase's job to add validation, only to re-skin the field with `GWTextField` |
| V6 Cryptography | Marginal | SDK account manager's "Add with mnemonic"/"Add with private key" dialogs handle key material — **this phase re-skins the dialog chrome only; the underlying FFI calls into the native SDK are untouched.** No key material should ever appear in a `debugPrint`/log statement introduced by this phase's re-skin work — verify no new `print`/`debugPrint` call is added anywhere in `sdk_account_manager.dart`'s dialog flow |

### Known Threat Patterns for this stack

| Pattern | STRIDE | Standard Mitigation |
|---|---|---|
| Accidental logging of mnemonic/private-key input during dialog re-skin | Information Disclosure | Do not add any `debugPrint`/`print`/logging call inside the mnemonic or private-key entry dialogs while converting them to `GWTextField`/`GWDialog` — grep for new logging calls in this file's diff before considering the plan done |
| Copy-address action leaking to system clipboard history | Information Disclosure (low severity, pre-existing) | Already develop's existing behavior (`Clipboard.setData` in the "Copy address" menu item) — not introduced by this phase, not this phase's job to change |

---

## Sources

### Primary (HIGH confidence — direct file reads this session)
- `lib/theme/theme.dart` (develop) — full file read
- `GNUS-compare/GeniusWallet-3514/lib/theme/theme.dart` (Alex) — full file read
- `lib/main.dart` — full file read (findings 2, 11, 12; the D-01 wrap site)
- `lib/navigation/router.dart` — full file read (`ShellRoute`, 8-destination confirmation)
- `lib/components/overlay/responsive_overlay.dart` — full file read (`_allDestinations`, `_currentIndex`, `_DesktopTopBar`, `MobileOverlay`)
- `lib/account/account_dropdown_selector.dart` — full file read (findings 4, 5, 23; D-06 resolution)
- `lib/account/sdk_account_manager.dart` (partial, ~140 lines) — component mapping confirmation
- `lib/components/overlays/gw_dialog.dart` — full file read (`GWDialog`'s `Dialog`-not-`AlertDialog` construction)
- `lib/theme/gw_appearance.dart` — full file read (the `load()` gap, §3.4)
- `lib/dev/token_probe_screen.dart` — full file read (the proven `ValueListenableBuilder` pattern)
- `lib/theme/genius_wallet_colors.dart`, `lib/theme/genius_wallet_consts.dart`, `lib/theme/genius_wallet_typography.dart` — targeted reads (token existence, `appBarHeight`, `toMaterialTextTheme()` coverage)
- `lib/utils/breakpoints.dart` — full file read (breakpoint confirmation, §2.4)
- `GNUS-compare/GeniusWallet-3514/lib/components/overlay/{destinations,gw_bottom_nav,desktop_overlay,mobile_overlay,desktop_tab_bar,genius_destination,global_swap_fab_host}.dart` — full file reads (Gen A/B analysis, §2; `GlobalSwapFabHost`, §3)
- `git show 7a63b4f` — full commit read (the `!_dirty` fix, §3.1-§3.2)
- Grep sweeps across `lib/` for `ToggleButtons(`, `FilledButton`, `OutlinedButton`, `Divider(`, `AlertDialog(`, `MenuAnchor|MenuItemButton`, `NavigationRail(` — used to find every live consumer of the six dropped `ThemeData` sections and confirm "desktop rail" isn't a literal widget anywhere

### Secondary (MEDIUM confidence)
- `.planning/phases/04-navigation-shell-chrome/04-UI-SPEC.md` — approved design contract, cross-checked against direct file reads rather than trusted at face value (found the Gen A/B Cubit gap and the `GlobalSwapFabHost` scope question this way)
- `.planning/phases/03-gw-component-library/03-VERIFICATION.md`, `03-09-SUMMARY.md` — Phase 3's verification record, used for the theme-confound findings and the excluded-file list

### Tertiary (LOW confidence)
- None — every claim in this document traces to a direct read or a git command run this session,
  except the two items in the Assumptions Log (Flutter framework merge/fallback behavior, not
  re-verified via an external tool this session).

## Metadata

**Confidence breakdown:**
- Theme reconciliation hazards (§1): HIGH — every dropped `ThemeData` key and its live consumers
  confirmed by direct file read and grep, not inferred
- Nav-shell synthesis (§2): HIGH — both generations read directly; the Cubit dependency and
  `PreferencesButton`/WIRE-02 coupling independently re-derived, not copied from the UI-SPEC
- `!_dirty`/`GlobalSwapFabHost` (§3): HIGH for the technical mechanism (read directly from the fix
  commit); MEDIUM for the scope question (§3.3, Open Question 1) — this is a genuine ambiguity in
  the phase's own planning documents, not a research gap
- Validation architecture: HIGH — directly extrapolated from Phases 2/3's own established,
  precedented walk protocol

**Research date:** 2026-07-17
**Valid until:** Should remain valid for the life of this phase (no external dependency, no
fast-moving library version risk) — re-check only if `04-UI-SPEC.md` or `04-CONTEXT.md` change
before planning begins.
